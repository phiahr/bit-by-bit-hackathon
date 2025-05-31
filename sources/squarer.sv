/* verilator lint_off MULTITOP */


module squarer (
  input  [63:0] data_in,      // 8 x 8-bit values packed
  output [127:0] data_out     // 8 x 16-bit squared outputs concatenated
);

  wire [15:0] sq [7:0];       // Array of 8 wires, each 16-bit

  // Instantiate eight square modules for each byte
  square sq0 (.data_in(data_in[7:0]),    .data_out(sq[0]));
  square sq1 (.data_in(data_in[15:8]),   .data_out(sq[1]));
  square sq2 (.data_in(data_in[23:16]),  .data_out(sq[2]));
  square sq3 (.data_in(data_in[31:24]),  .data_out(sq[3]));
  square sq4 (.data_in(data_in[39:32]),  .data_out(sq[4]));
  square sq5 (.data_in(data_in[47:40]),  .data_out(sq[5]));
  square sq6 (.data_in(data_in[55:48]),  .data_out(sq[6]));
  square sq7 (.data_in(data_in[63:56]),  .data_out(sq[7]));

  // Concatenate all squared outputs into one 128-bit bus
  assign data_out = {sq[7], sq[6], sq[5], sq[4], sq[3], sq[2], sq[1], sq[0]};

endmodule
/* verilator lint_on MULTITOP */
