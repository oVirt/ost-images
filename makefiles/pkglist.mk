%-pkglist.txt: %.qcow2
	virt-copy-out -a $*.qcow2 $(_PKGLIST_PATH)/$@ .

%-engine-installed-pkglist-diff.txt: %-engine-installed-pkglist.txt %-base-pkglist.txt
	$(_DIFF) $*-engine-installed-pkglist.txt $*-base-pkglist.txt > $@ || :
	[ -s $@ ]

%-host-installed-pkglist-diff.txt: %-host-installed-pkglist.txt %-base-pkglist.txt
	$(_DIFF) $*-host-installed-pkglist.txt $*-base-pkglist.txt > $@ || :
	[ -s $@ ]

%-he-installed-pkglist-diff.txt: %-he-installed-pkglist.txt %-host-installed-pkglist.txt
	$(_DIFF) $*-he-installed-pkglist.txt $*-host-installed-pkglist.txt > $@ || :
	[ -s $@ ]
