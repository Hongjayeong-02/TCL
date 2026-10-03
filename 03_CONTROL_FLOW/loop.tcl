puts "========================================"
puts " Tcl Loop Practice"
puts "========================================"

puts ""
puts "--- for ---"

for {set i 0} {$i < 5} {incr i} {
    puts "i = $i"
}

puts ""
puts "--- foreach ---"

set corners {
    fast_vdd1v0
    fast_vdd1v2
    slow_vdd1v0
    slow_vdd1v2
}

foreach corner $corners {
    puts "Corner = $corner"
}

puts ""
puts "--- while ---"

set count 0

while {$count < 3} {

    puts "count = $count"

    incr count
}
