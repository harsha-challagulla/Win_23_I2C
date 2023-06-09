import my_pkg::*;

module I2C (
        inout SDA,
        output logic SCL,
        input logic clk,
        input logic reset_n,
        input logic Master_en,
        input logic R_W_en,
        input address_t Mem_Addr,
        input byte_t Data,
        input ACKT_t ACKT
    );



logic [7:0] s_data,s_addr;
logic a_bit,d_bit;

int s_count,c_count;

//SDA and SCL CHANGE VARIABLES 
logic scl_en,scl_chan;
logic sda_en,sda_chan;



typedef enum  { IDLE= 0, 
                START1= 1, 
                START2= 2,
                ADDR_WR= 3, 
                ADDR_ACK= 4,
                WRITE_DATA= 5,
                WRITE_ACK= 6,  
                STOP1= 7,
                STOP2= 8 } state_type;

state_type State, Next;


always_ff @(posedge clk)
begin
if (~reset_n)
	State <= IDLE;
else
	State <= Next;
end




always_comb begin 
Next = State;
case(State)
    IDLE:       begin       
                   if(Master_en & reset_n)  begin  
                    s_data = '0;c_count= '0;
                    a_bit = '0; d_bit = '0;  
                    Next = START1;
                   end else Next = IDLE;
                end

    START1:     Next = START2;

    START2:     begin 
                 Next = ADDR_WR;
                 s_addr = {Mem_Addr,R_W_en};
                 s_data = Data;
                 c_count = 8;
                end

    ADDR_WR:        begin
                    if(s_count == 0) begin
                        Next = ADDR_ACK;
                        c_count = 0;
                    end
                    end

    ADDR_ACK:        begin  
                             if(ACKT && ~R_W_en)  begin     
                                                       Next = WRITE_DATA;
                                                       c_count = 8;
                                                   end
                         else if(ACKT && R_W_en)    begin 
                                                         Next = STOP1;
                                                         c_count = 0;
                                                    end 
                          else Next = ADDR_ACK;
                     end

    WRITE_DATA:      begin
                      if(s_count == 0) begin
                        Next = WRITE_ACK;
                        c_count = 0;
                    end
                    end 

    WRITE_ACK:       if(ACKT)                         Next = STOP1;

    STOP1:                                             Next = STOP2;

    STOP2 :                                            Next = IDLE;

   endcase
end

assign SDA      = sda_en ? sda_chan : 'x;

assign SCL        = scl_en ? clk : scl_chan;



always_comb begin 
 
case(State)
    IDLE:        begin 
                    sda_en = 1;
                    sda_chan = 1;
                    scl_en = 0;
                    scl_chan = 1;
                end    

    START1:       begin sda_chan = 0;  end

    START2:          begin scl_chan = 0;    
                      end

    ADDR_WR:     begin     
                    sda_en = 1;
                    scl_en = 1;
                    sda_chan = s_addr[s_count];
                 end


    ADDR_ACK:   begin 
                     sda_en = 0;
                end
                     

    WRITE_DATA: begin     
                    sda_en = 1;
                    sda_chan = s_data[s_count];
                 end

    WRITE_ACK:      begin
                       sda_en = 0;
                    end

    STOP1:          begin 
                    {scl_en,scl_chan,sda_en,sda_chan} = 4'b0110;
                    end

    STOP2:          {sda_en,sda_chan} = '1;
   endcase
end

always_ff @(posedge clk) begin
    if (c_count != 0)
        s_count <= (s_count == 0) ? c_count - 1 : s_count - 1;
    else
        s_count <= 0;
end

//-------------------------------------------------Assertions------------------------------------------------


property idealtoS1;
  @(posedge clk) disable iff (!reset_n)
    (State == IDLE  && reset_n && Master_en) |-> (Next == START1);
endproperty

 a1: assert property (idealtoS1) else $info("idealtoS1");

property S1toS2;
  @(posedge clk) disable iff (!reset_n)
    (State == START1) |-> (Next == START2) 
endproperty

 a2: assert property (S1toS2) else $info("S1toS2");;

property S2toADDWR;
  @(posedge clk) disable iff (!reset_n)
    (State == START2) |-> (Next == ADDR_WR) ;
endproperty

 a3: assert property (S2toADDWR) else $info("S2toADDWR");

 property ADDRWtoACK;
  @(posedge clk) disable iff (!reset_n)
    (State == ADDR_WR && s_count == 0) |-> Next == ADDR_ACK;
endproperty

 a4: assert property (ADDRWtoACK) else $info("ADDRWtoACK Failing");

property ACKtoWR;
  @(posedge clk) disable iff (!reset_n)
    (State == ADDR_ACK && ACKT && ~R_W_en) |-> Next == WRITE_DATA;
endproperty

 a5: assert property (ACKtoWR) else $info("ACKtoWR Failing");
    
 property WRtoACK;
  @(posedge clk) disable iff (!reset_n)
    (State == WRITE_DATA && s_count == 0) |-> Next == WRITE_ACK;
endproperty

 a6: assert property (WRtoACK) else $info("WRtoACK Failing");

 property ACKtoRD;
  @(posedge clk) disable iff (!reset_n)
    (State == ADDR_ACK && ACKT && R_W_en) |-> Next == STOP1;
endproperty

 a7: assert property (ACKtoRD) else $info("ACKtoRD Failing");

 property SP1toSP2;
  @(posedge clk) disable iff (!reset_n)
    (State == STOP1) |-> Next == STOP2;
endproperty

 a8: assert property (SP1toSP2) else $info("SP1toSP2 Failing");

 property SP2toIdle;
  @(posedge clk) disable iff (!reset_n)
    (State == STOP2 ) |-> Next == IDLE;
endproperty

 a9: assert property (SP2toIdle) else $info("SP2toIdle Failing");


 property WRacktoSP1;
  @(posedge clk) disable iff (!reset_n)
    (State == WRITE_ACK && ACKT ) |-> Next == STOP1;
endproperty

 a10: assert property (ACKtoRD) else $info("WRacktoSP1 Failing");

endmodule

