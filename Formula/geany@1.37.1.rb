class GeanyAT1371 < Formula
  desc "Fast and lightweight IDE"
  homepage "https://www.geany.org/"
  url "https://download.geany.org/geany-1.37.1.tar.gz"
  sha256 "3978148c57570df8ed817afe050bc038f1b4dd39dc8efeb0acb19cd4f0690a58"

  keg_only :versioned_formula

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

  patch :p1, :DATA

  def install
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
index 612a6e0..3f0b908 100644
--- a/src/vte.c
+++ b/src/vte.c
@@ -138,6 +138,10 @@ struct VteFunctions
 	void (*vte_terminal_set_color_bold_rgba) (VteTerminal *terminal, const GdkRGBA *foreground);
 	void (*vte_terminal_set_color_background_rgba) (VteTerminal *terminal, const GdkRGBA *background);
 #endif
+#ifndef NO_UTF8_CJK
+	void (*vte_terminal_set_cjk_ambiguous_width) (VteTerminal *terminal, int width);
+	int  (*vte_terminal_get_cjk_ambiguous_width) (VteTerminal *terminal);
+#endif
 };
 
 
@@ -348,6 +352,9 @@ static gboolean vte_start_idle(G_GNUC_UNUSED gpointer user_data)
 static void create_vte(void)
 {
 	GtkWidget *vte, *scrollbar, *hbox;
+#ifndef NO_UTF8_CJK
+	char *vte_cjk_width = NULL;
+#endif
 
 	vc->vte = vte = vf->vte_terminal_new();
 	scrollbar = gtk_vscrollbar_new(vf->vte_terminal_get_adjustment(VTE_TERMINAL(vte)));
@@ -391,6 +398,14 @@ static void create_vte(void)
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
 
 
@@ -642,6 +657,10 @@ static gboolean vte_register_symbols(GModule *mod)
 	if (! BIND_SYMBOL(vte_terminal_get_adjustment))
 		/* vte_terminal_get_adjustment() is available since 0.9 and removed in 0.38 */
 		vf->vte_terminal_get_adjustment = default_vte_terminal_get_adjustment;
+#ifndef NO_UTF8_CJK
+	BIND_REQUIRED_SYMBOL(vte_terminal_set_cjk_ambiguous_width);
+	BIND_REQUIRED_SYMBOL(vte_terminal_get_cjk_ambiguous_width);
+#endif
 
 	#undef BIND_REQUIRED_SYMBOL_RGBA_WRAPPED
 	#undef BIND_REQUIRED_SYMBOL
