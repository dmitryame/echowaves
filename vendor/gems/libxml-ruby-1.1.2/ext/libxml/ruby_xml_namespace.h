/* $Id: ruby_xml_namespace.h 758 2009-01-25 20:36:03Z cfis $ */

/* Please see the LICENSE file for copyright and distribution information */

#ifndef __RXML_NAMESPACE__
#define __RXML_NAMESPACE__

extern VALUE cXMLNamespace;

void rxml_init_namespace(void);
VALUE rxml_namespace_wrap(xmlNsPtr xns, RUBY_DATA_FUNC freeFunc);
#endif
