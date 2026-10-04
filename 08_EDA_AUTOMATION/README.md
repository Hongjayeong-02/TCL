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
setenv SDC_PATH <SDC_FILE_PATH>
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
uart_fifo.v
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
Clock port   : clk
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

Example PASS:

```bash
tclsh parse_timing_report.tcl timing_sample_pass.rpt
```

`timing_sample_pass.rpt` is a synthetic parser-test input, not a real synthesis result.

Example PASS output:

```text
SLACK : 0.420 ns  uart_apb_reg
SLACK : 0.180 ns  uart_irq_reg
SLACK : 0.310 ns  uart_core_reg

WNS : 0.180 ns
RESULT : PASS
```

Example FAIL:

```bash
tclsh parse_timing_report.tcl timing_sample_fail.rpt
```

Example FAIL output:

```text
SLACK : -0.120 ns  u_core/u_rx_fifo/mem_reg[7][3]/D
SLACK : -0.035 ns  u_core/u_tx_fifo/rd_ptr_reg[2]/D
SLACK :  0.040 ns  u_irq/irq_q_reg/D

WNS : -0.120 ns
RESULT : FAIL
```

Criterion:

```text
WNS >= 0  → PASS
WNS <  0  → FAIL
```

The parser uses regular expressions to extract slack values and determines the worst slack automatically.

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
tclsh parse_area_report.tcl area_sample_pass.rpt 2000
```

Example PASS:

```text
TOTAL AREA : 1890.234
AREA LIMIT : 2000.000
RESULT : PASS
```

Example FAIL:

```text
TOTAL AREA : 1890.234
AREA LIMIT : 1800.000
RESULT : FAIL
```

The parser uses `regexp` to extract total cell area and compares it with an optional threshold.

`area_sample_pass.rpt` is a synthetic parser-test input, not a real synthesis result.

---

# 6. Tcl to EDA Automation

The scripts in this directory connect Tcl language features to practical ASIC design automation tasks.

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

The separation is:

```text
Tcl
 └─ configuration / automation / parsing

Cadence Genus
 └─ synthesis / timing / reporting
```

---

# 7. UART V3 Automation Workflow

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
- UART V3 RTL work is reused as a practical automation target,
- synthetic parser samples are clearly separated from real synthesis results,
- real synthesis results are summarized separately in `RESULT.md`.
