PROJECT=
LIBDIR=src/lib/
MAINDIR=src/main/
BUILDDIR=build/
PACKAGES='core uint mysql ppx_deriving ppx_deriving.show fieldslib ppx_fields_conv pcre bignum'
all: ocaml_mysql_model
clean:
	rm -rvf build 

lib: $(LIBDIR)uint64_w_sexp.ml $(LIBDIR)uint64_w_sexp.mli $(LIBDIR)uint32_w_sexp.ml $(LIBDIR)uint32_w_sexp.mli $(LIBDIR)uint16_w_sexp.ml $(LIBDIR)uint16_w_sexp.mli $(LIBDIR)uint8_w_sexp.ml $(LIBDIR)uint8_w_sexp.mli $(LIBDIR)utilities.ml $(LIBDIR)utilities.mli $(LIBDIR)sql_supported_types.ml $(LIBDIR)sql_supported_types.mli $(LIBDIR)model.ml $(LIBDIR)model.mli $(LIBDIR)table.ml $(LIBDIR)table.mli
	ocamlbuild -classic-display -use-ocamlfind -j 1 -tag thread -tag principal -r -package $(PACKAGES) -build-dir build -I src/lib -I src/main -I build/src/lib src/lib/lib.cma

ocaml_mysql_model: lib $(MAINDIR)ocaml_mysql_model.ml
	ocamlbuild -classic-display -use-ocamlfind -j 1 -tag thread -tag principal -r -package $(PACKAGES) -build-dir build -I src/lib -I src/main -I build/src/lib src/main/ocaml_mysql_model.native

#only makes sense to run this after copying output file into the src/lib dir
#test_output: $(BUILDDIR)$(MAINDIR)ocaml_mysql_model.native
#	ocamlbuild -classic-display -use-ocamlfind -j 1 -tag thread -tag principal -r -package 'core uint mysql ppx_deriving ppx_deriving.show fieldslib ppx_fields_conv ppx_sexp_conv ppx_deriving.eq ppx_deriving.ord pcre' -build-dir build -I src/lib -I src/main -I build/src/lib src/lib/scrapings.cma
