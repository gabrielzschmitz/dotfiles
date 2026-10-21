# st-terminal
Beautiful, elegant, super fast and functional terminal emulator

![Shot-2025-05-01-102324](https://github.com/user-attachments/assets/d4f322e2-405d-4111-a395-f469cd2ddc9f)

My build is based entirely on [St-Graphics](https://github.com/sergei-grechanik/st-graphics). Specifically, on the [graphics-with-patches](https://github.com/sergei-grechanik/st-graphics/tree/graphics-with-patches) branch.

Patches removed: Alpha, External pipe.

### Patches included in this setup

- [Kitty graphics protocol](https://github.com/sergei-grechanik/st-graphics) - Images in your terminal, just like kitty, just like a modern terminal emulator.
- [Boxdraw](https://st.suckless.org/patches/boxdraw)
- [xresources with signal reloading](https://st.suckless.org/patches/xresources-with-reload-signal/) - Configure st via Xresources and signal reloading.
- [Alpha](https://st.suckless.org/patches/alpha/) - allows users to change the opacity of the background.
- [Scrollback](https://st.suckless.org/patches/scrollback)
- [Wide glyph support](https://st.suckless.org/patches/glyph_wide_support/) - Fixes wide glyphs truncation
- [Ligatures](https://st.suckless.org/patches/ligatures) - Proper drawing of ligatures.
- [Appsync](https://st.suckless.org/patches/sync/) - Better draw timing to reduce flicker/tearing and improve animation smoothness.
- [Blinking cursor](https://st.suckless.org/patches/blinking_cursor/) - Allows the use of a blinking cursor.
- [Desktop entry](https://st.suckless.org/patches/desktopentry/) - This enables to find st in a graphical menu and to display it with a nice icon.
- [Drag n drop](https://st.suckless.org/patches/drag-n-drop/) - This patch adds [XDND Drag-and-Drop](https://www.freedesktop.org/wiki/Specifications/XDND/) support for st.
- [Dynamic cursor color](https://st.suckless.org/patches/dynamic-cursor-color/) - Swaps the colors of your cursor and the character you're currently on (much like alacritty).
- [Bold is not bright](https://st.suckless.org/patches/bold-is-not-bright/) - This patch makes bold text rendered simply as bold, leaving the color unaffected.
- [swap mouse](https://st.suckless.org/patches/swapmouse/) - This patch changes the mouse shape to the global default when the running program subscribes for mouse events, for instance, in programs like ranger, yazi and fzf.
- [Unfocused-cursor](https://st.suckless.org/patches/unfocused_cursor/) - Removes the outlined rectangle, making the cursor invisible when the window is unfocused.
- [AnyGeometry](https://st.suckless.org/patches/anygeometry/) - This patch allows you to set st's width and height as pixels instead of cells

### Patches and changes that are included in the graphics implementation

This fork includes some patches and features that are not graphics-related
per se, but are hard to disentangle from the graphics implementation:
- [Anysize](https://st.suckless.org/patches/anysize/) - this patch is applied
  and on by default. If you want the "expected" anysize behavior (no centering),
  set `anysize_halign` and `anysize_valign` to zero in `config.h`.
- Support for several XTWINOPS control sequences to query information that is
  sometimes required for image display (like cell size in pixels).
- Support for decoration (underline) color and style. The decoration color is
  used to specify the placement id in Unicode placeholders, so it's hard to make
  them separate. The behavior of the underline is different from the upstream
  st: it's drawn behind the text and the thickness depends on the font size. You
  may need to tweak the code in `xdrawglyphfontspecs` in `x.c` if you don't like
  it.

### Default Keybindings<br>

<pre>
(Zoom)
alt  + comma            Zoom in <br>
alt  + .                Zoom out <br>
alt  + g                Reset Zoom<br>
</pre>

### Installation

You may need these dependencies first.

```txt
# Void
xbps-install libXft-devel libX11-devel harfbuzz-devel libXext-devel libXrender-devel libXinerama-devel gd-devel

# Debian (and ubuntu probably)
apt install build-essential libxft-dev libharfbuzz-dev libgd-dev

# Nix
nix develop github:siduck/st

# Arch
pacman -S gd

# Fedora (or Red-Hat based)
dnf install gd-devel libXft-devel

# SUSE (or openSUSE)
zypper in -t pattern devel_basis
zypper in gd-devel libXft-devel harfbuzz-devel

# Install font-symbola and libXft-bgra
```

There are two ways to do this.

1. Via Pacman, adding my repository. (Arch Linux)

Open /etc/pacman.conf and add my repo at the end:

```ini
[gh0stzk-dotfiles]
SigLevel = Optional TrustAll
Server = http://gh0stzk.github.io/pkgs/x86_64
```
Update the repositories, `sudo pacman -Syy` and now you can install it with `sudo pacman -S st-gh0stzk`

2. Compiling yourself (all distros)

```bash
git clone https://github.com/gh0stzk/st-terminal.git
cd st-terminal
make

# or Install on your system directly

sudo make install
```
### Apply your own colorscheme and font.

By default, the terminal comes with the Catppuccin Mocha colorscheme and the JetBrainsMono Nerd Font font, but you can change it to your preferences:

```bash
# Copy the Xresources file from this repository, and paste it into your HOME or wherever you want
# Edit it to your liking
# Now reload the config.

xrdb -merge pathToXresourcesFile && killall -USR1 st
```

From [siduck](https://github.com/siduck/st) repo:

## Ram usage comparison with other terminals and speed test

<img src="https://raw.githubusercontent.com/siduck/dotfiles/all/rice%20flex/terminal_ramUsage.jpg"> <br><br>
<img src="https://raw.githubusercontent.com/siduck/dotfiles/all/rice%20flex/speedTest.png"> <br><br>
<img src="https://raw.githubusercontent.com/siduck/dotfiles/all/rice%20flex/speedTest1.png"> <br>

( note : This benchmark was done on my low-end machine which has a pentium cpu so the speed results might vary )
