# Homebrew formula for Textrix. packaging/homebrew/formula.sh fills this in
# for each release (CI attaches the result to the GitHub release); it goes in
# the tap repository, github.com/seamoss/homebrew-textrix, as Formula/textrix.rb.
class Textrix < Formula
  desc "Irssi-style terminal client for Matrix"
  homepage "https://github.com/seamoss/Textrix"
  license "MIT"
  head "https://github.com/seamoss/Textrix.git", branch: "master"

  on_macos do
    on_arm do
      url "https://github.com/seamoss/Textrix/releases/download/v0.1.0/textrix-v0.1.0-aarch64-apple-darwin.tar.gz"
      sha256 "6d22b0f47d5d907113722bd2c457acd18f596eebfb0fd1ee2e3faaa15fdcb601"
    end
    on_intel do
      url "https://github.com/seamoss/Textrix/releases/download/v0.1.0/textrix-v0.1.0-x86_64-apple-darwin.tar.gz"
      sha256 "a82d29a0343e6c5128c0c5d35649509762438dd34b2b8df54dd3e995c102ba5a"
    end
  end

  on_linux do
    on_intel do
      url "https://github.com/seamoss/Textrix/releases/download/v0.1.0/textrix-v0.1.0-x86_64-unknown-linux-gnu.tar.gz"
      sha256 "f880b84b5fea7f29baa68286318c6c3a6e6eba6b68440da1cbd1ee28fde08d7d"
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
