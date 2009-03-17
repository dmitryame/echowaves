
#include <ruby.h>
#include <node.h>
#include <rubysig.h>
#include <env.h>
#include <version.h>

#include "node_type.h"

static VALUE cRubyNode;

static void rnode_mark(NODE * node) {
	rb_gc_mark((VALUE)node);
}

static VALUE node_to_rnode(NODE * node) {
	if (node) return Data_Wrap_Struct(cRubyNode, rnode_mark, 0, node);
	else return Qnil;
}

static VALUE rnode_type(VALUE self) {
	NODE * node;
	Data_Get_Struct(self, NODE, node);
	return node_type_to_sym(nd_type(node));
}

static VALUE rnode_flags(VALUE self) {
	NODE * node;
	Data_Get_Struct(self, NODE, node);
	return ULONG2NUM(node->flags);
}

static VALUE rnode_file(VALUE self) {
	NODE * node;
	Data_Get_Struct(self, NODE, node);
	if (node->nd_file) return rb_str_new2(node->nd_file);
	else return Qnil;
}

static VALUE rnode_line(VALUE self) {
	NODE * node;
	Data_Get_Struct(self, NODE, node);
	return UINT2NUM(nd_line(node));
}

static VALUE id_to_value(ID id) {
	/* some node types store non-ids in an id */
	if (id == 0 || id == 1) return INT2FIX(id);
	else if (rb_id2name(id)) return ID2SYM(id);
	else return Qnil;
}

static VALUE value_or_node_to_value(VALUE val, enum node_type nd_type, int union_idx, NODE * node) {
	if (!node_type_attrib_is_value(nd_type, union_idx)) {
		/* handle node types that are not handled by
		 * node_type_attrib_is_value (which is generated
		 * from gc_mark_children in gc.c)
		 *
		 * NODE_ALLOCA is not supported
		 */
		switch(nd_type) {
			case NODE_ARGSCAT:
			case NODE_ARGSPUSH:
				/* nd_head, nd_body */
				if (union_idx == ND_HEAD_UIDX || union_idx == ND_BODY_UIDX) break;
				else return Qnil;
			case NODE_ATTRASGN:
				/* nd_recv, nd_args */
				if (union_idx == ND_RECV_UIDX || union_idx == ND_ARGS_UIDX) break;
				else return Qnil;
			case NODE_BEGIN:
				/* nd_body */
				if (union_idx == ND_BODY_UIDX) break;
				else return Qnil;
			case NODE_BMETHOD:
#ifdef HAVE_NODE_DMETHOD
			case NODE_DMETHOD:
#endif
				/* nd_cval */
				if (union_idx == ND_CVAL_UIDX) break;
				else return Qnil;
			case NODE_DSYM:
				/* nd_lit, nd_next */
				if (union_idx == ND_LIT_UIDX || union_idx == ND_NEXT_UIDX) break;
				else return Qnil;
			case NODE_IFUNC:
				/* nd_tval */
				if (union_idx == ND_TVAL_UIDX) break;
				else return Qnil;
#ifdef HAVE_NODE_LAMBDA
			case NODE_LAMBDA:
				/* nd_var, nd_body */
				if (union_idx == ND_VAR_UIDX || union_idx == ND_BODY_UIDX) break;
				else return Qnil;
#endif
			case NODE_MEMO:
				/* enum.c: u1.value, u2.value
				 * variabe.c: u1.value (nd_lit), u2.argc (nd_nth)
				 * eval.c: u1.value
				 */
				if (union_idx == 1) break;
				else return Qnil;
			case NODE_OP_ASGN2:
				/* either 3 ids: nd_vid, nd_mid, nd_aid (actually nd_mid might be 0 or 1 instead of an id)
				 * or 3 values: nd_recv, nd_value, nd_next
				 */
				if (rb_id2name(node->nd_vid) && id_to_value(node->nd_mid) != Qnil && rb_id2name(node->nd_aid))
					return Qnil;
				else break;
#ifdef HAVE_NODE_PRELUDE
			case NODE_PRELUDE:
				/* nd_head, nd_body */
				if (union_idx == ND_HEAD_UIDX || union_idx == ND_BODY_UIDX) break;
				else return Qnil;
#endif
#ifdef HAVE_NODE_VALUES
			case NODE_VALUES:
				/* nd_head, nd_next */
				if (union_idx == ND_HEAD_UIDX || union_idx == ND_NEXT_UIDX) break;
				else return Qnil;
#endif
			case NODE_CONST:
				/* fall through */
			case NODE_LAST:
				/* fall through */
			default:
				return Qnil;
		}
	}
	if (TYPE(val) == T_NODE) return node_to_rnode((NODE *)val);
	else return val;
}

