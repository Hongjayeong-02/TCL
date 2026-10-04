# ============================================================
# namespace_basic.tcl
#
# Tcl namespace practice
#
# 목표
#   - namespace 생성
#   - namespace variable 사용
#   - namespace procedure 사용
#   - EDA project configuration을 scope별로 분리
# ============================================================


puts "========================================"
puts " Tcl Namespace Basic"
puts "========================================"


# ------------------------------------------------------------
# Stage 1
# Basic namespace
# ------------------------------------------------------------

namespace eval UART {

    variable TOP uart_apb
    variable CLOCK_MHZ 50
    variable BAUD_DIV 325

    proc show_config {} {

        variable TOP
        variable CLOCK_MHZ
        variable BAUD_DIV

        puts "TOP       : $TOP"
        puts "CLOCK_MHZ : $CLOCK_MHZ"
        puts "BAUD_DIV  : $BAUD_DIV"
    }
}


puts ""
puts "Stage 1 : namespace basic"
puts "----------------------------------------"

UART::show_config


# ------------------------------------------------------------
# Stage 2
# Separate synthesis configuration
# ------------------------------------------------------------

namespace eval SYN {

    variable LIBRARY slow_vdd1v0_basicCells.lib
    variable CORNER slow
    variable PERIOD 20.0

    proc show_config {} {

        variable LIBRARY
        variable CORNER
        variable PERIOD

        puts "LIBRARY : $LIBRARY"
        puts "CORNER  : $CORNER"
        puts "PERIOD  : $PERIOD ns"
    }
}


puts ""
puts "Stage 2 : synthesis namespace"
puts "----------------------------------------"

SYN::show_config


# ------------------------------------------------------------
# Stage 3
# namespace variable access
# ------------------------------------------------------------

puts ""
puts "Stage 3 : access namespace variables"
puts "----------------------------------------"

puts "UART TOP     = $UART::TOP"
puts "SYN LIBRARY  = $SYN::LIBRARY"


# ------------------------------------------------------------
# Stage 4
# namespace procedure for reusable checks
# ------------------------------------------------------------

namespace eval CHECK {

    proc file_exists {filename} {

        if {[file exists $filename]} {
            return 1
        }

        return 0
    }


    proc print_result {filename} {

        if {[file_exists $filename]} {
            puts "PASS : $filename"
        } else {
            puts "WARN : $filename not found"
        }
    }
}


puts ""
puts "Stage 4 : namespace procedure"
puts "----------------------------------------"

CHECK::print_result "namespace_basic.tcl"
CHECK::print_result "not_exist.tcl"


# ------------------------------------------------------------
# Stage 5
# namespace children
# ------------------------------------------------------------

puts ""
puts "Stage 5 : namespace list"
puts "----------------------------------------"

foreach ns [namespace children ::] {

    if {$ns eq "::UART" ||
        $ns eq "::SYN" ||
        $ns eq "::CHECK"} {

        puts $ns
    }
}
