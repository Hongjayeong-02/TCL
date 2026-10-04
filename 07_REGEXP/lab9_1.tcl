# ============================================================
# Lab 9-1 : regexp / regsub for RTL Processing
#
# 목표
#   Stage 1 : Verilog vector port 찾기
#   Stage 2 : vector signal 이름에 _bus suffix 붙이기
#             regsub -all 사용
#             변환 결과를 새 파일로 저장
#   Stage 3 : flattened vector name 변환
#             ain_7 -> ain[7]
#             data_15 -> data[15]
#
# 특징
#   - adder.vhdl 같은 lab 원본 예제를 사용하지 않음
#   - 직접 만든 UART/APB 스타일 Verilog 예제로 검증
# ============================================================


# ------------------------------------------------------------
# Stage 1
# Verilog RTL에서 vector port 찾기
#
# 예:
#   input      [7:0]  i_paddr,
#   input      [31:0] i_pwdata,
#   output reg [31:0] o_prdata,
# ------------------------------------------------------------

proc find_vector_port {filename} {

    if {![file exists $filename]} {
        error "File not found: $filename"
    }

    set fp [open $filename r]
    set result {}

    while {[gets $fp line] >= 0} {

        # -expanded:
        # 정규식을 여러 줄로 보기 좋게 작성하기 위해 사용
        #
        # direction  : input / output / inout
        # datatype   : wire / reg (optional)
        # vector     : [MSB:LSB]
        # signal     : signal name

        if {[regexp -expanded {
            ^[ \t]*
            (input|output|inout)
            [ \t]+
            (wire|reg)?
            [ \t]*
            \[[0-9]+:[0-9]+\]
            [ \t]+
            ([A-Za-z_][A-Za-z0-9_]*)
        } $line -> direction datatype signal]} {

            lappend result $signal
        }
    }

    close $fp

    return $result
}


# ------------------------------------------------------------
# Stage 2
# Vector port 이름에 _bus suffix 추가
#
# 예:
#   i_paddr   -> i_paddr_bus
#   i_pwdata  -> i_pwdata_bus
#   o_prdata  -> o_prdata_bus
#
# regsub -all을 사용해서
# 선언부뿐 아니라 RTL 내부 reference도 함께 변경
# ------------------------------------------------------------

proc convert_netlist {input_file output_file} {

    if {![file exists $input_file]} {
        error "File not found: $input_file"
    }

    # vector port 목록 추출
    set vector_ports [find_vector_port $input_file]

    # 입력 RTL 전체 읽기
    set fin [open $input_file r]
    set data [read $fin]
    close $fin


    # vector port마다 _bus suffix 추가
    foreach signal $vector_ports {

        # \m : word beginning
        # \M : word end
        #
        # 예:
        #   i_paddr      -> 변경
        #   i_paddr_tmp  -> 변경하지 않음

        set pattern "\\m${signal}\\M"

        regsub -all $pattern $data "${signal}_bus" data
    }


    # 변환 결과 저장
    set fout [open $output_file w]

    puts -nonewline $fout $data

    close $fout

    return $output_file
}


# ------------------------------------------------------------
# Stage 3
# Flattened vector signal 이름을
# Verilog vector notation으로 변환
#
# 예:
#   ain_7    -> ain[7]
#   ain_0    -> ain[0]
#   data_15  -> data[15]
#   addr_3   -> addr[3]
#
# 마지막 "_숫자" 패턴만 변환
# ------------------------------------------------------------
proc convert_vector {signal} {

    # 마지막 "_숫자" 부분을 vector index로 변환
    #
    # ain_7    -> ain[7]
    # data_15  -> data[15]
    # uart_rx  -> uart_rx

    if {[regexp {^(.*)_([0-9]+)$} \
        $signal -> base index]} {

        return "${base}\[$index\]"
    }

    return $signal
}


# ------------------------------------------------------------
# Demo RTL 생성
#
# 저작권 문제가 있는 lab 예제를 복사하지 않고
# 직접 만든 UART/APB 스타일 RTL을 사용
# ------------------------------------------------------------

proc create_demo_rtl {filename} {

    set fp [open $filename w]

    puts $fp {module uart_apb_demo (}
    puts $fp {    input              clk,}
    puts $fp {    input              rst_n,}
    puts $fp {    input      [7:0]   i_paddr,}
    puts $fp {    input      [31:0]  i_pwdata,}
    puts $fp {    output reg [31:0]  o_prdata,}
    puts $fp {    output             o_irq}
    puts $fp {);}
    puts $fp {}

    # vector port가 RTL 내부에서도 사용되는지 확인하기 위한 예제
    puts $fp {assign o_irq = i_paddr[0];}
    puts $fp {}

    puts $fp {always @(*) begin}
    puts $fp {    o_prdata = i_pwdata;}
    puts $fp {end}
    puts $fp {}

    puts $fp {endmodule}

    close $fp
}


# ============================================================
# Test
# ============================================================

puts "========================================"
puts " Lab 9-1 : REGEXP / REGSUB"
puts "========================================"


# ------------------------------------------------------------
# Stage 1
# find_vector_port
# ------------------------------------------------------------

puts ""
puts "Stage 1 : find_vector_port"
puts "----------------------------------------"

set demo_file "uart_apb_demo.v"

create_demo_rtl $demo_file

set vector_ports [find_vector_port $demo_file]

puts "Vector ports:"

foreach port $vector_ports {
    puts "  $port"
}


# ------------------------------------------------------------
# Stage 2
# convert_netlist
# ------------------------------------------------------------

puts ""
puts "Stage 2 : convert_netlist"
puts "----------------------------------------"

set output_file "uart_apb_demo_bus.v"

convert_netlist $demo_file $output_file

puts "Input  : $demo_file"
puts "Output : $output_file"

puts ""
puts "Converted RTL:"

set fp [open $output_file r]

puts [read $fp]

close $fp


# ------------------------------------------------------------
# Stage 3
# convert_vector
# ------------------------------------------------------------

puts ""
puts "Stage 3 : convert_vector"
puts "----------------------------------------"

set signals {
    ain_7
    ain_0
    data_15
    addr_3
    uart_rx
}

foreach signal $signals {

    puts [format "%-10s -> %s" \
        $signal \
        [convert_vector $signal]]
}
