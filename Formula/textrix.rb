# Homebrew formula for Textrix. packaging/homebrew/formula.sh fills this in
# for each release (CI attaches the result to the GitHub release); it goes in
# the tap repository, github.com/seamoss/homebrew-textrix, as Formula/textrix.rb.
class Textrix < Formula
  desc "Irssi-style terminal client for Matrix"
  homepage "https://github.com/seamoss/Textrix"
  license "MIT"
  head "https://github.com/seamoss/Textrix.git", branch: "master"

  on_macos do
    url "https://github.com/seamoss/Textrix/releases/download/v0.13.0/textrix-v0.13.0-universal-apple-darwin.tar.gz"
    sha256 "162195733ef6bf9226467851ba1810509176967d49264a5e934923f4cc679974"
  end

  on_linux do
    on_arm do
      url "https://github.com/seamoss/Textrix/releases/download/v0.13.0/textrix-v0.13.0-aarch64-unknown-linux-gnu.tar.gz"
      sha256 "290b013e04d91334592ac80ec5fe359bd560c202db5f29c7e2fd8e70b03273c6"
    end
    on_intel do
      url "https://github.com/seamoss/Textrix/releases/download/v0.13.0/textrix-v0.13.0-x86_64-unknown-linux-gnu.tar.gz"
      sha256 "c7f500c00b9c68ef8d66b95cc2bfb95a83ac63ba022ad63658f0a34be6a2200f"
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

      To upgrade: brew upgrade textrix. A Textrix that's running (in the
      background too) then shows "[x.y.z installed: /restart]", and
      /restart switches to the new one where you were.
    EOS
  end

  test do
    assert_match(/^textrix \d+\.\d+\.\d+$/, shell_output("#{bin}/textrix --version").strip)
  end
end
