puts "========================================"
puts " Tcl File Read"
puts "========================================"

set fid [open "timing_report.txt" r]

while {[gets $fid line] >= 0} {

    puts $line
}

close $fid
