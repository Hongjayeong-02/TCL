puts "========================================"
puts " Tcl File Write"
puts "========================================"

set fid [open "timing_report.txt" w]

puts $fid "Design : CMSDK_MCU"
puts $fid "Clock  : 125 MHz"
puts $fid "Period : 8 ns"
puts $fid "Status : PASS"

close $fid

puts "timing_report.txt created."
