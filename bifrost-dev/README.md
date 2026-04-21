![Logo](https://raw.githubusercontent.com/duvholt/bifrost/master/doc/logo-title-640x160.png)

# Bifrost Bridge [DEV VERSION]

Bifrost enables you to emulate a Philips Hue Bridge to control lights, groups
and scenes from [Zigbee2Mqtt](https://www.zigbee2mqtt.io/).

This is the DEVELOPMENT TESTING VERSION.

Please see the regular installation instructions here:

https://github.com/duvholt/bifrost-hassio/tree/master/bifrost

## Installation guide

  1. Install Bifrost Add-on
  2. Configure Bifrost (see next sections)
  3. Start Bifrost Add-on

## Configuring Bifrost

> [!IMPORTANT]
> You **must configure** bifrost before you can run it.

Bifrost requires a configuration file, `config.yaml`.

This file contains the essential settings needed to run the server. For example,
the IP and MAC address used by the server, and a list of the Zigbee2Mqtt servers
to connect to.

When using the Home Assistant Add-on, the file must be available inside the
docker container as `/config/bifrost/config.yaml`, which means you have to put
it here:

    /usr/share/hassio/homeassistant/bifrost

### If you have the popular "File Editor" add-on installed, do this:

  1. Open "File Editor"
  2. Go to the top level
  3. Create directory `bifrost` (*lowercase*)
  4. Inside that directory, create `config.yaml`

## Configuration example

Here's an example, for a server listening on `10.12.0.20/24`, with a Zigbee2Mqtt
server running on `10.0.0.100`:

```yaml
bridge:
  name: Bifrost
  mac: 00:11:22:33:44:55
  ipaddress: 10.12.0.20
  netmask: 255.255.255.0
  gateway: 10.12.0.1
  timezone: Europe/Copenhagen

z2m:
  server1:
    url: ws://10.0.0.100:8080
```

Please adjust this as needed.

> [!IMPORTANT]
> **Make sure** the "mac:" field matches the mac address on the network interface you want to serve requests from.

For details, see the [configuration reference](https://github.com/duvholt/bifrost/blob/master/doc/config-reference.md).

This mac address if used to generate a self-signed certificate, so the Hue App
will recognize this as a "real" Hue Bridge. If the mac address is incorrect,
this will not work. [How to find your mac address](https://github.com/duvholt/bifrost/blob/master/doc/how-to-find-mac-linux.md).

# Supported features

In the following, "z2m" is a shorthand for "Zigbee2Mqtt".

## Lights

| Action                         | . . . | in z2m                                                  | . . . | in Bifrost          |
|:-------------------------------|-------|:--------------------------------------------------------|-------|:--------------------|
| Add a light                    |       | Add the light in z2m, it should appear in bifrost       |       | *Not supported yet* |
| Remove a light                 |       | Remove the light in z2m, it should disappear in bifrost |       | *Not supported yet* |
| Rename a light                 |       | Rename the light in z2m, bifrost should reflect this    |       | *Not supported yet* |
| Toggle light (on/off)          |       | Supported, state will be updated in bifrost             |       | Supported           |
| Change color/color temperature |       | Supported, state will be updated in bifrost             |       | Supported           |
| Set startup parameters         |       | Supported, state will be updated in bifrost             |       | *Not supported yet* |

## Groups (rooms)

| Action         | . . . | in z2m                                                   | . . . | in Bifrost                                     |
|:---------------|-------|:---------------------------------------------------------|-------|:-----------------------------------------------|
| Add a group    |       | Add the group in z2m, it should appear as a room bifrost |       | *Not supported yet**                           |
| Remove a group |       | Remove the group in z2m, it should disappear in bifrost  |       | *Not supported yet**                           |
| Rename a light |       | Rename the group in z2m, bifrost should reflect this     |       | Room names can be specified in the config file |
| Control lights |       | Supported by z2m, although not in the web ui             |       | Supported                                      |

## Scenes

| Action           | . . . | in z2m                                                  | . . . | in Bifrost                                                             |
|:-----------------|-------|:--------------------------------------------------------|-------|:-----------------------------------------------------------------------|
| Add a scene      |       | Add the scene in z2m, it should appear in bifrost       |       | Fully supported. Adding a scene in Bifrost creates the scene in z2m!   |
| Remove a group   |       | Remove the scene in z2m, it should disappear in bifrost |       | Fully supported. Removing a scene in Bifrost removes the scene in z2m! |
| Rename a light   |       | Rename the group in z2m, bifrost should reflect this    |       | Supported                                                              |
| Activate a scene |       | Supported by z2m, bifrost should reflect this           |       | Supported                                                              |

# F.A.Q

## Will Bifrost work without Zigbee2Mqtt?

Not in the near future. Bifrost is closely integrated with Zigbee2Mqtt, to provide good, reliable performance.

Development is underway to be able to support multiple types of backends at some future
point, but only the z2m backend is being developed.

## Will Bifrost be able to use my switches / motion sensors?

Currently, no. However, Zigbee2Mqtt is able to use these, and it's
absolutely possible to use such devices via e.g. Home Assistant, even while
using Bifrost at the same time to control your lights.

We hope to support switches and motion sensors in a future Bifrost release.

## Will Bifrost ever support the Hue (HDMI) Sync Box, or true Entertainment Mode?

Yes! Work is well underway.

The Bifrost project has acheived several breakthroughs in reverse-engineering
the proprietary Hue Entertainment Mode protocols. This work has been made
possible by your donations, which have been invested in necessary equipment.

The newest `bifrost-dev` add-on is the first version of any Open Source
software, to ever support Entertainment Mode. Please help us test it, and let us
know what you think!

# Donors

I would like to personally thank the people who have helped this project financially.

Your support has resulted in major breakthroughs, and we all get to enjoy the results.

The following people have donated a total of 25€ or more:
  - Alexa & Peter Miller
  - Modem-Tones
  - Rohan Kapoor
  - thk

In particular, I would like to thank Rohan Kapoor for his very generous donation, which
covered the cost of a Hue Sync Box!



# Full changelog

### 2025-05-19: `chrivers/web-user-interface`

This is a preview of the upcoming Bifrost web interface!

Eventually, this will be more fleshed out, but already it allows controlling
lights and rooms, and experimental (and work-in-progress) support for
dynamically connecting to new Z2m servers.

> [!IMPORTANT]
> To use this early preview of the web interface with the Bifrost Home Assistant
> add-on, please add the following setting to your `config.yaml`:

```yaml
bifrost:
  frontend_dir: /app/frontend
```

After this change (and a restart of Bifrost), you should be able to visit the
web interface in your browser. It is available on the ip specified under
`bridge` in `config.yaml`.

****************************************

### 2025-05-19: `chrivers/z2m-new-features`

After the many fundamental and infrastructure changes in Bifrost, it's finally
time for a set of changes that add new features!

This one is particularly exciting, as it contains a number of exciting additions
that directly improve the end-user experience.

Bifrost is now able to:

 - Update existing scenes (closes #85)
 - Delete lights
 - Add new lights to the bridge
 - Add new lights to rooms
 - Remove lights from rooms
 - Make lights pulse when selected
 - Learn scenes with gradient colors

All these actions now work from the api, including directly from the Hue app!

No more jumping back and forth between the app and z2m to perform common
maintenance tasks!



# Now on Ko-fi! Donations welcome :-)

Developing software for the hue ecosystem is a fun, but pretty expensive hobby.

If you would like to toss a few dollaridoos in the hat, I've set up a Ko-fi accont:

[![Link to Ko-Fi donation page](https://raw.githubusercontent.com/chrivers/bifrost-hassio/refs/heads/master/kofi.png)](https://ko-fi.com/L4L819GOTY)

All donations will go towards new equipment for testing and development.

# Questions?

Questions, feedback, comments? Join us on discord

[![Join Valhalla on Discord](https://discordapp.com/api/guilds/1276604041727578144/widget.png?style=banner2)](https://discord.gg/YvBKjHBJpA)
