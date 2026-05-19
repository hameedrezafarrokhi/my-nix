#ifndef ATOMS_HH
#define ATOMS_HH

#include "main.hh"

namespace atoms
{
	enum
	{
		wm_state,
		wm_change_state,
		wm_protocols,
		wm_delete_window,
		wm_take_focus,
		motif_wm_hints,
		utf8_string,
		net_supported,
		net_supporting_wm_check,
		net_frame_extents,
		net_request_frame_extents,
		net_wm_name,
		net_wm_state,
		net_wm_state_fullscreen,
		NUM_ATOMS
	};

	extern Atom atom[NUM_ATOMS];
	extern const char * const name[NUM_ATOMS];

	inline void init()
	{
		for (uint i = 0; i < NUM_ATOMS; i++)
		{
			atom[i] = XInternAtom(dpy, name[i], False);
		}
	}
}

#define WM_STATE atoms::atom[atoms::wm_state]
#define WM_CHANGE_STATE atoms::atom[atoms::wm_change_state]
#define WM_PROTOCOLS atoms::atom[atoms::wm_protocols]
#define WM_DELETE_WINDOW atoms::atom[atoms::wm_delete_window]
#define WM_TAKE_FOCUS atoms::atom[atoms::wm_take_focus]
#define MOTIF_WM_HINTS atoms::atom[atoms::motif_wm_hints]
#define UTF8_STRING atoms::atom[atoms::utf8_string]
#define NET_WM_NAME atoms::atom[atoms::net_wm_name]
#define NET_SUPPORTED atoms::atom[atoms::net_supported]
#define NET_SUPPORTING_WM_CHECK atoms::atom[atoms::net_supporting_wm_check]
#define NET_FRAME_EXTENTS atoms::atom[atoms::net_frame_extents]
#define NET_REQUEST_FRAME_EXTENTS atoms::atom[atoms::net_request_frame_extents]
#define NET_WM_STATE atoms::atom[atoms::net_wm_state]
#define NET_WM_STATE_FULLSCREEN atoms::atom[atoms::net_wm_state_fullscreen]

#endif
