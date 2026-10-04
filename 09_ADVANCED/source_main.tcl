# ============================================================
# source_main.tcl
#
# Tcl source command practice
#
# 목표
#   - 외부 Tcl 파일 로드
#   - configuration 분리
#   - synthesis script 구조화
# ============================================================


puts "========================================"
puts " Tcl source Structure"
puts "========================================"


# ------------------------------------------------------------
# Stage 1
# config file 확인
# ------------------------------------------------------------

set config_file "./config.tcl"

if {![file exists $config_file]} {
    error "Configuration file not found: $config_file"
}


# ------------------------------------------------------------
# Stage 2
# source
# ------------------------------------------------------------

puts ""
puts "Stage 1 : source configuration"
puts "----------------------------------------"

source $config_file

puts "Loaded : $config_file"


# ------------------------------------------------------------
# Stage 3
# sourced variables 사용
# ------------------------------------------------------------

puts ""
puts "Stage 2 : configuration"
puts "----------------------------------------"

puts "TOP_DESIGN   : $TOP_DESIGN"
puts "CLOCK_PERIOD : $CLOCK_PERIOD ns"


# ------------------------------------------------------------
# Stage 4
# RTL list 확인
# ------------------------------------------------------------

puts ""
puts "Stage 3 : RTL list"
puts "----------------------------------------"

foreach rtl $RTL_LIST {
    puts "  $rtl"
}


# ------------------------------------------------------------
# Stage 5
# EDA-style derived configuration
# ------------------------------------------------------------

puts ""
puts "Stage 4 : derived information"
puts "----------------------------------------"

set RTL_COUNT [llength $RTL_LIST]
set CLOCK_FREQ_MHZ [expr {1000.0 / $CLOCK_PERIOD}]

puts "RTL count  : $RTL_COUNT"
puts "Clock freq : [format %.2f $CLOCK_FREQ_MHZ] MHz"


# ------------------------------------------------------------
# Stage 6
# synthesis flow concept
# ------------------------------------------------------------

puts ""
puts "Stage 5 : synthesis flow concept"
puts "----------------------------------------"

puts "source config.tcl"
puts "       ↓"
puts "project variables loaded"
puts "       ↓"
puts "read_hdl \$RTL_LIST"
puts "       ↓"
puts "elaborate \$TOP_DESIGN"
