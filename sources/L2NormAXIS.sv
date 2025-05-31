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
  reg [31:0] result_buffer;
  reg result_valid;
  wire [3:0] c1_out;
  reg computations_done;
  reg START_SQ;
  wire DONE_SQ;
  wire AVAILABLE_SQ;
  // module square_root (  input clk,               
  //                 input rstn,             
  //                 input [31:0] in,
  //                 output reg [31:0] out,
  //                 input START,
  //                 output reg DONE,
  //                 output reg AVAILABLE);   
  square_root sq1(
    .clk(clock),
    .rstn(reset),
    .in(io_in_tdata[31:0]),
    .out(result_buffer),
    .START(START_SQ),
    .DONE(DONE_SQ),
    .AVAILABLE(AVAILABLE_SQ)
  );
  always @(posedge clock) begin
    if (reset) begin
      result_valid <= 1'b0;
      result_data <= 32'h0;
      START_SQ <= 1'b0;
    end else begin
      
      if (io_in_tvalid && io_in_tready && io_in_tlast ) begin
        // $display("Data in");
        // $display(io_in_tdata);
        // result_data <= io_in_tdata[31:0];
        // result_data <= 32'h19;
        // result_valid <= 1'b1;
      $display("Main loop receive data");
        START_SQ <= 1'b1;
      end
      if(DONE_SQ) begin
      $display("Main loop send data");
        result_data <= result_buffer;
        START_SQ <= 1'b0;
        result_valid <= 1'b1;
      end else begin
      $display("Main loop wait");
      end
      if (io_out_tready && io_out_tvalid) begin
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