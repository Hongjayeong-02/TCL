# EDA Automation Result

## 1. Environment Setup

개인 서버 계정명과 설치 경로를 repository에 직접 기록하지 않도록 환경변수 기반으로 구성하였다.

```bash
export RTL_PATH=<project>/TOP/RTL
export SDC_PATH=<project>/TOP/SYN/cons/design.sdc
export PDK_LIB_DIR=<GPDK045_timing_lib_directory>
```

Tcl script에서는 다음 환경변수를 사용한다.

```text
RTL_PATH
SDC_PATH
PDK_LIB_DIR
```

환경변수가 설정되지 않은 경우 portable fallback path를 사용한다.

```text
RTL_PATH    = ../RTL
SDC_PATH    = ./cons/design.sdc
PDK_LIB_DIR = ./lib
```

---

## 2. Environment Check

실행:

```bash
cd 08_EDA_AUTOMATION
tclsh check_design_env.tcl
```

검사 항목:

```text
RTL directory
SDC constraint file
standard-cell timing libraries
Cadence Genus executable
```

예시 출력:

```text
========================================
 ASIC DESIGN ENVIRONMENT CHECK
========================================

Configuration
RTL_PATH    : ../RTL
SDC_PATH    : ./cons/design.sdc
PDK_LIB_DIR : ./lib

[1] RTL PATH
WARN : RTL directory not found

[2] SDC
WARN : SDC file not found

[3] STANDARD CELL LIBRARY
WARN : fast_vdd1v0_basicCells.lib not found
WARN : fast_vdd1v2_basicCells.lib not found
WARN : slow_vdd1v0_basicCells.lib not found
WARN : slow_vdd1v2_basicCells.lib not found

[4] EDA TOOL
PASS : genus command found
```

Fallback path를 사용하는 경우 해당 프로젝트 파일이 존재하지 않으면 WARN이 출력된다.

실제 synthesis 환경에서는 환경변수를 설정한 뒤 다시 실행하여 검증한다.

---

## 3. Standard Cell Corners

학습에 사용한 standard-cell timing library 구성:

| Corner | Voltage / Temperature 성격 | 용도 |
|---|---|---|
| `fast_vdd1v0_basicCells.lib` | Fast | fast-corner 확인 |
| `fast_vdd1v2_basicCells.lib` | Fast / higher supply | corner 비교 |
| `slow_vdd1v0_basicCells.lib` | Slow | setup-oriented synthesis 및 timing 분석 |
| `slow_vdd1v2_basicCells.lib` | Slow / alternate supply | corner 비교 |

실제 library의 filesystem absolute path는 repository에 저장하지 않는다.

---

## 4. RTL File Handling

RTL file list는 Tcl list와 file operation을 이용해 관리한다.

예:

```tcl
set RTL_LIST {
    uart_baud_gen.v
    uart_tx.v
    uart_tx_fifo.v
    uart_rx.v
    uart_rx_fifo.v
    uart_core.v
    uart_irq.v
    uart_apb.v
}
```

각 파일에 대해 존재 여부를 검사하여 synthesis 실행 전에 missing RTL을 탐지할 수 있다.

---

## 5. Synthesis Flow Connection

Tcl scripting 학습 내용을 실제 EDA flow에 연결한다.

```text
Project path setup
        ↓
RTL file validation
        ↓
Library setup
        ↓
read_hdl
        ↓
elaborate
        ↓
read_sdc
        ↓
syn_generic
        ↓
syn_map
        ↓
syn_opt
        ↓
report_timing / report_area / report_power
```

Tcl은 단순 문법 학습이 아니라 반복적인 synthesis setup과 결과 분석을 자동화하는 데 사용한다.

---

## 6. Security / Repository Policy

Repository에는 아래 정보를 직접 기록하지 않는다.

```text
/home/<username>/...
EDA tool installation absolute paths
PDK installation absolute paths
licensed course PDFs
server-specific credentials
```

대신 다음 방식을 사용한다.

```text
environment variables
relative paths
placeholder paths
.gitignore
```

이를 통해 동일 script를 다른 project 또는 server에서도 재사용할 수 있도록 구성
