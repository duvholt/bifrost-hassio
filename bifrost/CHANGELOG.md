# Changelog

This is the stable version of Bifrost.

There is a development testing version available (the `bifrost-dev` add-on). New
features and code that is still being developed is typically merged to
`bifrost-dev` first, and as such it is more frequently updated.

If you get any errors while using Bifrost, consider trying out `bifrost-dev`,
and see if that solves the problem.

We hope you will like Bifrost!

### 2026-05-03: `duvholt/fix/z2m-device-effect`

Fixes parsing of new device effects introduced in zigbee2mqtt 2.10.0. This caused parsing errors for most Philips Hue light updates.

****************************************

### 2026-05-02: `Intecpsp/fix/websocket-stability`

Clean up disconnected websocket connections in Bifrosts websocket API

****************************************

### 2026-05-02: `Intecpsp/fix/ent-stream-reconnect`

Clean up stale entertainment stream on Z2M reconnect

****************************************

### 2025-06-02: `duvholt/timed-effects`

Implement timed effects for Hue lights. This enables the effects "sunrise" and "sunset" using the https api.

****************************************

### 2025-05-27: `duvholt/light-transition`

Implement support for transition (color, brightness)

****************************************

### 2025-05-25: `duvholt/wake-up-sunrise-hue-crate`

Hue crate changes needed for implementing wake-up automation

****************************************

### 2025-05-24: `chrivers/sigterm-handling`

Since Bifrost is running as pid 1 in docker, we need to catch SIGTERM to perform clean shutdowns without waiting for docker timeout to stop the container.

For example, this makes the "stop" button in Home Assistant react quickly, and perform a clean shutdown.

****************************************

### 2025-05-24: `chrivers/unit-test-improvements`

Add unit test coverage for almost all lines of code in the `hue` crate, that is not a data model or constructor.

This work is a bit tedious, but very exciting for the maintainability of Bifrost.

The `hue` crate contains a significant amount of code related to handling events, colors, colorspaces, gamma correction, etc.

All of this code is now tested against our assumptions of what it *should* do.
This obviously doesn't test if our assumptions are correct, but at least now
the code can't easily deviate from them.

Adding these unit tests uncovered a number of minor errors that have been fixed:
- Fix `HueEntSegmentLayout::pack()`, which produced wrong output (currently not used in Bifrost)
- Make `HueStreamPacket::parse()` not panic on invalid input
- Make `Clamp::unit_to_u8_clamped()` perform proper rounding.
- Make `XY::from_rgb_unit()` fall back to `D50_WHITE_POINT`, not `D65_WHITE_POINT`.

Overall, these are minor papercuts that have not noticeably affected the functionality of Bifrost. Nevertheless, it is nice to have good test coverage.

****************************************

### 2025-05-24: `chrivers/service-instancing`

Rework `svc` ("service") crate, to support templated services.

These are analogous to systemd template service, in which a service name can contain `@` to indicate it is a template.

In this way, instead of manually registering `foo-1`, `foo-2`, etc,
we can register `foo@`, and then start instances `1`, `2`, etc.

This makes service management cleaner and simpler, and provides a way to recognize groups
of related services.

****************************************

### 2025-05-24: `chrivers/z2m-new-features`

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

****************************************

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

****************************************

### 2025-04-23: `chrivers/http-log-ip`

Add logging of client ip address and protocol (http/https) for http requests

****************************************

### 2025-04-22: `chrivers/fix-error-handling`

Fix error handling: We accidentally double-encoded the error as json, leading to, ironically, error errors.

This should improve api responses when an error is returned. This is mostly a technical fix, with little user-facing impact.

****************************************

### 2025-04-21: `chrivers/websocket-tls`

Implement support for using TLS with websockets ("wss://" urls)

A few users are reporting that they use TLS for their z2m websockets, and this
has previously not been supported.

With these changes, the z2m websocket urls can be specified as "wss://..."
instead of "ws://..." to enable TLS.

Additionally, a new (optional) z2m per-server config option,
`disable_tls_verify` has been added, to optionally turn TLS verification
off. This is useful for certain testing scenarios, where self-signed
certificates might be used.

****************************************

### 2025-04-21: `chrivers/upnp-description-xml`

Implement support for UPNP and SSDP in Bifrost!

