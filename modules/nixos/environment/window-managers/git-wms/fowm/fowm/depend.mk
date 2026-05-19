main.o: main.cc config.hh misc.hh screen.hh main.hh window.hh frame.hh \
 client.hh title.hh utility.hh decoration.hh border.hh atoms.hh info.hh \
 menu.hh winmenu.hh action.hh
screen.o: screen.cc frame.hh client.hh window.hh misc.hh title.hh main.hh \
 utility.hh decoration.hh border.hh screen.hh info.hh action.hh atoms.hh \
 config.hh menu.hh
frame.o: frame.cc winlist.hh screen.hh main.hh misc.hh window.hh frame.hh \
 client.hh title.hh utility.hh decoration.hh border.hh info.hh winmenu.hh \
 action.hh atoms.hh config.hh
client.o: client.cc frame.hh client.hh window.hh misc.hh title.hh main.hh \
 utility.hh decoration.hh border.hh screen.hh atoms.hh action.hh \
 config.hh
title.o: title.cc screen.hh main.hh misc.hh window.hh frame.hh client.hh \
 title.hh utility.hh decoration.hh border.hh decorfunc.hh action.hh \
 config.hh
border.o: border.cc frame.hh client.hh window.hh misc.hh title.hh main.hh \
 utility.hh decoration.hh border.hh decorfunc.hh action.hh config.hh
decoration.o: decoration.cc frame.hh client.hh window.hh misc.hh title.hh \
 main.hh utility.hh decoration.hh border.hh screen.hh config.hh
info.o: info.cc frame.hh client.hh window.hh misc.hh title.hh main.hh \
 utility.hh decoration.hh border.hh info.hh screen.hh config.hh
menu.o: menu.cc frame.hh client.hh window.hh misc.hh title.hh main.hh \
 utility.hh decoration.hh border.hh menu.hh winmenu.hh action.hh \
 screen.hh config.hh
winmenu.o: winmenu.cc winlist.hh screen.hh main.hh misc.hh window.hh \
 frame.hh client.hh title.hh utility.hh decoration.hh border.hh menu.hh \
 winmenu.hh action.hh config.hh
utility.o: utility.cc main.hh misc.hh utility.hh decoration.hh window.hh \
 config.hh
window.o: window.cc window.hh misc.hh
action.o: action.cc frame.hh client.hh window.hh misc.hh title.hh main.hh \
 utility.hh decoration.hh border.hh screen.hh action.hh info.hh menu.hh \
 winmenu.hh config.hh
atoms.o: atoms.cc atoms.hh main.hh misc.hh
pixmap.o: pixmap.cc pixmap.hh config.hh misc.hh screen.hh main.hh \
 window.hh
cursor.o: cursor.cc cursor.hh misc.hh config.hh main.hh
config.o: config.cc pixmap.hh cursor.hh misc.hh action.hh screen.hh \
 main.hh window.hh config.hh
misc.o: misc.cc misc.hh
