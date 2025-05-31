# Handle repo_path argument
set idx [lsearch ${argv} "-r"]
if {${idx} != -1} {
    set repo_path [glob -nocomplain [file normalize [lindex ${argv} [expr {${idx}+1}]]]]
} else {
    # Default
    set repo_path [file normalize [file dirname [info script]]/..]
}

# Handle xpr_path argument
set idx [lsearch ${argv} "-x"]
if {${idx} != -1} {
    set xpr_path [file normalize [lindex ${argv} [expr {${idx}+1}]]]
} else {
    # Default
    set xpr_path [file join ${repo_path} proj [file tail $repo_path]].xpr]
}

# Handle vivado_version argument
set idx [lsearch ${argv} "-v"]
if {${idx} != -1} {
    set vivado_version [lindex ${argv} [expr {${idx}+1}]]
} else {
    # Default
    set vivado_version [version -short]
}

# Handle build flag
set idx [lsearch ${argv} "-b"]
if {${idx} != -1} {
    set build_when_checked_out 1
} else {
    # Default
    set build_when_checked_out 0
}

# Handle no block flag
set idx [lsearch ${argv} "-no-block"]
if {${idx} != -1} {
    set wait_on_build 0
} else {
    # Default
    set wait_on_build 1
}

# Other variables
set vivado_year [lindex [split $vivado_version "."] 0]
set proj_name [file rootname [file tail $xpr_path]]

puts "INFO: Creating new project \"$proj_name\" in [file dirname $xpr_path]"
set proj_path [file normalize [file dirname $xpr_path]]
set root_name [file rootname $xpr_path]

create_project $proj_name [file dirname $xpr_path] -part xc7k325tffg900-2
# create_project haih2025 /home/ssakguel/Xilinx/Projects/haih2025 -part xc7k325tffg900-2
set_property board_part digilentinc.com:genesys2:part0:1.1 [current_project]
source import_files.tcl
update_compile_order -fileset sources_1


create_ip -name clk_wiz -vendor xilinx.com -library ip -version 6.0 -module_name clk_wiz_0
set_property -dict [list \
  CONFIG.CLKIN1_JITTER_PS {50.0} \
  CONFIG.CLKOUT1_JITTER {112.316} \
  CONFIG.CLKOUT1_PHASE_ERROR {89.971} \
  CONFIG.CLK_IN1_BOARD_INTERFACE {sys_diff_clock} \
  CONFIG.MMCM_CLKFBOUT_MULT_F {5.000} \
  CONFIG.MMCM_CLKIN1_PERIOD {5.000} \
  CONFIG.MMCM_CLKIN2_PERIOD {10.0} \
  CONFIG.PRIM_IN_FREQ {200.000} \
  CONFIG.PRIM_SOURCE {Differential_clock_capable_pin} \
] [get_ips clk_wiz_0]
generate_target {instantiation_template} [get_files $root_name.srcs/sources_1/ip/clk_wiz_0/clk_wiz_0.xci]
generate_target all [get_files  $root_name.srcs/sources_1/ip/clk_wiz_0/clk_wiz_0.xci]
catch { config_ip_cache -export [get_ips -all clk_wiz_0] }
export_ip_user_files -of_objects [get_files $root_name.srcs/sources_1/ip/clk_wiz_0/clk_wiz_0.xci] -no_script -sync -force -quiet
create_ip_run [get_files -of_objects [get_fileset sources_1] $root_name.srcs/sources_1/ip/clk_wiz_0/clk_wiz_0.xci]
launch_runs clk_wiz_0_synth_1 -jobs 16
wait_on_run clk_wiz_0_synth_1
export_simulation -of_objects [get_files $root_name.srcs/sources_1/ip/clk_wiz_0/clk_wiz_0.xci] -directory $root_name.ip_user_files/sim_scripts -ip_user_files_dir $root_name.ip_user_files -ipstatic_source_dir $root_name.ip_user_files/ipstatic -lib_map_path [list {modelsim=$root_name.cache/compile_simlib/modelsim} {questa=$root_name.cache/compile_simlib/questa} {xcelium=$root_name.cache/compile_simlib/xcelium} {vcs=$root_name.cache/compile_simlib/vcs} {riviera=$root_name.cache/compile_simlib/riviera}] -use_ip_compiled_libs -force -quiet

