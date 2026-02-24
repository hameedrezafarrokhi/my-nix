# xwww

PREFIX = /usr/local
SRCPREFIX = ${PREFIX}/lib

BINARY_PATH = ${DESTDIR}${PREFIX}/bin
SRC_PATH = ${DESTDIR}${SRCPREFIX}/xwww

VERSION = 0.1.0

uninstall:
	rm -f ${BINARY_PATH}/xwww
	rm -rf ${SRC_PATH}
	echo "Removed xwww source files"

install:
	mkdir -p ${BINARY_PATH} ${SRC_PATH} ${MAN_PATH}
	cp -rf src/* ${SRC_PATH}/
	cp src/xwww.sh xwww.sh.tmp
	sed "s|{{VERSION}}|${VERSION}|g" -i xwww.sh.tmp
	sed "s|{{SOURCE_PATH}}|${SRC_PATH}|g" -i xwww.sh.tmp
	cp -f xwww.sh.tmp ${SRC_PATH}/xwww.sh
	rm xwww.sh.tmp
	chmod 755 ${SRC_PATH}/animations/*.sh
	chmod 755 ${SRC_PATH}/xwww.sh
	ln -sf ${SRC_PATH}/xwww.sh ${BINARY_PATH}/xwww
	echo "Installed xwww"

.PHONY: install uninstall
