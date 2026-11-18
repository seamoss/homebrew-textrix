# Homebrew formula for Textrix. packaging/homebrew/formula.sh fills this in
# for each release (CI attaches the result to the GitHub release); it goes in
# the tap repository, github.com/seamoss/homebrew-textrix, as Formula/textrix.rb.
class Textrix < Formula
  desc "Irssi-style terminal client for Matrix"
  homepage "https://github.com/seamoss/Textrix"
  license "MIT"
  head "https://github.com/seamoss/Textrix.git", branch: "master"

  on_macos do
    url "https://github.com/seamoss/Textrix/releases/download/v0.25.0/textrix-v0.25.0-universal-apple-darwin.tar.gz"
    sha256 "b3865ffce38f4331472098e938cfa206e4003de66b1e7e660429e35e8d41045a"
  end

  on_linux do
    on_arm do
      url "https://github.com/seamoss/Textrix/releases/download/v0.25.0/textrix-v0.25.0-aarch64-unknown-linux-gnu.tar.gz"
      sha256 "45f100a1920f6039b067d9c82443d8ab92ddd3b5d1d627da8cfd54206f859bd5"
    end
    on_intel do
      url "https://github.com/seamoss/Textrix/releases/download/v0.25.0/textrix-v0.25.0-x86_64-unknown-linux-gnu.tar.gz"
      sha256 "e943fabb8aa56eba90f4da70ab1b1549070d043bb8f844c13c2fd4375da90c9a"
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
