module sqrt (
  input         clock,
  input         reset,
  input  [31:0] data_in,       // Sum of squares input
  input         data_valid,    // Input data is valid
  output [31:0] data_out,      // Square root result
  output        data_ready     // Output data is ready
);

  // Pipeline stage registers
  reg [31:0] stage1_value, stage2_value, stage3_value, stage4_value;
  reg [31:0] stage1_root, stage2_root, stage3_root;
  reg [31:0] stage4_result;
  reg stage1_valid, stage2_valid, stage3_valid, stage4_valid;

  // STAGE 1: Handle bits 15-12 (4 iterations)
  function [31:0] sqrt_stage1;
    input [31:0] value;
    reg [31:0] root;
    reg [31:0] test_root;
    integer i;
    begin
      root = 0;
     
      // Binary search: test bits 15 down to 12
      for (i = 15; i >= 12; i = i - 1) begin
        test_root = root | (1 << i);  // Try setting this bit
        if (test_root * test_root <= value) begin
          root = test_root;  // Keep this bit if result is still <= value
        end
      end
     
      sqrt_stage1 = root;
    end
  endfunction

  // STAGE 2: Handle bits 11-8 (4 iterations)
  function [31:0] sqrt_stage2;
    input [31:0] value;
    input [31:0] partial_root;
    reg [31:0] root;
    reg [31:0] test_root;
    integer i;
    begin
      root = partial_root;  // Start with result from stage 1
     
      // Binary search: test bits 11 down to 8
      for (i = 11; i >= 8; i = i - 1) begin
        test_root = root | (1 << i);  // Try setting this bit
        if (test_root * test_root <= value) begin
          root = test_root;  // Keep this bit if result is still <= value
        end
      end
     
      sqrt_stage2 = root;
    end
  endfunction

  // STAGE 3: Handle bits 7-4 (4 iterations)
  function [31:0] sqrt_stage3;
    input [31:0] value;
    input [31:0] partial_root;
    reg [31:0] root;
    reg [31:0] test_root;
    integer i;
    begin
      root = partial_root;  // Start with result from stage 2
     
      // Binary search: test bits 7 down to 4
      for (i = 7; i >= 4; i = i - 1) begin
        test_root = root | (1 << i);  // Try setting this bit
        if (test_root * test_root <= value) begin
          root = test_root;  // Keep this bit if result is still <= value
        end
      end
     
      sqrt_stage3 = root;
    end
  endfunction

  // STAGE 4: Handle bits 3-0 (4 iterations)
  function [31:0] sqrt_stage4;
    input [31:0] value;
    input [31:0] partial_root;
    reg [31:0] root;
    reg [31:0] test_root;
    integer i;
    begin
      root = partial_root;  // Start with result from stage 3
     
      // Binary search: test bits 3 down to 0
      for (i = 3; i >= 0; i = i - 1) begin
        test_root = root | (1 << i);  // Try setting this bit
        if (test_root * test_root <= value) begin
          root = test_root;  // Keep this bit if result is still <= value
        end
      end
     
      sqrt_stage4 = root;
    end
  endfunction

  // Main sqrt calculation logic - 4-stage pipeline
  always @(posedge clock) begin
    if (reset) begin
      // Reset all pipeline stages
      stage1_value <= 32'h0;
      stage2_value <= 32'h0;
      stage3_value <= 32'h0;
      stage4_value <= 32'h0;
      
      stage1_root <= 32'h0;
      stage2_root <= 32'h0;
      stage3_root <= 32'h0;
      stage4_result <= 32'h0;
      
      stage1_valid <= 1'b0;
      stage2_valid <= 1'b0;
      stage3_valid <= 1'b0;
      stage4_valid <= 1'b0;
    end else begin
      
      // STAGE 1: Process new input (bits 15-12)
      if (data_valid) begin
        stage1_value <= data_in;
        stage1_root <= sqrt_stage1(data_in);
        stage1_valid <= 1'b1;
      end else begin
        stage1_valid <= 1'b0;
      end
      
      // STAGE 2: Continue search (bits 11-8)
      stage2_value <= stage1_value;
      stage2_root <= stage1_valid ? sqrt_stage2(stage1_value, stage1_root) : 32'h0;
      stage2_valid <= stage1_valid;
      
      // STAGE 3: Continue search (bits 7-4)
      stage3_value <= stage2_value;
      stage3_root <= stage2_valid ? sqrt_stage3(stage2_value, stage2_root) : 32'h0;
      stage3_valid <= stage2_valid;
      
      // STAGE 4: Final search (bits 3-0) + format result
      stage4_value <= stage3_value;
      if (stage3_valid) begin
        reg [31:0] final_sqrt;
        final_sqrt = sqrt_stage4(stage3_value, stage3_root);
        
        // DEBUG: Print what input we're getting
        $display("DEBUG sqrt: input = %d, sqrt = %d", stage3_value, final_sqrt);
       
        `ifdef FLOAT
          // Convert to floating point for FLOAT mode (placeholder)
          stage4_result <= final_sqrt << 16;
        `else
          // For fixed point mode, shift by fractional bits
          `ifdef FIXED
            stage4_result <= final_sqrt << `FIXED;
          `else
            stage4_result <= final_sqrt << 16;  // Default 16 fractional bits
          `endif
        `endif
      end else begin
        stage4_result <= 32'h0;
      end
      stage4_valid <= stage3_valid;
    end
  end

  // Output assignments
  assign data_out = stage4_result;
  assign data_ready = stage4_valid;
endmodule