/*
 * fcgi.c
 * Copyright (C) 1998-1999  Network Applied Communication Laboratory, Inc.
 * Copyright (C) 2002-2006  MoonWolf <moonwolf@moonwolf.com>
 */

#include <stdio.h>
#include <sys/types.h>
#include <unistd.h>
#include <errno.h>
#include <fcntl.h>

#include "ruby.h"
#ifdef HAVE_FASTCGI_FCGIAPP_H
#include <fastcgi/fcgiapp.h>
#else
#include "fcgiapp.h"
#endif

static VALUE cFCGI;
static VALUE eFCGIError;
static VALUE cFCGIStream;
static VALUE eFCGIStreamError;
static VALUE eFCGIStreamUnsupportedVersionError;
static VALUE eFCGIStreamProtocolError;
static VALUE eFCGIStreamParamsError;
static VALUE eFCGIStreamCallSeqError;

typedef struct fcgi_data {
  FCGX_Request *req;
  VALUE in;
  VALUE out;
  VALUE err;
  VALUE env;
} fcgi_data;

static void fcgi_mark(fcgi_data *data)
{
/*  rb_gc_mark(data->req); */
  rb_gc_mark(data->in);
  rb_gc_mark(data->out);
  rb_gc_mark(data->err);
  rb_gc_mark(data->env);
}

static void fcgi_free_req(fcgi_data *data)
{
  free(data->req);
  free(data);
}

static VALUE fcgi_s_accept(VALUE self)
{
  int status;
  FCGX_Request *req;
  fd_set readfds;
  
  req = ALLOC(FCGX_Request);
  
  status = FCGX_InitRequest(req,0,0);
  if (status != 0) {
    rb_raise(eFCGIError, "FCGX_Init() failed");
    return Qnil;
  }

  FD_ZERO(&readfds);
  FD_SET(req->listen_sock, &readfds);
  if (rb_thread_select(req->listen_sock+1, &readfds, NULL, NULL, NULL) < 1) {
    return Qnil;
  }
  
  status = FCGX_Accept_r(req);
  if (status >= 0) {
    fcgi_data *data;
    char      **env;
    VALUE     obj,key, value;
    char      *pkey,*pvalue;
    int       flags, fd;

    /* Unset NONBLOCKING */
    fd = ((FCGX_Request*) req)->ipcFd;
    flags = fcntl(fd, F_GETFL);

    if (flags & O_NONBLOCK) {
       fcntl(fd, F_SETFL, flags & ~O_NONBLOCK);
    }
    
    obj = Data_Make_Struct(self, fcgi_data, fcgi_mark, fcgi_free_req, data);
    data->req = req;
    data->in  = Data_Wrap_Struct(cFCGIStream, 0, 0, req->in);
    data->out = Data_Wrap_Struct(cFCGIStream, 0, 0, req->out);
    data->err = Data_Wrap_Struct(cFCGIStream, 0, 0, req->err);
    data->env = rb_hash_new();
    env = req->envp;
    for (; *env; env++) {
      int size = 0;
      pkey = *env;
      pvalue = pkey;
      while( *(pvalue++) != '=') size++;
      key   = rb_str_new(pkey, size);
      value = rb_str_new2(pvalue);
      OBJ_TAINT(key);
      OBJ_TAINT(value);
      rb_hash_aset(data->env, key, value);
    }
    
    return obj;
  } else {
    return Qnil;
  }
}

static VALUE fcgi_s_each(VALUE self)
{
  VALUE fcgi;
  
  while ((fcgi = fcgi_s_accept(self)) != Qnil) {
    rb_yield(fcgi);
  }
  return Qnil;
}

static VALUE fcgi_s_iscgi(VALUE self)
{
  if (FCGX_IsCGI()) {
    return Qtrue;
  } else {
    return Qfalse;
  }
}

static VALUE fcgi_in(VALUE self)
{
  fcgi_data *data;

  Data_Get_Struct(self, fcgi_data, data);
  return data->in;
}

static VALUE fcgi_out(VALUE self)
{
  fcgi_data *data;

  Data_Get_Struct(self, fcgi_data, data);
  return data->out;
}

static VALUE fcgi_err(VALUE self)
{
  fcgi_data *data;

  Data_Get_Struct(self, fcgi_data, data);
  return data->err;
}

static VALUE fcgi_env(VALUE self)
{
  fcgi_data *data;

  Data_Get_Struct(self, fcgi_data, data);
  return data->env;
}

static VALUE fcgi_finish(VALUE self)
{
  fcgi_data *data;
  
  Data_Get_Struct(self, fcgi_data, data);
  
  FCGX_Finish_r(data->req);
  
  return Qtrue;
}

