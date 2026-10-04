# ============================================================
# uart_filelist_check.tcl
#
# UART V3 synthesis file-list generator / validator
#
# 목적
#   1. UART V3 synthesis 대상 RTL 목록 정의
#   2. 각 RTL 파일 존재 여부 검사
#   3. missing file이 있으면 FAIL
#   4. synthesis용 filelist_syn.f 자동 생성
#
# 환경변수
#   UART_RTL_PATH
#
# 예:
#   export UART_RTL_PATH=<project>/1_RTL/1_TASK/6_UART_V3/1_rtl
#
# 환경변수가 없으면 fallback:
#   ../1_RTL/1_TASK/6_UART_V3/1_rtl
# ============================================================


puts "========================================"
puts " UART V3 RTL FILELIST CHECK"
puts "========================================"


# ------------------------------------------------------------
# Helper
# ------------------------------------------------------------

proc getenv_or_default {name default_value} {

    if {[info exists ::env($name)]} {
        return $::env($name)
    }

    return $default_value
}


# ------------------------------------------------------------
# RTL Path
# ------------------------------------------------------------

set RTL_PATH [getenv_or_default \
    UART_RTL_PATH \
    "../1_RTL/1_TASK/6_UART_V3/1_rtl"]


puts ""
puts "RTL_PATH : $RTL_PATH"


# ------------------------------------------------------------
# UART V3 Synthesis RTL
#
# Backend Freeze 기준 dependency order
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


# ------------------------------------------------------------
# Check
# ------------------------------------------------------------

puts ""
puts {[1] RTL FILE CHECK}
puts "----------------------------------------"

set pass_count 0
set fail_count 0
set valid_files {}


foreach rtl $RTL_LIST {

    set full_path [file join $RTL_PATH $rtl]

    if {[file exists $full_path]} {

        puts "PASS : $rtl"

        incr pass_count

        lappend valid_files $rtl
	   } else {

        puts "FAIL : $rtl"

        incr fail_count
    }
}


# ------------------------------------------------------------
# Summary
# ------------------------------------------------------------

puts ""
puts {[2] SUMMARY}
puts "----------------------------------------"

puts "PASS : $pass_count"
puts "FAIL : $fail_count"


if {$fail_count > 0} {

    puts ""
    puts "RESULT : FAIL"
    puts "File list is NOT generated."

    exit 1
}


# ------------------------------------------------------------
# Generate synthesis file list
# ------------------------------------------------------------

set output_file "filelist_syn.f"

set fp [open $output_file w]

foreach rtl $valid_files {
    puts $fp $rtl
}

close $fp


# ------------------------------------------------------------
# Output
# ------------------------------------------------------------

puts ""
puts {[3] FILELIST GENERATION}
puts "----------------------------------------"

puts "OUTPUT : $output_file"

puts ""
puts "Generated RTL list:"

foreach rtl $valid_files {
    puts "  $rtl"
}


puts ""
puts "========================================"
puts " RESULT : PASS"
puts "========================================"