static VALUE rnode_u1_value_or_node(VALUE self) {
	NODE * node;
	Data_Get_Struct(self, NODE, node);
	return value_or_node_to_value(node->u1.value, nd_type(node), 1, node);
}
static VALUE rnode_u2_value_or_node(VALUE self) {
	NODE * node;
	Data_Get_Struct(self, NODE, node);
	return value_or_node_to_value(node->u2.value, nd_type(node), 2, node);
}
static VALUE rnode_u3_value_or_node(VALUE self) {
	NODE * node;
	Data_Get_Struct(self, NODE, node);
	return value_or_node_to_value(node->u3.value, nd_type(node), 3, node);
}

static VALUE rnode_u1_id(VALUE self) {
	NODE * node;
	Data_Get_Struct(self, NODE, node);
	return id_to_value(node->u1.id);
}
static VALUE rnode_u2_id(VALUE self) {
	NODE * node;
	Data_Get_Struct(self, NODE, node);
	return id_to_value(node->u2.id);
}
static VALUE rnode_u3_id(VALUE self) {
	NODE * node;
	Data_Get_Struct(self, NODE, node);
	return id_to_value(node->u3.id);
}

static VALUE rnode_u1_as_long(VALUE self) {
	NODE * node;
	Data_Get_Struct(self, NODE, node);
	return LONG2NUM((long)(node->u1.id));
}
static VALUE rnode_u1_cfunc(VALUE self) {
	NODE * node;
	Data_Get_Struct(self, NODE, node);
	return ULONG2NUM((unsigned long)(node->u1.cfunc));
}
static VALUE rnode_u2_argc(VALUE self) {
	NODE * node;
	Data_Get_Struct(self, NODE, node);
	return LONG2NUM(node->u2.argc);
}
static VALUE rnode_u3_state_or_cnt(VALUE self) {
	NODE * node;
	Data_Get_Struct(self, NODE, node);
	return LONG2NUM(node->u3.state);
}

static VALUE rnode_u1_tbl(VALUE self) {
	NODE * node;
	Data_Get_Struct(self, NODE, node);
	/* only allowed for SCOPE */
	if (nd_type(node) == NODE_SCOPE) {
		ID * tbl = node->u1.tbl;
		if (tbl) {
			size_t i;
			VALUE arr = rb_ary_new();
			/* tbl contains the names of local variables.  The first
			 * element is the size of the table.  The next two elements
			 * are $_ and $~.  The rest of the elements are the names of
			 * the variables themselves.
			 */
			for (i = 3; i <= tbl[0]; ++i) {
				if (tbl[i] == 0 || !rb_is_local_id(tbl[i]))
					/* flip state */
					rb_ary_push(arr, Qnil);
				else
					rb_ary_push(arr, ID2SYM(tbl[i]));
			}
			return arr;
		}
	}
	return Qnil;
}

#include "node_nd_attribs.h"

/****************************************************************
 * methods to extract nodes
 ****************************************************************/

#include "eval_c_structs.h"

static VALUE method_body(VALUE method) {
	struct METHOD * m;
	if(ruby_safe_level >= 4) {
		rb_raise(rb_eSecurityError, "Insecure: can't get method body");
	}
	Data_Get_Struct(method, struct METHOD, m);
	return node_to_rnode(m->body);
}

static VALUE proc_body(VALUE proc) {
	struct BLOCK * b;
	if(ruby_safe_level >= 4) {
		rb_raise(rb_eSecurityError, "Insecure: can't get proc body");
	}
	Data_Get_Struct(proc, struct BLOCK, b);
	return node_to_rnode(b->body);
}

static VALUE proc_var(VALUE proc) {
	struct BLOCK * b;
	if(ruby_safe_level >= 4) {
		rb_raise(rb_eSecurityError, "Insecure: can't get proc var");
	}
	Data_Get_Struct(proc, struct BLOCK, b);
	return node_to_rnode(b->var);
}

static VALUE proc_cref(VALUE proc) {
	struct BLOCK * b;
	if(ruby_safe_level >= 4) {
		rb_raise(rb_eSecurityError, "Insecure: can't get proc cref");
	}
	Data_Get_Struct(proc, struct BLOCK, b);
	return node_to_rnode(b->cref);
}


#if RUBY_VERSION_CODE < 190
extern NODE * ruby_eval_tree_begin;
#endif

