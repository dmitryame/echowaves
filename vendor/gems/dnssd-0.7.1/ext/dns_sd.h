/*
 * Copyright (c) 2003-2004 Apple Computer, Inc. All rights reserved.
 *
 * @APPLE_LICENSE_HEADER_START@
 * 
 * Copyright (c) 1999-2003 Apple Computer, Inc.  All Rights Reserved.
 * 
 * This file contains Original Code and/or Modifications of Original Code
 * as defined in and that are subject to the Apple Public Source License
 * Version 2.0 (the 'License'). You may not use this file except in
 * compliance with the License. Please obtain a copy of the License at
 * http://www.opensource.apple.com/apsl/ and read it before using this
 * file.
 * 
 * The Original Code and all software distributed under the License are
 * distributed on an 'AS IS' basis, WITHOUT WARRANTY OF ANY KIND, EITHER
 * EXPRESS OR IMPLIED, AND APPLE HEREBY DISCLAIMS ALL SUCH WARRANTIES,
 * INCLUDING WITHOUT LIMITATION, ANY WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE, QUIET ENJOYMENT OR NON-INFRINGEMENT.
 * Please see the License for the specific language governing rights and
 * limitations under the License.
 * 
 * @APPLE_LICENSE_HEADER_END@

    Change History (most recent first):

$Log: dns_sd.h,v $
Revision 1.1  2004/10/03 17:36:57  cmills
Adding the lastest version dns_sd.h to make it easier for users to compile
Ruby DNSSD from source.

Revision 1.17  2004/06/01 14:34:48  cheshire
For compatibility with older compilers, change '//' comments to ' / * ... * / '

Revision 1.16  2004/05/25 17:08:55  cheshire
Fix compiler warning (doesn't make sense for function return type to be const)

Revision 1.15  2004/05/21 21:41:35  cheshire
Add TXT record building and parsing APIs

Revision 1.14  2004/05/20 18:40:31  cheshire
Remove trailing comma that breaks build on strict compilers

Revision 1.13  2004/05/18 23:51:27  cheshire
Tidy up all checkin comments to use consistent "<rdar://problem/xxxxxxx>" format for bug numbers

Revision 1.12  2004/05/07 21:11:07  ksekar
API Update: Exposed new core error codes.  Added constants for
InterfaceIndexAny and InterfaceIndexLocalOnly.  Added flag for
long-lived unicast queries via DNSServiceQueryRecord.

Revision 1.11  2004/05/07 20:51:18  ksekar
<rdar://problem/3608226>: dns_sd.h needs to direct developers to
register their services at <http://www.dns-sd.org/ServiceTypes.html>

Revision 1.10  2004/05/06 18:42:58  ksekar
General dns_sd.h API cleanup, including the following radars:
<rdar://problem/3592068>: Remove flags with zero value
<rdar://problem/3479569>: Passing in NULL causes a crash.

Revision 1.9  2004/03/20 05:43:39  cheshire
Fix contributed by Terry Lambert & Alfred Perlstein:
On FreeBSD 4.x we need to include <sys/types.h> instead of <stdint.h>

Revision 1.8  2004/03/19 17:50:40  cheshire
Clarify comment about kDNSServiceMaxDomainName

Revision 1.7  2004/03/12 08:00:06  cheshire
Minor comment changes, headers, and wrap file in extern "C" for the benefit of C++ clients

Revision 1.6  2003/12/04 06:24:33  cheshire
Clarify meaning of MoreComing/Finished flag

Revision 1.5  2003/11/13 23:35:35  ksekar
<rdar://problem/3483020>: Header doesn't say that add/remove are possible values for flags
Bringing mDNSResponder project copy of dns_sd.h header up to date with
Libinfo copy

Revision 1.4  2003/10/13 23:50:53  ksekar
Updated dns_sd clientstub files to bring copies in synch with
top-of-tree Libinfo:  A memory leak in dnssd_clientstub.c is fixed,
and comments in dns_sd.h are improved.

Revision 1.3  2003/08/12 19:51:51  cheshire
Update to APSL 2.0
 */

#ifndef _DNS_SD_H
#define _DNS_SD_H

