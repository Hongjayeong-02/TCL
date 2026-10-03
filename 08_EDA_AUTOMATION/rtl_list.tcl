set RTL_LIST {
    uart_baud_gen.v
    uart_tx.v
    uart_rx.v
    uart_core.v
}

puts "========================================"
puts " UART RTL FILE LIST"
puts "========================================"

foreach rtl $RTL_LIST {

    puts "RTL : $rtl"
}

puts ""
puts "RTL Count = [llength $RTL_LIST]"
