#include "atoms.hh"

Atom atoms::atom[NUM_ATOMS];
const char * const atoms::name[NUM_ATOMS] =
{
	[wm_state] = "WM_STATE",
	[wm_change_state] = "WM_CHANGE_STATE",
	[wm_protocols] = "WM_PROTOCOLS",
	[wm_delete_window] = "WM_DELETE_WINDOW",
	[wm_take_focus] = "WM_TAKE_FOCUS",
	[motif_wm_hints] = "_MOTIF_WM_HINTS",
	[utf8_string] = "UTF8_STRING",
	[net_supported] = "_NET_SUPPORTED",
	[net_supporting_wm_check] = "_NET_SUPPORTING_WM_CHECK",
	[net_frame_extents] = "_NET_FRAME_EXTENTS",
	[net_request_frame_extents] = "_NET_REQUEST_FRAME_EXTENTS",
	[net_wm_name] = "_NET_WM_NAME",
	[net_wm_state] = "_NET_WM_STATE",
	[net_wm_state_fullscreen] = "_NET_WM_STATE_FULLSCREEN"
};
