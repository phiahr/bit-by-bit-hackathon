TCL_FILE := import_files.tcl
SRC_DIR := $(PWD)/../sources

.PHONY: all clean

all: init

$(TCL_FILE): $(SRC_DIR)
	@echo "Generating TCL file..."
	@find $(SRC_DIR) -type f -name "*.sv" | \
	sed 's|$(SRC_DIR)|import_files -norecurse $$proj_path/../sources|' | \
	sed 's|\\|/|g' > $(TCL_FILE)
	@echo "Generated $(TCL_FILE)"

init: $(TCL_FILE) reports
	@echo "Running TCL script..."
	vivado -mode batch -source proj_init.tcl -nolog -nojournal
	@echo "TCL script executed"

reports:
	mkdir reports

clean-project:
	@rm -rf ../proj
	
clean:
	@rm -f $(TCL_FILE)
	@rm -rf reports
	@echo "Cleaned up"