/*
 * Parse a string to nodes (the parsing is done in the current context).
 *
 * Takes file_name and line as optional arguments. They default to "(string)"
 * and 1
 */

static NODE * str_parse(int argc, VALUE *argv, VALUE src) {
	NODE * node;
	int critical;
	VALUE file_name, line;

	rb_scan_args(argc, argv, "02", &file_name, &line);
	if (argc < 1) file_name = rb_str_new2("(string)");
	if (argc < 2) line = LONG2FIX(1);

	ruby_nerrs = 0;
	StringValue(src);
	critical = rb_thread_critical;
	rb_thread_critical = Qtrue;
	ruby_in_eval++;
	node = rb_compile_string(StringValuePtr(file_name), src, NUM2INT(line));
	ruby_in_eval--;
	rb_thread_critical = critical;

	if (ruby_nerrs > 0) {
		ruby_nerrs = 0;
#if RUBY_VERSION_CODE < 190
		ruby_eval_tree_begin = 0;
#endif
		rb_exc_raise(ruby_errinfo);
	}

	return node;
}

#if RUBY_VERSION_CODE < 190
static VALUE str_parse_begin_to_nodes(int argc, VALUE *argv, VALUE src) {

	str_parse(argc, argv, src);

	if (ruby_eval_tree_begin) {
		VALUE res = node_to_rnode(ruby_eval_tree_begin);
		ruby_eval_tree_begin = 0;
		return res;
	}
	else return Qnil;
}
#endif

static VALUE str_parse_to_nodes(int argc, VALUE *argv, VALUE src) {
	VALUE result;

	result = node_to_rnode(str_parse(argc, argv, src));

#if RUBY_VERSION_CODE < 190
	ruby_eval_tree_begin = 0;
#endif

	return result;
}


void Init_rubynode_ext() {
	init_node_type_sym_tbl();

	cRubyNode = rb_define_class("RubyNode", rb_cObject);

	rb_undef_alloc_func(cRubyNode);
	rb_undef_method(CLASS_OF(cRubyNode), "new");

	rb_define_method(cRubyNode, "type", rnode_type, 0);
	rb_define_method(cRubyNode, "flags", rnode_flags, 0);
	rb_define_method(cRubyNode, "file", rnode_file, 0);
	rb_define_method(cRubyNode, "line", rnode_line, 0);

	rb_define_method(cRubyNode, "u1_value", rnode_u1_value_or_node, 0);
	rb_define_method(cRubyNode, "u2_value", rnode_u2_value_or_node, 0);
	rb_define_method(cRubyNode, "u3_value", rnode_u3_value_or_node, 0);
	rb_define_method(cRubyNode, "u1_node", rnode_u1_value_or_node, 0);
	rb_define_method(cRubyNode, "u2_node", rnode_u2_value_or_node, 0);
	rb_define_method(cRubyNode, "u3_node", rnode_u3_value_or_node, 0);
	rb_define_method(cRubyNode, "u1_id", rnode_u1_id, 0);
	rb_define_method(cRubyNode, "u2_id", rnode_u2_id, 0);
	rb_define_method(cRubyNode, "u3_id", rnode_u3_id, 0);
	rb_define_method(cRubyNode, "u1_as_long", rnode_u1_as_long, 0);
	rb_define_method(cRubyNode, "u1_cfunc", rnode_u1_cfunc, 0);
	rb_define_method(cRubyNode, "u2_argc", rnode_u2_argc, 0);
	rb_define_method(cRubyNode, "u3_state", rnode_u3_state_or_cnt, 0);
	rb_define_method(cRubyNode, "u3_cnt", rnode_u3_state_or_cnt, 0);
	rb_define_method(cRubyNode, "u1_tbl", rnode_u1_tbl, 0);

	define_nd_attribs(); /* in node_nd_attribs.h */

	rb_define_method(rb_define_class("Method", rb_cObject), "body_node", method_body, 0);
	rb_define_method(rb_define_class("UnboundMethod", rb_cObject), "body_node", method_body, 0);

	rb_define_method(rb_cProc, "body_node", proc_body, 0);
	rb_define_method(rb_cProc, "var_node", proc_var, 0);
	rb_define_method(rb_cProc, "cref_node", proc_cref, 0);

	rb_define_method(rb_cString, "parse_to_nodes", str_parse_to_nodes, -1);
#if RUBY_VERSION_CODE < 190
	rb_define_method(rb_cString, "parse_begin_to_nodes", str_parse_begin_to_nodes, -1);
#endif
}
