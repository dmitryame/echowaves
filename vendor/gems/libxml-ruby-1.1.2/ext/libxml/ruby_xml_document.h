/* $Id: ruby_xml_document.h 758 2009-01-25 20:36:03Z cfis $ */

/* Please see the LICENSE file for copyright and distribution information */

#ifndef __RXML_DOCUMENT__
#define __RXML_DOCUMENT__

extern VALUE cXMLDocument;

void rxml_init_document();


#if defined(_WIN32)
__declspec(dllexport) 
#endif
VALUE rxml_document_wrap(xmlDocPtr xnode);
#endif
