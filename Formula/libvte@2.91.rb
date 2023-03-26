class LibvteAT291 < Formula
  desc "VTE provides a virtual terminal widget for GTK applications."
  homepage "https://gitlab.gnome.org/GNOME/vte"
  license "CC-BY-4.0 GPL-3.0 LGPL-3.0"

  stable do
    url "https://github.com/GNOME/vte/archive/refs/tags/0.71.92.tar.gz"
    sha256 "ea0f9ef37726aa6e6b0b0cfa6006cfb0b694aeae103f677977bc4d10f256c225"
  end

  head do
    url "https://github.com/GNOME/vte.git"
  end

  depends_on "gtk+3"
  depends_on "gnutls"
  depends_on "systemd"
  depends_on "gobject-introspection"
  depends_on "meson" => :build
  depends_on "ninja" => :build
  depends_on "cmake" => :build
  depends_on "vala"  => :build

  keg_only :versioned_formula

  def install
    system "meson", "setup", "build", *std_meson_args, "-Ddebug=true"
    system "meson", "compile", "-C", "build", "--verbose"
    system "meson", "install", "-C", "build"
  end

  test do
    system "false"
  end
end
