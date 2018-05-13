PROJECT=ocaml_db_model
libdir=src/lib/
maindir=src/main/
builddir=build/

ifndef PREFIX
  PREFIX = $(shell dirname $$(dirname $$(which ocamlfind)))
  export PREFIX
endif

ifndef BINDIR
  BINDIR = $(PREFIX)/bin
  export BINDIR
endif

.PHONY: all clean lib ocaml_mysql_model install uninstall

#LIBINSTALL_FILES=$(wildcard *.ml *.mli *.cmi *.cmx *.cma *.cmo *.cmx *.cmxa *.a *.so *.o)
all: ocaml_mysql_model
clean:
	rm -rvf build;rm src/tables/*

lib: $(libdir)date_extended.ml $(libdir)date_extended.mli $(libdir)date_time_extended.ml $(libdir)date_time_extended.mli $(libdir)uint64_extended.ml $(libdir)uint64_extended.mli $(libdir)uint32_extended.ml $(libdir)uint32_extended.mli $(libdir)uint16_extended.ml $(libdir)uint16_extended.mli $(libdir)uint8_extended.ml $(libdir)uint8_extended.mli $(libdir)utilities2copy.ml $(libdir)utilities2copy.mli $(libdir)sql_supported_types.ml $(libdir)sql_supported_types.mli $(libdir)model.ml $(libdir)model.mli $(libdir)table.ml $(libdir)table.mli
	ocamlbuild -classic-display -use-ocamlfind -j 1 -tag thread -tag principal -r -package 'stdint mysql ppx_deriving ppx_deriving.eq ppx_deriving.ord ppx_deriving.show fieldslib ppx_fields_conv pcre ppx_sexp_conv ppx_compare yojson ppx_deriving_yojson' -build-dir build -I src/lib -I src/main -I build/src/lib src/lib/ocaml_db_model.a
	ocamlbuild -classic-display -use-ocamlfind -j 1 -tag thread -tag principal -r -package 'stdint mysql ppx_deriving ppx_deriving.eq ppx_deriving.ord ppx_deriving.show fieldslib ppx_fields_conv pcre ppx_sexp_conv ppx_compare yojson ppx_deriving_yojson' -build-dir build -I src/lib -I src/main -I build/src/lib src/lib/ocaml_db_model.cma
	ocamlbuild -classic-display -use-ocamlfind -j 1 -tag thread -tag principal -r -package 'stdint mysql ppx_deriving ppx_deriving.eq ppx_deriving.ord ppx_deriving.show fieldslib ppx_fields_conv pcre ppx_sexp_conv ppx_compare yojson ppx_deriving_yojson' -build-dir build -I src/lib -I src/main -I build/src/lib src/lib/ocaml_db_model.cmo
	ocamlbuild -classic-display -use-ocamlfind -j 1 -tag thread -tag principal -r -package 'stdint mysql ppx_deriving ppx_deriving.eq ppx_deriving.ord ppx_deriving.show fieldslib ppx_fields_conv pcre ppx_sexp_conv ppx_compare yojson ppx_deriving_yojson' -build-dir build -I src/lib -I src/main -I build/src/lib src/lib/ocaml_db_model.cmx
ocaml_mysql_model: lib $(maindir)ocaml_mysql_model.ml
	ocamlbuild -classic-display -use-ocamlfind -j 1 -tag thread -tag principal -r -package 'stdint mysql ppx_deriving ppx_deriving.eq ppx_deriving.ord ppx_deriving.show fieldslib ppx_fields_conv pcre ppx_sexp_conv ppx_compare yojson ppx_deriving_yojson' -build-dir build -I src/lib -I src/main -I build/src/lib src/main/ocaml_mysql_model.native
	ocamlbuild -classic-display -use-ocamlfind -j 1 -tag thread -tag principal -r -package 'stdint mysql ppx_deriving ppx_deriving.eq ppx_deriving.ord ppx_deriving.show fieldslib ppx_fields_conv pcre ppx_sexp_conv ppx_compare yojson ppx_deriving_yojson' -build-dir build -I src/lib -I src/main -I build/src/lib src/main/ocaml_mysql_model.byte

install: ocaml_mysql_model
	ocamlfind install $(PROJECT) ./$(builddir)$(libdir)* ./$(builddir)$(maindir)* META
	cp $(builddir)$(maindir)ocaml_mysql_model.native $(BINDIR)/
	cp $(builddir)$(maindir)ocaml_mysql_model.byte $(BINDIR)/

uninstall:
	ocamlfind remove $(PROJECT)
#only makes sense to run this after copying output file into the src/lib dir
#test_output: $(builddir)$(maindir)ocaml_mysql_model.native
#	ocamlbuild -classic-display -use-ocamlfind -j 1 -tag thread -tag principal -r -package 'stdint mysql ppx_deriving ppx_deriving.show fieldslib ppx_fields_conv ppx_sexp_conv ppx_deriving.eq ppx_deriving.ord pcre' -build-dir build -I src/lib -I src/main -I build/src/lib src/lib/scrapings.cma
