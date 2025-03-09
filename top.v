`default_nettype none

module top(
    output wire o_led
);

wire osc_clk;

osc oscillator(.oscout(osc_clk), .oscen(1'b1));
cpu cpu(.i_clk(osc_clk), .o_led(o_led));

endmodule