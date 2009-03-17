static VALUE node_type_sym_tbl[105];
static void init_node_type_sym_tbl() {
node_type_sym_tbl[0] = ID2SYM(rb_intern("method"));
node_type_sym_tbl[1] = ID2SYM(rb_intern("fbody"));
node_type_sym_tbl[2] = ID2SYM(rb_intern("cfunc"));
node_type_sym_tbl[3] = ID2SYM(rb_intern("scope"));
node_type_sym_tbl[4] = ID2SYM(rb_intern("block"));
node_type_sym_tbl[5] = ID2SYM(rb_intern("if"));
node_type_sym_tbl[6] = ID2SYM(rb_intern("case"));
node_type_sym_tbl[7] = ID2SYM(rb_intern("when"));
node_type_sym_tbl[8] = ID2SYM(rb_intern("opt_n"));
node_type_sym_tbl[9] = ID2SYM(rb_intern("while"));
node_type_sym_tbl[10] = ID2SYM(rb_intern("until"));
node_type_sym_tbl[11] = ID2SYM(rb_intern("iter"));
node_type_sym_tbl[12] = ID2SYM(rb_intern("for"));
node_type_sym_tbl[13] = ID2SYM(rb_intern("break"));
node_type_sym_tbl[14] = ID2SYM(rb_intern("next"));
node_type_sym_tbl[15] = ID2SYM(rb_intern("redo"));
node_type_sym_tbl[16] = ID2SYM(rb_intern("retry"));
node_type_sym_tbl[17] = ID2SYM(rb_intern("begin"));
node_type_sym_tbl[18] = ID2SYM(rb_intern("rescue"));
node_type_sym_tbl[19] = ID2SYM(rb_intern("resbody"));
node_type_sym_tbl[20] = ID2SYM(rb_intern("ensure"));
node_type_sym_tbl[21] = ID2SYM(rb_intern("and"));
node_type_sym_tbl[22] = ID2SYM(rb_intern("or"));
node_type_sym_tbl[23] = ID2SYM(rb_intern("not"));
node_type_sym_tbl[24] = ID2SYM(rb_intern("masgn"));
node_type_sym_tbl[25] = ID2SYM(rb_intern("lasgn"));
node_type_sym_tbl[26] = ID2SYM(rb_intern("dasgn"));
node_type_sym_tbl[27] = ID2SYM(rb_intern("dasgn_curr"));
node_type_sym_tbl[28] = ID2SYM(rb_intern("gasgn"));
node_type_sym_tbl[29] = ID2SYM(rb_intern("iasgn"));
node_type_sym_tbl[30] = ID2SYM(rb_intern("cdecl"));
node_type_sym_tbl[31] = ID2SYM(rb_intern("cvasgn"));
node_type_sym_tbl[32] = ID2SYM(rb_intern("cvdecl"));
node_type_sym_tbl[33] = ID2SYM(rb_intern("op_asgn1"));
node_type_sym_tbl[34] = ID2SYM(rb_intern("op_asgn2"));
node_type_sym_tbl[35] = ID2SYM(rb_intern("op_asgn_and"));
node_type_sym_tbl[36] = ID2SYM(rb_intern("op_asgn_or"));
node_type_sym_tbl[37] = ID2SYM(rb_intern("call"));
node_type_sym_tbl[38] = ID2SYM(rb_intern("fcall"));
node_type_sym_tbl[39] = ID2SYM(rb_intern("vcall"));
node_type_sym_tbl[40] = ID2SYM(rb_intern("super"));
node_type_sym_tbl[41] = ID2SYM(rb_intern("zsuper"));
node_type_sym_tbl[42] = ID2SYM(rb_intern("array"));
node_type_sym_tbl[43] = ID2SYM(rb_intern("zarray"));
node_type_sym_tbl[44] = ID2SYM(rb_intern("hash"));
node_type_sym_tbl[45] = ID2SYM(rb_intern("return"));
node_type_sym_tbl[46] = ID2SYM(rb_intern("yield"));
node_type_sym_tbl[47] = ID2SYM(rb_intern("lvar"));
node_type_sym_tbl[48] = ID2SYM(rb_intern("dvar"));
node_type_sym_tbl[49] = ID2SYM(rb_intern("gvar"));
node_type_sym_tbl[50] = ID2SYM(rb_intern("ivar"));
node_type_sym_tbl[51] = ID2SYM(rb_intern("const"));
node_type_sym_tbl[52] = ID2SYM(rb_intern("cvar"));
node_type_sym_tbl[53] = ID2SYM(rb_intern("nth_ref"));
node_type_sym_tbl[54] = ID2SYM(rb_intern("back_ref"));
node_type_sym_tbl[55] = ID2SYM(rb_intern("match"));
node_type_sym_tbl[56] = ID2SYM(rb_intern("match2"));
node_type_sym_tbl[57] = ID2SYM(rb_intern("match3"));
node_type_sym_tbl[58] = ID2SYM(rb_intern("lit"));
node_type_sym_tbl[59] = ID2SYM(rb_intern("str"));
node_type_sym_tbl[60] = ID2SYM(rb_intern("dstr"));
node_type_sym_tbl[61] = ID2SYM(rb_intern("xstr"));
node_type_sym_tbl[62] = ID2SYM(rb_intern("dxstr"));
node_type_sym_tbl[63] = ID2SYM(rb_intern("evstr"));
node_type_sym_tbl[64] = ID2SYM(rb_intern("dregx"));
node_type_sym_tbl[65] = ID2SYM(rb_intern("dregx_once"));
node_type_sym_tbl[66] = ID2SYM(rb_intern("args"));
node_type_sym_tbl[67] = ID2SYM(rb_intern("argscat"));
node_type_sym_tbl[68] = ID2SYM(rb_intern("argspush"));
node_type_sym_tbl[69] = ID2SYM(rb_intern("splat"));
node_type_sym_tbl[70] = ID2SYM(rb_intern("to_ary"));
node_type_sym_tbl[71] = ID2SYM(rb_intern("svalue"));
node_type_sym_tbl[72] = ID2SYM(rb_intern("block_arg"));
node_type_sym_tbl[73] = ID2SYM(rb_intern("block_pass"));
node_type_sym_tbl[74] = ID2SYM(rb_intern("defn"));
node_type_sym_tbl[75] = ID2SYM(rb_intern("defs"));
node_type_sym_tbl[76] = ID2SYM(rb_intern("alias"));
node_type_sym_tbl[77] = ID2SYM(rb_intern("valias"));
node_type_sym_tbl[78] = ID2SYM(rb_intern("undef"));
node_type_sym_tbl[79] = ID2SYM(rb_intern("class"));
node_type_sym_tbl[80] = ID2SYM(rb_intern("module"));
node_type_sym_tbl[81] = ID2SYM(rb_intern("sclass"));
node_type_sym_tbl[82] = ID2SYM(rb_intern("colon2"));
node_type_sym_tbl[83] = ID2SYM(rb_intern("colon3"));
node_type_sym_tbl[84] = ID2SYM(rb_intern("cref"));
node_type_sym_tbl[85] = ID2SYM(rb_intern("dot2"));
node_type_sym_tbl[86] = ID2SYM(rb_intern("dot3"));
node_type_sym_tbl[87] = ID2SYM(rb_intern("flip2"));
node_type_sym_tbl[88] = ID2SYM(rb_intern("flip3"));
node_type_sym_tbl[89] = ID2SYM(rb_intern("attrset"));
node_type_sym_tbl[90] = ID2SYM(rb_intern("self"));
node_type_sym_tbl[91] = ID2SYM(rb_intern("nil"));
node_type_sym_tbl[92] = ID2SYM(rb_intern("true"));
node_type_sym_tbl[93] = ID2SYM(rb_intern("false"));
node_type_sym_tbl[94] = ID2SYM(rb_intern("defined"));
node_type_sym_tbl[95] = ID2SYM(rb_intern("newline"));
node_type_sym_tbl[96] = ID2SYM(rb_intern("postexe"));
node_type_sym_tbl[97] = ID2SYM(rb_intern("alloca"));
node_type_sym_tbl[98] = ID2SYM(rb_intern("dmethod"));
node_type_sym_tbl[99] = ID2SYM(rb_intern("bmethod"));
node_type_sym_tbl[100] = ID2SYM(rb_intern("memo"));
node_type_sym_tbl[101] = ID2SYM(rb_intern("ifunc"));
node_type_sym_tbl[102] = ID2SYM(rb_intern("dsym"));
node_type_sym_tbl[103] = ID2SYM(rb_intern("attrasgn"));
node_type_sym_tbl[104] = ID2SYM(rb_intern("last"));
}
static VALUE node_type_to_sym(enum node_type nd_type) {
switch(nd_type) {
#define HAVE_NODE_METHOD
case NODE_METHOD:
return node_type_sym_tbl[0];
#define HAVE_NODE_FBODY
case NODE_FBODY:
return node_type_sym_tbl[1];
#define HAVE_NODE_CFUNC
case NODE_CFUNC:
return node_type_sym_tbl[2];
#define HAVE_NODE_SCOPE
case NODE_SCOPE:
return node_type_sym_tbl[3];
#define HAVE_NODE_BLOCK
case NODE_BLOCK:
return node_type_sym_tbl[4];
#define HAVE_NODE_IF
case NODE_IF:
return node_type_sym_tbl[5];
#define HAVE_NODE_CASE
case NODE_CASE:
return node_type_sym_tbl[6];
#define HAVE_NODE_WHEN
case NODE_WHEN:
return node_type_sym_tbl[7];
#define HAVE_NODE_OPT_N
case NODE_OPT_N:
return node_type_sym_tbl[8];
#define HAVE_NODE_WHILE
case NODE_WHILE:
return node_type_sym_tbl[9];
#define HAVE_NODE_UNTIL
case NODE_UNTIL:
return node_type_sym_tbl[10];
#define HAVE_NODE_ITER
case NODE_ITER:
return node_type_sym_tbl[11];
#define HAVE_NODE_FOR
case NODE_FOR:
return node_type_sym_tbl[12];
#define HAVE_NODE_BREAK
case NODE_BREAK:
return node_type_sym_tbl[13];
#define HAVE_NODE_NEXT
case NODE_NEXT:
return node_type_sym_tbl[14];
#define HAVE_NODE_REDO
case NODE_REDO:
return node_type_sym_tbl[15];
#define HAVE_NODE_RETRY
case NODE_RETRY:
return node_type_sym_tbl[16];
#define HAVE_NODE_BEGIN
case NODE_BEGIN:
return node_type_sym_tbl[17];
#define HAVE_NODE_RESCUE
case NODE_RESCUE:
return node_type_sym_tbl[18];
#define HAVE_NODE_RESBODY
case NODE_RESBODY:
return node_type_sym_tbl[19];
#define HAVE_NODE_ENSURE
case NODE_ENSURE:
return node_type_sym_tbl[20];
#define HAVE_NODE_AND
case NODE_AND:
return node_type_sym_tbl[21];
#define HAVE_NODE_OR
case NODE_OR:
return node_type_sym_tbl[22];
#define HAVE_NODE_NOT
case NODE_NOT:
return node_type_sym_tbl[23];
#define HAVE_NODE_MASGN
case NODE_MASGN:
return node_type_sym_tbl[24];
#define HAVE_NODE_LASGN
case NODE_LASGN:
return node_type_sym_tbl[25];
#define HAVE_NODE_DASGN
case NODE_DASGN:
return node_type_sym_tbl[26];
#define HAVE_NODE_DASGN_CURR
case NODE_DASGN_CURR:
return node_type_sym_tbl[27];
#define HAVE_NODE_GASGN
case NODE_GASGN:
return node_type_sym_tbl[28];
#define HAVE_NODE_IASGN
case NODE_IASGN:
return node_type_sym_tbl[29];
#define HAVE_NODE_CDECL
case NODE_CDECL:
return node_type_sym_tbl[30];
#define HAVE_NODE_CVASGN
case NODE_CVASGN:
return node_type_sym_tbl[31];
#define HAVE_NODE_CVDECL
case NODE_CVDECL:
return node_type_sym_tbl[32];
#define HAVE_NODE_OP_ASGN1
case NODE_OP_ASGN1:
return node_type_sym_tbl[33];
#define HAVE_NODE_OP_ASGN2
case NODE_OP_ASGN2:
return node_type_sym_tbl[34];
#define HAVE_NODE_OP_ASGN_AND
case NODE_OP_ASGN_AND:
return node_type_sym_tbl[35];
#define HAVE_NODE_OP_ASGN_OR
case NODE_OP_ASGN_OR:
return node_type_sym_tbl[36];
#define HAVE_NODE_CALL
case NODE_CALL:
return node_type_sym_tbl[37];
#define HAVE_NODE_FCALL
case NODE_FCALL:
return node_type_sym_tbl[38];
#define HAVE_NODE_VCALL
case NODE_VCALL:
return node_type_sym_tbl[39];
#define HAVE_NODE_SUPER
case NODE_SUPER:
return node_type_sym_tbl[40];
#define HAVE_NODE_ZSUPER
case NODE_ZSUPER:
return node_type_sym_tbl[41];
#define HAVE_NODE_ARRAY
case NODE_ARRAY:
return node_type_sym_tbl[42];
#define HAVE_NODE_ZARRAY
case NODE_ZARRAY:
return node_type_sym_tbl[43];
#define HAVE_NODE_HASH
case NODE_HASH:
return node_type_sym_tbl[44];
#define HAVE_NODE_RETURN
case NODE_RETURN:
return node_type_sym_tbl[45];
#define HAVE_NODE_YIELD
case NODE_YIELD:
return node_type_sym_tbl[46];
#define HAVE_NODE_LVAR
case NODE_LVAR:
return node_type_sym_tbl[47];
#define HAVE_NODE_DVAR
case NODE_DVAR:
return node_type_sym_tbl[48];
#define HAVE_NODE_GVAR
case NODE_GVAR:
return node_type_sym_tbl[49];
#define HAVE_NODE_IVAR
case NODE_IVAR:
return node_type_sym_tbl[50];
#define HAVE_NODE_CONST
case NODE_CONST:
return node_type_sym_tbl[51];
#define HAVE_NODE_CVAR
case NODE_CVAR:
return node_type_sym_tbl[52];
#define HAVE_NODE_NTH_REF
case NODE_NTH_REF:
return node_type_sym_tbl[53];
#define HAVE_NODE_BACK_REF
case NODE_BACK_REF:
return node_type_sym_tbl[54];
#define HAVE_NODE_MATCH
case NODE_MATCH:
return node_type_sym_tbl[55];
#define HAVE_NODE_MATCH2
case NODE_MATCH2:
return node_type_sym_tbl[56];
#define HAVE_NODE_MATCH3
case NODE_MATCH3:
return node_type_sym_tbl[57];
#define HAVE_NODE_LIT
case NODE_LIT:
return node_type_sym_tbl[58];
#define HAVE_NODE_STR
case NODE_STR:
return node_type_sym_tbl[59];
#define HAVE_NODE_DSTR
case NODE_DSTR:
return node_type_sym_tbl[60];
#define HAVE_NODE_XSTR
case NODE_XSTR:
return node_type_sym_tbl[61];
#define HAVE_NODE_DXSTR
case NODE_DXSTR:
return node_type_sym_tbl[62];
#define HAVE_NODE_EVSTR
case NODE_EVSTR:
return node_type_sym_tbl[63];
#define HAVE_NODE_DREGX
case NODE_DREGX:
return node_type_sym_tbl[64];
#define HAVE_NODE_DREGX_ONCE
case NODE_DREGX_ONCE:
return node_type_sym_tbl[65];
#define HAVE_NODE_ARGS
case NODE_ARGS:
return node_type_sym_tbl[66];
#define HAVE_NODE_ARGSCAT
case NODE_ARGSCAT:
return node_type_sym_tbl[67];
#define HAVE_NODE_ARGSPUSH
case NODE_ARGSPUSH:
return node_type_sym_tbl[68];
#define HAVE_NODE_SPLAT
case NODE_SPLAT:
return node_type_sym_tbl[69];
#define HAVE_NODE_TO_ARY
case NODE_TO_ARY:
return node_type_sym_tbl[70];
#define HAVE_NODE_SVALUE
case NODE_SVALUE:
return node_type_sym_tbl[71];
#define HAVE_NODE_BLOCK_ARG
case NODE_BLOCK_ARG:
return node_type_sym_tbl[72];
#define HAVE_NODE_BLOCK_PASS
case NODE_BLOCK_PASS:
return node_type_sym_tbl[73];
#define HAVE_NODE_DEFN
case NODE_DEFN:
return node_type_sym_tbl[74];
#define HAVE_NODE_DEFS
case NODE_DEFS:
return node_type_sym_tbl[75];
#define HAVE_NODE_ALIAS
case NODE_ALIAS:
return node_type_sym_tbl[76];
#define HAVE_NODE_VALIAS
case NODE_VALIAS:
return node_type_sym_tbl[77];
#define HAVE_NODE_UNDEF
case NODE_UNDEF:
return node_type_sym_tbl[78];
#define HAVE_NODE_CLASS
case NODE_CLASS:
return node_type_sym_tbl[79];
#define HAVE_NODE_MODULE
case NODE_MODULE:
return node_type_sym_tbl[80];
#define HAVE_NODE_SCLASS
case NODE_SCLASS:
return node_type_sym_tbl[81];
#define HAVE_NODE_COLON2
case NODE_COLON2:
return node_type_sym_tbl[82];
#define HAVE_NODE_COLON3
case NODE_COLON3:
return node_type_sym_tbl[83];
#define HAVE_NODE_CREF
case NODE_CREF:
return node_type_sym_tbl[84];
#define HAVE_NODE_DOT2
case NODE_DOT2:
return node_type_sym_tbl[85];
#define HAVE_NODE_DOT3
case NODE_DOT3:
return node_type_sym_tbl[86];
#define HAVE_NODE_FLIP2
case NODE_FLIP2:
return node_type_sym_tbl[87];
#define HAVE_NODE_FLIP3
case NODE_FLIP3:
return node_type_sym_tbl[88];
#define HAVE_NODE_ATTRSET
case NODE_ATTRSET:
return node_type_sym_tbl[89];
#define HAVE_NODE_SELF
case NODE_SELF:
return node_type_sym_tbl[90];
#define HAVE_NODE_NIL
case NODE_NIL:
return node_type_sym_tbl[91];
#define HAVE_NODE_TRUE
case NODE_TRUE:
return node_type_sym_tbl[92];
#define HAVE_NODE_FALSE
case NODE_FALSE:
return node_type_sym_tbl[93];
#define HAVE_NODE_DEFINED
case NODE_DEFINED:
return node_type_sym_tbl[94];
#define HAVE_NODE_NEWLINE
case NODE_NEWLINE:
return node_type_sym_tbl[95];
#define HAVE_NODE_POSTEXE
case NODE_POSTEXE:
return node_type_sym_tbl[96];
#ifdef C_ALLOCA
#define HAVE_NODE_ALLOCA
case NODE_ALLOCA:
return node_type_sym_tbl[97];
#endif
#define HAVE_NODE_DMETHOD
case NODE_DMETHOD:
return node_type_sym_tbl[98];
#define HAVE_NODE_BMETHOD
case NODE_BMETHOD:
return node_type_sym_tbl[99];
#define HAVE_NODE_MEMO
case NODE_MEMO:
return node_type_sym_tbl[100];
#define HAVE_NODE_IFUNC
case NODE_IFUNC:
return node_type_sym_tbl[101];
#define HAVE_NODE_DSYM
case NODE_DSYM:
return node_type_sym_tbl[102];
#define HAVE_NODE_ATTRASGN
case NODE_ATTRASGN:
return node_type_sym_tbl[103];
#define HAVE_NODE_LAST
case NODE_LAST:
return node_type_sym_tbl[104];
default:
return Qnil;
}
return Qnil;
}
static VALUE node_type_attrib_is_value(enum node_type nd_type, int union_idx) {
switch(nd_type) {
case NODE_IF:
case NODE_FOR:
case NODE_ITER:
case NODE_CREF:
case NODE_WHEN:
case NODE_MASGN:
case NODE_RESCUE:
case NODE_RESBODY:
case NODE_CLASS:
if (union_idx == 2) return Qtrue;
case NODE_BLOCK:
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
if (union_idx == 1) return Qtrue;
case NODE_SUPER:
case NODE_FCALL:
case NODE_DEFN:
case NODE_NEWLINE:
if (union_idx == 3) return Qtrue;
break;
case NODE_WHILE:
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
if (union_idx == 1) return Qtrue;
case NODE_METHOD:
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
if (union_idx == 2) return Qtrue;
break;
case NODE_HASH:
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
if (union_idx == 1) return Qtrue;
break;
case NODE_SCOPE:
case NODE_BLOCK_PASS:
case NODE_CDECL:
if (union_idx == 3) return Qtrue;
if (union_idx == 2) return Qtrue;
break;
case NODE_ZARRAY:
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
default:
return Qfalse;
}
return Qfalse;
}
#define ND_TVAL_UIDX 2
#define ND_END_UIDX 2
#define ND_SUPER_UIDX 3
#define ND_REST_UIDX 2
#define ND_COND_UIDX 1
#define ND_ALEN_UIDX 2
#define ND_STATE_UIDX 3
#define ND_MODL_UIDX 1
#define ND_CFNC_UIDX 1
#define ND_AID_UIDX 3
#define ND_ITER_UIDX 3
#define ND_IBDY_UIDX 2
#define ND_VAR_UIDX 1
#define ND_VID_UIDX 1
#define ND_CPATH_UIDX 1
#define ND_MID_UIDX 2
#define ND_FRML_UIDX 1
#define ND_ELSE_UIDX 3
#define ND_HEAD_UIDX 1
#define ND_OPT_UIDX 1
#define ND_TBL_UIDX 1
#define ND_ARGC_UIDX 2
#define ND_CNT_UIDX 3
#define ND_BODY_UIDX 2
#define ND_RVAL_UIDX 2
#define ND_ENSR_UIDX 3
#define ND_NEXT_UIDX 3
#define ND_NTH_UIDX 2
#define ND_CLSS_UIDX 1
#define ND_DEFN_UIDX 3
#define ND_NOEX_UIDX 1
#define ND_LIT_UIDX 1
#define ND_CVAL_UIDX 3
#define ND_RECV_UIDX 1
#define ND_VALUE_UIDX 2
#define ND_RESQ_UIDX 2
#define ND_BEG_UIDX 1
#define ND_STTS_UIDX 1
#define ND_2ND_UIDX 2
#define ND_1ST_UIDX 1
#define ND_TAG_UIDX 1
#define ND_ARGS_UIDX 3
#define ND_CFLAG_UIDX 2
#define ND_ORIG_UIDX 3
