#ifndef WINMENU_HH
#define WINMENU_HH

#include "action.hh"

class winmenu_action : public menu_action
{
public:
	static winmenu_action instance;
	static bool clean;

	static void init();

	void key_event(XKeyEvent *, frame_window *) override;
	void button_event(XButtonEvent *, frame_window *) override;
};

#endif
