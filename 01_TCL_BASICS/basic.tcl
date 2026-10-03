puts "=============================="
puts " Tcl Basic Practice"
puts "=============================="

set design "CMSDK_MCU"
set period 8.0
set frequency [expr {1000.0 / $period}]

puts "Design    : $design"
puts "Period    : $period ns"
puts "Frequency : $frequency MHz"
