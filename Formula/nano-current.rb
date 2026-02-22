class NanoCurrent < Formula
  desc "Free (GNU) replacement for the Pico text editor"
  homepage "https://www.nano-editor.org/"
  license "GPL-3.0-or-later"
  revision 3

  stable do
    url "https://www.nano-editor.org/dist/v8/nano-8.7.1.tar.xz"
    sha256 "76f0dcb248f2e2f1251d4ecd20fd30fb400a360a3a37c6c340e0a52c2d1cdedf"

    patch :p1, Formula["z80oolong/eaw/nano@8.7.1"].diff_data
  end

  head do
    url "https://github.com/madnight/nano.git"

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
    ENV.append "CFLAGS",     "-I#{Formula["z80oolong/eaw/ncurses-eaw@6.5"].opt_include}"
    ENV.append "CPPFLAGS",   "-I#{Formula["z80oolong/eaw/ncurses-eaw@6.5"].opt_include}"
    ENV.append "LDFLAGS",    "-L#{Formula["z80oolong/eaw/ncurses-eaw@6.5"].opt_lib}"
    ENV["LC_ALL"] = "C"

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
    assert_match Regexp.new("GNU nano, version 8.6\n", Regexp::MULTILINE), output
    assert_match Regexp.new("Compiled options: --enable-utf8\n", Regexp::MULTILINE), output
  end
end

module EnvExtend
  def replace_rpath(**replace_list)
    replace_list = replace_list.each_with_object({}) do |(old, new), result|
      result[old.to_s] = new.to_s
    end

    if (rpaths = fetch("HOMEBREW_RPATH_PATHS", false))
      self["HOMEBREW_RPATH_PATHS"] = (rpaths.split(":").map do |rpath|
        replace_list.fetch(rpath, rpath)
      end).join(":")
    end
  end
end

ENV.extend(EnvExtend)
