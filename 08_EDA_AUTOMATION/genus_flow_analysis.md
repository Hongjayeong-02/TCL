# Genus Synthesis Flow Analysis

Actual synthesis flow based on `cortexm0_45nm.tcl`.

## Flow

```text
Project Setup
    ↓
Library / Physical Data
    ↓
RTL Read & Elaboration
    ↓
SDC Constraint
    ↓
syn_generic
    ↓
syn_map
    ↓
syn_opt
    ↓
Timing / Area / Power / QoR Report
    ↓
Netlist / SDC / SDF Output
    ↓
Innovus P&R
```

## 1. Project Configuration

```tcl
set TOP_DESIGN cmsdk_mcu
set LOG_DIR "./log"
set RPT_DIR "./report"
set RTL_PATH "../RTL"
```

`set` is a Tcl command used to parameterize the design name and project paths.

---

## 2. Library Setup

```tcl
set LIB_LIST {
    fast_vdd1v0_basicCells.lib
    slow_vdd1v0_basicCells.lib
    pads_SS_s1vg.lib
}

read_libs ${LIB_LIST}
read_physical -lef ${LEF_LIST}
```

Standard-cell and I/O libraries are stored as Tcl lists and passed to Genus.

---

## 3. RTL Read & Elaboration

```tcl
read_hdl $RTL_SOURCES
elaborate ${TOP_DESIGN}
```

- `read_hdl` : reads RTL sources
- `elaborate` : builds the design hierarchy from the selected top module

---

## 4. Constraint Setup

```tcl
source -verbose ./cons/cmsdk_mcu.sdc
source -verbose ./cons/dont_use_45nm.tcl
```

Timing constraints and cell usage restrictions are applied before synthesis.

---

## 5. Synthesis

```tcl
syn_generic
syn_map
syn_opt
```

| Stage | Function |
|---|---|
| `syn_generic` | Converts RTL into technology-independent generic logic |
| `syn_map` | Maps generic logic to the target standard-cell library |
| `syn_opt` | Optimizes the mapped design for timing, area and power |

---

## 6. Reports

```tcl
report_area
report_power
report_qor
report_timing
report_constraint
```

The synthesis result is analyzed using area, power, timing, QoR and constraint reports.

---

## 7. Output

```tcl
write_design
write_hdl
write_sdc
write_sdf
```

Generated outputs are used by downstream implementation tools such as Cadence Innovus.

---

## Tcl vs Genus Commands

| Tcl Language | Genus Command |
|---|---|
| `set` | `set_db` |
| `if` | `read_libs` |
| `puts` | `read_hdl` |
| `list` | `elaborate` |
| `concat` | `syn_generic` |
| variable substitution | `syn_map`, `syn_opt` |

The synthesis script therefore combines:

```text
Tcl Language
     +
Genus Tool Commands
     =
ASIC Synthesis Automation
```
