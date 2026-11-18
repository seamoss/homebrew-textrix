# Homebrew formula for Textrix. packaging/homebrew/formula.sh fills this in
# for each release (CI attaches the result to the GitHub release); it goes in
# the tap repository, github.com/seamoss/homebrew-textrix, as Formula/textrix.rb.
class Textrix < Formula
  desc "Irssi-style terminal client for Matrix"
  homepage "https://github.com/seamoss/Textrix"
  license "MIT"
  head "https://github.com/seamoss/Textrix.git", branch: "master"

  on_macos do
    url "https://github.com/seamoss/Textrix/releases/download/v0.24.0/textrix-v0.24.0-universal-apple-darwin.tar.gz"
    sha256 "2b6186a3d4eda6bccd9950ecc8b860e6810e81e72bfb8723db2621668da66486"
  end

  on_linux do
    on_arm do
      url "https://github.com/seamoss/Textrix/releases/download/v0.24.0/textrix-v0.24.0-aarch64-unknown-linux-gnu.tar.gz"
      sha256 "2a449ea9da9351c3b226e6b2cba895a6d485a191f1601a001fe5bf14f4e7b4d2"
    end
    on_intel do
      url "https://github.com/seamoss/Textrix/releases/download/v0.24.0/textrix-v0.24.0-x86_64-unknown-linux-gnu.tar.gz"
      sha256 "8c8e61b27fc7b4f1c00ba64b5fa7def635629b391667c028b277d672dc8d546f"
    end
  end

  head do
    depends_on "rust" => :build
  end

  def install
    if build.head?
      system "cargo", "install", *std_cargo_args
    else
      bin.install "textrix"
    end
    pkgshare.install ".env.example" => "env.example"
    generate_completions_from_executable(bin/"textrix", "--completions")
    (man1/"textrix.1").write Utils.safe_popen_read(bin/"textrix", "--man")
  end

  def caveats
    <<~EOS
      Textrix only connects to the servers listed in ~/.textrix/.env. To start:
        textrix setup
      asks for your Matrix ID and writes that file, leaving your password for
      you to put in it (it's never typed into Textrix); then run `textrix`.
      Or by hand: copy #{opt_pkgshare}/env.example to ~/.textrix/.env,
      chmod 600 it and fill it in. Passwords can come from a password manager
      instead of the file; env.example explains how.

      To upgrade: brew update && brew upgrade textrix. A Textrix that's running (in the
      background too) then shows "[x.y.z installed: /restart]", and
      /restart switches to the new one where you were.

      On a Mac, `textrix app install` puts Textrix.app in ~/Applications, to start
      it from Alfred, Spotlight or the Dock (in Ghostty, or Terminal).
    EOS
  end

  test do
    assert_match(/^textrix \d+\.\d+\.\d+$/, shell_output("#{bin}/textrix --version").strip)
  end
end
