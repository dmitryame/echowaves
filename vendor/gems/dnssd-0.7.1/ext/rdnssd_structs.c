/*
 * Copyright (c) 2004 Chad Fowler, Charles Mills, Rich Kilmer
 * Licensed under the same terms as Ruby.
 * This software has absolutely no warranty.
 */
#include "rdnssd.h"

static VALUE cDNSSDFlags;
static VALUE cDNSSDReply;
	
static ID dnssd_iv_flags;
static ID dnssd_iv_interface;
static ID dnssd_iv_fullname;
static ID dnssd_iv_target;
static ID dnssd_iv_port;
static ID dnssd_iv_text_record;
static ID dnssd_iv_name;
static ID dnssd_iv_type;
static ID dnssd_iv_domain;
static ID dnssd_iv_service;

#define IsDNSSDFlags(obj) (rb_obj_is_kind_of(obj,cDNSSDFlags)==Qtrue)
#define VerifyDNSSDFlags(obj) \
	do { \
		if(!IsDNSSDFlags(obj)) rb_fatal(__FILE__":%d: bug in DNSSD",__LINE__); \
	} while (0)

/* dns sd flags, flag ID's, flag names */
#define DNSSD_MAX_FLAGS 9

static const DNSServiceFlags dnssd_flag[DNSSD_MAX_FLAGS] = {
	kDNSServiceFlagsMoreComing,
		
	kDNSServiceFlagsAdd,
	kDNSServiceFlagsDefault,
	
	kDNSServiceFlagsNoAutoRename,
	
	kDNSServiceFlagsShared,
	kDNSServiceFlagsUnique,
	
	kDNSServiceFlagsBrowseDomains,
	kDNSServiceFlagsRegistrationDomains,

	kDNSServiceFlagsLongLivedQuery
};

/* used to make sure only valid bits are set in a flag. */
#define DNSSD_FLAGS_MASK(f) \
		( (f) & (kDNSServiceFlagsMoreComing | \
		kDNSServiceFlagsAdd | kDNSServiceFlagsDefault | \
		kDNSServiceFlagsNoAutoRename | kDNSServiceFlagsShared | \
		kDNSServiceFlagsUnique | kDNSServiceFlagsBrowseDomains | \
		kDNSServiceFlagsRegistrationDomains | kDNSServiceFlagsLongLivedQuery) )

static const char *dnssd_flag_name[DNSSD_MAX_FLAGS] = {
	"more_coming",
	"add",
	"default",
	"no_auto_rename",
	"shared",
	"unique",
	"browse_domains",
	"registration_domains",
	"long_lived_query"
};

static void
dnssd_init_flags_methods(VALUE klass)
{
	char buffer[128];
	int i;
	for (i=0; i<DNSSD_MAX_FLAGS; i++) {
		unsigned long flag = (unsigned long)dnssd_flag[i];
		const char *flag_name = dnssd_flag_name[i];
		VALUE str;
		size_t len;
		len = snprintf(buffer, sizeof(buffer),
									 "def %s?; self & %lu end",
									 flag_name, flag);
		str = rb_str_new(buffer, (long)len);
		rb_mod_module_eval(1, &str, klass);

		/* similar to attr_writer method for each flag */
		len = snprintf(buffer, sizeof(buffer),
									 "def %s=(val); "
									 "if val then self.set_flag(%lu) else self.clear_flag(%lu) end; "
									 "val end", /* return val */
									 flag_name, flag, flag);
		str = rb_str_new(buffer, (long)len);
		rb_mod_module_eval(1, &str, klass);
	}
}

static VALUE
dnssd_flags_alloc(VALUE klass)
{
	/* no free function or mark function, initialize flags/data to 0 */
	return Data_Wrap_Struct(klass, 0, 0, 0);
}

static VALUE
dnssd_flags_init(VALUE self, DNSServiceFlags flags)
{
	VerifyDNSSDFlags(self);
	/* note DNSSD_FLAGS_MASK() here */
	RDATA(self)->data = (void*)DNSSD_FLAGS_MASK(flags);
	return self;
}

static DNSServiceFlags 
dnssd_get_flags(VALUE self)
{
	VerifyDNSSDFlags(self);
	return (DNSServiceFlags)RDATA(self)->data;
}

