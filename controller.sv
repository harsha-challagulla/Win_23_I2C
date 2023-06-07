module Controller(
    input SDA,
    input logic SCL,
    input logic clk,
    input logic reset_n,
    input [7:0] data_in,    // sending from memory ram . 
    output logic [7:0] data_out,  // sendig to user .
    output logic  [7:0] data_write, // sending to memory ram .
    output logic [6:0] address,    // sending to memory ram .
    output logic wr_en,           // read write enable for memory ram 
    output logic done,             // send to user
    output bit ACKT       // sending to i2c.
);


bit start;

byte write;
byte addr;
bit [6:0] addr_c;

int s_count,c_count;

typedef enum  { IDLE=0, 
                ADDR_WR=1, 
                ADDR_ACK=2,
                WRITE_DATA=3,
                WRITE_ACK=4, 
                READ_DATA=5,
                STOP=6 } state_type;


state_type Controller_state, Next;

always_ff @( posedge clk, negedge reset_n )
    if(!reset_n)    Controller_state <= IDLE;
    else            Controller_state <= Next;

always_ff @(posedge clk) begin
    if (c_count != 0)
        s_count <= (s_count == 0) ? c_count - 1 : s_count - 1;
    else
        s_count <= 0;
end

always_comb begin : set_next_state
    Next = Controller_state;
   case(Controller_state)
    IDLE:           begin 
                        if(~SCL) c_count = 8;       
                        if(start)                             Next = ADDR_WR;
                        else                                  Next = IDLE;
                    end

    ADDR_WR:        begin
                        if(s_count == 0) begin
                         Next = ADDR_ACK;
                         c_count = 0;
                        end
                    end          

    ADDR_ACK:       begin    
                        if( ACKT && addr[0] == 0)      begin            
                                                            Next = WRITE_DATA;
                                                            c_count = 8;
                                                        end

                        else if(ACKT && addr[0] == 1)   begin
                                                            Next = READ_DATA;
                                                            c_count = 0;
                                                        end
                    end

    WRITE_DATA:     begin
                        if(s_count == 0) begin
                            Next = WRITE_ACK;
                            c_count = 0;
                        end
                    end 

    WRITE_ACK:       if(ACKT)                          Next = STOP;

    READ_DATA:       Next = STOP;

    // READ_ACK:                                        Next = STOP;

    STOP :            if( SDA && SCL )                   Next = IDLE;
   endcase
end


always@(*) begin
   case(Controller_state)
    IDLE:            if(~SDA && ~SCL) begin  
                         start = 1 ;
                         data_write = 0;
                         address = 0;
                         done = 0;
                       end

    ADDR_WR:                begin   
                                start = 0;                       
                                addr[s_count] = SDA; 
                                  
                            end

    ADDR_ACK:           begin  
                          ACKT  = 1; 
                        end           
    
    WRITE_DATA:        begin    
                        ACKT = 0;              
                        write[s_count] = SDA;
                        end
    WRITE_ACK:          begin 
                                ACKT =1;
                                data_write = write ;
                                addr_c = addr[7:1];
                                address = addr_c;
                                wr_en = 0;
                        end

    READ_DATA:           begin 
                                addr_c = addr[7:1];
                                address = addr_c;
                                wr_en = 1;
                                data_out = data_in; 
                                //done = 1;
                        end

    STOP :              begin 
                          ACKT = 0;
                          done = 1;
                          wr_en = 1;
                        end
   endcase
end




endmodule