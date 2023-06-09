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

 


endmodule




class SEND_DATA;


    function new();
        
    endfunction //new()
endclass / SENDDATA