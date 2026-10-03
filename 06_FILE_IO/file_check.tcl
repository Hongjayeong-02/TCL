set RTL_LIST {
    uart_baud_gen.v
    uart_tx.v
    uart_rx.v
    uart_core.v
}

foreach rtl $RTL_LIST {

    if {[file exists $rtl]} {

        puts "PASS : $rtl"

    } else {

        puts "FAIL : $rtl"
    }
}
