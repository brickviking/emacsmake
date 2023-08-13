# Dirt-simple Makefile to install the emacsmake script
# v0.1 Initial cut - it only has to install one thing.

DESTDIR = /usr/local/bin

install: emacsmake
	@sudo cp -v emacsmake ${DESTDIR}/
	@sudo chmod -v +x ${DESTDIR}/emacsmake

uninstall:
	@sudo rm -v ${DESTDIR}/emacsmake
