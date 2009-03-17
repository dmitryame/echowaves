/*
 * Ruby Rendezvous Binding
 * $Id: rdnssd_service.c,v 1.24 2005/03/22 00:19:37 cmills Exp $
 *
 * Copyright (c) 2004 Chad Fowler, Charles Mills, Rich Kilmer
 * Licenced under the same terms as Ruby.
 * This software has absolutely no warranty.
 */

#include "rdnssd.h"
#include <assert.h>

#ifndef DNSSD_API
	/* define as nothing if not defined in Apple's "dns_sd.h" header  */
	#define DNSSD_API 
#endif

static VALUE cDNSSDService;
static ID dnssd_id_call;
static ID dnssd_id_to_str;
static ID dnssd_iv_block;
static ID dnssd_iv_thread;
static ID dnssd_iv_result;
static ID dnssd_iv_service;

#define IsDNSSDService(obj) (rb_obj_is_kind_of(obj,cDNSSDService)==Qtrue)
#define GetDNSSDService(obj, var) \
	do { assert(IsDNSSDService(obj)); Data_Get_Struct(obj, DNSServiceRef, var); } while (0)

void
dnssd_callback(VALUE service, VALUE reply)
{
  VALUE result = rb_funcall2( rb_ivar_get(service, dnssd_iv_block),
															dnssd_id_call, 1, &reply );
  rb_ivar_set(service, dnssd_iv_result, result);
}

static const char *
dnssd_get_domain(VALUE service_domain)
{
	const char *domain = StringValueCStr(service_domain);
	/* max len including the null terminator and trailing '.' */
	if (RSTRING(service_domain)->len >= kDNSServiceMaxDomainName - 1)
		rb_raise(rb_eArgError, "domain name string too large");
	return domain;
}

static uint32_t
dnssd_get_interface_index(VALUE interface)
{
	/* if the interface is a string then convert it to the interface index */
	if (rb_respond_to(interface, dnssd_id_to_str)) {
		return if_nametoindex(StringValueCStr(interface));
	} else {
		return (uint32_t)NUM2ULONG(interface);
	}
}

/*
 * call-seq:
 *    DNSSD::Service.fullname(name, type, domain) => string
 *
 * Concatenate a three-part domain name (as seen in DNSSD::Reply#fullname())
 * into a properly-escaped full domain name.
 *
 * Any dots or slashes in the _name_ must NOT be escaped.
 * May be <code>nil</code> (to construct a PTR record name, e.g. "_ftp._tcp.apple.com").
 *
 * The _type_ is the service type followed by the protocol, separated by a dot (e.g. "_ftp._tcp").
 *
 * The _domain_ is the domain name, e.g. "apple.com".  Any literal dots or backslashes
 * must be escaped.
 *
 * Raises a <code>ArgumentError</code> if the full service name cannot be constructed from
 * the arguments.
 */
static VALUE
dnssd_service_s_fullname(VALUE klass, VALUE name, VALUE type, VALUE domain)
{
	return dnssd_create_fullname( StringValueCStr(name), StringValueCStr(type),
																StringValueCStr(domain), 1 );
}

/*
 * call-seq:
 *    DNSSD::Service.split(fullname)           => array 
 *    DNSSD::Service.split_fullname(fullname)  => array
 *
 * Split a properly escaped multi-part domain name (as seen in DNSSD::Reply#fullname())
 * into an array of names.
 *
 *    DNSSD::Service.split('_http._tcp.local.') #=> ["_http.", "_tcp.", "local."]
 */
static VALUE
dnssd_service_s_split(VALUE klass, VALUE fullname)
{
	return dnssd_split_fullname(fullname);
}

/*
 * call-seq:
 *    DNSSD::Service.new() => raises a RuntimeError
 *
 * Services can only be instantiated using DNSSD.enumerate_domains(),
 * DNSSD.browse(), DNSSD.register(), and DNSSD.resolve().
 */
static VALUE
dnssd_service_new(int argc, VALUE *argv, VALUE klass)
{
	dnssd_instantiation_error(rb_class2name(klass));
	return Qnil;
}

