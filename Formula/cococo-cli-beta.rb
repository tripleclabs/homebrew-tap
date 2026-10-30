class CococoCliBeta < Formula
  desc "Command-line client for CoCoCo platform configuration (beta)"
  homepage "https://github.com/tripleclabs/iac"
  version "0.1.0-beta.12"
  license :cannot_represent

  depends_on :macos

  on_macos do
    if Hardware::CPU.arm?
      url "https://install.tripleclabs.de/cococo/beta/v0.1.0-beta.12/cococo-darwin-arm64"
      sha256 "d2d7836c022adfc1f6741431f9a78edcbc95eca51bc5c382619ede80cfeb5e97"
    else
      url "https://install.tripleclabs.de/cococo/beta/v0.1.0-beta.12/cococo-darwin-amd64"
      sha256 "a8ede5555baa109dcb96dafc0dd5947fab1d4360f8eb7f776aa973719c8fc6be"
    end
  end

  resource "third-party-notices" do
    url "https://install.tripleclabs.de/cococo/beta/v0.1.0-beta.12/THIRD-PARTY-NOTICES.txt"
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
