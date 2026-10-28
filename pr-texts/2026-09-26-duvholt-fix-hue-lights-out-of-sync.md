### 2026-09-26: `duvholt/fix/hue-lights-out-of-sync`

Fix some issues with Hue lights state going out of sync. This could affect both Bifrost light state being out of sync, but also the z2m state itself if attributes were read too early.
