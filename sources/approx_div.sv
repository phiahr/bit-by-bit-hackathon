
module approx_div (
  input clk,
  input rstn,
  input start,
  input [63:0] numerator,  // in_val (64-bit)
  input [31:0] denominator, // out (32-bit)
  output reg [31:0] result, // approximate numerator / denominator
  output reg done
);

  // Internal pipeline registers
  reg [2:0] stage;
  reg [31:0] recip;
  reg [63:0] product;

  always @(posedge clk) begin
    if (rstn) begin
      done <= 0;
      stage <= 0;
      recip <= 0;
      product <= 0;
      result <= 0;
    end else begin
      case (stage)
        0: begin
          if (start) begin
            stage <= 1;
            done <= 0;
          end
        end
        1: begin
          // Approximate reciprocal using fixed-point: recip = (2^32) / denominator
          // Since denominator is in 16.16, we compute: (1 << 32) / denominator
          recip <= (32'hFFFFFFFF / denominator); // Simple approximation
          stage <= 2;
        end
        2: begin
          // Multiply: numerator * reciprocal
          product <= numerator * recip;  // 64 * 32 = 96, but take 64 bits
          stage <= 3;
        end
        3: begin
          // Adjust fixed-point scale by shifting
          result <= product[47:16]; // shift down by 16 bits
          done <= 1;
          stage <= 0;
        end
      endcase
    end
  end
endmodule

