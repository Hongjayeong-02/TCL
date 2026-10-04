# RESULT

## 1. Environment Setup

Tcl 기반 EDA automation script를 실행하기 전에 project-specific path를 환경변수로 설정한다.

예:

```bash
export UART_RTL_PATH=<project>/TOP/RTL
export SDC_PATH=<project>/TOP/SYN/cons/cmsdk_mcu.sdc
export PDK_LIB_DIR=<pdk>/timing
```

`csh` / `tcsh` 환경에서는 다음과 같이 설정할 수 있다.

```csh
setenv UART_RTL_PATH <project>/TOP/RTL
setenv SDC_PATH <project>/TOP/SYN/cons/cmsdk_mcu.sdc
setenv PDK_LIB_DIR <pdk>/timing
```

환경변수가 설정되지 않은 경우 portable fallback path를 사용한다.

```text
UART_RTL_PATH = ../RTL
SDC_PATH      = ./cons/design.sdc
PDK_LIB_DIR   = ./lib
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
UART_RTL_PATH    : <UART_V3_RTL_PATH>
SDC_PATH         : <SDC_PATH>/cmsdk_mcu.sdc
PDK_LIB_DIR      : <PDK_TIMING_LIB_PATH>

[1] RTL PATH
PASS : RTL directory exists

[2] SDC
PASS : SDC file exists

[3] STANDARD CELL LIBRARY
PASS : fast_vdd1v0_basicCells.lib
PASS : fast_vdd1v2_basicCells.lib
PASS : slow_vdd1v0_basicCells.lib
PASS : slow_vdd1v2_basicCells.lib

[4] EDA TOOL
PASS : genus command found

========================================
 CHECK SUMMARY
========================================
PASS : 7
WARN : 0
RESULT : PASS
========================================
```

Fallback path를 사용하는 경우 해당 project file이 존재하지 않으면 WARN이 출력될 수 있다.

실제 synthesis 환경에서는 환경변수를 설정한 뒤 다시 실행하여 environment를 검증한다.

---

## 3. Standard Cell Corners

학습에 사용한 standard-cell timing library 구성은 다음과 같다.

| Library | PVT | 용도 |
|---|---|---|
| `fast_vdd1v0_basicCells.lib` | Fast / 1.10 V / 0°C | fast corner 분석 |
| `fast_vdd1v2_basicCells.lib` | Fast / 1.32 V / 0°C | high-voltage fast corner 분석 |
| `slow_vdd1v0_basicCells.lib` | Slow / 0.90 V / 125°C | setup-oriented slow corner 분석 |
| `slow_vdd1v2_basicCells.lib` | Slow / 1.08 V / 125°C | alternate-voltage slow corner 분석 |

4개 corner를 이용해 NAND2X1 cell의 leakage와 timing 특성을 비교하였다.

실제 library의 filesystem absolute path는 repository에 저장하지 않고 environment variable로 전달한다.

---

## 4. RTL File Handling

RTL file list는 Tcl list와 file operation을 이용해 관리한다.

예:

```tcl
set RTL_LIST {
    uart_baud_gen.v
    uart_fifo.v
    uart_tx.v
    uart_tx_fifo.v
    uart_rx.v
    uart_rx_fifo.v
    uart_core.v
    uart_irq.v
    uart_apb.v
}
```

각 RTL file에 대해 존재 여부를 검사하여 synthesis 실행 전에 missing RTL을 탐지할 수 있다.

Filelist validation 결과:

```text
PASS : uart_baud_gen.v
PASS : uart_fifo.v
PASS : uart_tx.v
PASS : uart_tx_fifo.v
PASS : uart_rx.v
PASS : uart_rx_fifo.v
PASS : uart_core.v
PASS : uart_irq.v
PASS : uart_apb.v

PASS : 9
FAIL : 0
RESULT : PASS
```

Validation 완료 후 synthesis용 filelist를 생성한다.

```text
filelist_syn.f
```

---

## 5. Synthesis Flow Connection

Tcl scripting 학습 내용을 실제 EDA flow에 연결하였다.

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
constraint setup
        ↓
syn_generic
        ↓
syn_map
        ↓
syn_opt
        ↓
