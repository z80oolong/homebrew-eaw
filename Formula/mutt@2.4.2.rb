class MuttAT242 < Formula
  desc "Mongrel of mail user agents (part elm, pine, mush, mh, etc.)"
  homepage "http://www.mutt.org/"
  url "http://ftp.mutt.org/pub/mutt/mutt-2.4.2.tar.gz"
  mirror "https://github.com/muttmua/mutt/archive/refs/tags/mutt-2-4-2-rel.tar.gz"
  mirror "https://bitbucket.org/mutt/mutt/downloads/mutt-2.4.2.tar.gz"
  sha256 "2703ff1a51a99c3163d4fd998ac22e982bbd5493d512a7c5bde716a8adba0394"
  license "GPL-2.0-or-later"
  revision 4

  keg_only "this is an alternate version of another formula"

  depends_on "autoconf" => :build
  depends_on "automake" => :build
  depends_on "libxslt" => :build
  depends_on "perl" => :build
  depends_on "glibc"
  depends_on "gpgme"
  depends_on "openssl@4"
  depends_on "tokyo-cabinet"
  depends_on "z80oolong/eaw/ncurses-eaw@6.5"

  uses_from_macos "bzip2"
  uses_from_macos "krb5"
  uses_from_macos "zlib"

  patch :p1 do
    file "Patches/mutt/mutt-2.4.2-fix.diff"
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
    ENV.append "CFLAGS",   "-I#{formula_opt_include("z80oolong/eaw/ncurses-eaw@6.5")}"
    ENV.append "CPPFLAGS", "-I#{formula_opt_include("z80oolong/eaw/ncurses-eaw@6.5")}"
    ENV.append "LDFLAGS",  "-I#{formula_opt_lib("z80oolong/eaw/ncurses-eaw@6.5")}"
    ENV["LC_ALL"] = "C"

    user_in_mail_group = Etc.getgrnam("mail").mem.include?(ENV["USER"])
    effective_group = Etc.getgrgid(Process.egid).name

    args = std_configure_args
    args << "--disable-warnings"
    args << "--enable-debug"
    args << "--enable-hcache"
    args << "--enable-imap"
    args << "--enable-pop"
    args << "--enable-sidebar"
    args << "--enable-smtp"
    args << "--with-gss"
    args << "--with-ssl=#{formula_opt_prefix("openssl@4")}"
    args << "--with-tokyocabinet"
    args << "--enable-gpgme"
    args << (OS.mac? ? "--with-sasl" : "--with-sasl2")

    system "./prepare", *args
    system "make"
    # This permits the `mutt_dotlock` file to be installed under a group
    # that isn't `mail`.
    # https://github.com/Homebrew/homebrew/issues/45400
    unless user_in_mail_group
      inreplace "Makefile", /^DOTLOCK_GROUP =.*$/, "DOTLOCK_GROUP = #{effective_group}"
    end
    system "make", "install"
  end

  def caveats
    <<~EOS
      mutt_dotlock(1) has been installed, but does not have the permissions to lock
      spool files in /var/mail. To grant the necessary permissions, run

        sudo chgrp mail #{bin}/mutt_dotlock
        sudo chmod g+s #{bin}/mutt_dotlock

      Alternatively, you may configure `spoolfile` in your .muttrc to a file inside
      your home directory.
    EOS
  end

  test do
    ENV["LC_ALL"] = "C"
    assert_equal "utf8_cjk is unset", shell_output("#{bin}/mutt -F /dev/null -Q utf8_cjk").strip
    assert_equal "utf8_emoji is unset", shell_output("#{bin}/mutt -F /dev/null -Q utf8_emoji").strip
    touch "foo"
    assert_empty shell_output("#{bin}/mutt_dotlock ./foo").strip
    assert_empty shell_output("#{bin}/mutt_dotlock -u ./foo").strip
  end
end
