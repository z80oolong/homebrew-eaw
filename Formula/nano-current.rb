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

class NanoCurrent < Formula
  desc "Free (GNU) replacement for the Pico text editor"
  homepage "https://www.nano-editor.org/"
  license "GPL-3.0-or-later"
  revision 1
  head "https://git.savannah.gnu.org/git/nano.git", branch: "master"

  stable do
    url "https://www.nano-editor.org/dist/v8/nano-8.6.tar.xz"
    sha256 "f7abfbf0eed5f573ab51bd77a458f32d82f9859c55e9689f819d96fe1437a619"

    patch :p1, Formula["z80oolong/eaw/nano@8.6"].diff_data
  end

  head do
    url "https://git.savannah.gnu.org/git/nano.git",

    patch :p1, Formula["z80oolong/eaw/nano@8.9-dev"].diff_data

    depends_on "autoconf" => :build
    depends_on "automake" => :build
    depends_on "perl" => :build
    depends_on "texinfo" => :build
  end

  keg_only "it conflicts with 'homebrew/core/nano'"

  depends_on "pkgconf" => :build
  depends_on "gettext"
  depends_on "z80oolong/eaw/ncurses-eaw@6.5"

  on_linux do
    depends_on "libmagic"
  end


  def install
    ENV.replace_rpath "ncurses" => "z80oolong/eaw/ncurses-eaw@6.5"

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
    system "#{bin}/nano", "--version"
  end
end
