puts "========================================"
puts " Tcl Array Practice"
puts "========================================"

set block_area(NAND2X1) 2.5
set block_area(NOR2X1)  2.8
set block_area(DFFRX1)  5.2

puts "NAND2X1 Area = $block_area(NAND2X1)"
puts "NOR2X1 Area  = $block_area(NOR2X1)"
puts "DFFRX1 Area  = $block_area(DFFRX1)"

puts ""
puts "--- ARRAY LOOP ---"

foreach cell [array names block_area] {
    puts "$cell = $block_area($cell)"
}
