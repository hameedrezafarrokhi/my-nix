#include <X11/Xlib.h>
#include <X11/Xutil.h>
#include <X11/Xatom.h>
#include <X11/extensions/shape.h>
#include <X11/Xft/Xft.h>
#include <X11/keysym.h>
#include <fontconfig/fontconfig.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <unistd.h>
#include <sys/time.h>
#include <math.h>
#include "config.h"

typedef struct {
    char icon[8];
    char text[32];
    char toggle_command[256];
    char untoggle_command[256];
    int is_active;
    int is_pressed;
    int click_only;
} Button;

typedef struct {
    Display *display;
    Window window;
    Window root_window;
    GC gc;
    XftDraw *xft_draw;
    XftFont *icon_font, *text_font, *page_font;
    XftColor xft_text_color, xft_active_text_color, xft_icon_color, xft_active_icon_color;
    XftColor xft_page_color, xft_page_active_color;
    Colormap colormap;
    Visual *visual;
    int has_compositor;
    
    XColor bg_color, text_color, window_border_color, border_color, button_bg_color;
    XColor active_bg_color, active_text_color, active_border_color;
    XColor pressed_bg_color, page_color, page_active_color;
    
    int screen_width, screen_height;
    int current_x, target_x, hidden_x;
    int is_visible, is_closing, is_animating, mouse_in_zone;
    int needs_redraw;
    int frame_count;
    
    int current_page;
    int total_pages;
    Button buttons[MAX_PAGES][BUTTONS_PER_PAGE];
} Widget;

// Function declarations
void init_widget(Widget *widget);
void animate_widget(Widget *widget);
void start_close_animation(Widget *widget);
void start_show_animation(Widget *widget);
void draw_widget(Widget *widget);
void draw_button(Widget *widget, int index);
void draw_page_indicator(Widget *widget);
void cleanup_widget(Widget *widget);
int check_mouse_in_hover_zone(Widget *widget);
int check_mouse_over_widget(Widget *widget);
void setup_colors(Widget *widget);
void setup_fonts(Widget *widget);
void execute_command(const char *command);
void init_buttons(Widget *widget);
int get_button_at_position(Widget *widget, int x, int y);
void toggle_button(Widget *widget, int button_index);
void change_page(Widget *widget, int direction);
void draw_text_centered_xft(Widget *widget, const char *text, int x, int y, int width, XftFont *font, XftColor *color);
int check_compositor(Display *display);
void set_window_opacity(Widget *widget, double opacity);


//NEW LINE
//static time_t hover_start = 0;
static struct timeval hover_start = {0, 0};
static int hovering = 0;
//

void execute_command(const char *command) {
    if (!command[0]) return;
    
    if (fork() == 0) {
        setsid();
        execl("/bin/sh", "sh", "-c", command, NULL);
        exit(1);
    }
}

void init_buttons(Widget *widget) {
    // Initialize all pages
    for (int page = 0; page < MAX_PAGES; page++) {
        for (int i = 0; i < BUTTONS_PER_PAGE; i++) {
            // Clear button data
            widget->buttons[page][i].icon[0] = '\0';
            widget->buttons[page][i].text[0] = '\0';
            widget->buttons[page][i].toggle_command[0] = '\0';
            widget->buttons[page][i].untoggle_command[0] = '\0';
            widget->buttons[page][i].click_only = 0;
            widget->buttons[page][i].is_active = 0;
            widget->buttons[page][i].is_pressed = 0;
        }
    }
    
    // Load page configurations
    for (int page = 0; page < MAX_PAGES; page++) {
        const struct {
            char icon[8];
            char text[32];
            char toggle_command[256];
            char untoggle_command[256];
            int click_only;
        } *page_config = get_page_config(page);
        
        if (page_config) {
            for (int i = 0; i < BUTTONS_PER_PAGE; i++) {
                if (page_config[i].icon[0] != '\0') {
                    strcpy(widget->buttons[page][i].icon, page_config[i].icon);
                    strcpy(widget->buttons[page][i].text, page_config[i].text);
                    strcpy(widget->buttons[page][i].toggle_command, page_config[i].toggle_command);
                    strcpy(widget->buttons[page][i].untoggle_command, page_config[i].untoggle_command);
                    widget->buttons[page][i].click_only = page_config[i].click_only;
                }
            }
        }
    }
    
    widget->current_page = DEFAULT_PAGE;
    widget->total_pages = MAX_PAGES;
}

