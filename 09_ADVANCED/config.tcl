# ============================================================
# config.tcl
#
# Shared configuration for source example
# ============================================================

set TOP_DESIGN uart_apb
set CLOCK_PERIOD 20.0

set RTL_LIST {
    uart_baud_gen.v
    uart_tx.v
    uart_tx_fifo.v
    uart_rx.v
    uart_rx_fifo.v
    uart_core.v
    uart_irq.v
    uart_apb.v
}
