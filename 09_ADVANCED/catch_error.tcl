# ============================================================
# catch_error.tcl
#
# Tcl error handling practice
#
# 목표
#   - error 발생시키기
#   - catch로 오류 처리
#   - return code / message 확인
#   - EDA automation에서 파일/명령 실패 처리
# ============================================================


puts "========================================"
puts " Tcl catch / error"
puts "========================================"


# ------------------------------------------------------------
# Stage 1
# Basic error
# ------------------------------------------------------------

proc divide {a b} {

    if {$b == 0} {
        error "division by zero is not allowed"
    }

    return [expr {$a / double($b)}]
}


puts ""
puts "Stage 1 : catch basic"
puts "----------------------------------------"

set code [catch {
    divide 10 2
} result]

puts "return code : $code"
puts "result      : $result"


# ------------------------------------------------------------
# Stage 2
# Catch actual error
# ------------------------------------------------------------

puts ""
puts "Stage 2 : catch error"
puts "----------------------------------------"

set code [catch {
    divide 10 0
} result]

puts "return code : $code"
puts "message     : $result"


# ------------------------------------------------------------
# Stage 3
# File check with error
# ------------------------------------------------------------

proc require_file {filename} {

    if {![file exists $filename]} {
        error "required file not found: $filename"
    }

    return $filename
}


puts ""
puts "Stage 3 : file error handling"
puts "----------------------------------------"

set code [catch {
    require_file "catch_error.tcl"
} result]

if {$code == 0} {
    puts "PASS : $result"
} else {
    puts "FAIL : $result"
}


set code [catch {
    require_file "missing_rtl.v"
} result]

if {$code == 0} {
    puts "PASS : $result"
} else {
    puts "WARN : $result"
}


# ------------------------------------------------------------
# Stage 4
# EDA-style command wrapper
# ------------------------------------------------------------

proc run_safe {description command} {

    puts ""
    puts "TASK : $description"

    set code [catch {
        uplevel 1 $command
    } result options]

    if {$code == 0} {

        puts "RESULT : PASS"

        return $result

    } else {

        puts "RESULT : FAIL"
        puts "ERROR  : $result"

        return ""
    }
}


puts ""
puts "Stage 4 : safe command wrapper"
puts "----------------------------------------"

set rtl_list {
    uart_tx.v
    uart_rx.v
    uart_core.v
}

set count [run_safe \
    "Count RTL files" \
    {llength $rtl_list}]

puts "RTL file count = $count"


run_safe \
    "Open missing synthesis report" \
    {
        set fp [open "missing_report.rpt" r]
        close $fp
    }


# ------------------------------------------------------------
# Stage 5
# Summary
# ------------------------------------------------------------

puts ""
puts "Stage 5 : summary"
puts "----------------------------------------"

puts "catch return code 0 = success"
puts "catch return code 1 = Tcl error"
puts "error command        = explicitly raise an error"
