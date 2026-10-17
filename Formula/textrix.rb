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
      url "https://github.com/seamoss/Textrix/releases/download/v0.1.1/textrix-v0.1.1-aarch64-apple-darwin.tar.gz"
      sha256 "d3d083269e26c9705d04f5944a403c8eda9942b572f46bedac4d9e04fcb894ac"
    end
    on_intel do
      url "https://github.com/seamoss/Textrix/releases/download/v0.1.1/textrix-v0.1.1-x86_64-apple-darwin.tar.gz"
      sha256 "70612d053f06f2bbf08e2b981ebb89ffad2592c5ad7eacfa3702a5d767d8a961"
    end
  end

  on_linux do
    on_intel do
      url "https://github.com/seamoss/Textrix/releases/download/v0.1.1/textrix-v0.1.1-x86_64-unknown-linux-gnu.tar.gz"
      sha256 "3dc1d8d661b658f392b5007e94052a63261fb89b606252201147292e619b065d"
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
