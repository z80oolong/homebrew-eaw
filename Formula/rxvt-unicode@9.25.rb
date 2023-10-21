class RxvtUnicodeAT925 < Formula
  desc "Rxvt fork with Unicode support"
  homepage "http://software.schmorp.de/pkg/rxvt-unicode.html"
  url "http://dist.schmorp.de/rxvt-unicode/Attic/rxvt-unicode-9.25.tar.bz2"
  sha256 "0c79c6c0056d51528ac8f96916794959b7fe0a0f785795f2130e2e8b99e12146"
  license "GPL-3.0-only"
  revision 3 

  keg_only :versioned_formula

  livecheck do
    url "http://dist.schmorp.de/rxvt-unicode/"
    regex(/href=.*?rxvt-unicode[._-]v?(\d+(?:\.\d+)+)\.t/i)
  end

  depends_on "pkg-config" => :build
  depends_on "gdk-pixbuf"
  depends_on "fontconfig"
  depends_on "freetype"
  depends_on "libx11"
  depends_on "libxft"
  depends_on "libxmu"
  depends_on "libxrender"
  depends_on "libxt"
  depends_on "startup-notification"
  depends_on "z80oolong/eaw/ncurses-eaw@6.2"

  uses_from_macos "perl"

  patch :p1, :DATA 

  def install
    args = %W[
      --prefix=#{prefix}
      --enable-256-color
      --with-term=xterm-256color
      --with-terminfo=#{Formula["z80oolong/eaw/ncurses-eaw@6.2"].opt_share}/terminfo
      --enable-smart-resize
      --enable-unicode3
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
    daemon = fork do
      system bin/"urxvtd"
    end
    sleep 2
    system bin/"urxvtc", "-k"
    Process.wait daemon
  end
end

__END__
diff --git a/Makefile.in b/Makefile.in
index eee5969..c230930 100644
--- a/Makefile.in
+++ b/Makefile.in
@@ -31,6 +31,7 @@ subdirs = src doc
 
 RECURSIVE_TARGETS = all allbin alldoc tags clean distclean realclean install
 
+.PHONY: install
 #-------------------------------------------------------------------------
 
 $(RECURSIVE_TARGETS):
diff --git a/configure b/configure
index d610e73..1639856 100755
--- a/configure
+++ b/configure
@@ -8705,8 +8705,8 @@ printf %s "checking for $PERL suitability... " >&6; }
 
      save_CXXFLAGS="$CXXFLAGS"
      save_LIBS="$LIBS"
-     CXXFLAGS="$CXXFLAGS `$PERL -MExtUtils::Embed -e ccopts`"
-     LIBS="$LIBS `$PERL -MExtUtils::Embed -e ldopts`"
+     CXXFLAGS="$CXXFLAGS `$PERL -MExtUtils::Embed -e ccopts|sed -E 's/ -arch [^ ]+//g'`"
+     LIBS="$LIBS `$PERL -MExtUtils::Embed -e ldopts|sed -E 's/ -arch [^ ]+//g'`"
      cat confdefs.h - <<_ACEOF >conftest.$ac_ext
 /* end confdefs.h.  */
 
@@ -8743,8 +8743,8 @@ printf "%s\n" "#define ENABLE_PERL 1" >>confdefs.h
 
         IF_PERL=
         PERL_O=rxvtperl.o
-        PERLFLAGS="`$PERL -MExtUtils::Embed -e ccopts`"
-        PERLLIB="`$PERL -MExtUtils::Embed -e ldopts`"
+        PERLFLAGS="`$PERL -MExtUtils::Embed -e ccopts|sed -E 's/ -arch [^ ]+//g'`"
+        PERLLIB="`$PERL -MExtUtils::Embed -e ldopts|sed -E 's/ -arch [^ ]+//g'`"
         PERLPRIVLIBEXP="`$PERL -MConfig -e 'print $Config{privlibexp}'`"
      else
         as_fn_error $? "no, unable to link" "$LINENO" 5
