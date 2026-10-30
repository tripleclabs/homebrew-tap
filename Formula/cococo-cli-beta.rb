class CococoCliBeta < Formula
  desc "Command-line client for CoCoCo platform configuration (beta)"
  homepage "https://github.com/tripleclabs/iac"
  version "0.1.0-beta.11"
  license :cannot_represent

  depends_on :macos

  on_macos do
    if Hardware::CPU.arm?
      url "https://install.tripleclabs.de/cococo/beta/v0.1.0-beta.11/cococo-darwin-arm64"
      sha256 "39cea416fb24c469b917b7bee3f4187599de6359a98e90ebc3a93e9417a2e55b"
    else
      url "https://install.tripleclabs.de/cococo/beta/v0.1.0-beta.11/cococo-darwin-amd64"
      sha256 "f9d33a7325238eb4b68b72cc4ebac783d52e78ba3a20c119e7e690b496dda611"
    end
  end

  resource "third-party-notices" do
    url "https://install.tripleclabs.de/cococo/beta/v0.1.0-beta.11/THIRD-PARTY-NOTICES.txt"
    sha256 "8473f80620262ccb61727bbac5bf14710f2de94a7d5838acf764c30fc461ff87"
  end

  def install
    bin.install Dir.children(".").select { |name| File.file?(name) }.fetch(0) => "cococo"
    resource("third-party-notices").stage do
      doc.install Dir.children(".").select { |name| File.file?(name) }.fetch(0) => "THIRD-PARTY-NOTICES.txt"
    end
  end

  def caveats
    <<~EOS
      This is the CoCoCo CLI beta channel. The installed command is cococo.
      Run cococo --version and check which -a cococo for older manual copies.
      Use your normal user account; installing does not sign in or change platform configuration.
      Product use is governed by your separately supplied CoCoCo terms.
    EOS
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/cococo --version")
    assert_match "Usage", shell_output("#{bin}/cococo --help")
  end
end
