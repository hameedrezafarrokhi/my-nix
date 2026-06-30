{ config, lib, pkgs, mypkgs, utils, inputs, ... }:

{ config = lib.mkIf (config.my.software.tools.enable) {

  environment.systemPackages =

  (utils.removePackagesByName ( with pkgs; [

    better-control   usbguard

    libnotify

    zenity

    tuxedo

    onboard                       ##Onscreen keyboard

   #(flameshot.override {
   #   enableWlrSupport = true;
   #   enableMonochromeIcon = true;
   #})
   #ksnip                         ##Screenshots
   #gradia                        ##Screenshots

    kdePackages.kruler            ##KDE ruler

    xcalc
   #xclock
    oclock
    gsimplecal

    units

   #crow-translate                ##Translation
   #dialect                       ##Translation

   #ulauncher                     ##Keyboard Launcher
   #albert                        ##Keyboard Launcher

   #kdePackages.kunitconversion   ##KDE unit converter krunner plugin
   #convertall                    ##Unit converter
   #valuta                        ##Currency converter

   #clairvoyant                   ##Ask the 8ball!
   #chance                        ##Roll the dice!

    eyedropper                    ##Colorpicker

   #gnome-characters              ##Gnome emojis
   #gnome-decoder                 ##QR code reader
    gnome-clocks                  ##Gnome clock app
    gnome-calendar                ##Gnome calendar
   #gnome-weather                 ##Gnome weather
   #gnome-maps                    ##Gnome maps

   #mousam                        ##Persian Weather
   #kdePackages.kweather          ##KDE weather

   #keypunch                      ##Train keyboard

    kdePackages.ktimer            ##Task Timer KDE
    kdePackages.kalarm
    kshutdown
   #kdePackages.kcron
    peaclock                       ##CLI Clock and Task Timer utils

   #dxvk
   #dxvk_2
   #vulkan-tools
   #libva-utils
   #clinfo
   #vdpauinfo
   #driversi686Linux.vdpauinfo

   #libgbm

   #######################################################################

   # UNCATEGORIZED

   #xeyes                    ##Detect wich apps use wayland
    wayland-logout

    # Astronomy
   #kstars
   #celestia
   #astroterm

   #devtoolbox
   #emblem
   #blesh

   #quickshell

    wallust
    awww

    tokei

    gpu-screen-recorder-gtk
    matugen
   #fltk

   #feishin
   #CuboCore.coretime

    bullshit
    (fortune.override { withOffensive = true; })


    wmctrl
   #flashfocus   # WARNING BROKEN

   #showmethekey

    busybox

   #ueberzug

    sl
   #asciiquarium
    asciiquarium-transparent
    unimatrix

    hollywood

    bucklespring

    go
    cargo-all-features

    toml2nix
    yaml2nix
    dconf2nix
    dos2unix
    json2yaml
    yaml2json
    toml2json


    xsct

    sticky-notes
    sticky
    xpad

    libxkbcommon

   #xosd
    xosd-xft


  ] ) config.my.software.tools.exclude)

   ++

  config.my.software.tools.include

   ++

  [

   #mypkgs.old-stable.stack2nix
    mypkgs.stable.ulauncher
    mypkgs.stable.flashfocus
   #mypkgs.stable.CuboCore.coretime

    (pkgs.writeShellScriptBin "color-image" ''
      ffmpeg -f lavfi -i color=c=#$1:s=1920x1080:d=1 -frames:v 1 $1.png
    '')

    (pkgs.writeShellScriptBin "peaclock-widget" ''
      ${config.my.default.terminal} --name peaclock --class peaclock sh -c 'peaclock --config-dir ~/.config/peaclock'
    '')

  ]

   #++ [(pkgs.callPackage ../myPackages/avvie.nix { })]
    ++ [(pkgs.callPackage ../myPackages/vboard.nix { })]
    ++ [(pkgs.callPackage ../myPackages/timeswitch.nix { })]
   #++ [(pkgs.callPackage ../myPackages/picom-ft.nix { })]
    ++ [(pkgs.callPackage ../myPackages/xsession-manager.nix { })]
    ++ [(pkgs.callPackage ../myPackages/paperview-rs.nix { })]

    ++ [(pkgs.callPackage ../myPackages/xvisbell3.nix { })]
    ++ [(pkgs.callPackage ../myPackages/xvisbell2.nix { })]
    ++ [(pkgs.callPackage ../myPackages/xvisbell.nix { })]

    ++ [(pkgs.callPackage ../myPackages/glimmer.nix { })]

    ++ [(pkgs.callPackage ../myPackages/barrette.nix { })]

    ++ [(pkgs.callPackage ../myPackages/led.nix { })]

   #++ [(pkgs.callPackage ../myPackages/gulp.nix { })]  # WARNING BORKEN (procps package is not found during build)

    ++ [(pkgs.callPackage ../myPackages/xmulberry.nix { })]

    ++ [(pkgs.callPackage ../myPackages/pod.nix { })]

    ++ [(pkgs.callPackage ../myPackages/clearine.nix { })]

    ++ [(pkgs.callPackage ../myPackages/nyancat.nix { })]

    ++ [(pkgs.callPackage ../myPackages/x11_shake_to_magnify_cursor.nix { })]

    ++ [(pkgs.callPackage ../myPackages/jiggle.nix { })]

   #++ [(pkgs.callPackage ../myPackages/woven.nix { })]
    ++ [(pkgs.callPackage ../myPackages/woven-bin.nix { })]

   #++ [(pkgs.callPackage ../myPackages/goto.nix { })]

   #++ [(pkgs.callPackage ../myPackages/choyce.nix { })]

    ++ [(pkgs.callPackage ../myPackages/gopowerd.nix { })]


   ++ [(pkgs.callPackage ../myPackages/pets/xpet-with-config.nix { })]
   ++ [(pkgs.callPackage ../myPackages/pets/petpepe.nix { })]
   ++ [(pkgs.callPackage ../myPackages/pets/Konqi-Pet.nix { })]
   ++ [(pkgs.callPackage ../myPackages/pets/catai.nix { })]
   ++ [(pkgs.callPackage ../myPackages/pets/tux-assistant.nix { })] # WARNING BROKEN not working
  #++ [(pkgs.callPackage ../myPackages/pets/bongocat-rs.nix { })]
   ++ [(pkgs.callPackage ../myPackages/pets/openpets.nix { })]
  #++ [(pkgs.callPackage ../myPackages/pets/windowpet.nix { })]
  #++ [(pkgs.callPackage ../myPackages/pets/bongocat.nix { })]
   ++ [(pkgs.callPackage ../myPackages/pets/bongocat-py.nix { })]
   ++ [(pkgs.callPackage ../myPackages/pets/desktop-pets.nix { })]
   ++ [(pkgs.callPackage ../myPackages/pets/desktop-pet-manager.nix { })]
   ++ [(pkgs.callPackage ../myPackages/pets/gif-desktop-manager.nix { })]
   ++ [(pkgs.callPackage ../myPackages/pets/nekopet.nix { })]

   ++ [(pkgs.callPackage ../myPackages/xidle.nix { })]
   ++ [(pkgs.callPackage ../myPackages/xobvol.nix { })]
   ++ [(pkgs.callPackage ../myPackages/xobbright.nix { })]

  #++ [(pkgs.callPackage ../myPackages/gloom.nix { })]
  #++ [(pkgs.callPackage ../myPackages/xdimmer.nix { })]
   ++ [(pkgs.callPackage ../myPackages/xsct_gui.nix { })]
   ++ [(pkgs.callPackage ../myPackages/cdim.nix { })]

   ++ [(pkgs.callPackage ../myPackages/timebomb.nix { })]

   ++ [(pkgs.callPackage ../myPackages/traymd.nix { })]

   ++ [(pkgs.callPackage ../myPackages/archynotch.nix { })]

  #++ [(mypkgs."_25-05".callPackage ../myPackages/loom.nix { })]

  #++ [(pkgs.callPackage ../myPackages/boomer.nix { })]
   ++ [(pkgs.callPackage ../myPackages/boomer-bin.nix { })]
  #++ [(pkgs.callPackage ../myPackages/zoomer.nix { })]
   ++ [(pkgs.callPackage ../myPackages/zoomer2.nix { })]
  #++ [(pkgs.callPackage ../myPackages/boomer-rs.nix { })]
  #++ [(pkgs.callPackage ../myPackages/mul.nix { })]

  #++ [(pkgs.callPackage ../myPackages/zstatus.nix { })]

   ++ [(pkgs.callPackage ../myPackages/ximaging.nix { })]
   ++ [(pkgs.callPackage ../myPackages/xfile.nix { })]
   ++ [(pkgs.callPackage ../myPackages/xfind.nix { })]
   ++ [(pkgs.callPackage ../myPackages/xmdialog.nix { })]
   ++ [(pkgs.callPackage ../myPackages/xpickrgb.nix { })]

  #++ [(pkgs.callPackage ../myPackages/polo.nix { })]  # Needs Gee 0.8 package
  #++ [(pkgs.callPackage ../myPackages/file-commander.nix { })]
   ++ [(pkgs.callPackage ../myPackages/file-commander-appimage.nix { })]

   ++ [(pkgs.callPackage ../myPackages/xclimsg.nix { })]

  #++ [(pkgs.callPackage ../myPackages/anima-linux.nix { })]

   ++ [(pkgs.callPackage ../myPackages/x11-idle-sync.nix { })]

   ++ [(pkgs.callPackage ../myPackages/xosdbar.nix { })]

   ++ [(pkgs.callPackage ../myPackages/fancylock.nix { })]

   ++ [(pkgs.callPackage ../myPackages/vtsh.nix { })]

  #++ [(pkgs.callPackage ../myPackages/xmms.nix { })]

   ++ [(pkgs.callPackage ../myPackages/zentile.nix { })]
   ++ [(pkgs.callPackage ../myPackages/pytyle3.nix { })]

   ++ [(pkgs.callPackage ../myPackages/edex-ui.nix { })]
   ++ [(pkgs.callPackage ../myPackages/musializer.nix { })]
   ++ [(pkgs.callPackage ../myPackages/zen-browser.nix { })]
   ++ [(pkgs.callPackage ../myPackages/xplorer.nix { })]

   ++ [(pkgs.callPackage ../myPackages/chasm/bare.nix { })]
   ++ [(pkgs.callPackage ../myPackages/chasm/bolt.nix { })]
   ++ [(pkgs.callPackage ../myPackages/chasm/chasm-bits.nix { })]
   ++ [(pkgs.callPackage ../myPackages/chasm/glass.nix { })]
   ++ [(pkgs.callPackage ../myPackages/chasm/glyph.nix { })]
   ++ [(pkgs.callPackage ../myPackages/chasm/show.nix { })]
   ++ [(pkgs.callPackage ../myPackages/chasm/spot.nix { })]
  #++ [(pkgs.callPackage ../myPackages/chasm/tile.nix { })]


   ++ [(pkgs.callPackage ../myPackages/leif.nix { })]
  #++ [(pkgs.callPackage ../myPackages/lyssa.nix { leif = pkgs.callPackage ../myPackages/leif.nix { }; })]
   ++ [(pkgs.callPackage ../myPackages/boron.nix { leif = pkgs.callPackage ../myPackages/leif.nix { }; })]
   ++ [(pkgs.callPackage ../myPackages/ticalc.nix {
         leif = pkgs.callPackage ../myPackages/leif.nix { };
         conf = ''
#pragma once

// Theming
#define MAIN_COL (LfColor){182, 211, 224, 255}
#define MAIN_TEXT_COL LF_BLACK
#define EXPR_TEXT_COL (LfColor){100, 100, 100, 255}
#define PANEL_COLOR lf_color_brightness(MAIN_COL, 1.5f)
#define BTN_COLOR lf_color_brightness(MAIN_COL, 1.6f)
#define BTN_PADDING 20.0f

// Aspects
#define WIN_INIT_W 400
#define WIN_INIT_H 600

#define PANEL_H s.winh / 4.0f

// Buffers
#define EXPR_BUF_SIZE 64
#define HIST_MAX 512

// Font declarationpercisio
#define FONT "ComicMono.ttf"
#define FONT_DIR "/home/hrf/.local/share/fonts/comic-mono/fonts/"

// Feature flags
#define AUTO_CLIPBOARD_RESULT true // Automatically copies the last result to the clipboard

// Results
#define RESULT_PRECISION "%.3f"

// Icons of the operation buttons (in order)
static const char* buttonicons[20] = {
  "%", "C",  "CE", "/",
  "7", "8",  "9",  "*",
  "4", "5",  "6",  "-",
  "1", "2",  "3",  "+",
  " ", "0",  ".",  "="
};

// Enumarion of actions of buttons (in order)
typedef enum {
  OP_PERCENT, OP_CLEAR, OP_CLEAR_ENTRIES, OP_DIVIDE,
  OP_7,       OP_8,     OP_9,             OP_MUTIPLY,
  OP_4,       OP_5,     OP_6,             OP_MINUS,
  OP_1,       OP_2,     OP_3,             OP_PLUS,
  OP_NONE,    OP_0,     OP_DOT,           OP_EQUALS
} btn_operation;

// Mapping from operations to shortcut keys (chars)
typedef enum {
  PLUS = '+',
  MINUS = '-',
  MULTIPLY = '*',
  DIVIDE = '/',
  DOT = '.',
} operation_shortcut;

// Key Strokes (Shortcuts)
#define SHORTCUT_EVAL           GLFW_KEY_ENTER
#define SHORTCUT_CLEAR          GLFW_KEY_B
#define SHORTCUT_CLEAR_ENTRIES  GLFW_KEY_S
#define SHORTCUT_COPY_RESULT    GLFW_KEY_C
#define SHORTCUT_PERCENT        GLFW_KEY_P
#define SHORTCUT_HIST_UP        GLFW_KEY_UP
#define SHORTCUT_HIST_DOWN      GLFW_KEY_DOWN
         '';
      })]

   #++ [(pkgs.callPackage ../myPackages/ax-shell.nix { inherit inputs; })]
   #++ [(pkgs.callPackage ../myPackages/ax-shell-2.nix { })]
   #++ [(pkgs.callPackage ../myPackages/fabric.nix { })]
   #++ [(pkgs.callPackage ../myPackages/fabric-cli.nix { })]
   #++ [(pkgs.callPackage ../myPackages/gray.nix { })]
   #++ [(pkgs.callPackage ../myPackages/run-widget.nix { })]

   ++ [(pkgs.callPackage ../myPackages/bars/bipolarbar.nix {
          conf = ''
            /* config.h for bipolarbar.c */
            #ifndef CONFIG_H
            #define CONFIG_H

            #define TOP_BAR 0        // 0=Bar at top, 1=Bar at bottom
            #define BAR_HEIGHT 18
            #define BAR_WIDTH 0      // 0=Full width or use num pixels
            // If font isn't found "fixed" will be used
            // #define FONT "-*-terminusmod.icons-medium-r-*-*-12-*-*-*-*-*-*-*,-*-stlarch-medium-r-*-*-12-*-*-*-*-*-*-*"
            #define FONT "-misc-fixed-medium-r-*-*-12-*-*-*-*-*-*-*"
            #define FONTS_ERROR 1      // 0 to have missing fonts error shown
            // colours are for background and the text
            #define colour0 "#001020"  // &0 Default Background colour
            #define colour1 "#ffffff"   // &1 Default foreground colour
            #define colour2 "#002030"  // &2
            #define colour3 "#665522"
            #define colour4 "#898900"
            #define colour5 "#776644"
            #define colour6 "#887733"
            #define colour7 "#998866"
            #define colour8 "#999999"
            #define colour9 "#000055"  // &9

            #endif
          '';
   })]

   ++ [(pkgs.callPackage ../myPackages/bars/some_sorta_bar.nix {
          conf = ''
            /* some_sorta_bar.c
            *
            *  This program is free software: you can redistribute it and/or modify
            *  it under the terms of the GNU General Public License as published by
            *  the Free Software Foundation, either version 2 of the License, or
            *  (at your option) any later version.
            *
            *  This program is distributed in the hope that it will be useful,
            *  but WITHOUT ANY WARRANTY; without even the implied warranty of
            *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
            *  GNU General Public License for more details.
            *
            *  You should have received a copy of the GNU General Public License
            *  along with this program.  If not, see <http://www.gnu.org/licenses/>.
            *
            */

            #include <X11/Xlib.h>
            #include <X11/Xutil.h>
            #include <X11/Xatom.h>
            #include <X11/Xlocale.h>

            #include <stdio.h>
            #include <stdlib.h>
            #include <locale.h>
            #include <string.h>
            #include <signal.h>
            #include <sys/select.h>
            #include <sys/time.h>
            #include <unistd.h>

            /* ***************** DEFINES ******************* */
            #define TOP_BAR 1        // 0=Bar at top, 1=Bar at bottom
            #define BAR_HEIGHT 16
            #define BAR_WIDTH 0      // 0=Full width or use num pixels
            #define BAR_CENTER 0     // 0=Screen center or pos/neg to move right/left
            // If font isn't found "fixed" will be used
            #define FONT "-*-terminusmod.icons-medium-r-*-*-12-*-*-*-*-*-*-*,-*-stlarch-medium-r-*-*-12-*-*-*-*-*-*-*"
            #define FONTS_ERROR 1      // 0 to have missing fonts error shown
            // colours are background then eight for the text
            #define colour0 "#003040"  // Background colour. The rest colour the text
            #define colour1 "#ffffff"  // &1
            #define colour2 "#004050"  // &2
            #define colour3 "#005060"
            #define colour4 "#006070"
            #define colour5 "#664422"
            #define colour6 "#aaaa00"
            #define colour7 "#bbbbbb"
            #define colour8 "#997755"
            #define colour9 "#00dd99"  // &9

            typedef struct {
                unsigned long color;
                GC gc;
            } Theme;
            static Theme theme[10];

            typedef struct {
                XFontStruct *font;          /* font structure */
                XFontSet fontset;           /* fontset structure */
                int height;                 /* height of the font */
                int width;
                unsigned int fh;            /* Y coordinate to draw characters */
                unsigned int ascent;
                unsigned int descent;
            } Iammanyfonts;

            static void get_font();
            static void print_text();
            static int wc_size(char *string, int num);

            static const char *defaultcolor[] = { colour0, colour1, colour2, colour3, colour4, colour5, colour6, colour7, colour8, colour9, };
            static const char *font_list = FONT;

            static unsigned int count, j, k, bg, text_length, c_length;
            static char output[256] = {"Some_Sorta_Bar "};

            static Display *dis;
            static unsigned int sw, sh;
            static unsigned int height, width;
            static unsigned int screen;
            static Window root, barwin;
            static Drawable winbar;

            static Iammanyfonts font;

            void get_font() {
            	char *def, **missing;
            	int i, n;

            	missing = NULL;
            	if(strlen(font_list) > 0)
            	    font.fontset = XCreateFontSet(dis, (char *)font_list, &missing, &n, &def);
            	if(missing) {
            		if(FONTS_ERROR < 1)
                        while(n--)
                            fprintf(stderr, ":: SSB :: missing fontset: %s\n", missing[n]);
            		XFreeStringList(missing);
            	}
            	if(font.fontset) {
            		XFontStruct **xfonts;
            		char **font_names;

            		font.ascent = font.descent = 0;
            		n = XFontsOfFontSet(font.fontset, &xfonts, &font_names);
            		for(i = 0, font.ascent = 0, font.descent = 0; i < n; i++) {
            			if (font.ascent < (*xfonts)->ascent) font.ascent = (*xfonts)->ascent;
                        if (font.descent < (*xfonts)->descent) font.descent = (*xfonts)->descent;
            			xfonts++;
            		}
            		font.width = XmbTextEscapement(font.fontset, " ", 1);
            	} else {
            		fprintf(stderr, ":: SSB :: Font '%s' Not Found\n:: SSB :: Trying Font 'Fixed'\n", font_list);
            		if(!(font.font = XLoadQueryFont(dis, font_list))
            		&& !(font.font = XLoadQueryFont(dis, "fixed")))
            			fprintf(stderr, ":: SSB :: Error, cannot load font: '%s'\n", font_list);
            		font.ascent = font.font->ascent;
            		font.descent = font.font->descent;
            		font.width = XTextWidth(font.font, " ", 1);
            	}
            	font.height = font.ascent + font.descent;
            }

            void update_output(int nc) {
                j=1; text_length = 0; count = 0;
                unsigned int n;
                int bc = BAR_CENTER;
                ssize_t num;
                char win_name[256];

                for(k=0;k<257;k++)
                    output[k] = '\0';
                if(nc < 1) {
                    if(!(num = read(STDIN_FILENO, output, sizeof(output)))) {
                        fprintf(stderr, "SSB :: FAILED TO READ STDIN!!\n");
                        strncpy(output, "FAILED TO READ STDIN!!", 24);
                    }
                }
                text_length = strlen(output);
                XFillRectangle(dis, winbar, theme[0].gc, 0, 0, width, height);
                for(k=0;k<width;k++) {
                    if(count <= text_length) {
                        if(output[count] == '\n' || output[count] == '\r') {
                            count += 1;
                        }
                        if(output[count] == '&' && output[count+1] == 'L') count +=2;
                        if(output[count] == '&' && (output[count+1] == 'C' || output[count+1] == 'R')) {
                            count += 2; c_length=0;
                            for(n=count;n<=text_length;n++) {
                                if(output[n] == '&' && output[n+1] == 'R') break;
                                while(output[n] == '&') {
                                    if(output[n+1]-'0' < 10 && output[n+1]-'0' >= 0) n += 2;
                                    if(output[n+1] == 'B' && output[n+2]-'0' < 10 && output[n+2]-'0' >= 0)
                                        n += 3;
                                }
                                if(output[n] == '\n' || output[n] == '\r') {
                                    c_length--;
                                    break;
                                }
                                win_name[c_length] = output[n];
                                c_length++;
                            }
                            win_name[c_length] = '\0';
                            c_length = wc_size(win_name, c_length);
                            if(output[count-1] == 'C')
                                k = (width/2 - c_length/2)+bc;
                            if(output[count-1] == 'R')
                                k = width-c_length;
                        }
                        print_text();
                    }
                }
                XCopyArea(dis, winbar, barwin, theme[1].gc, 0, 0, width, height, 0, 0);
                XSync(dis, False);
                return;
            }

            int wc_size(char *string, int num) {
                XRectangle rect;

                if(font.fontset) {
                    XmbTextExtents(font.fontset, string, num, NULL, &rect);
                    return rect.width;
                } else {
                    return XTextWidth(font.font, string, num);
                }
            }

            void print_text() {
                char astring[256];
                unsigned int wsize, n=0;

                while(output[count] == '&') {
                    if((output[count+1] == 'L') || (output[count+1] == 'C') || (output[count+1] == 'R')) {
                        count--;
                        break;
                    } else if(output[count+1]-'0' < 10 && output[count+1]-'0' >= 0) {
                        j = output[count+1]-'0';
                        count += 2;
                    } else if(output[count+1] == 'B' && output[count+2]-'0' < 10 && output[count+2]-'0' >= 0) {
                        bg = output[count+2]-'0';
                        count += 3;
                    } else break;
                }
                if(output[count] == '&') {
                    astring[n] = output[count];
                    n++;count++;
                }
                while(output[count] != '&' && output[count] != '\0' && output[count] != '\n' && output[count] != '\r') {
                    astring[n] = output[count];
                    n++;count++;
                }
                if(n < 1) return;
                astring[n] = '\0';
                wsize = wc_size(astring, n);
                XFillRectangle(dis, winbar, theme[bg].gc, k, 0, wsize, height);
                if((k+wsize) > width) {
                    k = width;
                    return;
                }
                if(font.fontset)
                    XmbDrawString(dis, winbar, font.fontset, theme[j].gc, k, font.fh, astring, n);
                else
                    XDrawString(dis, winbar, theme[j].gc, k, font.fh, astring, n);
                k += wsize-1;
                for(wsize=0;wsize<n;wsize++)
                    astring[n] = '\0';
            }

            unsigned long getcolor(const char* color) {
                XColor c;
                Colormap map = DefaultColormap(dis,screen);

                if(!XAllocNamedColor(dis,map,color,&c,&c)) {
                    fprintf(stderr, "\033[0;31mSSB :: Error parsing color!");
                    return 1;
                }
                return c.pixel;
            }

            int main(int argc, char ** argv){
                unsigned int i, y = 0;
                XEvent ev;
                XSetWindowAttributes attr;
            	char *loc;
            	fd_set readfds;
                struct timeval tv;

                dis = XOpenDisplay(NULL);
                if (!dis) {fprintf(stderr, "SSB :: unable to connect to display");return 7;}

                root = DefaultRootWindow(dis);
                screen = DefaultScreen(dis);
                sw = XDisplayWidth(dis,screen);
                sh = XDisplayHeight(dis,screen);
                loc = setlocale(LC_ALL, "");
                if (!loc || !strcmp(loc, "C") || !strcmp(loc, "POSIX") || !XSupportsLocale())
                    fprintf(stderr, "SSB :: LOCALE FAILED\n");
                get_font();
                height = (BAR_HEIGHT > font.height) ? BAR_HEIGHT : font.height+2;
                font.fh = ((height - font.height)/2) + font.ascent;
                width = (BAR_WIDTH == 0) ? sw : BAR_WIDTH;
                if (TOP_BAR != 0) y = sh - height;

                for(i=0;i<10;i++)
                    theme[i].color = getcolor(defaultcolor[i]);
                XGCValues values;

                for(i=0;i<10;i++) {
                    values.foreground = theme[i].color;
                    values.line_width = 2;
                    values.line_style = LineSolid;
                    if(font.fontset) {
                        theme[i].gc = XCreateGC(dis, root, GCForeground|GCLineWidth|GCLineStyle,&values);
                    } else {
                        values.font = font.font->fid;
                        theme[i].gc = XCreateGC(dis, root, GCForeground|GCLineWidth|GCLineStyle|GCFont,&values);
                    }
                }

                winbar = XCreatePixmap(dis, root, width, height, DefaultDepth(dis, screen));
                XFillRectangle(dis, winbar, theme[0].gc, 0, 0, width, height);
                barwin = XCreateSimpleWindow(dis, root, 0, y, width, height, 0, theme[0].color,theme[0].color);
                attr.override_redirect = True;
                XChangeWindowAttributes(dis, barwin, CWOverrideRedirect, &attr);
                XSelectInput(dis,barwin,ExposureMask);
                XMapWindow(dis, barwin);
                int x11_fd = ConnectionNumber(dis);
                while(1){
                   	FD_ZERO(&readfds);
                    FD_SET(x11_fd, &readfds);
                    FD_SET(STDIN_FILENO, &readfds);
                    tv.tv_sec = 0;
                    tv.tv_usec = 200000;
                    select(x11_fd+1, &readfds, NULL, NULL, &tv);

                	if (FD_ISSET(STDIN_FILENO, &readfds))
                	    update_output(0);
                    while(XPending(dis) != 0) {
                        XNextEvent(dis, &ev);
                        switch(ev.type){
                            case Expose:
                                XCopyArea(dis, winbar, barwin, theme[1].gc, 0, 0, width, height, 0, 0);
                                XSync(dis, False);
                                break;
                        }
                    }
                }

                return (0);
            }

          '';
   })]

   ++ [(pkgs.callPackage ../myPackages/pets/xpet.nix {
          conf = ''
#pragma once

#include <X11/Xutil.h>

#include "xpet.h"

#define PET_ASSET_DIR   "/run/current-system/sw/share/xpet/pets/dog"

#define PET_SPEED       20      /* pixels per frame - constant movement speed               */
#define PET_REFRESH     200     /* ms between movement updates (16ms=60fps)                 */
#define FRAME_DURATION  200     /* ms between frames (can be overridden per frame)          */
#define UNFREEZE_DELAY  2000    /* ms before pet walks again after unfreezing               */

#define WANDER_MIN_WAIT 16000   /* min ms to wait at destination                            */
#define WANDER_MAX_WAIT 32000   /* max ms to wait at destination                            */
#define WANDER_MARGIN   100     /* pixels from screen edge                                  */

#define SLEEP_DELAY     5000    /* ms frozen before falling asleep                          */
#define HAPPY_DURATION  3000    /* ms to stay happy after being clicked                     */
#define SPEECH_DURATION 3000    /* ms to show speech bubble                                 */

/* speech bubble sizing */
#define SPEECH_PAD_X    8
#define SPEECH_PAD_Y    6
#define SPEECH_MIN_W    24
#define SPEECH_MIN_H    16

/* speech phrases */
const char* pet_phrases[] = {
	"Lorem ipsum dolor sit amet, consectetur adipiscing elit...",
	NULL  /* sentinel, do not remove */
};

struct bind bindings[] = {
	{.sym = XK_f, .mask = Mod1Mask}, /* call/chase toggle */
	{.sym = XK_s, .mask = Mod1Mask}, /* freeze toggle */
	{.sym = XK_q, .mask = Mod1Mask}, /* quit */
};

struct animation animations[] = {
	[HAPPY]    = { .name = "happy",     .n_frames = 6, .loop = True, .frames = NULL, .frame_durations = NULL },
	[SLEEPING] = { .name = "sleeping",  .n_frames = 6, .loop = True, .frames = NULL, .frame_durations = NULL},
	[IDLE]     = { .name = "idle",      .n_frames = 6, .loop = True, .frames = NULL, .frame_durations = NULL },
	[DRAGGED]  = { .name = "dragged",   .n_frames = 6, .loop = True, .frames = NULL, .frame_durations = NULL },

	[N]  = { .name = "walk_north",      .n_frames = 2, .loop = True, .frames = NULL, .frame_durations = NULL },
	[S]  = { .name = "walk_south",      .n_frames = 2, .loop = True, .frames = NULL, .frame_durations = NULL },
	[E]  = { .name = "walk_east",       .n_frames = 2, .loop = True, .frames = NULL, .frame_durations = NULL },
	[W]  = { .name = "walk_west",       .n_frames = 2, .loop = True, .frames = NULL, .frame_durations = NULL },
	[NW] = { .name = "walk_northwest",  .n_frames = 2, .loop = True, .frames = NULL, .frame_durations = NULL },
	[NE] = { .name = "walk_northeast",  .n_frames = 2, .loop = True, .frames = NULL, .frame_durations = NULL },
	[SW] = { .name = "walk_southwest",  .n_frames = 2, .loop = True, .frames = NULL, .frame_durations = NULL },
	[SE] = { .name = "walk_southeast",  .n_frames = 2, .loop = True, .frames = NULL, .frame_durations = NULL },
};


          '';
   })]

  ;

  programs = {

    java = {      #For Minecraft
      enable = true;
      binfmt = true;
     #package = pkgs.jdk;
    };

  };

};}
