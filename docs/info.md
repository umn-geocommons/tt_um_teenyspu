<!---

This file is used to generate your project datasheet. Please fill in the information below and delete any unused
sections.

You can also include images in this folder and reference them in the markdown. Each image must be less than
512 kb in size, and the combined size of all images must be less than 1 MB.
-->

# TeenySPU on TinyTapeout Technical Docs

3.22.26 (Eric Shook, Logan Gall)

We developed a TeenySPU for the TinyTapeout architecture. TinyTapeout includes 8-bit input (INP), 8-bit output (OUT), and 8-bit input/output-swappable (UIO). The TeenySPU is a 4-bit architecture, so the 8-bit INP, OUT, and UIO are split into two 4-bit sections, high and low. The high 4-bits of INP provide the 4-bit opcode, the low 4-bits of INP control a Q MUX to select how input data from UIO is routed to inputs A, B, C, and D. The 4-bit outputs M and N are routed to OUT high and OUT low, respectively. For more details on the TinyTapeout specs, see: https://tinytapeout.com/specs

<img src="TeenySPU-1.0-TinyTapeout.png"/>

## Hardware Structure

TinySPU is structured to function within the limitations of the TinyTapeout project spec. In general, this means:

* ~50MHz Clock rate
* 8 bits of Input (designated to OpCode & QMux)
* 8 bits of Output (designated to M and N outputs)
* 8 bits of UIO (designated to ABCD inputs)

## How it works

Explain how your project works

## How to test

The Verilog code can be run in the HDL software of your choice, with src/tt_um_teenyspu.v as the top-level module.

File test/tb_tt_um_teenyspu.v contains a testbench of all operations programmed for the TeenySPU. This can be set as a simulation source.

## External hardware

List external hardware used in your project (e.g. PMOD, LED display, etc), if any
