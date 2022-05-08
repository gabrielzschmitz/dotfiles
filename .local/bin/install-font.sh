#!/bin/bash

set -e
set -o posix

ROOT_UID=0
OPTERR=1

loc_or_sysdir=/usr/local/share/groff  # make this default
version=current

trap interrupt SIGINT

shopt -s expand_aliases 

alias cp='cp -f'                      # -p flag for interactive
alias ln='ln -f'
alias mv='mv -f'

show_usage()
{
printf \
"Usage: install-font.sh [-lscpdD] \
[-C \033[4mdir\033[0m] \
[-F \033[4mfamily\033[0m] \
[-f \033[4mgroff fontname\033[0m] | +\033[4mSTYLE\033[0m] file ...\n\
Longer help: install-font.sh -H (pipe through 'less' or 'more')\n"
}

long_help()
{
  printf <<EOF \
"USAGE:

    install-font.sh [-hHlscpn] [-P \033[4mdir\033[0m] [-C \033[4mdir\033[0m] [-F \033[4mfamily\033[0m] \
[-f \033[4mgroff fontname\033[0m] file1 file2 ...

DESCRIPTION:

    A utility to make TrueType (.ttf), OpenType (.otf), and
    PostScript Type1 (.pfa, .pfb) fonts available for use with
    groff.

    With no options, for every file named on the command line,
    \033[4minstall-font\033[0m prompts for

      - a family name
      - a groff fontname
      - whether to make the font available to gropdf
      - whether to copy the input file(s) to a system-wide location

    \033[4minstall-font.sh\033[0m calls fontforge to convert TrueType and OpenType
    fonts to PostScript Type42 (.t42) and Type1 (.pfa), from which
    a groff font is generated.  The .t42 and groff fonts are moved
    to site-font/devps/ and registered in the 'download' file.  If
    the font is to be available to gropdf, the .pfa is moved to
    site-font/devpdf/ and registered in its 'download' file.  A
    symlink is made to the groff font in site-font/devps.

    PostScript fonts are converted to .pfa, even those with a .pfa
    extension.  The newly-generated .pfa has a filename derived from the
    font's PostScript name.  This is helpful in the case of fonts with
    cryptic names like 'bchri8a.pfa', which becomes 'CharterBT-Italic.pfa'.
    In all cases, the original file is preserved with its original
    name in the directory from which the font is being installed.
    
    The .pfa and groff fonts are moved to site-font/devps/ and
    registered in the 'download' file.  If the font is to be
    available to gropdf, symlinks are made in site-font/devpdf/ to
    both the .pfa and the groff font, and the .pfa is registered
    in /site-font/devpdf/download.

OPTIONS

    Options not requiring an argument may be grouped.

    -h  Short help.

    -H  Long help.

    -l  Assume prefix /usr/local/share/groff for all directories. (default)

    -s  Assume prefix /usr/share/groff for all directories.

    -P  \033[4mdir\033[0m
        Path to the top-level groff directory if groff has been
        installed in a non-default location.

    -c  Copy file(s) named on the command line to a system-accessible
        location.  If neither -s nor -C is given, copy to the family
        directory (see -F) under /usr/local/share/fonts/<fonttype>/,
        where <fonttype> is one of 'truetype', 'type1', or 'opentype'.
        If -s is given, copy to the family directory located under
        /usr/share/fonts/<fonttype>/.

        If neither -c nor -C is given, a prompt asks whether to copy
        the file(s) named on the command line.

    -n  Don't copy file(s) named on the command line to a system-accessible
        location.

    -d  Make font available to gropdf.

    -D  Do not make font available to gropdf.

    -p  Ask before overwriting or linking files.  Default is to
        overwrite without asking.

    -C  \033[4mdir\033[0m
        Copy file(s) named on the command line to the family directory
        (see -F) in \033[4mdir\033[0m.

    -F  \033[4mfamily\033[0m
        Family to which the font belongs.  Creates a family for the
        groff font, which can then be accessed by calls to .fam or
        .FAMILY (mom macros).  Also creates a family directory for
        fonts being made available system-wide (see -c and -C).

        -F is useful for batch processing fonts that belong to the
        same family.  Use with care, since all files named on the
        command line will be assigned to \033[4mfamily\033[0m.

        If -F is not given, a prompt asks for the family name.

    -f  \033[4mname\033[0m or +\033[4mSTYLE\033[0m 
        Name by which to access the font with calls to .ft or
        .FT (mom macros).  \033[4mname\033[0m may be arbitrary, or
        a '+' sign prefixed to an uppercase fontstyle recognized
        by groff, eg +R, +I, +B, +BI, which respectively stand for
        regular, italic, bold, and bold italic.  The mom macros
        provide additional styles, which may also be used.
        
        +\033[4mSTYLE\033[0m is affixed to the family name to arrive at the
        groff fontname.

            install-font -F Garamond -f +R <file>

        creates font GaramondR, which can be accessed by

            .fam Garamond
            .ft  R

        or

            .ft GaramondR
        
        -f is not compatible with batch processing.  \033[4minstall-font\033[0m
        will abort if the -f option is given and multiple files are
        named on the command line.

        If -f is not given, a prompt asks for the font name.
"
EOF
}

case $1 in
  -h | "")
    show_usage
    exit 0
  ;;
  -H)
    long_help
    exit 0
  ;;
esac

# if fontforge not installed, no point going any further

type fontforge > /dev/null 2>&1 || { 
  printf "fontforge not installed. Aborting.\n" >&2
  exit 1
}

tmp_dir=/tmp/install-font

[ -d ${tmp_dir} ] || mkdir ${tmp_dir}

clean_tmp()
{
  for i in ${tmp_dir}/*[!pe] ; do rm -f "$i" ; done         # everything but .pe
  for i in ${tmp_dir}/* ; do [ -L "$i" ] && rm "$i" ; done  # symlinks
}

interrupt()
{
  clean_tmp
  printf "\nAborting.\n"
  exit 130
}

error()
{
  case "$1" in
    no_filename)
      printf \
"[install-font]: Missing filename.  \
Aborting.\n" >&2
      exit 1
    ;;
    no_file)
      printf \
"[install-font]: File \"${file}\" not found.  \
Aborting.\n" >&2
      exit 1
    ;;
    no_arg)
      printf \
"[install-font]: Option \"-${option}\" requires an argument.  \
Aborting.\n" >&2 
      show_usage
      exit 1
    ;;
    filename_arg)
      printf \
"[install-font]: Option \"-${option}\" requires a non-filename argument.  \
Aborting.\n" >&2 
      show_usage
      exit 1
    ;;
    no_dir)
      printf \
"[install-font]: Directory \"${copy_dir}\" not found.  \
Aborting.\n" >&2
      exit 1
    ;;
    not_dir)
      printf \
"[install-font]: \"${OPTARG}\" not a directory.  \
Aborting.\n" >&2
      exit 1
    ;;
    not_writable)
      printf \
"[install-font]: \"${OPTARG}\" is not writable.  \
Aborting.\n" >&2
      exit 1
    ;;
    incompatible)
      printf \
"[install-font]: Incompatible file type. Must have extension ttf|pfa|pfb|otf.  \
Aborting.\n" >&2
      exit 1
    ;;
    arg_to_f)
      printf \
"[install-font]: Option -${option} incompatible with multiple filenames.  \
Aborting.\n" >&2
      exit 1
  esac
}

generate_t42()
{
cat <<EOF  > ${tmp_dir}/generate-t42.pe
# generate-t42.pe
                                                                                             
Open(\$1);
Generate(\$fontname + ".pfa");
Generate(\$fontname + ".t42");
EOF
}

generate_pfa()
{
cat <<EOF  > ${tmp_dir}/generate-pfa.pe
# generate-pfa.pe
                                                                                             
Open(\$1);
Generate(\$fontname + ".pfa");
EOF
}

convert_font()
{
  printf "Running fontforge...\n"

  fontforge -script ${script} "`basename "${file}"`"

  printf "Done.\n"
}

make_font()
{
  printf "Creating \033[33m${groff_font}\033[0m...\n"

  if [ "${is_italic}" ] ; then
    afmtodit_opts="-e text.enc -i50"
  else
    afmtodit_opts="-e text.enc -i0 -m"
  fi

  afmtodit ${afmtodit_opts} ${font}.afm textmap ${groff_font}

  unset afmtodit_opts
  rm ${font}.afm

  printf "Done.\n"
}

install_to_devps()
{
  printf \
"Installing \033[33m${groff_font}\033[0m in ${site_font_devps}/... "

  mv ${font}.${ext} ${site_font_devps}/
  mv ${groff_font} ${site_font_devps}/
  chmod 644 ${site_font_devps}/${font}.${ext}
  chmod 644 ${site_font_devps}/${groff_font}

  # update the download file in site-font/devps
  [ -e ${site_font_devps}/download ] || {
    touch ${site_font_devps}/download && chmod 755 ${site_font_devps}/download
  }

  [ $argc -eq 1 ] && {
    cp ${site_font_devps}/download ${site_font_devps}/download.bak
  }

  printf "${font}\t${font}.${ext}\n" >> ${site_font_devps}/download

  printf "Done.\n"
}

install_to_devpdf()
{
  if [ ${install_in_devpdf} ] ; then
    gropdf=yes
  else
    printf \
"Make \033[33m${groff_font}\033[0m available to gropdf? (y/n; default = y) "
    read gropdf
  fi

  case $gropdf in
    Y | y | YES | Yes | yes | "")
      printf "Checking for gropdf executable and devpdf directory... "
      have_gropdf=`type gropdf`

      if [ "$have_gropdf" ] ; then
        printf \
"gropdf found.\nInstalling \033[33m${groff_font}\033[0m in ${site_font_devpdf}/... "

        case ${ext} in
          t42)
            mv ${font}.pfa ${site_font_devpdf}/
            chmod 644 ${site_font_devpdf}/${font}.pfa
          ;;
          pfa)
            ln -s ${site_font_devps}/${font}.pfa ${site_font_devpdf}/${font}.pfa
          ;;
        esac

        ln -s ${site_font_devps}/${groff_font} ${site_font_devpdf}/${groff_font}

        [ -e ${site_font_devpdf}/download ] || {
          touch ${site_font_devpdf}/download && chmod 755 ${site_font_devpdf}/download
        }

        [ $argc -eq 1 ] && {
          cp -f ${site_font_devpdf}/download ${site_font_devpdf}/download.bak
        }

        printf "\t${font}\t${font}.pfa\n" >> ${site_font_devpdf}/download
        
        printf "Done.\n"
      else
        printf \
"gropdf not found.\nNo fonts will be installed in ${site_font_devpdf}.\n"
      fi ;;
  esac
}

get_fontname()
{
  printf \
"Enter +STYLE (eg +R, +I, +B, +BI), or a unique groff name for \
\033[36m${font}\033[0m.\n"
  printf \
"Leave blank to set name to '\033[36m${font}\033[0m': "
}

convert_install()
{
  cd ${tmp_dir}
  convert_font                    # generate t42/pfa and afm files

  # get postscript family and font name from afm
  family_name=`grep "^FamilyName" *afm | \
    sed -e 's/^FamilyName *\([[:graph:]]\{1,\}\) *[[:print:]]*$/\1/'`
  font=`grep "^FontName" *afm | \
    sed -e 's/^FontName *\([[:graph:]]\{1,\}\) *[[:print:]]*$/\1/'`
  is_italic=`grep -i "^FullName .*italic" *afm | sed -e 's/.*\([Ii]talic\)/\1/'`

  if [ ! ${family} ] ; then       # get user's name for family
    printf "Family name (default = ${family_name}): "
    read family
    [ ${family} ] || family=${family_name}
  fi

  printf \
"  =>\033[36m${font}\033[0m (${file}) assigned to family \
'\033[33m${family}\033[0m'.\n"

  if [ ! ${groff_font} ] ; then   # get groff fontname
    if [ ! ${append_style} ] ; then
      get_fontname
      read groff_font
      [ ${groff_font} ] || groff_font=${font}
      append_style=${groff_font:0:1}
      [ "$append_style" = "+" ] && {
        append_style=${groff_font##*+}
        groff_font=${family}${append_style}
      }
    else
      groff_font=${family}${append_style}
    fi
  fi

  printf \
"  =>\033[36m${font}\033[0m assigned groff fontname \
'\033[33m${groff_font}\033[0m'.\n"

# make links to textmap and text.enc if not already present in tmp_dir
  if [ ! -e textmap ] ; then
    [ -e ${devps}/generate/textmap ] && ln -s ${devps}/generate/textmap . || {
      printf "'textmap' not found.  Aborting.\n" >&2 ; exit 1
    }
  fi
  if [ ! -e text.enc ] ; then
    [ -e ${devps}/text.enc ] && ln -s ${devps}/text.enc . || {
      printf "'text.enc' not found.  Aborting.\n" >&2 ; exit 1
    }
  fi

  make_font
  install_to_devps

  [ ${skip_devpdf} ] || install_to_devpdf

  rm -f ${font}*
  cd - &>/dev/null
}

copy_file()
{
  [ -d ${copy_dir} ] || { 
    echo "${copy_dir} not found; creating." 
    mkdir ${copy_dir} 
    chmod 755 ${copy_dir} ; 
  }
  [ -d ${copy_dir}/${family} ] || {
    mkdir ${copy_dir}/${family}
    chmod 755 ${copy_dir}/${family}
  }
  printf "Installing ${file} in ${copy_dir}/${family}/... "
  cp "${file}" ${copy_dir}/${family}/
  chmod 644 ${copy_dir}/${family}/"${file}"
  printf "Done.\n"
}

print_sep()
{
  printf \
"======================================================================\n"
}

# getopts doesn't check if OPTARG is a flag, or a filename when some
# other value is expected

check_optarg()
{
  [ "${OPTARG:0:1}" = "-" ] && error no_arg # is an opt when arg to opt expected

  eval "has_ext=`echo ${OPTARG} | sed -e 's/^[[:graph:]]*\.[[:graph:]]*$/./'`"

  [ "${has_ext}" = "." ] && error filename_arg # is a filename when filename not expected
  :
}

check_optarg_dir()
{
  [ "${OPTARG:0:1}" = "-" ] && error no_arg # is an opt when arg to opt expected

  [ ! -d "${OPTARG}" ] && error not_dir

  [ ! -w "${OPTARG}" ] && error not_writable
  :
}

while getopts ":C:cndDF:f:hHlpP:s" opt
do
  case "$opt" in
    c)
      copy_orig=yes
    ;;
    C)
      option=C
      check_optarg
      copy_orig=yes
      copy_dir=${OPTARG}
      [ -d ${copy_dir} ] || error no_dir
    ;;
    n)
      dont_copy=yes
    ;;
    d)
      install_in_devpdf=yes 
    ;;
    D)
      skip_devpdf=yes
    ;;
    F)
      option=F
      check_optarg
      family=${OPTARG}
    ;;
    f)
      option=f
      opt_f=true
      check_optarg
      append_style=${OPTARG:0:1}
      case ${append_style} in
        "+")
          append_style=${OPTARG##*+}
        ;;
        *)
          groff_font=${OPTARG}
        ;;
      esac
    ;;
    h)
      show_usage
      exit 0
    ;;
    H)
      long_help
      exit 0
    ;;
    l)
      loc_or_sysdir=/usr/local/share/groff
    ;;
    P)
      option=P
      check_optarg_dir
      loc_or_sysdir=${OPTARG}
    ;;
    p)
      alias mv='mv -i'
      alias ln='ln -i'
      alias cp='cp -i'
    ;;
    s)
      loc_or_sysdir=/usr/share/groff
    ;;
    \?)
      printf "Option \"-${OPTARG}\" not valid. Aborting.\n" >&2 
      show_usage
      exit 1
    ;;
    :)
      printf "Option \"-${OPTARG}\" requires an argument. Aborting.\n" >&2
      show_usage
      exit 1
    ;;
  esac
done

shift $((OPTIND-1))

[ "$#" -eq 0 ] && error no_filename

[ $# -gt 1 -a "${opt_f}" ] && {
  error arg_to_f
  exit 1
}

if [ ! -w "$loc_or_sysdir" ] ; then
  # need write access to $loc_or_sysdir

  scriptname=`basename $0`
  printf \
"You don't have write access to ${loc_or_sysdir}
Superuser priviledges required.\nRerun as \
'\033[33msudo ${scriptname} \033[4margs\033[0m' \
or \
'\033[33msu root -c \"${scriptname} \033[4margs\033[0m\033[33m\"\033[0m'\n"
  exit 126
fi

devps=${loc_or_sysdir}/${version}/font/devps
devpdf=${loc_or_sysdir}/${version}/font/devpdf
site_font_devps=${loc_or_sysdir}/site-font/devps
site_font_devpdf=${loc_or_sysdir}/site-font/devpdf

# create site-font and site-font/devps and site-font/devpdf
# if not present

[ -d ${loc_or_sysdir}/site-font ] || { 
  printf "${loc_or_sysdir}/site-font not found; creating.\n" 
  mkdir ${loc_or_sysdir}/site-font 
  chmod 755 ${loc_or_sysdir}/site-font 
}

[ -d ${site_font_devps} ] || { 
  printf "${site_font_devps} not found; creating.\n" 
  mkdir ${site_font_devps} 
  chmod 755 ${site_font_devps} 
}

[ -d ${site_font_devpdf} ] || { 
  printf "${site_font_devpdf} not found; creating.\n" 
  mkdir ${site_font_devpdf} 
  chmod 755 ${site_font_devpdf} 
}

# process files

for i in "$@" ; do

  file="$i"
  argc=$((argc+1))

  [ -f "${file}" ] || error no_file

  case ${file##*.} in
    TTF | ttf | PFB | pfb | PFA | pfa | OTF | otf)
      font_type=${file##*.}
    ;;
    *)
      error incompatible
    ;;
  esac

  ln -s "$PWD/${file}" "${tmp_dir}/`basename "${file}"`"      # make a link in tmp dir to file

  [ $argc -gt 1 ] && print_sep

  printf "Processing \033[36m$file\033[0m...\n"

  case ${font_type} in
    TTF | ttf | OTF | otf)
      script=generate-t42.pe
      ext=t42

      [ -e /tmp/$script ] || generate_t42   # create if it doesn't exist

      convert_install

      if [ "${font_type}" = "TTF" -o "${font_type}" = "ttf" ] ; then
        [ ${copy_dir} ] || copy_dir=/usr/local/share/fonts/truetype
      else
        [ ${copy_dir} ] || copy_dir=/usr/local/share/fonts/opentype
      fi
    ;;
    PFB | pfb | PFA | pfa)
      script=generate-pfa.pe
      ext=pfa

      [ -e /tmp/$script ] || generate_pfa   # create if it doesn't exist

      convert_install

      [ ${copy_dir} ] || copy_dir=/usr/local/share/fonts/type1
    ;;
  esac

# copy input file to a system or named directory

  if [ ! "$dont_copy" ] ; then
    if [ ! "$copy_orig" ] ; then
      printf \
        "Copy \033[36m${file}\033[0m to ${copy_dir}/${family}/\n  (y/n; default = n) "
      read copy_file

      case "$copy_file" in
        Y | y | YES | Yes | yes)
          copy_file
        ;;
        * )
          printf \
  "Install \033[36m${file}\033[0m manually to make it available system-wide.\n"
        ;;
      esac
    else
      copy_file
    fi
  fi
  unset append_style
  unset ext
  unset font
  unset groff_font
  unset is_italic

done

clean_tmp

exit 0
