puts "========================================"
puts " Tcl Regular Expression Practice"
puts "========================================"

set line "Slack : -0.125 ns"

if {[regexp {Slack[ ]*:[ ]*(-?[0-9.]+)} $line match slack]} {

    puts "Matched string : $match"
    puts "Slack value    : $slack"
}
