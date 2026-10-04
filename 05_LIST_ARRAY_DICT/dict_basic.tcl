# ============================================================
# dict_basic.tcl
#
# Tcl dict practice for EDA-style data handling
#
# 목표
#   - dict 생성
#   - dict get / exists / set
#   - foreach로 key-value 순회
#   - cell/library 정보를 구조적으로 관리
# ============================================================


puts "========================================"
puts " Tcl Dictionary Basic"
puts "========================================"


# ------------------------------------------------------------
# Stage 1
# 기본 dict 생성
# ------------------------------------------------------------

set cell_info [dict create \
    name NAND2X1 \
    area 2.50 \
    corner slow \
    voltage 0.9 \
    temperature 125]

puts ""
puts "Stage 1 : Basic dict"
puts "----------------------------------------"

puts "name        : [dict get $cell_info name]"
puts "area        : [dict get $cell_info area]"
puts "corner      : [dict get $cell_info corner]"
puts "voltage     : [dict get $cell_info voltage]"
puts "temperature : [dict get $cell_info temperature]"


# ------------------------------------------------------------
# Stage 2
# dict exists
# ------------------------------------------------------------

puts ""
puts "Stage 2 : dict exists"
puts "----------------------------------------"

if {[dict exists $cell_info area]} {
    puts "PASS : area key exists"
} else {
    puts "FAIL : area key not found"
}

if {[dict exists $cell_info leakage]} {
    puts "PASS : leakage key exists"
} else {
    puts "INFO : leakage key not defined"
}


# ------------------------------------------------------------
# Stage 3
# dict set
# ------------------------------------------------------------

puts ""
puts "Stage 3 : dict set"
puts "----------------------------------------"

dict set cell_info leakage 39.0345
dict set cell_info library slow_vdd1v0_basicCells.lib

puts "leakage : [dict get $cell_info leakage]"
puts "library : [dict get $cell_info library]"


# ------------------------------------------------------------
# Stage 4
# dict 순회
# ------------------------------------------------------------

puts ""
puts "Stage 4 : iterate dictionary"
puts "----------------------------------------"

dict for {key value} $cell_info {
    puts [format "%-12s : %s" $key $value]
}


# ------------------------------------------------------------
# Stage 5
# 여러 cell을 nested dict로 관리
# ------------------------------------------------------------

puts ""
puts "Stage 5 : nested dict for cell database"
puts "----------------------------------------"

set cells {}

dict set cells NAND2X1 area 2.50
dict set cells NAND2X1 type combinational

dict set cells NOR2X1 area 2.80
dict set cells NOR2X1 type combinational

dict set cells INVX1 area 1.20
dict set cells INVX1 type combinational

dict set cells DFFRX1 area 5.20
dict set cells DFFRX1 type sequential


foreach cell [dict keys $cells] {

    set area [dict get $cells $cell area]
    set type [dict get $cells $cell type]

    puts [format "%-10s area=%5.2f type=%s" \
        $cell \
        $area \
        $type]
}


# ------------------------------------------------------------
# Stage 6
# Total area 계산
# ------------------------------------------------------------

puts ""
puts "Stage 6 : total area"
puts "----------------------------------------"

set total_area 0.0

foreach cell [dict keys $cells] {

    set area [dict get $cells $cell area]

    set total_area [expr {$total_area + $area}]
}

puts [format "Total area : %.2f" $total_area]
