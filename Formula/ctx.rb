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
  CTX_VERSION = "v0.1.2".freeze

  desc "Deterministic code context compiler — feeds your LLM exactly the right files"
  homepage "https://ctx.sh"
  license "MIT"
  version "0.1.2"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/lazyvamp/ctx-dist/releases/download/#{CTX_VERSION}/ctx-darwin-arm64"
      sha256 "7b8e57057d3c13809d3ae6b338a3011e1ac797d146ce4ab93893dabc0db1093e"

      resource "ctx-mcp" do
        url "https://github.com/lazyvamp/ctx-dist/releases/download/#{CTX_VERSION}/ctx-mcp-darwin-arm64"
        sha256 "12743c20817dd8dfdce4ad204e7ff80d7454c58dd3c812d2989c43885a80c151"
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
      sha256 "a9e0d6a8221e5e7f7a5fa6da5ad143c3c3d634dc88c085bb627fc0bbb0716055"

      resource "ctx-mcp" do
        url "https://github.com/lazyvamp/ctx-dist/releases/download/#{CTX_VERSION}/ctx-mcp-linux-arm64"
        sha256 "87d0cb9d6045e5155174e0bdf396656b5daec7c23976271a265e4f2d922a3e01"
      end
    else
      url "https://github.com/lazyvamp/ctx-dist/releases/download/#{CTX_VERSION}/ctx-linux-amd64"
      sha256 "7acd674787daba21e492a6681479d7fa705b3f3173303a8c1747f5afb09e111c"

      resource "ctx-mcp" do
        url "https://github.com/lazyvamp/ctx-dist/releases/download/#{CTX_VERSION}/ctx-mcp-linux-amd64"
        sha256 "fcb2b2dcd8f5ebd1e5e88ac4d5fa8b09ca346e37b02226cf53579cabacd55c46"
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
