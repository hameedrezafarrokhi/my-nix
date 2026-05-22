#Sara linboy fork Version
VERSION=1.0

#Customize to fit your system

#paths
X11INC = /usr/X11R6/include
X11LIB = /usr/X11R6/lib

#Freetype
FREETYPELIBS = -lfontconfig -lXft
FREETYPEINC = /usr/include/freetype2
#OpenBSD (uncomment)
#FREETYPEINC = ${X11INC}/freetype2

#Includes and Libs
INCS = -I${X11INC} -I${FREETYPEINC}
LIBS = -L${X11LIB} -lX11 ${XINERAMALIBS} ${FREETYPELIBS}
#Flags
CPPFLAGS = -D_DEFAULT_SOURCE -D_BSD_SOURCE -D_POSIX_C_SOURCE=2 -DVERSION=\"${VERSION}\" ${XINERAMAFLAGS}
CFLAGS   = -std=c99 -pedantic -Wall -Wno-deprecated-declarations -Os ${INCS} ${CPPFLAGS}
DFLAGS  = ${LIBS}

