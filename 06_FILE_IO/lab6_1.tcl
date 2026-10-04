# ============================================================
# Lab 6-1 : Bitstream Header Parser
#
# 목표
#   - Xilinx .bit header 에서 metadata 추출
#       0x61 : design file name
#       0x62 : part name
#       0x63 : date
#       0x64 : time
#       0x65 : configuration data (여기서 파싱 종료)
#
# 주의
#   field 데이터 안에도 0x61~0x65 ('a'~'e') 값이 들어갈 수 있으므로
#   marker byte 를 파일 전체에서 검색하면 잘못된 위치를 잡는다.
#
#   따라서:
#     marker → length field → length 만큼 read/skip → 다음 marker
#   방식으로 순차 파싱한다.
#
# 실행
#   tclsh lab6_1.tcl                  ;# 테스트 .bit 를 직접 만들어서 검증
#   tclsh lab6_1.tcl <bitstream.bit>  ;# 실제 파일 파싱
# ============================================================


# ------------------------------------------------------------
# Utility : binary byte -> unsigned integer
# ------------------------------------------------------------

proc byte_to_uint {byte} {

    # cu : unsigned char (Tcl 8.5+) → 음수 보정 불필요
    binary scan $byte cu value

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

    # Su : unsigned 16-bit big-endian
    binary scan $raw Su value

    return $value
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

    # length 에는 마지막 NULL(0x00) 이 포함되어 있으므로 제거
    return [string trimright $raw "\x00"]
}


# ------------------------------------------------------------
# Stage 1
# hex -> ASCII
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
# Stage 2 / 3
# Xilinx-style bitstream metadata parser
#
# 핵심:
#   marker 를 전체 파일에서 string first 로 찾지 않고
#   stream 을 앞에서부터 순서대로 읽는다.
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
    set result(file)   [file tail $bitstream]
    set result(design) ""
    set result(part)   ""
    set result(date)   ""
    set result(time)   ""


    # --------------------------------------------------------
    # Preamble skip
    #
    # preamble 에는 0x00 은 있을 수 있지만 0x61~0x65 는 없으므로
    # 첫 번째 0x61 이 header 의 시작이다.
    # 이후에는 length 를 이용해 정확하게 이동한다.
    # --------------------------------------------------------

    set found_start 0

    while {1} {

        set raw [read $fp 1]

        if {[string length $raw] != 1} {
            break
        }

        if {[byte_to_uint $raw] == 0x61} {
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
    #
    # 주의:
    #   byte_to_uint 는 10진수(예: 98)를 반환한다.
    #   switch 는 "문자열" 비교라서 98 과 "0x62" 는 매칭되지 않는다.
    #   → format 0x%02x 로 "0x62" 형태 문자열로 바꿔서 비교한다.
    # --------------------------------------------------------

    set current_marker 0x61

    while {1} {

        switch -- [format 0x%02x $current_marker] {

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
                # configuration data 시작 → metadata 파싱 종료
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
    }


    close $fp

    return [array get result]
}


# ------------------------------------------------------------
# get_filename
#   lab 의 "file name" = header 0x61 field 의 design file name
#   (bitstream 파일 경로의 끝부분이 아님)
# ------------------------------------------------------------

proc get_filename {bitstream} {

    array set info [parse_bitstream $bitstream]

    return $info(design)
}


# ------------------------------------------------------------
# Pretty print
# ------------------------------------------------------------

proc print_bitstream_info {bitstream} {

    array set info [parse_bitstream $bitstream]

    puts "File      : $info(file)"
    puts "File name : $info(design)"
    puts "Part name : $info(part)"
    puts "Date      : $info(date)"
    puts "Time      : $info(time)"

    return [array get info]
}


# ------------------------------------------------------------
# Test data 생성
#   course 제공 파일 대신 .bit header 형식에 맞춰 직접 만든다.
#   design 이름에 일부러 'a'(0x61) 'b'(0x62) 'c'(0x63) 를 넣어서
#   marker 검색 방식이면 틀리는 상황을 재현한다.
# ------------------------------------------------------------

proc make_text_field {key text} {

    set data "$text\x00"

    # c : 1 byte, S : 16-bit big-endian
    return [binary format cS $key [string length $data]]$data
}


proc make_test_bitstream {filename} {

    set preamble [binary format H* 00090ff00ff00ff00ff0000001]

    set header ""
    append header [make_text_field 0x61 "uart_apb_top.ncd"]
    append header [make_text_field 0x62 "xc7a35tcpg236"]
    append header [make_text_field 0x63 "2026/10/04"]
    append header [make_text_field 0x64 "13:45:00"]

    # 0x65 + 4-byte length + configuration data
    set config [binary format H* ffffffffaa995566]
    append header [binary format cI 0x65 [string length $config]]$config

    set fp [open $filename wb]
    fconfigure $fp -translation binary
    puts -nonewline $fp "$preamble$header"
    close $fp

    return $filename
}


# ------------------------------------------------------------
# Test
# ------------------------------------------------------------

puts "========================================"
puts " Lab 6-1 : Bitstream Header Parser"
puts "========================================"

puts ""
puts "Stage 1 : hex_to_ascii"
puts "61 62 63 64 65 -> [hex_to_ascii {61 62 63 64 65}]"


if {$argc >= 1} {

    puts ""
    puts "Stage 2 / 3 : [lindex $argv 0]"
    puts "----------------------------------------"

    print_bitstream_info [lindex $argv 0]

    exit 0
}


# ---- 인자 없이 실행하면 테스트 .bit 를 만들어 self-check ----

file mkdir out
set test_bit [make_test_bitstream [file join out test_uart.bit]]

puts ""
puts "Stage 2 : get_filename"
puts "----------------------------------------"
puts "File name : [get_filename $test_bit]"

puts ""
puts "Stage 3 : all fields"
puts "----------------------------------------"
array set info [print_bitstream_info $test_bit]


set expected {
    design uart_apb_top.ncd
    part   xc7a35tcpg236
    date   2026/10/04
    time   13:45:00
}

set errors 0

puts ""
foreach {key value} $expected {

    if {$info($key) eq $value} {
        puts "PASS : $key"
    } else {
        puts "FAIL : $key (expected $value, got $info($key))"
        incr errors
    }
}

puts ""

if {$errors == 0} {
    puts "RESULT : ALL PASS"
} else {
    puts "RESULT : $errors ERROR"
    exit 1
}
