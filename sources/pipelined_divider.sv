module divider_32bit_4stage (
    input wire clk,
    input wire rstn,
    input wire start,
    input wire [31:0] dividend,
    input wire [31:0] divisor,
    output reg [31:0] quotient,
    output reg [31:0] remainder,
    output reg done
);

    reg [1:0] stage;
    reg [63:0] rem_reg;
    reg [31:0] div;
    reg running;

    always @(posedge clk or negedge rstn) begin
        if (rstn) begin
            quotient <= 0;
            remainder <= 0;
            rem_reg <= 0;
            div <= 0;
            stage <= 0;
            done <= 0;
            running <= 0;
        end else begin
            if (start && !running) begin
                rem_reg <= {32'b0, dividend};  // 64-bit register: upper 32 bits for remainder
                div <= divisor;
                quotient <= 0;
                stage <= 0;
                done <= 0;
                running <= 1;
            end else if (running) begin
                integer i;
                for (i = 0; i < 2; i = i + 1) begin
                    rem_reg <= rem_reg << 1;
                    if (rem_reg[63:32] >= div) begin
                        rem_reg[63:32] <= rem_reg[63:32] - div;
                        quotient <= (quotient << 1) | 1'b1;
                    end else begin
                        quotient <= quotient << 1;
                    end
                end

                stage <= stage + 1;
                if (stage == 3) begin
                    remainder <= rem_reg[63:32];
                    done <= 1;
                    running <= 0;
                end
            end else begin
                done <= 0;
            end
        end
    end

endmodule