static void
dnssd_service_free_client(DNSServiceRef *client)
{
  DNSServiceRefDeallocate(*client);
	free(client); /* free the pointer */
}

static void
dnssd_service_free(void *ptr)
{
	DNSServiceRef *client = (DNSServiceRef*)ptr;
	if (client) {
		/* client will be non-null only if client has not been deallocated */
		dnssd_service_free_client(client);
	}
}

static VALUE
dnssd_service_alloc(VALUE block)
{
  DNSServiceRef *client = ALLOC(DNSServiceRef);
	VALUE service = Data_Wrap_Struct(cDNSSDService, 0, dnssd_service_free, client);
  rb_ivar_set(service, dnssd_iv_block, block);
  rb_ivar_set(service, dnssd_iv_thread, Qnil);
  rb_ivar_set(service, dnssd_iv_result, Qnil);
	return service;
}

/*
 * call-seq:
 *    service.stopped? => true or false
 *
 * Returns <code>true</code> if _service_ has been stopped, <code>false</code> otherwise.
 */
static VALUE
dnssd_service_is_stopped(VALUE service)
{
	DNSServiceRef *client = (DNSServiceRef*)RDATA(service)->data;
  return client == NULL ? Qtrue : Qfalse;
}

/*
 * call-seq:
 *    service.stop => service
 *
 * Stops _service_ closing the underlying socket and killing
 * the underlying thread.
 * 
 * It is good practice to all stop running services before exit.
 *
 *    service = DNSSD.browse('_http._tcp') do |r|
 *        # found a service ...
 *    end
 *    sleep(2)
 *    service.stop
 *
 */
static VALUE
dnssd_service_stop(VALUE service)
{
	VALUE thread;
	DNSServiceRef *client = (DNSServiceRef*)RDATA(service)->data;
	/* set to null right away for a bit more thread safety */
	RDATA(service)->data = NULL;
	if (client == NULL) rb_raise(rb_eRuntimeError, "service is already stopped");
	dnssd_service_free_client(client);
	thread = rb_ivar_get(service, dnssd_iv_thread);
  rb_ivar_set(service, dnssd_iv_block, Qnil);
  rb_ivar_set(service, dnssd_iv_thread, Qnil);
	
	if (!NIL_P(thread)) {
		/* will raise error if thread is not a Ruby Thread */
		rb_thread_kill(thread);
	}
  return service;
}

static VALUE
dnssd_service_process(VALUE service)
{
  int dns_sd_fd, nfds, result;
  fd_set readfds;

  DNSServiceRef *client;
  GetDNSSDService(service, client);

  dns_sd_fd = DNSServiceRefSockFD(*client);
  nfds = dns_sd_fd + 1;
  for ( ;; ) {
    FD_ZERO(&readfds);
    FD_SET(dns_sd_fd, &readfds);
    result = rb_thread_select(nfds, &readfds,
															(fd_set *) NULL,
															(fd_set *) NULL,
															(struct timeval *) NULL);
    if (result > 0) {
      if ( FD_ISSET(dns_sd_fd, &readfds) ) {
				DNSServiceErrorType e = DNSServiceProcessResult(*client);
				dnssd_check_error_code(e);
      }
    } else {
      break;
    }
  }
	/* return the result from the processing */
	return rb_ivar_get(service, dnssd_iv_result);
}

/* stop the service only if it is still running */
static VALUE
dnssd_service_stop2(VALUE service)
{
	if (dnssd_service_is_stopped(service)) {
		return service;
	}
	return dnssd_service_stop(service);
}

static VALUE
dnssd_service_start(VALUE service)
{
	return rb_ensure(dnssd_service_process, service, dnssd_service_stop2, service);
}

static VALUE
dnssd_service_start_in_thread(VALUE service)
{
	/* race condition - service.@block could be called before the service.@thread
	 * is set and if the block calls service.stop() will raise an error, even though
	 * the service has been started and is running. */
  VALUE thread = rb_thread_create(dnssd_service_process, (void *)service);
  rb_ivar_set(service, dnssd_iv_thread, thread);
	/* !! IMPORTANT: prevents premature garbage collection of the service,
	 * this way the thread holds a reference to the service and
	 * the service gets marked as long as the thread is running.
	 * Running threads are always marked by Ruby. !! */
	rb_ivar_set(thread, dnssd_iv_service, service);
	return service;
}

