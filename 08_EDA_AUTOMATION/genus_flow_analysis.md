# Genus Synthesis Flow Analysis

Actual synthesis flow based on a Cadence Genus ASIC synthesis script.

---

## Flow

```text
Project Setup
    ↓
Library / Physical Data Setup
    ↓
RTL Read
    ↓
Elaboration
    ↓
Timing / Design Constraints
    ↓
syn_generic
    ↓
syn_map
    ↓
syn_opt
    ↓
Timing / Area / Power / QoR Analysis
    ↓
Netlist / SDC / SDF Output
    ↓
Innovus P&R
```

---

## 1. Project Configuration

Tcl variables are used to separate project-specific settings from the synthesis commands.

```tcl
set TOP_DESIGN cmsdk_mcu
set LOG_DIR    "./log"
set RPT_DIR    "./report"
set RTL_PATH   "../RTL"
```

`set` is a Tcl built-in command.

Its role is to store values such as:

```text
top design name
RTL directory
report directory
library directory
constraint directory
```

This makes the synthesis script easier to reuse and modify.

---

## 2. Library Setup

Library file names can be managed using Tcl lists.

```tcl
set LIB_LIST {
    fast_vdd1v0_basicCells.lib
    slow_vdd1v0_basicCells.lib
    pads_SS_s1vg.lib
}
```

A full library path can be generated using Tcl commands.

```tcl
set libs {}

foreach lib $LIB_LIST {
    lappend libs [file join $LIB_PATH $lib]
}
```

The resulting list is then passed to a Genus command.

```tcl
read_libs $libs
```

Physical library information can also be read by Genus.

```tcl
read_physical -lef $LEF_LIST
```

### Separation of roles

```text
Tcl
    set
    foreach
    lappend
    file join

        ↓ prepares data

Genus
    read_libs
    read_physical

        ↓ loads technology data
```

---

## 3. RTL Read & Elaboration

RTL file lists can also be prepared using Tcl.

```tcl
set RTL_SOURCES {
    uart_baud_gen.v
    uart_tx.v
    uart_rx.v
    uart_core.v
}
```

Genus reads the RTL using:

```tcl
read_hdl $RTL_SOURCES
```

The design hierarchy is then constructed with:

```tcl
elaborate $TOP_DESIGN
```

### Genus commands

| Command | Function |
|---|---|
| `read_hdl` | Reads Verilog/SystemVerilog/VHDL RTL |
| `elaborate` | Builds the design hierarchy from the selected top module |

---

## 4. Constraint Setup

Constraint files can be loaded using the Tcl built-in command `source`.

```tcl
source -verbose ./cons/cmsdk_mcu.sdc
source -verbose ./cons/dont_use_45nm.tcl
```

`source` itself is a Tcl command.

However, the sourced files may contain EDA tool commands such as:

```tcl
create_clock
set_input_delay
set_output_delay
set_false_path
set_dont_use
```

Therefore:

```text
Tcl source command
        ↓
loads another Tcl script
        ↓
Genus / SDC commands inside the script are executed
```

---

## 5. Synthesis

The main Genus synthesis stages are:

```tcl
syn_generic
syn_map
syn_opt
```

| Stage | Function |
|---|---|
| `syn_generic` | Converts RTL into technology-independent generic logic |
| `syn_map` | Maps generic logic to target standard cells |
| `syn_opt` | Optimizes the mapped design for timing, area, and power |

Conceptually:

```text
RTL
 ↓
Generic Boolean / Sequential Logic
 ↓
Technology Mapping
 ↓
Mapped Standard Cells
 ↓
Optimization
```

---

## 6. Reports

After synthesis, Genus reports are generated.

```tcl
report_area
report_power
report_qor
report_timing
report_constraint
```

Typical report purposes:

| Report | Purpose |
|---|---|
| `report_timing` | Setup/hold path and slack analysis |
| `report_area` | Cell area and hierarchy area analysis |
| `report_power` | Estimated power analysis |
| `report_qor` | Overall Quality of Results summary |
| `report_constraint` | Constraint violations and checks |

Tcl can redirect report output to files.

```tcl
set timing_rpt [file join $RPT_DIR timing.rpt]

redirect $timing_rpt {
    report_timing
}
```

This demonstrates the combination of Tcl path handling and Genus report commands.

---

## 7. Output Generation

Post-synthesis data is written for downstream implementation.

```tcl
write_hdl
write_sdc
write_sdf
```

Typical output:

```text
Synthesized gate-level netlist
Synthesized SDC
SDF timing data
Reports
```

These outputs can be used by downstream tools such as Cadence Innovus.

---

# Tcl Built-ins vs Genus Commands

Tcl language commands and Genus commands are not one-to-one equivalents.

They serve different roles.

| Category | Examples | Role |
|---|---|---|
| Tcl built-in | `set` | Store variables |
| Tcl built-in | `if` | Conditional execution |
| Tcl built-in | `foreach` | Loop through lists |
| Tcl built-in | `puts` | Print text |
| Tcl built-in | `list`, `lappend` | Build and modify lists |
| Tcl built-in | `file join` | Construct portable paths |
| Tcl built-in | `source` | Execute another Tcl script |
| Genus | `read_libs` | Load timing libraries |
| Genus | `read_hdl` | Load RTL |
| Genus | `elaborate` | Build RTL hierarchy |
| Genus | `syn_generic` | Generic synthesis |
| Genus | `syn_map` | Technology mapping |
| Genus | `syn_opt` | Optimization |
| Genus | `report_timing` | Timing analysis |
| Genus | `report_area` | Area analysis |

The correct relationship is therefore:

```text
Tcl commands
    ↓
control script flow
manage variables
build file lists
process paths
handle conditions

Genus commands
    ↓
perform synthesis
load libraries
read RTL
elaborate design
optimize logic
generate reports
```

---

## Example: Tcl + Genus Together

```tcl
set LIB_PATH "./lib"

set LIB_LIST {
    fast_vdd1v0_basicCells.lib
    slow_vdd1v0_basicCells.lib
}

set libs {}

foreach lib $LIB_LIST {
    lappend libs [file join $LIB_PATH $lib]
}

read_libs $libs
```

In this example:

```text
set
foreach
lappend
file join
```

are Tcl commands.

```text
read_libs
```

is a Genus command.

Another example:

```tcl
set RTL_SOURCES {
    uart_tx.v
    uart_rx.v
    uart_core.v
}

if {[llength $RTL_SOURCES] > 0} {
    puts "Reading RTL..."
    read_hdl $RTL_SOURCES
}
```

Here:

```text
if / puts / llength
```

control the Tcl script.

```text
read_hdl
```

performs the EDA operation.

---

# Why Tcl Is Used in EDA

EDA tools expose tool-specific commands through a Tcl interpreter.

This allows synthesis flows to combine:

```text
Variables
Loops
Conditions
Lists
File handling
Error handling
Reusable procedures
```

with tool commands such as:

```text
read_hdl
elaborate
syn_generic
syn_map
syn_opt
report_timing
report_area
```

Therefore the relationship is:

```text
Tcl Language
      +
EDA Tool Command API
      =
ASIC Design Automation
```

Tcl provides the automation framework, while Genus commands perform synthesis-specific operations.
