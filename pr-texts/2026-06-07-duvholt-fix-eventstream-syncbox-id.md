### 2026-06-07: `duvholt/fix/eventstream-syncbox-id`

Properly parse eventstream last-event-id and use it to filter based on order instead of strict id-matching.
This fixes an issue with the Sync Box 4k which sent weird last-event-id's which could end up sending the wrong events over the eventstream which then caused the box to stop the stream prematurely.