XColor parse_color(Widget *widget, const char *color_str) {
    XColor color;
    if (!XParseColor(widget->display, widget->colormap, color_str, &color) ||
        !XAllocColor(widget->display, widget->colormap, &color)) {
        color.red = color.green = color.blue = 65535;
        XAllocColor(widget->display, widget->colormap, &color);
    }
    return color;
}

void setup_colors(Widget *widget) {
    int screen = DefaultScreen(widget->display);
    widget->colormap = DefaultColormap(widget->display, screen);
    widget->visual = DefaultVisual(widget->display, screen);
    
    widget->bg_color = parse_color(widget, BG_COLOR);
    widget->text_color = parse_color(widget, TEXT_COLOR);
    widget->window_border_color = parse_color(widget, WINDOW_BORDER_COLOR);
    widget->border_color = parse_color(widget, BORDER_COLOR);
    widget->button_bg_color = parse_color(widget, BUTTON_BG_COLOR);
    widget->active_bg_color = parse_color(widget, ACTIVE_BG_COLOR);
    widget->active_text_color = parse_color(widget, ACTIVE_TEXT_COLOR);
    widget->active_border_color = parse_color(widget, ACTIVE_BORDER_COLOR);
    widget->pressed_bg_color = parse_color(widget, PRESSED_BG_COLOR);
    widget->page_color = parse_color(widget, PAGE_COLOR);
    widget->page_active_color = parse_color(widget, PAGE_ACTIVE_COLOR);
    
    XftColorAllocName(widget->display, widget->visual, widget->colormap, TEXT_COLOR, &widget->xft_text_color);
    XftColorAllocName(widget->display, widget->visual, widget->colormap, ACTIVE_TEXT_COLOR, &widget->xft_active_text_color);
    XftColorAllocName(widget->display, widget->visual, widget->colormap, ICON_COLOR, &widget->xft_icon_color);
    XftColorAllocName(widget->display, widget->visual, widget->colormap, ACTIVE_ICON_COLOR, &widget->xft_active_icon_color);
    XftColorAllocName(widget->display, widget->visual, widget->colormap, PAGE_COLOR, &widget->xft_page_color);
    XftColorAllocName(widget->display, widget->visual, widget->colormap, PAGE_ACTIVE_COLOR, &widget->xft_page_active_color);
}

void setup_fonts(Widget *widget) {
    char icon_pattern[256], text_pattern[256], page_pattern[256];
    
    snprintf(icon_pattern, sizeof(icon_pattern), "%s:size=%d", ICON_FONT_NAME, ICON_FONT_SIZE);
    snprintf(text_pattern, sizeof(text_pattern), "%s:size=%d", TEXT_FONT_NAME, TEXT_FONT_SIZE);
    snprintf(page_pattern, sizeof(page_pattern), "%s:size=%d", PAGE_FONT_NAME, PAGE_FONT_SIZE);
    
    widget->icon_font = XftFontOpenName(widget->display, DefaultScreen(widget->display), icon_pattern);
    if (!widget->icon_font)
        widget->icon_font = XftFontOpenName(widget->display, DefaultScreen(widget->display), "monospace:size=20");
    
    widget->text_font = XftFontOpenName(widget->display, DefaultScreen(widget->display), text_pattern);
    if (!widget->text_font)
        widget->text_font = XftFontOpenName(widget->display, DefaultScreen(widget->display), "monospace:size=10");
    
    widget->page_font = XftFontOpenName(widget->display, DefaultScreen(widget->display), page_pattern);
    if (!widget->page_font)
        widget->page_font = XftFontOpenName(widget->display, DefaultScreen(widget->display), "monospace:size=8");
    
    if (!widget->icon_font || !widget->text_font || !widget->page_font)
        exit(1);
}

