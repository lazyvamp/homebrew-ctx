# Homebrew formula for ctx — lives in the tap repo `lazyvamp/homebrew-ctx`.
#
# Users install with:
#   brew install lazyvamp/ctx/ctx
#
# Release assets live in the public `lazyvamp/ctx-dist` repo. The source
# repo (`lazyvamp/ctx`) stays private; this formula only references
# public artifacts.
#
# Bumping versions: update `version`, then update the four sha256
# entries to match the SHA256SUMS published with the release. The CI
# release workflow uploads SHA256SUMS to the dist repo for this purpose.
class Ctx < Formula
  desc "Deterministic code context compiler — feeds your LLM exactly the right files"
  homepage "https://ctx.sh"
  license "MIT"
  version "0.1.0"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/lazyvamp/ctx-dist/releases/download/v#{version}/ctx-darwin-arm64"
      sha256 "0000000000000000000000000000000000000000000000000000000000000000"

      resource "ctx-mcp" do
        url "https://github.com/lazyvamp/ctx-dist/releases/download/v#{version}/ctx-mcp-darwin-arm64"
        sha256 "0000000000000000000000000000000000000000000000000000000000000000"
      end
    else
      url "https://github.com/lazyvamp/ctx-dist/releases/download/v#{version}/ctx-darwin-amd64"
      sha256 "0000000000000000000000000000000000000000000000000000000000000000"

      resource "ctx-mcp" do
        url "https://github.com/lazyvamp/ctx-dist/releases/download/v#{version}/ctx-mcp-darwin-amd64"
        sha256 "0000000000000000000000000000000000000000000000000000000000000000"
      end
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/lazyvamp/ctx-dist/releases/download/v#{version}/ctx-linux-arm64"
      sha256 "0000000000000000000000000000000000000000000000000000000000000000"

      resource "ctx-mcp" do
        url "https://github.com/lazyvamp/ctx-dist/releases/download/v#{version}/ctx-mcp-linux-arm64"
        sha256 "0000000000000000000000000000000000000000000000000000000000000000"
      end
    else
      url "https://github.com/lazyvamp/ctx-dist/releases/download/v#{version}/ctx-linux-amd64"
      sha256 "0000000000000000000000000000000000000000000000000000000000000000"

      resource "ctx-mcp" do
        url "https://github.com/lazyvamp/ctx-dist/releases/download/v#{version}/ctx-mcp-linux-amd64"
        sha256 "0000000000000000000000000000000000000000000000000000000000000000"
      end
    end
  end

  def install
    # The url-fetched file lands in the staging dir with whatever name
    # the URL had (e.g. `ctx-darwin-arm64`). bin.install with a Hash
    # renames it on the way into the prefix.
    bin.install Dir["*"].first => "ctx"

    resource("ctx-mcp").stage do
      bin.install Dir["*"].first => "ctx-mcp"
    end
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/ctx --version")
    assert_match version.to_s, shell_output("#{bin}/ctx-mcp --version")
  end
end
