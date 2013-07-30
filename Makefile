VERSION=0.7.3
INSTALL=install -p
SED=sed
LIBEXECDIR=/usr/libexec
DRACUTMODDIR=/usr/lib/dracut/modules.d

dracut_DIR = $(DRACUTMODDIR)/90system-upgrade
dracut_SCRIPTS = 90system-upgrade/module-setup.sh \
		 90system-upgrade/upgrade-init.sh \
		 90system-upgrade/upgrade-pre-pivot.sh \
		 90system-upgrade/upgrade-pre.sh \
		 90system-upgrade/upgrade.sh \
		 90system-upgrade/upgrade-post.sh
dracut_DATA = 90system-upgrade/README.txt \
	      90system-upgrade/upgrade.target \
	      90system-upgrade/upgrade-pre.service \
	      90system-upgrade/upgrade.service \
	      90system-upgrade/upgrade-post.service \
	      90system-upgrade/upgrade-debug-shell.service

rhelup_DIR = $(DRACUTMODDIR)/85system-upgrade-redhat
rhelup_BIN = system-upgrade-redhat
rhelup_SCRIPTS = 85system-upgrade-redhat/module-setup.sh \
		 85system-upgrade-redhat/keep-initramfs.sh \
		 85system-upgrade-redhat/prepare-rootfs.sh \
		 85system-upgrade-redhat/do-upgrade.sh \
		 85system-upgrade-redhat/upgrade-cleanup.sh \
		 85system-upgrade-redhat/save-journal.sh

THEMENAME=rhelup
THEMESDIR=$(shell pkg-config ply-splash-graphics --variable=themesdir)
plymouth_DIR = $(THEMESDIR)$(THEMENAME)
plymouth_DATA = plymouth/*.png
plymouth_THEME = plymouth/rhelup.plymouth

GENFILES = 85system-upgrade-redhat/module-setup.sh

SCRIPTS = $(dracut_SCRIPTS) $(rhelup_SCRIPTS)
DATA = $(dracut_DATA) $(plymouth_DATA) $(plymouth_THEME)
BIN = $(rhelup_BIN)

all: $(SCRIPTS) $(DATA) $(BIN)

PACKAGES=glib-2.0 rpm ply-boot-client

$(BIN): %: %.c
	$(CC) $(shell pkg-config $(PACKAGES) --cflags --libs) $(CFLAGS) $< -o $@

$(GENFILES): %: %.in
	$(SED) -e 's,@LIBEXECDIR@,$(LIBEXECDIR),g' \
	       -e 's,@VERSION@,$(VERSION),g' \
	       $< > $@

clean:
	rm -f $(BIN) $(GENFILES) $(ARCHIVE)

install: $(BIN) $(SCRIPTS) $(DATA)
	$(INSTALL) -d $(DESTDIR)$(LIBEXECDIR)
	$(INSTALL) $(BIN) $(DESTDIR)$(LIBEXECDIR)
	$(INSTALL) -d $(DESTDIR)$(dracut_DIR)
	$(INSTALL) $(dracut_SCRIPTS) $(DESTDIR)$(dracut_DIR)
	$(INSTALL) -m644 $(dracut_DATA) $(DESTDIR)$(dracut_DIR)
	$(INSTALL) -d $(DESTDIR)$(rhelup_DIR)
	$(INSTALL) $(rhelup_SCRIPTS) $(DESTDIR)$(rhelup_DIR)
	$(INSTALL) -d $(DESTDIR)$(plymouth_DIR)
	$(INSTALL) -m644 $(plymouth_DATA) $(DESTDIR)$(plymouth_DIR)
	$(INSTALL) -m644 $(plymouth_THEME) \
			 $(DESTDIR)$(plymouth_DIR)/$(THEMENAME).plymouth

ARCHIVE = rhelup-dracut-$(VERSION).tar.xz
archive: $(ARCHIVE)
$(ARCHIVE):
	git archive --format=tar --prefix=rhelup-dracut-$(VERSION)/ HEAD \
	  | xz -c > $@ || rm $@

.PHONY: all clean archive install
