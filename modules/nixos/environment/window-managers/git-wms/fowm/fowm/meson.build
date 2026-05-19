project('xfcalc', 'cpp', default_options :
	['cpp_std=gnu++11','cpp_eh=none','cpp_rtti=false'])

deps = []

if get_option('xft')
	deps += dependency('xft')
	deps += dependency('fontconfig')
	add_project_arguments('-DUSE_XFT=1', language : 'cpp')
endif

deps += dependency('xpm')
deps += dependency('xext')
deps += dependency('x11')

srcs = ['main.cc','screen.cc','frame.cc','client.cc','title.cc','border.cc', 
	'decoration.cc','info.cc','menu.cc','winmenu.cc','utility.cc', 
	'window.cc','action.cc','atoms.cc','pixmap.cc','cursor.cc', 
	'config.cc','misc.cc']

executable('fowm', srcs, dependencies : deps, install : true)
install_man('fowm.1')