These four-letter scrabble winners are discovery protocols, meant to improve auto-detection by clients.

Previously, Bifrost only supported mDNS - yet another such protocol - which is what most (but not all) clients use.

Specifically, Hue Essentials requires SSDP. Not only that, but Hue Essentials sends broken discovery requests, so special workarounds have had to be implemented to support it.

We still know of at least 1 device that is not yet able to find a Bifrost bridge, even with these improvements.

If you have a similar problem, please let us know.

In any case, this should be a clear improvement in how easy it is to connect to Bifrost.

****************************************

### 2025-03-17: `chrivers/api-v1-hs-color-mode`

Implement support for converting Hue/Saturation ("HS") light updates to modern XY-based values.

This enables support for receiving Hue/Sat light updates over API V1, specifically for `ApiLightStateUpdate` (`PUT` requests for controlling lights).

When such a request is received, it is converted to XY mode, and handled from there.

****************************************

### 2025-03-12: `chrivers/entertainment-reversing`

> [!IMPORTANT]
> ***This is the big one people have been waiting for!*** :-)

After spending countless hours reverse-engineering the proprietary Zigbee data
format used by Philips Hue lights for "Entertainment Mode", *even countlesser*
hours have gone into implementing support in Bifrost.

Today, I am proud to announce that Bifrost is the **first program in the world**
to have an entirely Open Source (Free Software) implementation of Hue
Entertainment mode!

This has been a monumental effort. Before starting this work, the Bifrost code
base was about 7200 lines of code. Now, it is over 15000 lines!. In other
words, implementing entertainment mode more than doubled the code base!

I think it's fair to say, that this was more complicated than anticipated.

To make this work at all, the Zigbee2Mqtt project was updated with patches from
myself (@chrivers), @danielhitch, and the author of Zigbee2Mqtt, @koenkk.

Special thanks to @koenkk for taking time out of his busy schedule, to help us
get the necessary bits in place. The new code was first released in version 2.1.1.

> [!WARNING]
> Zigbee2Mqtt MUST BE AT LEAST version 2.1.1 for Entertainment Mode to work.

> [!IMPORTANT]
> Even though version 2.1.1 is the minimum version, version 2.1.3 or greater is
> highly recommended, since some important bugs were fixed after version 2.1.1.

This is the very first of Bifrost that supports Entertainment Mode at all, so
please bear with us while we iron out any bugs or rough edges.

Should work:
 - Creating Entertainment Areas from the Hue App.
 - Updating Entertainment Area settings.
 - Adding lights or 7-segment strips to entertainment areas.
 - Streaming to Entertainment Areas from "Hue Sync for PC" (tested).
 - Streaming to Entertainment Areas from Play HDMI sync box 8K (tested).
 - Streaming to one or more lights.
 - Streaming to a combination of lamps and light strips.

Perhaps working: (please let us know what your experience is!)
 - Adding 3-segment strips to entertainment areas.
 - Adding non-color lights to entertainment areas.
 - Streaming to Entertainment Areas from Play HDMI sync box (older, non-8K version).

Not yet working:
 - Adjusting "stream mode" ("From Device" vs "From Bridge")
 - Adjusting "relative brightness" for lights
 - Streaming in XY color mode (most things seem to use RGB mode)

****************************************

### 2025-03-17: `chrivers/hue-crate-entertainment-mode`

This pull request implements the necessary code in the hue crate, to support decoding and encoding of Hue Entertainment Mode (also known as "Sync mode").

There are two major new areas of support:
 - Encoding and decoding the DTLS stream going to the bridge (from a sync client)
 - Encoding and decoding the specialized Zigbee frames going from the bridge, to the lights.

Especially the latter part builds on the previous work done by the Bifrost project, to reverse engineer the Hue Entertainment zigbee format.

This pull request does not in itself add entertainment mode support to the Bifrost bridge. It only adds required library code needed to implement that support in an upcoming pull request.

****************************************

### 2025-03-16: `chrivers/svc-crate`

Implement a new crate ("svc") to manage rust-based micro-services.

Bifrost consists of a number of "things" running independently, while performing work either on request, on a timer, or some combination of the two.

Synchronizing, coordinating and sharing information between all these various parts of Bifrost, takes up a non-trivial amount of the codebase.

