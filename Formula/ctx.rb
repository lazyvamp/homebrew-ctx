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
  CTX_VERSION = "v0.1.0".freeze

  desc "Deterministic code context compiler — feeds your LLM exactly the right files"
  homepage "https://ctx.sh"
  license "MIT"
  version "0.1.0"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/lazyvamp/ctx-dist/releases/download/#{CTX_VERSION}/ctx-darwin-arm64"
      sha256 "b88a9d72c1c7c65e32c3aa8d95e2abd299bae585e9a94aeda6396db343da79f5"

      resource "ctx-mcp" do
        url "https://github.com/lazyvamp/ctx-dist/releases/download/#{CTX_VERSION}/ctx-mcp-darwin-arm64"
        sha256 "df33bec0817473512a919e2c9fc12024feafc58a6838966609ef41338ef39a05"
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
      sha256 "93ae0798d3a26a155ddbe259e4231a676f47acba4c884f27d4f7c3b39286357d"

      resource "ctx-mcp" do
        url "https://github.com/lazyvamp/ctx-dist/releases/download/#{CTX_VERSION}/ctx-mcp-linux-arm64"
        sha256 "6ec4981223ac5ec430922c8d6c4a28053a4dfbffb80330c1890cef7c87cbfb87"
      end
    else
      url "https://github.com/lazyvamp/ctx-dist/releases/download/#{CTX_VERSION}/ctx-linux-amd64"
      sha256 "63be28a28a7b70b5eee25be9dffebbf7fe8b66858fc86d0dec1302451dcff71f"

      resource "ctx-mcp" do
        url "https://github.com/lazyvamp/ctx-dist/releases/download/#{CTX_VERSION}/ctx-mcp-linux-amd64"
        sha256 "ac236e64c38566e449d2f0d5fc4a813569e00a62641419a3b73db13f1ec03672"
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
