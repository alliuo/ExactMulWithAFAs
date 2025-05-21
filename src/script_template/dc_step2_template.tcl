set search_path         ". /home/library/PDK/SCC28NHKCP_HDC40P140_RVT_V0p2/liberty/0.9v"
set target_library      "scc28nhkcp_hdc40p140_rvt_tt_v0p9_25c_basic.db"
set link_library        "* $target_library"

read_verilog ../mapped/{UNIT_NAME}_synthesized.v

set CLK_PERIOD  1
create_clock -period $CLK_PERIOD -name vclk
set_input_delay 0.0 -clock vclk [all_inputs]
set_output_delay 0.0 -clock vclk [all_outputs]

read_saif -input ../vcs/saif/{UNIT_NAME}.saif -instance top_sim/top

report_saif > ../out/{UNIT_NAME}.saif.rpts
report_area -hierarchy > ../out/{UNIT_NAME}.area.rpts
report_power -analysis_effort high > ../out/{UNIT_NAME}.power.rpts
report_timing -path full -delay max -max_paths 1 -nworst 1 -significant_digits 5 > ../out/{UNIT_NAME}.timing.rpts

exit