/*
 * call-seq:
 *    service.inspect => string
 *
 */
static VALUE
dnssd_service_inspect(VALUE self)
{
	VALUE buf = rb_str_buf_new(32);
	rb_str_buf_cat2(buf, "<#");
	rb_str_buf_cat2(buf, rb_obj_classname(self));
	if (dnssd_service_is_stopped(self)) {
		rb_str_buf_cat2(buf, " (stopped)");
	}
	rb_str_buf_cat2(buf, ">");
	return buf;
}

static void DNSSD_API
dnssd_domain_enum_reply(DNSServiceRef sdRef, DNSServiceFlags flags,
												uint32_t interface_index, DNSServiceErrorType e,
												const char *domain, void *context)
{
	VALUE service;
	/* other parameters are undefined if errorCode != 0 */
	dnssd_check_error_code(e);
	service = (VALUE)context;
	dnssd_callback(service, dnssd_domain_enum_new(service, flags, interface_index, domain));
}

static VALUE
sd_enumerate_domains(int argc, VALUE *argv, VALUE service)
{
  VALUE tmp_flags, interface;
	
	DNSServiceFlags flags = 0;
	uint32_t interface_index = 0;

  DNSServiceErrorType e;
	DNSServiceRef *client;

  rb_scan_args (argc, argv, "02", &tmp_flags, &interface);

	/* optional parameters */
	if (!NIL_P(tmp_flags))
		flags = dnssd_to_flags(tmp_flags);
	if (!NIL_P(interface))
		interface_index = dnssd_get_interface_index(interface);
	
	GetDNSSDService(service, client);
  e = DNSServiceEnumerateDomains (client, flags, interface_index,
																	dnssd_domain_enum_reply, (void *)service);
  dnssd_check_error_code(e);
	return service;
}

/*
 * call-seq:
 *    DNSSD.enumerate_domains!(flags=0, interface=DNSSD::InterfaceAny) {|reply| block } => obj
 *
 * Synchronously enumerate domains available for browsing and registration.
 * For each domain found a DNSSD::Reply object is passed to block with #domain
 * set to the enumerated domain.
 *
 *    available_domains = []
 *    timeout(2) do
 *  	  DNSSD.enumerate_domains! do |r|
 *  	    available_domains << r.domain
 *      end
 *    rescue TimeoutError
 *    end
 *    puts available_domains.inspect
 *
 */
 
static VALUE
dnssd_enumerate_domains_bang (int argc, VALUE * argv, VALUE self)
{
	return dnssd_service_start(
		sd_enumerate_domains(argc, argv, dnssd_service_alloc(rb_block_proc()))
														);
}
/*
 * call-seq:
 *    DNSSD.enumerate_domains(flags=0, interface=DNSSD::InterfaceAny) {|reply| bloc } => serivce_handle
 *
 * Asynchronously enumerate domains available for browsing and registration.
 * For each domain found a DNSSD::DomainEnumReply object is passed to block.
 * The returned _service_handle_ can be used to control when to
 * stop enumerating domains (see DNSSD::Service#stop).
 *
 *    available_domains = []
 *    s = DNSSD.enumerate_domains do |d|
 *      available_domains << d.domain
 *    end
 *    sleep(0.2)
 *    s.stop
 *    puts available_domains.inspect
 *
 */
 
static VALUE
dnssd_enumerate_domains(int argc, VALUE * argv, VALUE self)
{
	return dnssd_service_start_in_thread(
		sd_enumerate_domains(argc, argv, dnssd_service_alloc(rb_block_proc()))
																			);
}

static void DNSSD_API
dnssd_browse_reply (DNSServiceRef client, DNSServiceFlags flags,
										uint32_t interface_index, DNSServiceErrorType e,
							      const char *name, const char *type,
										const char *domain, void *context)
{
	VALUE service;
	/* other parameters are undefined if errorCode != 0 */
	dnssd_check_error_code(e);
	service = (VALUE)context;
	dnssd_callback(service,
			dnssd_browse_new (service, flags, interface_index, name, type, domain)
								);
}

