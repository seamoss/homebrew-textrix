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
      url "https://github.com/seamoss/Textrix/releases/download/v0.1.3/textrix-v0.1.3-aarch64-apple-darwin.tar.gz"
      sha256 "da187b576d38131f3c41b5c01e5e01afe05433283e79a41e7077064bea09a387"
    end
    on_intel do
      url "https://github.com/seamoss/Textrix/releases/download/v0.1.3/textrix-v0.1.3-x86_64-apple-darwin.tar.gz"
      sha256 "9cb6c7a823274ebad06383ff0241349a7502166317b1ef87fc702211f7717e01"
    end
  end

  on_linux do
    on_intel do
      url "https://github.com/seamoss/Textrix/releases/download/v0.1.3/textrix-v0.1.3-x86_64-unknown-linux-gnu.tar.gz"
      sha256 "0b7d57abe7f0241a0dbead2cbe21bc75bc99303d5bc0479f6fb6420246f86b44"
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
