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
      url "https://github.com/seamoss/Textrix/releases/download/v0.1.2/textrix-v0.1.2-aarch64-apple-darwin.tar.gz"
      sha256 "e04ef43b3b5607aea0e50a9214b54706e3ed9ce4ccfca4885295111c1869e614"
    end
    on_intel do
      url "https://github.com/seamoss/Textrix/releases/download/v0.1.2/textrix-v0.1.2-x86_64-apple-darwin.tar.gz"
      sha256 "7fd2b3fcce803c11eccece2fd121879405f46023e57a7711a27e9b5066f13e8b"
    end
  end

  on_linux do
    on_intel do
      url "https://github.com/seamoss/Textrix/releases/download/v0.1.2/textrix-v0.1.2-x86_64-unknown-linux-gnu.tar.gz"
      sha256 "710c8d9bb034f94ead8b0f9894639fa4fa2cf7e405512c5183566ca9ccac19c3"
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
