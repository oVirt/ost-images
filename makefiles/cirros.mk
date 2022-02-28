cirros.img:
	curl -L -o $@ $(CIRROS_URL)
	qemu-img check -f qcow2 $@
