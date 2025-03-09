`default_nettype none

/* verilator lint_off UNUSEDSIGNAL */
module decoder(
    input wire        i_clk,
    input wire [31:0] i_insn,
    input wire        i_decode,
    output reg        o_valid = 0,
    output reg [3:0]  o_to_state = 0
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

always @(*) begin

o_valid = 1;
o_to_state = STATE_EXECUTE;

// TODO: Delete i_decode

// Handle singleton instructions.
if(k == 2'b00 && k0 == 4'b0000) begin
    case(sng)
        25'b0:   o_to_state = STATE_HALT;
        default: o_valid = 0;
    endcase
end
else begin
    o_valid = 0;
end

end

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
