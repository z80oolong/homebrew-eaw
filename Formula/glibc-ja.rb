class GlibcJa < Formula
  desc "Meta Formula for glibc locale setting for Japanese."
  homepage "https://www.gnu.org/software/libc/"
  version "2.35"
  url "https://ftp.gnu.org/gnu/glibc/glibc-2.35.tar.gz"
  mirror "https://ftpmirror.gnu.org/gnu/glibc/glibc-2.35.tar.gz"
  sha256 "3e8e0c6195da8dfbd31d77c56fb8d99576fb855fafd47a9e0a895e51fd5942d4"
  license all_of: ["GPL-2.0-or-later", "LGPL-2.1-or-later"]

  depends_on "glibc"

  def install
    prefix.install buildpath/"README" => "README"
    prefix.install buildpath/"INSTALL" => "INSTALL"
  end

  def post_install
    ohai "Installing locale data for en_US.UTF-8, ja_JP.UTF-8"
    
    system Formula["glibc"].opt_bin/"localedef", "-i", "ja_JP", "-f", "UTF-8", "ja_JP.UTF-8"
    system Formula["glibc"].opt_bin/"localedef", "-i", "en_US", "-f", "UTF-8", "en_US.UTF-8"
  end
end
