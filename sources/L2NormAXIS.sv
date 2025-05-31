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

  // Replace this loop back with the actual logic for L2 norm calculation
  // ------------------------------------------------------------------------
  // ------------------------------------------------------------------------
  reg [31:0] result_data;
  reg result_valid;
  always @(posedge clock) begin
    if (reset) begin
      result_valid <= 1'b0;
      result_data <= 32'h0;
    end else begin
      if (io_in_tvalid && io_in_tready && io_in_tlast) begin
        // result_data <= io_in_tdata[31:0];
        result_data <= 32'h19;

        result_valid <= 1'b1;
      end else if (io_out_tready && io_out_tvalid) begin
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