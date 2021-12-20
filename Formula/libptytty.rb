class Libptytty < Formula
  desc "Library of OS independent and secure pty/tty and utmp/wtmp/lastlog handling"
  homepage "https://github.com/yusiwen/libptytty"
  url "https://github.com/yusiwen/libptytty/archive/b9694ea18e0dbd78213f55233a430325c13ad63e.tar.gz"
  head "https://github.com/yusiwen/libptytty.git"
  version "2.0"
  sha256 "dbe67f6dbe5ba4bb3e0f0a2195b6837aedc32ee6d39d1b5484777a608f8709fb"
  license "GPL-2.0 License"

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
