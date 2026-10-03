puts "========================================"
puts " Hex String to ASCII"
puts "========================================"

set hex_string "55415254"

set result ""

for {set i 0} {$i < [string length $hex_string]} {incr i 2} {

    set hex_char [string range $hex_string $i [expr {$i + 1}]]

    set ascii_char [format "%c" "0x$hex_char"]

    append result $ascii_char
}

puts "HEX   : $hex_string"
puts "ASCII : $result"
