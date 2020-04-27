#!/usr/bin/env bash
#
# Simple script to interact with xrandr
# and set displays and screen solutions.
#
# usage: xswitch {option} [resolution] [--invert] [--force]
# options:
#   --auto/on   turn on screen monitors
#   --internal  internal computer screen only
#   --external  external screen only (e.g. HDMI)
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
RES="${2,,}" # set screen monitor resolution to display

NUM_SCREENS="$(xrandr | grep -c connected -w)"

[[ "$@" = *--invert* ]] &&
RIGHT="$(xrandr | grep $NAME_LEFT | awk '{print $1}' | tail -n 1)" &&
LEFT="$(xrandr | grep $NAME_RIGHT | awk '{print $1}' | tail -n 1)"

[[ "$@" = *--force* ]] &&
force=true

[[ "$RES" = on || "$RES" = auto || "$RES" = "--invert" || "$RES" = "--force" ]] &&
RES=""

# define functions
function help {
    head -n 13 "$0" | tail -n 8 | sed 's/# //'; }

function set_auto {
    # reset both screens
    OUTPUT="$LEFT" && set_res
    OUTPUT="$RIGHT" && set_res
    [[ "$NUM_SCREENS" = 2 ]] && set_dual; }

function set_internal {
    # internal computer screen
    OUTPUT="$LEFT" && set_res
    [[ "$NUM_SCREENS" = 2 && "$RES" = "" ]] && xrandr --output "$RIGHT" --off; }

function set_external {
    # change external e.g. HDMI
    OUTPUT="$RIGHT" && set_res
    [[ "$NUM_SCREENS" = 2 && "$RES" = "" ]] && xrandr --output "$LEFT" --off; }

function set_dual {
    OUTPUT="$RIGHT" && set_res
    # change screen positions
    if [[ "$RES" != "" ]]; then
        xrandr --output "$RIGHT" --auto --transform none --right-of "$LEFT" --mode "$RES"
    else # set automatically
        xrandr --output "$RIGHT" --auto --transform none --right-of "$LEFT"; fi; }

function set_clone {
    OUTPUT="$RIGHT" && set_res
    # change screen positions
    if [[ "$RES" != "" ]]; then
        xrandr --output "$RIGHT" --auto --transform none --same-as "$LEFT" --scale-from "$RES"
    else # set automatically
        RES="$(xrandr | grep '*' | head -n 1 | cut -d' ' -f4)"
        xrandr --output "$RIGHT" --auto --transform none --same-as "$LEFT" --scale-from "$RES"; fi; }

function set_res {
    if [[ "$RES" = off ]]; then
        # turn screen monitor off
        xrandr --output "$OUTPUT" --off
    elif [[ "$RES" != "" ]]; then
        # change screen mode
        [[ $force = true ]] && force_add
        xrandr --output "$OUTPUT" --mode "$RES"
    else # reset to default mode
        xrandr --output "$OUTPUT" --transform none --auto; fi; }

function set_off {
    # turn both monitors off
    xrandr --output "$LEFT" --off --output "$RIGHT" --off; }

function force_add {
    # add custom mode to screen (requires cvt)
    XRES="$(echo $RES | cut -f1 -d'x')"
    YRES="$(echo $RES | cut -f2 -d'x')"
    REFR="$(echo $RES | cut -f3 -d'x')"
    [[ "$REFR" = "" ]] && REFR=60
    echo "Setting $OUTPUT to ${XRES}x${YRES}x${REFR}..."
    MODE="$(cvt $XRES $YRES $REFR | tail -n 1 | sed 's/Modeline //' | tr -d \")"
    RES="$(echo $MODE | cut -f1 -d' ')"
    xrandr --delmode $OUTPUT $RES 2>/dev/null
    xrandr --rmmode $RES 2>/dev/null
    (xrandr --newmode $MODE) 2>/dev/null
    (xrandr --addmode $OUTPUT $RES) 2>/dev/null; }

# execute

case "$ARG" in

    internal)
        set_internal
        ;;

    external)
        set_external
        ;;

    auto|on)
        set_auto
        ;;

    dual)
        set_dual
        ;;

    clone)
        set_clone
        ;;

    off)
        set_off
        ;;

    *) # default
        help
        ;;

esac # finishes
