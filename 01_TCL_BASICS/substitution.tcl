puts "========================================"
puts " Tcl Substitution Practice"
puts "========================================"

set design "UART"
set period 8

puts ""
puts "1. Variable substitution"
puts "Design = $design"

puts ""
puts "2. Brace grouping"
puts {Design = $design}

puts ""
puts "3. Command substitution"
puts "Clock Frequency = [expr {1000.0 / $period}] MHz"

puts ""
puts "4. Nested command"
set frequency [expr {1000.0 / $period}]
puts "Frequency = $frequency MHz"

