module newton_divisers (  input clk,               
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
      cntr <= 5'b0;
      s1 <= 1'b1;
      s2 <= 1'b0;
      s3 <= 1'b0;
    end else begin
      if (s1) begin
        $display("DState 1");
        AVAILABLE <= 1'b1;
        DONE <= 1'b0;
        if (START) begin
          $display("DS1 - started");
          s1 <= 1'b0;
          s2 <= 1'b1;
          in_val[63:32] <= in;
          $display("DIn value:");
          $display(in);
          out <= 500;
          AVAILABLE <= 1'b0;
        end 
      end
      if (s2) begin
        $display("DState 2");
        $display("Doutval init:");
        $display(out);
        
        if (cntr > 14) begin
          $display("DS2 - counter > 5");
          s2 <= 1'b0;
          s3 <= 1'b1;
          DONE <= 1'b1;
          cntr <=  4'b0;
        end else begin
          $display("DS2 - calcs result:");
        //   X n+1​ =X n​ (2−B⋅X n​ )
          out <= (out *(2 - in_val*out));
          $display(out);
          cntr <= cntr + 1;
        end
      end
      if (s3) begin
        $display("DState 3");
        $display(START);
        $display(DONE);
        $display(AVAILABLE);

        if (!START) begin
          $display("DS3 - Start = 0");
          $display(START);
          s3 <= 1'b0;
          s1 <= 1'b1;
        end

      end

    end
  end
endmodule