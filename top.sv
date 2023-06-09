
module top;

    bit clk;
    bit reset_n;
    bit Master_en;
    bit R_W_en;
    logic [6:0] Mem_Addr;
    logic [7:0] Data;
    logic [7:0] data_out;
    logic done;
    logic [2:0] S;
    logic MSBIn,LSBIn;

    I2C_top MAIN(.*);
    import my_pkg::*;




// parameter TRUE_T = 1'b1;
// parameter FALSE_T = 1'b0;
// parameter CLOCK_CYCLE_T = 10; 
// parameter CLOCK_WIDTH_T = CLOCK_CYCLE_T/2;
// parameter IDLE_CLOCKS_T = 2;



initial begin 
         clk = 0;  // Clock Generation
        forever #CLOCK_WIDTH_T clk = ~clk;
    end


initial begin

        reset_n = 0;

        repeat(1) @(negedge clk);                     
        Data = 8'h55;
        reset_n = 1;
        S = 3'd1;                                // loading the data 8'h55 to shiftresister
        @(negedge clk);                                     
        MSBIn = 1'b1; LSBIn = 1'b0; S =3'd2;    //   
        @(negedge clk);
        S = 3'd0;
        @(negedge clk);
        Master_en = 1;
        Mem_Addr = 7'h55;
        R_W_en = 0; 
        @(posedge clk) Master_en = 0;
        repeat(23) @(posedge clk);
 
        @(negedge clk);
        MSBIn = 1'b1; LSBIn = 1'b0; S =3'd3; 
        @(negedge clk);
        S = 3'd0;

        Master_en = 1;
        Mem_Addr = 7'h01;
        R_W_en = 0;
         @(posedge clk) Master_en = 0; 
        repeat(23) @(posedge clk);

         @(negedge clk);
         MSBIn = 1'b1; LSBIn = 1'b0; S =3'd4; 
         @(negedge clk);
         S = 3'd0;
  
        Master_en = 1;
        Mem_Addr = 7'h02;
        R_W_en = 0; 
        @(posedge clk) Master_en = 0; 
        repeat(23) @(posedge clk);

       
         @(negedge clk);
         MSBIn = 1'b1; LSBIn = 1'b0; S =3'd5; 
         @(negedge clk);
         S = 3'd0;
        Master_en = 1;
        Mem_Addr = 7'h03;
        R_W_en = 0; 
        @(posedge clk) Master_en = 0; 
        repeat(23) @(posedge clk);
        
        @(negedge clk);
        Master_en = 1;
        Mem_Addr = 7'h55;
        R_W_en = 1;

        repeat(14)@(posedge clk); 
        
        @(negedge clk);
        Mem_Addr = 7'h01;
       
        repeat(14)@(posedge clk); 
        
        @(negedge clk);
        Mem_Addr = 7'h02;
        repeat(14)@(posedge clk);

        @(negedge clk);
        Mem_Addr = 7'h03;
        repeat(14)@(posedge clk);


     $finish;
end

endmodule
    
