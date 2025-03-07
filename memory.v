`default_nettype none

module memory(
    input  wire i_clk,
    input  wire i_read,
    input  wire [13:0] i_address,
    output reg  [31:0] o_bit
);

// according to the documentation we have 56 block rams
// with 1008K bits each. So, that should be 56_448_000 bits,
// which the nearest power of two that fits is 25. So let's
// start with 25.
//
// Note that lg(1008000) is itself ~19.9. So we could also try
// doing a memory of size 19 to see if that lets the IDE compile
// our dang code faster.
//
// 19 - 5 = 14
parameter LGMEMSZ = 19 - 5; 

reg [31:0] ram[0:(1<<LGMEMSZ)-1] /* verilator public */;
initial $readmemh("initial_ram.txt", ram);

always @(posedge i_clk) begin
    if(i_read) begin
        o_bit <= ram[i_address];
    end
end

endmodule
