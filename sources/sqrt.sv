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

  // Generate individual stage functions for each bit
  function [31:0] sqrt_bit;
    input [31:0] value;
    input [31:0] partial_root;
    input [4:0] bit_pos;
    reg [31:0] root;
    reg [31:0] test_root;
    begin
      root = partial_root;
      test_root = root | (1 << bit_pos);  // Try setting this bit
      if (test_root * test_root <= value) begin
        root = test_root;  // Keep this bit if result is still <= value
      end
      sqrt_bit = root;
    end
  endfunction

  // 16-stage ultra-pipeline logic
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
      
      // STAGE 1: Bit 15 (MSB)
      stage_value[1] <= stage_value[0];
      stage_root[0] <= stage_valid[0] ? sqrt_bit(stage_value[0], 32'h0, 5'd15) : 32'h0;
      stage_valid[1] <= stage_valid[0];
      
      // STAGE 2: Bit 14
      stage_value[2] <= stage_value[1];
      stage_root[1] <= stage_valid[1] ? sqrt_bit(stage_value[1], stage_root[0], 5'd14) : 32'h0;
      stage_valid[2] <= stage_valid[1];
      
      // STAGE 3: Bit 13
      stage_value[3] <= stage_value[2];
      stage_root[2] <= stage_valid[2] ? sqrt_bit(stage_value[2], stage_root[1], 5'd13) : 32'h0;
      stage_valid[3] <= stage_valid[2];
      
      // STAGE 4: Bit 12
      stage_value[4] <= stage_value[3];
      stage_root[3] <= stage_valid[3] ? sqrt_bit(stage_value[3], stage_root[2], 5'd12) : 32'h0;
      stage_valid[4] <= stage_valid[3];
      
      // STAGE 5: Bit 11
      stage_value[5] <= stage_value[4];
      stage_root[4] <= stage_valid[4] ? sqrt_bit(stage_value[4], stage_root[3], 5'd11) : 32'h0;
      stage_valid[5] <= stage_valid[4];
      
      // STAGE 6: Bit 10
      stage_value[6] <= stage_value[5];
      stage_root[5] <= stage_valid[5] ? sqrt_bit(stage_value[5], stage_root[4], 5'd10) : 32'h0;
      stage_valid[6] <= stage_valid[5];
      
      // STAGE 7: Bit 9
      stage_value[7] <= stage_value[6];
      stage_root[6] <= stage_valid[6] ? sqrt_bit(stage_value[6], stage_root[5], 5'd9) : 32'h0;
      stage_valid[7] <= stage_valid[6];
      
      // STAGE 8: Bit 8
      stage_value[8] <= stage_value[7];
      stage_root[7] <= stage_valid[7] ? sqrt_bit(stage_value[7], stage_root[6], 5'd8) : 32'h0;
      stage_valid[8] <= stage_valid[7];
      
      // STAGE 9: Bit 7
      stage_value[9] <= stage_value[8];
      stage_root[8] <= stage_valid[8] ? sqrt_bit(stage_value[8], stage_root[7], 5'd7) : 32'h0;
      stage_valid[9] <= stage_valid[8];
      
      // STAGE 10: Bit 6
      stage_value[10] <= stage_value[9];
      stage_root[9] <= stage_valid[9] ? sqrt_bit(stage_value[9], stage_root[8], 5'd6) : 32'h0;
      stage_valid[10] <= stage_valid[9];
      
      // STAGE 11: Bit 5
      stage_value[11] <= stage_value[10];
      stage_root[10] <= stage_valid[10] ? sqrt_bit(stage_value[10], stage_root[9], 5'd5) : 32'h0;
      stage_valid[11] <= stage_valid[10];
      
      // STAGE 12: Bit 4
      stage_value[12] <= stage_value[11];
      stage_root[11] <= stage_valid[11] ? sqrt_bit(stage_value[11], stage_root[10], 5'd4) : 32'h0;
      stage_valid[12] <= stage_valid[11];
      
      // STAGE 13: Bit 3
      stage_value[13] <= stage_value[12];
      stage_root[12] <= stage_valid[12] ? sqrt_bit(stage_value[12], stage_root[11], 5'd3) : 32'h0;
      stage_valid[13] <= stage_valid[12];
      
      // STAGE 14: Bit 2
      stage_value[14] <= stage_value[13];
      stage_root[13] <= stage_valid[13] ? sqrt_bit(stage_value[13], stage_root[12], 5'd2) : 32'h0;
      stage_valid[14] <= stage_valid[13];
      
      // STAGE 15: Bit 1
      stage_value[15] <= stage_value[14];
      stage_root[14] <= stage_valid[14] ? sqrt_bit(stage_value[14], stage_root[13], 5'd1) : 32'h0;
      stage_valid[15] <= stage_valid[14];
      
      // STAGE 16: Bit 0 (LSB) + Final formatting
      stage_value[16] <= stage_value[15];
      if (stage_valid[15]) begin
        reg [31:0] final_sqrt;
        final_sqrt = sqrt_bit(stage_value[15], stage_root[14], 5'd0);
        
        // DEBUG: Print what input we're getting
        $display("DEBUG sqrt: input = %d, sqrt = %d", stage_value[15], final_sqrt);
       
        `ifdef FLOAT
          // Convert to floating point for FLOAT mode (placeholder)
          stage16_result <= final_sqrt << 16;
        `else
          // For fixed point mode, shift by fractional bits
          `ifdef FIXED
            stage16_result <= final_sqrt << `FIXED;
          `else
            stage16_result <= final_sqrt << 16;  // Default 16 fractional bits
          `endif
        `endif
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