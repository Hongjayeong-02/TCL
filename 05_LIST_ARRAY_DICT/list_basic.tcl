puts "========================================"
puts " Tcl List Practice"
puts "========================================"

set RTL_LIST {
    uart_baud_gen.v
    uart_tx.v
    uart_rx.v
    uart_core.v
}

puts "RTL_LIST = $RTL_LIST"

puts ""
puts "Number of RTL files = [llength $RTL_LIST]"

puts ""
puts "First RTL file = [lindex $RTL_LIST 0]"

puts ""
puts "--- foreach ---"

foreach rtl $RTL_LIST {
    puts "RTL : $rtl"
}