DNSServiceFlags 
dnssd_to_flags(VALUE obj)
{
	DNSServiceFlags flags = 0;
	if (IsDNSSDFlags(obj)) {
		flags = dnssd_get_flags(obj);
	} else {
		/* don't want to include any bits that aren't flags */
		flags = DNSSD_FLAGS_MASK((DNSServiceFlags)NUM2ULONG(obj));
	}
	return flags;
}

/*
 * call-seq:
 *   DNSSD::Flags.new()                   => flags
 *   DNSSD::Flags.new(flag1, flag2, ...)  => union_of_flags
 *
 * Returns a new set of flags.
 * In the first form an empty set of flags is created.
 * In the second a set of flags containing the union of
 * each flag (or set of flags) given is created.
 *
 *   flags = Flags.new()
 *   flags.more_coming = true
 *   flags.to_i                #=> DNSSD::Flags::MoreComing
 *   f.shared = true
 *   flags.to_i                #=> Flags::MoreComing | Flags::Shared
 *
 *   same_flags = Flags.new(Flags::MoreComing | Flags::Shared)
 *   flags == same_flags       #=> true
 *
 *   same_flags_again = Flags.new(Flags::MoreComing, Flags::Shared)
 *   flags == same_flags_again  #=> true
 *
 */

static VALUE
dnssd_flags_initialize(int argc, VALUE *argv, VALUE self)
{
	int i;
	DNSServiceFlags flags = 0;

	for (i=0; i<argc; i++) {
		flags |= dnssd_to_flags(argv[i]);
	}
	return dnssd_flags_init(self, flags);
}

static VALUE
dnssd_flags_new2(VALUE klass, DNSServiceFlags flags)
{
	return dnssd_flags_init(dnssd_flags_alloc(klass), flags);
}

static VALUE
dnssd_flags_new(DNSServiceFlags flags)
{
	return dnssd_flags_new2(cDNSSDFlags, flags);
}

/*
 * call-seq:
 *    flags.set_flag(f)
 *
 * Set the flag _f_ in _flags_.
 *
 *    flags = Flags.new()                #=> #<DNSSD::Flags>
 *    flags.set_flag(Flags::MoreComing)  #=> #<DNSSD::Flags more_coming>
 *
 */

static VALUE
dnssd_flags_set(VALUE self, VALUE num)
{
	DNSServiceFlags flags;
	VerifyDNSSDFlags(self);
	flags = (DNSServiceFlags)RDATA(self)->data;
	flags |= dnssd_to_flags(num);
	RDATA(self)->data = (void*)flags;
	return self;
}

/*
 * call-seq:
 *    flags.clear_flag(f)
 *
 * Clear the flag _f_ in _flags_.
 *
 *    flags = Flags.new(Flags::MoreComing)  #=> #<DNSSD::Flags more_coming>
 *    flags.clear_flag(Flags::MoreComing)   #=> #<DNSSD::Flags>
 *
 */

static VALUE
dnssd_flags_clear(VALUE self, VALUE num)
{
	DNSServiceFlags flags;
	VerifyDNSSDFlags(self);
	/* flags should stay masked here (see DNSSD_FLAGS_MASK() macro) */
	flags = (DNSServiceFlags)RDATA(self)->data;
	flags &= ~dnssd_to_flags(num);
	RDATA(self)->data = (void*)flags;
	return self;
}

/*
 * call-seq:
 *    flags1 & flags2 => flags
 *
 * Returns the set of flags included in <i>flags1</i> and <i>flags2</i>.
 *
 */

static VALUE
dnssd_flags_and(VALUE self, VALUE num)
{
	return dnssd_flags_new2(CLASS_OF(self), dnssd_get_flags(self) & dnssd_to_flags(num));
}

/*
 * call-seq:
 *    flags1 | flags2 => flags
 *
 * Returns the set of flags included in <i>flags1</i> or <i>flags2</i>.
 *
 */

static VALUE
dnssd_flags_or(VALUE self, VALUE num)
{
	return dnssd_flags_new2(CLASS_OF(self), dnssd_get_flags(self) | dnssd_to_flags(num));
}

/*
 * call-seq:
 *    ~flags => unset_flags
 *
 * Returns the set of flags not included in _flags_.
 *
 */

static VALUE
dnssd_flags_not(VALUE self)
{
	/* doesn't totally make sence to return a set of flags here... */
	return dnssd_flags_new2(CLASS_OF(self), ~dnssd_get_flags(self));
}

/*
 * call-seq:
 *    flags.to_i => an_integer
 *
 * Get the integer representation of _flags_ by bitwise or'ing
 * each of the set flags.
 *
 */

