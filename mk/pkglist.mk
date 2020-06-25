%-pkglist.txt: %.qcow2
	virt-copy-out -a $*.qcow2 $(_PKGLIST_PATH)/$@ .

%-upgrade-pkglist-diff.txt: %-upgrade-pkglist.txt %-base-pkglist.txt
	$(_DIFF) $*-upgrade-pkglist.txt $*-base-pkglist.txt > $@

%-host-deps-installed-pkglist-diff.txt: %-host-deps-installed-pkglist.txt %-upgrade-pkglist.txt
	$(_DIFF) $*-host-deps-installed-pkglist.txt $*-upgrade-pkglist.txt > $@

%-engine-deps-installed-pkglist-diff.txt: %-engine-deps-installed-pkglist.txt %-upgrade-pkglist.txt
	$(_DIFF) $*-engine-deps-installed-pkglist.txt $*-upgrade-pkglist.txt > $@

%-host-installed-pkglist-diff.txt: %-host-installed-pkglist.txt %-upgrade-pkglist.txt
	$(_DIFF) $*-host-installed-pkglist.txt $*-upgrade-pkglist.txt > $@

%-engine-installed-pkglist-diff.txt: %-engine-installed-pkglist.txt %-upgrade-pkglist.txt
	$(_DIFF) $*-engine-installed-pkglist.txt $*-upgrade-pkglist.txt > $@
