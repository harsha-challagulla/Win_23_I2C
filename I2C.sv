module I2C_Controller(
    inout logic SDA,
    output logic SCL,
    input logic clk,
    input logic reset_n,
    input logic Master_en,
    input logic [6:0] Slave_Addr,
    input logic R_W_en,
    input logic [7:0] Mem_Addr,
    input logic [7:0] Sum1, Sum2;
);

    bit NACK, ACKT, ACKM, read;

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
    
    enum logic [12:0] { IDLE    = 13'd1<<IDLE_B,
                        START   = 13'd1<<START_B,
                        SAFW    = 13'd1<<SAFW_B,
                        SAFWACK = 13'd1<<SAFWACK_B,
                        SDF     = 13'd1<<SDF_B,
                        SDFACK  = 13'd1<<SDFACK_B,
                        LAD     = 13'd1<<LAD_B,
                        SAFR    = 13'd1<<SAFR_B,
                        SAFRACK = 13'd1<<SAFRACK_B,
                        RDF     = 13'd1<<RDF_B,
                        RDFACK  = 13'd1<<RDFACK_B,
                        RAD     = 13'd1<<RAD_B,
                        STOP    = 13'd1<<STOP_B } State, Next;
    
    always_ff @( posedge clk, negedge reset_n )
        if(!reset_n)    State <= IDLE;
        else            State <= Next;

    always_comb begin: set_next_state
        Next = State;
        unique case (1'b1)
            State[IDLE_B]:      if(reset_n & Master_en)     Next = START;

            State[START_B]:     if(!read)                   Next = SAFW;
                                else if(read)               Next = SAFR;

            State[SAFW_B]:                                  Next = SAFWACK;
            
            State[SAFWACK_B]:   if(NACK)                    Next = SAFW;
                                else if(ACKT)               Next = SDF;

            State[SDF_B]:                                   Next = SDFACK;

            State[SDFACK_B]:    if(NACK)                    Next = SDF;
                                else if(ACKT & R_W_en)      Next = START;
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

    always_comb begin: set_outputs
        {SDA,SCL} = '0;
        unique case (1'b1)
            State[IDLE_B]:
            State[START_B]:
            State[SAFW_B]:
            State[SAFWACK_B]:
            State[SDF_B]:
            State[SDFACK_B]:
            State[LAD_B]:
            State[SAFR_B]:
            State[SAFRACK_B]:
            State[RDF_B]:
            State[RDFACK_B]:
            State[RAD_B]:
            State[STOP_B]:

        endcase
    end: set_outputs

endmodule: I2C_Controller