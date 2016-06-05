TERMBOX_PATH = termbox
TERMBOX_A = $(TERMBOX_PATH)/build/src/libtermbox.a

all: $(TERMBOX_A)
	# Comple just the stubs into an object file.
	ocamlfind ocamlc -c termbox_stubs.c -ccopt -fPIC -ccopt -I$(TERMBOX_PATH)/src -o termbox_stubs.o

	# Make the dynamic and static libraries containing the stubs AND termbox objects.
	ocamlfind ocamlmklib termbox_stubs.o $(TERMBOX_PATH)/build/src/*.2.o -o otermbox

	# Make the cmi and cmo files.
	ocamlfind ocamlc -c termbox.mli termbox.ml
	# Make the bytecode library.
	#	"-dllib -lotermbox" Arrange that the stubs are loaded by the runtime system at program startup.
	#	"-cclib -lotermbox" Pass -lotermbox when linking in -custom runtime mode. ie. when including a runtime with the bytecode.
	ocamlfind ocamlc -a -dllib -lotermbox -cclib -lotermbox termbox.cmo -o termbox.cma

	# Make the cmx file.
	ocamlopt -c termbox.ml
	# Make the native version of the library.
	ocamlopt -a -cclib -lotermbox termbox.cmx -o termbox.cmxa
	# Make a version of the library that supports being loaded by Dynlink.
	ocamlopt -shared termbox.cmx -o termbox.cmxs

$(TERMBOX_A):
	cd $(TERMBOX_PATH) && ./waf configure && ./waf

install:
	ocamlfind install termbox META *.cmi *.cma *.cmx *.cmxa *.cmxs *.a *.so

uninstall:
	ocamlfind remove termbox

docs:
	mkdir docs
	ocamlfind ocamldoc -html -d docs termbox.mli

clean:
	rm -f *.cmi *.cmxa *.cmxs *.cma *.cmx *.cmo *.o *.so *.a
	cd $(TERMBOX_PATH) && ./waf clean
	rm -rf docs