#define CHECK_STREAM_ERROR(stream) {\
  int err = FCGX_GetError(stream);\
	extern int errno; \
  if (err) {\
    if (err > 0) {\
			errno = err;\
      rb_sys_fail(NULL);\
    }\
    else {\
      switch (err) {\
      case FCGX_UNSUPPORTED_VERSION:\
        rb_raise(eFCGIStreamUnsupportedVersionError, "unsupported version");\
        break;\
      case FCGX_PROTOCOL_ERROR:\
        rb_raise(eFCGIStreamProtocolError, "protocol error");\
        break;\
      case FCGX_PARAMS_ERROR:\
        rb_raise(eFCGIStreamProtocolError, "parameter error");\
        break;\
      case FCGX_CALL_SEQ_ERROR:\
        rb_raise(eFCGIStreamCallSeqError, "preconditions are not met");\
        break;\
      default:\
        rb_raise(eFCGIStreamError, "unknown error");\
        break;\
      }\
    }\
  }\
}

static VALUE fcgi_stream_putc(VALUE self, VALUE ch)
{
  FCGX_Stream *stream;
  int c;

  rb_secure(4);
  Data_Get_Struct(self, FCGX_Stream, stream);
  if ((c = FCGX_PutChar(NUM2INT(ch), stream)) == EOF)
    CHECK_STREAM_ERROR(stream);
  return INT2NUM(c);
}

static VALUE fcgi_stream_write(VALUE self, VALUE str)
{
  FCGX_Stream *stream;
  int len;

  rb_secure(4);
  Data_Get_Struct(self, FCGX_Stream, stream);
  str = rb_obj_as_string(str);
  len = FCGX_PutStr(RSTRING(str)->ptr, RSTRING(str)->len, stream);
  if (len == EOF) CHECK_STREAM_ERROR(stream);
  return INT2NUM(len);
}

static VALUE fcgi_stream_print(int argc, VALUE *argv, VALUE out)
{
  int i;
  VALUE line;

  /* if no argument given, print `$_' */
  if (argc == 0) {
    argc = 1;
    line = rb_lastline_get();
    argv = &line;
  }
  for (i=0; i<argc; i++) {
    if (!NIL_P(rb_output_fs) && i>0) {
      fcgi_stream_write(out, rb_output_fs);
    }
    switch (TYPE(argv[i])) {
    case T_NIL:
      fcgi_stream_write(out, rb_str_new2("nil"));
      break;
    default:
      fcgi_stream_write(out, argv[i]);
      break;
    }
  }
  if (!NIL_P(rb_output_rs)) {
    fcgi_stream_write(out, rb_output_rs);
  }

  return Qnil;
}

static VALUE fcgi_stream_printf(int argc, VALUE *argv, VALUE out)
{
  fcgi_stream_write(out, rb_f_sprintf(argc, argv));
  return Qnil;
}

static VALUE fcgi_stream_puts _((int, VALUE*, VALUE));

static VALUE fcgi_stream_puts_ary(VALUE ary, VALUE out)
{
  VALUE tmp;
  int i;

  for (i=0; i<RARRAY(ary)->len; i++) {
    tmp = RARRAY(ary)->ptr[i];
    if (rb_inspecting_p(tmp)) {
      tmp = rb_str_new2("[...]");
    }
    fcgi_stream_puts(1, &tmp, out);
  }
  return Qnil;
}

static VALUE fcgi_stream_puts(int argc, VALUE *argv, VALUE out)
{
  int i;
  VALUE line;

  /* if no argument given, print newline. */
  if (argc == 0) {
    fcgi_stream_write(out, rb_default_rs);
    return Qnil;
  }
  for (i=0; i<argc; i++) {
    switch (TYPE(argv[i])) {
    case T_NIL:
      line = rb_str_new2("nil");
      break;
    case T_ARRAY:
      rb_protect_inspect(fcgi_stream_puts_ary, argv[i], out);
      continue;
    default:
      line = argv[i];
      break;
    }
    line = rb_obj_as_string(line);
    fcgi_stream_write(out, line);
    if (RSTRING(line)->ptr[RSTRING(line)->len-1] != '\n') {
      fcgi_stream_write(out, rb_default_rs);
    }
  }

  return Qnil;
}

static VALUE fcgi_stream_addstr(VALUE out, VALUE str)
{
  fcgi_stream_write(out, str);
  return out;
}

