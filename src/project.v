/*
 * SPDX-License-Identifier: Apache-2.0
 */
`default_nettype none

module tt_um_lif_neuron (
    input  wire [7:0] ui_in,
    output wire [7:0] uo_out,
    input  wire [7:0] uio_in,
    output wire [7:0] uio_out,
    output wire [7:0] uio_oe,
    input  wire       ena,
    input  wire       clk,
    input  wire       rst_n
);

    assign uio_out = 8'b0;
    assign uio_oe  = 8'b0;
    wire _unused = &{uio_in};

    localparam integer V_BITS      = 9;
    localparam integer LEAK_SHIFT  = 3;          // leak ~= 12.5%/cycle
    localparam [V_BITS-1:0] THRESH = 9'd180;

    // Refractory period (cycles after a spike where neuron is silent)
    localparam integer REFRACT_CYCLES = 8;
    localparam integer R_BITS = 4;              // enough to hold up to 15

    reg [V_BITS-1:0] v;
    reg              spike_r;
    reg [R_BITS-1:0] refr;                      // refractory counter

    wire [V_BITS-1:0] i_in   = {1'b0, ui_in};
    wire [V_BITS-1:0] v_leak = v - (v >> LEAK_SHIFT);
    wire [V_BITS-1:0] v_pre  = v_leak + i_in;

    always @(posedge clk) begin
        if (!rst_n) begin
            v       <= {V_BITS{1'b0}};
            spike_r <= 1'b0;
            refr    <= {R_BITS{1'b0}};
        end else if (ena) begin
            // default: no spike unless we explicitly fire this cycle
            spike_r <= 1'b0;

            if (refr != 0) begin
                // In refractory: count down, hold membrane at 0 (or hold v if you prefer)
                refr <= refr - 1'b1;
                v    <= {V_BITS{1'b0}};
            end else begin
                // Normal integrate + fire
                if (v_pre >= THRESH) begin
                    spike_r <= 1'b1;
                    v       <= {V_BITS{1'b0}};
                    refr    <= REFRACT_CYCLES[R_BITS-1:0];
                end else begin
                    v <= v_pre;
                end
            end
        end else begin
            // not enabled: hold state, keep output quiet
            spike_r <= 1'b0;
            v       <= v;
            refr    <= refr;
        end
    end

    assign uo_out[0]   = spike_r;
    assign uo_out[7:1] = v[V_BITS-1:V_BITS-7];

endmodule

