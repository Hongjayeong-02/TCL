set cells {
    NAND2X1
    NOR2X1
    INV
    DFFRX1
}

foreach cell $cells {

    if {$cell == "INV"} {
        continue
    }

    puts "Processing : $cell"

    if {$cell == "DFFRX1"} {
        break
    }
}
