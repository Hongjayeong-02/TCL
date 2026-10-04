# ============================================================
# parse_timing_report.tcl
#
# Genus timing report parser
#
# 목적
#   - timing report에서 slack / WNS 값 추출
#   - 최악의 slack 계산
#   - slack >= 0 : PASS
#   - slack < 0  : FAIL
#
# 실행
#   tclsh parse_timing_report.tcl <timing_report>
# ============================================================


puts "========================================"
puts " Genus Timing Report Parser"
puts "========================================"


# ------------------------------------------------------------
# Argument check
# ------------------------------------------------------------

if {$argc != 1} {

    puts ""
    puts "Usage:"
    puts "  tclsh parse_timing_report.tcl <timing_report>"

    exit 1
}


set report_file [lindex $argv 0]


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
# Parse slack values
#
# 지원 예:
#
# slack          1.23
# Slack:        -0.15
# slack (MET)    0.42
# slack (VIOLATED) -0.08
# ------------------------------------------------------------

set slack_values {}

foreach line [split $report_data "\n"] {

    if {[regexp -nocase \
        {slack(?:\s+\([^)]+\))?\s*[:=]?\s*(-?[0-9]+(?:\.[0-9]+)?)} \
        $line -> slack]} {

        lappend slack_values $slack
    }
}


# ------------------------------------------------------------
# Result check
# ------------------------------------------------------------

puts ""
puts {[1] SLACK SEARCH}
puts "----------------------------------------"


if {[llength $slack_values] == 0} {

    puts "FAIL : no slack value found"

    exit 1
}


foreach value $slack_values {
    puts "SLACK : $value ns"
}


# ------------------------------------------------------------
# Find worst slack
# ------------------------------------------------------------

set worst_slack [lindex $slack_values 0]

foreach value $slack_values {

    if {$value < $worst_slack} {
        set worst_slack $value
    }
}


puts ""
puts {[2] WORST SLACK}
puts "----------------------------------------"

puts [format "WNS : %.3f ns" $worst_slack]


# ------------------------------------------------------------
# PASS / FAIL
# ------------------------------------------------------------

puts ""
puts {[3] TIMING RESULT}
puts "----------------------------------------"


if {$worst_slack >= 0.0} {

    puts "RESULT : PASS"
    puts "Timing constraint is satisfied."

    exit 0

} else {

    puts "RESULT : FAIL"
    puts "Timing violation detected."

    exit 2
}
