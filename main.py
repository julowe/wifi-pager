# SPDX-FileCopyrightText: 2021 Eva Herrada for Adafruit Industries, 2023 Justin Lowe
#
# SPDX-License-Identifier: MIT

# # TODO:
# [] Look at neopixel color cycling (to show it is charging)
# [] quiet hours? prob not, more alert severity filtering better
# [] do diff sleep when connected to computer?
# [] remove "alert" from end of json name?

# example data from grafana v1 dashboard
# {'evalData': {}, 'dashboardUid': 'n5qH1pcWk', 'url': '/graphs/d/n5qH1pcWk/temp-humidity', 'evalDate': '0001-01-01T00:00:00Z', 'id': 5, 'dashboardSlug': 'temp-humidity', 'state': 'ok', 'name': 'Rack Room alert', 'dashboardId': 1, 'executionError': '', 'panelId': 12, 'newStateDate': '2022-09-23T10:11:16Z'}
#ok
#{'evalData': None, 'dashboardUid': 'CBtIpJpGz', 'url': '/graphs/d/CBtIpJpGz/alert-dashboard', 'evalDate': '0001-01-01T00:00:00Z', 'id': 6, 'dashboardSlug': 'alert-dashboard', 'state': 'alerting', 'name': 'Sat System Pings from Shiphouse alert', 'dashboardId': 27, 'executionError': '', 'panelId': 8, 'newStateDate': '2022-09-23T20:46:16Z'}
#alerting

import time
import ssl
import gc
import wifi
import socketpool
import adafruit_requests as requests

import adafruit_ntp
from adafruit_magtag.magtag import MagTag
import alarm
import board
from adafruit_debouncer import Debouncer


## See if device woke from sleep, and how
#print(alarm.wake_alarm)
alarm_triggered = alarm.wake_alarm

#print(alarm.sleep_memory[0])
#if alarm.sleep_memory[0]:
#    print("true")
#else:
#    print("false")

#print(alarm.sleep_memory[1])

alarm_wake = "nothing"
if alarm_triggered is not None:
    if isinstance(alarm_triggered, alarm.pin.PinAlarm):
        alarm_wake = "button"
        print("Woken from sleep by button press")
    elif isinstance(alarm_triggered, alarm.time.TimeAlarm):
        alarm_wake = "timer"
        print("Woken from sleep by timed alarm")
    else:
        print("Woken by something else...")
else:
    print("Code running for first time")

    if alarm.sleep_memory[0] != 0:
        # reset state of all_ok_previous to False
        alarm.sleep_memory[0] = 0
        print("Resetting sleep_memory[0] (all_ok_previous) to 0")
    if alarm.sleep_memory[1] != 0:
        # reset alarm_silence_time sleep memory to no alarm silence time
        alarm.sleep_memory[1] = 0
        print("Resetting sleep_memory[1] (alarm_silence_time) to 0")

#print("end sleep mem", time.monotonic())

## Get wifi details and more from a secrets.py file
try:
    from secrets import secrets
except ImportError:
    print("WiFi secrets are kept in secrets.py, please add them there!")
    raise
#print("wifi", time.monotonic())

## TODO delete or fix for v8
def font_width_to_dict(font):
## Reads the font file to determine how wide each character is
## Used to avoid bad wrapping breaking the QR code
    chars = {}
    with open(font, "r") as file:
        for line in file:
            if "FONTBOUNDINGBOX" in line:
                size = int(line.split(" ")[1])
            if "ENCODING" in line and "_ENCODING" not in line:
                character = chr(int(line.split(" ")[1][:-1]))
                chars[character] = None
            if "SWIDTH" in line:
                swidth = (int(line.split(" ")[1]) / 1000) * size
            if "DWIDTH" in line:
                chars[character] = int(int(line.split(" ")[1]) + swidth)
    return chars


def wrap(text, max_width, max_lines, font):
    # Used to wrap the title and description to avoid breaking the QR code
    lines = []
    ellipsis = 3 * font["."]
    line = ""
    line_width = 0
    for word in text.split(" "):
        for character in word:
            line_width += font[character]
            if (
                len(lines) + 1 != max_lines
                or sum(font[i] for i in word) + line_width <= max_width
            ):
                if line_width > max_width:
                    print(str(line_width) + line)
                    line_width = sum(font[i] for i in word)
                    lines.append(line.strip())
                    line = word + " "
                    break
            else:
                for char_1 in word:
                    if line_width + ellipsis + font[char_1] > max_width:
                        line = line + "..."
                        print(str(line_width) + line)
                        lines.append(line)
                        return "\n".join(lines[:max_lines])
                    line = line + char_1
                    line_width += font[char_1]

        else:
            line = line + word + " "

    lines.append(line.strip())
    return "\n".join(lines[:max_lines])


