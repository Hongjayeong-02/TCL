# 08_EDA_AUTOMATION

Tcl-based automation examples for RTL synthesis preparation, environment checking, and report analysis.

This module connects basic Tcl syntax to an actual ASIC synthesis workflow using the UART V3 RTL project as the main example.

---

## Contents

| File | Purpose |
|---|---|
| `project_setup.tcl` | Basic project setup example |
| `rtl_list.tcl` | RTL source list handling |
| `library_corner.tcl` | Library / corner configuration example |
| `check_design_env.tcl` | Portable EDA environment validation |
| `synthesis_flow_example.tcl` | Synthesis flow structure example |
| `genus_flow_analysis.md` | Tcl and Genus command-role analysis |
| `sdc_timing_flow.md` | SDC / timing-flow notes |
| `uart_filelist_check.tcl` | UART V3 RTL validation and filelist generation |
| `uart_genus_flow.tcl` | UART V3 Cadence Genus synthesis-flow example |
| `parse_timing_report.tcl` | Timing report / WNS parser |
| `parse_area_report.tcl` | Area report parser and threshold check |
| `RESULT.md` | Execution-result summary |

---

# 1. Environment Check

Run:

```bash
tclsh check_design_env.tcl
```

The script checks configured RTL, SDC, library, and EDA-tool environments without embedding personal server paths in the repository.

Environment-dependent paths should be passed through shell environment variables.

For `csh` / `tcsh`:

```csh
setenv UART_RTL_PATH <UART_V3_RTL_DIRECTORY>
setenv PDK_LIB_DIR <PDK_TIMING_LIBRARY_DIRECTORY>
```

This keeps repository scripts portable across different servers and user accounts.

---

# 2. UART V3 Filelist Validation

Run:

```bash
tclsh uart_filelist_check.tcl
```

The script validates the synthesis source set for UART V3.

Expected RTL sources:

```text
uart_baud_gen.v
uart_tx.v
uart_tx_fifo.v
uart_rx.v
uart_rx_fifo.v
uart_core.v
uart_irq.v
uart_apb.v
```

Example result:

```text
PASS : uart_baud_gen.v
PASS : uart_tx.v
PASS : uart_tx_fifo.v
PASS : uart_rx.v
PASS : uart_rx_fifo.v
PASS : uart_core.v
PASS : uart_irq.v
PASS : uart_apb.v

PASS : 8
FAIL : 0
RESULT : PASS
```

If all files exist, the script generates:

```text
filelist_syn.f
```

The generated file contains only relative RTL filenames instead of personal absolute paths.

---

# 3. UART V3 Genus Flow

`uart_genus_flow.tcl` demonstrates how Tcl configuration is connected to Cadence Genus commands.

Conceptual execution:

```bash
genus -f uart_genus_flow.tcl
```

The flow is:

```text
environment variables
        ↓
library setup
        ↓
RTL file validation
        ↓
read_libs
        ↓
read_hdl
        ↓
elaborate
        ↓
constraints
        ↓
syn_generic
        ↓
syn_map
        ↓
syn_opt
        ↓
reports / netlist
```

The top-level design is:

```text
uart_apb
```

The example clock configuration is:

```text
Clock port   : i_pclk
Clock period : 20.0 ns
Frequency    : 50 MHz
```

The current synthesis example uses:

```text
slow_vdd1v0_basicCells.lib
```

The actual library directory is supplied externally through `PDK_LIB_DIR`.

---

# 4. Timing Report Parser

Run:

```bash
tclsh parse_timing_report.tcl <timing_report>
```

Example:

```bash
tclsh parse_timing_report.tcl timing_sample_pass.rpt
```

The script:

1. reads the report,
2. finds slack values using regular expressions,
3. determines the worst slack,
4. reports it as WNS,
5. generates a PASS / FAIL result.

Example PASS:

```text
SLACK : 0.42 ns
SLACK : 0.18 ns
SLACK : 0.31 ns

WNS : 0.180 ns

RESULT : PASS
```

Example FAIL:

```text
SLACK : 0.21 ns
SLACK : -0.08 ns
SLACK : 0.05 ns

WNS : -0.080 ns

RESULT : FAIL
```

Criterion:

```text
WNS >= 0  → PASS
WNS <  0  → FAIL
```

---

# 5. Area Report Parser

Run:

```bash
tclsh parse_area_report.tcl <area_report>
```

With an area limit:

```bash
tclsh parse_area_report.tcl <area_report> <area_limit>
```

Example:

```bash
tclsh parse_area_report.tcl area_sample_pass.rpt 1000
```

Example PASS:

```text
TOTAL AREA : 935.600
AREA LIMIT : 1000.000
RESULT : PASS
```

Example FAIL:

```text
TOTAL AREA : 935.600
AREA LIMIT : 900.000
RESULT : FAIL
```

The parser uses `regexp` to extract total cell area and compares it with an optional threshold.

---

# 6. Tcl to EDA Automation

This module demonstrates how Tcl language features become practical EDA automation components.

```text
Tcl feature               EDA application
--------------------------------------------------
set                       configuration variables
list / lappend            RTL source management
foreach                   source-file iteration
file / file exists        design-file validation
dict                      structured configuration
regexp                    report parsing
regsub                    text transformation
catch / error             flow error handling
argv                      command-line configuration
source                    modular script structure
namespace                 configuration isolation
```

These Tcl commands prepare, validate, and process data.

Genus commands perform synthesis operations:

```text
read_libs
read_hdl
elaborate
create_clock
syn_generic
syn_map
syn_opt
report_timing
report_area
report_power
write_hdl
```

The distinction is important:

```text
Tcl
    → controls and automates the flow

Genus commands
    → execute EDA-specific synthesis operations
```

---

# 7. UART V3 Automation Flow

The UART V3 example links the individual scripts into one workflow.

```text
UART V3 Backend Freeze
        ↓
RTL source definition
        ↓
uart_filelist_check.tcl
        ↓
filelist_syn.f
        ↓
uart_genus_flow.tcl
        ↓
Cadence Genus
        ↓
timing / area reports
        ↓
parse_timing_report.tcl
parse_area_report.tcl
        ↓
PASS / FAIL summary
```

This demonstrates progression from Tcl syntax practice to actual RTL synthesis automation.

---

# Learning Result

Through this module:

- synthesis source files can be validated automatically,
- project-specific absolute paths are removed from version-controlled scripts,
- environment variables are used for portable EDA configuration,
- timing reports can be parsed automatically for WNS,
- area reports can be checked against thresholds,
- Tcl language features are connected to an actual Genus synthesis flow,
- UART V3 RTL work is reused as a practical automation target.
