/*
 * Copyright (c) 2004 Chad Fowler, Charles Mills, Rich Kilmer
 * Licenced under the same terms as Ruby.
 * This software has absolutely no warrenty.
 */
#include "rdnssd.h"
#include <intern.h>
#include <string.h> /* for strchr() */

static VALUE cDNSSDTextRecord;

static void
dnssd_tr_decode_buffer(VALUE self, long buf_len, const char *buf_ptr)
{
	/* iterate through text record, inserting key, value pairs into hash */
	long i = 0;
	while(i < buf_len) {
		VALUE key, value;
		const char *p;
		long key_len, len = (long)(uint8_t)buf_ptr[i++];
		if (i + len > buf_len)
      rb_raise(rb_eArgError, "invalid text record (string longer than buffer)");

    if (len == 0) {
      /* 0-length key/value, handle this by skipping over it.
       * Probably the RR should have zero-length, but some services have been
       * found to advertise a non-zero length TXT record, with a zero-length
       * key/value string.
       */
      continue;
    }

		p = memchr(buf_ptr + i, '=', buf_len - i);
		if (p == NULL) {
      /* key, with no value, this is OK */
			key_len = len;
			key = rb_str_new(buf_ptr + i, key_len);
			value = Qnil;
		} else {
			key_len = p - (buf_ptr + i);
      if(key_len == 0)
         rb_raise(rb_eArgError, "invalid text record (zero-length key)");

			key = rb_str_new(buf_ptr + i, key_len);
			key_len++; /* step over '=' */
			value = rb_str_new(buf_ptr + i + key_len, len - key_len);
		}
		rb_hash_aset(self, key, value);
		i += len;
	}
}

static void
dnssd_tr_decode_str(VALUE self, VALUE str)
{
	str = StringValue(str);
	/* text records cannot be longer than 65535 (0xFFFF) */
	if (RSTRING(str)->len > UINT16_MAX)
		rb_raise(rb_eArgError, "string is to large to encode");
	dnssd_tr_decode_buffer (self, RSTRING(str)->len, RSTRING(str)->ptr);
}

/*
 * call-seq:
 *    DNSSD::TextRecord.decode(binary_string) => text_record 
 *
 * Create a new DNSSD::TextRecord be decoding the key
 * value pairs contained in _binary_string_.  See DNSSD::TextRecord.encode()
 * for more information.
 */

static VALUE
dnssd_tr_decode(VALUE klass, VALUE str)
{
	/* self needs to be on the stack - we add (allocate)
	 * lots of key, value pairs when decoding and this could
	 * cause the gc to run. */
	volatile VALUE self = rb_obj_alloc(klass);
	dnssd_tr_decode_str(self, str);
	return self;
}

VALUE
dnssd_tr_new(long len, const char *buf)
{
	VALUE self = rb_obj_alloc(cDNSSDTextRecord);
	dnssd_tr_decode_buffer(self, len, buf);
	return self;
}

/*
 * call-seq:
 *    DNSSD::TextRecord.new()               => text_record
 *    DNSSD::TextRecord.new(binary_string)  => text_record
 *
 * The first form creates an empty text record.  The second
 * creates a new text record populated with the key, value pairs
 * found in the encoded string _binary_string_.  See
 * DNSSD::TextRecord.encode() for more information.
 *
 *    tr = DNSSD::TextRecord.new  #=> {}
 *    tr["name"] = "Chad"
 *    tr["port"] = 3871.to_s
 *
 */

static VALUE
dnssd_tr_initialize(int argc, VALUE *argv, VALUE self)
{
	VALUE encoded_str;
	rb_scan_args(argc, argv, "01", &encoded_str);
	if (argc == 1) {
		/* try to decode the string */
		dnssd_tr_decode_str(self, encoded_str);
	}
	return self;
}

static void
dnssd_tr_valid_key(const char *key_cstr, long len)
{
	/* keys cannot contain '=' */
	if (strchr(key_cstr, '='))
		rb_raise(rb_eRuntimeError, "key '%s' contains '='", key_cstr);

	if (len <= 0)
		rb_raise(rb_eRuntimeError, "empty key given");
}

