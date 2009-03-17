/* $Id: ruby_xml_node.h 758 2009-01-25 20:36:03Z cfis $ */

/* Please see the LICENSE file for copyright and distribution information */

#ifndef __RXML_NODE__
#define __RXML_NODE__

extern VALUE cXMLNode;

void rxml_init_node(void);
void rxml_node_mark_common(xmlNodePtr xnode);
VALUE rxml_node_wrap(xmlNodePtr xnode);
VALUE check_string_or_symbol(VALUE val);
#endif
