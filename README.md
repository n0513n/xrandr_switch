xrandr_switch
---

Simple bash script to interact with `xrandr` and set display and screen solutions.

Allows `--force` parameter to add and set a custom resolution (requires `cvt`).

```
usage: xswitch {option} [mode] [--force]

options:
  --auto/on   turn on screen monitors
  --internal  internal computer screen only
  --external  external screen only (HDMI)
  --dual      dual head (twin view)
  --clone     mirror both screens
  --off       disable screens (!)
```

### Examples

Turn on all screen monitors on default resolution:

* `xswitch --auto`

Force custom 1152x648 resolution on internal screen monitor:

* `xswitch internal 1152x648 --force`

Twin view screen monitors using 1920x1080 external resolution:

* `xswitch dual 1920x1080`

Mirror both screen monitors using the same 1366x768 resolution:

* `xswitch clone 1366x768`

### Current limitations

Since this depends on `xrandr` (X/RandR), Wayland is unsupported.
