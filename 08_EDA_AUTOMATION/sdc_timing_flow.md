# SDC Timing Flow Analysis

`cmsdk_mcu.sdc`의 timing constraint가 Genus synthesis와 STA에 어떻게 연결되는지 정리한 문서입니다.

## 1. Clock Definition

```tcl
create_clock -period 8 -name MAIN_CLOCK [get_ports XTAL1]
```

`XTAL1` port에 8 ns period의 `MAIN_CLOCK`을 정의합니다.

```text
Clock Period = 8 ns
Clock Frequency = 125 MHz
```

이 clock이 register-to-register timing 분석의 기본 time budget이 됩니다.

---

## 2. Clock Environment

```tcl
set_clock_latency -source -max 0.2 [get_clocks MAIN_CLOCK]
set_clock_latency -max 0.2 [get_clocks MAIN_CLOCK]

set_clock_uncertainty -setup 0.1 [get_clocks MAIN_CLOCK]
set_clock_transition 0.1 [get_clocks MAIN_CLOCK]
```

### Clock Latency

- Source latency: clock 생성 지점에서 clock definition point까지의 지연
- Network latency: clock definition point에서 FF clock pin까지의 지연

현재 SDC에서는 각각 `0.2 ns`가 설정되어 있습니다.

### Clock Uncertainty

`0.1 ns`의 setup uncertainty를 적용하여 ideal clock보다 더 보수적인 setup timing 조건을 만듭니다.

### Clock Transition

`0.1 ns`의 clock slew를 정의하여 library timing calculation에 사용할 clock edge 특성을 모델링합니다.

---

## 3. Input Timing

```tcl
set_input_delay -max 0.1 -clock MAIN_CLOCK [all_inputs]
set_input_delay -min 0.01 -clock MAIN_CLOCK [all_inputs]
```

Input delay는 외부 device에서 chip input port까지 이미 소비된 timing budget을 나타냅니다.

개념적으로:

```text
External Device
      ↓
 Input Delay
      ↓
 Chip Input
      ↓
 Internal Logic
```

따라서 내부 logic은 전체 clock period를 모두 사용할 수 없습니다.

---

## 4. Output Timing

```tcl
set_output_delay -max 0.1 -clock MAIN_CLOCK [all_outputs]
set_output_delay -min -0.01 -clock MAIN_CLOCK [all_outputs]
```

Output delay는 chip output 이후 외부 device가 요구하는 timing을 반영합니다.

```text
Internal Logic
      ↓
 Chip Output
      ↓
Output Timing Requirement
      ↓
External Device
```

---

## 5. Electrical Environment

```tcl
set_driving_cell -lib_cell PADDI -pin Y ...
set_load [load_of PADDO/A] [all_outputs]
```

Input port에는 `PADDI`의 drive characteristic을 적용하고, output에는 `PADDO/A` 기준 load를 적용합니다.

이 값들은 Liberty LUT의 다음 축과 연결됩니다.

```text
Input Slew  → LUT index_1
Output Load → LUT index_2
```

---

## 6. Operating Condition

```tcl
set_operating_conditions \
    -max PVT_0P9V_125C \
    -min PVT_1P1V_0C
```

Timing 계산에 사용할 PVT corner를 지정합니다.

```text
-max → Slow Corner → Setup Analysis
-min → Fast Corner → Hold Analysis
```

---

## 7. SDC to Genus Flow

```text
cmsdk_mcu.sdc
      ↓
source -verbose
      ↓
Clock / I/O / Electrical Constraint
      ↓
syn_generic
      ↓
syn_map
      ↓
syn_opt
      ↓
report_timing
report_constraint
report_qor
```

Genus synthesis script에서 `cmsdk_mcu.sdc`를 source한 뒤 synthesis와 timing report를 수행하므로, SDC는 단순 설정 파일이 아니라 synthesis optimization의 기준 조건입니다.

---

## Key Connection

```text
create_clock
    ↓
Clock Timing Budget

set_input_delay / set_output_delay
    ↓
External Interface Timing

set_driving_cell / set_load
    ↓
Input Slew / Output Capacitance

set_operating_conditions
    ↓
PVT Corner Selection

          ↓

Liberty LUT Timing Calculation

          ↓

Genus Optimization & STA Report
```

## Result

현재 분석에서는 `MAIN_CLOCK = 8 ns`와 `setup uncertainty = 0.1 ns`가 timing report에 반영되었고, 제공된 synthesis result에서 R→R clock relationship이 `7900 ps = 8000 ps - 100 ps`로 나타난 것으로 정리되어 있습니다.
