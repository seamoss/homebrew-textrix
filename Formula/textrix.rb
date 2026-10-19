# Homebrew formula for Textrix. packaging/homebrew/formula.sh fills this in
# for each release (CI attaches the result to the GitHub release); it goes in
# the tap repository, github.com/seamoss/homebrew-textrix, as Formula/textrix.rb.
class Textrix < Formula
  desc "Irssi-style terminal client for Matrix"
  homepage "https://github.com/seamoss/Textrix"
  license "MIT"
  head "https://github.com/seamoss/Textrix.git", branch: "master"

  on_macos do
    url "https://github.com/seamoss/Textrix/releases/download/v0.8.0/textrix-v0.8.0-universal-apple-darwin.tar.gz"
    sha256 "369ccf4cb1172cc2dbb400ef1ad1529ab2a3017d600ef1f94dab286c17167767"
  end

  on_linux do
    on_arm do
      url "https://github.com/seamoss/Textrix/releases/download/v0.8.0/textrix-v0.8.0-aarch64-unknown-linux-gnu.tar.gz"
      sha256 "c10890811b3af1b8aa819fc0b5a2301dc99c51f5f9676c96b15901b9dccf1dc3"
    end
    on_intel do
      url "https://github.com/seamoss/Textrix/releases/download/v0.8.0/textrix-v0.8.0-x86_64-unknown-linux-gnu.tar.gz"
      sha256 "74252bc2ba2b77870d51db0dfc892a827b681ac11c18e380f0935d8f41673547"
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
      then fill in your server and account, and run `textrix`.
      Passwords can come from a password manager instead of the file;
      #{opt_pkgshare}/env.example explains how.
    EOS
  end

  test do
    assert_match "textrix", shell_output("#{bin}/textrix --version")
  end
end
