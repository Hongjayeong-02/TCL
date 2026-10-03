set LIB_LIST {
    fast_vdd1v0_basicCells.lib
    fast_vdd1v2_basicCells.lib
    slow_vdd1v0_basicCells.lib
    slow_vdd1v2_basicCells.lib
}

puts "========================================"
puts " LIBRARY CORNER LIST"
puts "========================================"

set index 0

foreach lib $LIB_LIST {

    incr index

    puts "$index : $lib"
}

puts ""
puts "Total Corner = [llength $LIB_LIST]"
