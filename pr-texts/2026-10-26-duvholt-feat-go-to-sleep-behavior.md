### 2026-10-26: `duvholt/feat/go-to-sleep-behavior`

- Adds full support for the go to sleep automation
- Support for manually starting and stopping automations
  - Both wakeup and go to sleep supports it, but it only seems to be used for go to sleep in the app
- Shared scheduling helper for automations
- Some edge case fixes for scheduling
- More integration tests for behavior instances
- Dynamic fade speed support with a default fade set to 400ms