diff --git a/libev/ev_iouring.c b/libev/ev_iouring.c
new file mode 100644
index 0000000..a0e3beb
--- /dev/null
+++ b/libev/ev_iouring.c
@@ -0,0 +1,712 @@
+/*
+ * libev linux io_uring fd activity backend
+ *
+ * Copyright (c) 2019-2020 Marc Alexander Lehmann <libev@schmorp.de>
+ * All rights reserved.
+ *
+ * Redistribution and use in source and binary forms, with or without modifica-
+ * tion, are permitted provided that the following conditions are met:
+ *
+ *   1.  Redistributions of source code must retain the above copyright notice,
+ *       this list of conditions and the following disclaimer.
+ *
+ *   2.  Redistributions in binary form must reproduce the above copyright
+ *       notice, this list of conditions and the following disclaimer in the
+ *       documentation and/or other materials provided with the distribution.
+ *
+ * THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR IMPLIED
+ * WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MER-
+ * CHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO
+ * EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPE-
+ * CIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
+ * PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
+ * OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
+ * WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTH-
+ * ERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED
+ * OF THE POSSIBILITY OF SUCH DAMAGE.
+ *
+ * Alternatively, the contents of this file may be used under the terms of
+ * the GNU General Public License ("GPL") version 2 or any later version,
+ * in which case the provisions of the GPL are applicable instead of
+ * the above. If you wish to allow the use of your version of this file
+ * only under the terms of the GPL and not to allow others to use your
+ * version of this file under the BSD license, indicate your decision
+ * by deleting the provisions above and replace them with the notice
+ * and other provisions required by the GPL. If you do not delete the
+ * provisions above, a recipient may use your version of this file under
+ * either the BSD or the GPL.
+ */
+
+/*
+ * general notes about linux io_uring:
+ *
+ * a) it's the best interface I have seen so far. on linux.
+ * b) best is not necessarily very good.
+ * c) it's better than the aio mess, doesn't suffer from the fork problems
+ *    of linux aio or epoll and so on and so on. and you could do event stuff
+ *    without any syscalls. what's not to like?
+ * d) ok, it's vastly more complex, but that's ok, really.
+ * e) why two mmaps instead of one? one would be more space-efficient,
+ *    and I can't see what benefit two would have (other than being
+ *    somehow resizable/relocatable, but that's apparently not possible).
+ * f) hmm, it's practically undebuggable (gdb can't access the memory, and
+ *    the bizarre way structure offsets are communicated makes it hard to
+ *    just print the ring buffer heads, even *iff* the memory were visible
+ *    in gdb. but then, that's also ok, really.
+ * g) well, you cannot specify a timeout when waiting for events. no,
+ *    seriously, the interface doesn't support a timeout. never seen _that_
+ *    before. sure, you can use a timerfd, but that's another syscall
+ *    you could have avoided. overall, this bizarre omission smells
+ *    like a µ-optimisation by the io_uring author for his personal
+ *    applications, to the detriment of everybody else who just wants
+ *    an event loop. but, umm, ok, if that's all, it could be worse.
+ *    (from what I gather from the author Jens Axboe, it simply didn't
+ *    occur to him, and he made good on it by adding an unlimited number
+ *    of timeouts later :).
+ * h) initially there was a hardcoded limit of 4096 outstanding events.
+ *    later versions not only bump this to 32k, but also can handle
+ *    an unlimited amount of events, so this only affects the batch size.
+ * i) unlike linux aio, you *can* register more then the limit
+ *    of fd events. while early verisons of io_uring signalled an overflow
+ *    and you ended up getting wet. 5.5+ does not do this anymore.
+ * j) but, oh my! it had exactly the same bugs as the linux aio backend,
+ *    where some undocumented poll combinations just fail. fortunately,
+ *    after finally reaching the author, he was more than willing to fix
+ *    this probably in 5.6+.
+ * k) overall, the *API* itself is, I dare to say, not a total trainwreck.
+ *    once the bugs ae fixed (probably in 5.6+), it will be without
+ *    competition.
+ */
+
+/* TODO: use internal TIMEOUT */
+/* TODO: take advantage of single mmap, NODROP etc. */
+/* TODO: resize cq/sq size independently */
+
+#include <sys/timerfd.h>
+#include <sys/mman.h>
+#include <poll.h>
+#include <stdint.h>
+
+#define IOURING_INIT_ENTRIES 32
+
+/*****************************************************************************/
+/* syscall wrapdadoop - this section has the raw api/abi definitions */
+
+#include <linux/fs.h>
+#include <linux/types.h>
+
+/* mostly directly taken from the kernel or documentation */
+
+struct io_uring_sqe
+{
+  __u8 opcode;
+  __u8 flags;
+  __u16 ioprio;
+  __s32 fd;
+  union {
+    __u64 off;
+    __u64 addr2;
+  };
+  __u64 addr;
+  __u32 len;
+  union {
+    __kernel_rwf_t rw_flags;
+    __u32 fsync_flags;
+    __u16 poll_events;
+    __u32 sync_range_flags;
+    __u32 msg_flags;
+    __u32 timeout_flags;
+    __u32 accept_flags;
+    __u32 cancel_flags;
+    __u32 open_flags;
+    __u32 statx_flags;
+    __u32 fadvise_advice;
+  };
+  __u64 user_data;
+  union {
+    __u16 buf_index;
+    __u16 personality;
+    __u64 __pad2[3];
+  };
+};
+
+struct io_uring_cqe
+{
+  __u64 user_data;
+  __s32 res;
+  __u32 flags;
+};
+
+struct io_sqring_offsets
+{
+  __u32 head;
+  __u32 tail;
+  __u32 ring_mask;
+  __u32 ring_entries;
+  __u32 flags;
+  __u32 dropped;
+  __u32 array;
+  __u32 resv1;
+  __u64 resv2;
+};
+
+struct io_cqring_offsets
+{
+  __u32 head;
+  __u32 tail;
+  __u32 ring_mask;
+  __u32 ring_entries;
+  __u32 overflow;
+  __u32 cqes;
+  __u64 resv[2];
+};
+
+struct io_uring_params
+{
+  __u32 sq_entries;
+  __u32 cq_entries;
+  __u32 flags;
+  __u32 sq_thread_cpu;
+  __u32 sq_thread_idle;
+  __u32 features;
+  __u32 resv[4];
+  struct io_sqring_offsets sq_off;
+  struct io_cqring_offsets cq_off;
+};
+
+#define IORING_FEAT_SINGLE_MMAP   0x00000001
+#define IORING_FEAT_NODROP        0x00000002
+#define IORING_FEAT_SUBMIT_STABLE 0x00000004
+
+#define IORING_SETUP_CQSIZE 0x00000008
+#define IORING_SETUP_CLAMP  0x00000010
+
+#define IORING_OP_POLL_ADD        6
+#define IORING_OP_POLL_REMOVE     7
+#define IORING_OP_TIMEOUT        11
+#define IORING_OP_TIMEOUT_REMOVE 12
+
+#define IORING_REGISTER_EVENTFD       4
+#define IORING_REGISTER_EVENTFD_ASYNC 7
+#define IORING_REGISTER_PROBE         8
+
+#define IO_URING_OP_SUPPORTED 1
+
+struct io_uring_probe_op {
+  __u8  op;
+  __u8  resv;
+  __u16 flags;
+  __u32 resv2;
+};
+
+struct io_uring_probe
+{
+  __u8  last_op;
+  __u8  ops_len;
+  __u16 resv;
+  __u32 resv2[3];
+  struct io_uring_probe_op ops[0];
+};
+
+/* relative or absolute, reference clock is CLOCK_MONOTONIC */
+struct iouring_kernel_timespec
+{
+  int64_t tv_sec;
+  long long tv_nsec;
+};
+
+#define IORING_TIMEOUT_ABS 0x00000001
+
+#define IORING_ENTER_GETEVENTS 0x01
+
+#define IORING_OFF_SQ_RING 0x00000000ULL
+#define IORING_OFF_SQES	   0x10000000ULL
+
+#define IORING_FEAT_SINGLE_MMAP   0x00000001
+#define IORING_FEAT_NODROP        0x00000002
+#define IORING_FEAT_SUBMIT_STABLE 0x00000004
+
+inline_size
+int
+evsys_io_uring_setup (unsigned entries, struct io_uring_params *params)
+{
+  return ev_syscall2 (SYS_io_uring_setup, entries, params);
+}
+
+inline_size
+int
+evsys_io_uring_enter (int fd, unsigned to_submit, unsigned min_complete, unsigned flags, const sigset_t *sig, size_t sigsz)
+{
+  return ev_syscall6 (SYS_io_uring_enter, fd, to_submit, min_complete, flags, sig, sigsz);
+}
+
+inline_size
+int
+evsys_io_uring_register (unsigned int fd, unsigned int opcode, void *arg, unsigned int nr_args)
+{
+  return ev_syscall4 (SYS_io_uring_register, fd, opcode, arg, nr_args);
+}
+
+/*****************************************************************************/
+/* actual backend implementation */
+
+/* we hope that volatile will make the compiler access this variables only once */
+#define EV_SQ_VAR(name) *(volatile unsigned *)((char *)iouring_ring + iouring_sq_ ## name)
+#define EV_CQ_VAR(name) *(volatile unsigned *)((char *)iouring_ring + iouring_cq_ ## name)
+
+/* the index array */
+#define EV_SQ_ARRAY     ((unsigned *)((char *)iouring_ring + iouring_sq_array))
+
+/* the submit/completion queue entries */
+#define EV_SQES         ((struct io_uring_sqe *)         iouring_sqes)
+#define EV_CQES         ((struct io_uring_cqe *)((char *)iouring_ring + iouring_cq_cqes))
+
+inline_speed
+int
+iouring_enter (EV_P_ ev_tstamp timeout)
+{
+  int res;
+
+  EV_RELEASE_CB;
+
+  res = evsys_io_uring_enter (iouring_fd, iouring_to_submit, 1,
+                              timeout > EV_TS_CONST (0.) ? IORING_ENTER_GETEVENTS : 0, 0, 0);
+
+  assert (("libev: io_uring_enter did not consume all sqes", (res < 0 || res == iouring_to_submit)));
+
+  iouring_to_submit = 0;
+
+  EV_ACQUIRE_CB;
+
+  return res;
+}
+
+/* TODO: can we move things around so we don't need this forward-reference? */
+static void
+iouring_poll (EV_P_ ev_tstamp timeout);
+
+static
+struct io_uring_sqe *
+iouring_sqe_get (EV_P)
+{
+  unsigned tail;
+  
+  for (;;)
+    {
+      tail = EV_SQ_VAR (tail);
+
+      if (ecb_expect_true (tail + 1 - EV_SQ_VAR (head) <= EV_SQ_VAR (ring_entries)))
+        break; /* whats the problem, we have free sqes */
+
+      /* queue full, need to flush and possibly handle some events */
+
+#if EV_FEATURE_CODE
+      /* first we ask the kernel nicely, most often this frees up some sqes */
+      int res = iouring_enter (EV_A_ EV_TS_CONST (0.));
+
+      ECB_MEMORY_FENCE_ACQUIRE; /* better safe than sorry */
+
+      if (res >= 0)
+        continue; /* yes, it worked, try again */
+#endif
+
+      /* some problem, possibly EBUSY - do the full poll and let it handle any issues */
+
+      iouring_poll (EV_A_ EV_TS_CONST (0.));
+      /* iouring_poll should have done ECB_MEMORY_FENCE_ACQUIRE for us */
+    }
+
+  /*assert (("libev: io_uring queue full after flush", tail + 1 - EV_SQ_VAR (head) <= EV_SQ_VAR (ring_entries)));*/
+
+  return EV_SQES + (tail & EV_SQ_VAR (ring_mask));
+}
+
+inline_size
+struct io_uring_sqe *
+iouring_sqe_submit (EV_P_ struct io_uring_sqe *sqe)
+{
+  unsigned idx = sqe - EV_SQES;
+
+  EV_SQ_ARRAY [idx] = idx;
+  ECB_MEMORY_FENCE_RELEASE;
+  ++EV_SQ_VAR (tail);
+  /*ECB_MEMORY_FENCE_RELEASE; /* for the time being we assume this is not needed */
+  ++iouring_to_submit;
+}
+
+/*****************************************************************************/
+
+/* when the timerfd expires we simply note the fact,
+ * as the purpose of the timerfd is to wake us up, nothing else.
+ * the next iteration should re-set it.
+ */
+static void
+iouring_tfd_cb (EV_P_ struct ev_io *w, int revents)
+{
+  iouring_tfd_to = EV_TSTAMP_HUGE;
+}
+
+/* called for full and partial cleanup */
+ecb_cold
+static int
+iouring_internal_destroy (EV_P)
+{
+  close (iouring_tfd);
+  close (iouring_fd);
+
+  if (iouring_ring != MAP_FAILED) munmap (iouring_ring, iouring_ring_size);
+  if (iouring_sqes != MAP_FAILED) munmap (iouring_sqes, iouring_sqes_size);
+
+  if (ev_is_active (&iouring_tfd_w))
+    {
+      ev_ref (EV_A);
+      ev_io_stop (EV_A_ &iouring_tfd_w);
+    }
+}
+
+ecb_cold
+static int
+iouring_internal_init (EV_P)
+{
+  struct io_uring_params params = { 0 };
+  uint32_t sq_size, cq_size;
+
+  params.flags = IORING_SETUP_CLAMP;
+
+  iouring_to_submit = 0;
+
+  iouring_tfd  = -1;
+  iouring_ring = MAP_FAILED;
+  iouring_sqes = MAP_FAILED;
+
+  if (!have_monotonic) /* cannot really happen, but what if11 */
+    return -1;
+
+  iouring_fd = evsys_io_uring_setup (iouring_entries, &params);
+
+  if (iouring_fd < 0)
+    return -1;
+
+  if ((~params.features) & (IORING_FEAT_NODROP | IORING_FEAT_SINGLE_MMAP | IORING_FEAT_SUBMIT_STABLE))
+    return -1; /* we require the above features */
+
+  /* TODO: remember somehow whether our queue size has been clamped */
+
+  sq_size = params.sq_off.array + params.sq_entries * sizeof (unsigned);
+  cq_size = params.cq_off.cqes  + params.cq_entries * sizeof (struct io_uring_cqe);
+
+  iouring_ring_size = sq_size > cq_size ? sq_size : cq_size;
+  iouring_sqes_size = params.sq_entries * sizeof (struct io_uring_sqe);
+
+  iouring_ring = mmap (0, iouring_ring_size, PROT_READ | PROT_WRITE,
+                       MAP_SHARED | MAP_POPULATE, iouring_fd, IORING_OFF_SQ_RING);
+  iouring_sqes = mmap (0, iouring_sqes_size, PROT_READ | PROT_WRITE,
+                       MAP_SHARED | MAP_POPULATE, iouring_fd, IORING_OFF_SQES);
+
+  if (iouring_ring == MAP_FAILED || iouring_sqes == MAP_FAILED)
+    return -1;
+
+  iouring_sq_head         = params.sq_off.head;
+  iouring_sq_tail         = params.sq_off.tail;
+  iouring_sq_ring_mask    = params.sq_off.ring_mask;
+  iouring_sq_ring_entries = params.sq_off.ring_entries;
+  iouring_sq_flags        = params.sq_off.flags;
+  iouring_sq_dropped      = params.sq_off.dropped;
+  iouring_sq_array        = params.sq_off.array;
+
+  iouring_cq_head         = params.cq_off.head;
+  iouring_cq_tail         = params.cq_off.tail;
+  iouring_cq_ring_mask    = params.cq_off.ring_mask;
+  iouring_cq_ring_entries = params.cq_off.ring_entries;
+  iouring_cq_overflow     = params.cq_off.overflow;
+  iouring_cq_cqes         = params.cq_off.cqes;
+
+  iouring_tfd_to = EV_TSTAMP_HUGE;
+
+  iouring_tfd = timerfd_create (CLOCK_MONOTONIC, TFD_CLOEXEC);
+
+  if (iouring_tfd < 0)
+    return -1;
+
+  return 0;
+}
+
+ecb_cold
+static void
+iouring_fork (EV_P)
+{
+  iouring_internal_destroy (EV_A);
+
+  while (iouring_internal_init (EV_A) < 0)
+    ev_syserr ("(libev) io_uring_setup");
+
+  fd_rearm_all (EV_A);
+
+  ev_io_stop  (EV_A_ &iouring_tfd_w);
+  ev_io_set   (EV_A_ &iouring_tfd_w, iouring_tfd, EV_READ);
+  ev_io_start (EV_A_ &iouring_tfd_w);
+}
+
+/*****************************************************************************/
+
+static void
+iouring_modify (EV_P_ int fd, int oev, int nev)
+{
+  if (oev)
+    {
+      /* we assume the sqe's are all "properly" initialised */
+      struct io_uring_sqe *sqe = iouring_sqe_get (EV_A);
+      sqe->opcode    = IORING_OP_POLL_REMOVE;
+      sqe->fd        = fd;
+      /* Jens Axboe notified me that user_data is not what is documented, but is
+       * some kind of unique ID that has to match, otherwise the request cannot
+       * be removed. Since we don't *really* have that, we pass in the old
+       * generation counter - if that fails, too bad, it will hopefully be removed
+       * at close time and then be ignored. */
+      sqe->addr      = (uint32_t)fd | ((__u64)(uint32_t)anfds [fd].egen << 32);
+      sqe->user_data = (uint64_t)-1;
+      iouring_sqe_submit (EV_A_ sqe);
+
+      /* increment generation counter to avoid handling old events */
+      ++anfds [fd].egen;
+    }
+
+  if (nev)
+    {
+      struct io_uring_sqe *sqe = iouring_sqe_get (EV_A);
+      sqe->opcode      = IORING_OP_POLL_ADD;
+      sqe->fd          = fd;
+      sqe->addr        = 0;
+      sqe->user_data   = (uint32_t)fd | ((__u64)(uint32_t)anfds [fd].egen << 32);
+      sqe->poll_events =
+        (nev & EV_READ ? POLLIN : 0)
+        | (nev & EV_WRITE ? POLLOUT : 0);
+      iouring_sqe_submit (EV_A_ sqe);
+    }
+}
+
+inline_size
+void
+iouring_tfd_update (EV_P_ ev_tstamp timeout)
+{
+  ev_tstamp tfd_to = mn_now + timeout;
+
+  /* we assume there will be many iterations per timer change, so
+   * we only re-set the timerfd when we have to because its expiry
+   * is too late.
+   */
+  if (ecb_expect_false (tfd_to < iouring_tfd_to))
+    {
+       struct itimerspec its;
+
+       iouring_tfd_to = tfd_to;
+       EV_TS_SET (its.it_interval, 0.);
+       EV_TS_SET (its.it_value, tfd_to);
+
+       if (timerfd_settime (iouring_tfd, TFD_TIMER_ABSTIME, &its, 0) < 0)
+         assert (("libev: iouring timerfd_settime failed", 0));
+    }
+}
+
+inline_size
+void
+iouring_process_cqe (EV_P_ struct io_uring_cqe *cqe)
+{
+  int      fd  = cqe->user_data & 0xffffffffU;
+  uint32_t gen = cqe->user_data >> 32;
+  int      res = cqe->res;
+
+  /* user_data -1 is a remove that we are not atm. interested in */
+  if (cqe->user_data == (uint64_t)-1)
+    return;
+
+  assert (("libev: io_uring fd must be in-bounds", fd >= 0 && fd < anfdmax));
+
+  /* documentation lies, of course. the result value is NOT like
+   * normal syscalls, but like linux raw syscalls, i.e. negative
+   * error numbers. fortunate, as otherwise there would be no way
+   * to get error codes at all. still, why not document this?
+   */
+
+  /* ignore event if generation doesn't match */
+  /* other than skipping removal events, */
+  /* this should actually be very rare */
+  if (ecb_expect_false (gen != (uint32_t)anfds [fd].egen))
+    return;
+
+  if (ecb_expect_false (res < 0))
+    {
+      /*TODO: EINVAL handling (was something failed with this fd)*/
+
+      if (res == -EBADF)
+        {
+          assert (("libev: event loop rejected bad fd", res != -EBADF));
+          fd_kill (EV_A_ fd);
+        }
+      else
+        {
+          errno = -res;
+          ev_syserr ("(libev) IORING_OP_POLL_ADD");
+        }
+
+      return;
+    }
+
+  /* feed events, we do not expect or handle POLLNVAL */
+  fd_event (
+    EV_A_
+    fd,
+    (res & (POLLOUT | POLLERR | POLLHUP) ? EV_WRITE : 0)
+    | (res & (POLLIN | POLLERR | POLLHUP) ? EV_READ : 0)
+  );
+
+  /* io_uring is oneshot, so we need to re-arm the fd next iteration */
+  /* this also means we usually have to do at least one syscall per iteration */
+  anfds [fd].events = 0;
+  fd_change (EV_A_ fd, EV_ANFD_REIFY);
+}
+
+/* called when the event queue overflows */
+ecb_cold
+static void
+iouring_overflow (EV_P)
+{
+  /* we have two options, resize the queue (by tearing down
+   * everything and recreating it, or living with it
+   * and polling.
+   * we implement this by resizing the queue, and, if that fails,
+   * we just recreate the state on every failure, which
+   * kind of is a very inefficient poll.
+   * one danger is, due to the bios toward lower fds,
+   * we will only really get events for those, so
+   * maybe we need a poll() fallback, after all.
+   */
+  /*EV_CQ_VAR (overflow) = 0;*/ /* need to do this if we keep the state and poll manually */
+
+  fd_rearm_all (EV_A);
+
+  /* we double the size until we hit the hard-to-probe maximum */
+  if (!iouring_max_entries)
+    {
+      iouring_entries <<= 1;
+      iouring_fork (EV_A);
+    }
+  else
+    {
+      /* we hit the kernel limit, we should fall back to something else.
+       * we can either poll() a few times and hope for the best,
+       * poll always, or switch to epoll.
+       * TODO: is this necessary with newer kernels?
+       */
+
+      iouring_internal_destroy (EV_A);
+
+      /* this should make it so that on return, we don't call any uring functions */
+      iouring_to_submit = 0;
+
+      for (;;)
+        {
+          backend = epoll_init (EV_A_ 0);
+
+          if (backend)
+            break;
+
+          ev_syserr ("(libev) iouring switch to epoll");
+        }
+    }
+}
+
+/* handle any events in the completion queue, return true if there were any */
+static int
+iouring_handle_cq (EV_P)
+{
+  unsigned head, tail, mask;
+  
+  head = EV_CQ_VAR (head);
+  ECB_MEMORY_FENCE_ACQUIRE;
+  tail = EV_CQ_VAR (tail);
+
+  if (head == tail)
+    return 0;
+
+  /* it can only overflow if we have events, yes, yes? */
+  if (ecb_expect_false (EV_CQ_VAR (overflow)))
+    {
+      iouring_overflow (EV_A);
+      return 1;
+    }
+
+  mask = EV_CQ_VAR (ring_mask);
+
+  do
+    iouring_process_cqe (EV_A_ &EV_CQES [head++ & mask]);
+  while (head != tail);
+
+  EV_CQ_VAR (head) = head;
+  ECB_MEMORY_FENCE_RELEASE;
+
+  return 1;
+}
+
+static void
+iouring_poll (EV_P_ ev_tstamp timeout)
+{
+  /* if we have events, no need for extra syscalls, but we might have to queue events */
+  /* we also clar the timeout if there are outstanding fdchanges */
+  /* the latter should only happen if both the sq and cq are full, most likely */
+  /* because we have a lot of event sources that immediately complete */
+  /* TODO: fdchacngecnt is always 0 because fd_reify does not have two buffers yet */
+  if (iouring_handle_cq (EV_A) || fdchangecnt)
+    timeout = EV_TS_CONST (0.);
+  else
+    /* no events, so maybe wait for some */
+    iouring_tfd_update (EV_A_ timeout);
+
+  /* only enter the kernel if we have something to submit, or we need to wait */
+  if (timeout || iouring_to_submit)
+    {
+      int res = iouring_enter (EV_A_ timeout);
+
+      if (ecb_expect_false (res < 0))
+        if (errno == EINTR)
+          /* ignore */;
+        else if (errno == EBUSY)
+          /* cq full, cannot submit - should be rare because we flush the cq first, so simply ignore */;
+        else
+          ev_syserr ("(libev) iouring setup");
+      else
+        iouring_handle_cq (EV_A);
+    }
+}
+
+inline_size
+int
+iouring_init (EV_P_ int flags)
+{
+  iouring_entries     = IOURING_INIT_ENTRIES;
+  iouring_max_entries = 0;
+
+  if (iouring_internal_init (EV_A) < 0)
+    {
+      iouring_internal_destroy (EV_A);
+      return 0;
+    }
+
+  ev_io_init  (&iouring_tfd_w, iouring_tfd_cb, iouring_tfd, EV_READ);
+  ev_set_priority (&iouring_tfd_w, EV_MINPRI);
+  ev_io_start (EV_A_ &iouring_tfd_w);
+  ev_unref (EV_A); /* watcher should not keep loop alive */
+
+  backend_modify = iouring_modify;
+  backend_poll   = iouring_poll;
+
+  return EVBACKEND_IOURING;
+}
+
+inline_size
+void
+iouring_destroy (EV_P)
+{
+  iouring_internal_destroy (EV_A);
+}
+
diff --git a/src/Makefile.in b/src/Makefile.in
index 974101a..2f3ffe0 100644
--- a/src/Makefile.in
+++ b/src/Makefile.in
@@ -40,7 +40,7 @@ COMMON = \
 	screen.o scrollbar.o scrollbar-next.o scrollbar-rxvt.o \
 	scrollbar-xterm.o scrollbar-plain.o xdefaults.o encoding.o \
 	rxvttoolkit.o rxvtutil.o keyboard.o rxvtimg.o \
