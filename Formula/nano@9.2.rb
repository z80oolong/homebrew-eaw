class NanoAT92 < Formula
  desc "Free (GNU) replacement for the Pico text editor"
  homepage "https://www.nano-editor.org/"
  url "https://www.nano-editor.org/dist/v9/nano-9.2.tar.xz"
  sha256 "05ecb99247b782e8a5b3a25ed4101dd034b0236902f7449bc9795b717642f7e9"
  license "GPL-3.0-or-later"
  revision 4 

  keg_only "this is an alternate version of another formula"

  depends_on "pkgconf" => :build
  depends_on "gettext"
  depends_on "z80oolong/eaw/ncurses-eaw@6.5"

  on_linux do
    depends_on "libmagic"
  end

  patch :p1 do
    file "Patches/nano/nano-9.2-fix.diff"
    type :unofficial
  end

  def install
    old_curses_f = Formula["ncurses"]
    new_curses_f = Formula["z80oolong/eaw/ncurses-eaw@6.5"]
    replace_list = {
      old_curses_f.lib.to_s     => new_curses_f.lib.to_s,
      old_curses_f.opt_lib.to_s => new_curses_f.opt_lib.to_s,
    }

    if (rpaths = ENV.fetch("HOMEBREW_RPATH_PATHS", false))
      ENV["HOMEBREW_RPATH_PATHS"] = (rpaths.split(":").map do |rpath|
        replace_list.fetch(rpath, rpath)
      end).join(":")
    end
    ENV.append "NCURSESW_CFLAGS", "-I#{new_curses_f.opt_include}"
    ENV.append "NCURSESW_LIBS", "-L#{new_curses_f.opt_lib} -lncursesw"
    ENV.append "NCURSES_CFLAGS", "-I#{new_curses_f.opt_include}"
    ENV.append "NCURSES_LIBS", "-L#{new_curses_f.opt_lib} -lncurses"

    args =  std_configure_args
    args << "--disable-dependency-tracking"
    args << "--sysconfdir=#{etc}"
    args << "--enable-color"
    args << "--enable-extra"
    args << "--enable-multibuffer"
    args << "--enable-nanorc"
    args << "--enable-utf8"

    system "./configure", *args
    system "make"
    system "make", "install"

    doc.install "doc/sample.nanorc"
  end

  test do
    ENV["LC_ALL"] = "C"
    output = shell_output("#{bin}/nano --version")
    assert_match Regexp.new("GNU nano, version #{version}\n", Regexp::MULTILINE), output
    assert_match Regexp.new("Compiled options: --enable-utf8\n", Regexp::MULTILINE), output
  end
end