static VALUE
dnssd_flags_to_i(VALUE self)
{
	return ULONG2NUM(dnssd_get_flags(self));
}

static VALUE
dnssd_flags_list(VALUE self)
{
	DNSServiceFlags flags = dnssd_get_flags(self);
	VALUE buf = rb_str_buf_new(0);
	int i;
	for (i=0; i<DNSSD_MAX_FLAGS; i++) {
		if (flags & dnssd_flag[i]) {
			rb_str_buf_cat2(buf, dnssd_flag_name[i]);
			rb_str_buf_cat2(buf, ",");
		}
	}
	/* get rid of trailing comma */
	if (RSTRING(buf)->len > 0) {
		long len = --(RSTRING(buf)->len);
		RSTRING(buf)->ptr[len] = '\000';
	}
	return buf;
}

static VALUE
dnssd_struct_inspect(VALUE self, VALUE data)
{
	VALUE buf = rb_str_buf_new(20 + RSTRING(data)->len);
	rb_str_buf_cat2(buf, "#<");
	rb_str_buf_cat2(buf, rb_obj_classname(self));
	if (RSTRING(data)->len > 0) {
		rb_str_buf_cat2(buf, " ");
		rb_str_buf_append(buf, data);
	}
	rb_str_buf_cat2(buf, ">");
	return buf;
}

/*
 * call-seq:
 *    flags.inspect => string
 *
 * Create a printable version of _flags_.
 *
 *    flags = DNSSD::Flags.new
 *    flags.add = true
 *    flags.default = true
 *    flags.inspect  # => "#<DNSSD::Flags add,default>"
 *
 */

static VALUE
dnssd_flags_inspect(VALUE self)
{
	return dnssd_struct_inspect(self, dnssd_flags_list(self));
}

/*
 * call-seq:
 *    flags == obj => true or false
 *
 * Equality--Two sets of flags are equal if they contain the same flags.
 *
 *    flags = Flags.new()
 *    flags.more_coming = true
 *    flags.shared = true
 *    flags == Flags::MoreComing | Flags::Shared            #=> true
 *    flags == Flags.new(Flags::MoreComing | Flags::Shared) #=> true
 */

static VALUE
dnssd_flags_equal(VALUE self, VALUE obj)
{
	DNSServiceFlags flags = dnssd_get_flags(self);
	DNSServiceFlags obj_flags = dnssd_to_flags(obj);

	return flags == obj_flags ? Qtrue : Qfalse;
}

VALUE
dnssd_create_fullname(const char *name, const char *regtype, const char *domain, int err_flag)
{
	char buffer[kDNSServiceMaxDomainName];
	if ( DNSServiceConstructFullName(buffer, name, regtype, domain) ) {
		static const char msg[] = "could not construct full service name";
		if (err_flag) {
			rb_raise(rb_eArgError, msg);
		} else {
			VALUE buf;
			rb_warn(msg);
			/* just join them all */
			buf = rb_str_buf_new2(name);
			rb_str_buf_cat2(buf, regtype);
			rb_str_buf_cat2(buf, domain);
			return buf;
		}
	}
	buffer[kDNSServiceMaxDomainName - 1] = '\000'; /* just in case */
	return rb_str_new2(buffer);
}

VALUE
dnssd_split_fullname(VALUE fullname)
{
	static const char re[] = "(?:\\\\.|[^\\.])+\\.";
	VALUE regexp = rb_reg_new(re, sizeof(re)-1, 0);
	return rb_funcall2(fullname, rb_intern("scan"), 1, &regexp);
}

#if 0
static void
quote_and_append(VALUE buf, VALUE str)
{
	const char *ptr;
	long i, last_mark, len;

	ptr = RSTRING(str)->ptr;
	len = RSTRING(str)->len;
	last_mark = 0;
	/* last character should be '.' */
	for (i=0; i<len-1; i++) {
		if (ptr[i] == '.') {
			/* write 1 extra character and replace it with '\\' */
			rb_str_buf_cat(buf, ptr + last_mark, i + 1 - last_mark);
			RSTRING(buf)->ptr[i] = '\\';
			last_mark = i;
		}
	}
	rb_str_buf_cat(buf, ptr + last_mark, len - last_mark);
}
#endif