static VALUE fcgi_stream_flush(VALUE self)
{
  FCGX_Stream *stream;

  Data_Get_Struct(self, FCGX_Stream, stream);
  if (FCGX_FFlush(stream) == EOF)
    CHECK_STREAM_ERROR(stream);
  return Qnil;
}

static VALUE fcgi_stream_getc(VALUE self)
{
  FCGX_Stream *stream;
  int c;

  Data_Get_Struct(self, FCGX_Stream, stream);
  if ((c = FCGX_GetChar(stream)) == EOF) {
    CHECK_STREAM_ERROR(stream);
    return Qnil;
  }
  else {
    return INT2NUM(c);
  }
}

static VALUE fcgi_stream_ungetc(VALUE self, VALUE ch)
{
  FCGX_Stream *stream;
  int c;

  if (rb_safe_level() >= 4 && !OBJ_TAINTED(self)) {
    rb_raise(rb_eSecurityError, "Insecure: operation on untainted IO");
  }
  Data_Get_Struct(self, FCGX_Stream, stream);
  c = FCGX_UnGetChar(NUM2INT(ch), stream);
  CHECK_STREAM_ERROR(stream);
  return INT2NUM(c);
}

static VALUE fcgi_stream_gets(VALUE self)
{
  FCGX_Stream *stream;
  char buff[BUFSIZ];
  VALUE str = rb_str_new("", 0);
  OBJ_TAINT(str);

  if (rb_safe_level() >= 4 && !OBJ_TAINTED(self)) {
    rb_raise(rb_eSecurityError, "Insecure: operation on untainted IO");
  }

  Data_Get_Struct(self, FCGX_Stream, stream);

  for (;;) {
    if (FCGX_GetLine(buff, BUFSIZ, stream) == NULL) {
      CHECK_STREAM_ERROR(stream);
      break;
    }
    rb_str_cat(str, buff, strlen(buff));
    if (strchr(buff, '\n')) break;
  }
  if (RSTRING(str)->len > 0)
    return str;
  else
    return Qnil;
}

static VALUE fcgi_stream_read(int argc, VALUE *argv, VALUE self)
{
  VALUE num,str;
  FCGX_Stream *stream;
  char *buff;
  int n;

  if (rb_safe_level() >= 4 && !OBJ_TAINTED(self)) {
    rb_raise(rb_eSecurityError, "Insecure: operation on untainted IO");
  }

  Data_Get_Struct(self, FCGX_Stream, stream);

  if (argc==0) {
    buff = ALLOC_N(char, 16384);
    n = FCGX_GetStr(buff, 16384, stream);
    CHECK_STREAM_ERROR(stream);
    if (n == 0) {
      free(buff);
      return  Qnil;
    }
    str = rb_str_new(buff, n);
    OBJ_TAINT(str);
    
    while(!FCGX_HasSeenEOF(stream)) {
      n = FCGX_GetStr(buff, 16384, stream);
      CHECK_STREAM_ERROR(stream);
      if (n > 0) {
        rb_str_cat(str, buff, n);
      } else {
        free(buff);
        return Qnil;
      }
    }
    free(buff);
    return str;
  }

  num = argv[0];
  n = NUM2INT(num);

  buff = ALLOC_N(char, n);
  n = FCGX_GetStr(buff, n, stream);
  CHECK_STREAM_ERROR(stream);
  if (n > 0) {
    str = rb_str_new(buff, n);
    OBJ_TAINT(str);
    free(buff);
    return str;
  }
  else {
    free(buff);
    return Qnil;
  }
}

static VALUE fcgi_stream_eof(VALUE self)
{
  FCGX_Stream *stream;

  if (rb_safe_level() >= 4 && !OBJ_TAINTED(self)) {
    rb_raise(rb_eSecurityError, "Insecure: operation on untainted IO");
  }
  Data_Get_Struct(self, FCGX_Stream, stream);
  return FCGX_HasSeenEOF(stream) ? Qtrue : Qfalse;
}

static VALUE fcgi_stream_close(VALUE self)
{
  FCGX_Stream *stream;

  if (rb_safe_level() >= 4 && !OBJ_TAINTED(self)) {
    rb_raise(rb_eSecurityError, "Insecure: can't close");
  }
  Data_Get_Struct(self, FCGX_Stream, stream);
  if (FCGX_FClose(stream) == EOF)
    CHECK_STREAM_ERROR(stream);
  return Qnil;
}

static VALUE fcgi_stream_closed(VALUE self)
{
  FCGX_Stream *stream;

  Data_Get_Struct(self, FCGX_Stream, stream);
  return stream->isClosed ? Qtrue : Qfalse;
}

