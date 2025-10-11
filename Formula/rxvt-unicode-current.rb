def ENV.replace_rpath(**replace_list)
  replace_list = replace_list.each_with_object({}) do |(old, new), result|
    old_f = Formula[old]
    new_f = Formula[new]
    result[old_f.opt_lib.to_s] = new_f.opt_lib.to_s
    result[old_f.lib.to_s] = new_f.lib.to_s
  end

  if (rpaths = fetch("HOMEBREW_RPATH_PATHS", false))
    self["HOMEBREW_RPATH_PATHS"] = (rpaths.split(":").map do |rpath|
      replace_list.fetch(rpath, rpath)
    end).join(":")
  end
end

class RxvtUnicodeCurrent < Formula
  desc "Rxvt fork with Unicode support"
  homepage "http://software.schmorp.de/pkg/rxvt-unicode.html"
  license "GPL-3.0-only"
  revision 7

  stable do
    url "http://dist.schmorp.de/rxvt-unicode/Attic/rxvt-unicode-9.31.tar.bz2"
    sha256 "aaa13fcbc149fe0f3f391f933279580f74a96fd312d6ed06b8ff03c2d46672e8"

    patch :p1, Formula["z80oolong/eaw/rxvt-unicode@9.31"].diff_data
  end

  head do
    url "https://github.com/yusiwen/rxvt-unicode.git"

    patch :p1, Formula["z80oolong/eaw/rxvt-unicode@9999-dev"].diff_data
  end

  livecheck do
    url "http://dist.schmorp.de/rxvt-unicode/"
    regex(/href=.*?rxvt-unicode[._-]v?(\d+(?:\.\d+)+)\.t/i)
  end

  keg_only "it conflicts with 'homebrew/core/rxvt-unicode'"

  depends_on "cmake" => :build
  depends_on "pkgconf" => :build
  depends_on "fontconfig"
  depends_on "freetype"
  depends_on "gdk-pixbuf"
  depends_on "libx11"
  depends_on "libxft"
  depends_on "libxmu"
  depends_on "libxrender"
  depends_on "libxt"
  depends_on "perl"
  depends_on "startup-notification"
  depends_on "libptytty"
  depends_on "z80oolong/eaw/ncurses-eaw@6.5"

  resource("libev") do
    url "http://dist.schmorp.de/libev/Attic/libev-4.33.tar.gz"
    sha256 "507eb7b8d1015fbec5b935f34ebed15bf346bed04a11ab82b8eee848c4205aea"
  end

  def install
    ENV.replace_rpath "ncurses" => "z80oolong/eaw/ncurses-eaw@6.5"

    resource("libev").stage do
      (buildpath/"libev").mkpath
      Pathname.glob("./*").each { |src| (buildpath/"libev").install src }
    end

    args = std_configure_args
    args << "--datarootdir=#{share}"
    args << "--enable-256-color"
    args << "--with-term=xterm-256color"
    args << "--with-terminfo=#{Formula["z80oolong/eaw/ncurses-eaw@6.5"].opt_share}/terminfo"
    args << "--enable-smart-resize"
    args << "--enable-unicode3"

    ENV.prepend_path "PKG_CONFIG_PATH", lib/"pkgconfig"
    ENV["LC_ALL"] = "C"

    system "./configure", *args
    system "make"
    system "make", "install"
  end

  test do
    daemon = fork do
      system bin/"urxvtd"
    end
    sleep 2
    system bin/"urxvtc", "-k"
    Process.wait daemon
  end
end
