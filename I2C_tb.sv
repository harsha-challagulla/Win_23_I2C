module top2;
    wire SDA;
    logic SCL;
    bit clk;
    bit reset_n;
    bit Master_en;
    logic [6:0] Slave_Addr;
    bit R_W_en;
    logic [7:0] Mem_Addr;
    logic [7:0] Sum1, Sum2;
    // logic SDAreg_Tb;

    I2C_Controller DUT (.*);

    parameter TRUE_T = 1'b1;
    parameter FALSE_T = 1'b0;
    parameter CLOCK_CYCLE_T = 10; 
    parameter CLOCK_WIDTH_T = CLOCK_CYCLE_T/2;
    parameter IDLE_CLOCKS_T = 2;

    // assign SDA = SDAreg_Tb;

    initial begin   // Clock Generation
        forever #CLOCK_WIDTH_T clk = ~clk;
    end

    initial begin
        Sum1 = 8'h77;   
        Sum2 = 8'h22;
        Mem_Addr = 8'h55;
        R_W_en = 0;
        Slave_Addr = 7'h55;
        reset_n = 0;
        clk = 0;

        @(negedge clk) reset_n = 1;
        Master_en = 1;
        repeat(27) @(posedge clk) begin
        @(negedge clk) if(DUT.SAFW_Done) DUT.SDAreg = 0;    // Slave is acking the SAF
        @(negedge clk) if(DUT.SDF_Done) DUT.SDAreg = 0;    // Slave is acking the SDF
        // @(negedge clk) if(DUT.SAFW_Done) DUT.SDAreg = 0;    // Slave is acking the SAF
        end
        @(posedge clk) R_W_en = 1;
        repeat(50) @(posedge clk) begin
            if(DUT.SAFW_Done) DUT.SDAreg = 0;
            if(DUT.SDF_Done) DUT.SDAreg = 0;
            if(DUT.SAFR_Done) DUT.SDAreg = 0;
        // end
        if(DUT.RDF_Done1) begin
            DUT.SDAreg = 1;
            @(posedge clk) DUT.SDAreg = 0;
            @(posedge clk) DUT.SDAreg = 1;
            @(posedge clk) DUT.SDAreg = 0;
            @(posedge clk) DUT.SDAreg = 1;
            @(posedge clk) DUT.SDAreg = 0;
            @(posedge clk) DUT.SDAreg = 1;
            @(posedge clk) DUT.SDAreg = 0;
            @(negedge clk) DUT.SDAreg = 1;
        end
    end

        @(posedge clk) $finish;
    end

endmodule