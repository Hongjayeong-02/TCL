# ============================================================
# parse_area_report.tcl
#
# Genus area report parser
#
# 목적
#   - area report에서 total cell area 추출
#   - optional area limit과 비교
#   - PASS / FAIL 판정
#
# 실행
#   tclsh parse_area_report.tcl <area_report>
#
# 또는
#   tclsh parse_area_report.tcl <area_report> <area_limit>
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
# Parse total area
#
# 지원 예:
#
# Total cell area: 1234.56
# Total Cell Area = 1234.56
# total area 1234.56
# ------------------------------------------------------------

set total_area ""

foreach line [split $report_data "\n"] {

    if {[regexp -nocase \
        {total\s+(?:cell\s+)?area\s*[:=]?\s*([0-9]+(?:\.[0-9]+)?)} \
        $line -> value]} {

        set total_area $value
        break
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


puts [format "TOTAL AREA : %.3f" $total_area]


# ------------------------------------------------------------
# Optional area limit check
# ------------------------------------------------------------

puts ""
puts {[2] AREA RESULT}
puts "----------------------------------------"


if {$area_limit eq ""} {

    puts "RESULT : INFO"
    puts "No area limit specified."
    puts [format "TOTAL AREA : %.3f" $total_area]

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
