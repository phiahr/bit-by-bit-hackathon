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
  reg [31:0] stage1_root, stage2_root, stage3_root, stage4_root;
  reg stage1_valid, stage2_valid, stage3_valid, stage4_valid;

  // STAGE 1: Integer bits 15-8 (8 iterations)
  function [31:0] sqrt_stage1;
    input [31:0] value;
    reg [31:0] root;
    reg [31:0] test_root;
    reg [63:0] test_square;
    integer i;
    begin
      root = 0;
      // First half of integer part (bits 15 down to 8)
      for (i = 15; i >= 8; i = i - 1) begin
        test_root = root | (1 << (i + 16));  // Test integer bits
        test_square = test_root * test_root;
        if (test_square <= (value << 32)) begin
          root = test_root;
        end
      end
      sqrt_stage1 = root;
    end
  endfunction

  // STAGE 2: Integer bits 7-0 (8 iterations)
  function [31:0] sqrt_stage2;
    input [31:0] value;
    input [31:0] partial_root;
    reg [31:0] root;
    reg [31:0] test_root;
    reg [63:0] test_square;
    integer i;
    begin
      root = partial_root;
      // Second half of integer part (bits 7 down to 0)
      for (i = 7; i >= 0; i = i - 1) begin
        test_root = root | (1 << (i + 16));
        test_square = test_root * test_root;
        if (test_square <= (value << 32)) begin
          root = test_root;
        end
      end
      sqrt_stage2 = root;
    end
  endfunction

  // STAGE 3: Fractional bits 15-8 (8 iterations)
  function [31:0] sqrt_stage3;
    input [31:0] value;
    input [31:0] partial_root;
    reg [31:0] root;
    reg [31:0] test_root;
    reg [63:0] test_square;
    integer i;
    begin
      root = partial_root;
      // First half of fractional part (bits 15 down to 8)
      for (i = 15; i >= 8; i = i - 1) begin
        test_root = root | (1 << i);  // Test fractional bits
        test_square = test_root * test_root;
        if (test_square <= (value << 32)) begin
          root = test_root;
        end
      end
      sqrt_stage3 = root;
    end
  endfunction

  // STAGE 4: Fractional bits 7-0 (8 iterations)
  function [31:0] sqrt_stage4;
    input [31:0] value;
    input [31:0] partial_root;
    reg [31:0] root;
    reg [31:0] test_root;
    reg [63:0] test_square;
    integer i;
    begin
      root = partial_root;
      // Second half of fractional part (bits 7 down to 0)
      for (i = 7; i >= 0; i = i - 1) begin
        test_root = root | (1 << i);
        test_square = test_root * test_root;
        if (test_square <= (value << 32)) begin
          root = test_root;
        end
      end
      sqrt_stage4 = root;
    end
  endfunction

  // 4-stage pipeline logic
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
      stage4_root <= 32'h0;
      
      stage1_valid <= 1'b0;
      stage2_valid <= 1'b0;
      stage3_valid <= 1'b0;
      stage4_valid <= 1'b0;
    end else begin
      
      // STAGE 1: Process new input (Integer bits 15-8)
      if (data_valid) begin
        stage1_value <= data_in;
        stage1_root <= sqrt_stage1(data_in);
        stage1_valid <= 1'b1;
      end else begin
        stage1_valid <= 1'b0;
      end
      
      // STAGE 2: Integer bits 7-0
      stage2_value <= stage1_value;
      stage2_root <= stage1_valid ? sqrt_stage2(stage1_value, stage1_root) : 32'h0;
      stage2_valid <= stage1_valid;
      
      // STAGE 3: Fractional bits 15-8
      stage3_value <= stage2_value;
      stage3_root <= stage2_valid ? sqrt_stage3(stage2_value, stage2_root) : 32'h0;
      stage3_valid <= stage2_valid;
      
      // STAGE 4: Fractional bits 7-0 (Final stage)
      stage4_value <= stage3_value;
      stage4_root <= stage3_valid ? sqrt_stage4(stage3_value, stage3_root) : 32'h0;
      stage4_valid <= stage3_valid;
      
      // Debug output for final stage
      if (stage3_valid) begin
        $display("DEBUG Final: input = %d, sqrt = %d", stage3_value, sqrt_stage4(stage3_value, stage3_root));
      end
    end
  end

  // Output assignments
  assign data_out = stage4_root;
  assign data_ready = stage4_valid;

endmodule