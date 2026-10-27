# Homebrew formula for Textrix. packaging/homebrew/formula.sh fills this in
# for each release (CI attaches the result to the GitHub release); it goes in
# the tap repository, github.com/seamoss/homebrew-textrix, as Formula/textrix.rb.
class Textrix < Formula
  desc "Irssi-style terminal client for Matrix"
  homepage "https://github.com/seamoss/Textrix"
  license "MIT"
  head "https://github.com/seamoss/Textrix.git", branch: "master"

  on_macos do
    url "https://github.com/seamoss/Textrix/releases/download/v0.16.2/textrix-v0.16.2-universal-apple-darwin.tar.gz"
    sha256 "43660f4f620ca1919c1f3ed43bb3cb48d2902dcb342f617677429027b7b5a635"
  end

  on_linux do
    on_arm do
      url "https://github.com/seamoss/Textrix/releases/download/v0.16.2/textrix-v0.16.2-aarch64-unknown-linux-gnu.tar.gz"
      sha256 "0ba5fe721241d3cb9df70ebc8bc6c8a600a64cd56e3ba9030317d773fecf80c4"
    end
    on_intel do
      url "https://github.com/seamoss/Textrix/releases/download/v0.16.2/textrix-v0.16.2-x86_64-unknown-linux-gnu.tar.gz"
      sha256 "7ea65f727bc235f429e31b5ece82d4994a6e5105d9bc26ec8790a7f20c2cbf3d"
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
    EOS
  end

  test do
    assert_match(/^textrix \d+\.\d+\.\d+$/, shell_output("#{bin}/textrix --version").strip)
  end
end
