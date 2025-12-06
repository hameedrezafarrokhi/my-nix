# bsp-layout-ext

PREFIX = /home/hrf/.local/share/bsp-layout-ext
MANPREFIX = ${PREFIX}/share/man
SRCPREFIX = ${PREFIX}/lib

BINARY_PATH = ${DESTDIR}${PREFIX}/bin
MAN_PATH = ${DESTDIR}${MANPREFIX}/man1
SRC_PATH = ${DESTDIR}${SRCPREFIX}/bsp-layout-ext

MANPAGE = ${MAN_PATH}/bsp-layout-ext.1

uninstall:
	rm -f ${BINARY_PATH}/bsp-layout-ext ${MAN_PATH}/bsp-layout-ext.1
	rm -rf ${SRC_PATH}
	echo "Removed bsp-layout-ext source files"

install:
	mkdir -p ${BINARY_PATH} ${SRC_PATH} ${MAN_PATH}
	cp -rf src/* ${SRC_PATH}/ # Source files
	cp src/layout-ext.sh layout-ext.sh.tmp
	bash update_version.sh ${SRC_PATH}
	cp -f ${SRC_PATH}/layout-ext.sh layout-ext.sh.tmp
	sed "s|{{SOURCE_PATH}}|${SRC_PATH}|g" layout-ext.sh.tmp > ${SRC_PATH}/layout-ext.sh # Update source path
	rm layout-ext.sh.tmp
	bash update_version.sh ${MANPAGE}
	chmod 644 ${MANPAGE} # Manpage permission
	chmod 755 ${SRC_PATH}/layouts/*.sh
	chmod 755 ${SRC_PATH}/layout-ext.sh
	ln -sf ${SRC_PATH}/layout-ext.sh ${BINARY_PATH}/bsp-layout-ext # Create bin
	echo "Installed bsp-layout-ext"

.PHONY: install uninstall
