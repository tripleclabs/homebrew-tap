# Triple C Labs Homebrew tap

Install the existing Homebrew package manager first, then use a normal terminal
account (not `sudo`). These formulae support macOS on Apple Silicon and Intel.
For Linux, use the shared apt repository instead.

```sh
brew update
brew tap tripleclabs/tap
brew install tripleclabs/tap/cococo-cli-beta
brew install tripleclabs/tap/hybrid-bridge
```

Install only the products you need. CoCoCo CLI beta 0.1.0-beta.9 provides the
`cococo` command. Hybrid Bridge is 2.1.0. Downloads use the published macOS
binaries with pinned SHA-256 checksums. The CLI's beta name is intentional;
it does not imply a stable CLI release. Product use remains subject to the
separately supplied CoCoCo terms.

## CoCoCo CLI

```sh
cococo --version
which -a cococo
cococo --help
```

There is no service or provisioning bundle. Obtain the platform address,
environment and workspace instructions from your implementation team. Installation
does not sign you in or change platform configuration. An older manual copy in
`~/.local/bin` or `/usr/local/bin` can take precedence: identify it before moving
it aside. Do not remove credentials or projects.

## Hybrid Bridge

Save your assigned provisioning bundle as a protected file. Provision as the
same normal user who will run the service, replacing the bundle path:

```sh
hybrid-bridge configure \
  --path "$(brew --prefix)/etc/hybrid-bridge/controller.env" \
  /path/to/bridge-bundle.b64
brew services start tripleclabs/tap/hybrid-bridge
brew services list
```

Do not run the start command if provisioning failed. Ask your implementation
team before reusing a possibly consumed one-time bundle. The `--path` option also
places certificates in the adjacent `certs` directory. Do not paste bundle
contents into a shell command or support ticket.

Installation alone does not configure or start the service. Its launcher exits
without starting the bridge if configuration is absent or empty. If you started
it too early, provision and then use `brew services restart hybrid-bridge`.
Confirm connectivity with your implementation team and test an integration;
service status alone does not prove a cloud connection.

The service runs as your user and starts when you log in. It is not a boot-time
system service. Keep that user logged in for continuous operation. Do not use
`sudo brew services`; use the qualified Linux/Windows service installation paths
when unattended boot-time operation is required.

| Data | Location beneath `brew --prefix` |
|---|---|
| Configuration and certificates | `etc/hybrid-bridge/` |
| Persistent application state | `var/lib/hybrid-bridge/` |
| Service logs | `var/log/hybrid-bridge/` |

The prefix is normally `/opt/homebrew` on Apple Silicon and `/usr/local` on Intel.
Directories are restricted to the installing user. Paths explicitly set in the
env file override the service's state defaults. Existing non-Homebrew Bridge
installations are not migrated automatically; review their configuration,
identity, state and service registration before switching. Never run two
instances with the same enrolled identity.

## Updates and removal

```sh
brew update
brew upgrade tripleclabs/tap/cococo-cli-beta
brew upgrade tripleclabs/tap/hybrid-bridge
brew services restart tripleclabs/tap/hybrid-bridge
```

Update during an agreed maintenance window. After a CLI update, run
`cococo upgrade` in existing workspaces to refresh guidance and restart any
editor/MCP connection. That command does not update the installed binary.

To remove Bridge, stop it first:

```sh
brew services stop tripleclabs/tap/hybrid-bridge
brew uninstall tripleclabs/tap/hybrid-bridge
```

Uninstall preserves configuration, certificates, state and logs. CLI uninstall
also leaves credentials and projects alone. Back up data before any migration.

## Release maintenance

Update formula versions, URLs and SHA-256 values from the product's published
checksums. Never rewrite versioned upstream assets or files under `notices/`.
Add matching CLI notices from the published release commit, not a dirty checkout.
Keep stable Bridge and beta CLI channels distinct. Run `brew style`, `brew audit`,
`brew install` and `brew test` for both formulae; test Bridge's missing-config
refusal, local health endpoint, restart and retained data on both architectures.
Native Intel coverage is supplied by the macOS Intel CI job when available.

## Release automation

Formulae are generated from the shared `linux-packages/release/catalog.json` by
`tools/render-formulae.py`. The product release publisher updates this repository's
`release-manifest.json` snapshot, formula versions, URLs and hashes, then commits
and pushes them. Edit service/install behavior in `templates/*.rb.in` and regenerate.

```sh
python3 tools/render-formulae.py --manifest release-manifest.json
python3 tools/render-formulae.py --manifest release-manifest.json --check
```

Stable and beta formulae coexist and conflict on installation because they own the
same executable. A release must include both macOS architectures to update its
formula. A Windows-only Bridge test release does not replace its macOS formula.
