// Import SPU definitions 
`include "definitions.vh" 

module teenyspu (
    input wire  clk,
    input wire  rst,

    // Data Inputs 
    input  wire `BUSWIDTH A,
    input  wire `BUSWIDTH B,
    input  wire `BUSWIDTH C,
    input  wire `BUSWIDTH D,
    
    // Data Outputs
    output reg  `BUSWIDTH M,
    output reg  `BUSWIDTH N,
    
    // Operation Input
    input  wire `OPWIDTH  Op
);

// Output wires from OP modules 
wire `BUSWIDTH m_distdir, n_distdir; 
wire `BUSWIDTH m_boxarea, n_boxarea; 
wire `BUSWIDTH m_bbuffer, n_bbuffer; 
wire `BUSWIDTH m_reclass, n_reclass; 
wire `BUSWIDTH m_nrmdiff, n_nrmdiff; 
wire `BUSWIDTH m_localop, n_localop; 
wire `BUSWIDTH m_dbldist, n_dbldist; 
wire `BUSWIDTH m_dotprod, n_dotprod; 

// OP modules
op_distdir u_op_distdir(.A(A),.B(B),.C(C),.D(D),.M(m_distdir),.N(n_distdir));
op_boxarea u_op_boxarea(.A(A),.B(B),.C(C),.D(D),.M(m_boxarea),.N(n_boxarea));
op_bbuffer u_op_bbuffer(.A(A),.B(B),.C(C),.D(D),.M(m_bbuffer),.N(n_bbuffer));
op_reclass u_op_reclass(.A(A),.B(B),.C(C),.D(D),.M(m_reclass),.N(n_reclass));
op_nrmdiff u_op_nrmdiff(.A(A),.B(B),.C(C),.D(D),.M(m_nrmdiff),.N(n_nrmdiff));
op_localop u_op_localop(.A(A),.B(B),.C(C),.D(D),.M(m_localop),.N(n_localop));
op_dbldist u_op_dbldist(.A(A),.B(B),.C(C),.D(D),.M(m_dbldist),.N(n_dbldist));
op_dotprod u_op_dotprod(.A(A),.B(B),.C(C),.D(D),.M(m_dotprod),.N(n_dotprod));

always @(posedge clk or posedge rst) begin
    if(rst) begin
            M <= 0;
            N <= 0;
    end else begin
        case (Op)
            `OP_NOP:        begin       // Do nothing, hold M and N values
                            end

            `OP_MINGATE:    begin       M <= (B < D) ? A : C;
                                        N <= (B < D) ? B : D;
                            end

            `OP_EQGATE:     begin       M <= (B == D) ? A : C;
                                        N <= D;
                            end

            `OP_ZEROMN:     begin       M <= 0;
                                        N <= 0;
                            end

            `OP_MEANROW:    begin       M <= (A + B + C) / 3;
                                        N <= (B + C + D) / 3;
                            end

            `OP_SUMROW:     begin       M <= (A + B + C);
                                        N <= (B + C + D);
                            end

            `OP_LCLDIV:     begin       M <= (C == 4'b0000) ? 4'b0000 : A / C;
                                        N <= (D == 4'b0000) ? 4'b0000 : B / D;
                            end
                                        
            `OP_MAXPOOL:    begin       M <= (A > B) ? A : B;
                                        N <= (C > D) ? C : D;
                            end

            `OP_DISTDIR:                {M, N} <= {m_distdir, n_distdir};
            `OP_BOXAREA:                {M, N} <= {m_boxarea, n_boxarea};
            `OP_BBUFFER:                {M, N} <= {m_bbuffer, n_bbuffer};
            `OP_RECLASS:                {M, N} <= {m_reclass, n_reclass};

            `OP_NRMDIFF:                {M, N} <= {m_nrmdiff, n_nrmdiff};
            `OP_LOCALOP:                {M, N} <= {m_localop, n_localop}; 
            `OP_DBLDIST:                {M, N} <= {m_dbldist, n_dbldist};
            `OP_DOTPROD:                {M, N} <= {m_dotprod, n_dotprod};

            default:        begin       M <= 0; 
                                        N <= 0; 
                            end
        endcase
    end
end
endmodule
