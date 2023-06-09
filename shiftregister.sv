module ShiftRegister (
    Q, clk, Clear, D, S, MSBIn, LSBIn
);
    parameter nBits = 8;

    output [nBits-1:0] Q;
    input clk;
    input Clear;
    input [nBits-1:0] D;
    input [$clog2(nBits)-1:0] S;
    input MSBIn;
    input LSBIn;

    wire [7:0] Y;

    // This generate construct is used to generate required MUX's at elaboration time
    genvar i;
    Mux8to1 MuxFirst(.Y(Y[0]), .V({1'b0, Q[1], Q[7], Q[1], LSBIn, Q[1], D[0], Q[0]}), .S(S));
    generate
        for(i = 0; i < (nBits-2); i = i + 1) begin:Mux
            Mux8to1 m (.Y(Y[i+1]), .V({Q[i], Q[i+2], Q[i], Q[i+2], Q[i], Q[i+2], D[i+1], Q[i+1]}), .S(S));
        end
    endgenerate
    Mux8to1 MuxLast(.Y(Y[7]), .V({Q[6], Q[7], Q[6], Q[0], Q[6], MSBIn, D[7], Q[7]}), .S(S));

    // This generate construct is used to generate required DFF's at elaboration time
    genvar j;
    generate
        for(j = 0; j < (nBits); j = j + 1) begin:Dff
            DFF FF0(.Q(Q[j]), .Clock(clk), .Clear(Clear), .D(Y[j]));
        end
    endgenerate
endmodule
// module ShiftRegister(Q, Clock, Clear, D, S, MSBIn, LSBIn);
// parameter N = 8;

// output [N-1:0] Q;
// input Clock;
// input Clear;
// input [N-1:0] D;
// input [2:0] S;
// input MSBIn;
// input LSBIn;

// logic [N-1:0] FFD;
// logic [7:0] M [N-1:0];					// mux inputs

// /*
// If you want to silence the warnings about bit select out of bounds you can use this code:

//   assign M[0]   = {  1'b0, Q[1],   Q[N-1], Q[1],   LSBIn,  Q[1],  D[0],   Q[0]};
//   assign M[N-1] = {Q[N-2], Q[N-1], Q[N-2], Q[0],   Q[N-2], MSBIn, D[N-1], Q[N-1]};
  
// genvar i;
// generate
//   for (i = N-2; i >= 1; i--)
// 	assign M[i] = {
// 			Q[i-1],	// ASL
// 			Q[i+1],	// ASR
// 	        Q[i-1],	// ROTL	
// 		    Q[i+1],	// ROTR
// 	        Q[i-1],	// LSL	    
// 		    Q[i+1],	// LSR
// 	    	D[i],	// LOAD
// 			Q[i]};	// NOP
// endgenerate

// */

// // Set up inputs for each mux (7:0)
// genvar i;
// generate
// for (i = N-1; i >= 0; i--)
// 	assign M[i] = {
// 			(i == 0)   ? 1'b0   : Q[i-1],	// ASL
// 			(i == N-1) ? Q[N-1] : Q[i+1],	// ASR
// 	        (i == 0)   ? Q[N-1] : Q[i-1],	// ROTL	
// 		    (i == N-1) ? Q[0]   : Q[i+1],	// ROTR
// 	        (i == 0)   ? LSBIn  : Q[i-1],	// LSL	    
// 		    (i == N-1) ? MSBIn  : Q[i+1],	// LSR
// 	    		                    D[i],	// LOAD
// 				                    Q[i]};	// NOP
// endgenerate

// DFF SR[N-1:0] (Q, Clock, Clear, FFD);	// instantiate array of DFFs for register
// Mux8to1 Mux[N-1:0] (FFD, M, S);			// instantiate array of Muxs to drive DFF inputs
// endmodule