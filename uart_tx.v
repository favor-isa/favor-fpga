`default_nettype none

module uart_tx(
    input wire       i_clk,
    input wire [7:0] i_char,
    input wire       i_write,

    output reg       o_tx,
    output reg       o_busy
);

localparam STATE_IDLE  = 2'b00;
localparam STATE_START = 2'b01;
localparam STATE_DATA  = 2'b10;
localparam STATE_STOP  = 2'b11;

parameter CLKS_PER_BIT /* verilator public */ = 434; // 50_000_000 / 115200

reg [7:0] data;
reg [9:0] step;
reg [1:0] state = STATE_IDLE;

reg [2:0] count_bits;

// Important: o_tx must start at 1 because that's the idle value.
initial begin
    o_tx = 1;
end

/* verilator lint_off UNSIGNED */
always @(posedge i_clk) begin
    if(step < (CLKS_PER_BIT - 1)) begin
        step <= step + 1;
        if(i_write & ~o_busy) begin
            data   <= i_char;
            o_busy <= 1;
        end
    end else begin
        step <= 0;
        case(state)
            STATE_IDLE: begin
                o_tx <= 1;

                if(i_write & ~o_busy) begin
                    data   <= i_char;
                    o_busy <= 1;

                    state <= STATE_START;
                    // Count up from 1, so that the last bit will equal 111
                    // when we need to change state.
                    count_bits    <= 0;
                end
                if(o_busy) begin
                    state <= STATE_START;
                    // Count up from 1, so that the last bit will equal 111
                    // when we need to change state.
                    count_bits    <= 0;
                end
            end
            STATE_START: begin
                o_tx <= 0;
                state <= STATE_DATA;

                o_busy <= 1;
            end
            STATE_DATA: begin
                o_tx <= data[0];
                data <= { 1'b0, data[7:1] };
                count_bits  <= count_bits + 1;

                o_busy <= 1;

                if(& count_bits) begin
                    state <= STATE_IDLE;
                    o_busy <= 0;
                end
            end
            // If we want an extra stop bit, go to this case instead of
            // STATE_IDLE above.
            STATE_STOP: begin
                o_tx <= 1;
                state <= STATE_IDLE;

                // We are ready for more data come next clock cycle.
                o_busy <= 0;
            end
        endcase
    end
end

endmodule;
