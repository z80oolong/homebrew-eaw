require "#{Tap.fetch("z80oolong/eaw").path}/lib/extend.rb"
ENV.extend(EnvExtend)

class MuttCurrent < Formula
  include DiffDataMixin

  desc "Mongrel of mail user agents (part elm, pine, mush, mh, etc.)"
  homepage "http://www.mutt.org/"
  license "GPL-2.0-or-later"
  revision 3

  stable do
    url "http://ftp.mutt.org/pub/mutt/mutt-2.4.3.tar.gz"
    mirror "https://github.com/muttmua/mutt/archive/refs/tags/mutt-2-4-3-rel.tar.gz"
    mirror "https://bitbucket.org/mutt/mutt/downloads/mutt-2.4.3.tar.gz"
    sha256 "ce9154e3afede622d98b90a22c87d06f32051c930a9afb2b7ef41656c4dbc948"

    patch :p1, Formula["mutt@2.4.3"].diff_data
  end

  head do
    url "https://gitlab.com/muttmua/mutt.git", branch: "master"

    patch :p1, Formula["mutt@9999-dev"].diff_data
  end

  keg_only "it conflicts with 'homebrew/core/mutt'"

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

  conflicts_with "tin", because: "both install mmdf.5 and mbox.5 man pages"

  resource "html" do
    url "https://muttmua.gitlab.io/mutt/manual-dev.html"
    sha256 "9065fae00bf57b8f973e287ba7f69487cc7ba5c782593a15527767697f5c620d"
  end

  def install
    old_curses_f = Formula["ncurses"]
    new_curses_f = Formula["z80oolong/eaw/ncurses-eaw@6.5"]

    ENV.replace_rpath old_curses_f.lib     => new_curses_f.lib,
                      old_curses_f.opt_lib => new_curses_f.opt_lib
    ENV.append "CFLAGS",   "-I#{Formula["z80oolong/eaw/ncurses-eaw@6.5"].opt_include}"
    ENV.append "CPPFLAGS", "-I#{Formula["z80oolong/eaw/ncurses-eaw@6.5"].opt_include}"
    ENV.append "LDFLAGS",  "-L#{Formula["z80oolong/eaw/ncurses-eaw@6.5"].opt_lib}"
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
    args << "--with-ssl=#{Formula["openssl@4"].opt_prefix}"
    args << "--with-tokyocabinet"
    args << "--enable-gpgme"
    args << (OS.mac? ? "--with-sasl" : "--with-sasl2")

    system "./prepare", *args
    system "make"
    # This permits the `mutt_dotlock` file to be installed under a group
    # that isn't `mail`.
    # https://github.com/Homebrew/homebrew/issues/45400
    inreplace "Makefile", /^DOTLOCK_GROUP =.*$/,
      "DOTLOCK_GROUP = #{effective_group}" unless user_in_mail_group
    system "make", "install"

    doc.install resource("html")
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