-	ev_cpp.o fdpass_wrapper.o ptytty_wrapper.o @PERL_O@
+	ev_cpp.o fdpass_wrapper.o ptytty_wrapper.o wcwidth.o @PERL_O@
 
 COMMON_DAEMON = rxvtdaemon.o
 
diff --git a/src/rxvt.h b/src/rxvt.h
index aa4caf7..11c31bd 100644
--- a/src/rxvt.h
+++ b/src/rxvt.h
@@ -645,7 +645,17 @@ typedef struct _mwmhints
 
 // for speed reasons, we assume that all codepoints 32 to 126 are
 // single-width.
+#ifndef NO_USE_UTF8_CJK
+extern int urxvt_wcwidth(wchar_t c);
+extern int urxvt_wcswidth(const wchar_t *s, size_t n);
+
+#define WCWIDTH(c)		(IN_RANGE_INC ((c), 0x20, 0x7e) ? 1 : urxvt_wcwidth ((c)))
+
+#define wcwidth(ucs)     urxvt_wcwidth((ucs))
+#define wcswidth(ucs, n) urxvt_wcswidth((ucs), (n))
+#else
 #define WCWIDTH(c)		(IN_RANGE_INC (c, 0x20, 0x7e) ? 1 : wcwidth (c))
+#endif /* NO_USE_UTF8_CJK */
 
 /* convert pixel dimensions to row/column values.  Everything as int32_t */
 #define Pixel2Col(x)            Pixel2Width((int32_t)(x))
