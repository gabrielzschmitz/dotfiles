#         .             .              .		  
#         |             |              |           .	  
# ,-. ,-. |-. ,-. . ,-. |  ,_, ,-. ,-. |-. ,-,-. . |- ,_, 
# | | ,-| | | |   | |-' |   /  `-. |   | | | | | | |   /  
# `-| `-^ ^-' '   ' `-' `' '"' `-' `-' ' ' ' ' ' ' `' '"' 
#  ,|							  
#  `'							  
# GITHUB:https://github.com/gabrielzschmitz		  
# INSTAGRAM:https://www.instagram.com/gabrielz.schmitz/   
# DOTFILES:https://github.com/gabrielzschmitz/dotfiles/   
#!bin/sh

# Usage:
# `$0`: Ask for recording type via dmenu
# `$0 screencast`: Record both audio and screen
# `$0 video`: Record only screen
# `$0 audio`: Record only audio
# `$0 kill`: Kill existing recording
#
# If there is already a running instance, user will be prompted to end it.

killrecording() {
	recpid="$(cat /tmp/recordingpid)"
	# kill with SIGTERM, allowing finishing touches.
	kill -15 "$recpid"
	rm -f /tmp/recordingpid
	exit
	}

screencast() { \
	ffmpeg -y \
	-f x11grab \
	-framerate 30 \
	-s "$(xdpyinfo | awk '/dimensions/ {print $2;}')" \
	-i "$DISPLAY" \
	-f pulse -i default \
 	-c:v libx264 -qp 0 -r 30 -c:a flac \
	"$HOME/vid/screencast-$(date '+%y%m%d-%H%M-%S').mkv" &
	echo $! > /tmp/recordingpid
       	}

video() { ffmpeg \
	-f x11grab \
	-s "$(xdpyinfo | awk '/dimensions/ {print $2;}')" \
	-i "$DISPLAY" \
 	-c:v libx264 -qp 0 -r 30 \
	"$HOME/vid/video-$(date '+%y%m%d-%H%M-%S').mkv" &
	echo $! > /tmp/recordingpid
	}

webcamhidef() { ffmpeg \
	-f v4l2 \
	-i /dev/video0 \
	-video_size 1920x1080 \
	"$HOME/vid/webcam-$(date '+%y%m%d-%H%M-%S').mkv" &
	echo $! > /tmp/recordingpid
	}

webcam() { ffmpeg \
	-f v4l2 \
	-i /dev/video0 \
	-video_size 640x480 \
	"$HOME/vid/webcam-$(date '+%y%m%d-%H%M-%S').mkv" &
	echo $! > /tmp/recordingpid
	}


audio() { \
	ffmpeg \
	-f pulse -i default \
	-c:a flac \
	"$HOME/vid/audio-$(date '+%y%m%d-%H%M-%S').flac" &
	echo $! > /tmp/recordingpid
	}

askrecording() { \
	choice=$(printf "screencast\\nvideo\\nvideo selected\\naudio\\nwebcam\\nwebcam (hi-def)" | dmenu -p "Select recording style:")
	case "$choice" in
		screencast) screencast;;
		audio) audio;;
		video) video;;
		*selected) videoselected;;
		webcam) webcam;;
		"webcam (hi-def)") webcamhidef;;
	esac
	}

asktoend() { \
	response=$(printf "No\\nYes" | dmenu -p "Recording still active. End recording?") &&
	[ "$response" = "Yes" ] &&  killrecording
	}

videoselected()
{
	slop -f "%x %y %w %h" > /tmp/slop
	read -r X Y W H < /tmp/slop
	rm /tmp/slop

	ffmpeg \
	-f x11grab \
	-framerate 30 \
	-video_size "$W"x"$H" \
	-i :0.0+"$X,$Y" \
	-c:v libx264 -qp 0 -r 30 \
	"$HOME/vid/box-$(date '+%y%m%d-%H%M-%S').mkv" &
	echo $! > /tmp/recordingpid
}

case "$1" in
	screencast) screencast;;
	audio) audio;;
	video) video;;
	*selected) videoselected;;
	kill) killrecording;;
	*) ([ -f /tmp/recordingpid ] && asktoend && exit) || askrecording;;
esac
