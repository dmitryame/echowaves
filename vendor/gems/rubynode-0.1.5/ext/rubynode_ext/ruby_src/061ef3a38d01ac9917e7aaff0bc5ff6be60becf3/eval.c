/**********************************************************************

  eval.c -

  $Author: knu $
  $Date: 2007-03-11 17:31:53 +0900 (Sun, 11 Mar 2007) $
  created at: Thu Jun 10 14:22:17 JST 1993

  Copyright (C) 1993-2003 Yukihiro Matsumoto
  Copyright (C) 2000  Network Applied Communication Laboratory, Inc.
  Copyright (C) 2000  Information-technology Promotion Agency, Japan

**********************************************************************/

/* extract from eval.c from ruby 1.8.6 */

struct BLOCK {
    NODE *var;
    NODE *body;
    VALUE self;
    struct FRAME frame;
    struct SCOPE *scope;
    VALUE klass;
    NODE *cref;
    int iter;
    int vmode;
    int flags;
    int uniq;
    struct RVarmap *dyna_vars;
    VALUE orig_thread;
    VALUE wrapper;
    VALUE block_obj;
    struct BLOCK *outer;
    struct BLOCK *prev;
};

struct METHOD {
    VALUE klass, rklass;
    VALUE recv;
    ID id, oid;
    int safe_level;
    NODE *body;
};

