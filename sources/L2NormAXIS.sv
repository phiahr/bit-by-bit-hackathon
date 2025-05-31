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


  // wire [63:0] squared_input_data;
  // Accumulator output wire
  wire [31:0] accumulator_sum;
  reg [31:0] accumulator;

  
  // squarer square_module (
  //   .data_in(io_in_tdata),
  //   .data_out(squared_input_data)
  // );

  addElements sum_module (
    .data_in(io_in_tdata),
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