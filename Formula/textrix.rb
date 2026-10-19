# Homebrew formula for Textrix. packaging/homebrew/formula.sh fills this in
# for each release (CI attaches the result to the GitHub release); it goes in
# the tap repository, github.com/seamoss/homebrew-textrix, as Formula/textrix.rb.
class Textrix < Formula
  desc "Irssi-style terminal client for Matrix"
  homepage "https://github.com/seamoss/Textrix"
  license "MIT"
  head "https://github.com/seamoss/Textrix.git", branch: "master"

  on_macos do
    url "https://github.com/seamoss/Textrix/releases/download/v0.2.0/textrix-v0.2.0-universal-apple-darwin.tar.gz"
    sha256 "788408d58472b8a3dbf5214bf45cda4df433bdc373bb4f582fc7493adf842978"
  end

  on_linux do
    on_arm do
      url "https://github.com/seamoss/Textrix/releases/download/v0.2.0/textrix-v0.2.0-aarch64-unknown-linux-gnu.tar.gz"
      sha256 "a5ea871804be53aa25f87832316564041e12a7d343ba3129fe859d623bb1dc7e"
    end
    on_intel do
      url "https://github.com/seamoss/Textrix/releases/download/v0.2.0/textrix-v0.2.0-x86_64-unknown-linux-gnu.tar.gz"
      sha256 "847635f49226f8adfbcddab07f6155b3209d775d2859c756f5178f80720efdd6"
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
