class HybridBridge < Formula
  desc "CoCoCo on-premise integration bridge"
  homepage "https://github.com/tripleclabs/hybrid-bridge"
  version "2.1.0"
  license :cannot_represent

  depends_on :macos

  on_macos do
    if Hardware::CPU.arm?
      url "https://install.tripleclabs.de/controller/v2.1.0/hybrid-bridge-darwin-arm64"
      sha256 "de5018f0a6f8132016f69c72a13a362c07eba910e103c8bef116708f1506e872"
    else
      url "https://install.tripleclabs.de/controller/v2.1.0/hybrid-bridge-darwin-amd64"
      sha256 "17450c5f0bbf798d6799c8c66284f389fcd33f69f48ca349dd081e27858a86fd"
    end
  end


  def install
    bin.install Dir["hybrid-bridge-darwin-*"].fetch(0) => "hybrid-bridge"
    (libexec/"start-service").write <<~SH
      #!/bin/sh
      set -eu
      umask 077
      export CONFIG_PATH="#{etc}/hybrid-bridge/controller.env"
      if [ ! -s "$CONFIG_PATH" ]; then
        echo "Hybrid Bridge is not configured. Follow brew info hybrid-bridge before starting the service." >&2
        exit 0
      fi
      export OFFLINE_BUFFER_PATH="#{var}/lib/hybrid-bridge/controller-outbox.sqlite3"
      export EDGE_APP_STATE_PATH="#{var}/lib/hybrid-bridge/edge-app-state.sqlite3"
      export EDGE_APP_CONFIG_PATH="#{var}/lib/hybrid-bridge/edge-app-config.json"
      exec "#{opt_bin}/hybrid-bridge"
    SH
    (libexec/"start-service").chmod 0755
    (doc/"LICENSE.txt").write <<~EOS
      Hybrid Bridge is proprietary software from Triple C Labs.
      Product use is governed by your separately supplied CoCoCo terms.
      Run hybrid-bridge --licenses=full for bundled third-party license notices.
    EOS
  end

  post_install_steps do
    mkdir_p "hybrid-bridge", base: :etc
    mkdir_p "lib/hybrid-bridge", base: :var
    mkdir_p "log/hybrid-bridge", base: :var
    set_permissions "hybrid-bridge", "700", base: :etc, recursive: false
    set_permissions ["lib/hybrid-bridge", "log/hybrid-bridge"], "700", base: :var, recursive: false
  end

  service do
    run [opt_libexec/"start-service"]
    keep_alive successful_exit: false
    working_dir var/"lib/hybrid-bridge"
    log_path var/"log/hybrid-bridge/output.log"
    error_log_path var/"log/hybrid-bridge/error.log"
  end

  def caveats
    <<~EOS
      Installation does not start or provision the bridge. As your normal user:
        hybrid-bridge configure --path "#{etc}/hybrid-bridge/controller.env" /path/to/bundle.b64
        brew services start tripleclabs/tap/hybrid-bridge

      Use brew services restart hybrid-bridge after configuring a previously started service.
      The default user service starts at login, not before login. Do not use sudo brew services.
      Configuration: #{etc}/hybrid-bridge
      Persistent state: #{var}/lib/hybrid-bridge
      Logs: #{var}/log/hybrid-bridge
      These directories survive upgrades and uninstall. Stop the service before uninstalling.
      Env-file settings override service defaults; review custom state paths before migration.
      Run hybrid-bridge --licenses=full for bundled third-party license notices.
    EOS
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/hybrid-bridge --version")
    assert_match "USAGE", shell_output("#{bin}/hybrid-bridge --help")
  end
end
