/*
 * Copyright (c) 2004 Chad Fowler, Charles Mills, Rich Kilmer
 * Licenced under the same terms as Ruby.
 * This software has absolutely no warrenty.
 */
#ifndef RDNSSD_INCLUDED
#define RDNSSD_INCLUDED

#include <ruby.h>
#include <intern.h>
#include <dns_sd.h>

/* for if_indextoname() and other unix networking functions */
#ifdef HAVE_UNISTD_H
	#include <unistd.h>
#endif
#ifdef HAVE_SYS_TYPES_H
	#include <sys/types.h>
#endif
#ifdef HAVE_SYS_SOCKET_H
	#include <sys/socket.h>
#endif
#ifdef HAVE_SYS_PARAM_H
	#include <sys/param.h>
#endif
#ifdef HAVE_NET_IF_H
	#include <net/if.h>
#endif
#ifdef HAVE_SYS_IF_H
	#include <sys/if.h>
#endif

extern VALUE mDNSSD;

void	dnssd_check_error_code(DNSServiceErrorType e);
void	dnssd_instantiation_error(const char *what);

VALUE	dnssd_create_fullname(const char *name, const char *regtype, const char *domain, int err_flag);
VALUE	dnssd_split_fullname(VALUE fullname);

/* decodes a buffer, creating a new text record */
VALUE	dnssd_tr_new(long len, const char *buf);

VALUE	dnssd_tr_to_encoded_str(VALUE v);

/* Get DNSServiceFlags from self */
DNSServiceFlags dnssd_to_flags(VALUE obj);

VALUE dnssd_domain_enum_new(VALUE service, DNSServiceFlags flags,
														uint32_t interface, const char *domain);

VALUE	dnssd_browse_new(VALUE service,	DNSServiceFlags flags, uint32_t interface,
												const char *name, const char *regtype, const char *domain);

VALUE dnssd_register_new(VALUE service,	DNSServiceFlags flags, const char *name,
													const char *regtype, const char *domain);

VALUE	dnssd_resolve_new(VALUE service, DNSServiceFlags flags, uint32_t interface,
												const char *fullname, const char *host_target,
												uint16_t opaqueport, uint16_t txt_len, const char *txt_rec);

#endif /* RDNSSD_INCLUDED */

