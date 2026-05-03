### 2025-05-24: `chrivers/sigterm-handling`

Since Bifrost is running as pid 1 in docker, we need to catch SIGTERM to perform clean shutdowns without waiting for docker timeout to stop the container.

For example, this makes the "stop" button in Home Assistant react quickly, and perform a clean shutdown.
