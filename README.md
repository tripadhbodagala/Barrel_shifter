# Barrel_shifter
UVM testbench for a 5-bit sequential barrel shifter (load, left/right logical shift, async active-low reset). Includes directed and random sequences, scoreboard with reference model, functional coverage, SVA assertions, and a Makefile for Synopsys VCS and Questa.

# UVM Verification of a 5-bit Sequential Barrel Shifter

A complete UVM testbench that verifies a 5-bit sequential barrel shifter RTL.
It drives directed and constrained-random stimulus, checks every cycle against a
reference model, and measures functional coverage of all verification scenarios.
Runs on both **Synopsys VCS** and **Siemens Questa**.

---

## Design Under Test

| Signal    | Width | Direction | Description                                   |
|-----------|-------|-----------|-----------------------------------------------|
| `clk`     | 1     | input     | Clock, all updates on the rising edge         |
| `rst_n`   | 1     | input     | Asynchronous, active-low reset                |
| `load`    | 1     | input     | 1 = load `data_in` into `result` (priority)   |
| `dir`     | 1     | input     | 0 = left shift, 1 = right shift               |
| `shift`   | 2     | input     | Shift amount (0 to 3)                         |
| `data_in` | 5     | input     | Data to load                                  |
| `result`  | 5     | output    | Registered output                             |

**Behaviour**

```
if (!rst_n)      result <= 0;                 // async reset
else if (load)   result <= data_in;           // load has priority
else if (!dir)   result <= result << shift;   // logical left, zero fill
else             result <= result >> shift;   // logical right, zero fill
```

---

## Testbench Architecture

```
                 +---------------------------- test ----------------------------+
                 |  +------------------------ environment ---------------------+ |
                 |  |  +------------- agent --------------+                   | |
 sequencee ----> |  |  | sequencer -> driver ----+         |                   | |
 (scenarios)     |  |  |                         |         |                   | |
                 |  |  |              monitor <--+-- DUT   |                   | |
                 |  |  +----------------|-----------------+                    | |
                 |  |                   +--> scoreboard (ref model + coverage) | |
                 |  +----------------------------------------------------------+ |
                 +---------------------------------------------------------------+
```

| Component     | File              | Role                                                              |
|---------------|-------------------|-------------------------------------------------------------------|
| Transaction   | `barrel_txn.sv`   | `rst_n`, `load`, `dir`, `shift`, `data_in`, `result`              |
| Agent config  | `barrel_cfg.sv`   | Virtual interface handle, active/passive setting                  |
| Env config    | `env_cfg.sv`      | Enables agent and scoreboard                                      |
| Driver        | `driver.sv`       | Drives one transaction per clock through the interface            |
| Monitor       | `monitor.sv`      | Samples DUT pins every clock, sends to scoreboard                 |
| Sequencer     | `sequencer.sv`    | Routes sequence items to the driver                               |
| Agent         | `agent.sv`        | Contains driver, monitor and sequencer                            |
| Sequences     | `sequencee.sv`    | Directed and random stimulus for all scenarios                    |
| Scoreboard    | `scoreboard.sv`   | Reference model, expected vs actual check, functional coverage    |
| Environment   | `environment.sv`  | Builds and connects agent and scoreboard                          |
| Test          | `test.sv`         | Builds config, environment, starts sequences                      |
| Interface     | `barrel_if.sv`    | DUT signals and assertions                                        |
| Top           | `top.sv`          | Clock, DUT instance, interface, `run_test()`                      |
| Package       | `barrel_pkg.sv`   | Includes all class files                                          |

---

## Verification Scenarios

### 1. Basic Load and Shift (`seq_basic`)
- Load random data with `load=1` and check the whole value appears in `result`.
- Apply `load=0, dir=0` and check the left shift.
- Load again, apply `load=0, dir=1` and check the right shift.

### 2. Direction Toggle (`seq_dir_toggle`)
- Load data, shift left, then immediately shift right without reloading.
- Repeat left/right toggles with different shift amounts.
- Check the stored value is never corrupted when the direction changes.

### 3. Corner Cases and Stress (`seq_corner`)
- **Load priority:** `load=1` with non-zero `shift` and random `dir`. Only the load must happen.
- **Maximum shift:** `shift=3` on boundary patterns (`11111`, `10000`, `00001`).
- **Zero shift:** `shift=0`. `result` must stay unchanged.
- **Random stress:** many cycles of fully random `load`, `dir`, `shift`, `data_in`, checked against the reference model.

`sequencee` runs all three scenarios back to back on the same sequencer.

---

## Scoreboard

- **Reference model:** a cycle-accurate model of the shifter, including the async reset.
- **Timing alignment:** the monitor samples at each rising edge. The scoreboard predicts
  the result from the previous cycle's inputs, compares it with the DUT, then stores the
  current inputs for the next cycle.
- **Mismatch reporting:** each failure is reported as a `UVM_ERROR` with the expected
  value, the actual value and the inputs that produced it.
- **Final summary:** pass count, fail count, coverage percentage and an overall PASS/FAIL verdict.

## Functional Coverage

| Coverpoint | Bins                                              |
|------------|---------------------------------------------------|
| `shift`    | low (0 to 1), high (2 to 3)                       |
| `load`     | 0, 1                                              |
| `dir`      | left, right                                       |
| `rst_n`    | asserted, deasserted                              |
| `data_in`  | empty (0), low, middle, high, full (31)           |
| `result`   | low, middle, high ranges                          |

## Assertions

- `result` changes only on the rising edge of `clk`.
- `load=1` loads `data_in` into `result` on the next edge.
- `load=0, dir=0` gives a correct logical left shift.
- `load=0, dir=1` gives a correct logical right shift.

---

## Directory Structure

```
barrel_shifter/
├── barrel_shifter.sv    # RTL (DUT)
├── barrel_if.sv         # interface + assertions
├── barrel_pkg.sv        # package
├── barrel_txn.sv
├── barrel_cfg.sv
├── env_cfg.sv
├── driver.sv
├── monitor.sv
├── sequencer.sv
├── agent.sv
├── sequencee.sv
├── scoreboard.sv
├── environment.sv
├── test.sv
├── top.sv
└── sim/
    └── Makefile
```

---

## How to Run

All commands are run from the `sim/` folder. The default simulator is VCS.

```bash
cd sim
make help                         # list all targets

make run_test                     # clean, compile and run (VCS)
make run_test SIMULATOR=Questa    # same with Questa

make regress                      # all tests + merged coverage
make report                       # merge coverage, HTML report
make cov                          # open merged coverage
make view_wave1                   # open waveform (Verdi / Questa)
make clean                        # remove generated files
```

Select a test by UVM name:

```bash
make run_test TEST=test
```

---

## Results

```
========== SCOREBOARD ==========
  pass count : 64
  fail count : 0
  coverage   : 100.00%
  RESULT     : TEST PASSED
================================
```

---

## Tools

- Synopsys VCS T-2022.06-SP1 with Verdi (FSDB waveforms, URG coverage)
- Siemens Questa 2022.1 (WLF waveforms, vcover coverage)
- UVM 1.1d / 1.2
