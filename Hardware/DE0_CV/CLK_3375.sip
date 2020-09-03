set_global_assignment -entity "CLK_3375" -library "lib_CLK_3375" -name IP_TOOL_NAME "altera_pll"
set_global_assignment -entity "CLK_3375" -library "lib_CLK_3375" -name IP_TOOL_VERSION "17.0"
set_global_assignment -entity "CLK_3375" -library "lib_CLK_3375" -name IP_TOOL_ENV "mwpim"
set_global_assignment -library "lib_CLK_3375" -name SPD_FILE [file join $::quartus(sip_path) "CLK_3375.spd"]

set_global_assignment -library "lib_CLK_3375" -name MISC_FILE [file join $::quartus(sip_path) "CLK_3375_sim/CLK_3375.vho"]
