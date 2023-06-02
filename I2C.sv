module I2C_Controller(
    inout wire SDA,
    output logic SCL,
    input logic clk,
    input logic reset_n,
    input logic Master_en,
    input logic [6:0] Slave_Addr,
    input logic R_W_en,
    input logic [7:0] Mem_Addr,
    input logic [7:0] Sum1, Sum2
);


    parameter TRUE = 1'b1;
    parameter FALSE = 1'b0;
    parameter CLOCK_CYCLE = 10; 
    parameter CLOCK_WIDTH = 10/2;
    parameter IDLE_CLOCKS = 2;
    bit NACK, ACKT, ACKM, read;
    bit SAFW_Done;
    int count_w, count_r;
    logic SDAreg;

    assign SDA = SDAreg;

    // assign SDA = SDAreg;

    logic [2:0] S1;   // Mux1 Select
    logic Y1;               // Mux1 output
    logic [7:0] V1;               // Mux1 Data

    Mux8to1 Mux1 (.Y(Y1), .V(V1), .S(S1));   // Mux to hold Slave Address


    enum {  IDLE_B      = 0,
            START_B     = 1,
            SAFW_B      = 2,     // Send Address Frame (Write Mode)
            SAFWACK_B   = 3,  // Send Address Frame (Write Mode) Acknowledgment
            SDF_B       = 4,      // Send Data Frame
            SDFACK_B    = 5,   // Send Data Frame Acknowledgement
            LAD_B       = 6,      // Load the mux with next data & Decrement the count.
            SAFR_B      = 7,     // Send Address Frame (Read Mode)
            SAFRACK_B   = 8,  // Send Address Frame (Read Mode) Acknowledgement
            RDF_B       = 9,      // Receive Data Frame
            RDFACK_B    = 10,  // Receive Data Frame Acknowledgement
            RAD_B       = 11,     // Recieve the Data frame into internal register & Decrement the count.
            STOP_B      = 12 }   // Stop State
            state_bit; 
    
    enum logic [12:0] { IDLE    = 13'd1<<IDLE_B,                // 1
                        START   = 13'd1<<START_B,               // 2
                        SAFW    = 13'd1<<SAFW_B,                // 4
                        SAFWACK = 13'd1<<SAFWACK_B,             // 8    
                        SDF     = 13'd1<<SDF_B,                 // 16
                        SDFACK  = 13'd1<<SDFACK_B,              // 32
                        LAD     = 13'd1<<LAD_B,                 // 64
                        SAFR    = 13'd1<<SAFR_B,                // 128
                        SAFRACK = 13'd1<<SAFRACK_B,             // 256
                        RDF     = 13'd1<<RDF_B,                 // 512
                        RDFACK  = 13'd1<<RDFACK_B,              // 1024
                        RAD     = 13'd1<<RAD_B,                 // 2048
                        STOP    = 13'd1<<STOP_B } State, Next;  // 4096
    
    always_ff @( posedge clk, negedge reset_n )
        if(!reset_n)    State <= IDLE;
        else            State <= Next;

    always_comb begin: set_next_state
        Next = State;
        unique case (1'b1)
            State[IDLE_B]:      if(reset_n & Master_en)     Next = START;

            State[START_B]:     if(!read)                   Next = SAFW;
                                else if(read)               Next = SAFR;

            State[SAFW_B]:      if(SAFW_Done)               Next = SAFWACK; 
            
            State[SAFWACK_B]:   if(NACK)                    Next = SAFW;
                                else if(ACKT)               Next = SDF;

            State[SDF_B]:                                   Next = SDFACK;

            State[SDFACK_B]:    if(NACK)                    Next = SDF;
                                else if(ACKT & R_W_en)      Next = START;       // make read = 1
                                else if(ACKT & !R_W_en)     Next = LAD;

            State[LAD_B]:       if(count_w == 0)            Next = STOP;
                                else if(count_w != 0)       Next = SDF;

            State[SAFR_B]:                                  Next = SAFRACK;
            
            State[SAFRACK_B]:   if(NACK)                    Next = SAFR;
                                else if(ACKT)               Next = RDF;

            State[RDF_B]:                                   Next = RDFACK;

            State[RDFACK_B]:    if(NACK)                    Next = RDF;
                                else if(ACKM)               Next = RAD;

            State[RAD_B]:       if(count_r == 0)            Next = STOP;
                                else if(count_r != 0)       Next = RDF;

            State[STOP_B]:                                  Next = IDLE;
        endcase
    end: set_next_state

    always @(State) begin: set_outputs
        // SDAreg = '0;
        // SCL = '0;
        unique case (1'b1)
            State[IDLE_B]:  begin   // 1
                                SDAreg = '1;
                                SCL = '1;
                                read = 0;
                                NACK = 0;
                                ACKT = 0;
                                ACKM = 0;
                            end

            State[START_B]: begin   // 2
                                SDAreg = 0;
                                // V1 = {Slave_Addr, read};
                                #IDLE_CLOCKS SCL = ~SCL;
                                // #IDLE_CLOCKS S1 = 3'd7;
                            end

            State[SAFW_B]:  begin   // 4
                                V1 = {Slave_Addr, read};
                                S1 = 3'd7;
                                // SDAreg = Y1;
                                // SCL = ~SCL;
                                // @(negedge clk) SCL = ~SCL;
                                repeat (8)  begin
                                            @(posedge clk)  SDAreg = Y1;
                                                            SCL = ~SCL;
                                            @(negedge clk)  SCL = ~SCL;
                                                            S1--;
                                end
                                @(posedge clk)
                                SDAreg = '1;
                                SAFW_Done = 1;
                            end

            State[SAFWACK_B]:   begin   // 8
                                    SCL = ~SCL;
                                    if (~SDA) begin
                                        ACKT = 1;
                                        @(negedge clk) SCL = ~SCL;
                                    end
                                    else begin
                                        NACK = 1;
                                        @(negedge clk) SCL = ~SCL;
                                    end
                                end

            State[SDF_B]: begin
                
            end
            
            State[SDFACK_B]: begin
                
            end

            State[LAD_B]: begin
                
            end

            State[SAFR_B]: begin
                
            end

            State[SAFRACK_B]: begin
                
            end

            State[RDF_B]: begin
                
            end

            State[RDFACK_B]: begin
                
            end

            State[RAD_B]: begin
                
            end

            State[STOP_B]: begin
                
            end

        endcase
    end: set_outputs

endmodule: I2C_Controller

module Mux8to1 (
    Y, V, S
);
    parameter SELECT_BITS = 3;
    localparam INPUT_BITS = 2 ** SELECT_BITS;

    output Y;
    input [INPUT_BITS-1:0] V;
    input [SELECT_BITS-1:0] S;

    assign Y = V[S];
endmodule