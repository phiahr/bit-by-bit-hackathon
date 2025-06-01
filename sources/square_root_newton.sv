module square_root_newton (  input clk,               
                  input rstn,             
                  input [31:0] in,
                  output reg [63:0] out,
                  input START,
                  output reg DONE,
                  output reg AVAILABLE);   
// gives out 16 bit fixed point precision

reg [3:0] cntr;
reg [3:0] div_cntr;

reg s1;
reg s2;
reg s21;
reg s3;
reg [127:0] in_val;
reg [127:0] div_out;
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
          in_val[63:32] <= in;
          $display("In value:");
          $display(in);
          out <= 500;
          AVAILABLE <= 1'b0;
        end 
      end
      if (s2) begin
        $display("State 2");
        $display("outval init:");
        $display(out);
        
        if (cntr > 14) begin
          $display("S2 - counter > 5");
          s2 <= 1'b0;
          s3 <= 1'b1;
          DONE <= 1'b1;
          cntr <=  4'b0;
        end else begin
          div_out <= 10;
          div_cntr <= 0;
          s2 <= 1'b0;
          s21 <= 1'b1;

        end
      end
      if (s21) begin
        if (div_cntr > 10) begin
          
          
          s21 <= 1'b0;
          s2 <= 1'b1;
          cntr <=  cntr + 1;
          out <= (out + (in_val*div_out)) >> 1;
          $display("div > threschold (div, out):");
          $display(div_out);
          $display(out);

        end else begin
          div_out <= div_out*(2- (div_out * out));
          div_cntr <= div_cntr + 1;
          $display("diving (div):");
          $display(div_out);
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