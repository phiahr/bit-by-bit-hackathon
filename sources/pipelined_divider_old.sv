// module pipelined_divider_old (
//     input clk,
//     input rstn,
//     input start,
//     input [63:0] dividend,
//     input [31:0] divisor,
//     output reg [31:0] quotient,
//     output reg ready
// );


// reg [63:0] rem;
// reg [31:0] div;
// reg [5:0] count;
// reg [31:0] quot;
// reg busy;

// always @(posedge clk or negedge rstn) begin
//   if (!rstn) begin
//     quotient <= 0;
//     ready <= 0;
//     rem <= 0;
//     div <= 0;
//     quot <= 0;
//     count <= 0;
//     busy <= 0;
//   end else begin
//     if (start && !busy) begin
//       // Initialize
//       rem <= dividend;
//       div <= divisor;
//       quot <= 0;
//       count <= 32;
//       busy <= 1;
//       ready <= 0;
//     end else if (busy) begin
//       if (count > 0) begin
//         rem = {rem[62:0], 1'b0}; // Shift left
//         if (rem[63:32] >= div) begin
//           rem[63:32] = rem[63:32] - div;
//           quot = {quot[30:0], 1'b1};
//         end else begin
//           quot = {quot[30:0], 1'b0};
//         end
//         count = count - 1;
//       end else begin
//         busy <= 0;
//         quotient <= quot;
//         ready <= 1;
//       end
//     end else begin
//       ready <= 0;
//     end
//   end
// end
// endmodule