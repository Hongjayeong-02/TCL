# ============================================================
# argv_basic.tcl
#
# Tcl command-line argument practice
#
# 목표
#   - argc / argv 사용
#   - 인자 개수 검증
#   - EDA script 실행 옵션 전달
# ============================================================


puts "========================================"
puts " Tcl argc / argv"
puts "========================================"


# ------------------------------------------------------------
# Stage 1
# argc / argv 출력
# ------------------------------------------------------------

puts ""
puts "Stage 1 : argument information"
puts "----------------------------------------"

puts "argc = $argc"
puts "argv = $argv"


# ------------------------------------------------------------
# Stage 2
# 인자가 없을 때 usage 출력
# ------------------------------------------------------------

if {$argc == 0} {

    puts ""
    puts "Usage:"
    puts "  tclsh argv_basic.tcl <top_module> <clock_period_ns>"
    puts ""
    puts "Example:"
    puts "  tclsh argv_basic.tcl uart_apb 20.0"

    exit 0
}


# ------------------------------------------------------------
# Stage 3
# 첫 번째 인자
# ------------------------------------------------------------

set top_module [lindex $argv 0]

puts ""
puts "Stage 2 : first argument"
puts "----------------------------------------"

puts "TOP = $top_module"


# ------------------------------------------------------------
# Stage 4
# 두 번째 인자
# ------------------------------------------------------------

if {$argc >= 2} {

    set clock_period [lindex $argv 1]

} else {

    set clock_period 20.0
}


puts ""
puts "Stage 3 : clock period"
puts "----------------------------------------"

puts "CLOCK_PERIOD = $clock_period ns"


# ------------------------------------------------------------
# Stage 5
# argument validation
# ------------------------------------------------------------

puts ""
puts "Stage 4 : validation"
puts "----------------------------------------"

if {![string is double -strict $clock_period]} {

    puts "ERROR : clock period must be numeric"

    exit 1
}


if {$clock_period <= 0} {

    puts "ERROR : clock period must be greater than 0"

    exit 1
}


puts "PASS : arguments are valid"


# ------------------------------------------------------------
# Stage 6
# EDA-style configuration
# ------------------------------------------------------------

puts ""
puts "Stage 5 : synthesis configuration"
puts "----------------------------------------"

set config [dict create \
    top $top_module \
    clock_period $clock_period]


puts "Top design   : [dict get $config top]"
puts "Clock period : [dict get $config clock_period] ns"


# ------------------------------------------------------------
# Stage 7
# Derived clock frequency
# ------------------------------------------------------------

set frequency_mhz [expr {1000.0 / $clock_period}]

puts "Clock freq   : [format %.2f $frequency_mhz] MHz"
