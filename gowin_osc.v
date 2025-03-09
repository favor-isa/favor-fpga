`default_nettype none

module osc (oscout, oscen);

output wire oscout;
input  wire oscen;

OSCA osc_inst (
    .OSCOUT(oscout),
    .OSCEN(oscen)
);

defparam osc_inst.FREQ_DIV = 2;

endmodule