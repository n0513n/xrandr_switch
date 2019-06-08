#!/usr/bin/env bash
#
# Simple script to interact with xrandr
# and set displays and screen solutions.
#
# usage: xswitch {option} [mode] [--force]
# options:
#   --auto/on   turn on screen monitors
#   --internal  internal computer screen only
#   --external  external screen only (HDMI)
#   --dual      dual head (twin view)
#   --clone     mirror both screens 
#   --off       disable screens (!)

# define user settings #

NAME_LEFT="$(xrandr | grep connected | grep -v VIRTUAL | sed 's/ .*//' | head -n 1)"
NAME_RIGHT="$(xrandr | grep connected | grep -v VIRTUAL | sed 's/ .*//' | tail -n 1)"

# define vars #

LEFT="$(xrandr | grep $NAME_LEFT | awk '{print $1}' | tail -n 1)"
RIGHT="$(xrandr | grep $NAME_RIGHT | awk '{print $1}' | tail -n 1)"

ARG="$(echo "$1" | sed s:-::g)" # argument to execute
VAR="${2,,}" # set screen monitor custom resolution
OPT="${3,,}" # set optional arg or other screen res

NUM_SCREENS="$(xrandr | grep -c connected -w)"

[[ "$VAR" = "-f" || "$OPT" = "-f" ]] &&
force=true

[[ "$VAR" = "-f" ]] &&
VAR="$OPT"

# define functions #

function help {
    head -n 13 "$0" | tail -n 8 | sed 's/# //'; }

function set_auto {
    if [[ "$NUM_SCREENS" = 2 ]]; then
        set_dual
    else # reset both screens
        OUTPUT="$LEFT"; set_res
        OUTPUT="$RIGHT"; set_res; fi; }

function set_off {
    # turn both monitors off
    xrandr --output $LEFT --off --output $RIGHT --off; }

function set_res {
    if [[ "$VAR" = off && "$OPT" = off ]]; then
        # turn both monitors off
        set_off
    elif [[ "$VAR" = off ]]; then
        # turn this monitor off
        xrandr --output $OUTPUT --off
    elif [[ "$OPT" = off ]]; then
        # turn other monitor off
        xrandr --output $OUTPUT --mode "$VAR" --output "$ALTPUT" --off
    elif [[ "$VAR" = "" || "$VAR" = on || "$VAR" = auto ]]; then
        # change to automatic resolution
        xrandr --output $OUTPUT --auto
    elif [[ "$VAR" != "" ]]; then
        # change to custom resolution
        xrandr --output $OUTPUT --mode "$VAR"; fi; }

function set_dual {
    # change screen positions
    if [[ "$VAR" != "" ]]; then
        xrandr --auto --output "$RIGHT" --mode "$VAR" --right-of "$LEFT" --mode "$VAR"
    else # set automatically
        xrandr --auto --output "$RIGHT" --auto --right-of "$LEFT"; fi; }

function force_res {
    # add custom resolution to xrandr available modes
    # examples taken from "cvrt"
    if [[ "$VAR" = "1920x1080_60.00" ]]; then
        xrandr --newmode "1920x1080_60.00" 173.00 1920 2048 2248 2576 1080 1083 1088 1120 -hsync +vsync &&
        xrandr --addmode $OUTPUT "1920x1080_60.00" && echo "Mode 1920x1080_60.00 added."
    elif [[ "$VAR" = "1600x900_60.00" ]]; then
        xrandr --newmode "1600x900_60.00"  118.25  1600 1696 1856 2112  900 903 908 934 -hsync +vsync &&
        xrandr --addmode $OUTPUT "1600x900_60.00" && echo "Mode 1600x900_60.00 added."
    elif [[ "$VAR" = "1280x720_60.00" ]]; then
        xrandr --newmode "1280x720_60.00"  74.50  1280 1344 1472 1664  720 723 728 748 -hsync +vsync &&
        xrandr --addmode $OUTPUT "1280x720_60.00" && echo "Mode 1280x720_60.00 added."
    elif [[ "$VAR" = "1024x768_60.00" ]]; then
        xrandr --newmode "1024x768_60.00"   63.50  1024 1072 1176 1328  768 771 775 798 -hsync +vsync &&
        xrandr --addmode $OUTPUT "1024x768_60.00" && echo "Mode 1024x768_60.00 added."
    elif [[ "$VAR" = "800x600_60.00" ]]; then
        xrandr --newmode "800x600_60.00"   38.25  800 832 912 1024  600 603 607 624 -hsync +vsync &&
        xrandr --addmode $OUTPUT "800x600_60.00" && echo "Mode 800x600_60.00 added."; fi; }

# execute #

case "$ARG" in

    internal)
        [[ $force = true ]] && force_res
        OUTPUT="$LEFT"; ALTPUT="$RIGHT"; set_res
        ;;

    external)
        [[ $force = true ]] && force_res
        OUTPUT="$RIGHT"; ALTPUT="$LEFT"; set_res
        ;;

    dual)
        set_dual
        ;;

    clone)
        set_clone
        ;;

    auto|on)
        set_auto
        ;;

    off)
        set_off
        ;;

    *) # default
        help
        ;;

esac # finishes