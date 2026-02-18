// Library for SPU ops

// Import SPU definitions 
`include "definitions.vh"

module op_distdir(
    input  wire `BUSWIDTH A,
    input  wire `BUSWIDTH B,
    input  wire `BUSWIDTH C,
    input  wire `BUSWIDTH D,
    output wire `BUSWIDTH M,
    output wire `BUSWIDTH N
 );

    // Compute absolute differences.
    wire `BUSWIDTH deltaX = (A > C) ? (A - C) : (C - A);    // |x1 - x2|
    wire `BUSWIDTH deltaY = (B > D) ? (B - D) : (D - B);    // |y1 - y2|

    reg [2:0] aspect_code;
    always @(*) begin
        if ((deltaX == 0) && (deltaY == 0))
            aspect_code = 3'd0;                             // default: North
        else if (deltaX == 0) begin
            if (B < D)
                aspect_code = 3'd0;                         // North      = 0
            else
                aspect_code = 3'd4;                         // South      = 4
        end else if (deltaY == 0) begin
            if (A < C)
                aspect_code = 3'd2;                         // East       = 2
            else
                aspect_code = 3'd6;                         // West       = 6
        end else if (A < C) begin 
            if (B < D)
                aspect_code = 3'd1;                         // Northeast  = 1
            else 
                aspect_code = 3'd3;                         // Southeast  = 3
        end else if (A > C) begin
            if (B < D)
                aspect_code = 3'd7;                         // Northwest  = 7
            else
                aspect_code = 3'd5;                         // Southwest  = 5
        end else
            aspect_code = 3'd0;                             // default: North
    end

    assign M = deltaX + deltaY;     // Manhattan Distance = |x1 - x2| + |y1 - y2|
    assign N = aspect_code;         // N=0, NE=1, E=2, SE=3, S=4, SW=5, W=6, NW=7

endmodule


module op_boxarea(
    input  wire `BUSWIDTH A,
    input  wire `BUSWIDTH B,
    input  wire `BUSWIDTH C,
    input  wire `BUSWIDTH D,
    output wire `BUSWIDTH M,
    output wire `BUSWIDTH N
 );
 
    wire `BUSWIDTH deltaX = (C > A) ? (C - A) : (A - C); // Width
    wire `BUSWIDTH deltaY = (D > B) ? (D - B) : (B - D); // Height

    assign M = deltaX * deltaY;                      // A = H * W
    assign N = (deltaX << 1) + (deltaY << 1);        // P = 2*H + 2*W
endmodule


module op_bbuffer(
    input  wire `BUSWIDTH A,
    input  wire `BUSWIDTH B,
    input  wire `BUSWIDTH C,
    input  wire `BUSWIDTH D,
    output wire `BUSWIDTH M,
    output wire `BUSWIDTH N
 );
    // WARNING: NO OVERFLOW PROTECTION. SIMPLE BUFFER OP.

    // Buffer distance is fixed at '2' 
    wire `BUSWIDTH buffer = `WIDTH'd2;  

    /*
    wire hor, ver;
    wire rt, up;
    assign hor = (B == D); // Is the line horizontal?
    assign ver = (A == C); // Is the line vertical?

    assign rt = (C > A);   // Is the line going right? 
    assign up = (D > B);   // Is the line going up?
    */

    
    wire hor = (B == D); // Is the line horizontal?
    wire ver = (A == C); // Is the line vertical?

    wire rt = (C > A);   // Is the line going right? 
    wire up = (D > B);   // Is the line going up?
    
    reg `BUSWIDTH buffer_x;
    reg `BUSWIDTH buffer_y;

    always @(*) begin

        if (hor && ver) begin               // ERROR DIAGONAL LINE
            buffer_x = 0;
            buffer_y = 0;
        end else if (!hor && !ver) begin    // ERROR NO LINE
            buffer_x = 0;
            buffer_y = 0;
        end else begin                       
            if (hor) begin                  // HORIZONTAL 
                if (rt) begin               //            RIGHT LINE
                    buffer_x = A - buffer;  // buf left
                    buffer_y = B - buffer;  // buf down
                end else begin              //             LEFT LINE
                    buffer_x = A + buffer;  // buf right 
                    buffer_y = B + buffer;  // buf up
                end 
            end else begin                  // VERTICAL
                if (up) begin               //               UP LINE
                    buffer_x = A + buffer;  // buf right
                    buffer_y = B - buffer;  // buf down
                end else begin              //             DOWN LINE
                    buffer_x = A - buffer;  // buf left
                    buffer_y = B + buffer;  // buf up
                end 
            end
        end
    end

    assign M = buffer_x;
    assign N = buffer_y;

    /*
    // Buffer distance is fixed at '2' 
    wire `BUSWIDTH buffer_distance = `WIDTH'd2;  

    wire dirx = C > A;  // Positive or 0 X
    wire diry = D > B;  // Positive or 0 Y

    wire `BUSWIDTH dx = (C > A) ? (C - A) : (A - C); // Width
    wire `BUSWIDTH dy = (D > B) ? (D - B) : (B - D); // Height

    // Determine X buffer value
    wire `BUSWIDTH buffer_x_pos = A + buffer_distance;
    wire `BUSWIDTH buffer_x_neg = A - buffer_distance;

    // Determine Y buffer value
    wire `BUSWIDTH buffer_y_pos = B + buffer_distance;
    wire `BUSWIDTH buffer_y_neg = B - buffer_distance;

    // Directly assign M and N based on conditions
    assign M = (dy == `WIDTH'd0) ? (dirx ? buffer_x_neg : buffer_x_pos) :
               (dx == `WIDTH'd0) ? (diry ? buffer_x_pos : buffer_x_neg) : A;

    assign N = (dy == `WIDTH'd0) ? (dirx ? buffer_y_neg : buffer_y_pos) :
               (dx == `WIDTH'd0) ? (diry ? buffer_y_neg : buffer_y_pos) : B;
    */
endmodule


module op_reclass(
    input  wire `BUSWIDTH A,
    input  wire `BUSWIDTH B,
    input  wire `BUSWIDTH C,
    input  wire `BUSWIDTH D,
    output wire `BUSWIDTH M,
    output wire `BUSWIDTH N
 );
    // M = 3 classes C > A == 1, C <= A and C >= B == 2, C < B == 3, 
    // N = 2 classes C > D == 1, C <= D == 2 

    assign M = (C > A) ? `WIDTH'd1 :
                        ((C <= A && C >= B) ? `WIDTH'd2 : `WIDTH'd3);
    assign N = (C > D) ? `WIDTH'd1 : `WIDTH'd2;


    /*
    wire [3:0] attr_r3; // 3 classes C>A == 1, C<B == 3, C<=A and C>=B == 2
    wire [3:0] attr_r2; // 2 classes C>=D == 0, C<D == 5


    assign attr_r3 = (C > A) ? 4'd1 :
                       ((C <= A && C >= B) ? 4'd2 : 4'd3);

    assign attr_r2 = (C >= D) ? 4'd0 : 4'd5;

    assign M = attr_r3; // Set 3 class, reclassification to M
    assign N = attr_r2; // Set 2 class, reclassification to N
    */
endmodule


module op_nrmdiff(
    input  wire `BUSWIDTH A,
    input  wire `BUSWIDTH B,
    input  wire `BUSWIDTH C,
    input  wire `BUSWIDTH D,
    output wire `BUSWIDTH M,
    output wire `BUSWIDTH N
 );
    
    /*
    NDVI (Normalized Difference Vegetation Index)
    NDVI Example: NIR[0] = A, NIR[1] = B, RED[0] = C, RED[1] = D
                  (A-C) / (A+C) == (NIR - RED) / (NIR + RED) @ 0
                  (B-D) / (B+D) == (NIR - RED) / (NIR + RED) @ 1
    NDWI (Normalized Difference Water Index - Must reverse NIR LOCATION)
    NDWI Example: GREEN[0] = A, GREEN[1] = B, NIR[0] = C, NIR[1] = D
                  (A-C) / (A+C) == (GREEN - NIR) / (GREEN + NIR) @ 0
                  (B-D) / (B+D) == (GREEN - NIR) / (GREEN + NIR) @ 1
    NBR (Normalized Burn Ratio)
    NBR Example: NIR[0] = A, NIR[1] = B, SWIR[0] = C, SWIR[1] = D
                  (A-C) / (A+C) == (NIR - SWIR) / (NIR + SWIR) @ 0
                  (B-D) / (B+D) == (NIR - SWIR) / (NIR + SWIR) @ 1
    */
  
    // Cast ABCD to (one-bit larger) signed type to handle subtraction
    wire signed [`WIDTH:0] A_s = $signed({1'b0, A});
    wire signed [`WIDTH:0] B_s = $signed({1'b0, B});
    wire signed [`WIDTH:0] C_s = $signed({1'b0, C});
    wire signed [`WIDTH:0] D_s = $signed({1'b0, D});

    // Equivalent to NIR-RED and NIR+RED
    wire signed [`WIDTH+1:0] AC_sub_s = A_s - C_s; 
    wire signed [`WIDTH+1:0] AC_sum_s = A_s + C_s;

    wire signed [`WIDTH+1:0] BD_sub_s = B_s - D_s; 
    wire signed [`WIDTH+1:0] BD_sum_s = B_s + D_s;

    // We want 3 fractional bits, so we shift left by 3.
    // 6 bits (diff) + 3 bits (shift) = 9 bits needed.
    reg signed [8:0] AC_scaled_s; // = AC_sub_s <<< 3;
    reg signed [8:0] BD_scaled_s; // = BD_sub_s <<< 3;

    //wire signed [8:0] AC_scaled_s = AC_sub_s <<< 3;
    //wire signed [8:0] BD_scaled_s = BD_sub_s <<< 3;

    always @(*) begin
        if (AC_sum_s == 0) begin // Avoid div by 0
            AC_scaled_s = 0;
        end else begin
            AC_scaled_s = (AC_sub_s <<< 3) / AC_sum_s;

            // SATURATION LOGIC
            // 4-bit signed max is +7. 
            // A perfect NDVI of 1.0 would be +8, which overflows to -8.
            // We must clamp the result.
            if (AC_scaled_s > 7)        AC_scaled_s = 4'b0111; // Clamp to +0.875
            else if (AC_scaled_s < -8)  AC_scaled_s = 4'b1000; // Clamp to -1.0
        end

        if (BD_sum_s == 0) begin // Avoid div by 0
            BD_scaled_s = 0;
        end else begin
            BD_scaled_s = (BD_sub_s <<< 3) / BD_sum_s;
            
            if (BD_scaled_s > 7)        BD_scaled_s = 4'b0111; // Clamp to +0.875
            else if (BD_scaled_s < -8)  BD_scaled_s = 4'b1000; // Clamp to -1.0
        end

    end

    // Pull only lowest 4-bits
    assign M = AC_scaled_s[3:0];
    assign N = BD_scaled_s[3:0];

    /*

    // Cast inputs to a larger signed type
    wire signed [4:0] sA = $signed({1'b0, A});
    wire signed [4:0] sB = $signed({1'b0, B});
    wire signed [4:0] sC = $signed({1'b0, C});
    wire signed [4:0] sD = $signed({1'b0, D});
    
    wire signed [9:0] num_ndiAC, tdn_ndiAC;
    wire signed [9:0] num_ndiBD, tdn_ndiBD;

    wire signed [9:0] scaled_ndiAC, scaled_ndiBD;
    wire [3:0] ndiAC, ndiBD;

    // TEST MORE :)    

    assign num_ndiAC = (sA - sC) * 16; // Equivalent to (NIR - Red) * 16 for NDVI (A-C) * 16
    assign tdn_ndiAC = (sA + sC) * 16; // Equivalent to (NIR + Red) * 16 for NDVI (A+C) * 16

    assign num_ndiBD = (sB - sD) * 16; // Equivalent to (NIR - Red) * 16 for NDVI
    assign tdn_ndiBD = (sB + sD) * 16; // Equivalent to (NIR + Red) * 16 for NDVI
    
    // Watch for division by 0 error: if (A+C)==0 or (B+D)==0, output 0
    // Compute scaled NDVI, NDWI, and NBR in range [-16, 16]
    assign scaled_ndiAC = (tdn_ndiAC == 0) ? 0 : (((num_ndiAC * 8) / tdn_ndiAC) + 8);
    assign scaled_ndiBD = (tdn_ndiBD == 0) ? 0 : (((num_ndiBD * 8) / tdn_ndiBD) + 8);

    // Map result to 4-bit output (0-15)
    assign ndiAC = (scaled_ndiAC > 15) ? 15 : scaled_ndiAC[3:0];
    assign ndiBD = (scaled_ndiBD > 15) ? 15 : scaled_ndiBD[3:0];

    assign M = ndiAC;
    assign N = ndiBD;
    
    */

endmodule


module op_localop(
    input  wire `BUSWIDTH A,
    input  wire `BUSWIDTH B,
    input  wire `BUSWIDTH C,
    input  wire `BUSWIDTH D,
    output wire `BUSWIDTH M,
    output wire `BUSWIDTH N
 );
    // D high holds op1, D low holds op2

    reg [7:0] op1_result; // intermediate result for op1  (A op1 B)
    reg [7:0] op2_result; // intermediate result for op2 ((A op1 B) op2 C)

    // Note: {4'b0000, A} turns A from 4-bits to 8 bits

    always @(*) begin
        // Determine op1 based on D[3:2]
        case (D[3:2])
            2'b00: op1_result = {4'b0000, A} & {4'b0000, B};          // 00 = bitwise AND
            2'b01: op1_result = {4'b0000, A} | {4'b0000, B};          // 01 = bitwise OR
            2'b10: op1_result = {4'b0000, A} + {4'b0000, B};          // 10 = addition
            2'b11: op1_result = {4'b0000, A} * {4'b0000, B};          // 11 = multiplication
            default: op1_result = 0;
        endcase
        
        // Determine op2 based on D[1:0]
        case (D[1:0])
            2'b00: op2_result = op1_result & {4'b0000, C}; // 00 = bitwise AND
            2'b01: op2_result = op1_result | {4'b0000, C}; // 01 = bitwise OR
            2'b10: op2_result = op1_result + {4'b0000, C}; // 10 = addition
            2'b11: op2_result = op1_result * {4'b0000, C}; // 11 = multiplication
            default: op2_result = 0;
        endcase
    end
    
    // Lower 4 bits of op1_result to M
    assign M = op1_result[`WIDTH-1:0];

    // Assign lower 4 bits of res to N
    assign N = op2_result[`WIDTH-1:0];
 
endmodule


module op_dbldist(
    input  wire `BUSWIDTH A,
    input  wire `BUSWIDTH B,
    input  wire `BUSWIDTH C,
    input  wire `BUSWIDTH D,
    output wire `BUSWIDTH M,
    output wire `BUSWIDTH N
 );
 
     wire [7:0] distance; // 8-bit Manhattan Distance
 
     // Compute absolute differences.
     wire `BUSWIDTH deltaX = (A > C) ? (A - C) : (C - A); // |x1 - x2|
     wire `BUSWIDTH deltaY = (B > D) ? (B - D) : (D - B); // |y1 - y2|

     // Distance addition with 8-bit can handle larger distance values. 
     assign distance = {4'b0000, deltaX} + {4'b0000, deltaY};
 
    // Deconstruct high and low 4-bits. Save into M (high) and N (low) 8-bit dist 
     assign M = distance[7:4]; // M = High 4-bits
     assign N = distance[3:0]; // N = Low 4-bits
endmodule


module op_dotprod(
    input  wire `BUSWIDTH A,
    input  wire `BUSWIDTH B,
    input  wire `BUSWIDTH C,
    input  wire `BUSWIDTH D,
    output wire `BUSWIDTH M,
    output wire `BUSWIDTH N
 );
    wire [7:0] prod;  // 8-bit product of A and B
    wire [7:0] accum; // 8-bit accumulated sum (input)
    wire [7:0] sum;   // 8-bit final sum

    // Compute the dot product (multiplication)
    assign prod = {4'b0000, A} * {4'b0000, B}; // 4-bit * 4-bit = 8-bit result


    // Reconstruct the accumulated sum from C (high 4-bits) and D (low 4-bits)
    assign accum = {C, D}; // Concatenating C and D to form 8-bit value

    // Compute the final sum
    assign sum = prod + accum;

    // Deconstruct high and low 4-bits. Save into M (high) and N (low) 8-bit sum
    assign M = sum[7:4]; // High 4-bits
    assign N = sum[3:0]; // Low 4-bits
 
endmodule


