require "mkmf"
require "digest/sha1"

def ruby_source_dir_error(extra = nil)
	warn "==================== ERROR ====================="
	if extra
		warn extra
		warn ""
	end
	warn "Please set RUBY_SOURCE_DIR to the source path of ruby #{RUBY_VERSION} (#{RUBY_RELEASE_DATE})!"
	warn "================================================"
	exit! 1
end

begin
	# read node.h from installed ruby
	node_h = IO.read(File.join($hdrdir, "node.h"))
	# digest it
	node_h_digest = Digest::SHA1.hexdigest(node_h)

	$rbsrcdir = ENV["RUBY_SOURCE_DIR"] || File.join(File.dirname(__FILE__), "ruby_src/#{node_h_digest}")

	unless File.directory? $rbsrcdir
		ruby_source_dir_error
	end

	# read gc.c and eval.c from $rbsrcdir
	gc_c = IO.read(File.join($rbsrcdir, "gc.c"))
	eval_c = IO.read(File.join($rbsrcdir, "eval.c"))

	if ENV["RUBY_SOURCE_DIR"]
		# if RUBY_SOURCE_DIR was set, check if it is actually "compatible" with $hdrdir
		unless node_h == IO.read(File.join($rbsrcdir, "node.h"))
			ruby_source_dir_error(File.join($hdrdir, "node.h") +
				"\nis different from\n" + File.join($rbsrcdir, "node.h"))
		end
	end

	raise "node.h does not contain 'enum node_type'" unless node_h =~ /enum node_type \{(.*?)\};/m
	typestr = $1
	nd_types = typestr.scan(/NODE_(\w+)/).flatten
	node_attrib_map = {}
	node_h.scan(/^#define\s+(nd_\w+)\s+(u[123]\.(node|id|value|tbl|argc|state|cnt|cfunc))\s*$/) {
		node_attrib_map[$1] = $2
	}
	%w[nd_noex nd_cflag].each { |nd|
		# noex and cflag are id (because u1 doesn't have a long member),
		# but they are used as long
		if node_attrib_map.has_key?(nd)
			node_attrib_map[nd] = node_attrib_map[nd].sub(".id", ".as_long")
		end
	}

	raise "gc.c does not contain an expected line" unless gc_c =~ /^\s*marking:\s*$(.*?)ALLOCA/m
	raise "gc.c does not contain an expected line" unless $1 =~ /switch\s*\(nd_type/
	nd_type_gc_switch_str = $'

	eval_c =~ /struct\s+BLOCK\s*\{.*?\};/m
	struct_block = $& || ""
	eval_c =~ /struct\s+METHOD\s*\{.*?\};/m
	struct_method = $& || ""

	File.open("node_type.h", "w") { |f|
		f << "static VALUE node_type_sym_tbl[#{nd_types.size}];\n"
		f << "static void init_node_type_sym_tbl() {\n"
		nd_types.each_with_index { |t, i|
			f << "node_type_sym_tbl[#{i}] = ID2SYM(rb_intern(\"#{t.downcase}\"));\n"
		}
		f << "}\n"
		f << "static VALUE node_type_to_sym(enum node_type nd_type) {\n"
		f << "switch(nd_type) {\n"
		nd_types.each_with_index { |t, i|
			f << "#ifdef C_ALLOCA\n" if t == "ALLOCA" && RUBY_VERSION < "1.9.0"
			f << "#define HAVE_NODE_#{t}\n"
			f << "case NODE_#{t}:\nreturn node_type_sym_tbl[#{i}];\n"
			f << "#endif\n" if t == "ALLOCA" && RUBY_VERSION < "1.9.0"
		}
		f << "default:\nreturn Qnil;\n"
		f << "}\nreturn Qnil;\n}\n"

		f << "static VALUE node_type_attrib_is_value(enum node_type nd_type, int union_idx) {\n"
		f << "switch(nd_type) {\n"
		nd_type_gc_switch_str.each { |line|
			case line
			when /ALLOCA/
				break
			when /case\s+NODE_(\w+):/
				f << "case NODE_#{$1}:\n"
			when /break;/, /goto again;/
				f << "break;\n"
			when /as\.node\.u(\d)\.node/
				f << "if (union_idx == #$1) return Qtrue;\n"
			end
		}
		f << "default:\nreturn Qfalse;\n"
		f << "}\nreturn Qfalse;\n}\n"
		node_attrib_map.each { |k, v|
			if v =~ /u(\d)\./
				f << "#define #{k.upcase}_UIDX #{$1}\n"
			end
		}
	}

	File.open("node_nd_attribs.h", "w") { |f|
		f << "static void define_nd_attribs() {\n"
		node_attrib_map.each { |k, v|
			fun =
				case v
				when /u(\d)\.(node|value)/
					"rnode_u#{$1}_value_or_node"
				when /u(\d)\.id/
					"rnode_u#{$1}_id"
				when "u1.tbl"
					"rnode_u1_tbl"
				when "u2.argc"
					"rnode_u2_argc"
				when "u3.state", "u3.cnt"
					"rnode_u3_state_or_cnt"
				when "u1.as_long"
					"rnode_u1_as_long"
				when "u2.as_long"
					"rnode_u2_argc"
				when "u1.cfunc"
					"rnode_u1_cfunc"
				else
					raise "unexpected node member: #{v}"
				end
			f << "rb_define_method(cRubyNode, \"#{k}\", #{fun}, 0);\n"
		}
		f << "}\n"
	}

	File.open("eval_c_structs.h", "w") { |f|
		f.puts struct_block
		f.puts struct_method
	}
rescue
	warn "error: #$!"
	exit! 1
end


$distcleanfiles = ["node_type.h", "node_nd_attribs.h", "eval_c_structs.h"]

create_makefile("rubynode_ext")
