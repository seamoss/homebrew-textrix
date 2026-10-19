# Homebrew formula for Textrix. packaging/homebrew/formula.sh fills this in
# for each release (CI attaches the result to the GitHub release); it goes in
# the tap repository, github.com/seamoss/homebrew-textrix, as Formula/textrix.rb.
class Textrix < Formula
  desc "Irssi-style terminal client for Matrix"
  homepage "https://github.com/seamoss/Textrix"
  license "MIT"
  head "https://github.com/seamoss/Textrix.git", branch: "master"

  on_macos do
    url "https://github.com/seamoss/Textrix/releases/download/v0.7.1/textrix-v0.7.1-universal-apple-darwin.tar.gz"
    sha256 "55f6356055290b69a06cbaf0296640423d4c64a20d45c7a586835f157c963c5c"
  end

  on_linux do
    on_arm do
      url "https://github.com/seamoss/Textrix/releases/download/v0.7.1/textrix-v0.7.1-aarch64-unknown-linux-gnu.tar.gz"
      sha256 "c05557c5ad20750d7ab369c2c13b2973e39260ff27aef9c22822c39a7a6dfae6"
    end
    on_intel do
      url "https://github.com/seamoss/Textrix/releases/download/v0.7.1/textrix-v0.7.1-x86_64-unknown-linux-gnu.tar.gz"
      sha256 "2fe60cd0beb20d83f60b3423425263578b64d5f2d8f07213c365007887ff9176"
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
