# ============================================================
# parse_area_report.tcl
#
# Genus area report parser
#
# 목적
#   - area report 에서 top total area 추출
#   - hierarchy 별 면적 / 비율 출력
#   - optional area limit 과 비교 → PASS / FAIL
#
# 지원 형식 (위에서부터 우선 적용)
#   1) Genus report_area 표
#        Instance  Module  Cell Count  Cell Area  Net Area  Total Area  Wireload
#      ----------------------------------------------------------------------
#      uart_apb               612   1890.234   0.000   1890.234  <none> (D)
#        u_core   uart_core   451   1402.110   0.000   1402.110  <none> (D)
#      (들여쓰기 2칸 = hierarchy 1단계, top 은 Module 칸이 비어 있음)
#
#   2) 일반 형식 : Total cell area: 935.60
#
# 실행
#   tclsh parse_area_report.tcl <area_report>
#   tclsh parse_area_report.tcl <area_report> <area_limit>
#
# 종료 코드
#   0 : PASS / INFO
#   2 : area limit 초과
#   1 : 사용법 / 파일 / 파싱 오류
# ============================================================


puts "========================================"
puts " Genus Area Report Parser"
puts "========================================"


# ------------------------------------------------------------
# Argument check
# ------------------------------------------------------------

if {$argc < 1 || $argc > 2} {

    puts ""
    puts "Usage:"
    puts "  tclsh parse_area_report.tcl <area_report>"
    puts ""
    puts "Optional limit:"
    puts "  tclsh parse_area_report.tcl <area_report> <area_limit>"

    exit 1
}


set report_file [lindex $argv 0]


if {$argc == 2} {

    set area_limit [lindex $argv 1]

    if {![string is double -strict $area_limit]} {

        puts "ERROR : area_limit must be numeric"

        exit 1
    }

} else {

    set area_limit ""
}


# ------------------------------------------------------------
# File check
# ------------------------------------------------------------

if {![file exists $report_file]} {

    puts ""
    puts "ERROR : report file not found"
    puts "FILE  : $report_file"

    exit 1
}


puts ""
puts "REPORT : $report_file"


# ------------------------------------------------------------
# Read report
# ------------------------------------------------------------

set fp [open $report_file r]
set report_data [read $fp]
close $fp


# ------------------------------------------------------------
# 1) Genus report_area 표
#
# rows:
#   {{instance module depth cell_count total_area} ...}
# ------------------------------------------------------------

set rows {}
set in_table 0

foreach line [split $report_data "\n"] {

    if {!$in_table} {

        # 구분선(-----) 다음 줄부터 표
        if {[regexp {^-{10,}\s*$} $line]} {
            set in_table 1
        }

        continue
    }


    # 빈 줄이 나오면 표 끝
    if {[string trim $line] eq ""} {
        break
    }


    # indent / instance / (module) /
    # count / cell area / net area / total area

    if {[regexp {^(\s*)(\S+)\s+(?:(\S+)\s+)?(\d+)\s+([0-9.]+)\s+([0-9.]+)\s+([0-9.]+)} \
            $line -> indent inst module count cell_area net_area total]} {

        set depth [expr {[string length $indent] / 2}]

        lappend rows [list \
            $inst \
            $module \
            $depth \
            $count \
            $total]
    }
}


set total_area ""
set format     ""


if {[llength $rows] > 0} {

    lassign [lindex $rows 0] \
        top_inst \
        - \
        - \
        top_count \
        total_area

    set format "Genus report_area table"
}


# ------------------------------------------------------------
# 2) 일반 형식 : Total cell area: 1234.56
# ------------------------------------------------------------

if {$total_area eq ""} {

    foreach line [split $report_data "\n"] {

        if {[regexp -nocase \
                {total\s+(?:cell\s+)?area\s*[:=]?\s*([0-9]+(?:\.[0-9]+)?)} \
                $line -> value]} {

            set total_area $value
            set format "generic Total cell area"

            break
        }
    }
}


# ------------------------------------------------------------
# Parsing result
# ------------------------------------------------------------

puts ""
puts {[1] AREA SEARCH}
puts "----------------------------------------"


if {$total_area eq ""} {

    puts "RESULT : FAIL"
    puts "ERROR  : total area not found"

    exit 1
}


puts "FORMAT     : $format"
puts [format "TOTAL AREA : %.3f" $total_area]


# ------------------------------------------------------------
# Hierarchy
#   Genus 표 형식일 때만
# ------------------------------------------------------------

if {[llength $rows] > 0} {

    puts [format "TOP        : %s (%d cells)" \
        $top_inst \
        $top_count]

    puts ""
    puts {[2] HIERARCHY}
    puts "----------------------------------------"

    foreach r $rows {

        lassign $r \
            inst \
            module \
            depth \
            count \
            area

        set name "[string repeat {  } $depth]$inst"

        puts [format \
            "%-22s %-15s %6d %10.3f %6.1f%%" \
            $name \
            $module \
            $count \
            $area \
            [expr {100.0 * $area / $total_area}]]
    }
}


# ------------------------------------------------------------
# Optional area limit check
# ------------------------------------------------------------

puts ""
puts {[3] AREA RESULT}
puts "----------------------------------------"


if {$area_limit eq ""} {

    puts "RESULT : INFO"
    puts "No area limit specified."

    exit 0
}


puts [format "AREA LIMIT : %.3f" $area_limit]


if {$total_area <= $area_limit} {

    puts "RESULT : PASS"
    puts "Area constraint is satisfied."

    exit 0

} else {

    puts "RESULT : FAIL"
    puts "Area limit exceeded."

    exit 2
}
