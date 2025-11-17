class NeomuttCurrent < Formula
  desc "E-mail reader with support for Notmuch, NNTP and much more"
  homepage "https://neomutt.org/"
  license "GPL-2.0-or-later"
  revision 4

  stable do
    url "https://github.com/neomutt/neomutt/archive/refs/tags/20250905.tar.gz"
    sha256 "f409fa3803bfc540869b78719400bceda216842e4da024f83ca3060241d9c516"

    patch :p1, Formula["z80oolong/eaw/neomutt@20250905"].diff_data
  end

  head do
    url "https://github.com/neomutt/neomutt.git", branch: "main"

    patch :p1, Formula["z80oolong/eaw/neomutt@9999-dev"].diff_data
  end

  keg_only "this formula conflicts with 'homebrew/core/neomutt'"

  depends_on "gettext"
  depends_on "glibc"
  depends_on "gpgme"
  depends_on "libidn"
  depends_on "lmdb"
  depends_on "lua"
  depends_on "notmuch"
  depends_on "openssl@1.1"
  depends_on "tokyo-cabinet"
  depends_on "z80oolong/eaw/ncurses-eaw@6.5"
  unless OS.mac?
    depends_on "pkgconf" => :build
    depends_on "cyrus-sasl"
    depends_on "krb5"
  end

  def install
    old_curses_f = Formula["ncurses"]
    new_curses_f = Formula["z80oolong/eaw/ncurses-eaw@6.5"]

    ENV.replace_rpath old_curses_f.lib     => new_curses_f.lib,
                      old_curses_f.opt_lib => new_curses_f.opt_lib
    ENV.append "CFLAGS",   "-I#{Formula["z80oolong/eaw/ncurses-eaw@6.5"].opt_include}"
    ENV.append "CPPFLAGS", "-I#{Formula["z80oolong/eaw/ncurses-eaw@6.5"].opt_include}"
    ENV.append "LDFLAGS",  "-L#{Formula["z80oolong/eaw/ncurses-eaw@6.5"].opt_lib}"
    ENV["XML_CATALOG_FILES"] = "#{etc}/xml/catalog"

    args = std_configure_args
    args << "--enable-gpgme"
    args << "--with-gpgme=#{Formula["gpgme"].opt_prefix}"
    args << "--disable-doc"
    args << "--gss"
    args << "--lmdb"
    args << "--notmuch"
    args << "--sasl"
    args << "--tokyocabinet"
    args << "--with-ssl=#{Formula["openssl@1.1"].opt_prefix}"
    args << "--with-ui=ncurses"
    args << "--with-ncurses=#{Formula["z80oolong/eaw/ncurses-eaw@6.5"].opt_prefix}"
    args << "--lua"
    args << "--with-lua=#{Formula["lua"].prefix}"

    system "./configure", *args
    system "make"
    system "make", "install"
  end

  test do
    output = shell_output("#{bin}/neomutt -F /dev/null -Q debug_level")
    assert_equal "set debug_level = 0", output.chomp
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
