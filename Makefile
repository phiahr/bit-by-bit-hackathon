VERILATED_DIR := obj_dir
TOP_NAME := L2NormAXIS
SRC_DIR := sources
SOURCES := $(shell find $(SRC_DIR) -name '*.sv' ! -name 'vivado_top.sv')
TESTBENCH_MAIN := testbench/tb.cpp

YOSYS_OUTDIR := yosys-results
YOSYS_COMMANDS ?= -flatten;
YOSYS_STAT_COMMANDS := stat -width -tech cmos -json;

VIZ_EXT ?= svg

# Empty cflags for now
CFLAGS ?=

MODE ?=
FIXED_WIDTH ?= 32

# Skip MODE validation for clean target
ifeq ($(MAKECMDGOALS),clean)
  SKIP_MODE_CHECK := 1
endif

DEFINES ?=

# Input validation for MODE
ifeq ($(MODE),float)
 DEFINES += FLOAT
else ifeq ($(MODE),fixed)
 DEFINES += FIXED=$(FIXED_WIDTH)
else
ifndef SKIP_MODE_CHECK
 $(error Invalid MODE. Use 'make MODE=float' or 'make MODE=fixed FIXED_WIDTH=<bits>')
endif
endif

MODE_FILENAME_SUFFIX := $(MODE)
ifeq ($(MODE),fixed)
	MODE_FILENAME_SUFFIX := $(MODE_FILENAME_SUFFIX)_$(FIXED_WIDTH)
endif

# Convert DEFINES into -D options for CFLAGS
CFLAGS_DEFINES := $(foreach def,$(DEFINES),-D$(def))

# Extend CFLAGS with the defines
CFLAGS += $(CFLAGS_DEFINES)

.PHONY: all clean run

all: $(VERILATED_DIR)/V$(TOP_NAME)

.PHONY: check-verilator
check-verilator:
	@echo "Checking Verilator version..."
	@if ! command -v verilator >/dev/null 2>&1; then \
		echo "Error: Verilator is not in your PATH."; \
		exit 1; \
	fi
	@VERILATOR_VERSION=$$(verilator --version | grep -oP 'Verilator \K[0-9]+\.[0-9]+'); \
	REQUIRED_VERSION="5.032"; \
	if [ "$$(printf '%s\n' "$$REQUIRED_VERSION" "$$VERILATOR_VERSION" | sort -V | head -n1)" = "$$REQUIRED_VERSION" ]; then \
		echo "Verilator version $$VERILATOR_VERSION is OK (>= $$REQUIRED_VERSION)."; \
	else \
		echo "Error: Verilator version $$VERILATOR_VERSION is too old. Required >= $$REQUIRED_VERSION."; \
		exit 1; \
	fi


$(VERILATED_DIR)/V$(TOP_NAME): $(SOURCES) $(TESTBENCH_MAIN) check-verilator
	verilator --cc --threads 1 --vpi --no-timing \
		$(SOURCES) \
		--exe $(abspath $(TESTBENCH_MAIN)) \
		--Mdir $(VERILATED_DIR) \
		-CFLAGS $(CFLAGS) \
		--build \
		-Wno-LATCH \
		-Wno-WIDTHEXPAND \
		-Wno-WIDTHTRUNC \
		-Wno-WAITCONST \
		-Wno-INITIALDLY

run: $(VERILATED_DIR)/V$(TOP_NAME)
	./$(VERILATED_DIR)/V$(TOP_NAME)


####  YOSYS based stats and visualization  ####
$(YOSYS_OUTDIR):
	mkdir -p $@

# Convert DEFINES into -D options for YOSYS
YOSYS_DEFINE_FLAGS := $(foreach def,$(DEFINES),-D$(def))

# generate a statistics output
$(YOSYS_OUTDIR)/stats_$(MODE_FILENAME_SUFFIX).json: $(YOSYS_OUTDIR) | $(SOURCES)
	@if ! command -v yosys >/dev/null 2>&1; then \
		echo "Error: Yosys is not installed or not in your PATH."; \
		exit 1; \
	fi
	yosys -Q $(YOSYS_DEFINE_FLAGS) -p "verilog_defines; prep -top $(TOP_NAME) $(YOSYS_COMMANDS); $(YOSYS_STAT_COMMANDS);" $(SOURCES) | tee $@
	@if command -v sed >/dev/null 2>&1; then \
		sed -i '/^{/,/^}/!d' $@; \
	else \
		echo "Error: sed is not installed or not in your PATH."; \
		exit 1; \
	fi

# generate a json netlist (custom yosys format)
$(YOSYS_OUTDIR)/netlist_$(MODE_FILENAME_SUFFIX).json: $(YOSYS_OUTDIR) | $(SOURCES)
	@if ! command -v yosys >/dev/null 2>&1; then \
		echo "Error: Yosys is not installed or not in your PATH."; \
		exit 1; \
	fi
	yosys -Q $(YOSYS_DEFINE_FLAGS) -p "verilog_defines; prep -top $(TOP_NAME) $(YOSYS_COMMANDS); write_json $@" $(SOURCES)

# convert the yoys netlist into a picture
$(YOSYS_OUTDIR)/netlist_$(MODE_FILENAME_SUFFIX).svg: $(YOSYS_OUTDIR)/netlist_$(MODE_FILENAME_SUFFIX).json
	@if ! command -v netlistsvg >/dev/null 2>&1; then \
		echo "Error: netlistsvg is not installed or not in your PATH."; \
		exit 1; \
	fi
	netlistsvg $< -o $@

# the svg files can be a bit annoying to view, add a rule to convert them
$(YOSYS_OUTDIR)/%.png: $(YOSYS_OUTDIR)/%.svg
	@if ! command -v convert >/dev/null 2>&1; then \
		echo "Error: ImageMagick's convert tool is not installed or not in your PATH."; \
		exit 1; \
	fi
	convert -density 96 $< $@

.PHONY: stats
stats: $(YOSYS_OUTDIR)/stats_$(MODE_FILENAME_SUFFIX).json

.PHONY: netlist
netlist: $(YOSYS_OUTDIR)/netlist_$(MODE_FILENAME_SUFFIX).json

.PHONY: visualize
visualize: $(YOSYS_OUTDIR)/netlist_$(MODE_FILENAME_SUFFIX).$(VIZ_EXT)


clean:
	rm -rf $(VERILATED_DIR) $(YOSYS_OUTDIR)
