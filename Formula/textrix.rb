# Homebrew formula for Textrix. packaging/homebrew/formula.sh fills this in
# for each release (CI attaches the result to the GitHub release); it goes in
# the tap repository, github.com/seamoss/homebrew-textrix, as Formula/textrix.rb.
class Textrix < Formula
  desc "Irssi-style terminal client for Matrix"
  homepage "https://github.com/seamoss/Textrix"
  license "MIT"
  head "https://github.com/seamoss/Textrix.git", branch: "master"

  on_macos do
    url "https://github.com/seamoss/Textrix/releases/download/v0.1.4/textrix-v0.1.4-universal-apple-darwin.tar.gz"
    sha256 "67864b549d764d66f99c1585e61175c829590dae98ae5b4edcee95eab203f47c"
  end

  on_linux do
    on_arm do
      url "https://github.com/seamoss/Textrix/releases/download/v0.1.4/textrix-v0.1.4-aarch64-unknown-linux-gnu.tar.gz"
      sha256 "a2a42a46e78d5f08961389914916abeeb660746cc2e48520ed83f3d16673222c"
    end
    on_intel do
      url "https://github.com/seamoss/Textrix/releases/download/v0.1.4/textrix-v0.1.4-x86_64-unknown-linux-gnu.tar.gz"
      sha256 "2cbbaffa82ffd6539016af243603a619b9b6a60c5012126b2ebd55a830a2b985"
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
