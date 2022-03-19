class LibptyttyAT20 < Formula
  desc "Library of OS independent and secure pty/tty and utmp/wtmp/lastlog handling"
  homepage "https://github.com/yusiwen/libptytty"
  license "GPL-2.0 License"
  url "http://dist.schmorp.de/libptytty/libptytty-2.0.tar.gz"
  version "2.0"
  sha256 "8033ed3aadf28759660d4f11f2d7b030acf2a6890cb0f7926fb0cfa6739d31f7"

  keg_only :versioned_formula

  depends_on "cmake" => :build

  def install
    system "mkdir", "#{buildpath}/build"
    Dir.chdir("#{buildpath}/build") do
      system "cmake", "-DCMAKE_INSTALL_PREFIX=#{prefix}", "-DBUILD_SHARED_LIBS=ON", ".."
      system "make"
      system "make", "install"
    end
  end
end
