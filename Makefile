PROJECT=
libdir=src/lib/
maindir=src/main/
builddir=build/
all: ocaml_mysql_model
clean:
	rm -rvf build 

lib: $(libdir)uint64_w_sexp.ml $(libdir)uint64_w_sexp.mli $(libdir)uint32_w_sexp.ml $(libdir)uint32_w_sexp.mli $(libdir)uint16_w_sexp.ml $(libdir)uint16_w_sexp.mli $(libdir)uint8_w_sexp.ml $(libdir)uint8_w_sexp.mli $(libdir)utilities.ml $(libdir)utilities.mli $(libdir)sql_supported_types.ml $(libdir)sql_supported_types.mli $(libdir)model.ml $(libdir)model.mli $(libdir)table.ml $(libdir)table.mli
	ocamlbuild -classic-display -use-ocamlfind -j 1 -tag thread -tag principal -r -package 'core uint mysql ppx_deriving ppx_deriving.show fieldslib ppx_fields_conv pcre' -build-dir build -I src/lib -I src/main -I build/src/lib src/lib/lib.cma

ocaml_mysql_model: lib $(maindir)ocaml_mysql_model.ml
	ocamlbuild -classic-display -use-ocamlfind -j 1 -tag thread -tag principal -r -package 'core uint mysql ppx_deriving ppx_deriving.show fieldslib ppx_fields_conv pcre' -build-dir build -I src/lib -I src/main -I build/src/lib src/main/ocaml_mysql_model.native

#only makes sense to run this after copying output file into the src/lib dir
#test_output: $(builddir)$(maindir)ocaml_mysql_model.native
#	ocamlbuild -classic-display -use-ocamlfind -j 1 -tag thread -tag principal -r -package 'core uint mysql ppx_deriving ppx_deriving.show fieldslib ppx_fields_conv ppx_sexp_conv ppx_deriving.eq ppx_deriving.ord pcre' -build-dir build -I src/lib -I src/main -I build/src/lib src/lib/scrapings.cma
