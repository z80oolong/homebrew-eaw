require "#{Tap.fetch("z80oolong/eaw").path}/lib/extend.rb"
ENV.extend(EnvExtend)

class NeomuttCurrent < Formula
  include DiffDataMixin

  desc "E-mail reader with support for Notmuch, NNTP and much more"
  homepage "https://neomutt.org/"
  license "GPL-2.0-or-later"
  revision 4

  stable do
    url "https://github.com/neomutt/neomutt/archive/refs/tags/20260504.tar.gz"
    sha256 "93fd8344c12cd857f084f8d7cc1187479f79036ab9725cfdbc81c0cc845f1615"

    depends_on "tokyo-cabinet"

    patch :p1, Formula["z80oolong/eaw/neomutt@20260504"].diff_data
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
  depends_on "z80oolong/eaw/ncurses-eaw@6.5"
  unless OS.mac?
    depends_on "pkgconf" => :build
    depends_on "cyrus-sasl"
    depends_on "krb5"
  end

  def install
    include DiffDataMixin

    old_curses_f = Formula["ncurses"]
    new_curses_f = Formula["z80oolong/eaw/ncurses-eaw@6.5"]

    ENV.replace_rpath old_curses_f.lib     => new_curses_f.lib,
                      old_curses_f.opt_lib => new_curses_f.opt_lib
    ENV.append "CFLAGS",   "-I#{new_curses_f.opt_include}"
    ENV.append "CPPFLAGS", "-I#{new_curses_f.opt_include}"
    ENV.append "LDFLAGS",  "-L#{new_curses_f.opt_lib}"
    ENV["XML_CATALOG_FILES"] = "#{etc}/xml/catalog"

    args = std_configure_args
    args << "--enable-gpgme"
    args << "--with-gpgme=#{Formula["gpgme"].opt_prefix}"
    args << "--disable-doc"
    args << "--gss"
    args << "--lmdb"
    args << "--notmuch"
    args << "--sasl"
    args << "--with-ssl=#{Formula["openssl@1.1"].opt_prefix}"
    args << "--with-ui=ncurses"
    args << "--with-ncurses=#{new_curses_f.opt_prefix}"
    args << "--lua"
    args << "--with-lua=#{Formula["lua"].prefix}"
    unless build.head?
      args << "--tokyocabinet"
    end

    system "./configure", *args
    system "make"
    system "make", "install"
  end

  test do
    ENV["LC_ALL"] = "C"
    output = shell_output("#{bin}/neomutt -F /dev/null -Q utf8_cjk 2>/dev/null || true")
    assert_equal "set utf8_cjk = no", output.strip
    output = shell_output("#{bin}/neomutt -F /dev/null -Q utf8_emoji 2>/dev/null || true")
    assert_equal "set utf8_emoji = no", output.strip
  end
end
