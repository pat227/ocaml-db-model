PROJECT=ocaml_db_model
libdir=src/lib/
maindir=src/main/
builddir=build/
#LIBINSTALL_FILES=$(wildcard *.ml *.mli *.cmi *.cmx *.cma *.cmo *.cmx *.cmxa *.a *.so *.o)
all: ocaml_mysql_model
clean:
	rm -rvf build;rm src/tables/*

lib: $(libdir)uint64_w_sexp.ml $(libdir)uint64_w_sexp.mli $(libdir)uint32_w_sexp.ml $(libdir)uint32_w_sexp.mli $(libdir)uint16_w_sexp.ml $(libdir)uint16_w_sexp.mli $(libdir)uint8_w_sexp.ml $(libdir)uint8_w_sexp.mli $(libdir)utilities.ml $(libdir)utilities.mli $(libdir)sql_supported_types.ml $(libdir)sql_supported_types.mli $(libdir)model.ml $(libdir)model.mli $(libdir)table.ml $(libdir)table.mli
	ocamlbuild -classic-display -use-ocamlfind -j 1 -tag thread -tag principal -r -package 'core uint mysql ppx_deriving ppx_deriving.eq ppx_deriving.ord ppx_deriving.show fieldslib ppx_fields_conv pcre ppx_sexp_conv ppx_compare' -build-dir build -I src/lib -I src/main -I build/src/lib src/lib/lib.a
	ocamlbuild -classic-display -use-ocamlfind -j 1 -tag thread -tag principal -r -package 'core uint mysql ppx_deriving ppx_deriving.eq ppx_deriving.ord ppx_deriving.show fieldslib ppx_fields_conv pcre ppx_sexp_conv ppx_compare' -build-dir build -I src/lib -I src/main -I build/src/lib src/lib/lib.cma
	ocamlbuild -classic-display -use-ocamlfind -j 1 -tag thread -tag principal -r -package 'core uint mysql ppx_deriving ppx_deriving.eq ppx_deriving.ord ppx_deriving.show fieldslib ppx_fields_conv pcre ppx_sexp_conv ppx_compare' -build-dir build -I src/lib -I src/main -I build/src/lib src/lib/lib.cmo
	ocamlbuild -classic-display -use-ocamlfind -j 1 -tag thread -tag principal -r -package 'core uint mysql ppx_deriving ppx_deriving.eq ppx_deriving.ord ppx_deriving.show fieldslib ppx_fields_conv pcre ppx_sexp_conv ppx_compare' -build-dir build -I src/lib -I src/main -I build/src/lib src/lib/lib.cmx
ocaml_mysql_model: lib $(maindir)ocaml_mysql_model.ml
	ocamlbuild -classic-display -use-ocamlfind -j 1 -tag thread -tag principal -r -package 'core uint mysql ppx_deriving ppx_deriving.eq ppx_deriving.ord ppx_deriving.show fieldslib ppx_fields_conv pcre ppx_sexp_conv ppx_compare' -build-dir build -I src/lib -I src/main -I build/src/lib src/main/ocaml_mysql_model.native
	ocamlbuild -classic-display -use-ocamlfind -j 1 -tag thread -tag principal -r -package 'core uint mysql ppx_deriving ppx_deriving.eq ppx_deriving.ord ppx_deriving.show fieldslib ppx_fields_conv pcre ppx_sexp_conv ppx_compare' -build-dir build -I src/lib -I src/main -I build/src/lib src/main/ocaml_mysql_model.byte

install: ocaml_mysql_model
	ocamlfind install $(PROJECT) ./$(builddir)$(libdir)* ./$(builddir)$(maindir)* META
uninstall:
	ocamlfind remove $(PROJECT)
#only makes sense to run this after copying output file into the src/lib dir
#test_output: $(builddir)$(maindir)ocaml_mysql_model.native
#	ocamlbuild -classic-display -use-ocamlfind -j 1 -tag thread -tag principal -r -package 'core uint mysql ppx_deriving ppx_deriving.show fieldslib ppx_fields_conv ppx_sexp_conv ppx_deriving.eq ppx_deriving.ord pcre' -build-dir build -I src/lib -I src/main -I build/src/lib src/lib/scrapings.cma
