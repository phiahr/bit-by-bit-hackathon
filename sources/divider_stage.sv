// module divider_stage (
//     input clk,
//     input [31:0] dividend_in,
//     input [31:0] divisor_in,
//     input [7:0] quotient_in,
//     input [31:0] remainder_in,
//     output reg [7:0] quotient_out,
//     output reg [31:0] remainder_out
// );
//     always @(posedge clk) begin
//         integer i;
//         reg [31:0] rem;
//         reg [7:0] q;

//         rem = remainder_in;
//         q = quotient_in;

//         for (i = 0; i < 8; i = i + 1) begin
//             rem = rem << 1;
//             if (rem >= divisor_in) begin
//                 rem = rem - divisor_in;
//                 q = (q << 1) | 1;
//             end else begin
//                 q = q << 1;
//             end
//         end

//         quotient_out <= q;
//         remainder_out <= rem;
//     end
// endmodule
