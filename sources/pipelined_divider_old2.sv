// module divider_stage #(parameter STAGE_ID = 0)(
//     input clk,
//     input [31:0] dividend_in,
//     input [31:0] divisor_in,
//     input [31:0] quotient_in,
//     input [31:0] remainder_in,
//     output reg [31:0] quotient_out,
//     output reg [31:0] remainder_out
// );
//     reg [3:0] i;
//     reg [31:0] rem;
//     reg [31:0] quot;

//     always @(posedge clk) begin
//         rem = remainder_in;
//         quot = quotient_in;

//         for (i = 0; i < 8; i = i + 1) begin
//             rem = rem << 1;
//             if (rem >= divisor_in) begin
//                 rem = rem - divisor_in;
//                 quot = (quot << 1) | 1;
//             end else begin
//                 quot = quot << 1;
//             end
//         end

//         quotient_out <= quot;
//         remainder_out <= rem;
//     end
// endmodule

// module pipelined_divider (
//     input clk,
//     input [31:0] dividend,
//     input [31:0] divisor,
//     input start,
//     output [31:0] quotient,
//     output reg ready
// );
//     reg [2:0] count = 0;
//     reg [31:0] r0 = 0, r1 = 0, r2 = 0, r3 = 0;
//     reg [31:0] q0 = 0, q1 = 0, q2 = 0, q3 = 0;

//     always @(posedge clk) begin
//         if (start) begin
//             q0 <= 0;
//             r0 <= dividend;
//             ready <= 0;
//             count <= 0;
//         end else begin
//             if (count == 0) begin
//                 r1 <= r0; q1 <= q0;
//             end else if (count == 1) begin
//                 r2 <= r1; q2 <= q1;
//             end else if (count == 2) begin
//                 r3 <= r2; q3 <= q2;
//             end else if (count == 3) begin
//                 ready <= 1;
//             end
//             count <= count + 1;
//         end
//     end

//     wire [31:0] q1_stage, r1_stage, q2_stage, r2_stage, q3_stage, r3_stage, q4_stage, r4_stage;

//     divider_stage #(.STAGE_ID(0)) s0(clk, r0, divisor, q0, 0, q1_stage, r1_stage);
//     divider_stage #(.STAGE_ID(1)) s1(clk, r1_stage, divisor, q1_stage, r1_stage, q2_stage, r2_stage);
//     divider_stage #(.STAGE_ID(2)) s2(clk, r2_stage, divisor, q2_stage, r2_stage, q3_stage, r3_stage);
//     divider_stage #(.STAGE_ID(3)) s3(clk, r3_stage, divisor, q3_stage, r3_stage, quotient, r4_stage);
// endmodule