void init_widget(Widget *widget) {
    widget->display = XOpenDisplay(NULL);
    if (!widget->display)
        exit(1);
    
    int screen = DefaultScreen(widget->display);
    widget->root_window = RootWindow(widget->display, screen);
    widget->screen_width = DisplayWidth(widget->display, screen);
    widget->screen_height = DisplayHeight(widget->display, screen);
    
    // Check for compositor
    widget->has_compositor = check_compositor(widget->display);
    
    setup_colors(widget);
    setup_fonts(widget);
    init_buttons(widget);
    
    widget->hidden_x = widget->screen_width;
    widget->target_x = widget->screen_width - WIDGET_WIDTH;
    widget->current_x = widget->hidden_x;
    widget->is_visible = 0;
    widget->is_closing = 0;
    widget->is_animating = 0;
    widget->mouse_in_zone = 0;
    widget->needs_redraw = 1;
    widget->frame_count = 0;
    
    widget->window = XCreateSimpleWindow(
        widget->display, widget->root_window,
        widget->current_x, (widget->screen_height - WIDGET_HEIGHT) / 2,
        WIDGET_WIDTH, WIDGET_HEIGHT, BORDER_WIDTH,
        widget->window_border_color.pixel, widget->bg_color.pixel
    );
    
    XStoreName(widget->display, widget->window, WINDOW_NAME);
    XClassHint class_hint = {WINDOW_CLASS_NAME, WINDOW_CLASS_CLASS};
    XSetClassHint(widget->display, widget->window, &class_hint);
    
    XSetWindowAttributes attrs;
    attrs.override_redirect = True;
    attrs.backing_store = Always;
    attrs.save_under = True;
    XChangeWindowAttributes(widget->display, widget->window, 
                           CWOverrideRedirect | CWBackingStore | CWSaveUnder, &attrs);
    
    // Set WM hints to accept keyboard input
    XWMHints *wm_hints = XAllocWMHints();
    if (wm_hints) {
        wm_hints->flags = InputHint;
        wm_hints->input = True;
        XSetWMHints(widget->display, widget->window, wm_hints);
        XFree(wm_hints);
    }
    
    XGCValues gc_values;
    gc_values.foreground = widget->text_color.pixel;
    gc_values.background = widget->bg_color.pixel;
    widget->gc = XCreateGC(widget->display, widget->window, GCForeground | GCBackground, &gc_values);
    
    widget->xft_draw = XftDrawCreate(widget->display, widget->window, widget->visual, widget->colormap);
    
    XSelectInput(widget->display, widget->window, 
                ExposureMask | ButtonPressMask | ButtonReleaseMask | 
                KeyPressMask | KeyReleaseMask | EnterWindowMask | LeaveWindowMask |
                PointerMotionMask | FocusChangeMask | StructureNotifyMask);
    
    XMapWindow(widget->display, widget->window);
    
    // Set window opacity after mapping if compositor is available
    if (widget->has_compositor) {
        set_window_opacity(widget, WINDOW_OPACITY);
    }
    
    XFlush(widget->display);
}

int check_mouse_in_hover_zone(Widget *widget) {
    Window root_return, child_return;
    int root_x, root_y, win_x, win_y;
    unsigned int mask_return;
    
    if (!XQueryPointer(widget->display, widget->root_window,
                      &root_return, &child_return,
                      &root_x, &root_y, &win_x, &win_y, &mask_return))
        return 0;
    
    int widget_y = (widget->screen_height - WIDGET_HEIGHT) / 2;
    return (root_x >= widget->screen_width - HOVER_ZONE_WIDTH &&
            root_y >= widget_y - HOVER_ZONE_HEIGHT && 
            root_y <= widget_y + WIDGET_HEIGHT + HOVER_ZONE_HEIGHT);
}

