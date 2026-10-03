# EDA Automation Result

## Environment Check

`check_design_env.tcl`

| Item | Result |
|---|---|
| RTL Path | PASS |
| SDC File | PASS |
| Standard Cell Libraries | PASS |
| Cadence Genus | PASS |

### Verified Environment

```text
RTL
/home/hah006/PROJ1/proj1_make/TOP/RTL

SDC
/home/hah006/SoC/SoC_make_G45/TOP/SYN/cons/cmsdk_mcu.sdc

Standard Cell Library
fast_vdd1v0_basicCells.lib
fast_vdd1v2_basicCells.lib
slow_vdd1v0_basicCells.lib
slow_vdd1v2_basicCells.lib

Genus
/tools/cadence/DDI221/GENUS221/tools.lnx86/bin/genus
```

## Tcl Practice Result

- File I/O: PASS
- Regular Expression: PASS
- RTL / Library list handling: PASS
- Project setup automation: PASS
- Environment validation: PASS

## EDA Flow Connection

```text
Tcl Script
    ↓
Design Environment Check
    ↓
Library / RTL / SDC Setup
    ↓
Genus Synthesis
    ↓
Timing / Area / Power Report
```

The study was extended from basic Tcl syntax to practical ASIC design-flow scripting.
