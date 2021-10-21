# If we're using preinstalled base image all we need to
# do is to make a symlink of the qcow image in the build
# directory.
%-base.qcow2:
	ln -s $(_BASE_IMAGE_PREFIX)$(*)-base.qcow2 $@
