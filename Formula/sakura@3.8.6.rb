class SakuraAT386 < Formula
  desc "GTK/VTE based terminal emulator."
  homepage "https://launchpad.net/sakura"
  license "GPL-2.0"
  url "https://github.com/dabisu/sakura/archive/refs/tags/SAKURA_3_8_6.tar.gz"
  sha256 "2cea5840c34e8d1a17b055dadc6efa6b5f1d97bb39d6b78590dba0915d19b0a7"

  keg_only :versioned_formula

  patch :p1, :DATA

  depends_on "gtk+3"
  depends_on "z80oolong/eaw/libvte@2.91"
  depends_on "systemd"
  depends_on "gettext"
  depends_on "pod2man" => :build
  depends_on "cmake" => :build

  def install
    std_cmake_args << "CMAKE_BUILD_TYPE=Debug"

    system "cmake", "-S", ".", "-B", "build", *std_cmake_args
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"
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
    system "#{bin}/sakura", "--version"
  end
end

__END__
diff --git a/src/sakura.c b/src/sakura.c
index d842b3a..9cddb40 100644
--- a/src/sakura.c
+++ b/src/sakura.c
@@ -2934,6 +2934,9 @@ sakura_add_tab()
 	GtkWidget *event_box;
 	int index; int npages;
 	gchar *cwd = NULL; gchar *default_label_text = NULL;
+#ifndef NO_UTF8_CJK
+	gchar *vte_cjk_width = NULL;
+#endif
 
 	sk_tab = g_new0(struct sakura_tab, 1);
 
@@ -2979,6 +2982,14 @@ sakura_add_tab()
 	sk_tab->hbox = gtk_box_new(GTK_ORIENTATION_HORIZONTAL, 0);
 	gtk_box_pack_start(GTK_BOX(sk_tab->hbox), sk_tab->vte, TRUE, TRUE, 0);
 	gtk_box_pack_start(GTK_BOX(sk_tab->hbox), sk_tab->scrollbar, FALSE, FALSE, 0);
+#ifndef NO_UTF8_CJK
+	vte_cjk_width = g_getenv("VTE_CJK_WIDTH");
+	if ((vte_cjk_width != NULL) && (strcmp(vte_cjk_width, "1") == 0)) {
+		vte_terminal_set_cjk_ambiguous_width(VTE_TERMINAL(sk_tab->vte), 2);
+	} else {
+		vte_terminal_set_cjk_ambiguous_width(VTE_TERMINAL(sk_tab->vte), 1);
+	}
+#endif
 
 	sk_tab->colorset = sakura.last_colorset-1;
 
