# Creating a Wifi Pager with an Adafruit MagTag

This project was started because push notifications on iOS were proving unreliable in delivery when at sea.
I wanted more control over the software and hardware so I could actually receive timely warning notifications.

## Current State

It works! Ok, mostly.
The scad file makes a workable but bulky case with hard to press TPU buttons.
Software will mostly work but probably hit edge cases and crash/hang.

## Software

### Compatibility

Tested and compatible with CircuitPython 10.x (specifically CircuitPython 10.2.1 on Adafruit MagTag ESP32-S2).

### Installation

1. Copy the following project files and folders to the root of your `CIRCUITPY` drive:
   - `main.py` — main application entry point and hardware event loop
   - `dashboard_state.py` — pure-logic alert parsing, duration math, and state classification
   - `config.py` — configuration for warning/critical duration thresholds and critical alert lists
   - `bmps/` — graphical assets
   - `fonts/` — custom fonts for e-ink display
2. Set up your secrets:
   - Copy `secrets.py.template` to `secrets.py`
   - Fill in your WiFi network SSIDs, passwords, and Grafana endpoints
   - Copy `secrets.py` to the root of your `CIRCUITPY` drive
3. Configure alert thresholds (optional):
   - In `config.py`, customize:
     - `WARNING_MINUTES` (default 5): duration before a `no_data` alert escalates to Alert
     - `CRITICAL_MINUTES` (default 30): duration before an `alerting` alert escalates to Critical
     - `ALWAYS_CRITICAL_ALERTS`: list of alert names that immediately escalate to Critical when alerting
4. Install libraries to `CIRCUITPY/lib/`:
   - **Recommended (automatic via circup):**
     Ensure your MagTag is connected via USB, then run:
     ```bash
     circup --path /media/$USER/CIRCUITPY install --auto
     ```
     To keep all existing libraries on the device up to date with CircuitPython 10:
     ```bash
     circup --path /media/$USER/CIRCUITPY update
     ```
   - **Manual copy:**
     Copy the `lib/` directory from this repository (or from the official Adafruit CircuitPython 10.x Library Bundle) to `CIRCUITPY/lib/`. The required libraries are:
     - `adafruit_magtag/`
     - `adafruit_portalbase/`
     - `adafruit_requests.mpy`
     - `adafruit_ntp.mpy`
     - `adafruit_debouncer.mpy`
     - `adafruit_display_text/`
     - `adafruit_bitmap_font/`
     - `adafruit_pixelbuf.mpy`
     - `neopixel.mpy`
     - `simpleio.mpy`
     - `adafruit_ticks.mpy`

### Development & Off-Device Testing

The alert parsing and categorization logic lives in `dashboard_state.py` without any microcontroller hardware dependencies. You can run the unit test suite locally on your computer:

```bash
.venv/bin/pytest tests/test_dashboard_state.py -v
```

## Hardware

And by this, for now, I mean the 3d printed case.
At this point I don't think I'll include STL files, as I'm sure they'll change.
Get [OpenSCAD](https://openscad.org) and open the `magtag-case.scad` file.
Hit the F5 key or go to the menu 'Design' > 'Preview'.
This should give you a quick preview of all objects.
There will be weird clipping artifacts, ignore them for now.

The file is arranged into a bunch of variables defining real world dimensions,
then a section I comment-titled 'start rendering things'
which calls the coded modules and actually make OpenSCAD render them,
and then a section of all the modules that do the work and define objects.
Comment in/out module calls from the 'start rendering things' section
to only render some or one at a time.
I tried to arrange the module calls in that section so you can
just select/deselect objects in your slicing program from one big STL -
but if you want to create an STL for each object or however, cool.

To create said STL hit the F6 button or go to the menu 'Design' > 'Render'.
Wait a while for that to work,
then hit the F7 button or go to the menu 'File' > 'Export' > 'Export as STL'.

NB: Objects in the lower right are to be printed out of TPU or
some other flexible filament.
This includes the larger rectangular gasket with rounded corners
and a raised interior lip, the smaller gasket with integrated buttons,
and the 8 washers.
In the end I think using an actual O-ring
or 1.75mm TPU filament cut straight from the roll may be better than the two printed gaskets,
but that idea was formed after I saw how uneven the flat surfaces were on printed TPU objects.
We'll see.

## BOM

- [Adafruit MagTag](https://www.adafruit.com/product/4800)
  often sold out at Adafruit, because resellers buy in bulk. So search online.
- [Compact USB-C Qi Receiver](https://www.amazon.com/gp/product/B07CVXW3MV/)
  Hack down the case around the Qi loop & PCB so if can fit in the case

## Misc Links

- [MagTag PCB Repo](https://github.com/adafruit/Adafruit_MagTag_PCBs/tree/main)
- [MagTab Circuitpython Release](https://github.com/adafruit/Adafruit_CircuitPython_MagTag/releases)
- [Misc MagTag Downloads from Adafruit](https://learn.adafruit.com/adafruit-magtag/downloads)
- [Altium Online PCB Viewer](https://www.altium.com/viewer/)

## TODO

### v0.9

- [ ] change case to use countersunk 3mm head depth bolts,
      vs 5mm depth socket cap bolts
- [x] make error message display on magtag screen if on boot you can't reach wifi
- [x] review code and see what TODOs are there and what other problems there are
- [x] make pager have two+ wifi networks to connect to,
      with different sleep intervals for each
      (e.g. on ship, refresh often.
      at home, be idle and sleep max,
      at third tbd place, refresh tbd)
- [ ] fix pager to clear the indefinite 'alarm silence'
      once the present alarm stop alarming

I plan to skip v1.0 because a true 1.0 would require me to
reprint the bulky case that can fit the old (larger) Qi charger,
and I don't want to do that.
So leaving v0.9 to reflect that it might not be production ready.

v2 will be with directly soldered qi and thus smaller case,
so will not be compatible with previous.

### v2.0

- [ ] How thin can i print TPU gaskets?
      Would just one layer be smoother?
      Or make channel for unprinted TPU filament/O-ring?
- [x] Solder Qi receiver directly to PCB
- [x] add some hot glue strain relief to Qi board <-> wires & wires <-> PCB
- [ ] document soldering Qi receiver directly to PCB
- [ ] shrink case dimensions now that Qi receiver is smaller and no USB-C sticking out

### v2.1

- [ ] think about adding vibration motor - space in case for motor,
      but also what pins to attach it to
- [ ] update menu functionality on pager
