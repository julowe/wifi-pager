# SPDX-FileCopyrightText: 2021 Eva Herrada for Adafruit Industries
#
# SPDX-License-Identifier: MIT

## # TODO:
## [] add text next to qr code to describe it (eg paypal or venmo etc)
## [] make buttons switch between qr codes (and add labels above buttons)
## [] Look at neopixel color cycling (for when magtag is plugged in to power source)

# import random
# import ssl
# import gc
# import wifi
# import socketpool
# import adafruit_requests as requests
import time
from adafruit_magtag.magtag import MagTag

# # Get wifi details and more from a secrets.py file
# try:
#     from secrets import secrets
# except ImportError:
#     print("WiFi secrets are kept in secrets.py, please add them there!")
#     raise

# Initialize magtag object
magtag = MagTag()

# magtag.set_background("bmps/oshwa_full.bmp")
magtag.set_background("bmps/cpu-sun.bmp")

# # Set up WiFi
# wifi.radio.connect(secrets["ssid"], secrets["password"])
# print(f"Connected to {secrets['ssid']}!")
# print("My IP address is", wifi.radio.ipv4_address)
#
# socket = socketpool.SocketPool(wifi.radio)
# https = requests.Session(socket, ssl.create_default_context())
#
# # Paste your API token below
# TOKEN = "YOUR_API_TOKEN"


def font_width_to_dict(font):
    # Reads the font file to determine how wide each character is
    # Used to avoid bad wrapping breaking the QR code
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


# # Get first 300 items, saving only the OSHWA UIDs. The first 300 are also used to find the
# # number of requests that will need to be made.
# # This was done this way since if the items themselves were all asked for and stored, the MagTag
# # would run out of memory. If we just got the number of total projects and chose a random number,
# # that also wouldn't work as you can only get individual projects with an OSHWA UID and these UIDs
# # are prefixed by the country they were registered in, thus making getting it with a simple number
# # in-between 1 and the total number of registered projects impossible.
# URL = "https://certificationapi.oshwa.org/api/projects?limit=300"
#
# print(URL)
#
# payload = {}
# headers = {"Content-Type": "application/json", "Authorization": f"Bearer {TOKEN}"}
#
# oshwaID = []
#
# print("Getting number of projects and first set of 300 projects")
# with https.get(URL, headers=headers, data=payload) as response:
#     R_JSON = response.json()
#     total = int(R_JSON["total"])
#     print(f"{total} Projects")
#     for i in R_JSON["items"]:
#         oshwaID.append(i["oshwaUid"])
#     R_JSON.clear()
#     R_JSON = None
#     gc.collect()
#
# # Gets the rest of the OSHWA UIDs
# print(len(oshwaID))
# for i in range(int(total / 300)):
#     print(f"Getting request {i+2}")
#     url = (
#         f"https://certificationapi.oshwa.org/api/projects?limit=300&offset={3*(i+1)}00"
#     )
#     with https.get(url, headers=headers, data=payload) as response:
#         R_JSON = response.json()
#         for item in R_JSON["items"]:
#             oshwaID.append(item["oshwaUid"])
#         R_JSON.clear()
#         R_JSON = None
#         gc.collect()
#     print(f"{len(oshwaID)} IDs gathered")
#
# # Select the UID that will be displayed
# selected = random.choice(oshwaID)

# # Get the project that will be displayed
# url = f"https://certificationapi.oshwa.org/api/projects/{selected}"
# response = https.get(url, headers=headers, data=payload)
#
# selected = response.json()[0]
#
# # Filters out characters that the API or the MagTag itself isn't handling correctly
# for char in range(1, 32):
#     selected["projectDescription"].replace(chr(char), "")
#
# selected["projectDescription"] = (
#     selected["projectDescription"]
#     .replace("&#x27;", "'")
#     .replace("&amp;#x27;", "'")
#     .replace("&#x2F;", "/")
#     .replace("&quot;", '"')
#     .replace("’", "'")
# )


magtag.add_text(
    text_font="fonts/Arial-Bold-12.bdf",
    text_position=(5, 0),
    text_scale=1,
    line_spacing=0.7,
    text_anchor_point=(0, 0),
)
# magtag.add_text(
#     text_font="fonts/Arial-Bold-12.bdf",
#     text_position=(5, 25),
#     text_scale=1,
#     line_spacing=0.7,
#     text_anchor_point=(0, 0),
# )

magtag.add_text(
    text_font="fonts/ArialMT-9.bdf",
    text_position=(5, 80),
    text_scale=1,
    line_spacing=0.6,
    text_anchor_point=(0, 0),
)

# Create the QR code
# url = f"https://certification.oshwa.org/{selected['oshwaUid'].lower()}.html"
url = "https://venmo.com/code?user_id=1777124390207488863&created=1654029427.873137"
magtag.graphics.qrcode(url, qr_size=4, x=160, y=-6)

# Prepare to wrap the text correctly by getting the width of each character for every font
arial_12 = font_width_to_dict("fonts/Arial-Bold-12.bdf")
arial_9 = font_width_to_dict("fonts/ArialMT-9.bdf")

# # SPDX-FileCopyrightText: 2017 Scott Shawcroft, written for Adafruit Industries
# #
# # SPDX-License-Identifier: Unlicense
# import time
# from adafruit_magtag.magtag import MagTag
#
# magtag = MagTag()
#
# magtag.add_text(
#     text_position=(
#         50,
#         (magtag.graphics.display.height // 2) - 1,
#     ),
#     text_scale=3,
# )
#
# magtag.set_text("Hello World")
#



# Set the text. On some characters, this fails. If so, run the whole file again in 5 seconds
try:
    magtag.set_text("Don't Forget \nTo Tip Your \nBartender", 0, False)
    magtag.set_text("Otherwise they might just not tell \nyou if you're walking in to \na death trap", 1)
    # magtag.exit_and_deep_sleep(3600)
except Exception:  # pylint: disable=broad-except
    print("Could not set title or description: unsupported glyphs.")
    print("Trying again in 10 seconds.")
    magtag.exit_and_deep_sleep(10)

button_colors = ((255, 0, 0), (255, 150, 0), (0, 255, 255), (180, 0, 255))
button_tones = (1047, 1318, 1568, 2093)

while True:
    for i, b in enumerate(magtag.peripherals.buttons):
        if not b.value:
            print("Button %c pressed" % chr((ord("A") + i)))
            magtag.peripherals.neopixel_disable = False
            magtag.peripherals.neopixels.fill(button_colors[i])
            magtag.peripherals.play_tone(button_tones[i], 0.25)
            break
    else:
        magtag.peripherals.neopixel_disable = True
    time.sleep(0.01)
