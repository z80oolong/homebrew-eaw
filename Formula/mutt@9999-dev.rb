require "#{Tap.fetch("z80oolong/eaw").path}/lib/extend.rb"
ENV.extend(EnvExtend)

class MuttAT9999Dev < Formula
  include DiffDataMixin

  desc "Mongrel of mail user agents (part elm, pine, mush, mh, etc.)"
  homepage "http://www.mutt.org/"

  CURRENT_COMMIT = "844fcfe7861631359ee789e4231d322144a1bd3b".freeze
  url "https://gitlab.com/muttmua/mutt.git", revision: CURRENT_COMMIT
  version "git-#{CURRENT_COMMIT[0..7]}"
  license "GPL-2.0-or-later"
  revision 3

  keg_only :versioned_fomula

  depends_on "autoconf" => :build
  depends_on "automake" => :build
  depends_on "libxslt" => :build
  depends_on "perl" => :build
  depends_on "glibc"
  depends_on "gpgme"
  depends_on "openssl@4"
  depends_on "tokyo-cabinet"
  depends_on "z80oolong/eaw/ncurses-eaw@6.5"

  uses_from_macos "bzip2"
  uses_from_macos "krb5"
  uses_from_macos "zlib"

  resource "html" do
    url "https://muttmua.gitlab.io/mutt/manual-dev.html"
    sha256 "9065fae00bf57b8f973e287ba7f69487cc7ba5c782593a15527767697f5c620d"
  end

  patch :p1, :DATA

  def install
    old_curses_f = Formula["ncurses"]
    new_curses_f = Formula["z80oolong/eaw/ncurses-eaw@6.5"]

    ENV.replace_rpath old_curses_f.lib     => new_curses_f.lib,
                      old_curses_f.opt_lib => new_curses_f.opt_lib
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
    args << "--with-ssl=#{Formula["openssl@4"].opt_prefix}"
    args << "--with-tokyocabinet"
    args << "--enable-gpgme"
    args << (OS.mac? ? "--with-sasl" : "--with-sasl2")

    system "./prepare", *args
    system "make"
    # This permits the `mutt_dotlock` file to be installed under a group
    # that isn't `mail`.
    # https://github.com/Homebrew/homebrew/issues/45400
    inreplace "Makefile", /^DOTLOCK_GROUP =.*$/,
      "DOTLOCK_GROUP = #{effective_group}" unless user_in_mail_group
    system "make", "install"

    doc.install resource("html")
  end

  def caveats
    <<~EOS
      #{full_name} is a Formula for installing the development version of
      `mutt` based on the HEAD version (commit #{CURRENT_COMMIT[0..7]}) from its Github repository.

      mutt_dotlock(1) has been installed, but does not have the permissions to lock
      spool files in /var/mail. To grant the necessary permissions, run

      sudo chgrp mail #{bin}/mutt_dotlock
      sudo chmod g+s #{bin}/mutt_dotlock

      Alternatively, you may configure `spoolfile` in your .muttrc to a file inside
      your home directory.
    EOS
  end

  test do
    ENV["LC_ALL"] = "C"
    assert_equal "utf8_cjk is unset", shell_output("#{bin}/mutt -F /dev/null -Q utf8_cjk").strip
    assert_equal "utf8_emoji is unset", shell_output("#{bin}/mutt -F /dev/null -Q utf8_emoji").strip
    touch "foo"
    assert_empty shell_output("#{bin}/mutt_dotlock ./foo").strip
    assert_empty shell_output("#{bin}/mutt_dotlock -u ./foo").strip
  end
end

__END__
diff --git a/curs_lib.c b/curs_lib.c
index 5c93cbb0..64587730 100644
--- a/curs_lib.c
+++ b/curs_lib.c
@@ -1414,7 +1414,11 @@ void mutt_format_string(char *dest, size_t destlen,
       else
         if (!IsWPrint(wc))
           wc = '?';
+#ifndef NO_USE_MKWCWIDTH
+      w = mutt_wcwidth(wc);
+#else
       w = wcwidth(wc);
+#endif
     }
     if (w >= 0)
     {
@@ -1543,7 +1547,11 @@ void mutt_paddstr(int n, const char *s)
     }
     if (!IsWPrint(wc))
       wc = '?';
+#ifndef NO_USE_MKWCWIDTH
+    w = mutt_wcwidth(wc);
+#else
     w = wcwidth(wc);
+#endif
     if (w >= 0)
     {
       if (w > n)
@@ -1580,7 +1588,11 @@ size_t mutt_wstr_trunc(const char *src, size_t maxlen, size_t maxwid, size_t *wi
       cl = (cl == (size_t)(-1)) ? 1 : n;
       wc = replacement_char();
     }
+#ifndef NO_USE_MKWCWIDTH
+    cw = mutt_wcwidth(wc);
+#else
     cw = wcwidth(wc);
+#endif
     /* hack because MUTT_TREE symbols aren't turned into characters
      * until rendered by print_enriched_string (#3364) */
     if (cw < 0 && cl == 1 && src[0] && src[0] < MUTT_TREE_MAX)
@@ -1618,7 +1630,11 @@ int mutt_charlen(const char *s, int *width)
   memset(&mbstate, 0, sizeof(mbstate));
   k = mbrtowc(&wc, s, n, &mbstate);
   if (width)
+#ifndef NO_USE_MKWCWIDTH
+    *width = mutt_wcwidth(wc);
+#else
     *width = wcwidth(wc);
+#endif
   return (k == (size_t)(-1) || k == (size_t)(-2)) ? -1 : k;
 }
 
@@ -1650,7 +1666,11 @@ int mutt_strwidth(const char *s)
     }
     if (!IsWPrint(wc))
       wc = '?';
