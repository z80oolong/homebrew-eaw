class RxvtUnicode < Formula
  desc "Rxvt fork with Unicode support"
  homepage "http://software.schmorp.de/pkg/rxvt-unicode.html"
  revision 2

  stable do
    url "http://dist.schmorp.de/rxvt-unicode/Attic/rxvt-unicode-9.30.tar.bz2"
    sha256 "fe1c93d12f385876457a989fc3ae05c0915d2692efc59289d0f70fabe5b44d2d"

    def pick_diff(formula_path)
      lines = formula_path.each_line.to_a.inject([]) do |result, line|
        result.push(line) if ((/^__END__/ === line) || result.first)
        result
      end
      lines.shift
      return lines.join("")
    end

    patch :p1, pick_diff(Formula["z80oolong/eaw/rxvt-unicode@9.30"].path)
  end

  license "GPL-3.0-only"

  livecheck do
    url "http://dist.schmorp.de/rxvt-unicode/"
    regex(/href=.*?rxvt-unicode[._-]v?(\d+(?:\.\d+)+)\.t/i)
  end

  depends_on "pkg-config" => :build
  depends_on "gdk-pixbuf"
  depends_on "fontconfig"
  depends_on "freetype"
  depends_on "libx11"
  depends_on "libxft"
  depends_on "libxmu"
  depends_on "libxrender"
  depends_on "libxt"

  uses_from_macos "perl"

  def install
    args = %W[
      --prefix=#{prefix}
      --enable-256-color
      --with-term=rxvt-unicode-256color
      --with-terminfo=/usr/share/terminfo
      --enable-smart-resize
      --enable-unicode3
    ]

    system "./configure", *args
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
