### 2026-05-04: `Intecpsp/fix/hue-sync-duvholt`

- Corrected the logic that was sorting device names alphabetically before mapping channels. It now uses the stable channel_id provided by the Hue API, ensuring that 'Left' stays 'Left' regardless of bulb names.

- Fixed the logic for standard (non-gradient) bulbs to honor user-assigned positions.
