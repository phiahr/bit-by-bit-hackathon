module square_root_newton (  input clk,               
                  input rstn,             
                  input [31:0] in,
                  output reg [31:0] out,
                  input START,
                  output reg DONE,
                  output reg AVAILABLE);   


reg [3:0] cntr;
reg s1;
reg s2;
reg s3;
reg [31:0] in_val;
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
          in_val <= in;
          $display("In value:");
          $display(in);
          out <= (in >> 1) + 1;
          AVAILABLE <= 1'b0;
        end 
      end
      if (s2) begin
        $display("State 2");
        $display("outval init:");
        $display(out);
        
        if (cntr > 11) begin
          $display("S2 - counter > 5");
          s2 <= 1'b0;
          s3 <= 1'b1;
          DONE <= 1'b1;
          cntr <=  4'b0;
        end else begin
          $display("S2 - calcs result:");
          out <= (out + (in/out)) >> 1;
          $display(out);
          cntr <= cntr + 1;
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