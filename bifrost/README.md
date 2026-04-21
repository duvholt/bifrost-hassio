![Logo](https://raw.githubusercontent.com/duvholt/bifrost/master/doc/logo-title-640x160.png)

# Bifrost Bridge

Bifrost enables you to emulate a Philips Hue Bridge to control lights, groups
and scenes from [Zigbee2Mqtt](https://www.zigbee2mqtt.io/).

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


# Changelog (11 most recent changes)

### 2025-05-09: `chrivers/apiv1-entertainment-mode`

Implement complete support for entertainment zones ("sync mode") for the v1 api, including the obsolete (but apparently still used) streaming v1 api!

This fixes support for at least the following:
 - Philips Ambilight TVs (..ironically)
 - The iLightShow app for streaming blinkenlights

This change also improves logging and error handling related to sync streaming.

****************************************

### 2025-05-04: `chrivers/sync-stream-fixes`

Major rework of entertainment streaming ("sync mode") for Bifrost!

- Now supports both XY and RGB mode
- Fix stream closing on DTLS timeout/disconnect (no longer left lingering in "active" state).
- Improves compatibility with Hue Sync Box
- Add support for configurable streaming fps limit for each z2m backend
- Increase timeout to match Hue Bridge
- Adjust the smoothing factor (fade speed) to match the frame rate!
- ..this smoothing factor adjustment is not even supported by a Hue Bridge! Only Bifrost :-)

****************************************

### 2025-05-04: `chrivers/ssdp-upnp-fix-uuid`

This change fixes ssdp/upnp discovery of Bifrost bridges.

Incorporating fixes from our forked version of tokio-ssdp makes Bifrost respond properly to M-SEARCH requests.

This makes several types of devices that were previously unable to find Bifrost, able to do so. One example is Philips Ambilight TVs.

Note: Because of a buggy implementation of the Hue protocol in those Ambilight TVs, they are still unable to use Bifrost as a streaming target. But at least they are now able to find Bifrost.

****************************************

### 2025-05-02: `chrivers/bifrost-api-crate`

This is a major internal refactoring, moving common code needed for
communication with Bifrost into a separate library ("crate").

Existing crates are reworked to have "features" (compile flags), that allow
partial functionality to be selected at compile time.

In the future, this will allow code to be shared between the backend, and an
upcoming web frontend.

This change also adds support for adding/removing lights from a room, directly from the hue app!

****************************************

### 2025-05-02: `chrivers/z2m-refactoring`

This change cleans up a bunch of internal code related to the z2m backend, and
makes two important user-facing improvement:

#### Status updates
Previously, as part of supporting hue effects (candle, fireplace, etc), we would
encode all light update requests to hue lights as the hue-specific
`HueZigbeeUpdate` data format.

This is the data format a Hue Bridge (mostly) uses to control lights, and is a
quick and effective way to update all light settings at once, even the
vendor-specific extensions.

However, Zigbee2MQTT does not know how to report state updates when this update
method is used. It just sees a "raw" message, and passes it along.

So until we land better support in Zigbee2MQTT for dealing with these kinds of
state updates, split light updates into two parts: one for regular light
properties (on/off, brightness, etc), and one optional part for hue-specific
effects.

The hue-specific update is then only sent if needed and supported.

This makes z2m able to report changes to common properties again, but has the
slight downside of sending two messages, if hue-specific extensions are used.

Hopefully over time this can be simplified, but for now this is an improvement
over the previous situation.

#### Z-Stack entertainment mode fix

Previously, "z-stack" based adaptors did not work with entertainment mode,
because of the way the highly specialized Zigbee frames are constructed.

This update changes how entertainment mode frames are constructed, allowing
adapters in the Z-Stack family to join the fun.

****************************************

### 2025-04-29: `chrivers/better-eventstream`

When hue objects are updated, the even stream offers live updates of changed properties, to allow clients (e.g. the Hue App) to track the changes over time.

So far, our mode of these eventstream blocks have been the same as for PUT updates.

It turns out this is *almost* correct, but subtle wrong.

Instead, the event streams are based on diffing json values, and including new and changed sub-values.

Also, certain properties should *always* be included, if present. Most notably, the `.owner` field (see #76, which might be fixed by this.)

Other clients might also be affected (improved) by this (see #122)

****************************************

### 2025-04-29: `chrivers/timezone-support`

Implement proper timezone support.

With these changes, the `bifrost.timezone` field in `config.yaml` is actually used to calculate the `.localtime` time field of the API config.

Multiple people have reported that this support (combined with *actually* setting the correct timezone), resolves their problems with connecting to Bifrost (see for example https://github.com/chrivers/bifrost/issues/88)

****************************************

### 2025-04-29: `chrivers/mdns-upnp-fixes`

- Entirely rework support for mDNS and SSDP/UPnP
 - Fixed a bug where mDNS reported an invalid hostname for Bifrost
 - Reworked my fork of tokio-ssdp crate, to make it respond properly
 - Add support for "upgrading" firmware through Hue App!

You read the last one right - if there's a new mandatory version upgrade before the automatic version check picks it up (it checks once per day), the Hue app will offer to upgrade the bridge firmware.

Simply say yes to this exciting prospect! Code has been added to Bifrost that recognizes this update pattern, and re-checks the version number.

The end result is that the Hue app *thinks* it has updated the bridge, which is all we need.

****************************************

### 2025-04-29: `chrivers/predictable-deterministic`

Manually impl Hash for RType, to maintain predictable output

if at all possible, RType::deterministic() should produce the same uuid in later versions of Bifrost as the current one.

If not, everybody will see bad artefacts such as the infamous duplicate group issue, that has happened a few times by accident - and now we found out why.

When reordering (or indeed just adding/removing) a variant of RType (Room, Scene, etc), all following variants would get a new index, and this meant a new hash.

Now Hash is implemented manually, and a regression test has been added to prevent future accidents.

****************************************

### 2025-04-25: `chrivers/hue-route-refactoring`

Refactor all route handling for Hue api v2 ("clip").

Previously, each sub-scope (`/light`, `/scene`, etc) implementer their own routing for that particular set of routes.

This works, but is highly repetitive, and was difficult to manage.

Now, there is only a single router component for the clip api, which dispatches to the relevant handlers for the parts that are implemented in Bifrost.

The biggest change (apart from being much easier to maintain) is that *all* routes are now very cleanly marked as one of

  1) Supported
  2) "Missing" (allowed by protocol, but not supported by Bifrost)
  3) "Denied" (not allowed by protocol, and correctly rejected by Bifrost)

Not only does this prevent duplicated bits of code and boilerplate, it also reduces risk of accidental divergence between various parts of the route handling.

****************************************

### 2025-04-22: `chrivers/legacy-api-fixes`

This update fixes bugs and adds workarounds for the legacy api.

In particular, this greatly improves compatibility with Hue Essentials, which
now works quite a bit better:

 - Fix brightness scaling: Legacy api uses 0..254, while the new api uses 0..100
 - Fix "group 0" handling: The bridge has a virtual "group 0", which represents all groups on the bridge
 - Add workaround for scenes without `.speed` field (Hue Essentials does this), so we don't get an error

## Full changelog

For the full changelog, please click on the "Changelog" link in the upper left corner.

# Now on Ko-fi! Donations welcome :-)

Developing software for the hue ecosystem is a fun, but pretty expensive hobby.

If you would like to toss a few dollaridoos in the hat, I've set up a Ko-fi accont:

[![Link to Ko-Fi donation page](https://raw.githubusercontent.com/chrivers/bifrost-hassio/refs/heads/master/kofi.png)](https://ko-fi.com/L4L819GOTY)

All donations will go towards new equipment for testing and development.

# Questions?

Questions, feedback, comments? Join us on discord

[![Join Valhalla on Discord](https://discordapp.com/api/guilds/1276604041727578144/widget.png?style=banner2)](https://discord.gg/YvBKjHBJpA)