int check_mouse_over_widget(Widget *widget) {
    Window root_return, child_return;
    int root_x, root_y, win_x, win_y;
    unsigned int mask_return;
    
    if (!XQueryPointer(widget->display, widget->root_window,
                      &root_return, &child_return,
                      &root_x, &root_y, &win_x, &win_y, &mask_return))
        return 0;
    
    int widget_y = (widget->screen_height - WIDGET_HEIGHT) / 2;
    return (root_x >= widget->current_x && 
            root_x <= widget->current_x + WIDGET_WIDTH &&
            root_y >= widget_y && 
            root_y <= widget_y + WIDGET_HEIGHT);
}

void animate_widget(Widget *widget) {
    if (widget->frame_count >= MAX_ANIMATION_FRAMES) {
        widget->current_x = widget->is_closing ? widget->hidden_x : widget->target_x;
        widget->is_visible = !widget->is_closing;
        widget->is_closing = 0;
        widget->is_animating = 0;
        widget->frame_count = 0;
        
        XMoveWindow(widget->display, widget->window, widget->current_x,
                   (widget->screen_height - WIDGET_HEIGHT) / 2);
        widget->needs_redraw = 1;
        return;
    }
    
    float frame_progress = (float)widget->frame_count / MAX_ANIMATION_FRAMES;
    float ease_out = 1.0f - (1.0f - frame_progress) * (1.0f - frame_progress) * (1.0f - frame_progress);
    
    if (widget->is_closing) {
        widget->current_x = widget->target_x + (int)((widget->hidden_x - widget->target_x) * ease_out);
    } else {
        widget->current_x = widget->hidden_x - (int)((widget->hidden_x - widget->target_x) * ease_out);
    }
    
    XMoveWindow(widget->display, widget->window, widget->current_x,
               (widget->screen_height - WIDGET_HEIGHT) / 2);
    
    widget->needs_redraw = 1;
    widget->frame_count++;
}

void start_close_animation(Widget *widget) {
    if (widget->is_visible && !widget->is_closing && !widget->is_animating) {
        widget->is_closing = 1;
        widget->is_animating = 1;
        widget->frame_count = 0;
    }
}

void start_show_animation(Widget *widget) {
    if (!widget->is_visible && !widget->is_closing && !widget->is_animating) {
        widget->mouse_in_zone = 1;
        widget->is_animating = 1;
        widget->frame_count = 0;
    }
}

void draw_text_centered_xft(Widget *widget, const char *text, int x, int y, int width, XftFont *font, XftColor *color) {
    if (!text || !text[0]) return;
    
    XGlyphInfo extents;
    XftTextExtentsUtf8(widget->display, font, (FcChar8*)text, strlen(text), &extents);
    
    int text_x = x + (width - extents.width) / 2;
    XftDrawStringUtf8(widget->xft_draw, color, font, text_x, y, (FcChar8*)text, strlen(text));
}

