# ============================================================
# uart_genus_flow.tcl
#
# UART V3 synthesis flow example for Cadence Genus
#
# 실행 예:
#   genus -f uart_genus_flow.tcl
#
# 환경변수
#   UART_RTL_PATH
#   PDK_LIB_DIR
#
# 목적
#   - UART V3 synthesis flow 구조 예제
#   - hard-coded 개인 경로 제거
#   - report 생성
# ============================================================


puts "========================================"
puts " UART V3 GENUS SYNTHESIS FLOW"
puts "========================================"


# ------------------------------------------------------------
# Helper
# ------------------------------------------------------------

proc require_env {name} {

    if {![info exists ::env($name)]} {
        puts "ERROR : environment variable $name is not defined"
        exit 1
    }

    return $::env($name)
}


# ------------------------------------------------------------
# Environment
# ------------------------------------------------------------

set RTL_PATH    [require_env UART_RTL_PATH]
set PDK_LIB_DIR [require_env PDK_LIB_DIR]

set TOP_DESIGN uart_apb
set CLOCK_PORT i_pclk
set CLOCK_PERIOD 20.0


# ------------------------------------------------------------
# Library
# ------------------------------------------------------------

set LIB_FILE [file join \
    $PDK_LIB_DIR \
    slow_vdd1v0_basicCells.lib]


if {![file exists $LIB_FILE]} {
    puts "ERROR : library not found"
    puts "FILE  : $LIB_FILE"
    exit 1
}


# ------------------------------------------------------------
# RTL list
# ------------------------------------------------------------

set RTL_LIST {
    uart_baud_gen.v
    uart_tx.v
    uart_tx_fifo.v
    uart_rx.v
    uart_rx_fifo.v
    uart_core.v
    uart_irq.v
    uart_apb.v
}


set RTL_FILES {}

foreach rtl $RTL_LIST {

    set full_path [file join $RTL_PATH $rtl]

    if {![file exists $full_path]} {
        puts "ERROR : RTL file not found"
        puts "FILE  : $full_path"
        exit 1
    }

    lappend RTL_FILES $full_path
}


# ------------------------------------------------------------
# Output directories
# ------------------------------------------------------------

file mkdir reports
file mkdir outputs


# ------------------------------------------------------------
# Genus setup
# ------------------------------------------------------------

puts ""
puts {[1] READ LIBRARY}
puts "----------------------------------------"

read_libs $LIB_FILE


puts ""
puts {[2] READ RTL}
puts "----------------------------------------"

read_hdl $RTL_FILES


puts ""
puts {[3] ELABORATE}
puts "----------------------------------------"

elaborate $TOP_DESIGN


# ------------------------------------------------------------
# Constraints
# ------------------------------------------------------------

puts ""
puts {[4] CONSTRAINTS}
puts "----------------------------------------"

create_clock \
    -name PCLK \
    -period $CLOCK_PERIOD \
    [get_ports $CLOCK_PORT]


# Async reset
set_false_path \
    -from [get_ports i_rst_n]


# UART RX asynchronous input
set_false_path \
    -from [get_ports i_uartRx]


# ------------------------------------------------------------
# Synthesis
# ------------------------------------------------------------

puts ""
puts {[5] SYNTHESIS}
puts "----------------------------------------"

syn_generic
syn_map
syn_opt


# ------------------------------------------------------------
# Reports
# ------------------------------------------------------------

puts ""
puts {[6] REPORTS}
puts "----------------------------------------"

report_timing \
    > reports/uart_timing.rpt

report_area \
    > reports/uart_area.rpt

report_power \
    > reports/uart_power.rpt


# ------------------------------------------------------------
# Netlist
# ------------------------------------------------------------

puts ""
puts {[7] OUTPUT}
puts "----------------------------------------"

write_hdl \
    > outputs/uart_apb_netlist.v


puts ""
puts "========================================"
puts " UART V3 SYNTHESIS FLOW COMPLETE"
puts "========================================"
