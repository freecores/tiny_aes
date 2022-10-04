# Design
set ::env(CLOCK_PORT) "clk"
set ::env(CLOCK_NET) $::env(CLOCK_PORT)
set ::env(GLB_RT_MAX_DIODE_INS_ITERS) 1
set ::env(SYNTH_MAX_FANOUT) 9
set ::env(FP_CORE_UTIL) 30
set ::env(GLB_RT_ADJUSTMENT) 0.05
set ::env(PL_TARGET_DENSITY) [ expr ($::env(FP_CORE_UTIL)+5) / 100.0 ]
set ::env(CLOCK_PERIOD) "15.0"