+#ifndef NO_USE_MKWCWIDTH
+    w += mutt_wcwidth(wc);
+#else
     w += wcwidth(wc);
+#endif
   }
   return w;
 }
diff --git a/enter.c b/enter.c
index fc6f7ee9..9dde0539 100644
--- a/enter.c
+++ b/enter.c
@@ -27,6 +27,9 @@
 #include "keymap.h"
 #include "history.h"
 #include "buffy.h"
+#ifndef NO_USE_MKWCWIDTH
+#include "mbyte.h"
+#endif
 
 #include <string.h>
 
@@ -39,7 +42,11 @@ enum
 
 static int my_wcwidth(wchar_t wc)
 {
+#ifndef NO_USE_MKWCWIDTH
+  int n = mutt_wcwidth(wc);
+#else
   int n = wcwidth(wc);
+#endif
   if (IsWPrint(wc) && n > 0)
     return n;
   if (!(wc & ~0x7f))
@@ -50,7 +57,11 @@ static int my_wcwidth(wchar_t wc)
 }
 
 /* combining mark / non-spacing character */
+#ifndef NO_USE_MKWCWIDTH
+#define COMB_CHAR(wc) (IsWPrint(wc) && !mutt_wcwidth(wc))
+#else
 #define COMB_CHAR(wc) (IsWPrint(wc) && !wcwidth(wc))
+#endif
 
 static int my_wcswidth(const wchar_t *s, size_t n)
 {
@@ -62,7 +73,11 @@ static int my_wcswidth(const wchar_t *s, size_t n)
 
 static int my_addwch(wchar_t wc)
 {
+#ifndef NO_USE_MKWCWIDTH
+  int n = mutt_wcwidth(wc);
+#else
   int n = wcwidth(wc);
+#endif
   if (IsWPrint(wc) && n > 0)
     return mutt_addwch(wc);
   if (!(wc & ~0x7f))
diff --git a/help.c b/help.c
index e1e839fd..4b135d20 100644
--- a/help.c
+++ b/help.c
@@ -109,7 +109,11 @@ static int print_macro(FILE *f, int maxwidth, const char **macro)
       wc = replacement_char();
     }
     /* glibc-2.1.3's wcwidth() returns 1 for unprintable chars! */
+#ifndef NO_USE_MKWCWIDTH
+    if (IsWPrint(wc) && (w = mutt_wcwidth(wc)) >= 0)
+#else
     if (IsWPrint(wc) && (w = wcwidth(wc)) >= 0)
+#endif
     {
       if (w > n)
         break;
@@ -174,7 +178,11 @@ static int get_wrapped_width(const char *t, size_t wid)
     }
     if (!IsWPrint(wc))
       wc = '?';
+#ifndef NO_USE_MKWCWIDTH
+    n += mutt_wcwidth(wc);
+#else
     n += wcwidth(wc);
+#endif
   }
   if (n > wid)
     n = m;