button_colors = ((255, 0, 0), (255, 150, 0), (0, 255, 255), (180, 0, 255))
button_tones = (1047, 1318, 1568, 2093)

#print("startmag", time.monotonic())

## Initialize magtag object
magtag = MagTag()

if alarm_wake == "button":
    # turn light on when rebooted by user action
    magtag.peripherals.neopixel_disable = False
    magtag.peripherals.neopixels.fill(button_colors[2])
    # teal (0, 255, 255)
    # keep lights on for half a second
    time.sleep(0.5)
    # turn lights off and move on
    #magtag.peripherals.neopixel_disable = True

magtag.set_background("bmps/jkl-initials.bmp")

#print("end mag", time.monotonic())

## get all_ok value from sleep_memory and save locally
all_ok_previous = alarm.sleep_memory[0]
## get alarm_silence_time value from sleep_memory and save locally
alarm_silence_time = alarm.sleep_memory[1]

#print("end read sleep", time.monotonic())

## Set up text fields for magtag

#print("start addtext", time.monotonic())
## text 0 - main alarm status display - average size text for when alerts are firing
magtag.add_text(
    text_font="fonts/Arial-Bold-12.pcf",
    text_wrap=36,
    text_position=(8, 10), # (in from left, down from top)
    text_scale=1,
    line_spacing=0.7,
    text_anchor_point=(0, 0),
)

