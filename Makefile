PROJECT=
libdir=src/lib/
maindir=src/main/
all: command
clean:
	rm -rvf build 

lib: $(libdir)uint64_w_sexp.ml $(libdir)uint64_w_sexp.mli $(libdir)uint32_w_sexp.ml $(libdir)uint32_w_sexp.mli $(libdir)uint16_w_sexp.ml $(libdir)uint16_w_sexp.mli $(libdir)uint8_w_sexp.ml $(libdir)uint8_w_sexp.mli $(libdir)utilities.ml $(libdir)utilities.mli $(libdir)sql_supported_types.ml $(libdir)sql_supported_types.mli $(libdir)model.ml $(libdir)model.mli $(libdir)table.ml $(libdir)table.mli
	ocamlbuild -classic-display -use-ocamlfind -j 1 -tag thread -tag principal -r -package 'core uint mysql ppx_deriving ppx_deriving.show fieldslib ppx_fields_conv' -build-dir build -I src/lib -I src/main -I build/src/lib src/lib/uint8_w_sexp.cma
	ocamlbuild -classic-display -use-ocamlfind -j 1 -tag thread -tag principal -r -package 'core uint mysql ppx_deriving ppx_deriving.show fieldslib ppx_fields_conv' -build-dir build -I src/lib -I src/main -I build/src/lib src/lib/lib.cma

command: lib $(maindir)command.ml
	ocamlbuild -classic-display -use-ocamlfind -j 1 -tag thread -tag principal -r -package 'core uint mysql ppx_deriving ppx_deriving.show fieldslib ppx_fields_conv' -build-dir build -I src/lib -I src/main -I build/src/lib src/main/command.native

test_output: command
	ocamlbuild -classic-display -use-ocamlfind -j 1 -tag thread -tag principal -r -package 'core uint mysql ppx_deriving ppx_deriving.show fieldslib ppx_fields_conv ppx_sexp_conv ppx_deriving.eq ppx_deriving.ord' -build-dir build -I src/lib -I src/main -I build/src/lib src/lib/scrapings.native
