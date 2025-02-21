AWK=awk
HUGO=hugo

.PHONY: build
build:
	# ... rest of your build process
	$(HUGO)
	# ... rest of your build process
	make $(shell find public -type f -name "*.html")

public/%.html: .FORCE
	@mv $@ tmp.html
	$(AWK) -v outfile=$@ -f scripts/process-code-blocks.awk tmp.html
	@rm tmp.html

.PHONY: .FORCE
.FORCE:
