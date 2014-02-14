all:
	# Comple just the stubs into an object file.
	ocamlfind ocamlopt -o termbox_stubs termbox_stubs.c -ccopt -fPIC
	ar -rc libtermbox_stubs.a termbox_stubs.o

	# Compile scrypt.mli (the interface) to a cmi (compiled module interface).
	# Compile scrypt.ml to bytecode (cmo).
	ocamlfind ocamlc -c termbox.mli termbox.ml

	# Compile scrypt.ml to scrypt.o (native code) and scrypt.cmx (extra information for optimizing and linking the native code.)
	ocamlfind ocamlopt -c termbox.ml

	# Take:
	#	* C object files, scrypt_stubs.o and all object files extracted from libscrypt/libscrypt.a.
	#	* Bytecode object file scrypt.cmo
	#	* Native object file scrypt.cmx + scrypt.o, we supply just the .cmx, but it points to the .o, and it is included in resulting scrypt.a.
	#
	# Link it all to produce the following files:
	#       libscrypt.a, contains scrypt_stubs.o and libscrypt/*.o:
	#		Most of the C portion of our library.
	#		libscrypt.a MUST be installed, see cmxa.
	#
	#	scrypt.a, contains scrypt.o:
	#		Native version of scrypt.ml, does NOT include the stubs.
	#		XXX: I'm not sure why this has to be a separate archive and isn't combined with libscrypt.a.
	#		     What happens when you have more files? Do you then have to install a bunch of .a files with your library?
	#		scrypt.a MUST be installed, see cmxa.
	#
	#	scrypt.cma, contains scrypt.cmo:
	#		Bytecode version of library.
	#		scrypt.cma MUST be installed.
	#		scrypt.cmo is NOT installed since it is fully comtained in scrypt.cma.
	#
	#	scrypt.cmxa, contains scrypt.cmx and combines it (without containing) with  scrypt.a, and libscrypt.a:
	#		These files comprise the native version of the library.
	#		scrypt.cmxa, scrypt.a, and libscrypt.a MUST be installed and linked together.
	#			The -cclib options accomplish this task transparently, since they
	#			are memoized in scrypt.cmxa and are automatically applied whenever a client links to the library.
	#		scrypt.cmx is NOT installed since it is fully contained in scrypt.cmxa.
	#
	#	-lcrypto is OpenSSL (scrypt dependency) and must be present on on the system, it will also link the resulting dllscrypt.so with libcrypto.so.
	ocamlfind ocamlmklib -v -o termbox termbox.cmo termbox.cmx libtermbox_stubs.a -cclib -ltermbox

install:
	ocamlfind install termbox META *.cmi *.cmxa *.cma *.a *.so

uninstall:
	ocamlfind remove termbox

docs:
	rm -rf docs
	mkdir docs
	ocamlfind ocamldoc -html -d docs scrypt.mli

clean:
	rm -f *.cmi *.cmxa *.cma *.cmx *.cmo *.o *.so *.a