static VALUE
dnssd_join_names(int argc, VALUE *argv)
{
	int i;
	VALUE buf;
	long len = 0;

	for (i=0; i<argc; i++) {
		argv[i] = StringValue(argv[i]);
		len += RSTRING(argv[i])->len;
	}
	buf = rb_str_buf_new(len);
	for (i=0; i<argc; i++) {
		rb_str_buf_append(buf, argv[i]);
	}
	return buf;
}

static void
reply_add_names(VALUE self, const char *name,
								const char *regtype, const char *domain)
{
	rb_ivar_set(self, dnssd_iv_name, rb_str_new2(name));
	rb_ivar_set(self, dnssd_iv_type, rb_str_new2(regtype));
	rb_ivar_set(self, dnssd_iv_domain, rb_str_new2(domain));
	rb_ivar_set(self, dnssd_iv_fullname, dnssd_create_fullname(name, regtype, domain, 0));
}

static void
reply_add_names2(VALUE self, const char *fullname)
{
	VALUE fn = rb_str_new2(fullname);
	VALUE ary = dnssd_split_fullname(fn);
	VALUE type[2] =  { rb_ary_entry(ary, 1), rb_ary_entry(ary, 2) };

	rb_ivar_set(self, dnssd_iv_name, rb_ary_entry(ary, 0));
	rb_ivar_set(self, dnssd_iv_type, dnssd_join_names(2, type));
	rb_ivar_set(self, dnssd_iv_domain, rb_ary_entry(ary, -1));
	rb_ivar_set(self, dnssd_iv_fullname, fn);
}


static void
reply_set_interface(VALUE self, uint32_t interface)
{
	VALUE if_value;
	char buffer[IF_NAMESIZE];
	if (if_indextoname(interface, buffer)) {
		if_value = rb_str_new2(buffer);
	} else {
		if_value = ULONG2NUM(interface);
	}
	rb_ivar_set(self, dnssd_iv_interface, if_value);
}

static void
reply_set_tr(VALUE self, uint16_t txt_len, const char *txt_rec)
{
	rb_ivar_set(self, dnssd_iv_text_record, dnssd_tr_new((long)txt_len, txt_rec));
}

static VALUE
reply_new(VALUE service, DNSServiceFlags flags)
{
	VALUE self = rb_obj_alloc(cDNSSDReply);
	rb_ivar_set(self, dnssd_iv_service, service);
	rb_ivar_set(self, dnssd_iv_flags, dnssd_flags_new(flags));
	return self;
}

VALUE
dnssd_domain_enum_new(VALUE service, DNSServiceFlags flags,
											uint32_t interface, const char *domain)
{
	VALUE d, self = reply_new(service, flags);
	reply_set_interface(self, interface);
	d = rb_str_new2(domain);
	rb_ivar_set(self, dnssd_iv_domain, d);
	rb_ivar_set(self, dnssd_iv_fullname, d);
	return self;
}

VALUE
dnssd_browse_new(VALUE service,	DNSServiceFlags flags, uint32_t interface,
									const char *name, const char *regtype, const char *domain)
{
	VALUE self = reply_new(service, flags);
	reply_set_interface(self, interface);
	reply_add_names(self, name, regtype, domain);
	return self;
}

#if 0
static VALUE
dnssd_gethostname(void)
{
#if HAVE_GETHOSTNAME
	#ifndef MAXHOSTNAMELEN 
		#define MAXHOSTNAMELEN 256
	#endif
	char buffer[MAXHOSTNAMELEN + 1];
	if (gethostname(buffer, MAXHOSTNAMELEN))
		return Qnil;
	buffer[MAXHOSTNAMELEN] = '\000';
	return rb_str_new2(buffer);
#else
	return Qnil;
#endif
}
#endif

VALUE
dnssd_register_new(VALUE service,	DNSServiceFlags flags, const char *name,
										const char *regtype, const char *domain	)
{
	VALUE self = reply_new(service, flags);
	reply_add_names(self, name, regtype, domain);
	/* HACK */
	/* See HACK in rdnssd_service.c */
	rb_ivar_set(self, dnssd_iv_interface, rb_ivar_get(service, dnssd_iv_interface));
	rb_ivar_set(self, dnssd_iv_port, rb_ivar_get(service, dnssd_iv_port));
	rb_ivar_set(self, dnssd_iv_text_record, rb_ivar_get(service, dnssd_iv_text_record));
	/********/
	return self;
}