static VALUE
sd_browse(int argc, VALUE *argv, VALUE service)
{
  VALUE type, domain, tmp_flags, interface;
	
	const char *type_str;
	const char *domain_str = NULL;
	DNSServiceFlags flags = 0;
	uint32_t interface_index = 0;

  DNSServiceErrorType e;
	DNSServiceRef *client;

  rb_scan_args (argc, argv, "13", &type,
								&domain, &tmp_flags, &interface);
	type_str = StringValueCStr(type);

	/* optional parameters */
  if (!NIL_P(domain))
		domain_str = dnssd_get_domain(domain);
	if (!NIL_P(tmp_flags))
		flags = dnssd_to_flags(tmp_flags);
	if (!NIL_P(interface))
		interface_index = dnssd_get_interface_index(interface);
	
	GetDNSSDService(service, client);
  e = DNSServiceBrowse (client, flags, interface_index,
												type_str, domain_str,
												dnssd_browse_reply, (void *)service);
  dnssd_check_error_code(e);
	return service;
}

/*
 * call-seq:
 *    DNSSD.browse!(type, domain=nil, flags=0, interface=DNSSD::InterfaceAny) {|reply| block } => obj
 *
 * Synchronously browse for services.
 * For each service found a DNSSD::Reply object is passed to block.
 *
 *    timeout(6) do
 *      DNSSD.browse!('_http._tcp') do |r|
 *        puts "found: #{r.inspect}"
 *      end
 *    rescue TimeoutError
 *    end
 *
 */
static VALUE
dnssd_browse_bang(int argc, VALUE * argv, VALUE self)
{
	return dnssd_service_start(
		sd_browse(argc, argv, dnssd_service_alloc(rb_block_proc()))
														);
}
 

/*
 * call-seq:
 *    DNSSD.browse(type, domain=nil, flags=0, interface=DNSSD::InterfaceAny) {|reply| block } => service_handle
 *
 * Asynchronously browse for services.
 * For each service found a DNSSD::BrowseReply object is passed to block.
 * The returned _service_handle_ can be used to control when to
 * stop browsing for services (see DNSSD::Service#stop).
 *
 *    s = DNSSD.browse('_http._tcp') do |b|
 *      puts "found: #{b.inspect}"
 *    end
 *
 */
static VALUE
dnssd_browse(int argc, VALUE * argv, VALUE self)
{
	return dnssd_service_start_in_thread(
		sd_browse(argc, argv, dnssd_service_alloc(rb_block_proc()))
																			);
}

static void DNSSD_API
dnssd_register_reply (DNSServiceRef client, DNSServiceFlags flags,
											DNSServiceErrorType e,
											const char *name, const char *regtype,
											const char *domain, void *context)
{
	VALUE service;
	/* other parameters are undefined if errorCode != 0 */
	dnssd_check_error_code(e);
	service = (VALUE)context;
	dnssd_callback(service, dnssd_register_new(service, flags, name, regtype, domain));
}

static VALUE
sd_register(int argc, VALUE *argv, VALUE service)
{
  VALUE name, type, domain, port,
				text_record, tmp_flags, interface;

	const char *name_str, *type_str, *domain_str = NULL;
	uint16_t opaqueport;
	uint16_t txt_len = 0;
	char *txt_rec = NULL;
	DNSServiceFlags flags = 0;
	uint32_t interface_index = 0;

  DNSServiceErrorType e;
  DNSServiceRef *client;

  rb_scan_args (argc, argv, "43",
								&name, &type, &domain, &port,
								&text_record, &tmp_flags, &interface);

	/* required parameters */
	name_str = StringValueCStr(name);
	type_str = StringValueCStr(type);

	if (!NIL_P(domain))
		domain_str = dnssd_get_domain(domain);
	/* convert from host to net byte order */
	opaqueport = htons((uint16_t)NUM2UINT(port));

	/* optional parameters */
	if (!NIL_P(text_record)) {
		text_record = dnssd_tr_to_encoded_str(text_record);
		txt_rec = RSTRING(text_record)->ptr;
		txt_len = RSTRING(text_record)->len;
	}
	if (!NIL_P(tmp_flags))
		flags = dnssd_to_flags(tmp_flags);
  if(!NIL_P(interface))
		interface_index = dnssd_get_interface_index(interface);

  GetDNSSDService(service, client);

	/* HACK */
	rb_iv_set(service, "@interface", interface);
	rb_iv_set(service, "@port", port);
	rb_iv_set(service, "@text_record", text_record);
	/********/
	e = DNSServiceRegister (client, flags, interface_index,
													name_str, type_str, domain_str,
													NULL, opaqueport, txt_len, txt_rec,
													dnssd_register_reply, (void*)service );
  dnssd_check_error_code(e);
  return service;
}

/*
 * call-seq:
 *    DNSSD.register!(name, type, domain, port, text_record=nil, flags=0, interface=DNSSD::InterfaceAny) {|reply| block } => obj
 *
 * Synchronously register a service.  A DNSSD::Reply object is passed
 * to the block when the registration completes.
 *
 *    DNSSD.register!("My Files", "_http._tcp", nil, 8080) do |r|
 *      warn("successfully registered: #{r.inspect}")
 *    end
 *
 */
static VALUE
dnssd_register_bang(int argc, VALUE * argv, VALUE self)
{
	return dnssd_service_start(
		sd_register(argc, argv, dnssd_service_alloc(rb_block_proc()))
														);
}

/*
 * call-seq:
 *    DNSSD.register(name, type, domain, port, text_record=nil, flags=0, interface=DNSSD::InterfaceAny) {|reply| block } => service_handle
 *
 * Asynchronously register a service.  A DNSSD::Reply object is
 * passed to the block when the registration completes.
 * The returned _service_handle_ can be used to control when to
 * stop the service (see DNSSD::Service#stop).
 *
 *    # Start a webserver and register it using DNS Service Discovery
 *    require 'dnssd'
 *    require 'webrick'
 *    
 *    web_s = WEBrick::HTTPServer.new(:Port=>8080, :DocumentRoot=>Dir::pwd)
 *    dns_s = DNSSD.register("My Files", "_http._tcp", nil, 8080) do |r|
 *      warn("successfully registered: #{r.inspect}")
 *    end
 *    
 *    trap("INT"){ dns_s.stop; web_s.shutdown }
 *    web_s.start
 *
 */
static VALUE
dnssd_register(int argc, VALUE * argv, VALUE self)
{
	return dnssd_service_start_in_thread(
		sd_register(argc, argv, dnssd_service_alloc(rb_block_proc()))
																			);
}

static void DNSSD_API
dnssd_resolve_reply (DNSServiceRef client, DNSServiceFlags flags,
										 uint32_t interface_index, DNSServiceErrorType e,
										 const char *fullname, const char *host_target,
										 uint16_t opaqueport, uint16_t txt_len,
										 const char *txt_rec, void *context)
{
	VALUE service;
	/* other parameters are undefined if errorCode != 0 */
	dnssd_check_error_code(e);
	service = (VALUE)context;
	dnssd_callback(service,
			dnssd_resolve_new(service, flags, interface_index, fullname,
												host_target, opaqueport, txt_len, txt_rec)
								);
}

static VALUE
sd_resolve(int argc, VALUE *argv, VALUE service)
{
  VALUE name, type, domain, tmp_flags, interface;

	const char *name_str, *type_str, *domain_str;
	DNSServiceFlags flags = 0;
	uint32_t interface_index = 0;

  DNSServiceErrorType err;
  DNSServiceRef *client;

  rb_scan_args(argc, argv, "32", &name, &type, &domain, &tmp_flags, &interface);

	/* required parameters */
	name_str = StringValueCStr(name),
	type_str = StringValueCStr(type),
	domain_str = dnssd_get_domain(domain);

	/* optional parameters */
	if (!NIL_P(tmp_flags))
		flags = dnssd_to_flags(tmp_flags);
	if (!NIL_P(interface))
		interface_index = dnssd_get_interface_index(interface);

  GetDNSSDService(service, client);
  err = DNSServiceResolve (client, flags, interface_index, name_str, type_str,
													 domain_str, dnssd_resolve_reply, (void *)service);
  dnssd_check_error_code(err);
	return service;
}

