# Homebrew formula for Textrix. packaging/homebrew/formula.sh fills this in
# for each release (CI attaches the result to the GitHub release); it goes in
# the tap repository, github.com/seamoss/homebrew-textrix, as Formula/textrix.rb.
class Textrix < Formula
  desc "Irssi-style terminal client for Matrix"
  homepage "https://github.com/seamoss/Textrix"
  license "MIT"
  head "https://github.com/seamoss/Textrix.git", branch: "master"

  on_macos do
    url "https://github.com/seamoss/Textrix/releases/download/v0.23.0/textrix-v0.23.0-universal-apple-darwin.tar.gz"
    sha256 "375a57a0ab482d7e6a4b66e3f768ab5247c4c9875a112571148c679162e9db29"
  end

  on_linux do
    on_arm do
      url "https://github.com/seamoss/Textrix/releases/download/v0.23.0/textrix-v0.23.0-aarch64-unknown-linux-gnu.tar.gz"
      sha256 "75d19533d5cc0c71ccfc7499fb42b634246ef8cf10eb63cc74a118c4a7a8672f"
    end
    on_intel do
      url "https://github.com/seamoss/Textrix/releases/download/v0.23.0/textrix-v0.23.0-x86_64-unknown-linux-gnu.tar.gz"
      sha256 "9065e2c03c62e6dd18793e2ab857ad66fdfada8aa00cefdd3e1e07b8240602b8"
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
        mkdir -p ~/.textrix
        cp #{opt_pkgshare}/env.example ~/.textrix/.env
        chmod 600 ~/.textrix/.env
      then fill in your server and account, check it with `textrix --check`,
      and run `textrix`. Passwords can come from a password manager instead
      of the file; #{opt_pkgshare}/env.example explains how.

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
