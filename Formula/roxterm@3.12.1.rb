class RoxtermAT3121 < Formula
  desc "ROXTerm is a terminal emulator intended to provide similar features to gnome-terminal, based on the same VTE library, but with a smaller footprint and quicker start-up time."
  homepage "https://roxterm.sourceforge.io/"
  url "https://github.com/realh/roxterm/archive/refs/tags/3.12.1.tar.gz"
  sha256 "9a662a00fe555ae9ff38301a1707a3432d8f678326062c98740f20827280a5aa"

  depends_on "cmake" => :build
  depends_on "pkg-config" => :build
  depends_on "libxslt" => :build
  depends_on "docbook-xsl" => :build
  depends_on "glib"
  depends_on "dbus-glib"
  depends_on "gtk+3"
  depends_on "z80oolong/eaw/libvte@2.91"

  keg_only :versioned_formula

  patch :p1, :DATA

  def install
    inreplace "CMakeLists.txt" do |s|
      s.gsub!(%r|http://docbook.sourceforge.net/release/xsl/current/manpages/docbook.xsl|, "#{Formula["docbook-xsl"].opt_prefix}/docbook-xsl-ns/manpages/docbook.xsl")
    end

    mkdir "build" do
      system "cmake", "..", *std_cmake_args
      system "make", "install"
    end
  end

  def diff_data
    lines = self.path.each_line.inject([]) do |result, line|
      result.push(line) if ((/^__END__/ === line) || result.first)
      result
    end
    lines.shift
    return lines.join("")
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/roxterm --version")
  end
end

__END__
diff --git a/src/roxterm.c b/src/roxterm.c
index 74de25e..8ad791b 100644
--- a/src/roxterm.c
+++ b/src/roxterm.c
@@ -3123,6 +3123,9 @@ static GtkWidget *roxterm_multi_tab_filler(MultiWin * win, MultiTab * tab,
     gboolean custom_tab_name = FALSE;
     MultiWin *template_win = roxterm_get_win(roxterm_template);
     GtkWidget *viewport = NULL;
+#ifndef NO_UTF8_CJK
+    char *vte_cjk_width = NULL;
+#endif
 
     roxterm_terms = g_list_append(roxterm_terms, roxterm);
 
@@ -3149,6 +3152,14 @@ static GtkWidget *roxterm_multi_tab_filler(MultiWin * win, MultiTab * tab,
             roxterm->columns, roxterm->rows);
     gtk_widget_grab_focus(roxterm->widget);
     vte = VTE_TERMINAL(roxterm->widget);
+#ifndef NO_UTF8_CJK
+    vte_cjk_width = g_getenv("VTE_CJK_WIDTH");
+    if ((vte_cjk_width != NULL) && (strncmp((const char *)vte_cjk_width, "1", (size_t)1) == 0)) {
+        if (vte_terminal_get_cjk_ambiguous_width(vte) != 2) {
+            vte_terminal_set_cjk_ambiguous_width(vte, 2);
+        }
+    }
+#endif
     if (vte_widget)
         *vte_widget = roxterm->widget;
     if (adjustment)
