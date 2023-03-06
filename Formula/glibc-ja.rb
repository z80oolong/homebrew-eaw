class GlibcJa < Formula
  desc "Meta Formula for glibc locale setting for Japanese."
  homepage "https://www.gnu.org/software/libc/libc.html"
  url "https://www.gnu.org/software/libc/libc.html"
  version "2.35"
  sha256 "94e0d086ce21d2c34cab7b72e96bf35a7303707f0dc7dffa0e0d309f1f6e008f"
  license all_of: ["GPL-2.0-or-later", "LGPL-2.1-or-later"]

  depends_on "glibc"
  depends_on "glibc@2.13"

  def install
    prefix.install buildpath/"libc.html" => "glibc.html"
  end

  def post_install
    ohai "Installing locale data for en_US.UTF-8, ja_JP.UTF-8"
    
    system Formula["glibc"].opt_bin/"localedef", "-i", "ja_JP", "-f", "UTF-8", "ja_JP.UTF-8"
    system Formula["glibc"].opt_bin/"localedef", "-i", "en_US", "-f", "UTF-8", "en_US.UTF-8"
    system Formula["glibc@2.13"].opt_bin/"localedef", "-i", "ja_JP", "-f", "UTF-8", "ja_JP.UTF-8"
    system Formula["glibc@2.13"].opt_bin/"localedef", "-i", "en_US", "-f", "UTF-8", "en_US.UTF-8"
  end
end