static VALUE fcgi_stream_binmode(VALUE self)
{
  if (rb_safe_level() >= 4 && !OBJ_TAINTED(self)) {
    rb_raise(rb_eSecurityError, "Insecure: operation on untainted IO");
  }
  return self;
}

static VALUE fcgi_stream_isatty(VALUE self)
{
  if (rb_safe_level() >= 4 && !OBJ_TAINTED(self)) {
    rb_raise(rb_eSecurityError, "Insecure: operation on untainted IO");
  }
  return Qfalse;
}

static VALUE fcgi_stream_sync(VALUE self)
{
  if (rb_safe_level() >= 4 && !OBJ_TAINTED(self)) {
    rb_raise(rb_eSecurityError, "Insecure: operation on untainted IO");
  }
  return Qfalse;
}

static VALUE fcgi_stream_setsync(VALUE self,VALUE sync)
{
  if (rb_safe_level() >= 4 && !OBJ_TAINTED(self)) {
    rb_raise(rb_eSecurityError, "Insecure: operation on untainted IO");
  }
  return Qfalse;
}



void Init_fcgi() {
  
  FCGX_Init();
  
  cFCGI = rb_define_class("FCGI", rb_cObject);
  eFCGIError =rb_define_class_under(cFCGI, "Error", rb_eStandardError);
  rb_define_singleton_method(cFCGI, "accept", fcgi_s_accept, 0);
  rb_define_singleton_method(cFCGI, "each", fcgi_s_each, 0);
  rb_define_singleton_method(cFCGI, "each_request", fcgi_s_each, 0);
  rb_define_singleton_method(cFCGI, "is_cgi?", fcgi_s_iscgi, 0);
  rb_define_method(cFCGI, "in",  fcgi_in, 0);
  rb_define_method(cFCGI, "out", fcgi_out, 0);
  rb_define_method(cFCGI, "err", fcgi_err, 0);
  rb_define_method(cFCGI, "env", fcgi_env, 0);
  rb_define_method(cFCGI, "finish", fcgi_finish, 0);
  
  cFCGIStream = rb_define_class_under(cFCGI, "Stream", rb_cObject);
  eFCGIStreamError =rb_define_class_under(cFCGIStream, "Error", rb_eStandardError);
  eFCGIStreamUnsupportedVersionError =
    rb_define_class_under(cFCGIStream, "UnsupportedVersionError",
                          eFCGIStreamError);
  eFCGIStreamProtocolError = rb_define_class_under(cFCGIStream, "ProtocolError",
                                                   eFCGIStreamError);
  eFCGIStreamParamsError = rb_define_class_under(cFCGIStream, "ParamsError",
                                                 eFCGIStreamError);
  eFCGIStreamCallSeqError = rb_define_class_under(cFCGIStream, "CallSeqError",
                                                  eFCGIStreamError);
  rb_undef_method(CLASS_OF(cFCGIStream), "new");
  rb_define_method(cFCGIStream, "putc", fcgi_stream_putc, 1);
  rb_define_method(cFCGIStream, "write", fcgi_stream_write, 1);
  rb_define_method(cFCGIStream, "print", fcgi_stream_print, -1);
  rb_define_method(cFCGIStream, "printf", fcgi_stream_printf, -1);
  rb_define_method(cFCGIStream, "puts", fcgi_stream_puts, -1);
  rb_define_method(cFCGIStream, "<<", fcgi_stream_addstr, 1);
  rb_define_method(cFCGIStream, "flush", fcgi_stream_flush, 0);
  rb_define_method(cFCGIStream, "getc", fcgi_stream_getc, 0);
  rb_define_method(cFCGIStream, "ungetc", fcgi_stream_ungetc, 1);
  rb_define_method(cFCGIStream, "gets", fcgi_stream_gets, 0);
  rb_define_method(cFCGIStream, "read", fcgi_stream_read, -1);
  rb_define_method(cFCGIStream, "eof", fcgi_stream_eof, 0);
  rb_define_method(cFCGIStream, "eof?", fcgi_stream_eof, 0);
  rb_define_method(cFCGIStream, "close", fcgi_stream_close, 0);
  rb_define_method(cFCGIStream, "closed?", fcgi_stream_closed, 0);
  rb_define_method(cFCGIStream, "binmode", fcgi_stream_binmode, 0);
  rb_define_method(cFCGIStream, "isatty", fcgi_stream_isatty, 0);
  rb_define_method(cFCGIStream, "tty?", fcgi_stream_isatty, 0);
  rb_define_method(cFCGIStream, "sync", fcgi_stream_sync, 0);
  rb_define_method(cFCGIStream, "sync=", fcgi_stream_setsync, 1);
}
