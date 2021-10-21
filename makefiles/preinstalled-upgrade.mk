# If we're using preinstalled image all we need to do is to
# make a symlink of the qcow image in the build directory.
%-upgrade.qcow2: %-base.qcow2
	ln -s $(_UPGRADE_IMAGE_PREFIX)$(*)-upgrade.qcow2 $@
