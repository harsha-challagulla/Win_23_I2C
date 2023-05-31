module top1;
  
  // Inputs
  logic [7:0] A;
  logic [7:0] B;
  logic Cin;
  
  // Outputs
  logic [7:0] Sum;
  logic [2:0] Cout;
  
  // Instantiate the DUT (Design Under Test)
  ALU dut (
    .A(A),
    .B(B),
    .Cin(Cin),
    .Sum(Sum),
    .Cout(Cout)
  );
  
  // Testbench stimulus
  initial begin
    // clk = 0;
    
    // Test case 1: A = 10, B = 5, Cin = 0
    A = 8'd10;
    B = 8'd5;
    Cin = '1;
    #10; // Wait for 10 time units
    
    // Check the expected results
    if (Sum !== 8'd41 || Cout !== 0) begin
      $display("Test case 1 failed! Sum: %b, Cout: %b", Sum, Cout);
    end else begin
      $display("Test case 1 passed! A = %d, B = %d, Cin = %d, Sum = %d, Cout = %d", A,B,Cin,Sum,Cout);
    end
    
    // Test case 2: A = 255, B = 0, Cin = 1
    A = 8'd255;
    B = 8'd0;
    Cin = '1;
    #10; // Wait for 10 time units
    
    // Check the expected results
    if ({Cout,Sum} !== 9'd511) begin
      $display("Test case 2 failed! Sum: %d, Cout: %d", Sum, Cout);
    end else begin
      $display("Test case 2 passed! A = %d, B = %d, Cin = %d, Sum = %d, Cout = %d", A,B,Cin,{Cout,Sum},Cout);
    end
    
    A = 8'd255;
    B = 8'd255;
    Cin = '0;
    #10; // Wait for 10 time units
    
    // Check the expected results
    if ({Cout,Sum} !== 11'd1530) begin
      $display("Test case 3 failed! Sum: %d, Cout: %d", Sum, Cout);
    end else begin
      $display("Test case 3 passed! A = %d, B = %d, Cin = %d, Sum = %d, Cout = %d", A,B,Cin,{Cout,Sum},Cout);
    end


    A = 8'd255;
    B = 8'd255;
    Cin = '1;
    #10; // Wait for 10 time units
    
    // Check the expected results
    if ({Cout,Sum} !== 11'd1531) begin
      $display("Test case 4 failed! Sum: %d, Cout: %d", Sum, Cout);
    end else begin
      $display("Test case 4 passed! A = %d, B = %d, Cin = %d, Sum = %d, Cout = %d", A,B,Cin,{Cout,Sum},Cout);
    end

    A = 8'd0;
    B = 8'd0;
    Cin = '0;
    #10; // Wait for 10 time units
    
    // Check the expected results
    if ({Cout,Sum} !== 9'd0) begin
      $display("Test case 5 failed! Sum: %d, Cout: %d", Sum, Cout);
    end else begin
      $display("Test case 5 passed! A = %d, B = %d, Cin = %d, Sum = %d, Cout = %d", A,B,Cin,{Cout,Sum},Cout);
    end

    A = 8'd0;
    B = 8'd0;
    Cin = '1;
    #10; // Wait for 10 time units
    
    // Check the expected results
    if ({Cout,Sum} !== 9'd1) begin
      $display("Test case 6 failed! Sum: %d, Cout: %d", Sum, Cout);
    end else begin
      $display("Test case 6 passed! A = %d, B = %d, Cin = %d, Sum = %d, Cout = %d", A,B,Cin,{Cout,Sum},Cout);
    end

    A = 8'd0;
    B = 8'd255;
    Cin = '0;
    #10; // Wait for 10 time units
    
    // Check the expected results
    if ({Cout,Sum} !== 10'd1020) begin
      $display("Test case 7 failed! Sum: %d, Cout: %d", Sum, Cout);
    end else begin
      $display("Test case 7 passed! A = %d, B = %d, Cin = %d, Sum = %d, Cout = %d", A,B,Cin,{Cout,Sum},Cout);
    end


    // Add more test cases if needed
    
    // End the simulation
    #10 $finish;
  end
  
endmodule