diff --git a/init.h b/init.h
index 394d3d1d..3b972735 100644
--- a/init.h
+++ b/init.h
@@ -5015,6 +5015,12 @@ struct option_t MuttVars[] = {
   {"xterm_set_titles",  DT_SYN,  R_NONE, {.p="ts_enabled"}, {.p=0} },
   /*
   */
+#ifndef NO_USE_MKWCWIDTH
+  {"utf8_cjk",          DT_BOOL, R_NONE, {.l=OPTUTF8CJK}, {.l=0} },
+#ifndef NO_USE_UTF8CJK_EMOJI
+  {"utf8_emoji",        DT_BOOL, R_NONE, {.l=OPTUTF8CJKEMOJI}, {.l=0} },
+#endif
+#endif
   /*--*/
   { NULL, 0, 0, {.l=0}, {.l=0} }
 };
diff --git a/mbyte.c b/mbyte.c
index 8e8b8719..00c01b5d 100644
--- a/mbyte.c
+++ b/mbyte.c
@@ -67,7 +67,329 @@ void mutt_set_charset(char *charset)
 #endif
 }
 
+#ifndef NO_USE_MKWCWIDTH
+int mk_wcwidth(wchar_t wc);
+int mk_wcwidth_cjk(wchar_t wc);
+int mk_wcwidth_cjk_emoji(wchar_t wc);
+
+int mutt_wcwidth (wchar_t wc)
+{
+  if (option(OPTUTF8CJKEMOJI))
+    return mk_wcwidth_cjk_emoji(wc);
+  else if (option(OPTUTF8CJK))
+    return mk_wcwidth_cjk(wc);
+  else
+    return mk_wcwidth(wc);
+}
+#endif
+
+#ifndef HAVE_WC_FUNCS
+/*
+ * For systems that don't have them, we provide here our own
+ * implementations of wcrtomb(), mbrtowc(), iswprint() and wcwidth().
+ * Instead of using the locale, as these functions normally would,
+ * we use Mutt's Charset variable. We support 3 types of charset:
+ * (1) For 8-bit charsets, wchar_t uses the same encoding as char.
+ * (2) For UTF-8, wchar_t uses UCS.
+ * (3) For stateless Japanese encodings, we use UCS and convert
+ *     via UTF-8 using iconv.
+ * Unfortunately, we can't handle non-stateless encodings.
+ */
+
+static size_t wcrtomb_iconv (char *s, wchar_t wc, iconv_t cd)
+{
+  char buf[MB_LEN_MAX+1];
+  ICONV_CONST char *ib;
+  char *ob;
+  size_t ibl, obl;
+
+  if (s)
+  {
+    ibl = mutt_wctoutf8 (buf, wc, sizeof (buf));
+    if (ibl == (size_t)(-1))
+      return (size_t)(-1);
+    ib = buf;
+    ob = s;
+    obl = MB_LEN_MAX;
+    iconv (cd, &ib, &ibl, &ob, &obl);
+  }
+  else
+  {
+    ib = "";
+    ibl = 1;
+    ob = buf;
+    obl = sizeof (buf);
+    iconv (cd, &ib, &ibl, &ob, &obl);
+  }
+  return ob - s;
+}
+
+size_t wcrtomb (char *s, wchar_t wc, mbstate_t *ps)
+{
+  /* We only handle stateless encodings, so we can ignore ps. */
+
+  if (Charset_is_utf8)
+    return mutt_wctoutf8 (s, wc, MB_LEN_MAX);
+  else if (charset_from_utf8 != (iconv_t)(-1))
+    return wcrtomb_iconv (s, wc, charset_from_utf8);
+  else
+  {
+    if (!s)
+      return 1;
+    if (wc < 0x100)
+    {
+      *s = wc;
+      return 1;
+    }
+    errno = EILSEQ;
+    return (size_t)(-1);
+  }
+}
+
+size_t mbrtowc_iconv (wchar_t *pwc, const char *s, size_t n,
+                      mbstate_t *ps, iconv_t cd)
+{
+  static mbstate_t mbstate;
+  ICONV_CONST char *ib, *ibmax;
+  char *ob, *t;
+  size_t ibl, obl, k, r;
+  char bufi[8], bufo[6];
+
+  if (!n)
+    return (size_t)(-2);
+
+  t = memchr (ps, 0, sizeof (*ps));
+  k = t ? (t - (char *)ps) : sizeof (*ps);
+  if (k > sizeof (bufi))
+    k = 0;
+  if (k)
+  {
+    /* use the buffer for input */
+    memcpy (bufi, ps, k);
+    ib = bufi;
+    ibmax = bufi + (k + n < sizeof (bufi) ? k + n : sizeof (bufi));
+    memcpy (bufi + k, s, ibmax - bufi - k);
+  }
+  else
+  {
+    /* use the real input */
+    ib = (ICONV_CONST char*) s;
+    ibmax = (ICONV_CONST char*) s + n;
+  }
+
+  ob = bufo;
+  obl = sizeof (bufo);
+  ibl = 1;
+
+  for (;;)
+  {
+    r = iconv (cd, &ib, &ibl, &ob, &obl);
+    if (ob > bufo && (!k || ib > bufi + k))
+    {
+      /* we have a character */
+      memset (ps, 0, sizeof (*ps));
+      utf8rtowc (pwc, bufo, ob - bufo, &mbstate);
+      return (pwc && *pwc) ? (ib - (k ? bufi + k : s)) : 0;
+    }
+    else if (!r || (r == (size_t)(-1) && errno == EINVAL))
+    {
+      if (ib + ibl < ibmax)
+        /* try using more input */
+        ++ibl;
+      else if (k && ib > bufi + k && bufi + k + n > ibmax)
+      {
+        /* switch to using real input */
+        ib = (ICONV_CONST char*) s + (ib - bufi - k);
+        ibmax = (ICONV_CONST char*) s + n;
+        k = 0;
+        ++ibl;
+      }
+      else
+      {
+        /* save the state and give up */
+        memset (ps, 0, sizeof (*ps));
+        if (ibl <= sizeof (mbstate_t)) /* need extra condition here! */
+          memcpy (ps, ib, ibl);
+        return (size_t)(-2);
+      }
+    }
+    else
+    {
+      /* bad input */
+      errno = EILSEQ;
+      return (size_t)(-1);
+    }
+  }
+}
+
+size_t mbrtowc (wchar_t *pwc, const char *s, size_t n, mbstate_t *ps)
+{
+  static mbstate_t mbstate;
+
+  if (!ps)
+    ps = &mbstate;
+
+  if (Charset_is_utf8)
+    return utf8rtowc (pwc, s, n, ps);
+  else if (charset_to_utf8 != (iconv_t)(-1))
+    return mbrtowc_iconv (pwc, s, n, ps, charset_to_utf8);
+  else
+  {
+    if (!s)
+    {
+      memset(ps, 0, sizeof(*ps));
+      return 0;
+    }
+    if (!n)
+      return (size_t)-2;
+    if (pwc)
+      *pwc = (wchar_t)(unsigned char)*s;
+    return (*s != 0);
+  }
+}
+
+int iswprint (wint_t wc)
+{
+  if (Charset_is_utf8 || charset_is_ja)
+    return ((0x20 <= wc && wc < 0x7f) || 0xa0 <= wc);
+  else
+    return (0 <= wc && wc < 256) ? IsPrint (wc) : 0;
+}
+
+int iswspace (wint_t wc)
+{
+  if (Charset_is_utf8 || charset_is_ja)
+    return IS_ASCII_WS (wc);
+  else
+    return (0 <= wc && wc < 256) ? isspace (wc) : 0;  /* __SAFE_ISSPACE_CHECKED__ */
+}
+
+int iswblank (wint_t wc)
+{
+  if (Charset_is_utf8 || charset_is_ja)
+    return wc == 9 || wc == 32;
+  else
+    return (0 <= wc && wc < 256) ? isblank (wc) : 0;
+}
+
+static wint_t towupper_ucs (wint_t x)
+{
+  /* Only works for x < 0x130 */
+  if ((0x60 < x && x < 0x7b) || (0xe0 <= x && x < 0xff && x != 0xf7))
+    return x - 32;
+  else if (0x100 <= x && x < 0x130)
+    return x & ~1;
+  else if (x == 0xb5)
+    return 0x39c;
+  else if (x == 0xff)
+    return 0x178;
+  else
+    return x;
+}
+
+static int iswupper_ucs (wint_t x)
+{
+  /* Only works for x < 0x130 */
+  if ((0x60 < x && x < 0x7b) || (0xe0 <= x && x < 0xff && x != 0xf7))
+    return 0;
+  else if ((0x40 < x && x < 0x5b) || (0xbf < x && x < 0xde))
+    return 1;
+  else if (0x100 <= x && x < 0x130)
+    return 1;
+  else if (x == 0xb5)
+    return 1;
+  else if (x == 0xff)
+    return 0;
+  else
+    return 0;
+}
+
+static wint_t towlower_ucs (wint_t x)
+{
+  /* Only works for x < 0x130 */
+  if ((0x40 < x && x < 0x5b) || (0xc0 <= x && x < 0xdf && x != 0xd7))
+    return x + 32;
+  else if (0x100 <= x && x < 0x130)
+    return x | 1;
+  else
+    return x;
+}
+
+static int iswalnum_ucs (wint_t wc)
+{
+  /* Only works for x < 0x220 */
+  if (wc >= 0x100)
+    return 1;
+  else if (wc < 0x30)
+    return 0;
+  else if (wc < 0x3a)
+    return 1;
+  else if (wc < 0xa0)
+    return (0x40 < (wc & ~0x20) && (wc & ~0x20) < 0x5b);
+  else if (wc < 0xc0)
+    return (wc == 0xaa || wc == 0xb5 || wc == 0xba);
+  else
+    return !(wc == 0xd7 || wc == 0xf7);
+}
+
+static int iswalpha_ucs (wint_t wc)
+{
+  /* Only works for x < 0x220 */
+  if (wc >= 0x100)
+    return 1;
+  else if (wc < 0x3a)
+    return 0;
+  else if (wc < 0xa0)
+    return (0x40 < (wc & ~0x20) && (wc & ~0x20) < 0x5b);
+  else if (wc < 0xc0)
+    return (wc == 0xaa || wc == 0xb5 || wc == 0xba);
+  else
+    return !(wc == 0xd7 || wc == 0xf7);
+}
+
+wint_t towupper (wint_t wc)
+{
+  if (Charset_is_utf8 || charset_is_ja)
+    return towupper_ucs (wc);
+  else
+    return (0 <= wc && wc < 256) ? toupper (wc) : wc;
+}
+
+wint_t towlower (wint_t wc)
+{
+  if (Charset_is_utf8 || charset_is_ja)
+    return towlower_ucs (wc);
+  else
+    return (0 <= wc && wc < 256) ? tolower (wc) : wc;
+}
+
+int iswalnum (wint_t wc)
+{
+  if (Charset_is_utf8 || charset_is_ja)
+    return iswalnum_ucs (wc);
+  else
+    return (0 <= wc && wc < 256) ? isalnum (wc) : 0;
+}
+
+int iswalpha (wint_t wc)
+{
+  if (Charset_is_utf8 || charset_is_ja)
+    return iswalpha_ucs (wc);
+  else
+    return (0 <= wc && wc < 256) ? isalpha (wc) : 0;
+}
+
+int iswupper (wint_t wc)
+{
+  if (Charset_is_utf8 || charset_is_ja)
+    return iswupper_ucs (wc);
+  else
+    return (0 <= wc && wc < 256) ? isupper (wc) : 0;
+}
+#endif
+
 #ifndef HAVE_WCWIDTH
