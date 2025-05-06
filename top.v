`default_nettype none

module top(
    output wire o_tx,
    output wire o_led
);

wire osc_clk;

osc oscillator(.oscout(osc_clk), .oscen(1'b1));

wire [7:0] u_char;
wire       u_write;
wire       u_busy;

reg [28:0] led_count;
reg led_on;

initial led_on = 0;


always @(posedge osc_clk) begin
    led_count <= led_count + 1;
    if(led_count > 52_500_000) begin
        led_on <= ~led_on;
        led_count <= 0;
    end
end

assign o_led = led_on;

uart_buf ubuf(
    .i_clk(osc_clk),
    .i_busy(u_busy),
    .o_char(u_char),
    .o_write(u_write)
);
uart_tx #(.CLKS_PER_BIT(0)) utx 
(
    .i_clk(osc_clk),
    .i_char(u_char),
    .i_write(u_write),
    .o_tx(o_tx),
    .o_busy(u_busy)
);

endmodule