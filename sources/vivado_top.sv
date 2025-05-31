module vivado_top (
    input clk_in1_p,
    input clk_in1_n,
    input reset_clk,
    input reset_n,
    output led0,
    output led1,
    output led2,
    output led3
);

  wire locked;
  wire clock;
  reg [5:0] reset_sync;
  reg [26:0] clock_divider;

  wire [63:0]  io_in_tdata;
  wire         io_in_tvalid;
  wire         io_in_tuser;
  wire [7:0]   io_in_tkeep;
  wire         io_in_tready;
  wire         io_in_tlast;
  wire  [31:0] io_out_tdata;
  wire         io_out_tvalid;
  wire         io_out_tuser;
  wire  [3:0]  io_out_tkeep;
  wire         io_out_tready;
  wire         io_out_tlast;

  clk_wiz_0 i_clock_wizard
   (
        // Clock out ports
        .clk_out1(clock),         // output clk_out1
        // Status and control signals
        .reset(reset_clk),        // input reset
        .locked(locked),          // output locked
        // Clock in ports
        .clk_in1_p(clk_in1_p),    // input clk_in1_p
        .clk_in1_n(clk_in1_n)     // input clk_in1_n
    );

    always @(posedge clock or negedge reset_n) begin
        if (!reset_n) begin
            reset_sync <= 6'b111111; // Assert all bits on reset
        end else begin
            reset_sync <= {reset_sync[4:0], 1'b0}; // Shift in a 0
        end
    end
    wire reset_sync_out = !reset_sync[5]; // Use the last bit as the reset signal

    always @(posedge clock) begin
        if (reset_sync_out) begin
            clock_divider <= 27'b0; // Reset the clock divider
        end else begin
            clock_divider <= clock_divider + 1; // Increment the clock divider
        end
    end

    assign led0 = reset_sync_out;    // Indicate if the reset is active
    assign led1 = locked;            // Indicate if the clock is locked
    assign led2 = reset_clk;         // Indicate the mmcm reset signal
    assign led3 = clock_divider[26]; // Clock divider output for debuging
    
    L2NormAXIS i_l2_norm_axis (
        .clock(clock),
        .reset(reset_sync_out),
        .io_in_tdata(io_in_tdata),
        .io_in_tvalid(io_in_tvalid && !io_in_tvalid_d),
        .io_in_tuser(io_in_tuser),
        .io_in_tkeep(io_in_tkeep),
        .io_in_tready(io_in_tready),
        .io_in_tlast(io_in_tlast),
        .io_out_tdata(io_out_tdata),
        .io_out_tvalid(io_out_tvalid),
        .io_out_tuser(io_out_tuser),
        .io_out_tkeep(io_out_tkeep),
        .io_out_tready(1'b1), // Always ready to accept output
        .io_out_tlast(io_out_tlast)
    );

    reg io_in_tvalid_d;
    always @(posedge clock) begin
        if (reset_sync_out) begin
            io_in_tvalid_d <= 1'b0; // Reset the valid signal
        end else begin
            io_in_tvalid_d <= io_in_tvalid; // Store the current valid state
        end
    end


    vio_0 i_vio_0 (
        .clk(clock),                // input wire clk
        .probe_in0(io_in_tready),    // input wire [0 : 0] probe_in0
        .probe_out0(io_in_tdata),  // output wire [63 : 0] probe_out0
        .probe_out1(io_in_tvalid),  // output wire [0 : 0] probe_out1
        .probe_out2(io_in_tlast)  // output wire [0 : 0] probe_out2
    );

    ila_0 i_ila_0 (
        .clk(clock),                // input wire clk
        .probe0(io_out_tdata),     // input wire [31 : 0] probe3
        .probe1(io_out_tvalid),    // input wire [0 : 0] probe4
        .probe2(io_out_tlast)      // input wire [0 : 0] probe5
    );

endmodule