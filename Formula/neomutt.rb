class Neomutt < Formula
  desc "E-mail reader with support for Notmuch, NNTP and much more"
  homepage "https://neomutt.org/"

  stable do
    url "https://github.com/neomutt/neomutt/archive/20200619.tar.gz"
    sha256 "4449d43b3586a730ead151c66afc6af37e3ea15b3e72065e579a9e9884146acc"

    diff_file = Tap.fetch("z80oolong/eaw").path/"diff/neomutt-#{version}-fix.diff"
    unless diff_file.exist? then
      diff_file = Formula["z80oolong/eaw/#{name}"].opt_prefix/".brew/neomutt-#{version}-fix.diff"
    end
    patch :p1, diff_file.open.gets(nil)
  end

  head do
    url "https://github.com/neomutt/neomutt.git"

    diff_file = Tap.fetch("z80oolong/eaw").path/"diff/neomutt-HEAD-90c5333f9-fix.diff"
    unless diff_file.exist? then
      diff_file = Formula["z80oolong/eaw/#{name}"].opt_prefix/".brew/neomutt-HEAD-90c5333f9-fix.diff"
    end
    patch :p1, diff_file.open.gets(nil)
  end

  depends_on "patchelf" => :build
  depends_on "gettext"
  depends_on "gpgme"
  depends_on "libidn"
  depends_on "lmdb"
  depends_on "lua"
  depends_on "notmuch"
  depends_on "openssl@1.1"
  depends_on "tokyo-cabinet"
  depends_on "z80oolong/eaw/ncurses-eaw@6.2"
  unless OS.mac?
    depends_on "krb5"
    depends_on "libsasl2"
  end

  def install
    ENV.append "CFLAGS",   "-I#{Formula["z80oolong/eaw/ncurses-eaw@6.2"].opt_include}"
    ENV.append "CPPFLAGS", "-I#{Formula["z80oolong/eaw/ncurses-eaw@6.2"].opt_include}"
    ENV.append "LDFLAGS",  "-L#{Formula["z80oolong/eaw/ncurses-eaw@6.2"].opt_lib}"
    ENV["XML_CATALOG_FILES"] = "#{etc}/xml/catalog"

    system "./configure", "--prefix=#{prefix}",
                          "--enable-gpgme",
                          "--with-gpgme=#{Formula["gpgme"].opt_prefix}",
                          "--disable-doc",
                          "--gss",
                          "--lmdb",
                          "--notmuch",
                          "--sasl",
                          "--tokyocabinet",
                          "--with-ssl=#{Formula["openssl@1.1"].opt_prefix}",
                          "--with-ui=ncurses",
                          "--with-ncurses=#{Formula["z80oolong/eaw/ncurses-eaw@6.2"].opt_prefix}",
                          "--lua",
                          "--with-lua=#{Formula["lua"].prefix}"
    system "make", "install"
    fix_rpath "#{bin}/neomutt", ["z80oolong/eaw/ncurses-eaw@6.2"], ["ncurses"]
  end

  def fix_rpath(binname, append_list, delete_list)
    delete_list_hash = {}
    rpath = %x{#{Formula["patchelf"].opt_bin}/patchelf --print-rpath #{binname}}.chomp.split(":")

    (append_list + delete_list).each {|name| delete_list_hash["#{Formula[name].opt_lib}"] = true}
    rpath.delete_if {|path| delete_list_hash[path]}
    append_list.each {|name| rpath.unshift("#{Formula[name].opt_lib}")}

    system "#{Formula["patchelf"].opt_bin}/patchelf", "--set-rpath", "#{rpath.join(":")}", "#{binname}"
  end

  def post_install
    if build.head? then
      system "install", "-m", "0444", Tap.fetch("z80oolong/eaw").path/"diff/neomutt-HEAD-90c5333f9-fix.diff", "#{prefix}/.brew"
    else
      system "install", "-m", "0444", Tap.fetch("z80oolong/eaw").path/"diff/neomutt-#{version}-fix.diff", "#{prefix}/.brew"
    end
  end

  test do
    output = shell_output("#{bin}/neomutt -F /dev/null -Q debug_level")
    assert_equal "set debug_level = 0", output.chomp
  end
end