report_timing
report_area
report_power
```

UART V3 synthesis의 top module은 다음과 같다.

```text
uart_apb
```

Clock 설정:

```text
Clock port   : clk
Clock period : 20 ns
Frequency    : 50 MHz
```

Tcl은 단순 문법 학습이 아니라 반복적인 synthesis setup, file validation, report parsing 및 결과 판정을 자동화하는 데 사용하였다.

---

## 6. UART V3 Synthesis Result

Cadence Genus를 이용하여 UART V3 top module `uart_apb`를 실제 synthesis한 결과이다.

### Synthesis Summary

| Item | Result |
|---|---:|
| Top Module | `uart_apb` |
| Clock | 50 MHz |
| Clock Period | 20 ns |
| WNS | +14.577 ns |
| TNS | 0.000 ns |
| Violated Paths | 0 |
| Leaf Instance Count | 922 |
| Sequential Instance Count | 317 |
| Combinational Instance Count | 605 |
| Total Area | 3360.150 |
| Timing Result | PASS |
| Area Result | PASS (limit 4000, example criterion) |

### QoR Result

```text
Clock Group : PCLK
Path Slack  : +14576.6 ps
TNS         : 0.0
Violating Paths : 0
```

Instance summary:

```text
Leaf Instance Count          : 922
Sequential Instance Count    : 317
Combinational Instance Count : 605
```

Area summary:

```text
Cell Area       : 3360.150
Physical Area   : 0.000
Net Area        : 0.000
Total Area      : 3360.150
```

---

### Timing Parser Result

실행:

```bash
tclsh parse_timing_report.tcl reports/uart_timing.rpt
```

결과:

```text
========================================
 Genus Timing Report Parser
========================================

REPORT : reports/uart_timing.rpt

[1] SLACK SEARCH
----------------------------------------
FORMAT : Genus path header (ps)
PATHS  : 1

SLACK : 14.577 ns  o_prdata[1]

[2] WORST SLACK
----------------------------------------
WNS      : 14.577 ns
TNS      : 0.000 ns
VIOLATED : 0 / 1 paths
WORST EP : o_prdata[1]

[3] TIMING RESULT
----------------------------------------
RESULT : PASS
Timing constraint is satisfied.
```

---

### Area Parser Result

실행:

```bash
tclsh parse_area_report.tcl reports/uart_area.rpt 4000
```

결과:

```text
========================================
 Genus Area Report Parser
========================================

REPORT : reports/uart_area.rpt

[1] AREA SEARCH
----------------------------------------
FORMAT     : Genus report_area table
TOTAL AREA : 3360.150
TOP        : uart_apb (922 cells)

[2] HIERARCHY
----------------------------------------
uart_apb    922    3360.150    100.0%

[3] AREA RESULT
----------------------------------------
AREA LIMIT : 4000.000
RESULT : PASS
Area constraint is satisfied.
```

---

### Generated Reports

실제 Genus synthesis 실행 후 다음 report를 생성하였다.

```text
reports/uart_qor.rpt
reports/uart_timing.rpt
reports/uart_area.rpt
reports/uart_power.rpt
reports/uart_gates.rpt
reports/uart_clocks.rpt
reports/uart_check_design.rpt
reports/uart_check_unresolved.rpt
```

실제 synthesis report를 Tcl parser와 연결하여 timing 및 area 수치를 자동 추출하고 PASS / FAIL 여부를 판정하였다.

---

## 7. Security / Repository Policy

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

이를 통해 동일 script를 다른 project 또는 server에서도 재사용할 수 있도록 구성하였다.

Generated synthesis database 및 intermediate output은 repository에서 제외한다.

예:

```text
fv/
```

---

## 8. Learning Result

이번 Tcl automation 실습을 통해 다음 내용을 확인하였다.

```text
Tcl syntax
        ↓
project configuration
        ↓
RTL source management
        ↓
environment validation
        ↓
Genus synthesis execution
        ↓
timing / area report generation
        ↓
report parsing
        ↓
PASS / FAIL decision
```

사용한 주요 Tcl 기능:

```text
set
list
lappend
foreach
file
file exists
dict
regexp
regsub
catch
error
argv
source
namespace
```

EDA automation과 연결한 주요 기능:

```text
RTL source validation
library path configuration
clock configuration
synthesis flow setup
timing report parsing
area report parsing
result summarization
```

단순 Tcl 문법 실습에서 끝내지 않고 실제 UART V3 RTL synthesis flow와 연결하여 scripting language를 ASIC design automation에 적용하였다.