void draw_button(Widget *widget, int index) {
    Button *button = &widget->buttons[widget->current_page][index];
    
    // Skip empty buttons
    if (button->icon[0] == '\0') return;
    
    int button_x = WIDGET_PADDING;
    int button_y = WIDGET_PADDING + index * (BUTTON_SIZE + BUTTON_MARGIN);
    
    XColor *bg_color, *border_color;
    XftColor *text_color, *icon_color;
    
    if (button->is_pressed) {
        bg_color = &widget->pressed_bg_color;
        border_color = &widget->active_border_color;
        text_color = &widget->xft_active_text_color;
        icon_color = &widget->xft_active_icon_color;
    } else if (button->is_active) {
        bg_color = &widget->active_bg_color;
        border_color = &widget->active_border_color;
        text_color = &widget->xft_active_text_color;
        icon_color = &widget->xft_active_icon_color;
    } else {
        bg_color = &widget->button_bg_color;
        border_color = &widget->border_color;
        text_color = &widget->xft_text_color;
        icon_color = &widget->xft_icon_color;
    }
    
    XSetForeground(widget->display, widget->gc, bg_color->pixel);
    XFillRectangle(widget->display, widget->window, widget->gc,
                   button_x, button_y, BUTTON_SIZE, BUTTON_SIZE);
    
    XSetForeground(widget->display, widget->gc, border_color->pixel);
    int border_thickness = button->is_pressed ? 3 : 2;
    
    for (int i = 0; i < border_thickness; i++) {
        XDrawRectangle(widget->display, widget->window, widget->gc,
                       button_x - i, button_y - i,
                       BUTTON_SIZE + 2 * i, BUTTON_SIZE + 2 * i);
    }
    
    int icon_area_height = BUTTON_SIZE - ICON_TEXT_SPACING - widget->text_font->height - 16;
    int icon_y = button_y + icon_area_height / 2 + widget->icon_font->ascent / 2 + 8;
    int text_y = button_y + BUTTON_SIZE - widget->text_font->descent - 8;
    
    draw_text_centered_xft(widget, button->icon, button_x, icon_y, BUTTON_SIZE, widget->icon_font, icon_color);
    draw_text_centered_xft(widget, button->text, button_x, text_y, BUTTON_SIZE, widget->text_font, text_color);
}

void draw_page_indicator(Widget *widget) {
    if (widget->total_pages <= 1) return;
    
    int indicator_y = WIDGET_HEIGHT - PAGE_INDICATOR_HEIGHT - WIDGET_PADDING;
    int total_width = widget->total_pages * PAGE_DOT_SIZE + (widget->total_pages - 1) * PAGE_DOT_SPACING;
    int start_x = (WIDGET_WIDTH - total_width) / 2;
    
    for (int i = 0; i < widget->total_pages; i++) {
        int dot_x = start_x + i * (PAGE_DOT_SIZE + PAGE_DOT_SPACING);
        int dot_center_x = dot_x + PAGE_DOT_SIZE / 2;
        int dot_center_y = indicator_y + PAGE_DOT_SIZE / 2;
        int radius = PAGE_DOT_SIZE / 2;
        
        XColor *color = (i == widget->current_page) ? &widget->page_active_color : &widget->page_color;
        XSetForeground(widget->display, widget->gc, color->pixel);
        
        // Draw filled circle using XFillArc (360 degrees = 360 * 64 in X11)
        XFillArc(widget->display, widget->window, widget->gc,
                 dot_center_x - radius, dot_center_y - radius,
                 PAGE_DOT_SIZE, PAGE_DOT_SIZE, 0, 360 * 64);
        
        // Add subtle border for inactive dots to make them more defined
        if (i != widget->current_page) {
            XSetForeground(widget->display, widget->gc, widget->border_color.pixel);
            XDrawArc(widget->display, widget->window, widget->gc,
                     dot_center_x - radius, dot_center_y - radius,
                     PAGE_DOT_SIZE, PAGE_DOT_SIZE, 0, 360 * 64);
        }
    }
    
    // Draw page numbers with better styling
    char page_text[16];
    snprintf(page_text, sizeof(page_text), "%d/%d", widget->current_page + 1, widget->total_pages);
    
    XftColor *text_color = &widget->xft_page_color;
    int text_y = indicator_y + PAGE_DOT_SIZE + 12;
    draw_text_centered_xft(widget, page_text, 0, text_y, WIDGET_WIDTH, widget->page_font, text_color);
}

void draw_widget(Widget *widget) {
    if (!widget->needs_redraw) return;
    
    // Clear entire window to prevent trails
    XClearWindow(widget->display, widget->window);
    
    XSetForeground(widget->display, widget->gc, widget->bg_color.pixel);
    XFillRectangle(widget->display, widget->window, widget->gc,
                   0, 0, WIDGET_WIDTH, WIDGET_HEIGHT);
    
    for (int i = 0; i < BUTTONS_PER_PAGE; i++) {
        draw_button(widget, i);
    }
    
    draw_page_indicator(widget);
    
    XFlush(widget->display);
    widget->needs_redraw = 0;
}

