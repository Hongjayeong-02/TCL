# ============================================================
# check_design_env.tcl
#
# ASIC design environment checker
#
# Personal server paths are NOT hard-coded.
# Required project paths are supplied through environment
# variables or portable fallback paths.
# ============================================================


puts "========================================"
puts " ASIC DESIGN ENVIRONMENT CHECK"
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
# Project Paths
# ------------------------------------------------------------

set RTL_PATH [getenv_or_default RTL_PATH "../RTL"]

set SDC_PATH [getenv_or_default \
    SDC_PATH \
    "./cons/design.sdc"]

set LIB_PATH [getenv_or_default \
    PDK_LIB_DIR \
    "./lib"]


# ------------------------------------------------------------
# Library List
# ------------------------------------------------------------

set LIB_LIST {
    fast_vdd1v0_basicCells.lib
    fast_vdd1v2_basicCells.lib
    slow_vdd1v0_basicCells.lib
    slow_vdd1v2_basicCells.lib
}


# ------------------------------------------------------------
# Print Current Configuration
# ------------------------------------------------------------

puts ""
puts "Configuration"

puts "RTL_PATH    : $RTL_PATH"
puts "SDC_PATH    : $SDC_PATH"
puts "PDK_LIB_DIR : $LIB_PATH"


# ------------------------------------------------------------
# Result Counter
# ------------------------------------------------------------

set pass_count 0
set warn_count 0


# ------------------------------------------------------------
# RTL Directory Check
# ------------------------------------------------------------

puts ""
puts "\[1\] RTL PATH"

if {[file isdirectory $RTL_PATH]} {

    puts "PASS : RTL directory exists"
    incr pass_count

} else {

    puts "WARN : RTL directory not found"
    incr warn_count
}


# ------------------------------------------------------------
# SDC Check
# ------------------------------------------------------------

puts ""
puts "\[2\] SDC"

if {[file exists $SDC_PATH]} {

    puts "PASS : SDC file exists"
    incr pass_count

} else {

    puts "WARN : SDC file not found"
    incr warn_count
}


# ------------------------------------------------------------
# Standard Cell Library Check
# ------------------------------------------------------------

puts ""
puts "\[3\] STANDARD CELL LIBRARY"

foreach lib $LIB_LIST {

    set full_path [file join $LIB_PATH $lib]

    if {[file exists $full_path]} {

        puts "PASS : $lib"
        incr pass_count

    } else {

        puts "WARN : $lib not found"
        incr warn_count
    }
}


# ------------------------------------------------------------
# EDA Tool Check
# ------------------------------------------------------------

puts ""
puts "\[4\] EDA TOOL"

set genus_path [auto_execok genus]

if {$genus_path ne ""} {

    puts "PASS : genus command found"
    incr pass_count

} else {

    puts "WARN : genus command not found"
    incr warn_count
}


# ------------------------------------------------------------
# Summary
# ------------------------------------------------------------

puts ""
puts "========================================"
puts " CHECK SUMMARY"
puts "========================================"

puts "PASS : $pass_count"
puts "WARN : $warn_count"

if {$warn_count == 0} {

    puts "RESULT : PASS"

} else {

    puts "RESULT : CHECK ENVIRONMENT VARIABLES"
}

puts "========================================"
