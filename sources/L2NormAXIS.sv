 /*
 module L2NormAXIS(
  input         clock,
  input         reset,
  input  [63:0] io_in_tdata,
  input         io_in_tvalid,
  input         io_in_tuser, // Not necessary to use
  input  [7:0]  io_in_tkeep, // Not necessary to use
  output        io_in_tready,
  input         io_in_tlast,
  output [31:0] io_out_tdata,
  output        io_out_tvalid,
  output        io_out_tuser, // Not necessary to use
  output [3:0]  io_out_tkeep, // Not necessary to use
  input         io_out_tready,
  output        io_out_tlast
);

  // Internal accumulator for sum of input elements
  // reg signed [31:0] accumulator;
  // integer i;
  // reg signed [7:0] element [7:0];
  //   reg signed [15:0] sum_elements;


   // Signal to reset the accumulator at end of vector
  // wire reset_accum = io_in_tvalid && io_in_tready && io_in_tlast;


  wire [127:0] squared_input_data;
  // Accumulator output wire
  wire [31:0] accumulator_sum;
  reg [31:0] accumulator;

  
  squarer square_module (
    .data_in(io_in_tdata),
    .data_out(squared_input_data)
  );

  addElements sum_module (
    .data_in(squared_input_data),
    .sum_out(accumulator_sum)
  );

  // Replace this loop back with the actual logic for L2 norm calculation
  // ------------------------------------------------------------------------
  // ------------------------------------------------------------------------
  reg [31:0] result_data;
  reg result_valid;
  always @(posedge clock) begin
    if (reset) begin
      result_valid <= 1'b0;
      result_data <= 32'h0;
      accumulator <= 32'h0; // Reset the accumulator

    end else begin
      if (io_in_tvalid && io_in_tready) begin
        accumulator  <= accumulator + accumulator_sum;
      end

      if (io_in_tvalid && io_in_tready && io_in_tlast) begin
        result_data <= accumulator + accumulator_sum; // Use the accumulator as the result
        result_valid <= 1'b1;
        accumulator <= 32'h0; // Reset the accumulator
      end
      else if (io_out_tready && io_out_tvalid) begin
        result_valid <= 1'b0; // Clear valid when output is ready
      end
    end
  end

  assign io_in_tready = 1'b1; // Always ready to accept input
  assign io_out_tdata = result_data;
  assign io_out_tvalid = result_valid; // Output valid when result is ready
  assign io_out_tuser = 1'b0; // Not used
  assign io_out_tkeep = 4'b1111; // Not used, but can be set to all valid
  assign io_out_tlast = result_valid; // Indicate last when result is valid
  // ------------------------------------------------------------------------
  // ------------------------------------------------------------------------

endmodule

*/

/*

module L2NormAXIS(
  input         clock,
  input         reset,
  input  [63:0] io_in_tdata,
  input         io_in_tvalid,
  input         io_in_tuser, // Not necessary to use
  input  [7:0]  io_in_tkeep, // Not necessary to use
  output        io_in_tready,
  input         io_in_tlast,
  output [31:0] io_out_tdata,
  output        io_out_tvalid,
  output        io_out_tuser, // Not necessary to use
  output [3:0]  io_out_tkeep, // Not necessary to use
  input         io_out_tready,
  output        io_out_tlast
);

  // Step 1: Square the input data
  wire [127:0] squared_input_data;
  squarer square_module (
    .data_in(io_in_tdata),
    .data_out(squared_input_data)
  );

  // Step 2: Sum the squared elements
  wire [31:0] accumulator_sum;
  addElements sum_module (
    .data_in(squared_input_data),
    .sum_out(accumulator_sum)
  );

  // Step 3: Accumulate across multiple beats
  reg [31:0] accumulator;
  
  // Step 4: Square root calculation
  reg sqrt_trigger;
  wire [31:0] sqrt_result;
  wire sqrt_ready;
  
  sqrt sqrt_module (
    .clock(clock),
    .reset(reset),
    .data_in(accumulator + accumulator_sum),
    .data_valid(sqrt_trigger),
    .data_out(sqrt_result),
    .data_ready(sqrt_ready)
  );

  // Step 5: Output logic
  reg [31:0] result_data;
  reg result_valid;
  
  always @(posedge clock) begin
    if (reset) begin
      result_valid <= 1'b0;
      result_data <= 32'h0;
      accumulator <= 32'h0;
      sqrt_trigger <= 1'b0;
    end else begin
      sqrt_trigger <= 1'b0; // Default: no sqrt trigger
      
      if (io_in_tvalid && io_in_tready) begin
        if (io_in_tlast) begin
          // Last beat - trigger sqrt and reset accumulator
          sqrt_trigger <= 1'b1;
          accumulator <= 32'h0;
        end else begin
          // Continue accumulating
          accumulator <= accumulator + accumulator_sum;
        end
      end
      
      // When sqrt is ready, capture the result
      if (sqrt_ready) begin
        result_data <= sqrt_result;
        result_valid <= 1'b1;
      end else if (io_out_tready && io_out_tvalid) begin
        // Output consumed, clear valid
        result_valid <= 1'b0;
      end
    end
  end

  // Output assignments - same as before
  assign io_in_tready = 1'b1; // Always ready to accept input
  assign io_out_tdata = result_data;
  assign io_out_tvalid = result_valid;
  assign io_out_tuser = 1'b0;
  assign io_out_tkeep = 4'b1111;
  assign io_out_tlast = result_valid;

endmodule

*/

