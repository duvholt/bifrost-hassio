### 2025-05-24: `chrivers/service-instancing`

Rework `svc` ("service") crate, to support templated services.

These are analogous to systemd template service, in which a service name can contain `@` to indicate it is a template.

In this way, instead of manually registering `foo-1`, `foo-2`, etc,
we can register `foo@`, and then start instances `1`, `2`, etc.

This makes service management cleaner and simpler, and provides a way to recognize groups
of related services.
