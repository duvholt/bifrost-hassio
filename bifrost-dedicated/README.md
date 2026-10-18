# Bifrost Dedicated LAN

This Home Assistant app runs Bifrost with a separate LAN identity. A macvlan
interface provides the IP and MAC configured in `/config/bifrost/config.yaml`,
while a private transit interface preserves access to Supervisor apps such as
Zigbee2MQTT.

The LAN interface is detected from the HAOS IPv4 default route.

The bridge MAC must be a unique, locally administered unicast address. When
migrating from the regular Bifrost app, move the existing `cert.pem` aside so
Bifrost can generate a certificate for its new bridge identity. Hue clients may
need to pair again.

This app requires host networking, `NET_ADMIN`, `SYS_ADMIN`, and `/dev/net/tun`
to create the network namespace. Those capabilities are removed from the
Bifrost process after setup.

The regular `Bifrost` app remains available for installations that do not need
a separate LAN identity or these additional privileges. Do not run both apps at
the same time; they share the same Bifrost configuration and bridge identity.
