# Validation — 23 October 2026

Tested with Homebrew 7.0.10 on an Apple Silicon Mac:

- Both formulae download with their pinned published SHA-256 values and install.
- `brew style`, `brew audit` and both `brew test` blocks pass.
- CLI reports 0.1.0-beta.7; Bridge reports v2.1.0.
- Bridge's service launcher exits without starting an unconfigured daemon.
- `tests/bridge-service.sh` verifies launchd start/restart, local health, retained
  configuration/state across uninstall and reinstall, and startup afterward.
- The test uses loopback upstream only, no real bundle or credentials. Its expected
  health is HTTP 503 with `status: disconnected`; it does not verify enrollment.
- Cleanup leaves Bridge installed but stopped and removes the test configuration.
- Intel downloads match their published checksums and are x86_64 Mach-O files.
  Native Intel runtime testing remains for the macos-15-intel CI job; no Rosetta
  installation was available on the local host.

The public tap includes CI for both Mac architectures. Account-level GitHub
Actions availability may prevent jobs from starting; local results above are
independent of CI. No Windows or Linux installation is changed by these formulae.
