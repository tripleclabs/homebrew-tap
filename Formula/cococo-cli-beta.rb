class CococoCliBeta < Formula
  desc "Command-line client for CoCoCo platform configuration (beta)"
  homepage "https://github.com/tripleclabs/iac"
  version "0.1.0-beta.9"
  license :cannot_represent

  depends_on :macos

  on_macos do
    if Hardware::CPU.arm?
      url "https://install.tripleclabs.de/cococo/beta/v0.1.0-beta.9/cococo-darwin-arm64"
      sha256 "274a4c47006dcb9cdf5f1530a15999e1a65501a007da10c07aa31a3cfcfb0592"
    else
      url "https://install.tripleclabs.de/cococo/beta/v0.1.0-beta.9/cococo-darwin-amd64"
      sha256 "b84b3380e23113f734337f45d3a46470bf63de720b0b9186356a8297684933ed"
    end
  end

  resource "third-party-notices" do
    url "https://raw.githubusercontent.com/tripleclabs/homebrew-tap/main/notices/cococo-0.1.0-beta.9.txt"
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
