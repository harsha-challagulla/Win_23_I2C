module I2C_top(
    input logic clk,
    input logic reset_n,
    input logic Master_en,
    input logic R_W_en,
    input logic [6:0] Mem_Addr,
    input logic [7:0] Data,
    output logic [7:0] data_out,
    output done,
    input [2:0] S,
    input MSBIn,
    input LSBIn
);
 wire SDA,SCL;
 wire ACKT;
 wire [7:0] data_in; // sending from memory ram . 
 wire  [7:0] data_write;// sending to memory ram .
 wire [6:0] address;  // sending to memory ram .
 wire wr_en;     // read write enable for memory ram 
 wire [7:0] data_final;

 wire [7:0] SR_out;

 I2C DUT (.clk(clk),.reset_n(reset_n),.Mem_Addr(Mem_Addr),.Data(SR_out),.Master_en(Master_en),.SDA(SDA),.SCL(SCL),.ACKT(ACKT),.R_W_en(R_W_en));
 
 Controller Dut1(.SDA(SDA),.SCL(SCL),.clk(clk),.reset_n(reset_n),.data_in(data_final),.data_out(data_out),.data_write(data_write),.address(address),.wr_en(wr_en),.done(done),.ACKT(ACKT));
 
 memory DUT2 (.clk(clk),.reset_n(reset_n),.data_write(data_write),.address(address),.wr_en(wr_en),.data_final(data_final));


ShiftRegister SR(.Q(SR_out), .clk(clk), .Clear(reset_n), .D(Data), .S(S), .MSBIn(MSBIn), .LSBIn(LSBIn));

endmodule