That's why we are introducing a dedicates library (a "crate", in rust terminology) for managing services that implement a standardized interface, specifically, the `Service` trait.

This makes it possible to share start/run/stop handling for all services, as well as more advanced features like policies ("if a service fails, what should happen?"), error handling, dependencies, and liveness checks.

This PR introduces and builds up the "svc" crate, but does not change Bifrost to use it, yet.

****************************************

### 2025-03-16: `chrivers/api-v1-improvements`

This PR combines a number of minor improvements to the Hue V1 api implementation.

 - The virtual "daylight sensor" present in the v1 api is now partially implemented. It is now present in the api output, which is an improvement for programs that expected it to be present, but it does not yet do anything.
 - The virtual "group 0", representing all lights on a bridge, is now implemented for the v1 api.
 - Usernames for api v1 can now be any string, instead of only valid uuids.
 - The "create user" endpoint can now reply with the "client key" needed for Entertainment Mode / Sync streams.
 - The reported capabilities have been increased to report lots of space for activities.

****************************************

### 2025-03-15: `chrivers/hue-and-zcl-crates`

This is one of those pull requests that are almost invisible for end users, but important for the developers of Bifrost.

With this change, several pieces of Bifrost are split out into independent packages ("crates" in rust parlance).

This includes:

 - `crates/zcl`: Zigbee Cluster Library crate. This contains code needed to encode/decode Philips Hue zigbee messages.
 - `crates/hue`: Contains data models and functions needed to work with Philips Hue lights, including color space handling, gradient encodings, and more.

Improving the code this much was a lot of work: 56 commits, adding 1630 lines and removing 265.

New features: None :-P

****************************************

### 2025-03-13: `chrivers/docker-ca-certificates` + `chrivers/dockerfile-update`

This fixes the docker build process for Bifrost, which was accidentally broken
during the rush of recent, big merges coming in.

 - Add missing `libssl-dev` package for compile step
 - Add missing `libssl3` package for runtime container
 - Add missing bind mounts for building bifrost
 - Upgrade rust version for build container
 - Add missing `ca-certificates` package, to make hue api version checking
   function correctly again.

With all these checks, the docker release of Bifrost should be back in a good
state.

****************************************

### 2025-03-12: `chrivers/light-status-and-effects`

After having reverse engineered and documented the proprietary [Hue Zigbee message formats](https://github.com/chrivers/bifrost/pull/93), we can start using this knowledge in Bifrost.

This change updates the z2m backend, to enable support for all "Hue Effects" as seen in the Hue app.

In other words, effects like "Candle", "Fireplace", "Opal", etc, are now fully supported on Hue lights connected over z2m. Ordinary light updates (for brightness, color, color temperature, etc) are now also controlled over this format, allowing for a faster, more efficient way to control Philips Hue lights.

Since only Philips Hue lights support these vendor-specific Zigbee messages, all other lights will use the traditional code path from previous versions of Bifrost.

****************************************

### 2025-03-11: `chrivers/zigbee-docs`

This merge request introduces significant enhancements to the documentation of the Bifrost project, specifically focusing on the reverse engineering and detailed description of the Hue Zigbee message formats.

1. **New Document: Hue Zigbee Clusters**
    - Added `hue-zigbee-clusters.md`, providing comprehensive information on custom Zigbee messages for Hue devices, focusing on lights.
    - Covers clusters such as Hue Button events, Entertainment zones, Gradients, Effects, and Animations.
    - Includes detailed descriptions of cluster-specific commands and attributes with byte structures and examples.

2. **Entertainment Clusters Documentation**
    - Detailed documentation of the Entertainment cluster (0xFC01), describing commands for updating entertainment zones, synchronizing entertainment zones, retrieving segment mappings, and configuring segments for entertainment mode.
    - Provides byte structures and examples for these commands.

3. **Gradients, Effects, and Animations Clusters**
    - Descriptions of the Gradients, Effects, and Animations cluster (0xFC03), including combined state commands and various attributes.
    - Sample values and descriptions help identify properties supported by different Hue devices.

4. **Enhancements to Existing Documentation**
    - Updated `hue-zigbee-format.md` with clarifications and additional details.
    - Improvements include specifying `zigbee::EffectType`, adding examples for unpacking and packing color coordinates, and refining scaling values for color coordinates.

****************************************

### 2025-03-11: `chrivers/the-big-backend-refactor`

The Big Backend Refactor

Rework the infrastructure of Bifrost, to make a clean separation of Zigbee2Mqtt-specific code into a z2m backend module.

At the same time, a new common interface is defined, that backends must implement.

This opens the door for hypothetically supporting multiple types of backends at some future time. However, Zigbee2Mqtt is still the only supported for now.

****************************************

### 2025-03-11: `chrivers/axum-fixes`

Upgrade to Axum 0.8, and clean up dependencies to avoid unnecessary/duplicate crates.

****************************************

## 2025-03-02: `duvholt/state-version-fix`

Use `get_software_version` when patching bridge version.

This fixes a bug where the hue application disconnects periodically, after a version update.

****************************************

## 2025-02-13: `FabioCanavarro/Add-Docker-Pull-Method`

README: Add Docker pull installation method

****************************************

## 2025-02-13: `waywardmonkeys/reduce-typo-count`

Reduce typo count - big thanks to @waywardmonkeys

****************************************

## 2025-02-04: `chrivers/gradient-support`

Experimental support for gradient light strips!

Helped by generous donations from the community, I have been able to purchase a
hue gradient light strip.

After much work, this is now in a mostly-working state.

Support for this is pretty involved, and requires somewhat complicated math to
do color space conversion between XYZ, XYY and RGB.

Some artifacts are expected, and so far this has only been tested with a single
hue led strip, the LCX005 ("Hue Light Strip for PC").

Feedback very welcome. Please let me know if this works for you, and which
lights you have tried this on :)

