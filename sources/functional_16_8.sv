module sqrt (
  input         clock,
  input         reset,
  input  [31:0] data_in,       // Sum of squares input
  input         data_valid,    // Input data is valid
  output [31:0] data_out,      // Square root result
  output        data_ready     // Output data is ready
);

  // 16-stage pipeline registers
  reg [31:0] stage_value [0:16];   // Value propagates through all stages
  reg [31:0] stage_root [0:15];    // Root builds up through stages
  reg [31:0] stage16_result;       // Final formatted result
  reg [16:0] stage_valid;          // Valid signals for all stages

  // Unified bit function - handles both integer and fractional bits uniformly
  function [31:0] sqrt_unified_bits;
    input [31:0] value;
    input [31:0] partial_root;
    input [4:0] high_bit;    // highest bit position for this stage
    input [4:0] num_bits;    // number of bits to process (1 or 2)
    reg [31:0] root;
    reg [31:0] test_root;
    reg [63:0] test_square;
    integer i;
    begin
      root = partial_root;
      // Process the specified number of bits
      for (i = 0; i < num_bits; i = i + 1) begin
        test_root = root | (1 << (high_bit - i));  // Test this bit position
        test_square = test_root * test_root;
        if (test_square <= (value << 24)) begin  // Updated scaling for 16.12 format
          root = test_root;
        end
      end
      sqrt_unified_bits = root;
    end
  endfunction

  // 16-stage unified pipeline: 28 total bits (16 integer + 12 fractional)
  always @(posedge clock) begin
    if (reset) begin
      // Reset all pipeline stages
      integer i;
      for (i = 0; i <= 16; i = i + 1) begin
        stage_value[i] <= 32'h0;
        stage_valid[i] <= 1'b0;
      end
      for (i = 0; i <= 15; i = i + 1) begin
        stage_root[i] <= 32'h0;
      end
      stage16_result <= 32'h0;
    end else begin
      
      // STAGE 0: Input stage
      if (data_valid) begin
        stage_value[0] <= data_in;
        stage_valid[0] <= 1'b1;
      end else begin
        stage_valid[0] <= 1'b0;
      end
      
      // STAGE 1: Bits 27,26 (integer MSBs)
      stage_value[1] <= stage_value[0];
      stage_root[0] <= stage_valid[0] ? sqrt_unified_bits(stage_value[0], 32'h0, 5'd27, 5'd2) : 32'h0;
      stage_valid[1] <= stage_valid[0];
      
      // STAGE 2: Bits 25,24
      stage_value[2] <= stage_value[1];
      stage_root[1] <= stage_valid[1] ? sqrt_unified_bits(stage_value[1], stage_root[0], 5'd25, 5'd2) : 32'h0;
      stage_valid[2] <= stage_valid[1];
      
      // STAGE 3: Bits 23,22
      stage_value[3] <= stage_value[2];
      stage_root[2] <= stage_valid[2] ? sqrt_unified_bits(stage_value[2], stage_root[1], 5'd23, 5'd2) : 32'h0;
      stage_valid[3] <= stage_valid[2];
      
      // STAGE 4: Bits 21,20
      stage_value[4] <= stage_value[3];
      stage_root[3] <= stage_valid[3] ? sqrt_unified_bits(stage_value[3], stage_root[2], 5'd21, 5'd2) : 32'h0;
      stage_valid[4] <= stage_valid[3];
      
      // STAGE 5: Bits 19,18
      stage_value[5] <= stage_value[4];
      stage_root[4] <= stage_valid[4] ? sqrt_unified_bits(stage_value[4], stage_root[3], 5'd19, 5'd2) : 32'h0;
      stage_valid[5] <= stage_valid[4];
      
      // STAGE 6: Bits 17,16
      stage_value[6] <= stage_value[5];
      stage_root[5] <= stage_valid[5] ? sqrt_unified_bits(stage_value[5], stage_root[4], 5'd17, 5'd2) : 32'h0;
      stage_valid[6] <= stage_valid[5];
      
      // STAGE 7: Bits 15,14
      stage_value[7] <= stage_value[6];
      stage_root[6] <= stage_valid[6] ? sqrt_unified_bits(stage_value[6], stage_root[5], 5'd15, 5'd2) : 32'h0;
      stage_valid[7] <= stage_valid[6];
      
      // STAGE 8: Bits 13,12 (last integer bits)
      stage_value[8] <= stage_value[7];
      stage_root[7] <= stage_valid[7] ? sqrt_unified_bits(stage_value[7], stage_root[6], 5'd13, 5'd2) : 32'h0;
      stage_valid[8] <= stage_valid[7];
      
      // STAGE 9: Bits 11,10 (first fractional bits)
      stage_value[9] <= stage_value[8];
      stage_root[8] <= stage_valid[8] ? sqrt_unified_bits(stage_value[8], stage_root[7], 5'd11, 5'd2) : 32'h0;
      stage_valid[9] <= stage_valid[8];
      
      // STAGE 10: Bits 9,8
      stage_value[10] <= stage_value[9];
      stage_root[9] <= stage_valid[9] ? sqrt_unified_bits(stage_value[9], stage_root[8], 5'd9, 5'd2) : 32'h0;
      stage_valid[10] <= stage_valid[9];
      
      // STAGE 11: Bits 7,6
      stage_value[11] <= stage_value[10];
      stage_root[10] <= stage_valid[10] ? sqrt_unified_bits(stage_value[10], stage_root[9], 5'd7, 5'd2) : 32'h0;
      stage_valid[11] <= stage_valid[10];
      
      // STAGE 12: Bits 5,4
      stage_value[12] <= stage_value[11];
      stage_root[11] <= stage_valid[11] ? sqrt_unified_bits(stage_value[11], stage_root[10], 5'd5, 5'd2) : 32'h0;
      stage_valid[12] <= stage_valid[11];
      
      // STAGE 13: Bits 3,2
      stage_value[13] <= stage_value[12];
      stage_root[12] <= stage_valid[12] ? sqrt_unified_bits(stage_value[12], stage_root[11], 5'd3, 5'd2) : 32'h0;
      stage_valid[13] <= stage_valid[12];
      
      // STAGE 14: Bits 1,0 (fractional LSBs)
      stage_value[14] <= stage_value[13];
      stage_root[13] <= stage_valid[13] ? sqrt_unified_bits(stage_value[13], stage_root[12], 5'd1, 5'd2) : 32'h0;
      stage_valid[14] <= stage_valid[13];
      
      // STAGE 15: Buffer stage
      stage_value[15] <= stage_value[14];
      stage_root[14] <= stage_root[13];
      stage_valid[15] <= stage_valid[14];
      
      // STAGE 16: Final formatting
      stage_value[16] <= stage_value[15];
      if (stage_valid[15]) begin
        reg [31:0] final_sqrt;
        final_sqrt = stage_root[14];
        
        // Result is in 16.12 format (bits 27:12 = integer, bits 11:0 = fractional)
        // Use the exact same output format as your original working code
        `ifdef FLOAT
          // Convert to floating point for FLOAT mode (placeholder)
          stage16_result <= final_sqrt << 16;
        `else
          // For fixed point mode, shift by fractional bits
          `ifdef FIXED
            stage16_result <= final_sqrt << (`FIXED - 12);  // Account for our 12 fractional bits
          `else
            stage16_result <= final_sqrt << 4;  // Shift by 4 more to get 16 total fractional bits
          `endif
        `endif
        
        // DEBUG: Show both integer and fractional parts
        $display("DEBUG sqrt: input = %d, sqrt = %d.%d (16.12 fixed point)", 
                 stage_value[15], final_sqrt >> 12, final_sqrt & 12'hFFF);
      end else begin
        stage16_result <= 32'h0;
      end
      stage_valid[16] <= stage_valid[15];
    end
  end

  // Output assignments
  assign data_out = stage16_result;
  assign data_ready = stage_valid[16];

endmodule