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

# define user settings
NAME_LEFT="$(xrandr | grep connected | grep -v VIRTUAL | sed 's/ .*//' | head -n 1)"
NAME_RIGHT="$(xrandr | grep connected | grep -v VIRTUAL | sed 's/ .*//' | tail -n 1)"

# define vars
LEFT="$(xrandr | grep $NAME_LEFT | awk '{print $1}' | tail -n 1)"
RIGHT="$(xrandr | grep $NAME_RIGHT | awk '{print $1}' | tail -n 1)"

ARG="$(echo "$1" | sed s:-::g)" # argument to execute
VAR="${2,,}" # set screen monitor resolution to display

NUM_SCREENS="$(xrandr | grep -c connected -w)"

[[ "$@" = *--force* ]] &&
force=true

# define functions

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
    if [[ "$VAR" = off ]]; then
        # turn first monitor off
        xrandr --output "$OUTPUT" --off
    elif [[ "$VAR" = "" || "$VAR" = on || "$VAR" = auto ]]; then
        # change to automatic resolution
        xrandr --output "$OUTPUT" --auto
    elif [[ "$VAR" != "" ]]; then
        # change to custom resolution
        xrandr --output "$OUTPUT" --mode "$VAR"; fi; }

function set_dual {
    # change screen positions
    if [[ "$VAR" != "" ]]; then
        xrandr --output "$RIGHT" --mode "$VAR" --right-of "$LEFT" --mode "$VAR"
    else # set automatically
        xrandr --output "$RIGHT" --auto --right-of "$LEFT"; fi; }

function set_clone {
    # change screen positions
    if [[ "$VAR" != "" ]]; then
        xrandr --output "$RIGHT" --mode "$VAR" --output "$LEFT" --scale-from "$VAR"
    else # set automatically
        xrandr --output "$RIGHT" --auto --output "$LEFT" --auto; fi; }

function force_add {
    # add custom mode to screen (requires cvt)
    XRES="$(echo $VAR | cut -f1 -d'x')"
    YRES="$(echo $VAR | cut -f2 -d'x')"
    REFR="$(echo $VAR | cut -f3 -d'x')"
    [[ "$REFR" = "" ]] && REFR=60
    echo "Setting $OUTPUT to ${XRES}x${YRES}x${REFR}..."
    MODE="$(cvt $XRES $YRES $REFR | tail -n 1 | sed 's/Modeline //' | tr -d \")"
    VAR="$(echo $MODE | cut -f1 -d' ')"
    xrandr --rmmode $customres 2>/dev/null
    xrandr --delmode $OUTPUT $VAR 2>/dev/null
    (xrandr --newmode $MODE) 2>/dev/null
    (xrandr --addmode $OUTPUT $VAR) 2>/dev/null; }

# execute

case "$ARG" in

    internal)
        OUTPUT="$LEFT"
        ALTPUT="$RIGHT"
        [[ $force = true ]] && force_add
        set_res
        ;;

    external)
        OUTPUT="$RIGHT"
        ALTPUT="$LEFT"
        [[ $force = true ]] && force_add
        set_res
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
