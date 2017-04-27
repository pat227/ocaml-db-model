PROJECT=
libdir=src/lib/
maindir=src/main/
all: lib
clean:
	rm -rvf build 

lib: $(libdir)sql_supported_types.ml $(libdir)sql_supported_types.mli $(libdir)model.ml $(libdir)model.mli $(libdir)table.ml $(libdir)table.mli
	ocamlbuild -classic-display -use-ocamlfind -j 1 -tag thread -tag principal -r -build-dir build -I src/lib -I src/main src/lib/table.cmxs
	ocamlbuild -classic-display -use-ocamlfind -j 1 -tag thread -tag principal -r -package 'core uint' -build-dir build -I src/lib -I src/main src/lib/sql_supported_types.cmxs
	ocamlbuild -classic-display -use-ocamlfind -j 1 -tag thread -tag principal -r -package 'core uint mysql ppx_deriving ppx_deriving.show' -build-dir build -I src/lib -I src/main src/lib/model.cmxs

command: lib $(maindir)command.ml
	ocamlbuild -classic-display -use-ocamlfind -j 1 -tag thread -tag principal -r -package 'core ' -build-dir build -I src/lib -I src/main src/main/command.native

#uninstall:
#     ocamlfind remove $(PROJECT)

#install: uninstall META
#     ocamlfind install $(PROJECT) META build/$(libdir)* build/$(maindir) 
