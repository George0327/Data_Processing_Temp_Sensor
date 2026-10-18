# Real-Time Sensor Data Processing on FPGA (VHDL)

A streaming pipeline in VHDL that filters, aggregates and summarises temperature readings. It was the project for Structure of Computer Systems at the Technical University of Cluj-Napoca (target board: Nexys 4, Xilinx Vivado). Every stage talks to the next through the **AXI4-Stream** handshake (`tvalid` / `tready` / `tdata`).

## Pipeline

```
 temp in ──▶ Filter ──▶ FIFO ──▶ Aggregation ──▶ FIFO ──▶ Broadcaster ─┬─▶ Statistics ──▶ avg / min / max ─┐
 (8-bit)                                                               └─▶ raw data ─────────────────────────┤
                                                                                                                ▼
                                                                                          Display sequencer ──▶ output
                                                                                          (button selects the stream)
```

| Module | What it does |
|---|---|
| `Filter.vhd` | Accepts only plausible readings, between -20 °C and 40 °C (signed 8-bit). Out-of-range readings are not forwarded; a previously buffered value is substituted. |
| `Aggregation.vhd` | Moving average over a window of 8 samples. |
| `statistics.vhd` | Average over a sliding window of the last 8 samples, plus the running minimum and maximum since reset. |
| `display_sequencer.vhd` | Multiplexes the four result streams (average, minimum, maximum, raw data). A button press cycles through them. |
| `data_processing.vhd` | Top level that connects all stages with two AXI-Stream FIFOs (`fifo8x32`) and an AXI-Stream broadcaster (Xilinx IP). |
| `testing.vhd` | Wrapper used for simulation. |

Testbenches are in `Temp_data.srcs/sim_1/new/` (`tb_filter`, `tb_aggregation`, `tb_statistics`, `tb_display_sequencer`, `tb_data_processing`, `tb_testing`).

## Run

1. Open Vivado and create a project, or open `Temp_data.srcs` sources in a new one.
2. Add the sources from `Temp_data.srcs/sources_1/new/` and the IP in `sources_1/ip/` (`fifo8x32`, `axis_broadcaster_0`).
3. Set a testbench from `sim_1/new/` as the simulation top and run the behavioural simulation.

## Scope

The original project description also covers receiving readings from a microcontroller over a serial link and driving a 7-segment display. This repository contains the **data-processing pipeline and its testbenches**; the UART receiver and display driver are not part of it.
