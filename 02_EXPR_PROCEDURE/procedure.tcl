puts "========================================"
puts " Tcl Procedure Practice"
puts "========================================"

proc average {n1 n2 n3 n4} {

    set sum [expr {$n1 + $n2 + $n3 + $n4}]
    set avg [expr {$sum / 4.0}]

    return $avg
}

set result [average 10 20 30 40]

puts "Average = $result"
