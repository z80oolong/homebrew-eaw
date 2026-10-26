class NeomuttAT9999Dev < Formula
  desc "E-mail reader with support for Notmuch, NNTP and much more"
  homepage "https://neomutt.org/"

  CURRENT_COMMIT = "2f5469f2ab3619011631416eb91ee6214c624554".freeze
  url "https://github.com/neomutt/neomutt.git", branch: "main", revision: CURRENT_COMMIT
  version "git-#{CURRENT_COMMIT[0..7]}"
  license "GPL-2.0-or-later"
  revision 5

  keg_only "this is an alternate version of another formula"

  depends_on "gettext"
  depends_on "glibc"
  depends_on "gpgme"
  depends_on "libidn"
  depends_on "lmdb"
  depends_on "lua"
  depends_on "notmuch"
  depends_on "openssl@4"
  depends_on "z80oolong/eaw/ncurses-eaw@6.5"
  unless OS.mac?
    depends_on "pkgconf" => :build
    depends_on "cyrus-sasl"
    depends_on "krb5"
  end

  patch :p1 do
    file "Patches/neomutt/neomutt-HEAD-#{CURRENT_COMMIT[0..8]}-fix.diff"
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
    ENV.append "CFLAGS",   "-I#{new_curses_f.opt_include}"
    ENV.append "CPPFLAGS", "-I#{new_curses_f.opt_include}"
    ENV.append "LDFLAGS",  "-L#{new_curses_f.opt_lib}"
    ENV["XML_CATALOG_FILES"] = "#{etc}/xml/catalog"

    args = std_configure_args
    args << "--enable-gpgme"
    args << "--with-gpgme=#{formula_opt_prefix("gpgme")}"
    args << "--disable-doc"
    args << "--gss"
    args << "--lmdb"
    args << "--notmuch"
    args << "--sasl"
    args << "--with-ssl=#{formula_opt_prefix("openssl@4")}"
    args << "--with-ui=ncurses"
    args << "--with-ncurses=#{new_curses_f.opt_prefix}"
    args << "--lua"
    args << "--with-lua=#{formula_opt_prefix("lua")}"

    system "./configure", *args
    system "make"
    system "make", "install"
  end

  def caveats
    <<~EOS
      #{full_name} is a Formula for installing the development version of
      `neomutt` based on the HEAD version (commit #{CURRENT_COMMIT[0..7]}) from its Github repository.
    EOS
  end

  test do
    ENV["LC_ALL"] = "C"
    output = shell_output("#{bin}/neomutt -F /dev/null -Q debug_level 2>/dev/null || true")
    assert_equal "set debug_level = 0", output.strip
    output = shell_output("#{bin}/neomutt -F /dev/null -Q utf8_cjk 2>/dev/null || true")
    assert_equal "set utf8_cjk = no", output.strip
    output = shell_output("#{bin}/neomutt -F /dev/null -Q utf8_emoji 2>/dev/null || true")
    assert_equal "set utf8_emoji = no", output.strip
  end
end