****************************************

## 2025-02-04: `chrivers/json-extractor-workaround`

This fixes a recurring problem with poorly-implemented client programs (i.e, not
the Hue app or Home Assistant).

Programs like Free@Home, Hue Essentials and OnSwitch do not consistently send
the correct `Content-Type` headers, causing Bifrost to reject their API requests:

 - https://github.com/chrivers/bifrost/issues/70
 - https://github.com/chrivers/bifrost/issues/69
 - https://github.com/chrivers/bifrost/issues/25

With this change, Bifrost ignores the Content-Type header, and tries to decode
Json whenever that is the expected input format.

****************************************

## 2025-02-01: `FabioCanavarro/add-build-essential-note`

README: Added build-essential note and Bash syntax highlighting for shell commands

****************************************

## 2025-01-29: `duvholt/device-with-slash`

Christian Duvholt is back with another improvement. This merge request adds
support for Zigbee2Mqtt device names with a "/" in them.

****************************************

## 2025-01-29: `chrivers/zigbee-format-doc`

The Bifrost project achieved a breakthrough in understanding the
manufacturer-specific Zigbee protocols used for Philips Hue lights. These are
required for proper gradient strip support, and have now been fully documented
for the first time ever!

****************************************

## 2025-01-26: `duvholt/sse-resume`

Christian Duvholt fixed a long-standing annoyance in Bifrost, by making event
stream able to resume from timestamp.

This improves how quickly the hue app is updating after short breaks (i.e,
turning off your phone screen for a short while).

****************************************

## 2025-01-25: Internal device database

Bifrost now has a built-in table of product data for known hue devices, allowing
it to emulate hue bridges more precisely.

****************************************

## 2025-01-25: Fix for iHueConnect app for iPhone

Discord users Alexa and Peter Miller reported an error with the iPhone app "iHue Connect".

After some research, it was discovered that iHue Connect, for unknown reasons,
sends an invalid api request, before proceeding to start.

By emulating the bridge response to the junk request, the app accepts Bifrost as
a real hue bridge, thus making the app work.

****************************************

## 2025-01-19: Zigbee2mqtt version 2.x support

Zigbee2mqtt version 2.x was released recently. It brings a number of changes,
including stricter requirements for connecting to the websocket.

This version of bifrost has support for z2m 2.x.

Please let us know how it works for you!

****************************************

## 2025-01-19: `duvholt/actions-permissions-fix`

Re-add GitHub Actions permissions block

****************************************

## 2025-01-19: Experimental support for `aarch64` architecture

