/* verilator lint_off UNUSEDSIGNAL */

`default_nettype none

module alu(
    input  wire  [3:0] i_op,
    input  wire  [1:0] i_sz,
    input  wire [63:0] i_src1,
    input  wire [63:0] i_src2,
    output reg  [63:0] o_dest
);

reg [64:0] result;

always @(*) begin
    result = 65'b0;
    case(i_op)
        4'b0000: result = i_src1 + i_src2;
        4'b0001: result = i_src1 - i_src2;
        default: ;
    endcase
end

always @(*) begin
    case(i_sz)
        2'b00: o_dest = { 56'b0, result[ 7:0] };
        2'b01: o_dest = { 48'b0, result[15:0] };
        2'b10: o_dest = { 32'b0, result[31:0] };
        2'b11: o_dest =          result[63:0];
    endcase
end

endmodule
