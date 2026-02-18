// Import SPU definitions 
`include "definitions.vh" 

module qteenyspu (
    input wire clk,
    input wire rst,

    // Data Inputs 
    input  wire `TTWIDTH uio_in,
    input  wire `OPWIDTH Op_in,
    input  wire `OPWIDTH Q_in,
    
    // Data Outputs
    output reg  `BUSWIDTH A,
    output reg  `BUSWIDTH B,
    output reg  `BUSWIDTH C,
    output reg  `BUSWIDTH D,
   
    // Op is also output so the delay from reg aligns with values ABCD 
    output reg  `OPWIDTH Op
);

// Get high [7:4] and low [3:0] IO values from uio_in
wire `BUSWIDTH ioh, iol;

assign ioh = uio_in[7:4];
assign iol = uio_in[3:0];

always @(posedge clk or posedge rst) begin
    if(rst) begin
        A <= 0; 
        B <= 0;
        C <= 0;
        D <= 0; 
        Op <= 0;
    end else begin
        // Save Op_in in Op reg 
        Op <= Op_in;

        case (Q_in)
            // NOP AND ZERO OPS
            `QOP_NOP:       begin           // Do nothing
                            end

            `QOP_ZEROAB:    begin           A <= 0; 
                                            B <= 0;
                            end

            `QOP_ZEROCD:    begin           C <= 0;
                                            D <= 0; 
                            end

            `QOP_ZEROABCD:  begin           A <= 0; 
                                            B <= 0;
                                            C <= 0;
                                            D <= 0; 
                            end

            // Load AB, CD, AC, BD 
            `QOP_LDAB:      begin           A <= ioh;
                                            B <= iol;
                            end

            `QOP_LDCD:      begin           C <= ioh;
                                            D <= iol;
                            end

            `QOP_LDAC:      begin           A <= ioh;
                                            C <= iol;
                            end

            `QOP_LDBD:      begin           B <= ioh;
                                            D <= iol;
                            end

            // Load from Low (LDL) iol -> A, B, C, D 
            `QOP_LDL_A:                     A <= iol;
            `QOP_LDL_B:                     B <= iol;
            `QOP_LDL_C:                     C <= iol;
            `QOP_LDL_D:                     D <= iol;

            // BCAST OPS Load from High/Low 
            `QOP_HLHL:      begin           A <= ioh;
                                            B <= iol;
                                            C <= ioh;
                                            D <= iol;
                            end

            `QOP_HHLL:      begin           A <= ioh;
                                            B <= ioh;
                                            C <= iol;
                                            D <= iol;
                            end

            `QOP_LHLH:      begin           A <= iol;
                                            B <= ioh;
                                            C <= iol;
                                            D <= ioh;
                            end // SWAP POSITIONS

            `QOP_LABCD:     begin           A <= iol;
                                            B <= iol;
                                            C <= iol;
                                            D <= iol;
                            end // BCAST Low to ABCD

            default:        begin           A <= 0; 
                                            B <= 0;
                                            C <= 0;
                                            D <= 0; 
                            end
        endcase
    end
end
endmodule
