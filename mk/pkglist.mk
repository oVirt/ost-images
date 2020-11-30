%-pkglist.txt: %.qcow2
	virt-copy-out -a $*.qcow2 $(_PKGLIST_PATH)/$@ .

%-upgrade-pkglist-diff.txt: %-upgrade-pkglist.txt %-base-pkglist.txt
	$(_DIFF) $*-upgrade-pkglist.txt $*-base-pkglist.txt > $@

%-engine-installed-pkglist-diff.txt: %-engine-installed-pkglist.txt %-upgrade-pkglist.txt
	$(_DIFF) $*-engine-installed-pkglist.txt $*-upgrade-pkglist.txt > $@

%-host-installed-pkglist-diff.txt: %-host-installed-pkglist.txt %-upgrade-pkglist.txt
	$(_DIFF) $*-host-installed-pkglist.txt $*-upgrade-pkglist.txt > $@

%-he-installed-pkglist-diff.txt: %-he-installed-pkglist.txt %-host-installed-pkglist.txt
	$(_DIFF) $*-he-installed-pkglist.txt $*-host-installed-pkglist.txt > $@