#ifdef  __cplusplus
    extern "C" {
#endif

#if defined(__FreeBSD__) && (__FreeBSD_version < 500000)
/* stdint.h does not exist on FreeBSD 4.x; its types are defined in sys/types.h instead */
#include <sys/types.h>
#else
#include <stdint.h>
#endif

/* DNSServiceRef, DNSRecordRef
 *
 * Opaque internal data types.
 * Note: client is responsible for serializing access to these structures if
 * they are shared between concurrent threads.
 */

typedef struct _DNSServiceRef_t *DNSServiceRef;
typedef struct _DNSRecordRef_t *DNSRecordRef;

/* General flags used in functions defined below */
enum
    {
    kDNSServiceFlagsMoreComing          = 0x1,
    /* MoreComing indicates to a callback that at least one more result is
     * queued and will be delivered following immediately after this one.
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

    kDNSServiceFlagsAdd                 = 0x2,
    kDNSServiceFlagsDefault             = 0x4,
    /* Flags for domain enumeration and browse/query reply callbacks.
     * "Default" applies only to enumeration and is only valid in
     * conjuction with "Add".  An enumeration callback with the "Add"
     * flag NOT set indicates a "Remove", i.e. the domain is no longer
     * valid.
     */

    kDNSServiceFlagsNoAutoRename        = 0x8,
    /* Flag for specifying renaming behavior on name conflict when registering
     * non-shared records. By default, name conflicts are automatically handled
     * by renaming the service.  NoAutoRename overrides this behavior - with this
     * flag set, name conflicts will result in a callback.  The NoAutorename flag
     * is only valid if a name is explicitly specified when registering a service
     * (ie the default name is not used.)
     */

    kDNSServiceFlagsShared              = 0x10,
    kDNSServiceFlagsUnique              = 0x20,
    /* Flag for registering individual records on a connected
     * DNSServiceRef.  Shared indicates that there may be multiple records
     * with this name on the network (e.g. PTR records).  Unique indicates that the
     * record's name is to be unique on the network (e.g. SRV records).
     */

    kDNSServiceFlagsBrowseDomains       = 0x40,
    kDNSServiceFlagsRegistrationDomains = 0x80,
    /* Flags for specifying domain enumeration type in DNSServiceEnumerateDomains.
     * BrowseDomains enumerates domains recommended for browsing, RegistrationDomains
     * enumerates domains recommended for registration.
     */

    kDNSServiceFlagsLongLivedQuery      = 0x100
    /* Flag for creating a long-lived unicast query for the DNSServiceQueryRecord call. */
    };

/* possible error code values */
enum
    {
    kDNSServiceErr_NoError             = 0,
    kDNSServiceErr_Unknown             = -65537,       /* 0xFFFE FFFF */
    kDNSServiceErr_NoSuchName          = -65538,
    kDNSServiceErr_NoMemory            = -65539,
    kDNSServiceErr_BadParam            = -65540,
    kDNSServiceErr_BadReference        = -65541,
    kDNSServiceErr_BadState            = -65542,
    kDNSServiceErr_BadFlags            = -65543,
    kDNSServiceErr_Unsupported         = -65544,
    kDNSServiceErr_NotInitialized      = -65545,
    kDNSServiceErr_AlreadyRegistered   = -65547,
    kDNSServiceErr_NameConflict        = -65548,
    kDNSServiceErr_Invalid             = -65549,
    kDNSServiceErr_Incompatible        = -65551,        /* client library incompatible with daemon */
    kDNSServiceErr_BadInterfaceIndex   = -65552,
    kDNSServiceErr_Refused             = -65553,
    kDNSServiceErr_NoSuchRecord        = -65554,
    kDNSServiceErr_NoAuth              = -65555,
    kDNSServiceErr_NoSuchKey           = -65556
    /* mDNS Error codes are in the range
     * FFFE FF00 (-65792) to FFFE FFFF (-65537) */
    };


/* Maximum length, in bytes, of a domain name represented as an escaped C-String */
/* including the final trailing dot, and the C-String terminating NULL at the end */

#define kDNSServiceMaxDomainName 1005

/* Constants for specifying an interface index.  Specific interface indexes are
 * identified via a 32-bit unsigned integer returned by the if_nametoindex()
 * family of calls
 */

#define kDNSServiceInterfaceIndexAny 0
#define kDNSServiceInterfaceIndexLocalOnly ( (uint32_t) ~0 )


typedef uint32_t DNSServiceFlags;
typedef int32_t DNSServiceErrorType;


/*********************************************************************************************
 *
 * Unix Domain Socket access, DNSServiceRef deallocation, and data processing functions
 *
 *********************************************************************************************/


/* DNSServiceRefSockFD()
 *
 * Access underlying Unix domain socket for an initialized DNSServiceRef.
 * The DNS Service Discovery implmementation uses this socket to communicate between
 * the client and the mDNSResponder daemon.  The application MUST NOT directly read from
 * or write to this socket.  Access to the socket is provided so that it can be used as a
 * run loop source, or in a select() loop: when data is available for reading on the socket,
 * DNSServiceProcessResult() should be called, which will extract the daemon's reply from
 * the socket, and pass it to the appropriate application callback.  By using a run loop or
 * select(), results from the daemon can be processed asynchronously.  Without using these
 * constructs, DNSServiceProcessResult() will block until the response from the daemon arrives.
 * The client is responsible for ensuring that the data on the socket is processed in a timely
 * fashion - the daemon may terminate its connection with a client that does not clear its
 * socket buffer.
 *
 * sdRef:            A DNSServiceRef initialized by any of the DNSService calls.
 *
 * return value:    The DNSServiceRef's underlying socket descriptor, or -1 on
 *                  error.
 */

int DNSServiceRefSockFD(DNSServiceRef sdRef);


/* DNSServiceProcessResult()
 *
 * Read a reply from the daemon, calling the appropriate application callback.  This call will
 * block until the daemon's response is received.  Use DNSServiceRefSockFD() in
 * conjunction with a run loop or select() to determine the presence of a response from the
 * server before calling this function to process the reply without blocking.  Call this function
 * at any point if it is acceptable to block until the daemon's response arrives.  Note that the
 * client is responsible for ensuring that DNSServiceProcessResult() is called whenever there is
 * a reply from the daemon - the daemon may terminate its connection with a client that does not
 * process the daemon's responses.
 *
 * sdRef:           A DNSServiceRef initialized by any of the DNSService calls
 *                  that take a callback parameter.
 *
 * return value:    Returns kDNSServiceErr_NoError on success, otherwise returns
 *                  an error code indicating the specific failure that occurred.
 */

DNSServiceErrorType DNSServiceProcessResult(DNSServiceRef sdRef);


/* DNSServiceRefDeallocate()
 *
 * Terminate a connection with the daemon and free memory associated with the DNSServiceRef.
 * Any services or records registered with this DNSServiceRef will be deregistered. Any
 * Browse, Resolve, or Query operations called with this reference will be terminated.
 *
 * Note: If the reference's underlying socket is used in a run loop or select() call, it should
 * be removed BEFORE DNSServiceRefDeallocate() is called, as this function closes the reference's
 * socket.
 *
 * Note: If the reference was initialized with DNSServiceCreateConnection(), any DNSRecordRefs
 * created via this reference will be invalidated by this call - the resource records are
 * deregistered, and their DNSRecordRefs may not be used in subsequent functions.  Similarly,
 * if the reference was initialized with DNSServiceRegister, and an extra resource record was
 * added to the service via DNSServiceAddRecord(), the DNSRecordRef created by the Add() call
 * is invalidated when this function is called - the DNSRecordRef may not be used in subsequent
 * functions.
 *
 * Note: This call is to be used only with the DNSServiceRef defined by this API.  It is
 * not compatible with dns_service_discovery_ref objects defined in the legacy Mach-based
 * DNSServiceDiscovery.h API.
 *
 * sdRef:           A DNSServiceRef initialized by any of the DNSService calls.
 *
 */

void DNSServiceRefDeallocate(DNSServiceRef sdRef);


/*********************************************************************************************
 *
 * Domain Enumeration
 *
 *********************************************************************************************/

/* DNSServiceEnumerateDomains()
 *
 * Asynchronously enumerate domains available for browsing and registration.
 * Currently, the only domain returned is "local.", but other domains will be returned in future.
 *
 * The enumeration MUST be cancelled via DNSServiceRefDeallocate() when no more domains
 * are to be found.
 *
 *
 * DNSServiceDomainEnumReply Callback Parameters:
 *
 * sdRef:           The DNSServiceRef initialized by DNSServiceEnumerateDomains().
 *
 * flags:           Possible values are:
 *                  kDNSServiceFlagsMoreComing
 *                  kDNSServiceFlagsAdd
 *                  kDNSServiceFlagsDefault
 *
 * interfaceIndex:  Specifies the interface on which the domain exists.  (The index for a given
 *                  interface is determined via the if_nametoindex() family of calls.)
 *
 * errorCode:       Will be kDNSServiceErr_NoError (0) on success, otherwise indicates
 *                  the failure that occurred (other parameters are undefined if errorCode is nonzero).
 *
 * replyDomain:     The name of the domain.
 *
 * context:         The context pointer passed to DNSServiceEnumerateDomains.
 *
 */

typedef void (*DNSServiceDomainEnumReply)
    (
    DNSServiceRef                       sdRef,
    DNSServiceFlags                     flags,
    uint32_t                            interfaceIndex,
    DNSServiceErrorType                 errorCode,
    const char                          *replyDomain,
    void                                *context
    );


/* DNSServiceEnumerateDomains() Parameters:
 *
 *
 * sdRef:           A pointer to an uninitialized DNSServiceRef.  May be passed to
 *                  DNSServiceRefDeallocate() to cancel the enumeration.
 *
 * flags:           Possible values are:
 *                  kDNSServiceFlagsBrowseDomains to enumerate domains recommended for browsing.
 *                  kDNSServiceFlagsRegistrationDomains to enumerate domains recommended
 *                  for registration.
 *
 * interfaceIndex:  If non-zero, specifies the interface on which to look for domains.
 *                  (the index for a given interface is determined via the if_nametoindex()
 *                  family of calls.)  Most applications will pass 0 to enumerate domains on
 *                  all interfaces.
 *
 * callBack:        The function to be called when a domain is found or the call asynchronously
 *                  fails.
 *
 * context:         An application context pointer which is passed to the callback function
 *                  (may be NULL).
 *
 * return value:    Returns kDNSServiceErr_NoError on succeses (any subsequent, asynchronous
 *                  errors are delivered to the callback), otherwise returns an error code indicating
 *                  the error that occurred (the callback is not invoked and the DNSServiceRef
 *                  is not initialized.)
 */

DNSServiceErrorType DNSServiceEnumerateDomains
    (
    DNSServiceRef                       *sdRef,
    DNSServiceFlags                     flags,
    uint32_t                            interfaceIndex,
    DNSServiceDomainEnumReply           callBack,
    void                                *context  /* may be NULL */
    );


/*********************************************************************************************
 *
 *  Service Registration
 *
 *********************************************************************************************/

/* Register a service that is discovered via Browse() and Resolve() calls.
 *
 *
 * DNSServiceRegisterReply() Callback Parameters:
 *
 * sdRef:           The DNSServiceRef initialized by DNSServiceRegister().
 *
 * flags:           Currently unused, reserved for future use.
 *
 * errorCode:       Will be kDNSServiceErr_NoError on success, otherwise will
 *                  indicate the failure that occurred (including name conflicts, if the
 *                  kDNSServiceFlagsNoAutoRename flag was passed to the
 *                  callout.)  Other parameters are undefined if errorCode is nonzero.
 *
 * name:            The service name registered (if the application did not specify a name in
 *                  DNSServiceRegister(), this indicates what name was automatically chosen).
 *
 * regtype:         The type of service registered, as it was passed to the callout.
 *
 * domain:          The domain on which the service was registered (if the application did not
 *                  specify a domain in DNSServiceRegister(), this indicates the default domain
 *                  on which the service was registered).
 *
 * context:         The context pointer that was passed to the callout.
 *
 */

typedef void (*DNSServiceRegisterReply)
    (
    DNSServiceRef                       sdRef,
    DNSServiceFlags                     flags,
    DNSServiceErrorType                 errorCode,
    const char                          *name,
    const char                          *regtype,
    const char                          *domain,
    void                                *context
    );


/* DNSServiceRegister()  Parameters:
 *
 * sdRef:           A pointer to an uninitialized DNSServiceRef.  If this call succeeds, the reference
 *                  may be passed to
 *                  DNSServiceRefDeallocate() to deregister the service.
 *
 * interfaceIndex:  If non-zero, specifies the interface on which to register the service
 *                  (the index for a given interface is determined via the if_nametoindex()
 *                  family of calls.)  Most applications will pass 0 to register on all
 *                  available interfaces.  Pass -1 to register a service only on the local
 *                  machine (service will not be visible to remote hosts.)
 *
 * flags:           Indicates the renaming behavior on name conflict (most applications
 *                  will pass 0).  See flag definitions above for details.
 *
 * name:            If non-NULL, specifies the service name to be registered.
 *                  Most applications will not specify a name, in which case the
 *                  computer name is used (this name is communicated to the client via
 *                  the callback).
 *
 * regtype:         The service type followed by the protocol, separated by a dot
 *                  (e.g. "_ftp._tcp").  The transport protocol must be "_tcp" or "_udp".
 *                  New service types should be registered at htp://www.dns-sd.org/ServiceTypes.html.
 *
 * domain:          If non-NULL, specifies the domain on which to advertise the service.
 *                  Most applications will not specify a domain, instead automatically
 *                  registering in the default domain(s).
 *
 * host:            If non-NULL, specifies the SRV target host name.  Most applications
 *                  will not specify a host, instead automatically using the machine's
 *                  default host name(s).  Note that specifying a non-NULL host does NOT
 *                  create an address record for that host - the application is responsible
 *                  for ensuring that the appropriate address record exists, or creating it
 *                  via DNSServiceRegisterRecord().
 *
 * port:            The port, in network byte order, on which the service accepts connections.
 *                  Pass 0 for a "placeholder" service (i.e. a service that will not be discovered
 *                  by browsing, but will cause a name conflict if another client tries to
 *                  register that same name).  Most clients will not use placeholder services.
 *
 * txtLen:          The length of the txtRecord, in bytes.  Must be zero if the txtRecord is NULL.
 *
 * txtRecord:       The txt record rdata.  May be NULL.  Note that a non-NULL txtRecord
 *                  MUST be a properly formatted DNS TXT record, i.e. <length byte> <data>
 *                  <length byte> <data> ...
 *
 * callBack:        The function to be called when the registration completes or asynchronously
 *                  fails.  The client MAY pass NULL for the callback -  The client will NOT be notified
 *                  of the default values picked on its behalf, and the client will NOT be notified of any
 *                  asynchronous errors (e.g. out of memory errors, etc.) that may prevent the registration
 *                  of the service.  The client may NOT pass the NoAutoRename flag if the callback is NULL.
 *                  The client may still deregister the service at any time via DNSServiceRefDeallocate().
 *
 * context:         An application context pointer which is passed to the callback function
 *                  (may be NULL).
 *
 * return value:    Returns kDNSServiceErr_NoError on succeses (any subsequent, asynchronous
 *                  errors are delivered to the callback), otherwise returns an error code indicating
 *                  the error that occurred (the callback is never invoked and the DNSServiceRef
 *                  is not initialized.)
 *
 */

DNSServiceErrorType DNSServiceRegister
    (
    DNSServiceRef                       *sdRef,
    DNSServiceFlags                     flags,
    uint32_t                            interfaceIndex,
    const char                          *name,         /* may be NULL */
    const char                          *regtype,
    const char                          *domain,       /* may be NULL */
    const char                          *host,         /* may be NULL */
    uint16_t                            port,
    uint16_t                            txtLen,
    const void                          *txtRecord,    /* may be NULL */
    DNSServiceRegisterReply             callBack,      /* may be NULL */
    void                                *context       /* may be NULL */
    );


/* DNSServiceAddRecord()
 *
 * Add a record to a registered service.  The name of the record will be the same as the
 * registered service's name.
 * The record can later be updated or deregistered by passing the RecordRef initialized
 * by this function to DNSServiceUpdateRecord() or DNSServiceRemoveRecord().
 *
 *
 * Parameters;
 *
 * sdRef:           A DNSServiceRef initialized by DNSServiceRegister().
 *
 * RecordRef:       A pointer to an uninitialized DNSRecordRef.  Upon succesfull completion of this
 *                  call, this ref may be passed to DNSServiceUpdateRecord() or DNSServiceRemoveRecord().
 *                  If the above DNSServiceRef is passed to DNSServiceRefDeallocate(), RecordRef is also
 *                  invalidated and may not be used further.
 *
 * flags:           Currently ignored, reserved for future use.
 *
 * rrtype:          The type of the record (e.g. TXT, SRV, etc), as defined in nameser.h.
 *
 * rdlen:           The length, in bytes, of the rdata.
 *
 * rdata:           The raw rdata to be contained in the added resource record.
 *
 * ttl:             The time to live of the resource record, in seconds.
 *
 * return value:    Returns kDNSServiceErr_NoError on success, otherwise returns an
 *                  error code indicating the error that occurred (the RecordRef is not initialized).
 */

DNSServiceErrorType DNSServiceAddRecord
    (
    DNSServiceRef                       sdRef,
    DNSRecordRef                        *RecordRef,
    DNSServiceFlags                     flags,
    uint16_t                            rrtype,
    uint16_t                            rdlen,
    const void                          *rdata,
    uint32_t                            ttl
    );


/* DNSServiceUpdateRecord
 *
 * Update a registered resource record.  The record must either be:
 *   - The primary txt record of a service registered via DNSServiceRegister()
 *   - A record added to a registered service via DNSServiceAddRecord()
 *   - An individual record registered by DNSServiceRegisterRecord()
 *
 *
 * Parameters:
 *
 * sdRef:           A DNSServiceRef that was initialized by DNSServiceRegister()
 *                  or DNSServiceCreateConnection().
 *
 * RecordRef:       A DNSRecordRef initialized by DNSServiceAddRecord, or NULL to update the
 *                  service's primary txt record.
 *
 * flags:           Currently ignored, reserved for future use.
 *
 * rdlen:           The length, in bytes, of the new rdata.
 *
 * rdata:           The new rdata to be contained in the updated resource record.
 *
 * ttl:             The time to live of the updated resource record, in seconds.
 *
 * return value:    Returns kDNSServiceErr_NoError on success, otherwise returns an
 *                  error code indicating the error that occurred.
 */

DNSServiceErrorType DNSServiceUpdateRecord
    (
    DNSServiceRef                       sdRef,
    DNSRecordRef                        RecordRef,     /* may be NULL */
    DNSServiceFlags                     flags,
    uint16_t                            rdlen,
    const void                          *rdata,
    uint32_t                            ttl
    );


/* DNSServiceRemoveRecord
 *
 * Remove a record previously added to a service record set via DNSServiceAddRecord(), or deregister
 * an record registered individually via DNSServiceRegisterRecord().
 *
 * Parameters:
 *
 * sdRef:           A DNSServiceRef initialized by DNSServiceRegister() (if the
 *                  record being removed was registered via DNSServiceAddRecord()) or by
 *                  DNSServiceCreateConnection() (if the record being removed was registered via
 *                  DNSServiceRegisterRecord()).
 *
 * recordRef:       A DNSRecordRef initialized by a successful call to DNSServiceAddRecord()
 *                  or DNSServiceRegisterRecord().
 *
 * flags:           Currently ignored, reserved for future use.
 *
 * return value:    Returns kDNSServiceErr_NoError on success, otherwise returns an
 *                  error code indicating the error that occurred.
 */

DNSServiceErrorType DNSServiceRemoveRecord
    (
    DNSServiceRef                 sdRef,
    DNSRecordRef                  RecordRef,
    DNSServiceFlags               flags
    );


/*********************************************************************************************
 *
 *  Service Discovery
 *
 *********************************************************************************************/

/* Browse for instances of a service.
 *
 *
 * DNSServiceBrowseReply() Parameters:
 *
 * sdRef:           The DNSServiceRef initialized by DNSServiceBrowse().
 *
 * flags:           Possible values are kDNSServiceFlagsMoreComing and kDNSServiceFlagsAdd.
 *                  See flag definitions for details.
 *
 * interfaceIndex:  The interface on which the service is advertised.  This index should
 *                  be passed to DNSServiceResolve() when resolving the service.
 *
 * errorCode:       Will be kDNSServiceErr_NoError (0) on success, otherwise will
 *                  indicate the failure that occurred.  Other parameters are undefined if
 *                  the errorCode is nonzero.
 *
 * serviceName:     The service name discovered.
 *
 * regtype:         The service type, as passed in to DNSServiceBrowse().
 *
 * domain:          The domain on which the service was discovered (if the application did not
 *                  specify a domain in DNSServicBrowse(), this indicates the domain on which the
 *                  service was discovered.)
 *
 * context:         The context pointer that was passed to the callout.
 *
 */

typedef void (*DNSServiceBrowseReply)
    (
    DNSServiceRef                       sdRef,
    DNSServiceFlags                     flags,
    uint32_t                            interfaceIndex,
    DNSServiceErrorType                 errorCode,
    const char                          *serviceName,
    const char                          *regtype,
    const char                          *replyDomain,
    void                                *context
    );


/* DNSServiceBrowse() Parameters:
 *
 * sdRef:           A pointer to an uninitialized DNSServiceRef.  May be passed to
 *                  DNSServiceRefDeallocate() to terminate the browse.
 *
 * flags:           Currently ignored, reserved for future use.
 *
 * interfaceIndex:  If non-zero, specifies the interface on which to browse for services
 *                  (the index for a given interface is determined via the if_nametoindex()
 *                  family of calls.)  Most applications will pass 0 to browse on all available
 *                  interfaces.  Pass -1 to only browse for services provided on the local host.
 *
 * regtype:         The service type being browsed for followed by the protocol, separated by a
 *                  dot (e.g. "_ftp._tcp").  The transport protocol must be "_tcp" or "_udp".
 *
 * domain:          If non-NULL, specifies the domain on which to browse for services.
 *                  Most applications will not specify a domain, instead browsing on the
 *                  default domain(s).
 *
 * callBack:        The function to be called when an instance of the service being browsed for
 *                  is found, or if the call asynchronously fails.
 *
 * context:         An application context pointer which is passed to the callback function
 *                  (may be NULL).
 *
 * return value:    Returns kDNSServiceErr_NoError on succeses (any subsequent, asynchronous
 *                  errors are delivered to the callback), otherwise returns an error code indicating
 *                  the error that occurred (the callback is not invoked and the DNSServiceRef
 *                  is not initialized.)
 */

DNSServiceErrorType DNSServiceBrowse
    (
    DNSServiceRef                       *sdRef,
    DNSServiceFlags                     flags,
    uint32_t                            interfaceIndex,
    const char                          *regtype,
    const char                          *domain,    /* may be NULL */
    DNSServiceBrowseReply               callBack,
    void                                *context    /* may be NULL */
    );


/* DNSServiceResolve()
 *
 * Resolve a service name discovered via DNSServiceBrowse() to a target host name, port number, and
 * txt record.
 *
 * Note: Applications should NOT use DNSServiceResolve() solely for txt record monitoring - use
 * DNSServiceQueryRecord() instead, as it is more efficient for this task.
 *
 * Note: When the desired results have been returned, the client MUST terminate the resolve by calling
 * DNSServiceRefDeallocate().
 *
 * Note: DNSServiceResolve() behaves correctly for typical services that have a single SRV record and
 * a single TXT record (the TXT record may be empty.)  To resolve non-standard services with multiple
 * SRV or TXT records, DNSServiceQueryRecord() should be used.
 *
 * DNSServiceResolveReply Callback Parameters:
 *
 * sdRef:           The DNSServiceRef initialized by DNSServiceResolve().
 *
 * flags:           Currently unused, reserved for future use.
 *
 * interfaceIndex:  The interface on which the service was resolved.
 *
 * errorCode:       Will be kDNSServiceErr_NoError (0) on success, otherwise will
 *                  indicate the failure that occurred.  Other parameters are undefined if
 *                  the errorCode is nonzero.
 *
 * fullname:        The full service domain name, in the form <servicename>.<protocol>.<domain>.
 *                  (Any literal dots (".") are escaped with a backslash ("\."), and literal
 *                  backslashes are escaped with a second backslash ("\\"), e.g. a web server
 *                  named "Dr. Pepper" would have the fullname  "Dr\.\032Pepper._http._tcp.local.").
 *                  This is the appropriate format to pass to standard system DNS APIs such as
 *                  res_query(), or to the special-purpose functions included in this API that
 *                  take fullname parameters.
 *
 * hosttarget:      The target hostname of the machine providing the service.  This name can
 *                  be passed to functions like gethostbyname() to identify the host's IP address.
 *
 * port:            The port, in network byte order, on which connections are accepted for this service.
 *
 * txtLen:          The length of the txt record, in bytes.
 *
 * txtRecord:       The service's primary txt record, in standard txt record format.
 *

 * context:         The context pointer that was passed to the callout.
 *
 */

typedef void (*DNSServiceResolveReply)
    (
    DNSServiceRef                       sdRef,
    DNSServiceFlags                     flags,
    uint32_t                            interfaceIndex,
    DNSServiceErrorType                 errorCode,
    const char                          *fullname,
    const char                          *hosttarget,
    uint16_t                            port,
    uint16_t                            txtLen,
    const char                          *txtRecord,
    void                                *context
    );


/* DNSServiceResolve() Parameters
 *
 * sdRef:           A pointer to an uninitialized DNSServiceRef.  May be passed to
 *                  DNSServiceRefDeallocate() to terminate the resolve.
 *
 * flags:           Currently ignored, reserved for future use.
 *
 * interfaceIndex:  The interface on which to resolve the service.  The client should
 *                  pass the interface on which the servicename was discovered, i.e.
 *                  the interfaceIndex passed to the DNSServiceBrowseReply callback,
 *                  or 0 to resolve the named service on all available interfaces.
 *
 * name:            The servicename to be resolved.
 *
 * regtype:         The service type being resolved followed by the protocol, separated by a
 *                  dot (e.g. "_ftp._tcp").  The transport protocol must be "_tcp" or "_udp".
 *
 * domain:          The domain on which the service is registered, i.e. the domain passed
 *                  to the DNSServiceBrowseReply callback.
 *
 * callBack:        The function to be called when a result is found, or if the call
 *                  asynchronously fails.
 *
 * context:         An application context pointer which is passed to the callback function
 *                  (may be NULL).
 *
 * return value:    Returns kDNSServiceErr_NoError on succeses (any subsequent, asynchronous
 *                  errors are delivered to the callback), otherwise returns an error code indicating
 *                  the error that occurred (the callback is never invoked and the DNSServiceRef
 *                  is not initialized.)
 */

DNSServiceErrorType DNSServiceResolve
    (
    DNSServiceRef                       *sdRef,
    DNSServiceFlags                     flags,
    uint32_t                            interfaceIndex,
    const char                          *name,
    const char                          *regtype,
    const char                          *domain,
    DNSServiceResolveReply              callBack,
    void                                *context  /* may be NULL */
    );


/*********************************************************************************************
 *
 *  Special Purpose Calls (most applications will not use these)
 *
 *********************************************************************************************/

/* Note on DNS Naming Conventions:
 *
 * The functions below refer to resource records by their full domain name, unlike the
 * functions above which divide the name into servicename/regtype/domain fields.  In the
 * functions above, a dot (".") is considered to be a literal dot in the servicename field
 * (e.g. "Dr. Pepper") and a label separator in the regtype ("_ftp._tcp") or domain
 * ("apple.com") fields.  Literal dots in the domain field would be escaped with a backslash,
 * and literal backslashes would be escaped with a second backslash (this is generally not an
 * issue, as domain names on the Internet today almost never use characters other than
 * letters, digits, or hyphens, and the dots are label separators.) Furthermore, this is
 * transparent to the caller, so long as the fields are passed between functions without
 * manipulation.  However, the following, special-purpose calls use a single, full domain
 * name.  As such, all dots are considered to be label separators, unless escaped, and all
 * backslashes are considered to be escape characters, unless preceded by a second backslash.
 * For example, the name "Dr. Smith \ Dr. Johnson" could be passed literally as a service
 * name parameter in the above calls, but in the special purpose calls, the dots and backslash
 * would have to be escaped (e.g. "Dr\. Smith \\ Dr\. Johnson._ftp._tcp.apple.com" for an ftp
 * service on the apple.com domain.) The function DNSServiceConstructFullName() is provided
 * to aid in this conversion from servicename/regtype/domain to a single fully-qualified DNS
 * name with proper escaping.
 */

/* DNSServiceCreateConnection()
 *
 * Create a connection to the daemon allowing efficient registration of
 * multiple individual records.
 *
 *
 * Parameters:
 *
 * sdRef:           A pointer to an uninitialized DNSServiceRef.  Deallocating
 *                  the reference (via DNSServiceRefDeallocate()) severs the
 *                  connection and deregisters all records registered on this connection.
 *
 * return value:    Returns kDNSServiceErr_NoError on success, otherwise returns
 *                  an error code indicating the specific failure that occurred (in which
 *                  case the DNSServiceRef is not initialized).
 */

DNSServiceErrorType DNSServiceCreateConnection(DNSServiceRef *sdRef);


/* DNSServiceRegisterRecord
 *
 * Register an individual resource record on a connected DNSServiceRef.
 *
 * Note that name conflicts occurring for records registered via this call must be handled
 * by the client in the callback.
 *
 *
 * DNSServiceRegisterRecordReply() parameters:
 *
 * sdRef:           The connected DNSServiceRef initialized by
 *                  DNSServiceDiscoveryConnect().
 *
 * RecordRef:       The DNSRecordRef initialized by DNSServiceRegisterRecord().  If the above
 *                  DNSServiceRef is passed to DNSServiceRefDeallocate(), this DNSRecordRef is
 *                  invalidated, and may not be used further.
 *
 * flags:           Currently unused, reserved for future use.
 *
 * errorCode:       Will be kDNSServiceErr_NoError on success, otherwise will
 *                  indicate the failure that occurred (including name conflicts.)
 *                  Other parameters are undefined if errorCode is nonzero.
 *
 * context:         The context pointer that was passed to the callout.
 *
 */

 typedef void (*DNSServiceRegisterRecordReply)
    (
    DNSServiceRef                       sdRef,
    DNSRecordRef                        RecordRef,
    DNSServiceFlags                     flags,
    DNSServiceErrorType                 errorCode,
    void                                *context
    );


/* DNSServiceRegisterRecord() Parameters:
 *
 * sdRef:           A DNSServiceRef initialized by DNSServiceCreateConnection().
 *
 * RecordRef:       A pointer to an uninitialized DNSRecordRef.  Upon succesfull completion of this
 *                  call, this ref may be passed to DNSServiceUpdateRecord() or DNSServiceRemoveRecord().
 *                  (To deregister ALL records registered on a single connected DNSServiceRef
 *                  and deallocate each of their corresponding DNSServiceRecordRefs, call
 *                  DNSServiceRefDealloocate()).
 *
 * flags:           Possible values are kDNSServiceFlagsShared or kDNSServiceFlagsUnique
 *                  (see flag type definitions for details).
 *
 * interfaceIndex:  If non-zero, specifies the interface on which to register the record
 *                  (the index for a given interface is determined via the if_nametoindex()
 *                  family of calls.)  Passing 0 causes the record to be registered on all interfaces.
 *                  Passing -1 causes the record to only be visible on the local host.
 *
 * fullname:        The full domain name of the resource record.
 *
 * rrtype:          The numerical type of the resource record (e.g. PTR, SRV, etc), as defined
 *                  in nameser.h.
 *
 * rrclass:         The class of the resource record, as defined in nameser.h (usually 1 for the
 *                  Internet class).
 *
 * rdlen:           Length, in bytes, of the rdata.
 *
 * rdata:           A pointer to the raw rdata, as it is to appear in the DNS record.
 *
 * ttl:             The time to live of the resource record, in seconds.
 *
 * callBack:        The function to be called when a result is found, or if the call
 *                  asynchronously fails (e.g. because of a name conflict.)
 *
 * context:         An application context pointer which is passed to the callback function
 *                  (may be NULL).
 *
 * return value:    Returns kDNSServiceErr_NoError on succeses (any subsequent, asynchronous
 *                  errors are delivered to the callback), otherwise returns an error code indicating
 *                  the error that occurred (the callback is never invoked and the DNSRecordRef is
 *                  not initialized.)
 */

DNSServiceErrorType DNSServiceRegisterRecord
    (
    DNSServiceRef                       sdRef,
    DNSRecordRef                        *RecordRef,
    DNSServiceFlags                     flags,
    uint32_t                            interfaceIndex,
    const char                          *fullname,
    uint16_t                            rrtype,
    uint16_t                            rrclass,
    uint16_t                            rdlen,
    const void                          *rdata,
    uint32_t                            ttl,
    DNSServiceRegisterRecordReply       callBack,
    void                                *context    /* may be NULL */
    );


/* DNSServiceQueryRecord
 *
 * Query for an arbitrary DNS record.
 *
 *
 * DNSServiceQueryRecordReply() Callback Parameters:
 *
 * sdRef:           The DNSServiceRef initialized by DNSServiceQueryRecord().
 *
 * flags:           Possible values are kDNSServiceFlagsMoreComing and
 *                  kDNSServiceFlagsAdd.  The Add flag is NOT set for PTR records
 *                  with a ttl of 0, i.e. "Remove" events.
 *
 * interfaceIndex:  The interface on which the query was resolved (the index for a given
 *                  interface is determined via the if_nametoindex() family of calls).
 *
 * errorCode:       Will be kDNSServiceErr_NoError on success, otherwise will
 *                  indicate the failure that occurred.  Other parameters are undefined if
 *                  errorCode is nonzero.
 *
 * fullname:        The resource record's full domain name.
 *
 * rrtype:          The resource record's type (e.g. PTR, SRV, etc) as defined in nameser.h.
 *
 * rrclass:         The class of the resource record, as defined in nameser.h (usually 1).
 *
 * rdlen:           The length, in bytes, of the resource record rdata.
 *
 * rdata:           The raw rdata of the resource record.
 *
 * ttl:             The resource record's time to live, in seconds.
 *
 * context:         The context pointer that was passed to the callout.
 *
 */

typedef void (*DNSServiceQueryRecordReply)
    (
    DNSServiceRef                       DNSServiceRef,
    DNSServiceFlags                     flags,
    uint32_t                            interfaceIndex,
    DNSServiceErrorType                 errorCode,
    const char                          *fullname,
    uint16_t                            rrtype,
    uint16_t                            rrclass,
    uint16_t                            rdlen,
    const void                          *rdata,
    uint32_t                            ttl,
    void                                *context
    );


/* DNSServiceQueryRecord() Parameters:
 *
 * sdRef:           A pointer to an uninitialized DNSServiceRef.
 *
 * flags:           Pass kDNSServiceFlagsLongLivedQuery to create a "long-lived" unicast
 *                  query in a non-local domain.  Without setting this flag, unicast queries
 *                  will be one-shot - that is, only answers available at the time of the call
 *                  will be returned.  By setting this flag, answers (including Add and Remove
 *                  events) that become available after the initial call is made will generate
 *                  callbacks.  This flag has no effect on link-local multicast queries.
 *
 * interfaceIndex:  If non-zero, specifies the interface on which to issue the query
 *                  (the index for a given interface is determined via the if_nametoindex()
 *                  family of calls.)  Passing 0 causes the name to be queried for on all
 *                  interfaces.  Passing -1 causes the name to be queried for only on the
 *                  local host.
 *
 * fullname:        The full domain name of the resource record to be queried for.
 *
 * rrtype:          The numerical type of the resource record to be queried for (e.g. PTR, SRV, etc)
 *                  as defined in nameser.h.
 *
 * rrclass:         The class of the resource record, as defined in nameser.h
 *                  (usually 1 for the Internet class).
 *
 * callBack:        The function to be called when a result is found, or if the call
 *                  asynchronously fails.
 *
 * context:         An application context pointer which is passed to the callback function
 *                  (may be NULL).
 *
 * return value:    Returns kDNSServiceErr_NoError on succeses (any subsequent, asynchronous
 *                  errors are delivered to the callback), otherwise returns an error code indicating
 *                  the error that occurred (the callback is never invoked and the DNSServiceRef
 *                  is not initialized.)
 */

DNSServiceErrorType DNSServiceQueryRecord
    (
    DNSServiceRef                       *sdRef,
    DNSServiceFlags                     flags,
    uint32_t                            interfaceIndex,
    const char                          *fullname,
    uint16_t                            rrtype,
    uint16_t                            rrclass,
    DNSServiceQueryRecordReply          callBack,
    void                                *context  /* may be NULL */
    );


/* DNSServiceReconfirmRecord
 *
 * Instruct the daemon to verify the validity of a resource record that appears to
 * be out of date (e.g. because tcp connection to a service's target failed.)
 * Causes the record to be flushed from the daemon's cache (as well as all other
 * daemons' caches on the network) if the record is determined to be invalid.
 *
 * Parameters:
 *
 * flags:           Currently unused, reserved for future use.
 *
 * fullname:        The resource record's full domain name.
 *
 * rrtype:          The resource record's type (e.g. PTR, SRV, etc) as defined in nameser.h.
 *
 * rrclass:         The class of the resource record, as defined in nameser.h (usually 1).
 *
 * rdlen:           The length, in bytes, of the resource record rdata.
 *
 * rdata:           The raw rdata of the resource record.
 *
 */

void DNSServiceReconfirmRecord
    (
    DNSServiceFlags                    flags,
    uint32_t                           interfaceIndex,
    const char                         *fullname,
    uint16_t                           rrtype,
    uint16_t                           rrclass,
    uint16_t                           rdlen,
    const void                         *rdata
    );


/*********************************************************************************************
 *
 *  General Utility Functions
 *
 *********************************************************************************************/

/* DNSServiceConstructFullName()
 *
 * Concatenate a three-part domain name (as returned by the above callbacks) into a
 * properly-escaped full domain name. Note that callbacks in the above functions ALREADY ESCAPE
 * strings where necessary.
 *
 * Parameters:
 *
 * fullName:        A pointer to a buffer that where the resulting full domain name is to be written.
 *                  The buffer must be kDNSServiceMaxDomainName (1005) bytes in length to
 *                  accommodate the longest legal domain name without buffer overrun.
 *
 * service:         The service name - any dots or slashes must NOT be escaped.
 *                  May be NULL (to construct a PTR record name, e.g.
 *                  "_ftp._tcp.apple.com").
 *
 * regtype:         The service type followed by the protocol, separated by a dot
 *                  (e.g. "_ftp._tcp").
 *
 * domain:          The domain name, e.g. "apple.com".  Any literal dots or backslashes
 *                  must be escaped.
 *
 * return value:    Returns 0 on success, -1 on error.
 *
 */

int DNSServiceConstructFullName
    (
    char                            *fullName,
    const char                      *service,      /* may be NULL */
    const char                      *regtype,
    const char                      *domain
    );


/*********************************************************************************************
 *
 *   TXT Record Construction Functions
 *
 *********************************************************************************************/

/*
 * A typical calling sequence for TXT record construction is something like:
 *
 * Client allocates storage for TXTRecord data (e.g. declare buffer on the stack)
 * TXTRecordCreate();
 * TXTRecordSetValue();
 * TXTRecordSetValue();
 * TXTRecordSetValue();
 * ...
 * DNSServiceRegister( ... TXTRecordGetLength(), TXTRecordGetBytesPtr() ... );
 * TXTRecordDeallocate();
 * Explicitly deallocate storage for TXTRecord data (if not allocated on the stack)
 */


/* TXTRecordRef
 *
 * Opaque internal data type.
 * Note: Represents a DNS-SD TXT record.
 */

typedef struct _TXTRecordRef_t { char private[16]; } TXTRecordRef;


/* TXTRecordCreate()
 *
 * Creates a new empty TXTRecordRef referencing the specified storage.
 *
 * If the buffer parameter is NULL, or the specified storage size is not
 * large enough to hold a key subsequently added using TXTRecordSetValue(),
 * then additional memory will be added as needed using malloc().
 *
 * On some platforms, when memory is low, malloc() may fail. In this
 * case, TXTRecordSetValue() will return kDNSServiceErr_NoMemory, and this
 * error condition will need to be handled as appropriate by the caller.
 *
 * You can avoid the need to handle this error condition if you ensure
 * that the storage you initially provide is large enough to hold all
 * the key/value pairs that are to be added to the record.
 * The caller can precompute the exact length required for all of the
 * key/value pairs to be added, or simply provide a fixed-sized buffer
 * known in advance to be large enough.
 * A no-value (key-only) key requires  (1 + key length) bytes.
 * A key with empty value requires     (1 + key length + 1) bytes.
 * A key with non-empty value requires (1 + key length + 1 + value length).
 * For most applications, DNS-SD TXT records are generally
 * less than 100 bytes, so in most cases a simple fixed-sized
 * 256-byte buffer will be more than sufficient.
 * Recommended size limits for DNS-SD TXT Records are discussed in
 * <http://files.dns-sd.org/draft-cheshire-dnsext-dns-sd.txt>
 *
 * txtRecord:       A pointer to an uninitialized TXTRecordRef.
 *
 * bufferLen:       The size of the storage provided in the "buffer" parameter.
 *
 * buffer:          The storage used to hold the TXTRecord data.
 *                  This storage must remain valid for as long as
 *                  the TXTRecordRef.
 */

void TXTRecordCreate
    (
    TXTRecordRef     *txtRecord,
    uint16_t         bufferLen,
    void             *buffer
    );


/* TXTRecordDeallocate()
 *
 * Releases any resources allocated in the course of preparing a TXT Record
 * using TXTRecordCreate()/TXTRecordSetValue()/TXTRecordRemoveValue().
 * Ownership of the buffer provided in TXTRecordCreate() returns to the client.
 *
 * txtRecord:           A TXTRecordRef initialized by calling TXTRecordCreate().
 *
 */

void TXTRecordDeallocate
    (
    TXTRecordRef     *txtRecord
    );


/* TXTRecordSetValue()
 *
 * Adds a key (optionally with value) to a TXTRecordRef. If the "key" already
 * exists in the TXTRecordRef, then the current value will be replaced with
 * the new value.
 * Keys may exist in four states with respect to a given TXT record:
 *  - Absent (key does not appear at all)
 *  - Present with no value ("key" appears alone)
 *  - Present with empty value ("key=" appears in TXT record)
 *  - Present with non-empty value ("key=value" appears in TXT record)
 * For more details refer to "Data Syntax for DNS-SD TXT Records" in
 * <http://files.dns-sd.org/draft-cheshire-dnsext-dns-sd.txt>
 *
 * txtRecord:       A TXTRecordRef initialized by calling TXTRecordCreate().
 *
 * key:             A null-terminated string which only contains printable ASCII
 *                  values (0x20-0x7E), excluding '=' (0x3D). Keys should be
 *                  14 characters or less (not counting the terminating null).
 *
 * valueSize:       The size of the value.
 *
 * value:           Any binary value. For values that represent
 *                  textual data, UTF-8 is STRONGLY recommended.
 *                  For values that represent textual data, valueSize
 *                  should NOT include the terminating null (if any)
 *                  at the end of the string.
 *                  If NULL, then "key" will be added with no value.
 *                  If non-NULL but valueSize is zero, then "key=" will be
 *                  added with empty value.
 *
 * return value:    Returns kDNSServiceErr_NoError on success.
 *                  Returns kDNSServiceErr_Invalid if the "key" string contains
 *                  illegal characters.
 *                  Returns kDNSServiceErr_NoMemory if adding this key would
 *                  exceed the available storage.
 */

DNSServiceErrorType TXTRecordSetValue
    (
    TXTRecordRef     *txtRecord,
    const char       *key,
    uint8_t          valueSize,        /* may be zero */
    const void       *value            /* may be NULL */
    );


/* TXTRecordRemoveValue()
 *
 * Removes a key from a TXTRecordRef.  The "key" must be an
 * ASCII string which exists in the TXTRecordRef.
 *
 * txtRecord:       A TXTRecordRef initialized by calling TXTRecordCreate().
 *
 * key:             A key name which exists in the TXTRecordRef.
 *
 * return value:    Returns kDNSServiceErr_NoError on success.
 *                  Returns kDNSServiceErr_NoSuchKey if the "key" does not
 *                  exist in the TXTRecordRef.
 *
 */

DNSServiceErrorType TXTRecordRemoveValue
    (
    TXTRecordRef     *txtRecord,
    const char       *key
    );


/* TXTRecordGetLength()
 *
 * Allows you to determine the length of the raw bytes within a TXTRecordRef.
 *
 * txtRecord:       A TXTRecordRef initialized by calling TXTRecordCreate().
 *
 * return value:    Returns the size of the raw bytes inside a TXTRecordRef
 *                  which you can pass directly to DNSServiceRegister() or
 *                  to DNSServiceUpdateRecord().
 *                  Returns 0 if the TXTRecordRef is empty.
 *
 */

uint16_t TXTRecordGetLength
    (
    const TXTRecordRef *txtRecord
    );


/* TXTRecordGetBytesPtr()
 *
 * Allows you to retrieve a pointer to the raw bytes within a TXTRecordRef.
 *
 * txtRecord:       A TXTRecordRef initialized by calling TXTRecordCreate().
 *
 * return value:    Returns a pointer to the raw bytes inside the TXTRecordRef
 *                  which you can pass directly to DNSServiceRegister() or
 *                  to DNSServiceUpdateRecord().
 *
 */

const void * TXTRecordGetBytesPtr
    (
    const TXTRecordRef *txtRecord
    );


/*********************************************************************************************
 *
 *   TXT Record Parsing Functions
 *
 *********************************************************************************************/

/*
 * A typical calling sequence for TXT record parsing is something like:
 *
 * Receive TXT record data in DNSServiceResolve() callback
 * if (TXTRecordContainsKey(txtLen, txtRecord, "key")) then do something
 * val1ptr = TXTRecordGetValuePtr(txtLen, txtRecord, "key1", &len1);
 * val2ptr = TXTRecordGetValuePtr(txtLen, txtRecord, "key2", &len2);
 * ...
 * bcopy(val1ptr, myval1, len1);
 * bcopy(val2ptr, myval2, len2);
 * ...
 * return;
 *
 * If you wish to retain the values after return from the DNSServiceResolve()
 * callback, then you need to copy the data to your own storage using bcopy()
 * or similar, as shown in the example above.
 *
 * If for some reason you need to parse a TXT record you built yourself
 * using the TXT record construction functions above, then you can do
 * that using TXTRecordGetLength and TXTRecordGetBytesPtr calls:
 * TXTRecordGetValue(TXTRecordGetLength(x), TXTRecordGetBytesPtr(x), key, &len);
 *
 * Most applications only fetch keys they know about from a TXT record and
 * ignore the rest.
 * However, some debugging tools wish to fetch and display all keys.
 * To do that, use the TXTRecordGetCount() and TXTRecordGetItemAtIndex() calls.
 */

/* TXTRecordContainsKey()
 *
 * Allows you to determine if a given TXT Record contains a specified key.
 *
 * txtLen:          The size of the received TXT Record.
 *
 * txtRecord:       Pointer to the received TXT Record bytes.
 *
 * key:             A null-terminated ASCII string containing the key name.
 *
 * return value:    Returns 1 if the TXT Record contains the specified key.
 *                  Otherwise, it returns 0.
 *
 */

int TXTRecordContainsKey
    (
    uint16_t         txtLen,
    const void       *txtRecord,
    const char       *key
    );


/* TXTRecordGetValuePtr()
 *
 * Allows you to retrieve the value for a given key from a TXT Record.
 *
 * txtLen:          The size of the received TXT Record
 *
 * txtRecord:       Pointer to the received TXT Record bytes.
 *
 * key:             A null-terminated ASCII string containing the key name.
 *
 * valueLen:        On output, will be set to the size of the "value" data.
 *
 * return value:    Returns NULL if the key does not exist in this TXT record,
 *                  or exists with no value (to differentiate between
 *                  these two cases use TXTRecordContainsKey()).
 *                  Returns pointer to location within TXT Record bytes
 *                  if the key exists with empty or non-empty value.
 *                  For empty value, valueLen will be zero.
 *                  For non-empty value, valueLen will be length of value data.
 */

const void * TXTRecordGetValuePtr
    (
    uint16_t         txtLen,
    const void       *txtRecord,
    const char       *key,
    uint8_t          *valueLen
    );


/* TXTRecordGetCount()
 *
 * Returns the number of keys stored in the TXT Record.  The count
 * can be used with TXTRecordGetItemAtIndex() to iterate through the keys.
 *
 * txtLen:          The size of the received TXT Record.
 *
 * txtRecord:       Pointer to the received TXT Record bytes.
 *
 * return value:    Returns the total number of keys in the TXT Record.
 *
 */

uint16_t TXTRecordGetCount
    (
    uint16_t         txtLen,
    const void       *txtRecord
    );


/* TXTRecordGetItemAtIndex()
 *
 * Allows you to retrieve a key name and value pointer, given an index into
 * a TXT Record.  Legal index values range from zero to TXTRecordGetCount()-1.
 * It's also possible to iterate through keys in a TXT record by simply
 * calling TXTRecordGetItemAtIndex() repeatedly, beginning with index zero
 * and increasing until TXTRecordGetItemAtIndex() returns kDNSServiceErr_Invalid.
 *
 * On return:
 * For keys with no value, *value is set to NULL and *valueLen is zero.
 * For keys with empty value, *value is non-NULL and *valueLen is zero.
 * For keys with non-empty value, *value is non-NULL and *valueLen is non-zero.
 *
 * txtLen:          The size of the received TXT Record.
 *
 * txtRecord:       Pointer to the received TXT Record bytes.
 *
 * index:           An index into the TXT Record.
 *
 * keyBufLen:       The size of the string buffer being supplied.
 *
 * key:             A string buffer used to store the key name.
 *                  On return, the buffer contains a null-terminated C string
 *                  giving the key name. DNS-SD TXT keys are usually
 *                  14 characters or less. To hold the maximum possible
 *                  key name, the buffer should be 256 bytes long.
 *
 * valueLen:        On output, will be set to the size of the "value" data.
 *
 * value:           On output, *value is set to point to location within TXT
 *                  Record bytes that holds the value data.
 *
 * return value:    Returns kDNSServiceErr_NoError on success.
 *                  Returns kDNSServiceErr_NoMemory if keyBufLen is too short.
 *                  Returns kDNSServiceErr_Invalid if index is greater than
 *                  TXTRecordGetCount()-1.
 */

DNSServiceErrorType TXTRecordGetItemAtIndex
    (
    uint16_t         txtLen,
    const void       *txtRecord,
    uint16_t         index,
    uint16_t         keyBufLen,
    char             *key,
    uint8_t          *valueLen,
    const void       **value
    );


#ifdef  __cplusplus
    }
#endif

#endif  /* _DNS_SD_H */
