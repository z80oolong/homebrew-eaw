class NanoAT63 < Formula
  desc "Free (GNU) replacement for the Pico text editor"
  homepage "https://www.nano-editor.org/"
  license "GPL-3.0-or-later"
  url "https://www.nano-editor.org/dist/v6/nano-6.3.tar.xz"
  sha256 "eb532da4985672730b500f685dbaab885a466d08fbbf7415832b95805e6f8687"

  depends_on "pkg-config" => :build
  depends_on "gettext"
  depends_on "z80oolong/eaw/ncurses-eaw@6.2"

  on_linux do
    depends_on "patchelf" => :build
  end

  depends_on "libmagic" unless OS.mac?

  keg_only :versioned_formula

  patch :p1, :DATA

  def install
    ENV.append "CFLAGS",   "-I#{Formula["z80oolong/eaw/ncurses-eaw@6.2"].opt_include}"
    ENV.append "CPPFLAGS", "-I#{Formula["z80oolong/eaw/ncurses-eaw@6.2"].opt_include}"
    ENV.append "LDFLAGS",  "-L#{Formula["z80oolong/eaw/ncurses-eaw@6.2"].opt_lib}"

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
    return unless OS.linux?

    delete_list_hash = {}
    rpath = %x{#{Formula["patchelf"].opt_bin}/patchelf --print-rpath #{binname}}.chomp.split(":")

    (append_list + delete_list).each {|name| delete_list_hash["#{Formula[name].opt_lib}"] = true}
    rpath.delete_if {|path| delete_list_hash[path]}
    append_list.each {|name| rpath.unshift("#{Formula[name].opt_lib}")}

    system "#{Formula["patchelf"].opt_bin}/patchelf", "--set-rpath", "#{rpath.join(":")}", "#{binname}"
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
    system "#{bin}/nano", "--version"
  end
end

__END__
diff --git a/src/chars.c b/src/chars.c
index 2b8714c..0a035aa 100644
--- a/src/chars.c
+++ b/src/chars.c
@@ -28,6 +28,405 @@
 #include <wchar.h>
 #include <wctype.h>
 
+#ifndef NO_USE_UTF8CJK
+/*
+ * This is an implementation of wcwidth() and wcswidth() (defined in
+ * IEEE Std 1002.1-2001) for Unicode.
+ *
+ * http://www.opengroup.org/onlinepubs/007904975/functions/wcwidth.html
+ * http://www.opengroup.org/onlinepubs/007904975/functions/wcswidth.html
+ *
+ * In fixed-width output devices, Latin characters all occupy a single
+ * "cell" position of equal width, whereas ideographic CJK characters
+ * occupy two such cells. Interoperability between terminal-line
+ * applications and (teletype-style) character terminals using the
+ * UTF-8 encoding requires agreement on which character should advance
+ * the cursor by how many cell positions. No established formal
+ * standards exist at present on which Unicode character shall occupy
+ * how many cell positions on character terminals. These routines are
+ * a first attempt of defining such behavior based on simple rules
+ * applied to data provided by the Unicode Consortium.
+ *
+ * For some graphical characters, the Unicode standard explicitly
+ * defines a character-cell width via the definition of the East Asian
+ * FullWidth (F), Wide (W), Half-width (H), and Narrow (Na) classes.
+ * In all these cases, there is no ambiguity about which width a
+ * terminal shall use. For characters in the East Asian Ambiguous (A)
+ * class, the width choice depends purely on a preference of backward
+ * compatibility with either historic CJK or Western practice.
+ * Choosing single-width for these characters is easy to justify as
+ * the appropriate long-term solution, as the CJK practice of
+ * displaying these characters as double-width comes from historic
+ * implementation simplicity (8-bit encoded characters were displayed
+ * single-width and 16-bit ones double-width, even for Greek,
+ * Cyrillic, etc.) and not any typographic considerations.
+ *
+ * Much less clear is the choice of width for the Not East Asian
+ * (Neutral) class. Existing practice does not dictate a width for any
+ * of these characters. It would nevertheless make sense
+ * typographically to allocate two character cells to characters such
+ * as for instance EM SPACE or VOLUME INTEGRAL, which cannot be
+ * represented adequately with a single-width glyph. The following
+ * routines at present merely assign a single-cell width to all
+ * neutral characters, in the interest of simplicity. This is not
+ * entirely satisfactory and should be reconsidered before
+ * establishing a formal standard in this area. At the moment, the
+ * decision which Not East Asian (Neutral) characters should be
+ * represented by double-width glyphs cannot yet be answered by
+ * applying a simple rule from the Unicode database content. Setting
+ * up a proper standard for the behavior of UTF-8 character terminals
+ * will require a careful analysis not only of each Unicode character,
+ * but also of each presentation form, something the author of these
+ * routines has avoided to do so far.
+ *
+ * http://www.unicode.org/unicode/reports/tr11/
+ *
+ * Markus Kuhn -- 2007-05-26 (Unicode 5.0)
+ *
+ * Permission to use, copy, modify, and distribute this software
+ * for any purpose and without fee is hereby granted. The author
+ * disclaims all warranties with regard to this software.
+ *
+ * Latest version: http://www.cl.cam.ac.uk/~mgk25/ucs/wcwidth.c
+ */
+
+// Delete duplicated '#include <wchar.h>' by Z.OOL. <zool@zool.jpn.org>
+//#include <wchar.h>
+
+struct interval {
+  int first;
+  int last;
+};
+
+/* auxiliary function for binary search in interval table */
+static int bisearch(wchar_t ucs, const struct interval *table, int max) {
+  int min = 0;
+  int mid;
+
+  if (ucs < table[0].first || ucs > table[max].last)
+    return 0;
+  while (max >= min) {
+    mid = (min + max) / 2;
+    if (ucs > table[mid].last)
+      min = mid + 1;
+    else if (ucs < table[mid].first)
+      max = mid - 1;
+    else
+      return 1;
+  }
+
+  return 0;
+}
+
+/* The following two functions define the column width of an ISO 10646
+ * character as follows:
+ *
+ *    - The null character (U+0000) has a column width of 0.
+ *
+ *    - Other C0/C1 control characters and DEL will lead to a return
+ *      value of -1.
+ *
+ *    - Non-spacing and enclosing combining characters (general
+ *      category code Mn or Me in the Unicode database) have a
+ *      column width of 0.
+ *
+ *    - SOFT HYPHEN (U+00AD) has a column width of 1.
+ *
+ *    - Other format characters (general category code Cf in the Unicode
+ *      database) and ZERO WIDTH SPACE (U+200B) have a column width of 0.
+ *
+ *    - Hangul Jamo medial vowels and final consonants (U+1160-U+11FF)
+ *      have a column width of 0.
+ *
+ *    - Spacing characters in the East Asian Wide (W) or East Asian
+ *      Full-width (F) category as defined in Unicode Technical
+ *      Report #11 have a column width of 2.
+ *
+ *    - All remaining characters (including all printable
+ *      ISO 8859-1 and WGL4 characters, Unicode control characters,
+ *      etc.) have a column width of 1.
+ *
+ * This implementation assumes that wchar_t characters are encoded
+ * in ISO 10646.
+ */
+
+int mk_wcwidth(wchar_t ucs)
+{
+  /* sorted list of non-overlapping intervals of non-spacing characters */
+  /* generated by "uniset +cat=Me +cat=Mn +cat=Cf -00AD +1160-11FF +200B c" */
+  static const struct interval combining[] = {
+    { 0x0300, 0x036F }, { 0x0483, 0x0486 }, { 0x0488, 0x0489 },
+    { 0x0591, 0x05BD }, { 0x05BF, 0x05BF }, { 0x05C1, 0x05C2 },
+    { 0x05C4, 0x05C5 }, { 0x05C7, 0x05C7 }, { 0x0600, 0x0603 },
+    { 0x0610, 0x0615 }, { 0x064B, 0x065E }, { 0x0670, 0x0670 },
+    { 0x06D6, 0x06E4 }, { 0x06E7, 0x06E8 }, { 0x06EA, 0x06ED },
+    { 0x070F, 0x070F }, { 0x0711, 0x0711 }, { 0x0730, 0x074A },
+    { 0x07A6, 0x07B0 }, { 0x07EB, 0x07F3 }, { 0x0901, 0x0902 },
+    { 0x093C, 0x093C }, { 0x0941, 0x0948 }, { 0x094D, 0x094D },
+    { 0x0951, 0x0954 }, { 0x0962, 0x0963 }, { 0x0981, 0x0981 },
+    { 0x09BC, 0x09BC }, { 0x09C1, 0x09C4 }, { 0x09CD, 0x09CD },
+    { 0x09E2, 0x09E3 }, { 0x0A01, 0x0A02 }, { 0x0A3C, 0x0A3C },
+    { 0x0A41, 0x0A42 }, { 0x0A47, 0x0A48 }, { 0x0A4B, 0x0A4D },
+    { 0x0A70, 0x0A71 }, { 0x0A81, 0x0A82 }, { 0x0ABC, 0x0ABC },
+    { 0x0AC1, 0x0AC5 }, { 0x0AC7, 0x0AC8 }, { 0x0ACD, 0x0ACD },
+    { 0x0AE2, 0x0AE3 }, { 0x0B01, 0x0B01 }, { 0x0B3C, 0x0B3C },
+    { 0x0B3F, 0x0B3F }, { 0x0B41, 0x0B43 }, { 0x0B4D, 0x0B4D },
+    { 0x0B56, 0x0B56 }, { 0x0B82, 0x0B82 }, { 0x0BC0, 0x0BC0 },
+    { 0x0BCD, 0x0BCD }, { 0x0C3E, 0x0C40 }, { 0x0C46, 0x0C48 },
+    { 0x0C4A, 0x0C4D }, { 0x0C55, 0x0C56 }, { 0x0CBC, 0x0CBC },
+    { 0x0CBF, 0x0CBF }, { 0x0CC6, 0x0CC6 }, { 0x0CCC, 0x0CCD },
+    { 0x0CE2, 0x0CE3 }, { 0x0D41, 0x0D43 }, { 0x0D4D, 0x0D4D },
+    { 0x0DCA, 0x0DCA }, { 0x0DD2, 0x0DD4 }, { 0x0DD6, 0x0DD6 },
+    { 0x0E31, 0x0E31 }, { 0x0E34, 0x0E3A }, { 0x0E47, 0x0E4E },
+    { 0x0EB1, 0x0EB1 }, { 0x0EB4, 0x0EB9 }, { 0x0EBB, 0x0EBC },
+    { 0x0EC8, 0x0ECD }, { 0x0F18, 0x0F19 }, { 0x0F35, 0x0F35 },
+    { 0x0F37, 0x0F37 }, { 0x0F39, 0x0F39 }, { 0x0F71, 0x0F7E },
+    { 0x0F80, 0x0F84 }, { 0x0F86, 0x0F87 }, { 0x0F90, 0x0F97 },
+    { 0x0F99, 0x0FBC }, { 0x0FC6, 0x0FC6 }, { 0x102D, 0x1030 },
+    { 0x1032, 0x1032 }, { 0x1036, 0x1037 }, { 0x1039, 0x1039 },
+    { 0x1058, 0x1059 }, { 0x1160, 0x11FF }, { 0x135F, 0x135F },
+    { 0x1712, 0x1714 }, { 0x1732, 0x1734 }, { 0x1752, 0x1753 },
+    { 0x1772, 0x1773 }, { 0x17B4, 0x17B5 }, { 0x17B7, 0x17BD },
+    { 0x17C6, 0x17C6 }, { 0x17C9, 0x17D3 }, { 0x17DD, 0x17DD },
+    { 0x180B, 0x180D }, { 0x18A9, 0x18A9 }, { 0x1920, 0x1922 },
+    { 0x1927, 0x1928 }, { 0x1932, 0x1932 }, { 0x1939, 0x193B },
+    { 0x1A17, 0x1A18 }, { 0x1B00, 0x1B03 }, { 0x1B34, 0x1B34 },
+    { 0x1B36, 0x1B3A }, { 0x1B3C, 0x1B3C }, { 0x1B42, 0x1B42 },
+    { 0x1B6B, 0x1B73 }, { 0x1DC0, 0x1DCA }, { 0x1DFE, 0x1DFF },
+    { 0x200B, 0x200F }, { 0x202A, 0x202E }, { 0x2060, 0x2063 },
+    { 0x206A, 0x206F }, { 0x20D0, 0x20EF }, { 0x302A, 0x302F },
+    { 0x3099, 0x309A }, { 0xA806, 0xA806 }, { 0xA80B, 0xA80B },
+    { 0xA825, 0xA826 }, { 0xFB1E, 0xFB1E }, { 0xFE00, 0xFE0F },
+    { 0xFE20, 0xFE23 }, { 0xFEFF, 0xFEFF }, { 0xFFF9, 0xFFFB },
+    { 0x10A01, 0x10A03 }, { 0x10A05, 0x10A06 }, { 0x10A0C, 0x10A0F },
+    { 0x10A38, 0x10A3A }, { 0x10A3F, 0x10A3F }, { 0x1D167, 0x1D169 },
+    { 0x1D173, 0x1D182 }, { 0x1D185, 0x1D18B }, { 0x1D1AA, 0x1D1AD },
+    { 0x1D242, 0x1D244 }, { 0xE0001, 0xE0001 }, { 0xE0020, 0xE007F },
+    { 0xE0100, 0xE01EF }
+  };
+
+  /* test for 8-bit control characters */
+  if (ucs == 0)
+    return 0;
+  if (ucs < 32 || (ucs >= 0x7f && ucs < 0xa0))
+    return -1;
+
+  /* binary search in table of non-spacing characters */
+  if (bisearch(ucs, combining,
+	       sizeof(combining) / sizeof(struct interval) - 1))
+    return 0;
+
+  /* if we arrive here, ucs is not a combining or C0/C1 control character */
+
+  return 1 + 
+    (ucs >= 0x1100 &&
+     (ucs <= 0x115f ||                    /* Hangul Jamo init. consonants */
+      ucs == 0x2329 || ucs == 0x232a ||
+      (ucs >= 0x2e80 && ucs <= 0xa4cf &&
+       ucs != 0x303f) ||                  /* CJK ... Yi */
+      (ucs >= 0xac00 && ucs <= 0xd7a3) || /* Hangul Syllables */
+      (ucs >= 0xf900 && ucs <= 0xfaff) || /* CJK Compatibility Ideographs */
+      (ucs >= 0xfe10 && ucs <= 0xfe19) || /* Vertical forms */
+      (ucs >= 0xfe30 && ucs <= 0xfe6f) || /* CJK Compatibility Forms */
+      (ucs >= 0xff00 && ucs <= 0xff60) || /* Fullwidth Forms */
+      (ucs >= 0xffe0 && ucs <= 0xffe6) ||
+      (ucs >= 0x20000 && ucs <= 0x2fffd) ||
+      (ucs >= 0x30000 && ucs <= 0x3fffd)));
+}
+
+int mk_wcswidth(const wchar_t *pwcs, size_t n)
+{
+  int w, width = 0;
+
+  for (;*pwcs && n-- > 0; pwcs++)
+    if ((w = mk_wcwidth(*pwcs)) < 0)
+      return -1;
+    else
+      width += w;
+
+  return width;
+}
+
+/*
+ * The following functions are the same as mk_wcwidth() and
+ * mk_wcswidth(), except that spacing characters in the East Asian
+ * Ambiguous (A) category as defined in Unicode Technical Report #11
+ * have a column width of 2. This variant might be useful for users of
+ * CJK legacy encodings who want to migrate to UCS without changing
+ * the traditional terminal character-width behaviour. It is not
+ * otherwise recommended for general use.
+ */
+int mk_wcwidth_cjk(wchar_t ucs)
+{
+  /* sorted list of non-overlapping intervals of East Asian Ambiguous
+   * characters, generated by "uniset +WIDTH-A -cat=Me -cat=Mn -cat=Cf c" */
+  static const struct interval ambiguous[] = {
+    { 0x00A1, 0x00A1 }, { 0x00A4, 0x00A4 }, { 0x00A7, 0x00A8 },
+    { 0x00AA, 0x00AA }, { 0x00AE, 0x00AE }, { 0x00B0, 0x00B4 },
+    { 0x00B6, 0x00BA }, { 0x00BC, 0x00BF }, { 0x00C6, 0x00C6 },
+    { 0x00D0, 0x00D0 }, { 0x00D7, 0x00D8 }, { 0x00DE, 0x00E1 },
+    { 0x00E6, 0x00E6 }, { 0x00E8, 0x00EA }, { 0x00EC, 0x00ED },
+    { 0x00F0, 0x00F0 }, { 0x00F2, 0x00F3 }, { 0x00F7, 0x00FA },
+    { 0x00FC, 0x00FC }, { 0x00FE, 0x00FE }, { 0x0101, 0x0101 },
+    { 0x0111, 0x0111 }, { 0x0113, 0x0113 }, { 0x011B, 0x011B },
+    { 0x0126, 0x0127 }, { 0x012B, 0x012B }, { 0x0131, 0x0133 },
+    { 0x0138, 0x0138 }, { 0x013F, 0x0142 }, { 0x0144, 0x0144 },
+    { 0x0148, 0x014B }, { 0x014D, 0x014D }, { 0x0152, 0x0153 },
+    { 0x0166, 0x0167 }, { 0x016B, 0x016B }, { 0x01CE, 0x01CE },
+    { 0x01D0, 0x01D0 }, { 0x01D2, 0x01D2 }, { 0x01D4, 0x01D4 },
+    { 0x01D6, 0x01D6 }, { 0x01D8, 0x01D8 }, { 0x01DA, 0x01DA },
+    { 0x01DC, 0x01DC }, { 0x0251, 0x0251 }, { 0x0261, 0x0261 },
+    { 0x02C4, 0x02C4 }, { 0x02C7, 0x02C7 }, { 0x02C9, 0x02CB },
+    { 0x02CD, 0x02CD }, { 0x02D0, 0x02D0 }, { 0x02D8, 0x02DB },
+    { 0x02DD, 0x02DD }, { 0x02DF, 0x02DF }, { 0x0391, 0x03A1 },
+    { 0x03A3, 0x03A9 }, { 0x03B1, 0x03C1 }, { 0x03C3, 0x03C9 },
+    { 0x0401, 0x0401 }, { 0x0410, 0x044F }, { 0x0451, 0x0451 },
+    { 0x2010, 0x2010 }, { 0x2013, 0x2016 }, { 0x2018, 0x2019 },
+    { 0x201C, 0x201D }, { 0x2020, 0x2022 }, { 0x2024, 0x2027 },
+    { 0x2030, 0x2030 }, { 0x2032, 0x2033 }, { 0x2035, 0x2035 },
+    { 0x203B, 0x203B }, { 0x203E, 0x203E }, { 0x2074, 0x2074 },
+    { 0x207F, 0x207F }, { 0x2081, 0x2084 }, { 0x20AC, 0x20AC },
+    { 0x2103, 0x2103 }, { 0x2105, 0x2105 }, { 0x2109, 0x2109 },
+    { 0x2113, 0x2113 }, { 0x2116, 0x2116 }, { 0x2121, 0x2122 },
+    { 0x2126, 0x2126 }, { 0x212B, 0x212B }, { 0x2153, 0x2154 },
+    { 0x215B, 0x215E }, { 0x2160, 0x216B }, { 0x2170, 0x2179 },
+    { 0x2190, 0x2199 }, { 0x21B8, 0x21B9 }, { 0x21D2, 0x21D2 },
+    { 0x21D4, 0x21D4 }, { 0x21E7, 0x21E7 }, { 0x2200, 0x2200 },
+    { 0x2202, 0x2203 }, { 0x2207, 0x2208 }, { 0x220B, 0x220B },
+    { 0x220F, 0x220F }, { 0x2211, 0x2211 }, { 0x2215, 0x2215 },
+    { 0x221A, 0x221A }, { 0x221D, 0x2220 }, { 0x2223, 0x2223 },
+    { 0x2225, 0x2225 }, { 0x2227, 0x222C }, { 0x222E, 0x222E },
+    { 0x2234, 0x2237 }, { 0x223C, 0x223D }, { 0x2248, 0x2248 },
+    { 0x224C, 0x224C }, { 0x2252, 0x2252 }, { 0x2260, 0x2261 },
+    { 0x2264, 0x2267 }, { 0x226A, 0x226B }, { 0x226E, 0x226F },
+    { 0x2282, 0x2283 }, { 0x2286, 0x2287 }, { 0x2295, 0x2295 },
+    { 0x2299, 0x2299 }, { 0x22A5, 0x22A5 }, { 0x22BF, 0x22BF },
+    { 0x2312, 0x2312 }, { 0x2460, 0x24E9 }, { 0x24EB, 0x254B },
+    { 0x2550, 0x2573 }, { 0x2580, 0x258F }, { 0x2592, 0x2595 },
+    { 0x25A0, 0x25A1 }, { 0x25A3, 0x25A9 }, { 0x25B2, 0x25B3 },
+    { 0x25B6, 0x25B7 }, { 0x25BC, 0x25BD }, { 0x25C0, 0x25C1 },
+    { 0x25C6, 0x25C8 }, { 0x25CB, 0x25CB }, { 0x25CE, 0x25D1 },
+    { 0x25E2, 0x25E5 }, { 0x25EF, 0x25EF }, { 0x2605, 0x2606 },
+    { 0x2609, 0x2609 }, { 0x260E, 0x260F }, { 0x2614, 0x2615 },
+    { 0x261C, 0x261C }, { 0x261E, 0x261E }, { 0x2640, 0x2640 },
+    { 0x2642, 0x2642 }, { 0x2660, 0x2661 }, { 0x2663, 0x2665 },
+    { 0x2667, 0x266A }, { 0x266C, 0x266D }, { 0x266F, 0x266F },
+    { 0x273D, 0x273D }, { 0x2776, 0x277F }, { 0xE000, 0xF8FF },
+    { 0xFFFD, 0xFFFD }, { 0xF0000, 0xFFFFD }, { 0x100000, 0x10FFFD }
+  };
+
+  /* binary search in table of non-spacing characters */
+  if (bisearch(ucs, ambiguous,
+	       sizeof(ambiguous) / sizeof(struct interval) - 1))
+    return 2;
+
+  return mk_wcwidth(ucs);
+}
+
+int mk_wcswidth_cjk(const wchar_t *pwcs, size_t n)
+{
+  int w, width = 0;
+
+  for (;*pwcs && n-- > 0; pwcs++)
+    if ((w = mk_wcwidth_cjk(*pwcs)) < 0)
+      return -1;
+    else
+      width += w;
+
+  return width;
+}
+
+#ifndef NO_USE_UTF8CJK_EMOJI
+/* The following functions are the same as mk_wcwidth_cjk() and
+ * mk_wcswidth_cjk(), except that spacing characters in the "Emoji"
+ * characters as defined in Unicode have a column width of 2.
+ * This function is based on the following vim-jp issue,
+ * by Mr.mattn <https://github.com/mattn>.
+ *
+ * https://github.com/vim-jp/issues/issues/1086
+ */
+int mk_wcwidth_cjk_emoji(wchar_t ucs)
+{
+  /* Sorted list of non-overlapping intervals of all Emoji characters,
+   * based on http://unicode.org/emoji/charts/emoji-list.html */
+
+  static const struct interval emoji_all[] = {
+    { 0x203c, 0x203c }, { 0x2049, 0x2049 }, { 0x2122, 0x2122 },
+    { 0x2139, 0x2139 }, { 0x2194, 0x2199 }, { 0x21a9, 0x21aa },
+    { 0x231a, 0x231b }, { 0x2328, 0x2328 }, { 0x23cf, 0x23cf },
+    { 0x23e9, 0x23f3 }, { 0x23f8, 0x23fa }, { 0x24c2, 0x24c2 },
+    { 0x25aa, 0x25ab }, { 0x25b6, 0x25b6 }, { 0x25c0, 0x25c0 },
+    { 0x25fb, 0x25fe }, { 0x2600, 0x2604 }, { 0x260e, 0x260e },
+    { 0x2611, 0x2611 }, { 0x2614, 0x2615 }, { 0x2618, 0x2618 },
+    { 0x261d, 0x261d }, { 0x2620, 0x2620 }, { 0x2622, 0x2623 },
+    { 0x2626, 0x2626 }, { 0x262a, 0x262a }, { 0x262e, 0x262f },
+    { 0x2638, 0x263a }, { 0x2640, 0x2640 }, { 0x2642, 0x2642 },
+    { 0x2648, 0x2653 }, { 0x2660, 0x2660 }, { 0x2663, 0x2663 },
+    { 0x2665, 0x2666 }, { 0x2668, 0x2668 }, { 0x267b, 0x267b },
+    { 0x267f, 0x267f }, { 0x2692, 0x2697 }, { 0x2699, 0x2699 },
+    { 0x269b, 0x269c }, { 0x26a0, 0x26a1 }, { 0x26aa, 0x26ab },
+    { 0x26b0, 0x26b1 }, { 0x26bd, 0x26be }, { 0x26c4, 0x26c5 },
+    { 0x26c8, 0x26c8 }, { 0x26ce, 0x26cf }, { 0x26d1, 0x26d1 },
+    { 0x26d3, 0x26d4 }, { 0x26e9, 0x26ea }, { 0x26f0, 0x26f5 },
+    { 0x26f7, 0x26fa }, { 0x26fd, 0x26fd }, { 0x2702, 0x2702 },
+    { 0x2705, 0x2705 }, { 0x2708, 0x270d }, { 0x270f, 0x270f },
+    { 0x2712, 0x2712 }, { 0x2714, 0x2714 }, { 0x2716, 0x2716 },
+    { 0x271d, 0x271d }, { 0x2721, 0x2721 }, { 0x2728, 0x2728 },
+    { 0x2733, 0x2734 }, { 0x2744, 0x2744 }, { 0x2747, 0x2747 },
+    { 0x274c, 0x274c }, { 0x274e, 0x274e }, { 0x2753, 0x2755 },
+    { 0x2757, 0x2757 }, { 0x2763, 0x2764 }, { 0x2795, 0x2797 },
+    { 0x27a1, 0x27a1 }, { 0x27b0, 0x27b0 }, { 0x27bf, 0x27bf },
+    { 0x2934, 0x2935 }, { 0x2b05, 0x2b07 }, { 0x2b1b, 0x2b1c },
+    { 0x2b50, 0x2b50 }, { 0x2b55, 0x2b55 }, { 0x3030, 0x3030 },
+    { 0x303d, 0x303d }, { 0x3297, 0x3297 }, { 0x3299, 0x3299 },
+    { 0x1f004, 0x1f004 }, { 0x1f0cf, 0x1f0cf }, { 0x1f170, 0x1f171 },
+    { 0x1f17e, 0x1f17f }, { 0x1f18e, 0x1f18e }, { 0x1f191, 0x1f19a },
+    { 0x1f1e6, 0x1f1ff }, { 0x1f201, 0x1f202 }, { 0x1f21a, 0x1f21a },
+    { 0x1f22f, 0x1f22f }, { 0x1f232, 0x1f23a }, { 0x1f250, 0x1f251 },
+    { 0x1f300, 0x1f321 }, { 0x1f324, 0x1f393 }, { 0x1f396, 0x1f397 },
+    { 0x1f399, 0x1f39b }, { 0x1f39e, 0x1f3f0 }, { 0x1f3f3, 0x1f3f5 },
+    { 0x1f3f7, 0x1f4fd }, { 0x1f4ff, 0x1f53d }, { 0x1f549, 0x1f54e },
+    { 0x1f550, 0x1f567 }, { 0x1f56f, 0x1f570 }, { 0x1f573, 0x1f57a },
+    { 0x1f587, 0x1f587 }, { 0x1f58a, 0x1f58d }, { 0x1f590, 0x1f590 },
+    { 0x1f595, 0x1f596 }, { 0x1f5a4, 0x1f5a5 }, { 0x1f5a8, 0x1f5a8 },
+    { 0x1f5b1, 0x1f5b2 }, { 0x1f5bc, 0x1f5bc }, { 0x1f5c2, 0x1f5c4 },
+    { 0x1f5d1, 0x1f5d3 }, { 0x1f5dc, 0x1f5de }, { 0x1f5e1, 0x1f5e1 },
+    { 0x1f5e3, 0x1f5e3 }, { 0x1f5e8, 0x1f5e8 }, { 0x1f5ef, 0x1f5ef },
+    { 0x1f5f3, 0x1f5f3 }, { 0x1f5fa, 0x1f64f }, { 0x1f680, 0x1f6c5 },
+    { 0x1f6cb, 0x1f6d2 }, { 0x1f6e0, 0x1f6e5 }, { 0x1f6e9, 0x1f6e9 },
+    { 0x1f6eb, 0x1f6ec }, { 0x1f6f0, 0x1f6f0 }, { 0x1f6f3, 0x1f6f8 },
+    { 0x1f910, 0x1f93a }, { 0x1f93c, 0x1f93e }, { 0x1f940, 0x1f945 },
+    { 0x1f947, 0x1f94c }, { 0x1f950, 0x1f96b }, { 0x1f980, 0x1f997 },
+    { 0x1f9c0, 0x1f9c0 }, { 0x1f9d0, 0x1f9e6 }
+  };
+
+  /* binary search in table of non-spacing characters */
+  if (bisearch(ucs, emoji_all,
+	       sizeof(emoji_all) / sizeof(struct interval) - 1))
+    return 2;
+
+  return mk_wcwidth_cjk(ucs);
+}
+#endif /* NO_USE_UTF8CJK_EMOJI */
+
+int nano_wcwidth(wchar_t wc)
+{
+#ifndef NO_USE_UTF8CJK_EMOJI
+	if (ISSET(UTF8EMOJI))
+		return mk_wcwidth_cjk_emoji(wc);
+	else if (ISSET(UTF8CJK))
+		return mk_wcwidth_cjk(wc);
+	else
+		return mk_wcwidth(wc);
+#else
+	if (ISSET(UTF8CJK))
+		return mk_wcwidth_cjk(wc);
+	else
+		return mk_wcwidth(wc);
+#endif /* NO_USE_UTF8CJK_EMOJI */
+}
+#endif /* NO_USE_UTF8CJK */
+
 static bool use_utf8 = FALSE;
 		/* Whether we've enabled UTF-8 support. */
 
@@ -234,8 +633,11 @@ bool is_doublewidth(const char *ch)
 
 	if (mbtowide(&wc, ch) < 0)
 		return FALSE;
-
+#ifndef NO_USE_UTF8CJK
+	return (nano_wcwidth(wc) == 2);
+#else
 	return (wcwidth(wc) == 2);
+#endif
 }
 
 /* Return TRUE when the given character occupies zero cells. */
