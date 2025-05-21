set search_path         ". /home/library/PDK/SCC28NHKCP_HDC40P140_RVT_V0p2/liberty/0.9v"
set target_library      "scc28nhkcp_hdc40p140_rvt_tt_v0p9_25c_basic.db"
set link_library        "* $target_library"

set top "{UNIT_NAME}"

analyze -format sverilog -vcs [glob -nocomplain -directory ../../../../2x2/*.v]
analyze -format sverilog -vcs [glob -nocomplain -directory ../../../../units/HA.v]
analyze -format sverilog -vcs [glob -nocomplain -directory ../../../../units/FA.v]
elaborate $top
current_design $top
check_design

link

set CLK_PERIOD  1
create_clock -period $CLK_PERIOD -name vclk
set_input_delay 0.0 -clock vclk [all_inputs]
set_output_delay 0.0 -clock vclk [all_outputs]

set_max_area 0 -ignore_tns

compile_ultra

write -f verilog -output ../mapped/{UNIT_NAME}_synthesized.v

exit