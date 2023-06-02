module I2C_Controller(
    inout logic SDA,
    output logic SCL,
    input logic clk,
    input logic reset_n,
    input logic Master_en,
    input logic [6:0] Slave_Addr,
    input logic R_W_en,
    input logic Mem_Addr,
    input [7:0] Sum1, Sum2;
);

    bit NACK, ACKT, ACKM;
    enum {  IDLE_B = 0,
            START_B = 1,
            SAF_B = 2,
            SAFACK_B = 3,
            SDF_B = 4,
            SDFACK_B = 5,
            LNF_B = 6,
            RDF_B = 7,
            RDFACK_B = 8,
            RNF_B = 9
            STOP_B = 10 } state_bit;
    
    enum logic [10:0] {  IDLE = 11'b00000000001<<IDLE_B,
                        START = 11'b00000000001<<START_B,
                        SAF = 11'b00000000001<<SAF_B,
                        SAFACK = 11'b00000000001<<SAFACK_B,
                        SDF = 11'b00000000001<<SDF_B,
                        SDFACK = 11'b00000000001<<SDFACK_B,
                        LNF = 11'b00000000001<<LNF_B,
                        RDF = 11'b00000000001<<RDF_B,
                        RDFACK = 11'b00000000001<<RDFACK_B,
                        RNF = 11'b00000000001<<RNF_B,
                        STOP = 11'b00000000001<<STOP_B } State, Next;
    
    always_ff @( posedge clk, negedge reset_n )
        if(!reset_n)    State <= IDLE;
        else            State <= Next;

    always_comb begin: set_next_state
        Next = State;
        unique case (1'b1)
            State[IDLE_B]:  if(reset_n & Master_en)     Next = START;   
                            else                        Next = IDLE;

            State[START_B]: if(!reset_n)                Next = IDLE;    
                            else                        Next = SDF;

            State[SAF_B]:   if(!reset_n)                Next = IDLE;    
                            else                        Next = SAFACK;

            State[SAFACK_B]:if(!reset_n)                Next = IDLE;    
                            else if(NACK)               Next = SAF;     
                            else if(ACKT & !R_W_en)     Next = SDF; 
                            else if(ACKT & R_W_en)      Next = RDF;

            State[SDF_B]:   if()                        Next = SDFACK;
            State[SDFACK_B]:if()                        Next = LNF;     else                Next = SDF;
            State[LNF_B]:   if()                        Next = STOP;    else if()           Next = SDF;    
            State[RDF_B]:   if()                        Next = RDFACK;
            State[RDFACK_B]:if()                        Next = RNF;     else                Next = RDF;
            State[RNF_B]:   if()                        Next = STOP;    else if()           Next = RDF;
            State[STOP_B]:  if()                        Next = IDLE;
        endcase
    end: set_next_state

    always_comb begin: set_outputs
        {SDA,SCL} = '0;
        unique case (1'b1)
            State[IDLE_B]: 
            State[START_B]:
            State[SAF_B]:
            State[SAFACK_B]:
            State[SDF_B]:
            State[SDFACK_B]:
            State[LNF_B]:
            State[RDF_B]:
            State[RDFACK_B]:
            State[RNF_B]:
            State[STOP_B]:
        endcase
    end: set_outputs

endmodule: I2C_Controller