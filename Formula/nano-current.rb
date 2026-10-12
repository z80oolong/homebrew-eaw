require "#{Tap.fetch("z80oolong/eaw").path}/lib/extend.rb"
ENV.extend(EnvExtend)

class NanoCurrent < Formula
  include DiffDataMixin

  desc "Free (GNU) replacement for the Pico text editor"
  homepage "https://www.nano-editor.org/"
  license "GPL-3.0-or-later"
  revision 3

  stable do
    url "https://www.nano-editor.org/dist/v9/nano-9.2.tar.xz"
    sha256 "05ecb99247b782e8a5b3a25ed4101dd034b0236902f7449bc9795b717642f7e9"

    patch :p1, Formula["z80oolong/eaw/nano@9.2"].diff_data
  end

  head do
    url "git://git.sv.gnu.org/nano.git"

    depends_on "autoconf" => :build
    depends_on "automake" => :build
    depends_on "perl" => :build
    depends_on "texinfo" => :build

    patch :p1, Formula["z80oolong/eaw/nano@9999-dev"].diff_data
  end

  keg_only "it conflicts with 'homebrew/core/nano'"

  depends_on "pkgconf" => :build
  depends_on "gettext"
  depends_on "z80oolong/eaw/ncurses-eaw@6.5"

  on_linux do
    depends_on "libmagic"
  end

  def install
    old_curses_f = Formula["ncurses"]
    new_curses_f = Formula["z80oolong/eaw/ncurses-eaw@6.5"]

    ENV.replace_rpath old_curses_f.lib     => new_curses_f.lib,
                      old_curses_f.opt_lib => new_curses_f.opt_lib
    ENV.append "NCURSESW_CFLAGS", "-I#{new_curses_f.opt_include}"
    ENV.append "NCURSESW_LIBS", "-L#{new_curses_f.opt_lib} -lncursesw"
    ENV.append "NCURSES_CFLAGS", "-I#{new_curses_f.opt_include}"
    ENV.append "NCURSES_LIBS", "-L#{new_curses_f.opt_lib} -lncurses"
    ENV["LC_ALL"] = "C"
    if build.head?
      ENV["HOMEBREW_ACLOCAL_PATH"] = "#{Formula["pkgconf"].opt_share}/aclocal"
    end

    args =  std_configure_args
    args << "--disable-dependency-tracking"
    args << "--sysconfdir=#{etc}"
    args << "--enable-color"
    args << "--enable-extra"
    args << "--enable-multibuffer"
    args << "--enable-nanorc"
    args << "--enable-utf8"

    system "sh", "autogen.sh" if build.head?

    system "./configure", *args
    system "make"
    system "make", "install"

    doc.install "doc/sample.nanorc"
  end

  test do
    ENV["LC_ALL"] = "C"
    output = shell_output("#{bin}/nano --version")
    assert_match Regexp.new("GNU nano, version 9.0\n", Regexp::MULTILINE), output
    assert_match Regexp.new("Compiled options: --enable-utf8\n", Regexp::MULTILINE), output
  end
end
