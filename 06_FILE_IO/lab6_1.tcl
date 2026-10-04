# ============================================================
# Lab 6-1 : Bitstream Header Parser
#
# 목표
#   - bitstream binary file에서 metadata 추출
#   - filename
#   - part
#   - date
#   - time
#
# 주의
#   bitstream 내부 data 영역에도 0x61~0x65 값이 존재할 수 있으므로
#   단순히 marker byte를 전체 파일에서 검색하면 잘못된 위치를 잡을 수 있다.
#
#   따라서:
#     marker
#       ↓
#     length field
#       ↓
#     해당 length만큼 data skip/read
#
#   방식으로 순차 파싱한다.
# ============================================================


# ------------------------------------------------------------
# Utility : binary byte -> integer
# ------------------------------------------------------------

proc byte_to_uint {byte} {

    binary scan $byte c value

    # Tcl의 signed char 보정
    if {$value < 0} {
        set value [expr {$value + 256}]
    }

    return $value
}


# ------------------------------------------------------------
# Utility : 2-byte big-endian length read
# ------------------------------------------------------------

proc read_u16_be {fp} {

    set raw [read $fp 2]

    if {[string length $raw] != 2} {
        error "Unexpected EOF while reading 16-bit length field"
    }

    binary scan $raw cc b0 b1

    if {$b0 < 0} {
        set b0 [expr {$b0 + 256}]
    }

    if {$b1 < 0} {
        set b1 [expr {$b1 + 256}]
    }

    return [expr {($b0 << 8) | $b1}]
}


# ------------------------------------------------------------
# Utility : read string field
# ------------------------------------------------------------

proc read_string_field {fp length} {

    if {$length <= 0} {
        return ""
    }

    set raw [read $fp $length]

    if {[string length $raw] != $length} {
        error "Unexpected EOF while reading string field"
    }

    # bitstream 문자열은 마지막에 NULL이 포함되는 경우가 있으므로 제거
    set value [string trimright $raw "\x00"]

    return $value
}


# ------------------------------------------------------------
# Stage 1
# 기존 hex_to_ascii 개념
# ------------------------------------------------------------

proc hex_to_ascii {hex_string} {

    set result ""

    foreach hex_byte [split $hex_string] {

        scan $hex_byte %x value

        append result [format %c $value]
    }

    return $result
}


# ------------------------------------------------------------
# Stage 2
# filename 추출
#
# get_filename $bitstream
# ------------------------------------------------------------

proc get_filename {bitstream} {

    return [file tail $bitstream]
}


# ------------------------------------------------------------
# Stage 3
# Xilinx-style bitstream metadata parser
#
# 일반적으로 metadata tag:
#
#   0x61 = design / filename
#   0x62 = part
#   0x63 = date
#   0x64 = time
#   0x65 = bitstream data
#
# 핵심:
# marker를 전체 파일에서 string first로 찾지 않고
# stream을 앞에서부터 순서대로 읽는다.
# ------------------------------------------------------------

proc parse_bitstream {bitstream} {

    if {![file exists $bitstream]} {
        error "File not found: $bitstream"
    }

    set fp [open $bitstream rb]

    fconfigure $fp \
        -translation binary \
        -encoding binary


    # 결과 저장
    set result(filename) [file tail $bitstream]
    set result(design)   ""
    set result(part)     ""
    set result(date)     ""
    set result(time)     ""


    # --------------------------------------------------------
    # Header skip
    #
    # bitstream 형식에 따라 앞부분에 binary header가 존재하므로
    # metadata tag 0x61이 나올 때까지 byte 단위로 전진한다.
    #
    # 단, 이후에는 각 field length를 이용해 정확하게 이동한다.
    # --------------------------------------------------------

    set found_start 0

    while {![eof $fp]} {

        set raw [read $fp 1]

        if {[string length $raw] != 1} {
            break
        }

        set marker [byte_to_uint $raw]

        if {$marker == 0x61} {
            set found_start 1
            break
        }
    }


    if {!$found_start} {
        close $fp
        error "Metadata start marker 0x61 not found"
    }


    # --------------------------------------------------------
    # Metadata sequential parsing
    # --------------------------------------------------------

    set current_marker 0x61

    while {1} {

        switch -- $current_marker {

            0x61 {
                set length [read_u16_be $fp]
                set result(design) [read_string_field $fp $length]
            }

            0x62 {
                set length [read_u16_be $fp]
                set result(part) [read_string_field $fp $length]
            }

            0x63 {
                set length [read_u16_be $fp]
                set result(date) [read_string_field $fp $length]
            }

            0x64 {
                set length [read_u16_be $fp]
                set result(time) [read_string_field $fp $length]
            }

            0x65 {
                # 실제 configuration data 시작
                # 여기부터는 metadata parser 범위를 종료
                break
            }

            default {
                close $fp
                error [format "Unexpected marker: 0x%02X" $current_marker]
            }
        }


        # ----------------------------------------------------
        # 다음 marker 읽기
        # ----------------------------------------------------

        set raw [read $fp 1]

        if {[string length $raw] != 1} {
            break
        }

        set current_marker [byte_to_uint $raw]


        if {$current_marker == 0x65} {
            break
        }
    }


    close $fp

    return [array get result]
}


# ------------------------------------------------------------
# Pretty print
# ------------------------------------------------------------

proc print_bitstream_info {bitstream} {

    array set info [parse_bitstream $bitstream]

    puts "========================================"
    puts " Bitstream Metadata"
    puts "========================================"

    puts "File   : $info(filename)"
    puts "Design : $info(design)"
    puts "Part   : $info(part)"
    puts "Date   : $info(date)"
    puts "Time   : $info(time)"
}


# ------------------------------------------------------------
# Test
# ------------------------------------------------------------

puts "========================================"
puts " Lab 6-1 : File / Bitstream Parser"
puts "========================================"

puts ""
puts "Stage 1"

puts "61 62 63 64 65 -> [hex_to_ascii {61 62 63 64 65}]"

puts ""
puts "Stage 2"

set demo_path "/project/fpga/build/top.bit"

puts "Path     : $demo_path"
puts "Filename : [get_filename $demo_path]"

puts ""
puts "Stage 3"

if {$argc >= 1} {

    set bitstream [lindex $argv 0]

    print_bitstream_info $bitstream

} else {

    puts "Usage:"
    puts "  tclsh lab6_1.tcl <bitstream.bit>"
}
