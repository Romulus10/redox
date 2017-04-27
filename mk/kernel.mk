$(KBUILD)/libcollections.rlib: rust/src/libcollections/Cargo.toml rust/src/libcollections/**
	mkdir -p $(KBUILD)
	$(KCARGO) rustc --manifest-path $< $(KCARGOFLAGS) -o $@
	cp rust/src/target/$(KTARGET)/release/deps/*.rlib $(KBUILD)

$(KBUILD)/libkernel.a: kernel/Cargo.toml kernel/src/** $(KBUILD)/libcollections.rlib $(KBUILD)/initfs.tag
	$(KCARGO) rustc --manifest-path $< --lib $(KCARGOFLAGS) -o $@

$(KBUILD)/libkernel_live.a: kernel/Cargo.toml kernel/src/** $(KBUILD)/libcollections.rlib $(KBUILD)/initfs.tag build/filesystem.bin
	$(KCARGO) rustc --manifest-path $< --lib --features live $(KCARGOFLAGS) -o $@

$(KBUILD)/kernel: $(KBUILD)/libkernel.a
	$(LD) $(LDFLAGS) -z max-page-size=0x1000 -T kernel/linkers/$(ARCH).ld -o $@ $<

$(KBUILD)/kernel_live: $(KBUILD)/libkernel_live.a
	$(LD) $(LDFLAGS) -z max-page-size=0x1000 -T kernel/linkers/$(ARCH).ld -o $@ $<
