# Homebrew formula for Textrix. packaging/homebrew/formula.sh fills this in
# for each release (CI attaches the result to the GitHub release); it goes in
# the tap repository, github.com/seamoss/homebrew-textrix, as Formula/textrix.rb.
class Textrix < Formula
  desc "Irssi-style terminal client for Matrix"
  homepage "https://github.com/seamoss/Textrix"
  license "MIT"
  head "https://github.com/seamoss/Textrix.git", branch: "master"

  on_macos do
    url "https://github.com/seamoss/Textrix/releases/download/v0.26.0/textrix-v0.26.0-universal-apple-darwin.tar.gz"
    sha256 "0243492a950100dbb71c0c11915fe72d0c526edce6c54e66c33c0bf3405f77be"
  end

  on_linux do
    on_arm do
      url "https://github.com/seamoss/Textrix/releases/download/v0.26.0/textrix-v0.26.0-aarch64-unknown-linux-gnu.tar.gz"
      sha256 "994bcd7d89eac8d30d2d77d297847e61dcaa8f35011a85962389eeb1a6cfe888"
    end
    on_intel do
      url "https://github.com/seamoss/Textrix/releases/download/v0.26.0/textrix-v0.26.0-x86_64-unknown-linux-gnu.tar.gz"
      sha256 "a4e0b62a716e81b2a3889e80d0c5430df20d79788037a37c0b50744c6f94ff3e"
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
