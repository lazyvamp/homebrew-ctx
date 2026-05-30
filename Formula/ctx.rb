# Homebrew formula for ctx — lives in the tap repo `lazyvamp/homebrew-ctx`.
#
# Users install with:
#   brew install lazyvamp/ctx/ctx
#
# Release assets live in the public `lazyvamp/ctx-dist` repo. The source
# repo (`lazyvamp/ctx`) stays private; this formula only references
# public artifacts.
#
# Bumping versions: update CTX_VERSION + version, then update the six
# sha256 entries to match the SHA256SUMS published with the release.
# The CI release workflow uploads SHA256SUMS to the dist repo for this
# purpose.
#
# Why CTX_VERSION as a constant instead of `#{version}` inside resource
# blocks: inside a Homebrew `resource` block, `version` refers to the
# resource's own version (empty by default), NOT the parent formula's.
# Using `#{version}` there silently rendered URLs like `.../v//...` and
# 404'd. A class-level constant sidesteps the scoping gotcha.
class Ctx < Formula
  CTX_VERSION = "v0.1.3".freeze

  desc "Deterministic code context compiler — feeds your LLM exactly the right files"
  homepage "https://ctx.sh"
  license "MIT"
  version "0.1.3"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/lazyvamp/ctx-dist/releases/download/#{CTX_VERSION}/ctx-darwin-arm64"
      sha256 "030a55c3037efca44b44ea04a88a22457ff7ea2f43340bf8694aa08e31292884"

      resource "ctx-mcp" do
        url "https://github.com/lazyvamp/ctx-dist/releases/download/#{CTX_VERSION}/ctx-mcp-darwin-arm64"
        sha256 "2d29443500e608faeb9088234881ea1e94a1164b6f2c5c86774a32483303e1d0"
      end
    else
      # macOS Intel is not shipped as a native binary. Rosetta runs
      # the arm64 build fine; users who want a native amd64 build
      # should compile from source.
      odie "macOS Intel native builds are not published. Use Rosetta on the arm64 build, or build from source."
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/lazyvamp/ctx-dist/releases/download/#{CTX_VERSION}/ctx-linux-arm64"
      sha256 "e9df4568b6be7124c7998b32163a264ef78286008052337bd359aecd48edb2ef"

      resource "ctx-mcp" do
        url "https://github.com/lazyvamp/ctx-dist/releases/download/#{CTX_VERSION}/ctx-mcp-linux-arm64"
        sha256 "ba31868aeb3aaa67d7a83fe58f2310dd96b87ead6e4ea138d949fdc95811a795"
      end
    else
      url "https://github.com/lazyvamp/ctx-dist/releases/download/#{CTX_VERSION}/ctx-linux-amd64"
      sha256 "23bc11015eaf6d454b441f23d8016c7074f507a04a1aab4f32dadb8b32a2ea08"

      resource "ctx-mcp" do
        url "https://github.com/lazyvamp/ctx-dist/releases/download/#{CTX_VERSION}/ctx-mcp-linux-amd64"
        sha256 "ef02a01d39ccc3e6fed4d6d958883ac1f7eecb049140e4a9a65476fccade5789"
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
