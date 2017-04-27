PROJECT=
libdir=src/lib/
maindir=src/main/
all: lib
clean:
	rm -rvf build 

lib: $(libdir)sql_supported_types.ml $(libdir)sql_supported_types.mli $(libdir)model.ml $(libdir)model.mli
	ocamlbuild -classic-display -use-ocamlfind -j 1 -tag thread -tag principal -r -package 'core uint' -build-dir build -I src/lib -I src/main src/lib/sql_supported_types.cmxs
	ocamlbuild -classic-display -use-ocamlfind -j 1 -tag thread -tag principal -r -package 'core uint mysql ppx_deriving ppx_deriving.show' -build-dir build -I src/lib -I src/main src/lib/model.cmxs

#command: lib $(maindir)sf_rest_pull.ml
#	ocamlbuild -classic-display -use-ocamlfind -j 1 -tag thread -tag principal -r -package 'core ' -build-dir build -I src/lib -I src/main src/main/sf_rest_pull.native

#uninstall:
#     ocamlfind remove $(PROJECT)

#install: uninstall META
#     ocamlfind install $(PROJECT) META build/$(libdir)* build/$(maindir) 