module L2NormAXIS(
  input         clock,
  input         reset,
  input  [63:0] io_in_tdata,
  input         io_in_tvalid,
  input         io_in_tuser, // Not necessary to use
  input  [7:0]  io_in_tkeep, // Not necessary to use
  output        io_in_tready,
  input         io_in_tlast,
  output [31:0] io_out_tdata,
  output        io_out_tvalid,
  output        io_out_tuser, // Not necessary to use
  output [3:0]  io_out_tkeep, // Not necessary to use
  input         io_out_tready,
  output        io_out_tlast
);

  // Step 1: Square the input data
  wire [127:0] squared_input_data;
  squarer square_module (
    .data_in(io_in_tdata),
    .data_out(squared_input_data)
  );

  // Step 2: Sum the squared elements  
  wire [31:0] accumulator_sum;
  addElements sum_module (
    .data_in(squared_input_data),
    .sum_out(accumulator_sum)
  );

  // Step 3: Accumulate across multiple beats
  reg [31:0] accumulator;
  reg [31:0] final_sum;  // Store the complete sum here
  
  // Step 4: Square root calculation
  reg sqrt_trigger;
  wire [31:0] sqrt_result;
  wire sqrt_ready;
  
  sqrt sqrt_module (
    .clock(clock),
    .reset(reset),
    .data_in(final_sum),     // Use stored final sum, not accumulator
    .data_valid(sqrt_trigger),
    .data_out(sqrt_result),
    .data_ready(sqrt_ready)
  );

  // Step 5: Output logic
  reg [31:0] result_data;
  reg result_valid;
  
  always @(posedge clock) begin
    if (reset) begin
      result_valid <= 1'b0;
      result_data <= 32'h0;
      accumulator <= 32'h0;
      final_sum <= 32'h0;
      sqrt_trigger <= 1'b0;
    end else begin
      sqrt_trigger <= 1'b0; // Default: no sqrt trigger
      
      if (io_in_tvalid && io_in_tready) begin
        if (io_in_tlast) begin
          // Last beat - store final sum and trigger sqrt
          final_sum <= accumulator + accumulator_sum;  // Store complete sum
          sqrt_trigger <= 1'b1;                        // Trigger sqrt
          accumulator <= 32'h0;                        // Reset for next vector
        end else begin
          // Continue accumulating
          accumulator <= accumulator + accumulator_sum;
        end
      end
      
      // When sqrt is ready, capture the result
      if (sqrt_ready) begin
        result_data <= sqrt_result;
        result_valid <= 1'b1;
      end else if (io_out_tready && io_out_tvalid) begin
        // Output consumed, clear valid
        result_valid <= 1'b0;
      end
    end
  end

  // Output assignments - same as before
  assign io_in_tready = 1'b1; // Always ready to accept input
  assign io_out_tdata = result_data;
  assign io_out_tvalid = result_valid;
  assign io_out_tuser = 1'b0;
  assign io_out_tkeep = 4'b1111;
  assign io_out_tlast = result_valid;

endmodule
