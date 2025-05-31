/*


module sqrt (
  input         clock,
  input         reset,
  input  [31:0] data_in,       // Sum of squares input
  input         data_valid,    // Input data is valid
  output [31:0] data_out,      // Square root result
  output        data_ready     // Output data is ready
);

  // Registers for pipelined operation
  reg [31:0] result;
  reg ready;
  
  // CORRECTED integer square root using binary search
  function [31:0] int_sqrt;
    input [31:0] value;
    reg [31:0] root;
    reg [31:0] test_root;
    integer i;
    begin
      root = 0;
      
      // Binary search: test each bit position
      for (i = 15; i >= 0; i = i - 1) begin
        test_root = root | (1 << i);  // Try setting this bit
        if (test_root * test_root <= value) begin
          root = test_root;  // Keep this bit if result is still <= value
        end
      end
      
      int_sqrt = root;
    end
  endfunction

  // Main sqrt calculation logic
  always @(posedge clock) begin
    if (reset) begin
      result <= 32'h0;
      ready <= 1'b0;
    end else begin
      if (data_valid && !ready) begin
        // DEBUG: Print what input we're getting
        $display("DEBUG sqrt: input = %d, sqrt = %d", data_in, int_sqrt(data_in));
        
        `ifdef FLOAT
          // Convert to floating point for FLOAT mode (placeholder)
          result <= int_sqrt(data_in) << 16;
        `else
          // For fixed point mode, shift by fractional bits
          `ifdef FIXED
            result <= int_sqrt(data_in) << `FIXED;
          `else
            result <= int_sqrt(data_in) << 16;  // Default 16 fractional bits
          `endif
        `endif
        
        ready <= 1'b1;
      end else if (!data_valid) begin
        ready <= 1'b0;
      end
    end
  end

  // Output assignments
  assign data_out = result;
  assign data_ready = ready;

endmodule

*/

// THIS IS Fractional Binary Search


module sqrt (
  input         clock,
  input         reset,
  input  [31:0] data_in,       // Sum of squares input
  input         data_valid,    // Input data is valid
  output [31:0] data_out,      // Square root result
  output        data_ready     // Output data is ready
);

  reg [31:0] result;
  reg ready;
  
  // Enhanced binary search with fractional precision
  function [31:0] precise_sqrt;
    input [31:0] value;
    
    reg [31:0] root;
    reg [31:0] test_root;
    reg [63:0] test_square;
    integer i;
    
    begin
      root = 0;
      
      // First pass: Integer part (bits 31 to 16)
      for (i = 15; i >= 0; i = i - 1) begin
        test_root = root | (1 << (i + 16));  // Test integer bits
        test_square = test_root * test_root;
        
        if (test_square <= (value << 32)) begin  // Compare with scaled value
          root = test_root;
        end
      end
      
      // Second pass: Fractional part (bits 15 to 0)  
      for (i = 15; i >= 0; i = i - 1) begin
        test_root = root | (1 << i);  // Test fractional bits
        test_square = test_root * test_root;
        
        if (test_square <= (value << 32)) begin
          root = test_root;
        end
      end
      
      precise_sqrt = root;
    end
  endfunction

  always @(posedge clock) begin
    if (reset) begin
      result <= 32'h0;
      ready <= 1'b0;
    end else begin
      if (data_valid && !ready) begin
        result <= precise_sqrt(data_in);
        ready <= 1'b1;
      end else if (!data_valid) begin
        ready <= 1'b0;
      end
    end
  end

  assign data_out = result;
  assign data_ready = ready;

endmodule
