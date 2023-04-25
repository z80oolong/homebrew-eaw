class Geany < Formula
  desc "Fast and lightweight IDE"
  homepage "https://www.geany.org/"

  stable do
    url "https://download.geany.org/geany-1.38.tar.bz2"
    sha256 "abff176e4d48bea35ee53037c49c82f90b6d4c23e69aed6e4a5ca8ccd3aad546"
    patch :p1, Formula["z80oolong/eaw/geany@1.38"].diff_data
  end

  head do
    url "https://github.com/geany/geany.git"
    patch :p1, :HEAD

    depends_on "autoconf" => :build
    depends_on "automake" => :build
    depends_on "libtool" => :build
    depends_on "docutils" => :build
  end

  depends_on "pkg-config" => :build
  depends_on "intltool" => :build
  depends_on "gettext"
  depends_on "gtk+3"
  depends_on "hicolor-icon-theme"
  depends_on "z80oolong/eaw/libvte@2.91"
  depends_on "ctags"
  depends_on "pcre"
  depends_on "libsoup"
  depends_on "enchant"
  depends_on "libvterm"
  depends_on "z80oolong/eaw/scintilla@5.3.4"
  depends_on "source-highlight"
  depends_on "lua"

  def install
    system "sh", "./autogen.sh" if head?

    args = %W[
      --disable-dependency-tracking
      --prefix=#{prefix}
      --disable-silent-rules
      --enable-gtk3
      --enable-vte
      --enable-enchant
      --enable-lua
      --enable-plugins
      --with-libvterm=#{Formula["libvterm"].opt_prefix}
    ]

    system "./configure", *args
    system "make", "install"
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
    system "#{bin}/geany", "--version"
  end
end

__END__
diff --git a/src/vte.c b/src/vte.c
index d25a7eb8d..9074019ad 100644
--- a/src/vte.c
+++ b/src/vte.c
@@ -136,6 +136,10 @@ struct VteFunctions
 	void (*vte_terminal_set_color_foreground_rgba) (VteTerminal *terminal, const GdkRGBA *foreground);
 	void (*vte_terminal_set_color_bold_rgba) (VteTerminal *terminal, const GdkRGBA *foreground);
 	void (*vte_terminal_set_color_background_rgba) (VteTerminal *terminal, const GdkRGBA *background);
+#ifndef NO_UTF8_CJK
+	void (*vte_terminal_set_cjk_ambiguous_width) (VteTerminal *terminal, int width);
+	int  (*vte_terminal_get_cjk_ambiguous_width) (VteTerminal *terminal);
+#endif
 };
 
 
@@ -339,6 +343,9 @@ static gboolean vte_start_idle(G_GNUC_UNUSED gpointer user_data)
 static void create_vte(void)
 {
 	GtkWidget *vte, *scrollbar, *hbox;
+#ifndef NO_UTF8_CJK
+	char *vte_cjk_width = NULL;
+#endif
 
 	vte_config.vte = vte = vf->vte_terminal_new();
 	scrollbar = gtk_scrollbar_new(GTK_ORIENTATION_VERTICAL, vf->vte_terminal_get_adjustment(VTE_TERMINAL(vte)));
@@ -382,6 +389,14 @@ static void create_vte(void)
 	gtk_notebook_insert_page(GTK_NOTEBOOK(msgwindow.notebook), hbox, terminal_label, MSG_VTE);
 
 	g_signal_connect_after(vte, "realize", G_CALLBACK(on_vte_realize), NULL);
+#ifndef NO_UTF8_CJK
+    vte_cjk_width = g_getenv("VTE_CJK_WIDTH");
+    if ((vte_cjk_width != NULL) && (strncmp((const char *)vte_cjk_width, "1", (size_t)1) == 0)) {
+        if (vf->vte_terminal_get_cjk_ambiguous_width(VTE_TERMINAL(vte)) != 2) {
+            vf->vte_terminal_set_cjk_ambiguous_width(VTE_TERMINAL(vte), 2);
+        }
+    }
+#endif
 }
 
 
@@ -629,6 +644,10 @@ static gboolean vte_register_symbols(GModule *mod)
 	if (! BIND_SYMBOL(vte_terminal_get_adjustment))
 		/* vte_terminal_get_adjustment() is available since 0.9 and removed in 0.38 */
 		vf->vte_terminal_get_adjustment = default_vte_terminal_get_adjustment;
+#ifndef NO_UTF8_CJK
+	BIND_REQUIRED_SYMBOL(vte_terminal_set_cjk_ambiguous_width);
+	BIND_REQUIRED_SYMBOL(vte_terminal_get_cjk_ambiguous_width);
+#endif
 
 	#undef BIND_REQUIRED_SYMBOL_RGBA_WRAPPED
 	#undef BIND_REQUIRED_SYMBOL
