`default_nettype none

/* verilator lint_off UNUSEDSIGNAL */
module decoder(
    input wire        i_clk,
    input wire [31:0] i_insn,
    input wire [2047:0] i_gpr,
    output reg        o_valid,
    output reg [3:0]  o_to_state,
    output reg [3:0]  o_alu_op,
    output reg [1:0]  o_sz,
    output reg [63:0] o_src1,
    output reg [63:0] o_src2,
    output wire [4:0] o_dst
);

// The "kind" of instruction.
wire [1:0] k;

// K0 instruction identifier.
wire [3:0] k0;

// Singleton instruction identifier.
wire [24:0] sng;

// K1 instruction identifier.
wire [3:0] k1;
// K1 immediate value.
wire [15:0] k1_imm;

assign k   = i_insn[30:29];
assign k0  = i_insn[28:25];
assign sng = i_insn[24:0];

assign k1     = i_insn[19:16];
assign k1_imm = i_insn[15:0];

assign o_dst = i_insn[24:20]; 

`include "cpustate.vinc"

always @(*) begin

o_valid = 1;
o_to_state = STATE_EXECUTE;

o_alu_op = 0;
o_sz = i_insn[28:27];
//o_dst = i_insn[24:20];
o_src1 = i_gpr[{ i_insn[19:15], 6'b0 } +: 64];
o_src2 = i_gpr[{ i_insn[14:10], 6'b0 } +: 64];

// Handle singleton instructions.
if(k == 2'b00 && k0 == 4'b0000) begin
    case(sng)
        25'b0:   o_to_state = STATE_HALT;
        default: o_valid = 0;
    endcase
end
// 1-argument instructions
else if(k == 2'b01) begin
    case(k1)
        // load immediate
        4'b0000: begin
            o_src1 = { 48'b0, k1_imm };
            o_to_state = STATE_SRC1_TO_DST;
        end
        // load immediate upper
        4'b0001: begin
            o_src1 = i_gpr[{ o_dst, 6'b0 } +: 64] | { 32'b0, k1_imm, 16'b0 };
            o_to_state = STATE_SRC1_TO_DST;
        end
        // load immediate upper-upper
        4'b0010: begin
            o_src1 = i_gpr[{ o_dst, 6'b0 } +: 64] | { 16'b0, k1_imm, 32'b0 };
            o_to_state = STATE_SRC1_TO_DST;
        end
        // load immediate upper-upper-upper
        4'b0011: begin
            o_src1 = i_gpr[{ o_dst, 6'b0 } +: 64] | { k1_imm, 48'b0 };
            o_to_state = STATE_SRC1_TO_DST;
        end
        default: o_valid = 0;
    endcase
end
// 3-argument instructions.
else if(k == 2'b11) begin
    o_alu_op = i_insn[3:0];
end
else begin
    o_valid = 0;
end

end

endmodule
