module square (
  input signed [7:0] data_in,
  output [15:0] data_out
);
  assign data_out = data_in * data_in; // Squaring the input

endmodule
