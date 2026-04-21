DESIGN ?= pynq_base_zu15
VIVADO_VERSION ?= 2024.2
FORCE :=

create:
ifneq ($(FORCE),)
	$(eval FORCE_FLAG := -Force)
endif
ifeq ($(OS),Windows_NT)
	pwsh -ExecutionPolicy Bypass -File scripts/create_project.ps1 -Design $(DESIGN) $(FORCE_FLAG)
else
	bash scripts/create_project.sh -design $(DESIGN) $(FORCE_FLAG)
endif

clean:
ifeq ($(OS),Windows_NT)
	pwsh -ExecutionPolicy Bypass -File scripts/clean.ps1
else
	bash scripts/clean.sh
endif

clean-build:
ifeq ($(OS),Windows_NT)
	pwsh -ExecutionPolicy Bypass -File scripts/clean.ps1 -Build
else
	bash scripts/clean.sh --build
endif

clean-logs:
ifeq ($(OS),Windows_NT)
	pwsh -ExecutionPolicy Bypass -File scripts/clean.ps1 -Logs
else
	bash scripts/clean.sh --logs
endif

designs:
	@echo "Available designs:"
	@ls -1 designs/ | grep -v README | awk '{print "  - " $$0}'

help:
	@echo "Vivado Makefile"
	@echo ""
	@echo "Usage:"
	@echo "  make create                    # default (pynq_base_zu15)"
	@echo "  make create DESIGN=pynq_base_zu9 # select design (use DESIGN= syntax!)"
	@echo "  make create FORCE=1            # overwrite existing"
	@echo "  make clean                   # remove build and logs"
	@echo "  make clean-build            # remove build only"
	@echo "  make clean-logs             # remove logs only"
	@echo "  make designs"

.PHONY: create clean clean-build clean-logs designs help