static long
dnssd_tr_convert_pairs(volatile VALUE ary)
{
	long i, tot_len = 0;
	VALUE *ptr = RARRAY(ary)->ptr;
	/* iterate over key, value pairs checking if each one is valid */
	for(i=0; i<RARRAY(ary)->len; i++) {
		VALUE key = RARRAY(ptr[i])->ptr[0];
		VALUE value = RARRAY(ptr[i])->ptr[1];
		/* checks if key is a valid C String (null terminated)
		 * note: StringValueCStr takes a pointer to key by &key
		 * this may cause key to be reassigned. */
		const char *key_cstr = StringValueCStr(key);
		long len = RSTRING(key)->len;
		dnssd_tr_valid_key(key_cstr, len);

		if (!NIL_P(value)) {
			value = StringValue(value);
			len += 1 + RSTRING(value)->len;
		}
		/* len == sum(key length, 1 for '=' if value != nil, value length) */
		if (len > UINT8_MAX)
			rb_raise(rb_eRuntimeError, "key, value pair at '%s' is too large to encode", key_cstr);
	
		/* now that we know no errors are going to occur */
		if (RSTRING(key)->len > 14)
			rb_warn("key '%s' is greator than 14 bytes, may not be compatible with all clients", key_cstr);
		/* key and value may have been reassigned by StringValue macros */
		RARRAY(ptr[i])->ptr[0] = key;
		RARRAY(ptr[i])->ptr[1] = value;
		tot_len += len + 1; /* plus 1 to hold key, value pair length */
	}
	return tot_len;
}

/*
 * call-seq:
 *    text_record.encode => an_encoded_string
 *
 * Encodes the contents of _text_record_ into a sequence of <em>binary strings</em>
 * (one for each key, value pair).
 * The each <em>binary string</em> comprises of a <em>length</em> and a <em>payload</em>.
 * The <em>length</em> gives the number of bytes in the <em>payload</em>
 * (must be between <code>0</code> and <code>255</code>).
 * This is an unsigned integer packed into the first byte of the binary string.
 * The <em>payload</em> contains a key, value pair separated by a <code>=</code> character.
 * Because <code>=</code> is used as a separator, keys must not contain any
 * <code>=</code> characters.  Here is an example of how the key, value pair
 * <code>"1rst"</code>, <code>"Sam"</code> is encoded.
 *
 *    [00][01][02][03][04][05][06][07][08]
 *    \010 1   r   s   t   =   S   a   m
 *
 * It is recommended to use keys with a length less than or equal to <code>14</code> bytes
 * to ensure compatibility with all clients.
 *
 *    text_record = DNSSD::TextRecord.new
 *    text_record["1rst"]="Sam"
 *    text_record["Last"]="Green"
 *    text_record["email"]="sam@green.org"
 *    s = text_record.encode      #=> "\nLast=Green\0101rst=Sam\023email=sam@green.org"
 *    DNSSD::TextRecord.decode(s) #=> {"Last"=>"Green", "1rst"=>"Sam", "email"=>"sam@green.org"}
 *
 */

static VALUE
dnssd_tr_encode(VALUE self)
{
	long i;
	VALUE buf;
	/* Declare ary volatile to prevent it from being reclaimed when:
	 * buf is allocated later, key/values are converted to strings */
	volatile VALUE ary = rb_funcall2(self, rb_intern("to_a"), 0, 0);
	/* array of key, value pairs */
	VALUE *ptr = RARRAY(ary)->ptr;
	
	buf = rb_str_buf_new(dnssd_tr_convert_pairs(ary));
	for(i=0; i<RARRAY(ary)->len; i++) {
		uint8_t len;
		VALUE key = RARRAY(ptr[i])->ptr[0];
		VALUE value = RARRAY(ptr[i])->ptr[1];
		if (!NIL_P(value)) {
			len = (uint8_t)(RSTRING(key)->len + RSTRING(value)->len + 1);
			rb_str_buf_cat(buf, &len, 1);
			rb_str_buf_append(buf, key);
			rb_str_buf_cat(buf, "=", 1);
			rb_str_buf_append(buf, value);	
		} else {
			len = (uint8_t)RSTRING(key)->len;
			rb_str_buf_cat(buf, &len, 1);
			rb_str_buf_append(buf, key);
		}
	}
	return buf;
}

VALUE
dnssd_tr_to_encoded_str(VALUE v)
{
	if (rb_obj_is_kind_of(v, rb_cHash) == Qtrue)
		return dnssd_tr_encode(v);
	/* allow the user to use arbitrary strings as text records */
	return StringValue(v);
}

/*
 * Document-class: DNSSD::TextRecord
 *
 * DNSSD::TextRecord is a Hash with the ability to encode its contents into
 * a binary string that can be send over the wire as using the DNSSD protocol.
 *
 */

void
Init_DNSSD_TextRecord(void)
{
/* hack so rdoc documents the project correctly */
#ifdef mDNSSD_RDOC_HACK
	mDNSSD = rb_define_module("DNSSD");
#endif
	cDNSSDTextRecord = rb_define_class_under(mDNSSD, "TextRecord", rb_cHash);
	
	rb_define_singleton_method(cDNSSDTextRecord, "decode", dnssd_tr_decode, 1);

	rb_define_method(cDNSSDTextRecord, "initialize", dnssd_tr_initialize, -1);
	rb_define_method(cDNSSDTextRecord, "encode", dnssd_tr_encode, 0);
}

