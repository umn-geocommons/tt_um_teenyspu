// Check if definitions have already been defined, if not, then define them all.
`ifndef SPUDEFS_VH
`define SPUDEFS_VH

// // // // // // // //
//   System defined  //
// // // // // // // //

// Named sizes for architectural clarity
`define TOY     2
`define TEENY   4
`define TINY    8
`define TRIM    16
`define TYPICAL 32
`define TITAN   64

// TinyTapeout definitions
`define TINYTAPEOUTWIDTH 8



// // // // // // // //
//    User defined   //
// // // // // // // //

// Named sizes for this architecture

// Set (data) width/size to the teeny size for this chip
`define WIDTH `TEENY

// Set (op) width/size to the teeny size for this chip
`define OPSIZE `TEENY


// SPU opcodes

// Control Ops
`define OP_NOP      4'b0000
`define OP_MINGATE  4'b0001 
`define OP_EQGATE   4'b0010
`define OP_ZEROMN   4'b0011

// Vector Ops 
`define OP_DISTDIR  4'b0100
`define OP_BOXAREA  4'b0101
`define OP_BBUFFER  4'b0110
`define OP_RECLASS  4'b0111

// Raster Ops 
`define OP_MEANROW  4'b1000
`define OP_SUMROW   4'b1001
`define OP_LCLDIV   4'b1010
`define OP_MAXPOOL  4'b1011

// Multispec Raster
`define OP_NRMDIFF  4'b1100
`define OP_LOCALOP  4'b1101

// 8-bit Ops
`define OP_DBLDIST  4'b1110
`define OP_DOTPROD  4'b1111



// Q opcodes

// Input is high or low (h or l)
// h = uio_in[7:4], l = uio_in[3:0]    
//                                        A B C D
// NOP and ZEROS                          -------
`define QOP_NOP      4'b0000 //           A B C D
`define QOP_ZEROAB   4'b0001 //           0 0 C D
`define QOP_ZEROCD   4'b0010 //           A B 0 0
`define QOP_ZEROABCD 4'b0011 //           0 0 0 0

// Load AB, CD, AC, BD 
`define QOP_LDAB     4'b0100 //           h l C D
`define QOP_LDCD     4'b0101 //           A B h l
`define QOP_LDAC     4'b0110 //           h B l D
`define QOP_LDBD     4'b0111 //           A h C l

// Load from Low (LDL) -> A, B, C, D 
`define QOP_LDL_A    4'b1000 //           l B C D
`define QOP_LDL_B    4'b1001 //           A l C D
`define QOP_LDL_C    4'b1010 //           A B l D
`define QOP_LDL_D    4'b1011 //           A B C l

// BCAST OPS Load from High/Low 
`define QOP_HLHL     4'b1100 //           h l h l
`define QOP_HHLL     4'b1101 //           h h l l
`define QOP_LHLH     4'b1110 // Swap      l h l h
`define QOP_LABCD    4'b1111 //           l l l l 






// // // // // // // //
//      Derived      //
// // // // // // // //

// Set bus width using the defined WIDTH above. Makes code easier to read.
`define BUSWIDTH [`WIDTH-1:0]

// Set op width using the defined OPSIZE above. Makes code easier to read.
`define OPWIDTH [`OPSIZE-1:0]



// FIXME: HALF WASNT WORKING WELL ...
// Set half widths for readability and portability.
`define HALFWIDTH `WIDTH>>1

`define HALFIOH `WIDTH-1:`HALFWIDTH
`define HALFIOL `HALFWIDTH-1:0

// Set bus width for TinyTapeout using the defined TINYTAPEOUTWIDTH.
`define TTWIDTH [`TINYTAPEOUTWIDTH-1:0]

// Set TThalf widths for readability and portability.
`define TTHALFWIDTH `TINYTAPEOUTWIDTH>>1

`define TTHALFIOH `TTWIDTH-1:`TTHALFWIDTH
`define TTHALFIOL `TTHALFWIDTH-1:0


`endif // SPUDEFS_VH
