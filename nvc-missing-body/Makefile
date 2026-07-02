# Reproduces an NVC elaboration crash (see README.md):
#
#   ** Fatal: (init): missing body for WORK.TOP_REPRO.U0.PA_MSB()I
#
# Requires `nvc` on $PATH (override with `make NVC=/path/to/nvc`).
# Verified against nvc master 55395b8d (2026-07-02).
#
# Targets:
#   make repro   - run analysis + elaboration; FAILS while the bug is present
#                  (this is the command sequence to quote in the bug report)
#   make check   - exits 0 iff the bug reproduces (inverted, for scripting)
#   make clean   - remove the work library

NVC ?= nvc
TOP  = top_repro
SRC  = repro.vhd

.PHONY: all repro check clean

all: repro

repro: $(SRC)
	$(NVC) -a $(SRC)
	$(NVC) -e $(TOP)

check: $(SRC)
	$(NVC) -a $(SRC)
	@if $(NVC) -e $(TOP) 2>elab.log; then \
	  echo "NOT REPRODUCED: elaboration succeeded (bug fixed?)"; \
	  exit 1; \
	elif grep -q "missing body" elab.log; then \
	  cat elab.log; \
	  echo "REPRODUCED: elaboration failed with the expected error"; \
	else \
	  cat elab.log; \
	  echo "elaboration failed, but NOT with the expected error"; \
	  exit 1; \
	fi

clean:
	rm -rf work elab.log
