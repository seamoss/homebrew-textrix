# Homebrew formula for Textrix. packaging/homebrew/formula.sh fills this in
# for each release (CI attaches the result to the GitHub release); it goes in
# the tap repository, github.com/seamoss/homebrew-textrix, as Formula/textrix.rb.
class Textrix < Formula
  desc "Irssi-style terminal client for Matrix"
  homepage "https://github.com/seamoss/Textrix"
  license "MIT"
  head "https://github.com/seamoss/Textrix.git", branch: "master"

  on_macos do
    url "https://github.com/seamoss/Textrix/releases/download/v0.16.4/textrix-v0.16.4-universal-apple-darwin.tar.gz"
    sha256 "1bdc3a5545f9b1a55caa6aad8e9ff25766d75fd8850f466ce8cd3257a02ee3e1"
  end

  on_linux do
    on_arm do
      url "https://github.com/seamoss/Textrix/releases/download/v0.16.4/textrix-v0.16.4-aarch64-unknown-linux-gnu.tar.gz"
      sha256 "ea41e435014e492ddd276e9270ecf9fdcc78d45c48f7decc51bea99cdc0c437d"
    end
    on_intel do
      url "https://github.com/seamoss/Textrix/releases/download/v0.16.4/textrix-v0.16.4-x86_64-unknown-linux-gnu.tar.gz"
      sha256 "8e14af7baf812a8f900b420520baaf64d6d010cdbf48ddd89410e7ade7535f6d"
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