int get_button_at_position(Widget *widget, int x, int y) {
    (void)widget;
    
    for (int i = 0; i < BUTTONS_PER_PAGE; i++) {
        int button_x = WIDGET_PADDING;
        int button_y = WIDGET_PADDING + i * (BUTTON_SIZE + BUTTON_MARGIN);
        
        if (x >= button_x && x <= button_x + BUTTON_SIZE &&
            y >= button_y && y <= button_y + BUTTON_SIZE) {
            return i;
        }
    }
    return -1;
}

void toggle_button(Widget *widget, int button_index) {
    if (button_index < 0 || button_index >= BUTTONS_PER_PAGE) return;
    
    Button *button = &widget->buttons[widget->current_page][button_index];
    
    // Skip empty buttons
    if (button->icon[0] == '\0') return;
    
    if (button->click_only) {
        // Click-only button: just execute the toggle command
        execute_command(button->toggle_command);
    } else {
        // Toggle button: change state and execute appropriate command
        button->is_active = !button->is_active;
        execute_command(button->is_active ? button->toggle_command : button->untoggle_command);
    }
    
    widget->needs_redraw = 1;
}

void change_page(Widget *widget, int direction) {
    int new_page = widget->current_page + direction;
    
    if (new_page < 0) {
        new_page = widget->total_pages - 1;
    } else if (new_page >= widget->total_pages) {
        new_page = 0;
    }
    
    if (new_page != widget->current_page) {
        for (int i = 0; i < BUTTONS_PER_PAGE; i++) {
            widget->buttons[widget->current_page][i].is_pressed = 0;
        }
        
        widget->current_page = new_page;
        widget->needs_redraw = 1;
    }
}

void cleanup_widget(Widget *widget) {
    XftColorFree(widget->display, widget->visual, widget->colormap, &widget->xft_text_color);
    XftColorFree(widget->display, widget->visual, widget->colormap, &widget->xft_active_text_color);
    XftColorFree(widget->display, widget->visual, widget->colormap, &widget->xft_icon_color);
    XftColorFree(widget->display, widget->visual, widget->colormap, &widget->xft_active_icon_color);
    XftColorFree(widget->display, widget->visual, widget->colormap, &widget->xft_page_color);
    XftColorFree(widget->display, widget->visual, widget->colormap, &widget->xft_page_active_color);
    XftFontClose(widget->display, widget->icon_font);
    XftFontClose(widget->display, widget->text_font);
    XftFontClose(widget->display, widget->page_font);
    XftDrawDestroy(widget->xft_draw);
    
    unsigned long pixels[] = {
        widget->bg_color.pixel, widget->text_color.pixel, widget->window_border_color.pixel, widget->border_color.pixel,
        widget->button_bg_color.pixel, widget->active_bg_color.pixel, 
        widget->active_text_color.pixel, widget->active_border_color.pixel,
        widget->pressed_bg_color.pixel, widget->page_color.pixel, widget->page_active_color.pixel
    };
    XFreeColors(widget->display, widget->colormap, pixels, 11, 0);
    
    XFreeGC(widget->display, widget->gc);
    XDestroyWindow(widget->display, widget->window);
    XCloseDisplay(widget->display);
}

int check_compositor(Display *display) {
    char prop_name[32];
    snprintf(prop_name, sizeof(prop_name), "_NET_WM_CM_S%d", DefaultScreen(display));
    Atom atom = XInternAtom(display, prop_name, False);
    return XGetSelectionOwner(display, atom) != None;
}

