module addElements (
  input  [127:0] data_in,
  output [31:0] sum_out
);

  integer i;
  // reg signed [7:0] elements [7:0];
  reg [15:0] sq_elements [7:0];
  
  reg [31:0] sum;

  always @(*) begin
    for (i = 0; i < 8; i = i + 1) begin

      // elements[i] = data_in[i*8 +: 8]; //* data_in[i*8 +: 8]; // Squaring the input elements
      sq_elements[i] = data_in[i*16 +: 16];
    end

    // for (i = 0; i < 8; i = i + 1) begin

    //   sq_elements[i] = elements[i] * elements[i];
    // end

    sum = 0;
    for (i = 0; i < 8; i = i + 1) begin
      sum = sum + sq_elements[i];
    end
  end

  assign sum_out = sum;

endmodule