+#ifndef NO_USE_MKWCWIDTH
 /*
  * l10n for Japanese:
  *   Symbols, Greek and Cyrillic in JIS X 0208, Japanese Kanji
@@ -86,11 +408,20 @@ static int wcwidth_ja(wchar_t ucs)
   else
     return -1;
 }
+#endif
 
 int wcwidth_ucs(wchar_t ucs);
 
 int wcwidth(wchar_t wc)
 {
+#ifndef NO_USE_MKWCWIDTH
+  if (option(OPTUTF8CJKEMOJI))
+    return mk_wcwidth_cjk_emoji(wc);
+  else if (option(OPTUTF8CJK))
+    return mk_wcwidth_cjk(wc);
+  else
+    return mk_wcwidth(wc);
+#else
   if (!Charset_is_utf8)
   {
     if (!charset_is_ja)
@@ -112,6 +443,7 @@ int wcwidth(wchar_t wc)
     }
   }
   return wcwidth_ucs(wc);
+#endif
 }
 #endif /* !HAVE_WCWIDTH */
 
diff --git a/mbyte.h b/mbyte.h
index 9822d573..8b6babef 100644
--- a/mbyte.h
+++ b/mbyte.h
@@ -9,5 +9,8 @@ void mutt_set_charset(char *charset);
 extern int Charset_is_utf8;
 wchar_t replacement_char(void);
 int is_display_corrupting_utf8(wchar_t wc);
