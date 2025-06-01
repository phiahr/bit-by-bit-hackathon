module square_root_newton (  input clk,               
                  input rstn,             
                  input [31:0] in,
                  output reg [31:0] out,
                  input START,
                  output reg DONE,
                  output reg AVAILABLE);   
// gives out 16 bit fixed point precision

reg [3:0] cntr;
reg s1;
reg s2;
reg s3;
reg [63:0] in_val;
reg div_start;
wire div_done;
reg [31:0] div_dividend;
reg [31:0] div_divisor;
wire [31:0] div_quotient;
wire [31:0] div_remainder;

divider_32bit divider_inst (
  .clk(clk),
  .rstn(rstn),
  .start(div_start),
  .dividend(div_dividend),
  .divisor(div_divisor),
  .quotient(div_quotient),
  .remainder(div_remainder),
  .done(div_done)
);

  always @ (posedge clk) begin
    if (rstn) begin
      out <= 0;
      in_val <= 0;
      DONE <= 1'b0;
      AVAILABLE <= 1'b1;
      cntr <= 4'b0;
      s1 <= 1'b1;
      s2 <= 1'b0;
      s3 <= 1'b0;
    end else begin
      if (s1) begin
        $display("State 1");
        AVAILABLE <= 1'b1;
        DONE <= 1'b0;
        if (START) begin
          $display("S1 - started");
          s1 <= 1'b0;
          s2 <= 1'b1;
          in_val[63:0] <= in;
          $display("In value:");
          $display(in);
          out <= 1;
          AVAILABLE <= 1'b0;
        end 
      end
      if (s2) begin
        $display("State 2");
        $display("outval init:");
        $display(out);
        
        if (cntr > 4) begin
          $display("S2 - counter > 5");
          s2 <= 1'b0;
          s3 <= 1'b1;
          DONE <= 1'b1;
          out <= out << 16;
          cntr <=  4'b0;
        end else begin
          $display("S2 - calcs result:");
          // out <= (out + (in/out)) >> 1;
          // cntr <= cntr + 1;
          if (!div_start && !div_done) begin
            div_start <= 1;
            div_dividend <= in;   // or in_val[63:32] if you want 64 bit input upper half
            div_divisor <= out;
          end else if (div_done) begin
            div_start <= 0;
            out <= (out + div_quotient) >> 1;
            cntr <= cntr + 1;
          end
          $display(out);
        end
      end
      if (s3) begin
        $display("State 3");
        $display(START);
        $display(DONE);
        $display(AVAILABLE);

        if (!START) begin
          $display("S3 - Start = 0");
          $display(START);
          s3 <= 1'b0;
          s1 <= 1'b1;
        end

      end

    end
  end
endmodule