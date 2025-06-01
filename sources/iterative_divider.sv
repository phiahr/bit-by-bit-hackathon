module iterative_divider (
  input clk,
  input rstn,
  input start,
  input [63:0] numerator,
  input [31:0] denominator,
  output reg [31:0] quotient,
  output reg done
);

  reg [95:0] dividend; // Shift register: numerator shifted left + remainder
  reg [5:0] bit_;       // 0 to 64 bits

  reg running;

  always @(posedge clk) begin
    if (rstn) begin
      quotient <= 0;
      done <= 0;
      dividend <= 0;
      bit_ <= 0;
      running <= 0;
    end else begin
      if (start && !running) begin
        // Load numerator in dividend upper bits, clear quotient bits
        dividend <= {numerator, 32'b0}; // Shift numerator left by 32 bits for remainder
        bit_ <= 16;  // number of bits to process
        quotient <= 0;
        done <= 0;
        running <= 1;
      end else if (running) begin
        // Shift dividend left by 1 bit_
        dividend <= {dividend[94:0], 1'b0};
        // Subtract denominator if possible
        if (dividend[95:64] >= denominator) begin
          dividend[95:64] <= dividend[95:64] - denominator;
          quotient <= (quotient << 1) | 1'b1;
        end else begin
          quotient <= (quotient << 1);
        end
        bit_ <= bit_ - 1;

        if (bit_ == 0) begin
          done <= 1;
          running <= 0;
        end
      end else begin
        done <= 0; // clear done if not running or started
      end
    end
  end

endmodule
