xrandr_switch
---

Simple bash script to interact with ```xrandr``` and set display and screen solutions.

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

### Current limitations

* Since this depends on ```xrandr``` (X/RandR), no Wayland for now.