void set_window_opacity(Widget *widget, double opacity) {
    if (!widget->has_compositor) return;
    
    Atom atom = XInternAtom(widget->display, "_NET_WM_WINDOW_OPACITY", False);
    if (atom != None) {
        unsigned long opacity_value = (unsigned long)(opacity * 0xFFFFFFFF);
        XChangeProperty(widget->display, widget->window, atom, XA_CARDINAL, 32,
                       PropModeReplace, (unsigned char*)&opacity_value, 1);
    }
}

int main() {
    Widget widget;
    XEvent event;
    int has_focus = 0;
    
    init_widget(&widget);
    
    while (1) {
        // Process all pending X events first
        while (XPending(widget.display)) {
            XNextEvent(widget.display, &event);
            
            switch (event.type) {
                case Expose:
                    widget.needs_redraw = 1;
                    break;
                
                case EnterNotify:
                    has_focus = 1;
                    // Only grab focus when mouse actually enters
                    XSetInputFocus(widget.display, widget.window, RevertToPointerRoot, CurrentTime);
                    widget.needs_redraw = 1;
                    break;
                
                case LeaveNotify:
                    has_focus = 0;
                    // Explicitly release focus back to the root window or previous window
                    XSetInputFocus(widget.display, PointerRoot, RevertToPointerRoot, CurrentTime);
                    widget.needs_redraw = 1;
                    break;
                
                case FocusIn:
                    has_focus = 1;
                    break;
                
                case FocusOut:
                    has_focus = 0;
                    break;
                
                case MotionNotify: // CHANGED SECTION
                    // usleep(500000); // NEW LINE
                    // More precise focus handling based on exact mouse position
                    if (event.xmotion.x >= 0 && event.xmotion.x < WIDGET_WIDTH &&
                        event.xmotion.y >= 0 && event.xmotion.y < WIDGET_HEIGHT) {
                        if (!hovering) {
                            hovering = 1;
                            //hover_start = time(NULL);
                            gettimeofday(&hover_start, NULL);
                        }
                        struct timeval now;
                        gettimeofday(&now, NULL);
                        long diff = (now.tv_sec - hover_start.tv_sec) * 1000000 + (now.tv_usec - hover_start.tv_usec);
                        if (diff >= 2000000 && !has_focus) {
                            has_focus = 1;
                            XSetInputFocus(widget.display, widget.window, RevertToPointerRoot, CurrentTime);
                        }
                        //if (hovering && (time(NULL) - hover_start) >= 1) {
                        //    if (!has_focus) {
                        //        has_focus = 1;
                        //        XSetInputFocus(widget.display, widget.window, RevertToPointerRoot, CurrentTime);
                        //    }
                        //}
                    } else {
                        hovering = 0;
                        if (has_focus) {
                            has_focus = 0;
                            XSetInputFocus(widget.display, PointerRoot, RevertToPointerRoot, CurrentTime);
                        }
                    }
                    break; // END OF CHANGED SECTION
                    
                case ButtonPress:
                    // Only grab focus if we're actually clicking on the widget
                    if (event.xbutton.x >= 0 && event.xbutton.x < WIDGET_WIDTH &&
                        event.xbutton.y >= 0 && event.xbutton.y < WIDGET_HEIGHT) {
                        has_focus = 1;
                        XSetInputFocus(widget.display, widget.window, RevertToPointerRoot, CurrentTime);
                    }
                    
                    if (event.xbutton.button == Button1) {
                        int button_index = get_button_at_position(&widget, 
                                                                  event.xbutton.x, 
                                                                  event.xbutton.y);
                        if (button_index >= 0) {
                            widget.buttons[widget.current_page][button_index].is_pressed = 1;
                            widget.needs_redraw = 1;
                        }
                    }
                    // Scroll wheel support
                    else if (event.xbutton.button == Button4) { // Scroll up
                        change_page(&widget, -1);
                    }
                    else if (event.xbutton.button == Button5) { // Scroll down
                        change_page(&widget, 1);
                    }
                    break;
                    
                case ButtonRelease:
                    if (event.xbutton.button == Button1) {
                        int button_index = get_button_at_position(&widget, 
                                                                  event.xbutton.x, 
                                                                  event.xbutton.y);
                        for (int i = 0; i < BUTTONS_PER_PAGE; i++) {
                            widget.buttons[widget.current_page][i].is_pressed = 0;
                        }
                        
                        if (button_index >= 0) {
                            toggle_button(&widget, button_index);
                        }
                        widget.needs_redraw = 1;
                    }
                    break;
                
                case KeyPress: {
                    if (!has_focus) break;
                    
                    KeySym keysym = XLookupKeysym(&event.xkey, 0);
                    
                    if (SCROLL_DIRECTION) {
                        switch (keysym) {
                            case XK_Left:
                            case XK_a:
                            case XK_h:
                                change_page(&widget, -1);
                                break;
                            case XK_Right:
                            case XK_d:
                            case XK_l:
                                change_page(&widget, 1);
                                break;
                        }
                    } else {
                        switch (keysym) {
                            case XK_Up:
                            case XK_w:
                            case XK_k:
                                change_page(&widget, -1);
                                break;
                            case XK_Down:
                            case XK_s:
                            case XK_j:
                                change_page(&widget, 1);
                                break;
                        }
                    }
                    
                    switch (keysym) {
                        case XK_Page_Up:
                            change_page(&widget, -1);
                            break;
                        case XK_Page_Down:
                            change_page(&widget, 1);
                            break;
                        case XK_Home:
                            if (widget.current_page != 0) {
                                widget.current_page = 0;
                                widget.needs_redraw = 1;
                            }
                            break;
                        case XK_End:
                            if (widget.current_page != widget.total_pages - 1) {
                                widget.current_page = widget.total_pages - 1;
                                widget.needs_redraw = 1;
                            }
                            break;
                        case XK_Escape:
                            if (widget.is_visible) {
                                start_close_animation(&widget);
                            }
                            break;
                        case XK_1:
                        case XK_2:
                        case XK_3:
                        case XK_4:
                        case XK_5:
                        case XK_6:
                        case XK_7:
                        case XK_8:
                        case XK_9: {
                            int page_num = keysym - XK_1;
                            if (page_num < widget.total_pages && page_num != widget.current_page) {
                                widget.current_page = page_num;
                                widget.needs_redraw = 1;
                            }
                            break;
                        }
                    }
                    break;
                }
                    
                case ConfigureNotify:
                    if (widget.is_visible && !widget.is_closing) {
                        XMoveWindow(widget.display, widget.window, widget.current_x,
                                   (widget.screen_height - WIDGET_HEIGHT) / 2);
                    }
                    break;
            }
        }
        
        // Handle animation
        if (widget.is_animating) {
            animate_widget(&widget);
            if (widget.is_visible || widget.is_animating) {
                draw_widget(&widget);
            }
            usleep(ANIMATION_SLEEP_MS * 1000); // 16ms for ~60fps animation
            continue;
        }
        
        // Check mouse position only when not animating
        int mouse_in_zone = check_mouse_in_hover_zone(&widget);
        int mouse_over_widget = check_mouse_over_widget(&widget);
        
        if (mouse_in_zone && !widget.is_visible && !widget.is_closing) {
            start_show_animation(&widget);
        } else if (!mouse_in_zone && !mouse_over_widget && widget.is_visible && !widget.is_closing) {
            widget.mouse_in_zone = 0;
            // Release focus when hiding the widget
            if (has_focus) {
                has_focus = 0;
                XSetInputFocus(widget.display, PointerRoot, RevertToPointerRoot, CurrentTime);
            }
            start_close_animation(&widget);
        }
        
        // Draw if needed
        if (widget.is_visible && widget.needs_redraw) {
            draw_widget(&widget);
        }
        
        // Sleep longer when idle to achieve 0% CPU usage
        usleep(IDLE_SLEEP_MS * 1000); // 50ms when idle
    }
    
    cleanup_widget(&widget);
    return 0;
}