VALUE
dnssd_resolve_new(VALUE service, DNSServiceFlags flags, uint32_t interface,
									const char *fullname, const char *host_target,
									uint16_t opaqueport, uint16_t txt_len, const char *txt_rec)
{
	uint16_t port = ntohs(opaqueport);
	VALUE self = reply_new(service, flags);
	reply_set_interface(self, interface);
	reply_add_names2(self, fullname);
	rb_ivar_set(self, dnssd_iv_target, rb_str_new2(host_target));
	rb_ivar_set(self, dnssd_iv_port, UINT2NUM(port));
	reply_set_tr(self, txt_len, txt_rec);
	return self;
}

/*
 * call-seq:
 *    reply.inspect   => string
 *
 */
static VALUE
reply_inspect(VALUE self)
{
	VALUE fullname = rb_ivar_get(self, dnssd_iv_fullname);
	return dnssd_struct_inspect(self, StringValue(fullname));
}

/*
 * call-seq:
 *    DNSSD::Reply.new() => raises a RuntimeError
 *
 */
static VALUE
reply_initialize(int argc, VALUE *argv, VALUE reply)
{
	dnssd_instantiation_error(rb_obj_classname(reply));
	return Qnil;
}

void
Init_DNSSD_Replies(void)
{
/* hack so rdoc documents the project correctly */
#ifdef mDNSSD_RDOC_HACK
	mDNSSD = rb_define_module("DNSSD");
#endif

	dnssd_iv_flags = rb_intern("@flags");
	dnssd_iv_interface = rb_intern("@interface");
	dnssd_iv_fullname = rb_intern("@fullname");
	dnssd_iv_target = rb_intern("@target");
	dnssd_iv_port = rb_intern("@port");
	dnssd_iv_text_record = rb_intern("@text_record");
	dnssd_iv_name = rb_intern("@name");
	dnssd_iv_type = rb_intern("@type");
	dnssd_iv_domain = rb_intern("@domain");
	dnssd_iv_service = rb_intern("@service");

	cDNSSDFlags = rb_define_class_under(mDNSSD, "Flags", rb_cObject);
	rb_define_alloc_func(cDNSSDFlags, dnssd_flags_alloc);
	rb_define_method(cDNSSDFlags, "initialize", dnssd_flags_initialize, -1);
	/* this creates all the attr_writer and flag? methods */
	dnssd_init_flags_methods(cDNSSDFlags);
	rb_define_method(cDNSSDFlags, "inspect", dnssd_flags_inspect, 0);
	rb_define_method(cDNSSDFlags, "to_i", dnssd_flags_to_i, 0);
	rb_define_method(cDNSSDFlags, "==", dnssd_flags_equal, 1);
	
	rb_define_method(cDNSSDFlags, "&", dnssd_flags_and, 1);
	rb_define_method(cDNSSDFlags, "|", dnssd_flags_or, 1);
	rb_define_method(cDNSSDFlags, "~", dnssd_flags_not, 0);
	
	rb_define_method(cDNSSDFlags, "set_flag", dnssd_flags_set, 1);
	rb_define_method(cDNSSDFlags, "clear_flag", dnssd_flags_clear, 1);

	cDNSSDReply = rb_define_class_under(mDNSSD, "Reply", rb_cObject);
	/* DNSSD::Reply objects can only be instantiated by
	 * DNSSD.browse(), DNSSD.register(), DNSSD.resolve(), DNSSD.enumerate_domains(). */
	rb_define_method(cDNSSDReply, "initialize", reply_initialize, -1);
	/* The service associated with the reply.  See DNSSD::Service for more information. */
	rb_define_attr(cDNSSDReply, "service", 1, 0);
	/* Flags describing the reply.  See DNSSD::Flags for more information. */
	rb_define_attr(cDNSSDReply, "flags", 1, 0);
	/* The service name. (Not used by DNSSD.enumerate_domains().) */
	rb_define_attr(cDNSSDReply, "name", 1, 0);
	/* The service type. (Not used by DNSSD.enumerate_domains().) */
	rb_define_attr(cDNSSDReply, "type", 1, 0);
	/* The service domain. */
	rb_define_attr(cDNSSDReply, "domain", 1, 0);
	/* The interface on which the service is available. (Used only by DNSSSD.resolve().) */
	rb_define_attr(cDNSSDReply, "interface", 1, 0);
	/* The full service domain name, in the form "<servicename>.<protocol>.<domain>.".
	 * (Any literal dots (".") are escaped with a backslash ("\."), and literal
	 * backslashes are escaped with a second backslash ("\\"), e.g. a web server
	 * named "Dr. Pepper" would have the fullname  "Dr\.\032Pepper._http._tcp.local.".)
	 * See DNSSD::Service.fullname() for more information. */
	rb_define_attr(cDNSSDReply, "fullname", 1, 0);
	/* The service's primary text record, see DNSSD::TextRecord for more information. */
	rb_define_attr(cDNSSDReply, "text_record", 1, 0);
	/* The target hostname of the machine providing the service.
	 * This name can be passed to functions like Socket.gethostbyname()
	 * to identify the host's IP address. */
	rb_define_attr(cDNSSDReply, "target", 1, 0);
	/* The port on which connections are accepted for this service. */
	rb_define_attr(cDNSSDReply, "port", 1, 0);

	rb_define_method(cDNSSDReply, "inspect", reply_inspect, 0);

	/* flag constants */
#if DNSSD_MAX_FLAGS != 9
	#error The code below needs to be updated.
#endif
	/* MoreComing indicates that at least one more result is queued and will be delivered following immediately after this one.
	 * Applications should not update their UI to display browse
	 * results when the MoreComing flag is set, because this would
	 * result in a great deal of ugly flickering on the screen.
	 * Applications should instead wait until until MoreComing is not set,
	 * and then update their UI.
	 * When MoreComing is not set, that doesn't mean there will be no more
	 * answers EVER, just that there are no more answers immediately
	 * available right now at this instant. If more answers become available
	 * in the future they will be delivered as usual.
	 */
	rb_define_const(cDNSSDFlags, "MoreComing", ULONG2NUM(kDNSServiceFlagsMoreComing));
	

	/* Flags for domain enumeration and DNSSD.browse() reply callbacks.
	 * DNSSD::Flags::Default applies only to enumeration and is only valid in
	 * conjuction with DNSSD::Flags::Add.  An enumeration callback with the DNSSD::Flags::Add
	 * flag NOT set indicates a DNSSD::Flags::Remove, i.e. the domain is no longer valid.
	 */
	rb_define_const(cDNSSDFlags, "Add", ULONG2NUM(kDNSServiceFlagsAdd));
	rb_define_const(cDNSSDFlags, "Default", ULONG2NUM(kDNSServiceFlagsDefault));

	/* Flag for specifying renaming behavior on name conflict when registering non-shared records.
	 * By default, name conflicts are automatically handled by renaming the service.
	 * DNSSD::Flags::NoAutoRename overrides this behavior - with this
	 * flag set, name conflicts will result in a callback.  The NoAutoRename flag
	 * is only valid if a name is explicitly specified when registering a service
	 * (ie the default name is not used.)
	 */
	rb_define_const(cDNSSDFlags, "NoAutoRename", ULONG2NUM(kDNSServiceFlagsNoAutoRename));

	/* Flag for registering individual records on a connected DNSServiceRef.
	 * DNSSD::Flags::Shared indicates that there may be multiple records
	 * with this name on the network (e.g. PTR records).  DNSSD::Flags::Unique indicates that the
	 * record's name is to be unique on the network (e.g. SRV records).
	 * (DNSSD::Flags::Shared and DNSSD::Flags::Unique are currently not used by the Ruby API.)
	 */
	rb_define_const(cDNSSDFlags, "Shared", ULONG2NUM(kDNSServiceFlagsShared));
	rb_define_const(cDNSSDFlags, "Unique", ULONG2NUM(kDNSServiceFlagsUnique));

	/* Flags for specifying domain enumeration type in DNSSD.enumerate_domains()
	 * (currently not part of the Ruby API).
	 * DNSSD::Flags::BrowseDomains enumerates domains recommended for browsing,
	 * DNSSD::Flags::RegistrationDomains enumerates domains recommended for registration.
	 */
	rb_define_const(cDNSSDFlags, "BrowseDomains", ULONG2NUM(kDNSServiceFlagsBrowseDomains));
	rb_define_const(cDNSSDFlags, "RegistrationDomains", ULONG2NUM(kDNSServiceFlagsRegistrationDomains));

	/* Flag for creating a long-lived unicast query for the DNSDS.query_record()
	 * (currently not part of the Ruby API). */
	rb_define_const(cDNSSDFlags, "LongLivedQuery", ULONG2NUM(kDNSServiceFlagsLongLivedQuery));
}

/* Document-class: DNSSD::Reply
 * 
 * DNSSD::Reply is used to return information 
 *
 */

/* Document-class: DNSSD::Flags
 * 
 * Flags used in DNSSD Ruby API.
 */

