### 2026-09-26: `duvholt/feat/zone-room-rework`

- Add CLIP v2 room and zone creation, updates, and deletion.
  - Handle group changes like rename and deleting done directly in Zigbee2MQTT
  - Support empty rooms and zones, creating backend groups when children are added.
  - Expose zones through the legacy v1 groups API.
  - Delete associated scenes when removing rooms or zones.
  - Add integration tests for rooms and zones