/*
 * call-seq:
 *    DNSSD.resolve!(name, type, domain, flags=0, interface=DNSSD::InterfaceAny) {|reply| block } => obj
 *
 * Synchronously resolve a service discovered via DNSSD.browse().
 * The service is resolved to a target host name, port number, and
 * text record - all contained in the DNSSD::Reply object
 * passed to the required block.
 *
 *    timeout(2) do
 *      DNSSD.resolve!("foo bar", "_http._tcp", "local") do |r|
 *        puts r.inspect
 *      end
 *    rescue TimeoutError
 *    end
 *
 */
static VALUE
dnssd_resolve_bang(int argc, VALUE * argv, VALUE self)
{
	return dnssd_service_start(
		sd_resolve(argc, argv, dnssd_service_alloc(rb_block_proc()))
														);
}

/*
 * call-seq:
 *    DNSSD.resolve(name, type, domain, flags=0, interface=DNSSD::InterfaceAny) {|reply| block } => service_handle
 *
 * Asynchronously resolve a service discovered via DNSSD.browse().
 * The service is resolved to a target host name, port number, and
 * text record - all contained in the DNSSD::Reply object
 * passed to the required block.  
 * The returned _service_handle_ can be used to control when to
 * stop resolving the service (see DNSSD::Service#stop).
 *
 *    s = DNSSD.resolve("foo bar", "_http._tcp", "local") do |r|
 *      puts r.inspect
 *    end
 *    sleep(2)
 *    s.stop
 *
 */
static VALUE
dnssd_resolve(int argc, VALUE * argv, VALUE self)
{
	return dnssd_service_start_in_thread(
		sd_resolve(argc, argv, dnssd_service_alloc(rb_block_proc()))
																			);
}

void
Init_DNSSD_Service(void)
{
/* hack so rdoc documents the project correctly */
#ifdef mDNSSD_RDOC_HACK
	mDNSSD = rb_define_module("DNSSD");
#endif
	dnssd_id_call = rb_intern("call");
	dnssd_id_to_str = rb_intern("to_str");
	dnssd_iv_block = rb_intern("@block");
	dnssd_iv_thread = rb_intern("@thread");
	dnssd_iv_result = rb_intern("@result");
	dnssd_iv_service = rb_intern("@service");

	cDNSSDService = rb_define_class_under(mDNSSD, "Service", rb_cObject);

	rb_define_singleton_method(cDNSSDService, "new", dnssd_service_new, -1);
	rb_define_singleton_method(cDNSSDService, "fullname", dnssd_service_s_fullname, 3);
	rb_define_singleton_method(cDNSSDService, "split_fullname", dnssd_service_s_split, 1);
	rb_define_singleton_method(cDNSSDService, "split", dnssd_service_s_split, 1);

	/* Access the services underlying thread.  Returns nil if the service is synchronous. */
	rb_define_attr(cDNSSDService, "thread", 1, 0);
	
	rb_define_method(cDNSSDService, "stop", dnssd_service_stop, 0);
	rb_define_method(cDNSSDService, "stopped?", dnssd_service_is_stopped, 0);
	rb_define_method(cDNSSDService, "inspect", dnssd_service_inspect, 0);
	
  rb_define_module_function(mDNSSD, "enumerate_domains", dnssd_enumerate_domains, -1);
  rb_define_module_function(mDNSSD, "enumerate_domains!", dnssd_enumerate_domains_bang, -1);
  rb_define_module_function(mDNSSD, "browse", dnssd_browse, -1);
  rb_define_module_function(mDNSSD, "browse!", dnssd_browse_bang, -1);
  rb_define_module_function(mDNSSD, "resolve", dnssd_resolve, -1);
  rb_define_module_function(mDNSSD, "resolve!", dnssd_resolve_bang, -1);
  rb_define_module_function(mDNSSD, "register", dnssd_register, -1);
  rb_define_module_function(mDNSSD, "register!", dnssd_register_bang, -1);
}

