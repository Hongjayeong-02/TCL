puts "========================================"
puts " EDA PROJECT SETUP"
puts "========================================"

set DESIGN "cmsdk_mcu"

set CLOCK_PERIOD 8.0

set RTL_PATH "../RTL"
set REPORT_PATH "./reports"

set CLOCK_FREQ [expr {1000.0 / $CLOCK_PERIOD}]

puts "Design          : $DESIGN"
puts "Clock Period    : $CLOCK_PERIOD ns"
puts "Clock Frequency : $CLOCK_FREQ MHz"

if {![file exists $REPORT_PATH]} {

    file mkdir $REPORT_PATH

    puts "Create report directory : $REPORT_PATH"

} else {

    puts "Report directory already exists"
}
