# Homebrew formula for Textrix. packaging/homebrew/formula.sh fills this in
# for each release (CI attaches the result to the GitHub release); it goes in
# the tap repository, github.com/seamoss/homebrew-textrix, as Formula/textrix.rb.
class Textrix < Formula
  desc "Irssi-style terminal client for Matrix"
  homepage "https://github.com/seamoss/Textrix"
  license "MIT"
  head "https://github.com/seamoss/Textrix.git", branch: "master"

  on_macos do
    url "https://github.com/seamoss/Textrix/releases/download/v0.8.1/textrix-v0.8.1-universal-apple-darwin.tar.gz"
    sha256 "0d2b8ebda23e4fa430c134b602a1c3784c889a3adfd6a7a66e2b86c84a126bcf"
  end

  on_linux do
    on_arm do
      url "https://github.com/seamoss/Textrix/releases/download/v0.8.1/textrix-v0.8.1-aarch64-unknown-linux-gnu.tar.gz"
      sha256 "433afbf15ab4f950e48810bcd9d042475b5094a5a39baf6755ebe560b4a057c9"
    end
    on_intel do
      url "https://github.com/seamoss/Textrix/releases/download/v0.8.1/textrix-v0.8.1-x86_64-unknown-linux-gnu.tar.gz"
      sha256 "c2223f0603c378d86dc259b7ddda5c4d1463425b3380e28e07b625edd4d04200"
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
