### 2026-05-14: `duvholt/feat/effects-state`

`philips_raw` was introduced in zigbee2mqtt which reports the raw state for Philips Hue lights. 

Since Bifrost already has support for decoding this format it was relatively straightforward to use this to update our internal light state instead of using attributes from zigbee2mqtt.

The most noticeable change from this is that Philips Hue effects and gradient lights should now properly reflect their status in the app.
