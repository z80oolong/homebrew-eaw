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

class MuttCurrent < Formula
  desc "Mongrel of mail user agents (part elm, pine, mush, mh, etc.)"
  homepage "http://www.mutt.org/"
  license "GPL-2.0-or-later"
  revision 3

  stable do
    url "https://bitbucket.org/mutt/mutt/downloads/mutt-2.2.14.tar.gz"
    sha256 "d162fb6d491e3af43d6f62f949b7e687bb0c7c2584da52c99a99354a25de14ef"

    patch :p1, Formula["mutt@2.2.14"].diff_data
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
  depends_on "openssl@3"
  depends_on "tokyo-cabinet"
  depends_on "z80oolong/eaw/ncurses-eaw@6.5"

  uses_from_macos "bzip2"
  uses_from_macos "krb5"
  uses_from_macos "zlib"

  conflicts_with "tin", because: "both install mmdf.5 and mbox.5 man pages"

  resource "html" do
    url "https://muttmua.gitlab.io/mutt/manual-dev.html"
    sha256 "107c8e55cf0a2801cbec22055758c9554726a3db8e908c6aee5448385925753d"
  end

  def install
    ENV.replace_rpath "ncurses" => "z80oolong/eaw/ncurses-eaw@6.5"
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
    args << "--with-ssl=#{Formula["openssl@3"].opt_prefix}"
    args << "--with-tokyocabinet"
    args << "--enable-gpgme"
    args << (OS.mac? ? "--with-sasl" : "--with-sasl2")

    system "./prepare", *args
    system "make"
    # This permits the `mutt_dotlock` file to be installed under a group
    # that isn't `mail`.
    # https://github.com/Homebrew/homebrew/issues/45400
    inreplace "Makefile", /^DOTLOCK_GROUP =.*$/, "DOTLOCK_GROUP = #{effective_group}" unless user_in_mail_group
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
    system bin/"mutt", "-D"
    touch "foo"
    system bin/"mutt_dotlock", "foo"
    system bin/"mutt_dotlock", "-u", "foo"
  end
end
