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
# ok
# {'evalData': None, 'dashboardUid': 'CBtIpJpGz', 'url': '/graphs/d/CBtIpJpGz/alert-dashboard', 'evalDate': '0001-01-01T00:00:00Z', 'id': 6, 'dashboardSlug': 'alert-dashboard', 'state': 'alerting', 'name': 'Sat System Pings from Shiphouse alert', 'dashboardId': 27, 'executionError': '', 'panelId': 8, 'newStateDate': '2022-09-23T20:46:16Z'}
# alerting

import gc
import ssl
import time

import adafruit_ntp
import adafruit_requests as requests
import alarm
import board
import socketpool
import supervisor
import wifi
from adafruit_debouncer import Debouncer
from adafruit_magtag.magtag import MagTag

import config
from dashboard_state import DashboardState

DEBUG = False

## See if device woke from sleep, and how
# print(alarm.wake_alarm)
alarm_triggered = alarm.wake_alarm
print("alarm.wake_alarm:", alarm.wake_alarm)

# print(alarm.sleep_memory[0])
# if alarm.sleep_memory[0]:
#    print("true")
# else:
#    print("false")

# print(alarm.sleep_memory[1])

# print(supervisor.runtime.run_reason)

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


## TODO delete or fix for v8
def font_width_to_dict(font):
    ## Reads the font file to determine how wide each character is
    ## Used to avoid bad wrapping breaking the QR code
    chars = {}
    with open(font) as file:
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
            if len(lines) + 1 != max_lines or sum(font[i] for i in word) + line_width <= max_width:
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


## Initialize magtag object
magtag = MagTag()
magtag.peripherals.neopixel_disable = False
magtag.peripherals.neopixels.fill((0, 0, 0))

if alarm_wake == "button":
    # turn light on when rebooted by user action
    magtag.peripherals.neopixels.fill(button_colors[2])
    # teal (0, 255, 255)
    # keep lights on for half a second
    time.sleep(0.5)
    magtag.peripherals.neopixels.fill((0, 0, 0))

magtag.set_background("bmps/jkl-initials.bmp")


## get all_ok value from sleep_memory and save locally
all_ok_previous = alarm.sleep_memory[0]
## get alarm_silence_time value from sleep_memory and save locally
alarm_silence_time = alarm.sleep_memory[1]


## Set up text fields for magtag

## text 0 - main alarm status display - average size text for when alerts are firing
magtag.add_text(
    text_font="fonts/Arial-Bold-12.pcf",
    text_wrap=36,
    text_position=(8, 10),  # (in from left, down from top)
    text_scale=1,
    line_spacing=0.7,
    text_anchor_point=(0, 0),
)

## text 1 - big 'all ok' status text
magtag.add_text(
    # text_font="/fonts/Arial-Bold-12.bdf",
    # text_font="fonts/SourceSerifPro-Bold-AllOk-25.pcf",
    text_font="fonts/SourceSerifPro-Bold-AllOk-38.pcf",
    text_wrap=36,
    # text_maxlen=120,
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
    # text_position=(5, 120),
    text_position=(4, 4),
    text_anchor_point=(0, 0),
)

