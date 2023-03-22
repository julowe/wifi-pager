# Creating a Wifi Pager with an Adafruit MagTag

This project was started because push notifications on iOS were proving unreliable in delivery when at sea. 
I wanted more control over the software and hardware so I could actually receive timely warning notifications.

## Current State

It works! Ok, mostly. scad file makes a workable but bulky case with hard to press TPU buttons.
Software will mostly work but probably hit edge cases and crash/hang.

## Software

### Installation

Copy to your magtag the directories `bmps`, `lib`, and `fonts` and the file `main.py`. Edit the file `secrets.py.template` to have you SSID info (AIO info is not currently used) and rename the file to `secrets.py`, and copy to your magtag.

## Hardware

And by this, for now, I mean the 3d printed case. At this point I don't think I'll include STL files, as I'm sure they'll change. Get [OpenSCAD](https://openscad.org) and open the `magtag-case.scad` file. Hit the F5 key or go to the menu 'Design' > 'Preview'. This should give you a quick preview of all objects. There will be weird clipping artifacts, ignore them for now. 

The file is arranged into a bunch of variables defining real world dimensions, then a section I comment-titled 'start rendering things' which calls the coded modules and actually make OpenSCAD render them, and then a section of all the modules that do the work and define objects. Comment in/out module calls from the 'start rendering things' section to only render some or one at a time. I tried to arrange the module calls in that section so you can just select/deselct objects in your slicing program from one big STL - but if you want to create an STL for each object or however, cool.

To create said STL hit the F6 button or go to the menu 'Design' > 'Render'. Wait a while for that to work, then hit the F7 button or go to the menu 'File' > 'Export' > 'Export as STL'.

NB: Objects in the lower right are to be printed out of TPU or some other flexible filament. This includes the larger rectangular gasket with rounded corners and a raised interior lip, the smaller gasket with integrated buttons, and the 8 washers. In the end I think using an actual O-ring or 1.75mm TPU filament cut straight from the roll may be better than the two printed gaskets, but that idea was formed after I saw how uneven the flat surfaces were on printed TPU objects. We'll see.

## BOM
- [Adafruit MagTag](https://www.adafruit.com/product/4800) often sold at Adafruit, because resellers buy in bulk. So search online.
- [Compact USB-C Qi Receiver](https://www.amazon.com/gp/product/B07CVXW3MV/) Hack down the case around the Qi loop & PCB so if can fit in the case

## TODO

### v0.9
- [ ] change case to use countersunk 3mm head depth bolts, vs 5mm depth socket cap bolts
- [ ] make error message display on magtag screen if on boot you can't reach wifi
- [ ] review code and see what TODOs are there and what other problems there are

I plan to skip v1.0 because a true 1.0 would require me to reprint the bullky case that can fit the old (larger) Qi charger, and I don't want to do that. So leaving v0.9 to reflect that it might not be production ready. v2 will be with directly soldered qi and thus smaller case, so will not be compatible with previous.

### v2.0
- [ ] How thin can i print TPU gaskets? Would just one layer be smoother? Or make channel for unprinted TPU filament/O-ring?
- [x] Solder Qi receiver directly to PCB
- [ ] add some hot glue strain relief to Qi board <-> wires & wires <-> PCB
- [ ] document soldering Qi receiver directly to PCB
- [ ] shrink case dimensions now that Qi receiver is smaller and no USB-C sticking out 
- [ ] think about adding vibration motor - space in case for motor, but also what pins to attach it to