## text 1 - big 'all ok' status text
magtag.add_text(
    #text_font="/fonts/Arial-Bold-12.bdf",
    #text_font="fonts/SourceSerifPro-Bold-AllOk-25.pcf",
    text_font="fonts/SourceSerifPro-Bold-AllOk-38.pcf",
    text_wrap=36,
    #text_maxlen=120,
    text_position=(
        (magtag.graphics.display.width // 2),
        (magtag.graphics.display.height // 2) - 10,
    ),
    line_spacing=0.75,
    text_scale=1,
    text_anchor_point=(0.5, 0.5),  # center the text on x & y
)


# magtag.add_text(
#     text_font="fonts/Arial-Bold-12.bdf",
#     text_position=(5, 25),
#     text_scale=1,
#     line_spacing=0.7,
#     text_anchor_point=(0, 0),
# )

## text 2 - small status text in top left corner, down one line
magtag.add_text(
    text_font="fonts/ArialMT-9.pcf",
    text_position=(7, 18),
    text_scale=1,
    text_wrap=65,
    line_spacing=0.8,
    text_anchor_point=(0, 0),
)

## text 3 - time & battery status bar
magtag.add_text(
    text_font="fonts/ArialMT-9.pcf",
    text_scale=1,
    text_maxlen=300,
    #text_position=(5, 120),
    text_position=(4, 4),
    text_anchor_point=(0, 0),
)

## text 4 - button text
magtag.add_text(
    text_font="fonts/ArialMT-9.pcf",
    text_scale=1,
    #text_wrap=25,
    #text_maxlen=300,
    #text_position=(215, 120),
    text_position=(5, 118),
    text_anchor_point=(0, 0),
)

## text 5 - silence alarm menu
magtag.add_text(
    text_font="fonts/Arial-Bold-12.pcf",
    text_position=(8, 80),
    text_scale=1,
    line_spacing=0.7,
    text_anchor_point=(0, 0),
)

refresh_interval_mins_ok = 5
refresh_interval_mins_alerting = 1
alert = "noise"

data_url = ""
wifi_connected = False
attempted_ssids = ""
## Set up WiFi
for location in secrets:
    try:
        print("connecting to", location["ssid"])
        wifi.radio.connect(location["ssid"], location["password"])
        print(f"Connected to {location['ssid']}!")
        print("My IP address is", wifi.radio.ipv4_address)
        socket = socketpool.SocketPool(wifi.radio)
        https = requests.Session(socket, ssl.create_default_context())
    except Exception as errorMessage:  # pylint: disable=broad-except
        print("Could not connect to wifi ssid:", location["ssid"], "at", location["name"])
        print(errorMessage)
        attempted_ssids += location["ssid"] + " "
        # TODO add check to see which error?
    else:
        data_url = location["URL"]
        wifi_connected = True
        refresh_interval_mins_ok = location["refresh_interval"]
        if location["alert_default"] == "mute" and alarm_triggered is None: #i.e. mute alarm by default and this is the first time code was run:
            alarm_silence_time = 99 # 99 is a stand-in for 'indefinitely'

wifi_sleep_seconds_retry = 60
if not wifi_connected:
    print("Failed to connect to SSIDs", attempted_ssids, ", sleeping for", wifi_sleep_seconds_retry, "seconds.")
    magtag.set_text("Can't connect to " + attempted_ssids + "!", 0)
    print("Available WiFi networks:")
    for network in wifi.radio.start_scanning_networks():
        print("\t%s\t\tRSSI: %d\tChannel: %d" % (str(network.ssid, "utf-8"),network.rssi, network.channel))
        wifi.radio.stop_scanning_networks()
    magtag.exit_and_deep_sleep(wifi_sleep_seconds_retry)


#print("end wifi", time.monotonic())

ok_concise = True
alert_initial_tone = False
alerting_user = False
all_ok = True
list_ok = list()
list_pending = list()
list_nodata = list()
list_alerting = list()
list_alert_silence_minutes = [5, 10, 30, 99]

## Get alarm statuses from Grafana

print(data_url)

## turn lights off from bootup
magtag.peripherals.neopixel_disable = True

## try to ping server here to see if reachable
## to avoid/inform about -2 error below when can;t reach server

try:
    with https.get(data_url) as response:
        try:
            R_JSON = response.json()
        except Exception:  # pylint: disable=broad-except
            print("Could not parse json. Trying again in 60 seconds.")
            magtag.exit_and_deep_sleep(60)

        for i in R_JSON:
            if i["state"] == "ok":
                #print(i["name"], "is ok")
                #display_text += str(i["name"]) + " is ok\n"
                list_ok.append(str(i["name"]))
        
            elif i["state"] == "pending":
                all_ok = False
                #print(i["name"], "is", i["state"])
                #display_text += str(i["name"]) + " is pending\n"
                list_pending.append(str(i["name"]))

                if alert_initial_tone:
                    magtag.peripherals.play_tone(button_tones[0], 0.25)

            elif i["state"] == "no_data":
                all_ok = False
                #print(i["name"], "is", i["state"])
                #display_text += str(i["name"]) + " is pending\n"
                list_nodata.append(str(i["name"]))

                if alert_initial_tone:
                    magtag.peripherals.play_tone(button_tones[0], 0.25)

            else:
                all_ok = False
                #print(i["name"], "is", i["state"])
                #display_text += str(i["name"]) + " is " + str(i["state"]) + "\n"
                alerting_user = True
                list_alerting.append(str(i["name"]))

                # turn on lights if error and leave on
                magtag.peripherals.neopixel_disable = False
                magtag.peripherals.neopixels.fill(button_colors[3])

                if alert_initial_tone:
                    magtag.peripherals.play_tone(button_tones[3], 0.25)
                # teal (0, 255, 255)
                # purple (180, 0, 255)

        # clean up JSON stuff, so save anything you want!
        R_JSON.clear()
        R_JSON = None
        gc.collect()
except Exception:  # pylint: disable=broad-except
    print("Could not get url. Trying again in 60 seconds.")
    magtag.exit_and_deep_sleep(60)

#print("end json parse", time.monotonic())

## update debugging boolean!
debug_bool = False
if debug_bool:
    print("Debugging: set status to alerting to test things")
    alerting_user = True
    all_ok = False
    # turn on lights if error and leave on
    magtag.peripherals.neopixel_disable = False
    magtag.peripherals.neopixels.fill(button_colors[3])
    if alert_initial_tone:
        magtag.peripherals.play_tone(button_tones[3], 0.25)

## if nothing alerting, reset alarm silence time
## this also functions such that silence 'for duration' silences all alarms (current and new ones) until all alerts are back to ok
if all_ok:
    if location["alert_default"] == "mute":
        alarm_silence_time = 99
    else:
        alarm_silence_time = 0


if all_ok_previous and all_ok and alarm_wake == "timer":
    print("Not updating NTP time, woken by timer and previous status & current status is 'all ok'")
    time_now_string = "Time not updated"
else:
    # Get NTP time
    #pool = socketpool.SocketPool(wifi.radio)
    try:
        ntp = adafruit_ntp.NTP(socket, tz_offset=0)
        #print(ntp.datetime)

        time_now_string = "Updated at: {:d}-{:02d}-{:02d} {:02d}:{:02d}Z".format(ntp.datetime.tm_year, ntp.datetime.tm_mon, ntp.datetime.tm_mday, ntp.datetime.tm_hour, ntp.datetime.tm_min)
        time_now_min = ntp.datetime.tm_min
    except Exception as errorMessage:  # pylint: disable=broad-except
        print("Could not get NTP time. Ignoring")
        time_now_string = "Unable to get NTP time"
        time_now_min = 59
        print(errorMessage)

print(time_now_string)

#print("end ntp get", time.monotonic())

## somewhere above here, start collecting errors and if any print them to screen


# Construct text to display on e-ink
text_ok = ", ".join(list_ok)
text_pending = ", ".join(list_pending)
text_nodata = ", ".join(list_nodata)
text_alerting = ", ".join(list_alerting)

# TODO change pending to warning? not quite right. alerting change to critical?
if len(list_alerting) > 1:
    text_alerting += " are alerting."
else:
    text_alerting += " is alerting."

if len(list_pending) > 1:
    text_pending += " are pending."
else:
    text_pending += " is pending."

if len(list_nodata) > 1:
    text_nodata += " have no data."
else:
    text_nodata += " has no data."

if len(list_ok) > 1:
    text_ok += " are ok."
else:
    text_ok += " is ok."

#print(text_ok)
#print(text_pending)
#print(text_nodata)
#print(text_alerting)

display_text_list = list()
if list_alerting:
    #print("appended alerting")
    display_text_list.append(text_alerting)
if list_pending:
    #print("appended pending")
    display_text_list.append(text_pending)
if list_nodata:
    #print("appended nodata")
    display_text_list.append(text_nodata)

print("\n".join(display_text_list))

if list_ok and not ok_concise:
    #print("appended ok")
    display_text_list.append(text_ok)


if not list_alerting and not list_pending and not list_nodata and ok_concise:
    display_text = "All Ok  :-)"
else:
    display_text = "\n".join(display_text_list)


print(display_text)

#print("end addt ext", time.monotonic())

## Prepare to wrap the text correctly by getting the width of each character for every font
#arial_12 = font_width_to_dict("fonts/Arial-Bold-12.bdf")
#arial_9 = font_width_to_dict("fonts/ArialMT-9.bdf")


## if active alert, yell for UI_wait_minutes and then sleep for shorter time than if no alert
if alerting_user:
    UI_wait_minutes = 1
    deep_sleep_minutes = refresh_interval_mins_alerting
elif alarm_wake == "timer":
    UI_wait_minutes = 0.1 # do we even want any wait time if this thing just wakes on interval?
    deep_sleep_minutes = refresh_interval_mins_ok
else:
    UI_wait_minutes = 1
    deep_sleep_minutes = refresh_interval_mins_ok

## Check status and alarm if needed
## refresh screen once an hour, during the first refresh interval
if all_ok_previous and all_ok and alarm_wake == "timer" and time_now_min <= refresh_interval_mins_ok:
    print("Not updating e-ink display, previous status and current status is 'all ok' and this isn't the first refresh of the hour (or I can't get time)")
    screen_name = "main"
else:
    print("Updating e-ink display")
    # Set the text. On some characters, this fails. If so, run the whole file again in 5 seconds
    try:
        # Note what screen/menu we are on
        screen_name = "main"

        if magtag.peripherals.battery < 3.5:
            battery_display_string = "!!BATTERY LOW!! at"
        else:
            battery_display_string = "battery:"

        
        # Display updated time
        magtag.set_text(time_now_string + ", " + battery_display_string + " {0:.2f}V".format(magtag.peripherals.battery), 3, False)

        # Display wake device text
        if all_ok:
            magtag.set_text("List All Alerts                                                     Wake Device", 4, False)
        else:
            # this differnce is mostly bc it isn't coded yet to show a long status screen when all alerts are not in ok state
            magtag.set_text("                                                                    Wake Device", 4, False)

        if alerting_user:
            if alarm_silence_time == 99:
                magtag.set_text("Alarm Silenced indefinitely, set to:\n   {}           {}           {}     indefinitely".format(alarm_silence_time, list_alert_silence_minutes[0], list_alert_silence_minutes[1], list_alert_silence_minutes[2]), 5, False)
            elif alarm_silence_time > 0:
                magtag.set_text("Alarm Silenced for {} mins, set to:\n   {}           {}           {}     indefinitely".format(alarm_silence_time, list_alert_silence_minutes[0], list_alert_silence_minutes[1], list_alert_silence_minutes[2]), 5, False)
            else:
                magtag.set_text("Silence alarm for X mins:\n   {}           {}           {}     indefinitely".format(list_alert_silence_minutes[0], list_alert_silence_minutes[1], list_alert_silence_minutes[2]), 5, False)
        else:
            magtag.set_text("\nChecking status every {} minutes.".format(deep_sleep_minutes), 5, False)

        # Display status of alerts
        if all_ok:
            magtag.set_text(display_text, 1)
        else:
            magtag.set_text(display_text, 0)

        #print("end screen", time.monotonic())

    except Exception:  # pylint: disable=broad-except
        print("Could not update display.")
        print("Trying again in 60 seconds.")
        alarm.sleep_memory[0] = 0 # aka: all_ok_previous = 0, signal for screen refresh
        magtag.exit_and_deep_sleep(60)

    print("e-ink display updated, waiting", UI_wait_minutes, "minutes for button presses before sleeping")

## https://docs.circuitpython.org/projects/magtag/en/latest/api.html#adafruit-magtag-peripherals


    # TODO what do we want menu to do?
    # set vibrate or noise mode?
    # get more info on an alert?
    # acknowledge alerts that came and went with no user interaction?
    # show actual values instead of just ok pending alerting?
    # if all ok, then one button will refresh screen with full list of all alerts as a sanity check

    time_UI_start = time.monotonic()
    #print(time_UI_start)

    # set up debounce buttons
    switches = list()
    #pin=board.D11
    for i, b in enumerate(magtag.peripherals.buttons):
        #print(i)
        #print(b)
        switches.append(Debouncer(b))

    #if alarm_silence_time > 0 and alerting_user:
    #    print("alarm silence time:",alarm_silence_time)


    while time.monotonic() - time_UI_start < 60*UI_wait_minutes:

        for i, switch in enumerate(switches):
            switch.update()

            # can now check switch.value or rose or fell
            #if not switch.value:
            #    if alerting_user:
            #        alarm.sleep_memory[1] = list_alert_silence_minutes[i]
            #        print("Button value updated", i)
            #        print("setting to silence for", list_alert_silence_minutes[i])
                #print('not pressed')
            #    continue

            if switch.fell:
                # reset wait time when button pressed
                time_UI_start = time.monotonic()
                # Give feedback that button was pressed
                print("Button %c pressed" % chr((ord("A") + i)))
                magtag.peripherals.neopixel_disable = False
                magtag.peripherals.neopixels.fill(button_colors[i])

                # same noise for menu button presses? or how about for only active menu options?
                #magtag.peripherals.play_tone(button_tones[i], 0.25)
                #magtag.peripherals.play_tone(button_tones[0], 0.25)

                # respond to button presses on 'silence for X mins' menu
                if alerting_user:
                    alarm_silence_time = list_alert_silence_minutes[i]
                    magtag.peripherals.play_tone(button_tones[i], 0.25)
                    #print("Button ", i)
                    print("setting to silence for", list_alert_silence_minutes[i])
                    break

                # respond to button presses on non-alerting menu
                if i == 0:
                    magtag.peripherals.play_tone(button_tones[i], 0.25)
                    if screen_name == "main":
                        print("Changing to display of all alerts screen")
                        print(text_ok)
                        # Note screen change
                        screen_name = "long-ok"

                        # Clear old text
                        #magtag.remove_all_text() # oh this remove all that add_text did, not sets to blank...
                        magtag.set_text("", 5, False)
                        #magtag.set_text("", 4, False)
                        #magtag.set_text("", 3, False) #keep status bar the same
                        #magtag.set_text("", 2, False)
                        magtag.set_text("", 1, False)
                        magtag.set_text("", 0, False)

                        # Display exit button text
                        # TODO make this actually work... prob need to spin off module to update screen
                        magtag.set_text("Return to Main                                                     Wake Device", 4, False)
                        #magtag.set_text("Return to Main", 4, False)

                        # Display full list of all_ok alerts (which all are, if not in alerting_user state)
                        magtag.set_text(text_ok, 2)
                        break

                    if screen_name == "long-ok":
                        print("Changing to display of main screen")
                        # Note screen change
                        screen_name = "main"

                        # Clear old text
                        #magtag.remove_all_text() # oh this remove all that add_text did, not sets to blank...
                        #magtag.set_text("", 5, False)
                        #magtag.set_text("", 4, False)
                        #magtag.set_text("", 3, False)
                        magtag.set_text("", 2, False)
                        #magtag.set_text("", 1, False)
                        magtag.set_text("", 0, False)

                        # Display updated time
                        #didn't change
                        #magtag.set_text(time_now_string + ", battery: {0:.2f}V".format(magtag.peripherals.battery), 3, False)

                        # Display wake device text
                        magtag.set_text("List All Alerts                                                     Wake Device", 4, False)
                        #magtag.set_text("Wake Device", 4, False)

                        magtag.set_text("\nChecking status every {} minutes.".format(deep_sleep_minutes), 5, False)

                        # Display concise all ok status
                        magtag.set_text(display_text, 1)
                        break
                #if i == 1:
                # keep lights on for a shake after being pressed
                time.sleep(0.2)

            # still needed?? TODO
            if switch.rose:
                # reset wait time when button pressed
                time_UI_start = time.monotonic()
                #print("Button %c released" % chr((ord("A") + i)))
                break
        else:
            if alerting_user:
                # always set lights for alerts
                magtag.peripherals.neopixels.fill(button_colors[3])

                # see if silencing alarms
                if alarm_silence_time > 0:
                    #print("greater than zero")
                    continue
                else:
                    magtag.peripherals.neopixels.fill(button_colors[3])
                    #magtag.peripherals.play_tone(button_tones[0], 0.25)
                    #sleep(1)
                    magtag.peripherals.play_tone(button_tones[1], 0.25)
                    #magtag.peripherals.play_tone(button_tones[2], 0.25)
                    #magtag.peripherals.play_tone(button_tones[3], 0.25)
                    #magtag.peripherals.play_tone(button_tones[3], 0.25)
            else:
                # this is only really needed while menu shows lights
                magtag.peripherals.neopixel_disable = True


## after waiting UI_wait_minutes minutes for a button to be pressed, go back to sleep
print("Going to sleep for", deep_sleep_minutes, "minutes")

if screen_name == "main":
    # get all_ok value from sleep_memory and save locally
    alarm.sleep_memory[0] = all_ok
else:
    # if not on main screen, then we should update the screen next time it updates data
    alarm.sleep_memory[0] = 0

## subtract UI_wait_minutes and upcoming deep_sleep_minutes from time to silence alarm (but not if ==99 or == 0)
if alarm_silence_time > 0:
    print("alarm silence time was:",alarm_silence_time)
    if alarm_silence_time != 99:
        alarm_silence_time = alarm_silence_time - UI_wait_minutes - deep_sleep_minutes

        # sleep_memory can only be 0-255
        if alarm_silence_time < 0:
            alarm_silence_time = 0

    alarm.sleep_memory[1] = int(alarm_silence_time)
    print("sleep memory 1 is now:",alarm.sleep_memory[1])



#print(time.monotonic() - time_UI_start)

## release buttons
magtag.peripherals.deinit()

## wake up after deep_sleep_minutes minutes to check status
time_alarm = alarm.time.TimeAlarm(monotonic_time=time.monotonic() + 60*deep_sleep_minutes)

## wake up on button press - always refresh?
## yes? why else would I be pressing a button when I can already see the screen?
pin_alarm = alarm.pin.PinAlarm(pin=board.D11, value=False, pull=True)

## sleep for deep_sleep_minutes or until D11 button pressed
#alarm_triggered = alarm.exit_and_deep_sleep_until_alarms(time_alarm, pin_alarm)
alarm.exit_and_deep_sleep_until_alarms(time_alarm, pin_alarm)