Thanks to a [contribution from
@duvholt](https://github.com/chrivers/bifrost/pull/54) bifrost docker images are
now available for `aarch64`. This is the 64-bit ARM architecture, used by
Raspberry Pi and many other Single Board Computers.

Please let us know how Bifrost for ARM works for you!

****************************************

## 2025-01-17: Hue API model and emulation improvements

Improved compatibility and features based on these branches:

 - `duvholt/arm64` + `duvholt/actions-permissions-fix`
 - `chrivers/device-update`
 - `chrivers/normalization`
 - `chrivers/z2m-fixes3`
 - `chrivers/z2m-fixes2`

****************************************

## 2025-01-17: `chrivers/normalization`

Chrivers/normalization

****************************************

## 2025-01-17: Multiple bug fixes for rare edge cases

Several users reported edge cases in parsing the z2m output. Some of these

Bugs fixed:

 - [Issue 56](https://github.com/chrivers/bifrost/issues/56) Event loop broke: invalid type: integer 30, expected a string
 - [Issue 51](https://github.com/chrivers/bifrost/issues/51) Failed to parse critical z2m bridge message on [bridge/devices]
 - [Issue 47](https://github.com/chrivers/bifrost/issues/47) Possible API breakage with z2m version 2.x

****************************************

## 2025-01-15: Self update

Bifrost now queries the hue firmware update servers (like the hue app does) to learn about the newest hue version number.

This branch implements all the necessary support, and spawns a new server task (background job) that tries to fetch the newest version number every 24 hours.

Once a new version number is found, the state database is automatically patched.

In my local test, the version number was successfully updated as soon as Bifrost started.

The log output looks like this:

```
bifrost[104186]: bifrost::server::updater: Firmware update information expired. Fetching..
bifrost[104186]: reqwest::connect: starting new connection: https://firmware.meethue.com/
bifrost[104186]: hyper_util::client::legacy::connect::dns: resolve; host=firmware.meethue.com
bifrost[104186]: hyper_util::client::legacy::connect::http: connecting to 34.120.72.74:443
bifrost[104186]: hyper_util::client::legacy::connect::http: connected to 34.120.72.74:443
bifrost[104186]: hyper_util::client::legacy::pool: pooling idle connection for ("https", firmware.meethue.com)
```

later that second, we see this:

```
bifrost[104186]: bifrost::model::state: Bridge device 37859e65-fdef-5965-8858-bbaef6cf47b8 on older firmware 1.60.1960149090. Updating to 1.68.0
bifrost[104186]: bifrost::model::state: Bridge device 72ca59bc-b9e3-578c-8a7d-e2ce07f3604c on older firmware 1.60.1960149090. Updating to 1.68.0
```

This all happened automatically, and the hue app worked again 👍

****************************************

## 2024-09-07: `chrivers/issue-26`

Make z2m parsing more forgiving (fixes #26)

****************************************

## 2024-09-07: `chrivers/issue-25`

Allow POST to /api without "Content-Type: text/json" header.

****************************************

## 2024-09-04: `chrivers/id-v1`

Implement proper support for `id_v1` and v1 api

****************************************

## 2024-08-24: `chrivers/missing-brightness-control`

Implement missing brightness feature detection

****************************************

## 2024-08-24: `chrivers/z2m-parsing-improvement`

Chrivers/z2m parsing improvement

****************************************

## 2024-08-24: `chrivers/group-filters`

Add support for group_filter option on z2m server blocks

****************************************

## 2024-08-24: `chrivers/z2m-fixes`

After initial testing, a number of minor z2m modelling errors were discovered.

Thanks to @joeblack2k for reporting this, and testing the fix.

Fixes #6 (half here, half in an upcoming PR for supporting group prefixes)

****************************************

## 2024-08-24: `chrivers/z2mdump`

Added z2mdump example, to make it easier to gather debug info

****************************************

## 2024-08-24: `ellwoodb/master`

Add Docker install instructions

****************************************

## 2024-08-22: `ellwoodb/master`

Add basic Docker compatibility (contributed by @ellwoodb)


# Questions?

Questions, feedback, comments? Join us on discord

[![Join Valhalla on Discord](https://discordapp.com/api/guilds/1276604041727578144/widget.png?style=banner2)](https://discord.gg/YvBKjHBJpA)
