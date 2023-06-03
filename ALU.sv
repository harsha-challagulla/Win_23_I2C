module ALU(
  input logic [7:0] A, B,
  input logic Cin,
  output logic [7:0] Sum1,
  output logic [7:0] Sum2
);
  
  logic [8:0] TwoA;
  logic [9:0] FourB;
  logic [8:0] Cext;
  
  assign TwoA = A << 1;     // Left shift A by 1 bit to multiply it by 2
  assign FourB = B << 2;   // Left shift B by 1 bit to multiply it by 4
  
  assign Cext = Cin;
  assign {Sum2, Sum1} = TwoA + FourB + Cext; // 2A + 4B
  
endmodule
