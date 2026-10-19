# Homebrew formula for Textrix. packaging/homebrew/formula.sh fills this in
# for each release (CI attaches the result to the GitHub release); it goes in
# the tap repository, github.com/seamoss/homebrew-textrix, as Formula/textrix.rb.
class Textrix < Formula
  desc "Irssi-style terminal client for Matrix"
  homepage "https://github.com/seamoss/Textrix"
  license "MIT"
  head "https://github.com/seamoss/Textrix.git", branch: "master"

  on_macos do
    url "https://github.com/seamoss/Textrix/releases/download/v0.6.1/textrix-v0.6.1-universal-apple-darwin.tar.gz"
    sha256 "2c840405fae7b6ea866efbb59cd6e79d3e586f92e2a59f29dda52803f500eeeb"
  end

  on_linux do
    on_arm do
      url "https://github.com/seamoss/Textrix/releases/download/v0.6.1/textrix-v0.6.1-aarch64-unknown-linux-gnu.tar.gz"
      sha256 "aa33ef580f30248f1334b5b7b56d787ccbb7f2ecae16d3dc72ffb73a2f6172de"
    end
    on_intel do
      url "https://github.com/seamoss/Textrix/releases/download/v0.6.1/textrix-v0.6.1-x86_64-unknown-linux-gnu.tar.gz"
      sha256 "912f6abde28cfc06d747a8b9a80221704909df07e06cc1ad5162309f5548e788"
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
