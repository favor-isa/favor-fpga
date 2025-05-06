`default_nettype none

module top_sim(
    input wire i_clk,
    output wire o_tx
);

wire [7:0] u_char;
wire       u_write;
wire       u_busy;

uart_buf ubuf(
    .i_clk(i_clk),
    .i_busy(u_busy),
    .o_char(u_char),
    .o_write(u_write)
);
uart_tx #(.CLKS_PER_BIT(0)) utx 
(
    .i_clk(i_clk),
    .i_char(u_char),
    .i_write(u_write),
    .o_tx(o_tx),
    .o_busy(u_busy)
);

endmodule
