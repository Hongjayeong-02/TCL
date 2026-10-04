# ============================================================
# Lab 7-1 : Sort Cells by Area
#
# 목표
#   Stage 1 : 이름 기준으로 area 정렬
#   Stage 2 : info exists로 area 없는 셀 제외
#   Stage 3 : {name area} 형태의 pair 반환
#   Stage 4 : hierarchy별 total area 계산
# ============================================================


# ------------------------------------------------------------
# Test Data
# ------------------------------------------------------------

set decoder {
    NAND2X1
    NOR2X1
    INVX1
    DFFRX1
    BUF_UNKNOWN
}

set block_area(NAND2X1) 2.5
set block_area(NOR2X1)  2.8
set block_area(INVX1)   1.2
set block_area(DFFRX1)  5.2


# ------------------------------------------------------------
# Stage 1
# Cell name list를 area 기준으로 정렬
# ------------------------------------------------------------

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


proc sort_by_area {cell_list} {

    global block_area

    set valid_cells {}

    foreach cell $cell_list {

        # area 정보가 있는 cell만 사용
        if {[info exists block_area($cell)]} {
            lappend valid_cells $cell
        } else {
            puts "WARNING : area not found for $cell"
        }
    }

    return [lsort -command compare_area $valid_cells]
}


# ------------------------------------------------------------
# Stage 2 / 3
# {name area} pair를 반환
#
# 예:
# {
#   {INVX1 1.2}
#   {NAND2X1 2.5}
#   ...
# }
# ------------------------------------------------------------

proc compare_area_pair {a b} {

    set area_a [lindex $a 1]
    set area_b [lindex $b 1]

    if {$area_a < $area_b} {
        return -1
    }

    if {$area_a > $area_b} {
        return 1
    }

    return 0
}


proc sort_by_area2 {cell_list} {

    global block_area

    set result {}

    foreach cell $cell_list {

        if {![info exists block_area($cell)]} {
            puts "WARNING : skip $cell (area does not exist)"
            continue
        }

        lappend result [list $cell $block_area($cell)]
    }

    return [lsort -command compare_area_pair $result]
}


# ------------------------------------------------------------
# Stage 4
# Hierarchy별 total area 계산
# ------------------------------------------------------------

proc total_area {cell_list} {

    global block_area

    set total 0.0

    foreach cell $cell_list {

        if {![info exists block_area($cell)]} {
            puts "WARNING : skip $cell in total_area"
            continue
        }

        set total [expr {$total + $block_area($cell)}]
    }

    return $total
}


# ------------------------------------------------------------
# Hierarchy Test Data
# ------------------------------------------------------------

set hierarchy(uart_tx) {
    DFFRX1
    NAND2X1
    INVX1
}

set hierarchy(uart_rx) {
    DFFRX1
    NOR2X1
    INVX1
    INVX1
}

set hierarchy(uart_irq) {
    NAND2X1
    NOR2X1
}


# ------------------------------------------------------------
# Test
# ------------------------------------------------------------

puts "========================================"
puts " Lab 7-1 : Sort Cells by Area"
puts "========================================"


puts ""
puts "Stage 1 : sort_by_area"
puts "----------------------------------------"

set sorted_cells [sort_by_area $decoder]

foreach cell $sorted_cells {
    puts [format "%-12s : %5.2f" \
        $cell \
        $block_area($cell)]
}


puts ""
puts "Stage 2 / 3 : sort_by_area2"
puts "----------------------------------------"

set sorted_pairs [sort_by_area2 $decoder]

foreach pair $sorted_pairs {

    set name [lindex $pair 0]
    set area [lindex $pair 1]

    puts [format "%-12s : %5.2f" $name $area]
}


puts ""
puts "Returned list:"
puts $sorted_pairs


puts ""
puts "Stage 4 : Hierarchical Total Area"
puts "----------------------------------------"

foreach module [lsort [array names hierarchy]] {

    set area [total_area $hierarchy($module)]

    puts [format "%-12s : %5.2f" $module $area]
}
