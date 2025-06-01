module newton_divider (
    input clk,
    input rstn,
    input start,
    input [31:0] dividend,
    input [31:0] divisor,
    output reg [31:0] quotient,
    output reg ready
);

// Fixed-point Q16.16
parameter ITERATIONS = 4;

reg [31:0] x, d, n;
reg [2:0] iter;
reg running;

wire [63:0] dx, xdx, two_minus_dx, x_next, result;

assign dx = d * x;                                // dx = D * x_n
assign xdx = {16'b0, 32'h20000} - dx;             // 2.0 - dx (2 in Q16.16 = 0x20000)
assign x_next = (x * xdx) >> 16;                  // x_{n+1} = x_n * (2 - D * x_n)
assign result = (n * x) >> 16;                    // Final division result: N * (1/D)

always @(posedge clk or negedge rstn) begin
  if (rstn) begin
    x <= 0;
    d <= 0;
    n <= 0;
    iter <= 0;
    running <= 0;
    quotient <= 0;
    ready <= 0;
  end else begin
    if (start && !running) begin
      // Initialize
      d <= divisor;
      n <= dividend;
    //   x <= 32'h10000; // Initial guess = 1.0 in Q16.16
      x <= 200; // Initial guess = 1.0 in Q16.16
      iter <= 0;
      running <= 1;
      ready <= 0;
    end else if (running) begin
      if (iter < ITERATIONS) begin
        x <= x_next[31:0];
        iter <= iter + 1;
      end else begin
        quotient <= result[31:0];
        ready <= 1;
        running <= 0;
      end
    end else begin
      ready <= 0;
    end
  end
end

endmodule
