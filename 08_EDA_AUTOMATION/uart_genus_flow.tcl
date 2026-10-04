# ============================================================
# uart_genus_flow.tcl
#
# UART V3 synthesis flow for Cadence Genus
#
# 실행 예:
#   genus -files uart_genus_flow.tcl -log reports/genus
#
# 환경변수
#   UART_RTL_PATH
#   PDK_LIB_DIR
#
# 목적
#   - UART V3 synthesis flow (Backend Freeze 기준)
#   - hard-coded 개인 경로 제거
#   - report / netlist 생성
#
# Freeze 기준 값
#   Top       : uart_apb
#   Clock     : PCLK 50 MHz (20.0 ns), port = clk
#   Reset     : rst_n (async, active-low)
#   UART RX   : i_uartRx (async input)
#   Library   : slow_vdd1v0_basicCells.lib (setup)
# ============================================================


puts "========================================"
puts " UART V3 GENUS SYNTHESIS FLOW"
puts "========================================"


# ------------------------------------------------------------
# tclsh 로 잘못 실행한 경우 안내
# ------------------------------------------------------------

if {[info commands syn_generic] eq ""} {
    puts "ERROR : this script must run inside Genus"
    puts "        genus -files uart_genus_flow.tcl"
    exit 1
}


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

set TOP_DESIGN   uart_apb

# uart_apb 실제 포트명
set CLOCK_PORT   clk
set RESET_PORT   rst_n
set UART_RX_PORT i_uartRx

set CLOCK_NAME   PCLK
set CLOCK_PERIOD 20.0

# 초기 constraint 값
set CLOCK_UNCERTAINTY 0.2
set IO_DELAY          2.0

# uart_rx.v 의 2-FF synchronizer 확인 후 1로 변경
set RX_SYNC_CONFIRMED 1


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
    uart_fifo.v
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

# unresolved module 이 있으면 file list 누락 가능성
check_design -unresolved > reports/uart_check_unresolved.rpt


# ------------------------------------------------------------
# Port check
#
# SDC 에 쓰는 포트가 실제 top 에 없으면
# constraint 가 무시될 수 있으므로 합성 전에 확인
# ------------------------------------------------------------

puts ""
puts {[4] PORT CHECK}
puts "----------------------------------------"

foreach port [list $CLOCK_PORT $RESET_PORT $UART_RX_PORT] {

    if {[catch {get_ports $port} found] || [llength $found] == 0} {
        puts "ERROR : port '$port' not found in $TOP_DESIGN"
        exit 1
    }

    puts "PASS : $port"
}


# ------------------------------------------------------------
# Constraints
# ------------------------------------------------------------

puts ""
puts {[5] CONSTRAINTS}
puts "----------------------------------------"


create_clock \
    -name $CLOCK_NAME \
    -period $CLOCK_PERIOD \
    [get_ports $CLOCK_PORT]


set_clock_uncertainty \
    $CLOCK_UNCERTAINTY \
    [get_clocks $CLOCK_NAME]


# Async reset
set_false_path \
    -from [get_ports $RESET_PORT]


# APB / synchronous input delay
set_input_delay \
    $IO_DELAY \
    -clock $CLOCK_NAME \
    [remove_from_collection \
        [all_inputs] \
        [get_ports [list \
            $CLOCK_PORT \
            $RESET_PORT \
            $UART_RX_PORT]]]


# output delay
set_output_delay \
    $IO_DELAY \
    -clock $CLOCK_NAME \
    [all_outputs]


# UART RX asynchronous input
#
# 2-FF synchronizer 확인 전에는 false path 적용하지 않음
if {$RX_SYNC_CONFIRMED} {

    set_false_path \
        -from [get_ports $UART_RX_PORT]

    puts "INFO : false path on $UART_RX_PORT"

} else {

    puts "WARN : $UART_RX_PORT false path skipped (RX_SYNC_CONFIRMED = 0)"
}


report_clocks > reports/uart_clocks.rpt


# ------------------------------------------------------------
# Synthesis
# ------------------------------------------------------------

puts ""
puts {[6] SYNTHESIS}
puts "----------------------------------------"

syn_generic
syn_map
syn_opt


# ------------------------------------------------------------
# Reports
# ------------------------------------------------------------

puts ""
puts {[7] REPORTS}
puts "----------------------------------------"

report_timing > reports/uart_timing.rpt
report_area   > reports/uart_area.rpt
report_power  > reports/uart_power.rpt
report_gates  > reports/uart_gates.rpt
report_qor    > reports/uart_qor.rpt

check_design -all > reports/uart_check_design.rpt


# ------------------------------------------------------------
# Netlist / SDC
# ------------------------------------------------------------

puts ""
puts {[8] OUTPUT}
puts "----------------------------------------"

write_hdl > outputs/uart_apb_netlist.v
write_sdc > outputs/uart_apb_syn.sdc


puts ""
puts "========================================"
puts " UART V3 SYNTHESIS FLOW COMPLETE"
puts "========================================"

puts "Next:"
puts "  tclsh parse_timing_report.tcl reports/uart_timing.rpt"
puts "  tclsh parse_area_report.tcl   reports/uart_area.rpt"

exit