## text 4 - button text
magtag.add_text(
    text_font="fonts/ArialMT-9.pcf",
    text_scale=1,
    # text_wrap=25,
    # text_maxlen=300,
    # text_position=(215, 120),
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


def clear_screen():
    for i in range(6):
        magtag.set_text("", i, False)


## Get wifi details and more from a secrets.py file
try:
    from secrets import secrets
except ImportError:
    print("WiFi secrets are kept in secrets.py, please add them there!")
    magtag.peripherals.neopixel_disable = False
    magtag.peripherals.neopixels.fill((255, 0, 0))
    clear_screen()
    magtag.set_text("Error: Missing secrets.py", 1, False)
    magtag.refresh()
    raise

refresh_interval_mins_ok = 5
# refresh_interval_mins_alerting = 1
refresh_interval_mins_alerting = 0.5  # or maybe just zero? maybe better to have short break so the constant alarm noise doesn't get lost in background noise of ship
alert = "noise"
location_info = ""

data_url = ""
wifi_connected = False
attempted_ssids = ""

## Set up WiFi (Pixel 3 / 1st Light on left)
magtag.peripherals.neopixel_disable = False
magtag.peripherals.neopixels[3] = (0, 0, 255)  # Blue: connecting

for location in secrets:
    location_info = location
    try:
        print("connecting to", location["ssid"])
        wifi.radio.connect(location["ssid"], location["password"])
        print(f"Connected to {location['ssid']}!")
        print("My IP address is", wifi.radio.ipv4_address)
        socket = socketpool.SocketPool(wifi.radio)
        https = requests.Session(socket, ssl.create_default_context())
    except Exception as errorMessage:  # pylint: disable=broad-except
        print(
            "Could not connect to wifi ssid:",
            location["ssid"],
            "at",
            location["name"],
        )
        print(errorMessage)
        attempted_ssids += location["ssid"] + " "
        # TODO add check to see which error?
    else:
        data_url = location["URL"]
        wifi_connected = True
        magtag.peripherals.neopixels[3] = (0, 255, 0)  # Green: connected
        refresh_interval_mins_ok = location["refresh_interval"]
        if (
            location["alert_default"] == "mute" and alarm_triggered is None
        ):  # i.e. mute alarm by default and this is the first time code was run:
            alarm_silence_time = 99  # 99 is a stand-in for 'indefinitely'
        break

wifi_sleep_seconds_retry = 60
if not wifi_connected:
    print(
        "Failed to connect to SSIDs",
        attempted_ssids,
        ", sleeping for",
        wifi_sleep_seconds_retry,
        "seconds.",
    )
    magtag.peripherals.neopixels[3] = (255, 255, 0)  # Yellow: failed
    clear_screen()
    magtag.set_text("Error: Can't connect to WiFi!", 1, False)
    magtag.refresh()
    print("Available WiFi networks:")
    for network in wifi.radio.start_scanning_networks():
        print(f"\t{str(network.ssid, 'utf-8')}\t\tRSSI: {network.rssi}\tChannel: {network.channel}")
    wifi.radio.stop_scanning_networks()
    magtag.exit_and_deep_sleep(wifi_sleep_seconds_retry)


## Get NTP time (Pixel 2 / 2nd Light)
current_time = None
magtag.peripherals.neopixels[2] = (0, 0, 255)  # Blue: syncing time
try:
    ntp = adafruit_ntp.NTP(socket, tz_offset=0)
    current_time = ntp.datetime
    time_now_string = f"Updated at: {current_time.tm_year:d}-{current_time.tm_mon:02d}-{current_time.tm_mday:02d} {current_time.tm_hour:02d}:{current_time.tm_min:02d}Z"
    time_now_min = current_time.tm_min
    magtag.peripherals.neopixels[2] = (0, 255, 0)  # Green: synced
except Exception as errorMessage:  # pylint: disable=broad-except
    print("Could not get NTP time. Ignoring")
    magtag.peripherals.neopixels[2] = (255, 255, 0)  # Yellow: failed (non-fatal)
    current_time = None
    time_now_string = "Unable to get NTP time"
    time_now_min = 59
    print(errorMessage)

print(time_now_string)

alert_initial_tone = False
alerting_user = False
all_ok = True
list_alert_silence_minutes = [5, 10, 30, 99]

## Get alarm statuses from Grafana (Pixel 1: Fetch / 3rd Light, Pixel 0: Parse / 4th Light)

print(data_url)

magtag.peripherals.neopixels[1] = (0, 0, 255)  # Blue: fetching data
try:
    with https.get(data_url) as response:
        magtag.peripherals.neopixels[1] = (0, 255, 0)  # Green: fetched data
        magtag.peripherals.neopixels[0] = (0, 0, 255)  # Blue: parsing JSON
        try:
            R_JSON = response.json()
            magtag.peripherals.neopixels[0] = (0, 255, 0)  # Green: parsed JSON
        except Exception:  # pylint: disable=broad-except
            print("Could not parse json. Trying again in 60 seconds.")
            magtag.peripherals.neopixels[0] = (255, 255, 0)  # Yellow: parse error
            clear_screen()
            magtag.set_text("Error: Could not parse JSON.", 1, False)
            magtag.refresh()
            magtag.exit_and_deep_sleep(60)

        state = DashboardState(R_JSON, config=config, current_time=current_time)

        # clean up JSON stuff, so save anything you want!
        R_JSON.clear()
        R_JSON = None
        gc.collect()
except Exception:  # pylint: disable=broad-except
    print("Could not get url. Trying again in 60 seconds.")
    magtag.peripherals.neopixels[1] = (255, 255, 0)  # Yellow: fetch error
    clear_screen()
    magtag.set_text("Error: Could not reach Grafana.", 1, False)
    magtag.refresh()
    magtag.exit_and_deep_sleep(60)

## Boot completed successfully - turn off LEDs before checking alert states or updating screen
magtag.peripherals.neopixel_disable = True

all_ok = state.is_all_ok
if state.has_criticals or state.has_alerts:
    alerting_user = True
    # turn on lights if error and leave on
    magtag.peripherals.neopixel_disable = False
    magtag.peripherals.neopixels.fill(button_colors[3])

    if alert_initial_tone:
        magtag.peripherals.play_tone(button_tones[3], 0.25)
elif state.has_warnings:
    magtag.peripherals.neopixel_disable = True
    if alert_initial_tone:
        magtag.peripherals.play_tone(button_tones[0], 0.25)


## update debugging boolean!
debug_messages = False
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
if all_ok and not all_ok_previous:
    if location_info["alert_default"] == "mute":
        alarm_silence_time = 99
    else:
        alarm_silence_time = 0
    alarm.sleep_memory[1] = alarm_silence_time

if debug_messages:
    print(
        "all_ok=",
        all_ok,
        "and location_info['alert_default']=",
        location_info["alert_default"],
        "and alarm_silence_time set to:",
        alarm_silence_time,
    )
    print(location_info)

## somewhere above here, start collecting errors and if any print them to screen


# Construct text to display on e-ink
display_text = state.get_display_summary()
if len(state.healthy_alerts) > 1:
    text_ok = f"{', '.join(state.healthy_alerts)} are ok."
elif state.healthy_alerts:
    text_ok = f"{state.healthy_alerts[0]} is ok."
else:
    text_ok = "All Ok  :-)"

print("Screen will display:", display_text)


## Prepare to wrap the text correctly by getting the width of each character for every font
# arial_12 = font_width_to_dict("fonts/Arial-Bold-12.bdf")
# arial_9 = font_width_to_dict("fonts/ArialMT-9.bdf")


## if active alert, yell for UI_wait_minutes and then sleep for shorter time than if no alert
if alerting_user:
    UI_wait_minutes = 3
    deep_sleep_minutes = refresh_interval_mins_alerting
elif alarm_wake == "timer":
    UI_wait_minutes = 0.1  # do we even want any wait time if this thing just wakes on interval?
    deep_sleep_minutes = refresh_interval_mins_ok
else:
    UI_wait_minutes = 1
    deep_sleep_minutes = refresh_interval_mins_ok

## if connected to desktop USB/serial always refresh fast (0.5 mins / 30s)
if DEBUG and supervisor.runtime.serial_connected:
    if alerting_user:
        UI_wait_minutes = 0.3  # make noise for longer, but still loop through faster than when not connected to usb
    else:
        UI_wait_minutes = 0.1

    deep_sleep_minutes = 0.5
    print("all_ok_previous stored in alarm.sleep_memory[0] =", alarm.sleep_memory[0])
    print("alarm_silence_time stored in alarm.sleep_memory[1] =", alarm.sleep_memory[1])


## Check status and alarm if needed
## refresh screen once an hour, during the first refresh interval (when not on serial debug)
if (
    not supervisor.runtime.serial_connected
    and all_ok_previous
    and all_ok
    and alarm_wake == "timer"
    and time_now_min >= refresh_interval_mins_ok
):
    print(
        "Not updating e-ink display, previous status and current status is 'all ok' and this isn't the first refresh of the hour (or I can't get time)"
    )
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

        # Display updated time, battery, and IP
        ip_display_string = f", IP: {wifi.radio.ipv4_address}" if wifi.radio.ipv4_address else ""
        magtag.set_text(
            f"{time_now_string}, {battery_display_string} {magtag.peripherals.battery:.2f}V{ip_display_string}",
            3,
            False,
        )

        # Display wake device text
        if all_ok:
            magtag.set_text(
                "List All Alerts                                                     Wake Device",
                4,
                False,
            )
        else:
            # this difference is mostly bc it isn't coded yet to show a long status screen when all alerts are not in ok state
            magtag.set_text(
                "                                                                    Wake Device",
                4,
                False,
            )

        if alerting_user:
            if alarm_silence_time == 99:
                magtag.set_text(
                    f"Alarm Silenced indefinitely, set to:\n   {alarm_silence_time}           {list_alert_silence_minutes[0]}           {list_alert_silence_minutes[1]}     indefinitely",
                    5,
                    False,
                )
            elif alarm_silence_time > 0:
                magtag.set_text(
                    f"Alarm Silenced for {alarm_silence_time} mins, set to:\n   {list_alert_silence_minutes[0]}           {list_alert_silence_minutes[1]}           {list_alert_silence_minutes[2]}     indefinitely",
                    5,
                    False,
                )
            else:
                magtag.set_text(
                    f"Silence alarm for X mins:\n   {list_alert_silence_minutes[0]}           {list_alert_silence_minutes[1]}           {list_alert_silence_minutes[2]}     indefinitely",
                    5,
                    False,
                )
        else:
            magtag.set_text(f"\nChecking status every {deep_sleep_minutes} minutes.", 5, False)

        # Display status of alerts
        if all_ok:
            magtag.set_text(display_text, 1, False)
        else:
            magtag.set_text(display_text, 0, False)

        magtag.refresh()

    except Exception:  # pylint: disable=broad-except
        print("Could not update display.")
        print("Trying again in 60 seconds.")
        alarm.sleep_memory[0] = 0  # aka: all_ok_previous = 0, signal for screen refresh
        magtag.exit_and_deep_sleep(60)

    print(
        "e-ink display updated, waiting",
        UI_wait_minutes,
        "minutes for button presses before sleeping",
    )

    ## https://docs.circuitpython.org/projects/magtag/en/latest/api.html#adafruit-magtag-peripherals

    # TODO what do we want menu to do?
    # set vibrate or noise mode?
    # get more info on an alert?
    # acknowledge alerts that came and went with no user interaction?
    # show actual values instead of just ok pending alerting?
    # if all ok, then one button will refresh screen with full list of all alerts as a sanity check

    time_UI_start = time.monotonic()
    # print(time_UI_start)

    # set up debounce buttons
    switches = []
    # pin=board.D11
    for b in magtag.peripherals.buttons:
        switches.append(Debouncer(b))

    # if alarm_silence_time > 0 and alerting_user:
    #    print("alarm silence time:",alarm_silence_time)

    while time.monotonic() - time_UI_start < 60 * UI_wait_minutes:
        for i, switch in enumerate(switches):
            switch.update()

            # can now check switch.value or rose or fell
            # if not switch.value:
            #    if alerting_user:
            #        alarm.sleep_memory[1] = list_alert_silence_minutes[i]
            #        print("Button value updated", i)
            #        print("setting to silence for", list_alert_silence_minutes[i])
            # print('not pressed')
            #    continue

            if switch.fell:
                # reset wait time when button pressed
                time_UI_start = time.monotonic()
                # Give feedback that button was pressed
                print(f"Button {chr(ord('A') + i)} pressed")
                magtag.peripherals.neopixel_disable = False
                magtag.peripherals.neopixels.fill(button_colors[i])

                # same noise for menu button presses? or how about for only active menu options?
                # magtag.peripherals.play_tone(button_tones[i], 0.25)
                # magtag.peripherals.play_tone(button_tones[0], 0.25)

                # respond to button presses on 'silence for X mins' menu
                if alerting_user:
                    alarm_silence_time = list_alert_silence_minutes[i]
                    magtag.peripherals.play_tone(button_tones[i], 0.25)
                    # print("Button ", i)
                    print("setting to silence for", list_alert_silence_minutes[i])
                    # TODO update eink display with something like 'Alarm silenced for list_alert_silence_minutes[i] mins. Change to:  '
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
                        # magtag.remove_all_text() # oh this remove all that add_text did, not sets to blank...
                        magtag.set_text("", 5, False)
                        # magtag.set_text("", 4, False)
                        # magtag.set_text("", 3, False) #keep status bar the same
                        # magtag.set_text("", 2, False)
                        magtag.set_text("", 1, False)
                        magtag.set_text("", 0, False)

                        # Display exit button text
                        # TODO make this actually work... prob need to spin off module to update screen
                        magtag.set_text(
                            "Return to Main                                                     Wake Device",
                            4,
                            False,
                        )
                        # magtag.set_text("Return to Main", 4, False)

                        # Display full list of all_ok alerts (which all are, if not in alerting_user state)
                        magtag.set_text(text_ok, 2, False)
                        magtag.refresh()
                        break

                    if screen_name == "long-ok":
                        print("Changing to display of main screen")
                        # Note screen change
                        screen_name = "main"

                        # Clear old text
                        # magtag.remove_all_text() # oh this remove all that add_text did, not sets to blank...
                        # magtag.set_text("", 5, False)
                        # magtag.set_text("", 4, False)
                        # magtag.set_text("", 3, False)
                        magtag.set_text("", 2, False)
                        # magtag.set_text("", 1, False)
                        magtag.set_text("", 0, False)

                        # Display updated time
                        # didn't change
                        # magtag.set_text(time_now_string + ", battery: {0:.2f}V".format(magtag.peripherals.battery), 3, False)

                        # Display wake device text
                        magtag.set_text(
                            "List All Alerts                                                     Wake Device",
                            4,
                            False,
                        )
                        # magtag.set_text("Wake Device", 4, False)

                        magtag.set_text(
                            f"\nChecking status every {deep_sleep_minutes} minutes.",
                            5,
                            False,
                        )

                        # Display concise all ok status
                        magtag.set_text(display_text, 1, False)
                        magtag.refresh()
                        break
                # if i == 1:
                # keep lights on for a shake after being pressed
                time.sleep(0.2)

            # still needed?? TODO
            if switch.rose:
                # reset wait time when button pressed
                time_UI_start = time.monotonic()
                # print("Button %c released" % chr((ord("A") + i)))
                break
        else:
            if alerting_user:
                # always set lights for alerts
                magtag.peripherals.neopixels.fill(button_colors[3])

                # see if silencing alarms
                if alarm_silence_time > 0:
                    # print("greater than zero")
                    continue
                else:
                    magtag.peripherals.neopixels.fill(button_colors[3])
                    # magtag.peripherals.play_tone(button_tones[0], 0.25)
                    # sleep(1)
                    magtag.peripherals.play_tone(button_tones[1], 0.25)
                    # magtag.peripherals.play_tone(button_tones[2], 0.25)
                    # magtag.peripherals.play_tone(button_tones[3], 0.25)
                    # magtag.peripherals.play_tone(button_tones[3], 0.25)
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
    print("alarm silence time was:", alarm_silence_time)
    if alarm_silence_time != 99:
        alarm_silence_time = alarm_silence_time - UI_wait_minutes - deep_sleep_minutes

        # sleep_memory can only be 0-255
        alarm_silence_time = max(alarm_silence_time, 0)

    alarm.sleep_memory[1] = int(
        alarm_silence_time
    )  # this int conversion eats away at actual sleep time faster if we have non-integer lengths (like during usb-connected state) but shrug?
    print("sleep memory 1 (alarm_silence_time) is now:", alarm.sleep_memory[1])


# print(time.monotonic() - time_UI_start)

## release buttons
magtag.peripherals.deinit()

## wake up after deep_sleep_minutes minutes to check status
time_alarm = alarm.time.TimeAlarm(monotonic_time=time.monotonic() + 60 * deep_sleep_minutes)

## wake up on button press - always refresh?
## yes? why else would I be pressing a button when I can already see the screen?
pin_alarm = alarm.pin.PinAlarm(pin=board.D11, value=False, pull=True)

print(supervisor.runtime.run_reason)

## sleep for deep_sleep_minutes (30s on serial, or 30m on battery) or until D11 button pressed
alarm.exit_and_deep_sleep_until_alarms(time_alarm, pin_alarm)
