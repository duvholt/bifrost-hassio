### 2026-05-26: `duvholt/light-switch-support`

Add support for light switches with almost all configurations except for:
- "Dim up and down" (not to be confused with "Dim down" and "Dim up" which are implemented)
- Smart on/off

For now only these light switches are mapped out:
- Philips Hue dimmer switches (gen1 and gen2)
- Friends of Hue switch EnOcean PTM 215Z

Known limitations:
- The current implementation has to be implemented custom for each light switch. The problem is that there is no universal action interface exposed from z2m so I haven't been able to do any generic button mapping.
- It's not possible to configure a button for a subset of lights in a room or many rooms. That's because this is using zones which is currently not implemented in Bifrost.
