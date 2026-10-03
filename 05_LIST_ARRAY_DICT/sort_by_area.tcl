set blocks {
    NAND2X1
    NOR2X1
    INVX1
    DFFRX1
}

set block_area(NAND2X1) 2.5
set block_area(NOR2X1)  2.8
set block_area(INVX1)   1.2
set block_area(DFFRX1)  5.2

proc compare_area {a b} {

    global block_area

    if {$block_area($a) < $block_area($b)} {
        return -1
    }

    if {$block_area($a) > $block_area($b)} {
        return 1
    }

    return 0
}

set sorted_blocks [lsort -command compare_area $blocks]

puts "========================================"
puts " Block Area Sorting"
puts "========================================"

foreach block $sorted_blocks {
    puts "$block : $block_area($block)"
}
