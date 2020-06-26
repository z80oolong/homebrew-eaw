class Nano < Formula
  desc "Free (GNU) replacement for the Pico text editor"
  homepage "https://www.nano-editor.org/"

  stable do
    url "https://www.nano-editor.org/dist/v4/nano-4.9.3.tar.xz"
    sha256 "6e3438f033a0ed07d3d74c30d0803cbda3d2366ba1601b7bbf9b16ac371f51b4"

    diff_file = Tap.fetch("z80oolong/eaw").path/"diff/nano-#{version}-fix.diff"
    patch :p1, diff_file.open.gets(nil)
  end

  head do
    url "https://git.savannah.gnu.org/git/nano.git"

    diff_file = Tap.fetch("z80oolong/eaw").path/"diff/nano-HEAD-24740815-fix.diff"
    patch :p1, diff_file.open.gets(nil)

    depends_on "automake" => :build
    depends_on "autoconf" => :build
    depends_on "texinfo"  => :build
  end

  depends_on "pkg-config" => :build
  depends_on "patchelf" => :build
  depends_on "gettext"
  depends_on "z80oolong/eaw/ncurses-eaw@6.2"

  depends_on "libmagic" unless OS.mac?

  option "without-utf8-cjk", "Build without using East asian Ambiguous Width Character in tmux."
  option "without-utf8-emoji", "Build without using Emoji Character in tmux."

  def install
    ENV.append "CFLAGS",     "-I#{Formula["z80oolong/eaw/ncurses-eaw@6.2"].opt_include}"
    ENV.append "CPPFLAGS",   "-I#{Formula["z80oolong/eaw/ncurses-eaw@6.2"].opt_include}"
    ENV.append "LDFLAGS",    "-L#{Formula["z80oolong/eaw/ncurses-eaw@6.2"].opt_lib}"

    ENV.append "CPPFLAGS", "-DNO_USE_UTF8CJK" if build.without?("utf8-cjk")
    ENV.append "CPPFLAGS", "-DNO_USE_UTF8CJK_EMOJI" if build.without?("utf8-emoji")

    system "sh", "autogen.sh" if build.head?

    system "./configure", "--disable-debug",
                          "--disable-dependency-tracking",
                          "--prefix=#{prefix}",
                          "--sysconfdir=#{etc}",
                          "--enable-color",
                          "--enable-extra",
                          "--enable-multibuffer",
                          "--enable-nanorc",
                          "--enable-utf8"
    system "make", "install"
    fix_rpath "#{bin}/nano", ["z80oolong/eaw/ncurses-eaw@6.2"], ["ncurses"]
    doc.install "doc/sample.nanorc"
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
    system "#{bin}/nano", "--version"
  end
end