create_ip -name vio -vendor xilinx.com -library ip -version 3.0 -module_name vio_0
set_property -dict [list \
  CONFIG.C_NUM_PROBE_OUT {3} \
  CONFIG.C_PROBE_OUT0_WIDTH {64} \
] [get_ips vio_0]
generate_target {instantiation_template} [get_files $root_name.srcs/sources_1/ip/vio_0/vio_0.xci]
generate_target all [get_files  $root_name.srcs/sources_1/ip/vio_0/vio_0.xci]
catch { config_ip_cache -export [get_ips -all vio_0] }
export_ip_user_files -of_objects [get_files $root_name.srcs/sources_1/ip/vio_0/vio_0.xci] -no_script -sync -force -quiet
create_ip_run [get_files -of_objects [get_fileset sources_1] $root_name.srcs/sources_1/ip/vio_0/vio_0.xci]
launch_runs vio_0_synth_1 -jobs 16
wait_on_run vio_0_synth_1
export_simulation -of_objects [get_files $root_name.srcs/sources_1/ip/vio_0/vio_0.xci] -directory $root_name.ip_user_files/sim_scripts -ip_user_files_dir $root_name.ip_user_files -ipstatic_source_dir $root_name.ip_user_files/ipstatic -lib_map_path [list {modelsim=$root_name.cache/compile_simlib/modelsim} {questa=$root_name.cache/compile_simlib/questa} {xcelium=$root_name.cache/compile_simlib/xcelium} {vcs=$root_name.cache/compile_simlib/vcs} {riviera=$root_name.cache/compile_simlib/riviera}] -use_ip_compiled_libs -force -quiet

create_ip -name ila -vendor xilinx.com -library ip -version 6.2 -module_name ila_0
set_property -dict [list \
  CONFIG.C_NUM_OF_PROBES {3} \
  CONFIG.C_PROBE0_TYPE {1} \
  CONFIG.C_PROBE0_WIDTH {32} \
] [get_ips ila_0]
generate_target {instantiation_template} [get_files $root_name.srcs/sources_1/ip/ila_0/ila_0.xci]
generate_target all [get_files  $root_name.srcs/sources_1/ip/ila_0/ila_0.xci]
catch { config_ip_cache -export [get_ips -all ila_0] }
export_ip_user_files -of_objects [get_files $root_name.srcs/sources_1/ip/ila_0/ila_0.xci] -no_script -sync -force -quiet
create_ip_run [get_files -of_objects [get_fileset sources_1] $root_name.srcs/sources_1/ip/ila_0/ila_0.xci]
launch_runs ila_0_synth_1 -jobs 16
wait_on_run ila_0_synth_1
export_simulation -of_objects [get_files $root_name.srcs/sources_1/ip/ila_0/ila_0.xci] -directory $root_name.ip_user_files/sim_scripts -ip_user_files_dir $root_name.ip_user_files -ipstatic_source_dir $root_name.ip_user_files/ipstatic -lib_map_path [list {modelsim=$root_name.cache/compile_simlib/modelsim} {questa=$root_name.cache/compile_simlib/questa} {xcelium=$root_name.cache/compile_simlib/xcelium} {vcs=$root_name.cache/compile_simlib/vcs} {riviera=$root_name.cache/compile_simlib/riviera}] -use_ip_compiled_libs -force -quiet

add_files -fileset constrs_1 -norecurse $proj_path/../vivado_local/const_0.xdc

update_compile_order -fileset sources_1
update_compile_order -fileset sources_1
reset_run clk_wiz_0_synth_1
reset_run vio_0_synth_1
reset_run ila_0_synth_1
launch_runs impl_1 -jobs 16
wait_on_run impl_1

open_run impl_1
report_timing_summary -file reports/timing.rpt
report_utilization -hierarchical -hierarchical_percentages -file reports/util.rpt -cells [get_cells i_l2_norm_axis]