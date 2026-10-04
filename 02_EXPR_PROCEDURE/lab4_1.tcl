# ============================================================
# Lab 4-1 : Extracting Bits from Integers
#
# 목표
#   0~15 정수를 4-bit binary 문자열로 변환
#
# 예:
#   to_bits 14
#   -> 1110b
#
# 범위 밖 입력:
#   warning 출력 후 빈 문자열 반환
# ============================================================


# ------------------------------------------------------------
# Stage 1
# Bitwise operation으로 직접 bit 추출
# ------------------------------------------------------------

proc stage1_demo {} {

    set a 9

    set b0 [expr {$a & 1}]
    set b1 [expr {($a >> 1) & 1}]
    set b2 [expr {($a >> 2) & 1}]
    set b3 [expr {($a >> 3) & 1}]

    set bits "$b3$b2$b1$b0"

    puts "Stage 1 : $a -> ${bits}b"

    return "${bits}b"
}


# ------------------------------------------------------------
# Stage 2
# Procedure 형태로 일반화
# ------------------------------------------------------------

proc to_bits {a} {

    # 입력값 검사
    if {![string is integer -strict $a]} {
        puts "Warning: integer input required ($a)"
        return ""
    }

    # 4-bit 표현 가능 범위 검사
    if {$a < 0 || $a > 15} {
        puts "Warning: value must be between 0 and 15 ($a)"
        return ""
    }

    set b0 [expr {$a & 1}]
    set b1 [expr {($a >> 1) & 1}]
    set b2 [expr {($a >> 2) & 1}]
    set b3 [expr {($a >> 3) & 1}]

    set bits "$b3$b2$b1$b0"

    return "${bits}b"
}


# ------------------------------------------------------------
# Stage 3
# bit width를 parameter로 확장
#
# 예:
#   to_bits_n 5 8
#   -> 00000101b
# ------------------------------------------------------------

proc to_bits_n {a width} {

    if {![string is integer -strict $a]} {
        puts "Warning: integer input required ($a)"
        return ""
    }

    if {![string is integer -strict $width] || $width <= 0} {
        puts "Warning: width must be a positive integer ($width)"
        return ""
    }

    set max_value [expr {(1 << $width) - 1}]

    if {$a < 0 || $a > $max_value} {
        puts "Warning: value must be between 0 and $max_value ($a)"
        return ""
    }

    set bits ""

    for {set i [expr {$width - 1}]} {$i >= 0} {incr i -1} {

        set bit [expr {($a >> $i) & 1}]

        append bits $bit
    }

    return "${bits}b"
}


# ------------------------------------------------------------
# Test
# ------------------------------------------------------------

puts "========================================"
puts " Lab 4-1 : Extracting Bits"
puts "========================================"

puts "Stage 1 result : [stage1_demo]"

puts ""
puts "Stage 2"

puts "14 -> [to_bits 14]"
puts "9  -> [to_bits 9]"
puts "0  -> [to_bits 0]"
puts "15 -> [to_bits 15]"

puts ""
puts "Invalid input test"

set result [to_bits 18]

if {$result eq ""} {
    puts "18 -> invalid input"
} else {
    puts "18 -> $result"
}

puts ""
puts "Stage 3"

puts "5 (8-bit)   -> [to_bits_n 5 8]"
puts "14 (8-bit)  -> [to_bits_n 14 8]"
puts "325 (9-bit) -> [to_bits_n 325 9]"
