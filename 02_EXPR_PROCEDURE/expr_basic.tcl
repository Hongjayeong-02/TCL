puts "========================================"
puts " Tcl Expression Practice"
puts "========================================"

set a 10
set b 3

puts "a = $a"
puts "b = $b"

puts "a + b = [expr {$a + $b}]"
puts "a - b = [expr {$a - $b}]"
puts "a * b = [expr {$a * $b}]"
puts "a / b = [expr {double($a) / $b}]"

puts ""
puts "Bitwise AND   = [expr {$a & $b}]"
puts "Right shift   = [expr {$a >> 1}]"
puts "Left shift    = [expr {$a << 1}]"
