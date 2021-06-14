zerofetch
==========

A rewrite of [neofetch](https://github.com/dylanaraps/neofetch) in C.
Currently only supports Linux and Xorg.


Why use zerofetch over neofetch?
-----------------------------------------
One major reason is the performance improvement. For example: neofetch finishes running after about 222 milliseconds where as zerofetch can finish running in a blazing fast 3 milliseconds.

Note: this testing occured on only 1 computer, it's not a good representation on the performance benefit you may gain.


Example output:

![example output](example.png)

Dependencies
------------

Paleofetch requires `libX11` and `libpci`. If you're running Xorg you should already have
the former. On Arch Linux, you should have `libpci` already installed if you have `pciutils`
installed. On other linux distrobutions, you may need to install libpci seperatley
if its not already present.

Compiling
---------

    make install

Usage
-----

After compiling, make this alias in your bashrc:

    alias zerofetch='./zerofetch'
    

Configuration
-------------

Paleofetch is configured by editing `config.h` and recompiling.
You can change your logo by including the appropriate header file in the logos directory.
The color with which zero fetch draws the logo can be chosen by defining the `COLOR` macro,
look up ANSI escape codes for information on customizing this.

The last configuration is the `CONFIG` macro, which controls what information zerofetch
prints. Each entry in this macro should look like

    { "NAME: ",   getter_function, false }, \
    
Take note of the trailing comma and backslash. The first piece, `"NAME: "`, sets
what zerofetch prints before printing the information; this usually tells you what
bit of information is being shown. Note that the name entry should be unique for entries
which are to be cached. The second piece, `getter_function`, sets
which function zerofetch will call display. Current available getter functions are

* `get_title`: prints `host@user` like in a bash prompt. Host and user will be printed in color.
* `get_bar`: Meant to be added after `get_title`, underlines the title
* `get_os`: Prints your operating system (including distrobution)
* `get_host`: Prints the model of computer
* `get_kernel`: Prints the version of the linux kernel
* `get_uptime`: Shows how long linux has been running
* `get_shell`: Shows which shell you are using
* `get_resolution`: Prints your screen resolution
* `get_terminal`: Prints the name of your current terminal
* `get_cpu`: Prints the name of your CPU, number of cores, and maximum frequency
* `get_colors1`, `get_colors2`: Prints the colors of your terminal

To include a blank line between entries, put `SPACER \` between the two lines
you want to separate.

The booleans in `CONFIG` tell zerofetch whether you want to cache an entry.
When cached, zerofetch will save the value and not recompute it whenever you run zerofetch
(unless you specify the `--recache` option).

The CPU and GPU name can be configured as well. This is done under the CPU_CONFIG and GPU_CONFIG section
in the config.h file. Two macros are provided to customize and tidy up the model names:

* `REMOVE(string)`: removes the first occurence of `string`
* `REPLACE(string1, string2)`: replaces the first occurence of `string1` with `string2`

Don't forget to run zerofetch with the --recache flag after compiling it with your new
configuration, otherwise it will still show the old name for already cached entries.

