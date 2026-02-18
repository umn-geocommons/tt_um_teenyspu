/*
 * Copyright (c) 2024 Eric Shook 
 * SPDX-License-Identifier: Apache-2.0
 */

`include "definitions.vh"  // Set our definitions for this SPU 

`default_nettype none

// module specification for the TinyTapeout (DO NOT CHANGE)
module tt_um_teenyspu (
    input  wire [7:0] ui_in,    // Dedicated inputs    [7:4] = Op, [3:0] = Q
    output wire [7:0] uo_out,   // Dedicated outputs   [7:4] = M,  [3:0] = N
    input  wire [7:0] uio_in,   // IOs: Input path     [7:4] = ABC [3:0] = BCD (see Q) 
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // always 1 when the design is powered, so ignore it
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);

    // Generate active-high reset (readability).
    wire rst = ~rst_n;

    // Wires to connect Op(_in) and Q(_in) from ui_in
    wire `OPWIDTH Op_in = ui_in[7:4];
    wire `OPWIDTH Q_in  = ui_in[3:0];

    // Wires to connect Q to SPU 
    wire `BUSWIDTH A, B, C, D;
    wire `OPWIDTH  Op;
    
    // Wires to connect SPU to uo_out in TinyTapeout
    wire `BUSWIDTH M, N; 
    assign uo_out = {M, N};

    // Tie unused outputs to zero.
    assign uio_out = 8'b0; // Ignored in SPU
    assign uio_oe  = 8'b0; // 0 flags uio for _in, not _out
    
    // Generate teenyq as the operating IO queue for the SPU (QSPU)
    qteenyspu qspu( .clk(clk),
                    .rst(rst),
                    .uio_in(uio_in),
                    .Op_in(Op_in),
                    .Q_in(Q_in),
                    .A(A), 
                    .B(B), 
                    .C(C), 
                    .D(D),
                    .Op(Op)
                );

    // Generate teenyspu as the operating SPU 
    teenyspu spu(   .clk(clk), 
                    .rst(rst), 
                    .A(A), 
                    .B(B), 
                    .C(C), 
                    .D(D), 
                    .M(M), 
                    .N(N), 
                    .Op(Op)
                );

endmodule
