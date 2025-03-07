/* verilator lint_off UNUSEDSIGNAL */
module decoder(
    input wire        i_clk,
    input wire [31:0] i_insn,
    output reg        o_valid = 0,
    output reg        o_halt = 0
);

// The "kind" of instruction.
wire [1:0] k;

// K0 instruction identifier.
wire [3:0] k0;

// Singleton instruction identifier.
wire [24:0] sng;

assign k   = i_insn[30:29];
assign k0  = i_insn[28:25];
assign sng = i_insn[24:0];

`include "cpustate.vinc"

// always @(posedge i_clk) begin
//     o_valid <= 0;

//     case(k)
//         2'b00: begin
//             case(k0)
//                 2'b00: begin

//                 end

//             endcase
//         end
//         2'b01: begin
//         end
//         2'b10: begin
//         end
//         2'b11: begin
//         end
//     endcase
// end

endmodule