@@ -256,7 +658,11 @@ bool is_zerowidth(const char *ch)
 		return FALSE;
 #endif
 
+#ifndef NO_USE_UTF8CJK
+	return (nano_wcwidth(wc) == 0);
+#else
 	return (wcwidth(wc) == 0);
+#endif
 }
 #endif /* ENABLE_UTF8 */
 
@@ -341,7 +747,11 @@ int advance_over(const char *string, size_t *column)
 				return 1;
 			}
 
+#ifndef NO_USE_UTF8CJK
+			int width = nano_wcwidth(wc);
+#else
 			int width = wcwidth(wc);
+#endif
 
 #if defined(__OpenBSD__)
 			*column += (width < 0 || wc >= 0xF0000) ? 1 : width;
diff --git a/src/definitions.h b/src/definitions.h
index 5c517a3..bf72656 100644
--- a/src/definitions.h
+++ b/src/definitions.h
@@ -358,6 +358,12 @@ enum {
 	LET_THEM_ZAP,
 	BREAK_LONG_LINES,
 	JUMPY_SCROLLING,
+#ifndef NO_USE_UTF8CJK
+	UTF8CJK,
+#ifndef NO_USE_UTF8CJK_EMOJI
+	UTF8EMOJI,
+#endif /* NO_USE_UTF8CJK_EMOJI */
+#endif /* NO_USE_UTF8CJK */
 	EMPTY_LINE,
 	INDICATOR,
 	BOOKSTYLE,
diff --git a/src/global.c b/src/global.c
index a3c90fe..0075e8d 100644
--- a/src/global.c
+++ b/src/global.c
@@ -92,8 +92,12 @@ int didfind = 0;
 char *present_path = NULL;
 		/* The current browser directory when trying to do tab completion. */
 
+#if 0
 unsigned flags[4] = {0, 0, 0, 0};
+#else
+unsigned flags[8] = {0, 0, 0, 0, 0, 0, 0, 0};
 		/* Our flags array, containing the states of all global options. */
+#endif
 
 int controlleft, controlright, controlup, controldown;
 int controlhome, controlend;
diff --git a/src/nano.c b/src/nano.c
index 8133478..47bde3b 100644
--- a/src/nano.c
+++ b/src/nano.c
@@ -658,6 +658,14 @@ void usage(void)
 #ifdef HAVE_LIBMAGIC
 	print_opt("-!", "--magic", N_("Also try magic to determine syntax"));
 #endif
+#ifdef ENABLE_UTF8
+#ifndef NO_USE_UTF8CJK
+	print_opt("-8", "--utf8cjk", N_("Set width of UTF-8 East Asia Ambiguous Width Character to 2."));
+#ifndef NO_USE_UTF8CJK_EMOJI
+	print_opt("-4", "--utf8emoji", N_("Set width of UTF-8 Emoji Character to 2."));
+#endif /* NO_USE_UTF8CJK_EMOJI */
+#endif /* NO_USE_UTF8CJK */ 
+#endif
 }
 
 /* Display the version number of this nano, a copyright notice, some contact
@@ -1776,6 +1784,14 @@ int main(int argc, char **argv)
 #ifdef HAVE_LIBMAGIC
 		{"magic", 0, NULL, '!'},
 #endif
+#ifdef ENABLE_UTF8
+#ifndef NO_USE_UTF8CJK
+		{"utf8cjk", 0, NULL, '8'},
+#ifndef NO_USE_UTF8CJK_EMOJI
+		{"utf8emoji", 0, NULL, '4'},
+#endif /* NO_USE_UTF8CJK_EMOJI */
+#endif /* NO_USE_UTF8CJK */
+#endif /* ENABLE_UTF8 */
 		{NULL, 0, NULL, 0}
 	};
 
