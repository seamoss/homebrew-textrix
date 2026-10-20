# Homebrew formula for Textrix. packaging/homebrew/formula.sh fills this in
# for each release (CI attaches the result to the GitHub release); it goes in
# the tap repository, github.com/seamoss/homebrew-textrix, as Formula/textrix.rb.
class Textrix < Formula
  desc "Irssi-style terminal client for Matrix"
  homepage "https://github.com/seamoss/Textrix"
  license "MIT"
  head "https://github.com/seamoss/Textrix.git", branch: "master"

  on_macos do
    url "https://github.com/seamoss/Textrix/releases/download/v0.9.7/textrix-v0.9.7-universal-apple-darwin.tar.gz"
    sha256 "a5c157bfd649593bf95bc851d5c87be74f4e9b99b98208198d09e89e9dba3b10"
  end

  on_linux do
    on_arm do
      url "https://github.com/seamoss/Textrix/releases/download/v0.9.7/textrix-v0.9.7-aarch64-unknown-linux-gnu.tar.gz"
      sha256 "bddef99c8d3dd12dff96ea61d215306bc6e68e445d192d99e8cc7b3fe0b9b87b"
    end
    on_intel do
      url "https://github.com/seamoss/Textrix/releases/download/v0.9.7/textrix-v0.9.7-x86_64-unknown-linux-gnu.tar.gz"
      sha256 "027dd14a45f71b892af27c402fe082d1623532b9c7c3b43d4dedfc60dfaa2089"
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
