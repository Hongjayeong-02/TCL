# ============================================================
# parse_timing_report.tcl
#
# Genus timing report parser
#
# 목적
#   - timing report 에서 path 별 slack 추출
#   - WNS (worst negative slack) / TNS (total negative slack) 계산
#   - WNS >= 0 : PASS,  WNS < 0 : FAIL
#
# 지원 형식 (위에서부터 우선 적용)
#   1) Genus path header   : Path 1: MET (15234 ps) Setup Check with Pin ...
#                            Path 2: VIOLATED (-120 ps) Setup Check ...
#   2) Genus slack line    : Slack:=   15234           (단위 ps)
#   3) 일반 형식           : slack (MET) 0.21          (단위 ns 로 가정)
#
#   Genus report 의 slack 단위는 ps → 출력은 ns 로 통일
#
# 실행
#   tclsh parse_timing_report.tcl <timing_report>
#
# 종료 코드
#   0 : PASS,  2 : timing violation,  1 : 사용법 / 파일 / 파싱 오류
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
# Parse
#   paths : {{slack_ns endpoint} ...}
# ------------------------------------------------------------

set paths  {}
set format ""
set lines  [split $report_data "\n"]


# ---- 1) Genus path header + Endpoint ----

set cur_slack ""
set cur_ep    ""

foreach line $lines {

    if {[regexp {^\s*Path\s+\d+:\s+(?:MET|VIOLATED)\s+\(\s*(-?[0-9.]+)\s*ps\)} \
            $line -> slack_ps]} {

        if {$cur_slack ne ""} {
            lappend paths [list $cur_slack $cur_ep]
        }

        set cur_slack [expr {$slack_ps / 1000.0}]
        set cur_ep    ""

    } elseif {$cur_slack ne "" && \
              [regexp {^\s*Endpoint:\s+\([RF]\)\s+(\S+)} $line -> ep]} {

        set cur_ep $ep
    }
}

if {$cur_slack ne ""} {
    lappend paths [list $cur_slack $cur_ep]
    set format "Genus path header (ps)"
}


# ---- 2) Genus "Slack:=" line ----

if {[llength $paths] == 0} {

    foreach line $lines {

        if {[regexp {Slack\s*:=\s*(-?[0-9.]+)} $line -> slack_ps]} {
            lappend paths [list [expr {$slack_ps / 1000.0}] ""]
        }
    }

    if {[llength $paths]} {
        set format "Genus Slack:= (ps)"
    }
}


# ---- 3) 일반 형식 : slack (MET) 0.21 / Slack: -0.15 ----

if {[llength $paths] == 0} {

    foreach line $lines {

        if {[regexp -nocase \
                {slack(?:\s+\([^)]+\))?\s*[:=]?\s*(-?[0-9]+(?:\.[0-9]+)?)} \
                $line -> slack_ns]} {

            lappend paths [list $slack_ns ""]
        }
    }

    if {[llength $paths]} {
        set format "generic slack (ns)"
    }
}


# ------------------------------------------------------------
# Result check
# ------------------------------------------------------------

puts ""
puts {[1] SLACK SEARCH}
puts "----------------------------------------"

if {[llength $paths] == 0} {

    puts "FAIL : no slack value found"

    exit 1
}

puts "FORMAT : $format"
puts "PATHS  : [llength $paths]"
puts ""

foreach p $paths {

    lassign $p slack ep

    puts [format "SLACK : %8.3f ns  %s" $slack $ep]
}


# ------------------------------------------------------------
# WNS / TNS
#   lsort -real -index 0 : slack 오름차순 → 첫 번째가 worst
# ------------------------------------------------------------

set sorted [lsort -real -index 0 $paths]

lassign [lindex $sorted 0] worst_slack worst_ep

set tns 0.0
set violated 0

foreach p $paths {

    set s [lindex $p 0]

    if {$s < 0} {

        set tns [expr {$tns + $s}]
        incr violated
    }
}


puts ""
puts {[2] WORST SLACK}
puts "----------------------------------------"

puts [format "WNS      : %.3f ns" $worst_slack]
puts [format "TNS      : %.3f ns" $tns]
puts "VIOLATED : $violated / [llength $paths] paths"

if {$worst_ep ne ""} {
    puts "WORST EP : $worst_ep"
}


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
