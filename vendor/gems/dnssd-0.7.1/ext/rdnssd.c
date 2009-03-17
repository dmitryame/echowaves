/*
 * == Authors
 * Chad Fowler, Charles Mills, Rich Kilmer
 *
 * == Copyright
 * Copyright (c) 2004 Chad Fowler, Charles Mills, Rich Kilmer
 * Licensed under the same terms as Ruby.
 * This software has absolutely no warranty.
 */

#include "rdnssd.h"
#include <assert.h>

VALUE mDNSSD;
static VALUE eDNSSDError;
static VALUE eDNSSDUnknownError;

#define DNSSD_ERROR_START	(-65556)
#define DNSSD_ERROR_END		(-65536)

static VALUE dnssd_errors[DNSSD_ERROR_END - DNSSD_ERROR_START];

static void
dnssd_errors_store(VALUE error, int num)
{
	assert(DNSSD_ERROR_START <= num && num < DNSSD_ERROR_END);
	dnssd_errors[num - DNSSD_ERROR_START] = error;
}

void
dnssd_check_error_code(DNSServiceErrorType e)
{
	int num = (int)e;
	if (num) {
		if(DNSSD_ERROR_START <= num && num < DNSSD_ERROR_END) {
			rb_raise(dnssd_errors[num - DNSSD_ERROR_START],
							 "DNSSD operation failed with error code: %d", num);
		} else {
			rb_raise(eDNSSDUnknownError,
							 "DNSSD operation failed with unrecognized error code: %d", num);
		}
	}
}

void
dnssd_instantiation_error(const char *what)
{
	rb_raise(rb_eRuntimeError,
					"cannot instantiate %s, use DNSSD "
					"enumerate_domains(), browse(), resolve() or register() instead",
					what);
}

/*
 * Document-module: DNSSD
 * DNSSD is a wrapper for Apple's DNS Service Discovery library.
 * The methods DNSSD.enumerate_domains, DNSSD.browse(),
 * DNSSD.register(), and DNSSD.resolve() provide the basic API
 * for making your applications DNS Service Discovery aware.
 *
 */

static void
Init_DNSSD(void)
{
	VALUE error_class;
	mDNSSD = rb_define_module("DNSSD");
	eDNSSDError = rb_define_class_under(mDNSSD, "Error", rb_eStandardError);
	
	/* Specifies all interfaces. */
	rb_define_const(mDNSSD, "InterfaceAny", ULONG2NUM(kDNSServiceInterfaceIndexAny));
	/* Specifies local interfaces only. */
	rb_define_const(mDNSSD, "InterfaceLocalOnly", ULONG2NUM(kDNSServiceInterfaceIndexLocalOnly));

	/* errors - these are 2 stepped (create and store) so that rdoc is happy */
	eDNSSDUnknownError = rb_define_class_under(mDNSSD, "UnknownError", eDNSSDError);
	dnssd_errors_store(eDNSSDUnknownError, -65537);

	error_class = rb_define_class_under(mDNSSD, "NoSuchNameError", eDNSSDError);
	dnssd_errors_store(error_class, -65538);

	dnssd_errors_store(rb_eNoMemError, -65539);

	error_class = rb_define_class_under(mDNSSD, "BadParamError", eDNSSDError);
	dnssd_errors_store(error_class, -65540);

	error_class = rb_define_class_under(mDNSSD, "BadReferenceError", eDNSSDError);
	dnssd_errors_store(error_class, -65541);

	error_class = rb_define_class_under(mDNSSD, "BadStateError", eDNSSDError);
	dnssd_errors_store(error_class, -65542);

	error_class = rb_define_class_under(mDNSSD, "BadFlagsError", eDNSSDError);
	dnssd_errors_store(error_class, -65543);
	
	error_class = rb_define_class_under(mDNSSD, "UnsupportedError", eDNSSDError);
	dnssd_errors_store(error_class, -65544);

	error_class = rb_define_class_under(mDNSSD, "NotInitializedError", eDNSSDError);
	dnssd_errors_store(error_class, -65545);

	error_class = rb_define_class_under(mDNSSD, "AlreadyRegisteredError", eDNSSDError);
	dnssd_errors_store(error_class, -65547);

	error_class = rb_define_class_under(mDNSSD, "NameConflictError", eDNSSDError);
	dnssd_errors_store(error_class, -65548);

	error_class = rb_define_class_under(mDNSSD, "InvalidError", eDNSSDError);
	dnssd_errors_store(error_class, -65549);

	error_class = rb_define_class_under(mDNSSD, "ClientIncompatibleError", eDNSSDError);
	dnssd_errors_store(error_class, -65551);

	error_class = rb_define_class_under(mDNSSD, "BadInterfaceIndexError", eDNSSDError);
	dnssd_errors_store(error_class, -65552);

	error_class = rb_define_class_under(mDNSSD, "ReferenceUsedError", eDNSSDError);
	dnssd_errors_store(error_class, -65553);

	error_class = rb_define_class_under(mDNSSD, "NoSuchRecordError", eDNSSDError);
	dnssd_errors_store(error_class, -65554);

	error_class = rb_define_class_under(mDNSSD, "NoAuthenticationError", eDNSSDError);
	dnssd_errors_store(error_class, -65555);

	error_class = rb_define_class_under(mDNSSD, "NoSuchKeyError", eDNSSDError);
	dnssd_errors_store(error_class, -65556);
}

/* Document-class: DNSSD::Error
 *
 * Base class of all DNS Service Discovery related errors.
 *
 */

/* defined in other .c files */
void Init_DNSSD_Service(void);
void Init_DNSSD_TextRecord(void);
void Init_DNSSD_Replies(void);

void
Init_rdnssd(void)
{
	/* called when library is required */
	Init_DNSSD();
	Init_DNSSD_Service();
	Init_DNSSD_TextRecord();
	Init_DNSSD_Replies();
}

