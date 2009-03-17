/**********************************************************************

  gc.c -

  $Author: matz $
  $Date: 2006/08/25 08:12:46 $
  created at: Tue Oct  5 09:44:46 JST 1993

  Copyright (C) 1993-2003 Yukihiro Matsumoto
  Copyright (C) 2000  Network Applied Communication Laboratory, Inc.
  Copyright (C) 2000  Information-technology Promotion Agency, Japan

**********************************************************************/

/* extract from gc.c from ruby 1.8.5 */

static void
gc_mark_children(ptr, lev)
    VALUE ptr;
    int lev;
{
    register RVALUE *obj = RANY(ptr);

    goto marking;		/* skip */

  again:
    obj = RANY(ptr);
    if (rb_special_const_p(ptr)) return; /* special const not marked */
    if (obj->as.basic.flags == 0) return;       /* free cell */
    if (obj->as.basic.flags & FL_MARK) return;  /* already marked */
    obj->as.basic.flags |= FL_MARK;

  marking:
    if (FL_TEST(obj, FL_EXIVAR)) {
	rb_mark_generic_ivar(ptr);
    }

    switch (obj->as.basic.flags & T_MASK) {
      case T_NIL:
      case T_FIXNUM:
	rb_bug("rb_gc_mark() called for broken object");
	break;

      case T_NODE:
	mark_source_filename(obj->as.node.nd_file);
	switch (nd_type(obj)) {
	  case NODE_IF:		/* 1,2,3 */
	  case NODE_FOR:
	  case NODE_ITER:
	  case NODE_CREF:
	  case NODE_WHEN:
	  case NODE_MASGN:
	  case NODE_RESCUE:
	  case NODE_RESBODY:
	  case NODE_CLASS:
	    gc_mark((VALUE)obj->as.node.u2.node, lev);
	    /* fall through */
	  case NODE_BLOCK:	/* 1,3 */
	  case NODE_ARRAY:
	  case NODE_DSTR:
	  case NODE_DXSTR:
	  case NODE_DREGX:
	  case NODE_DREGX_ONCE:
	  case NODE_FBODY:
	  case NODE_ENSURE:
	  case NODE_CALL:
	  case NODE_DEFS:
	  case NODE_OP_ASGN1:
	    gc_mark((VALUE)obj->as.node.u1.node, lev);
	    /* fall through */
	  case NODE_SUPER:	/* 3 */
	  case NODE_FCALL:
	  case NODE_DEFN:
	  case NODE_NEWLINE:
	    ptr = (VALUE)obj->as.node.u3.node;
	    goto again;

	  case NODE_WHILE:	/* 1,2 */
	  case NODE_UNTIL:
	  case NODE_AND:
	  case NODE_OR:
	  case NODE_CASE:
	  case NODE_SCLASS:
	  case NODE_DOT2:
	  case NODE_DOT3:
	  case NODE_FLIP2:
	  case NODE_FLIP3:
	  case NODE_MATCH2:
	  case NODE_MATCH3:
	  case NODE_OP_ASGN_OR:
	  case NODE_OP_ASGN_AND:
	  case NODE_MODULE:
	  case NODE_ALIAS:
	  case NODE_VALIAS:
	  case NODE_ARGS:
	    gc_mark((VALUE)obj->as.node.u1.node, lev);
	    /* fall through */
	  case NODE_METHOD:	/* 2 */
	  case NODE_NOT:
	  case NODE_GASGN:
	  case NODE_LASGN:
	  case NODE_DASGN:
	  case NODE_DASGN_CURR:
	  case NODE_IASGN:
	  case NODE_CVDECL:
	  case NODE_CVASGN:
	  case NODE_COLON3:
	  case NODE_OPT_N:
	  case NODE_EVSTR:
	  case NODE_UNDEF:
	    ptr = (VALUE)obj->as.node.u2.node;
	    goto again;

	  case NODE_HASH:	/* 1 */
	  case NODE_LIT:
	  case NODE_STR:
	  case NODE_XSTR:
	  case NODE_DEFINED:
	  case NODE_MATCH:
	  case NODE_RETURN:
	  case NODE_BREAK:
	  case NODE_NEXT:
	  case NODE_YIELD:
	  case NODE_COLON2:
	  case NODE_SPLAT:
	  case NODE_TO_ARY:
	  case NODE_SVALUE:
	    ptr = (VALUE)obj->as.node.u1.node;
	    goto again;

	  case NODE_SCOPE:	/* 2,3 */
	  case NODE_BLOCK_PASS:
	  case NODE_CDECL:
	    gc_mark((VALUE)obj->as.node.u3.node, lev);
	    ptr = (VALUE)obj->as.node.u2.node;
	    goto again;

	  case NODE_ZARRAY:	/* - */
	  case NODE_ZSUPER:
	  case NODE_CFUNC:
	  case NODE_VCALL:
	  case NODE_GVAR:
	  case NODE_LVAR:
	  case NODE_DVAR:
	  case NODE_IVAR:
	  case NODE_CVAR:
	  case NODE_NTH_REF:
	  case NODE_BACK_REF:
	  case NODE_REDO:
	  case NODE_RETRY:
	  case NODE_SELF:
	  case NODE_NIL:
	  case NODE_TRUE:
	  case NODE_FALSE:
	  case NODE_ATTRSET:
	  case NODE_BLOCK_ARG:
	  case NODE_POSTEXE:
	    break;
	  case NODE_ALLOCA:
	    mark_locations_array((VALUE*)obj->as.node.u1.value,
				 obj->as.node.u3.cnt);
	    ptr = (VALUE)obj->as.node.u2.node;
	    goto again;

	  default:		/* unlisted NODE */
	    if (is_pointer_to_heap(obj->as.node.u1.node)) {
		gc_mark((VALUE)obj->as.node.u1.node, lev);
	    }
	    if (is_pointer_to_heap(obj->as.node.u2.node)) {
		gc_mark((VALUE)obj->as.node.u2.node, lev);
	    }
	    if (is_pointer_to_heap(obj->as.node.u3.node)) {
		gc_mark((VALUE)obj->as.node.u3.node, lev);
	    }
	}
	return;			/* no need to mark class. */
    }

    gc_mark(obj->as.basic.klass, lev);
    switch (obj->as.basic.flags & T_MASK) {
      case T_ICLASS:
      case T_CLASS:
      case T_MODULE:
	mark_tbl(obj->as.klass.m_tbl, lev);
	mark_tbl(obj->as.klass.iv_tbl, lev);
	ptr = obj->as.klass.super;
	goto again;

      case T_ARRAY:
	if (FL_TEST(obj, ELTS_SHARED)) {
	    ptr = obj->as.array.aux.shared;
	    goto again;
	}
	else {
	    long i, len = obj->as.array.len;
	    VALUE *ptr = obj->as.array.ptr;

	    for (i=0; i < len; i++) {
		gc_mark(*ptr++, lev);
	    }
	}
	break;

      case T_HASH:
	mark_hash(obj->as.hash.tbl, lev);
	ptr = obj->as.hash.ifnone;
	goto again;

      case T_STRING:
#define STR_ASSOC FL_USER3   /* copied from string.c */
	if (FL_TEST(obj, ELTS_SHARED|STR_ASSOC)) {
	    ptr = obj->as.string.aux.shared;
	    goto again;
	}
	break;

      case T_DATA:
	if (obj->as.data.dmark) (*obj->as.data.dmark)(DATA_PTR(obj));
	break;

      case T_OBJECT:
	mark_tbl(obj->as.object.iv_tbl, lev);
	break;

      case T_FILE:
      case T_REGEXP:
      case T_FLOAT:
      case T_BIGNUM:
      case T_BLKTAG:
	break;

      case T_MATCH:
	if (obj->as.match.str) {
	    ptr = obj->as.match.str;
	    goto again;
	}
	break;

      case T_VARMAP:
	gc_mark(obj->as.varmap.val, lev);
	ptr = (VALUE)obj->as.varmap.next;
	goto again;

      case T_SCOPE:
	if (obj->as.scope.local_vars && (obj->as.scope.flags & SCOPE_MALLOC)) {
	    int n = obj->as.scope.local_tbl[0]+1;
	    VALUE *vars = &obj->as.scope.local_vars[-1];

	    while (n--) {
		gc_mark(*vars++, lev);
	    }
	}
	break;

      case T_STRUCT:
	{
	    long len = obj->as.rstruct.len;
	    VALUE *ptr = obj->as.rstruct.ptr;

	    while (len--) {
		gc_mark(*ptr++, lev);
	    }
	}
	break;

      default:
	rb_bug("rb_gc_mark(): unknown data type 0x%lx(0x%lx) %s",
	       obj->as.basic.flags & T_MASK, obj,
	       is_pointer_to_heap(obj) ? "corrupted object" : "non object");
    }
}