@@ -1806,7 +1822,16 @@ int main(int argc, char **argv)
 #endif
 
 #ifdef ENABLE_NLS
+#if 1
+	const char *locale_dir;
+
+	if ((locale_dir = getenv("LOCALEDIR")) == NULL)
+		locale_dir = LOCALEDIR;
+
+	bindtextdomain(PACKAGE, locale_dir);
+#else
 	bindtextdomain(PACKAGE, LOCALEDIR);
+#endif
 	textdomain(PACKAGE);
 #endif
 
@@ -1817,8 +1842,18 @@ int main(int argc, char **argv)
 	if (*(tail(argv[0])) == 'r')
 		SET(RESTRICTED);
 
+#ifndef NO_USE_UTF8CJK
+#ifndef NO_USE_UTF8CJK_EMOJI
+	while ((optchr = getopt_long(argc, argv, "0ABC:DEFGHIJ:KLMNOPQ:RST:UVWX:Y:Z"
+				"abcdef:ghijklmno:pqr:s:tuvwxyz84$%_!", long_options, NULL)) != -1) {
+#else
+	while ((optchr = getopt_long(argc, argv, "0ABC:DEFGHIJ:KLMNOPQ:RST:UVWX:Y:Z"
+				"abcdef:ghijklmno:pqr:s:tuvwxyz8$%_!", long_options, NULL)) != -1) {
+#endif /* NO_USE_UTF8CJK_EMOJI */
+#else
 	while ((optchr = getopt_long(argc, argv, "0ABC:DEFGHIJ:KLMNOPQ:RST:UVWX:Y:Z"
 				"abcdef:ghijklmno:pqr:s:tuvwxyz$%_!", long_options, NULL)) != -1) {
+#endif /* NO_USE_UTF8CJK */
 		switch (optchr) {
 #ifndef NANO_TINY
 			case 'A':
@@ -2053,6 +2088,19 @@ int main(int argc, char **argv)
 #endif
 			case 'z':
 				break;
+#ifdef ENABLE_UTF8
+#ifndef NO_USE_UTF8CJK
+			case '8':
+				SET(UTF8CJK);
+				break;
+#ifndef NO_USE_UTF8CJK_EMOJI
+			case '4':
+				SET(UTF8CJK);
+				SET(UTF8EMOJI);
+				break;
+#endif
+#endif
+#endif
 #ifndef NANO_TINY
 			case '%':
 				SET(STATEFLAGS);
@@ -2079,6 +2127,21 @@ int main(int argc, char **argv)
 	if (getenv("TERM") == NULL)
 		putenv("TERM=vt220");
 
+#ifdef ENABLE_UTF8
+#ifndef NO_USE_UTF8CJK
+	const char *lc_ctype;
+
+	if ((lc_ctype = setlocale(LC_CTYPE, "")) != NULL) {
+		if (!strncmp(lc_ctype, "ja", 2) || !strncmp(lc_ctype, "ko", 2) || !strncmp(lc_ctype, "zh", 2)) {
+			SET(UTF8CJK);
+#ifndef NO_USE_UTF8CJK_EMOJI
+			SET(UTF8EMOJI);
+#endif
+		}
+	}
+#endif
+#endif
+
 	/* Enter into curses mode.  Abort if this fails. */
 	if (initscr() == NULL)
 		exit(1);
diff --git a/src/prototypes.h b/src/prototypes.h
index 0708ded..890d94d 100644
--- a/src/prototypes.h
+++ b/src/prototypes.h
@@ -61,7 +61,11 @@ extern int didfind;
 
 extern char *present_path;
 
+#if 0
 extern unsigned flags[4];
+#else
+extern unsigned flags[8];
+#endif
 
 extern int controlleft, controlright;
 extern int controlup, controldown;
diff --git a/src/rcfile.c b/src/rcfile.c
index 049a288..61390c5 100644
--- a/src/rcfile.c
+++ b/src/rcfile.c
@@ -137,6 +137,14 @@ static const rcoption rcopts[] = {
 	{"errorcolor", 0},
 	{"keycolor", 0},
 	{"functioncolor", 0},
+#endif
+#ifdef ENABLE_UTF8
+#ifndef NO_USE_UTF8CJK
+	{"utf8cjk", UTF8CJK},
+#ifndef NO_USE_UTF8CJK_EMOJI
+	{"utf8emoji", UTF8EMOJI},
+#endif /* NO_USE_UTF8CJK_EMOJI */
+#endif /* NO_USE_UTF8CJK */
 #endif
 	{NULL, 0}
 };
diff --git a/src/winio.c b/src/winio.c
index dee5485..e4f4367 100644
--- a/src/winio.c
+++ b/src/winio.c
@@ -29,6 +29,9 @@
 #include <string.h>
 #ifdef ENABLE_UTF8
 #include <wchar.h>
+#ifndef NO_USE_UTF8CJK
+extern int nano_wcwidth(wchar_t ucs);
+#endif /* NO_USE_UTF8CJK */
 #endif
 
 #ifdef REVISION
@@ -1855,7 +1858,11 @@ char *display_string(const char *text, size_t column, size_t span,
 		}
 
 		/* Determine whether the character takes zero, one, or two columns. */
+#ifndef NO_USE_UTF8CJK
+		charwidth = nano_wcwidth(wc);
+#else
 		charwidth = wcwidth(wc);
+#endif /* NO_USE_UTF8CJK */
 
 		/* Watch the number of zero-widths, to keep ample memory reserved. */
 		if (charwidth == 0 && --stowaways == 0) {
