puts "========================================"
puts " Tcl String Practice"
puts "========================================"

set text "UART_PERIPHERAL_IP"

puts "String        : $text"
puts "Length        : [string length $text]"
puts "First UART    : [string first UART $text]"
puts "Range 0~3     : [string range $text 0 3]"
puts "Lower case    : [string tolower $text]"
puts "Upper case    : [string toupper $text]"