diff --git a/src/wcwidth.C b/src/wcwidth.C
new file mode 100644
index 0000000..2f41de5
--- /dev/null
+++ b/src/wcwidth.C
@@ -0,0 +1,488 @@
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
+#include <wchar.h>
+#include <stdlib.h>
+#include <string.h>
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
+#define USE_MK_WCWIDTH 0  /* Use wcwidth(), wcswidth() instead of mk_wcwidth(), mk_wcswidth() by Z.OOL. */
+
+#if USE_MK_WCWIDTH
+static int mk_wcwidth(wchar_t ucs)
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
+static int mk_wcswidth(const wchar_t *pwcs, size_t n)
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
+#endif
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
+static int mk_wcwidth_cjk(wchar_t ucs)
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
+#if USE_MK_WCWIDTH
+  return mk_wcwidth(ucs);
+#else
+  return wcwidth(ucs);
+#endif
+}
+
+static int mk_wcswidth_cjk(const wchar_t *pwcs, size_t n)
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
+static int mk_wcwidth_cjk_emoji(wchar_t ucs)
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
+static int mk_wcswidth_cjk_emoji(const wchar_t *pwcs, size_t n)
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
+
+#define NO_CJK 0
+#define CJK    1
+#define EMOJI  2
+
+static int urxvt_use_wcwidth(void)
+{
+  char *lang = NULL, *cjk = NULL;
+#ifndef NO_USE_UTF8CJK_EMOJI
+  char *emoji = NULL;
+#endif
+  static int use_wcwidth = -1;
+
+  if (use_wcwidth >= 0)
+    return use_wcwidth;
+
+  lang  = getenv("LC_CTYPE");
+  cjk   = getenv("URXVT_USE_UTF8_CJK");
+#ifndef NO_USE_UTF8CJK_EMOJI
+  emoji = getenv("URXVT_USE_UTF8_CJK_EMOJI");
+#endif
+
+  if (lang == NULL || *lang =='\0')
+    lang = getenv("LANG");
+  if (lang == NULL || *lang == '\0')
+    lang = getenv("LC_ALL");
+  if (lang == NULL || *lang == '\0')
+    lang = "";
+
+  if (cjk == NULL || *cjk == '\0')
+    cjk = "";
+#ifndef NO_USE_UTF8CJK_EMOJI
+  if (emoji == NULL || *emoji == '\0')
+    emoji = "";
+#endif
+
+  if (!strncmp(lang, "ja", 2) || !strncmp(lang, "ko", 2) || !strncmp(lang, "zh", 2))
+    use_wcwidth = CJK;
+  else
+    use_wcwidth = NO_CJK;
+
+  if (!strncmp(cjk, "1", 1))
+    use_wcwidth = CJK;
+  else if(!strncmp(cjk, "0", 1))
+    use_wcwidth = NO_CJK;
+
+#ifndef NO_USE_UTF8CJK_EMOJI
+  if (!strncmp(emoji, "1", 1))
+    use_wcwidth = EMOJI;
+#endif
+
+  return use_wcwidth;
+}
+
+int urxvt_wcwidth(wchar_t ucs)
+{
+  switch (urxvt_use_wcwidth()) {
+#if USE_MK_WCWIDTH
+    case NO_CJK: return mk_wcwidth(ucs);
+#else
+    case NO_CJK: return wcwidth(ucs);
+#endif
+    case CJK:    return mk_wcwidth_cjk(ucs);
+#ifndef NO_USE_UTF8CJK_EMOJI
+    case EMOJI:  return mk_wcwidth_cjk_emoji(ucs);
+#endif
+  }
+}
+
+int urxvt_wcswidth(const wchar_t *ucs, size_t n)
+{
+  switch (urxvt_use_wcwidth()) {
+#if USE_MK_WCWIDTH
+    case NO_CJK: return mk_wcswidth(ucs, n);
+#else
+    case NO_CJK: return wcswidth(ucs, n);
+#endif
+    case CJK:    return mk_wcswidth_cjk(ucs, n);
+#ifndef NO_USE_UTF8CJK_EMOJI
+    case EMOJI:  return mk_wcswidth_cjk_emoji(ucs, n);
+#endif
+  }
+}
+#endif /* NO_USE_UTF8CJK */
