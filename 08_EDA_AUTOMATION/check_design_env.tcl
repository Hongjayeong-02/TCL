puts "========================================"
puts " ASIC DESIGN ENVIRONMENT CHECK"
puts "========================================"

# --------------------------------------------------
# Project Paths
# --------------------------------------------------

set RTL_PATH    "/home/hah006/PROJ1/proj1_make/TOP/RTL"
set SDC_PATH "/home/hah006/SoC/SoC_make_G45/TOP/SYN/cons/cmsdk_mcu.sdc"
set LIB_PATH    "/GPDK045/digital/gsclib045_all_v4.4/gsclib045/timing"

# --------------------------------------------------
# Library List
# --------------------------------------------------

set LIB_LIST {
    fast_vdd1v0_basicCells.lib
    fast_vdd1v2_basicCells.lib
    slow_vdd1v0_basicCells.lib
    slow_vdd1v2_basicCells.lib
}

# --------------------------------------------------
# RTL Directory Check
# --------------------------------------------------

puts ""
puts "\[1\] RTL PATH"

if {[file isdirectory $RTL_PATH]} {
    puts "PASS : $RTL_PATH"
} else {
    puts "FAIL : $RTL_PATH"
}

# --------------------------------------------------
# SDC Check
# --------------------------------------------------

puts ""
puts "\[2\] SDC"

if {[file exists $SDC_PATH]} {
    puts "PASS : $SDC_PATH"
} else {
    puts "FAIL : $SDC_PATH"
}

# --------------------------------------------------
# Library Check
# --------------------------------------------------

puts ""
puts "\[3\] STANDARD CELL LIBRARY"

foreach lib $LIB_LIST {

    set full_path "$LIB_PATH/$lib"

    if {[file exists $full_path]} {
        puts "PASS : $lib"
    } else {
        puts "FAIL : $lib"
    }
}

# --------------------------------------------------
# Tool Check
# --------------------------------------------------

puts ""
puts "\[4\] EDA TOOL"

set genus_path [auto_execok genus]

if {$genus_path ne ""} {
    puts "PASS : genus = $genus_path"
} else {
    puts "FAIL : genus command not found"
}

puts ""
puts "========================================"
puts " CHECK COMPLETE"
puts "========================================"
