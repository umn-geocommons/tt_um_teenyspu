`timescale 1ns / 1ps

`include "definitions.vh"  // Set our definitions for this SPU 

/*
//  Control Ops
OP_NOP      4'b0000
OP_MINGATE  4'b0001
OP_EQGATE   4'b0010
OP_ZEROMN   4'b0011
 
//   Vector Ops
OP_DISTDIR  4'b0100
OP_BOXAREA  4'b0101
OP_BBUFFER  4'b0110
OP_RECLASS  4'b0111
 
//   Raster Ops
OP_MEANROW  4'b1000
OP_SUMROW   4'b1001
OP_LCLDIV   4'b1010
OP_MAXPOOL  4'b1011
 
//Multispec Raster Ops
OP_NRMDIFF  4'b1100
OP_LOCALOP  4'b1101
 
//    8-bit Ops
OP_DBLDIST  4'b1110
OP_DOTPROD  4'b1111
*/



module tb_tt_um_teenyspu;

    // 1. Declare Signals
    reg [7:0] ui_in;
    reg [7:0] uio_in;
    reg       ena;
    reg       clk;
    reg       rst_n;

    wire [7:0] uo_out;
    wire [7:0] uio_out;
    wire [7:0] uio_oe;

    // 2. Instantiate the Unit Under Test (UUT)
    tt_um_teenyspu uut (
        .ui_in(ui_in),
        .uo_out(uo_out),
        .uio_in(uio_in),
        .uio_out(uio_out),
        .uio_oe(uio_oe),
        .ena(ena),
        .clk(clk),
        .rst_n(rst_n)
    );

    // 3. Clock Generation (100MHz / 10ns period)
    always #5 clk = ~clk;

    /*
    reg `BUSWIDTH ioh, iol;
    reg `BUSWIDTH M, N;
    reg `OPWIDTH Op, Q;
    */

    task spu_setup();
        begin

            // Initialize inputs
            clk    = 0;
            rst_n  = 0;
            ena    = 1;
            ui_in  = 0;
            uio_in = 0;
            
            #20 rst_n = 1;

        end
    endtask

    task spu_test(input [7:4] exp_h, input [3:0] exp_l, input [127:0] test_name);
        begin
            if (uo_out[7:4] == exp_h && uo_out[3:0] == exp_l) $display("PASS+            %-s    ", test_name);
            else                                              $display("FAIL- ---------  %-s !!!\n---------------\n", test_name);
        end
    endtask 

    task spu_inst(input [3:0] instr_h);
        begin
            ui_in  = {instr_h, `QOP_NOP};
            #20; // clk tik, clk tok 
        end
    endtask

    task spu_data(input [3:0] instr_l, input [3:0] dataq_h, input [3:0] dataq_l);
        begin
            ui_in  = {`OP_NOP, instr_l};
            uio_in = {dataq_h, dataq_l};
            #10; // clk tik 
        end
    endtask

    task spu_wait();
        begin
            #20; // clk tik twice
        end
    endtask


    task spu_stst(input [3:0] data_a, input [3:0] data_b, 
                  input [3:0] data_c, input [3:0] data_d, 
                  input [3:0] inst_i, 
                  input [3:0] test_m, input [3:0] test_n, 
                  input [127:0] test_name);
        begin
            spu_wait();
            spu_data(`QOP_LDAB, data_a, data_b);
            spu_data(`QOP_LDCD, data_c, data_d);
            spu_inst(inst_i);
            spu_test(test_m, test_n, test_name);
        end
    endtask





    // 4. Stimulus Block
    initial begin
        // Setup waveform dumping for GTKWave
        $dumpfile("sim_dump.vcd");
        $dumpvars(0, tb_tt_um_teenyspu);

    /*
        // Initialize inputs
        clk    = 0;
        rst_n  = 0;
        ena    = 1;
        ui_in  = 0;
        uio_in = 0;

        //[7:0] ui_in,  // Dedicated inputs  [7:4] = Op, [3:0] = Q
        //[7:0] uo_out, // Dedicated outputs [7:4] = M,  [3:0] = N
        //[7:0] uio_in, // IOs: Input path   [7:4] = ABC [3:0] = BCD (see Q) 
        // Release Reset after 20ns
        #20 rst_n = 1;
    */
    
        spu_setup();

        



        // Test Case 1: HLHL. sumrow
        spu_data(`QOP_HLHL, 4'd6   , 4'd1     );
        spu_inst(`OP_SUMROW);
        spu_test(13, 8, "SUMROW");

        // Set A B C D = 6 1 6 1
        //ui_in  = {`OP_NOP, `QOP_HLHL};
        //uio_in = {4'd6   , 4'd1     };

        // Test Case 2: ZEROMN.
        spu_wait();
        spu_inst(`OP_ZEROMN);
        spu_test(0, 0, "ZEROMN");


        // Test Case 3: BOXAREA
        spu_wait();
        spu_data(`QOP_HHLL, 4'd2   , 4'd5);
        spu_inst(`OP_BOXAREA);
        spu_test(9, 12, "BOXAREA");
        
        
        // Test Case 4: CHANGE A, BOXAREA REPEAT
        // Set A B C D = 1 x x x 
        //ui_in  = {`OP_NOP, `QOP_LDL_A};
        //uio_in = {4'd2   , 4'd1     };
        //#10; // Set ABCD = 1xxx 
        

        spu_wait();
        spu_data(`QOP_LDL_A, 4'd2   , 4'd1);
        spu_inst(`OP_BOXAREA);
        spu_test(12, 14, "BOXAREA 2");

        // Test Case 5: DISTDIR
        spu_wait();
        // Reuse A B C D = 1 2 5 5
        spu_inst(`OP_DISTDIR);
        spu_test(7, 1, "DISTDIR");


        //Reminder
        //`define QOP_LDAB     4'b0100 //           h l C D
        //`define QOP_LDCD     4'b0101 //           A B h l

        $display("NEWSET");

        /* 
        spu_wait();
        spu_data(`QOP_LDAB, 4'd7   , 4'd3);
        spu_data(`QOP_LDCD, 4'd2   , 4'd5);
        spu_inst(`OP_MINGATE);
        spu_test(7, 3, "MINGATE (b < d)");

        spu_wait();
        spu_data(`QOP_LDAB, 4'd9   , 4'd8);
        spu_data(`QOP_LDCD, 4'd1   , 4'd4);
        spu_inst(`OP_MINGATE);
        spu_test(1, 4, "MINGATE (b > d)");
        */

        spu_stst( 7,  3,  2,  5, `OP_MINGATE,  7,  3, "MINGATE (b  < d)");
        spu_stst( 9,  8,  1,  4, `OP_MINGATE,  1,  4, "MINGATE (b  > d)");
        spu_stst(15, 10,  5, 10, `OP_MINGATE,  5, 10, "MINGATE (b == d)");
        spu_stst( 0,  0,  0,  1, `OP_MINGATE,  0,  0, "MINGATE (zero check)");

        spu_stst( 9,  5,  2,  5, `OP_EQGATE,  9,  5, "EQGATE   (b == d)");
        spu_stst( 1,  8, 12,  3, `OP_EQGATE, 12,  3, "EQGATE   (b != d)");
        spu_stst( 0,  0, 14,  0, `OP_EQGATE,  0,  0, "EQGATE   (zero match)");
        spu_stst( 7, 14,  0, 15, `OP_EQGATE,  0, 15, "EQGATE   (max b != d)");

        


        // Wait and Finish
        spu_wait();
        spu_wait();
        spu_wait();
        $display("Simulation complete. Check the waveforms.");
        $finish;
    end

    // Optional: Monitor changes in the terminal
    initial begin
        $monitor("Time: %8t | op: %b | q: %b | ioh: %b | iol: %b | m: %d | n: %d", 
              $time, ui_in[7:4],  ui_in[3:0], 
                     uio_in[7:4], uio_in[3:0], 
                     uo_out[7:4], uo_out[3:0]);
        //$monitor("Time: %0t | ui_in: %b | uio_in: %b | uo_out: %b | M: %d | N: %d", 
        //      $time, ui_in, uio_in, uo_out, M, N);
        //$monitor("Time: %0t | ui_in: %d | uio_in: %d | uo_out: %d", 
        //      $time, ui_in, uio_in, uo_out);
        //$monitor("Time: %0t | clk: %b | ui_in: %d | uio_in: %d | uo_out: %d", 
        //      $time, clk, ui_in, uio_in, uo_out);
        //$monitor("At time %t: ui_in=%d, uio_in=%d, Result (uo_out)=%d", 
        //         $time, ui_in, uio_in, uo_out);
    end

endmodule
