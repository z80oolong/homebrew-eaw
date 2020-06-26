class NeomuttAT20200501 < Formula
  desc "E-mail reader with support for Notmuch, NNTP and much more"
  homepage "https://neomutt.org/"
  url "https://github.com/neomutt/neomutt/archive/20200501.tar.gz"
  sha256 "9d0a0da14448ebb60f2585532fc4cd903c10146903c8639cd0a3d51fe620430f"

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

  diff_file = Tap.fetch("z80oolong/eaw").path/"diff/neomutt-#{version}-fix.diff"
  patch :p1, diff_file.open.gets(nil)

  keg_only :versioned_formula

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

  test do
    output = shell_output("#{bin}/neomutt -F /dev/null -Q debug_level")
    assert_equal "set debug_level = 0", output.chomp
  end
end