+#ifndef NO_USE_MKWCWIDTH
+extern int mutt_wcwidth(wchar_t wc);
+#endif
 
 #endif /* _MBYTE_H */
diff --git a/mutt.h b/mutt.h
index 262c7e54..af1ea025 100644
--- a/mutt.h
+++ b/mutt.h
@@ -610,6 +610,12 @@ enum
   OPTPGPSHOWUNUSABLE,
   OPTPGPAUTOINLINE,
   OPTPGPREPLYINLINE,
+#ifndef NO_USE_MKWCWIDTH
+  OPTUTF8CJK,
+#ifndef NO_USE_UTF8CJK_EMOJI
+  OPTUTF8CJKEMOJI,
+#endif
+#endif
 
   /* pseudo options */
 
diff --git a/pager.c b/pager.c
index fcadf26e..1855b33b 100644
--- a/pager.c
+++ b/pager.c
@@ -1440,7 +1440,11 @@ static int format_line(struct line_t **lineInfo, int n, unsigned char *buf,
     {
       if (wc == ' ')
         space = ch;
+#ifndef NO_USE_MKWCWIDTH
+      t = mutt_wcwidth(wc);
+#else
       t = wcwidth(wc);
+#endif
       if (col + t > wrap_cols)
         break;
       col += t;
diff --git a/sendlib.c b/sendlib.c
index 22061753..4f499c7d 100644
--- a/sendlib.c
+++ b/sendlib.c
@@ -1963,7 +1963,11 @@ static int my_width(const char *p, int col, int flags)
       consumed = (consumed == (size_t)(-1)) ? 1 : n;
     }
 
+#ifndef NO_USE_MKWCWIDTH
+    l = mutt_wcwidth(wc);
+#else
     l = wcwidth(wc);
+#endif
     if (l < 0)
       l = 1;
     /* correctly calc tab stop, even for sending as the
diff --git a/wcwidth.c b/wcwidth.c
index a8167992..176a8d31 100644
--- a/wcwidth.c
+++ b/wcwidth.c
@@ -184,3 +184,338 @@ int wcswidth(const wchar_t *pwcs, size_t n)
   return width;
 }
 #endif
+
+#ifndef NO_USE_MKWCWIDTH
+/*
+ * Use original mk_wcswidth(), mk_wcswidth_cjk(), mk_wcswidth_cjk_emoji(), etc.
+ */
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
+/* The following function returns 1 if wide charactor code ucs is
+ * The following functions are the same as mk_wcwidth_cjk() and
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
+
+int mk_wcswidth_cjk_emoji(const wchar_t *pwcs, size_t n)
+{
+  int w, width = 0;
+
+  for (;*pwcs && n-- > 0; pwcs++)
+    if ((w = mk_wcwidth_cjk_emoji(*pwcs)) < 0)
+      return -1;
+    else
+      width += w;
+
+  return width;
+}
+#endif
