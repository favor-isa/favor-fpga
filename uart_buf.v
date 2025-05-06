`default_nettype none

module uart_buf(
    input wire i_clk,
    input wire i_busy,

    output reg [7:0] o_char,
    output reg       o_write
);

reg was_busy = 1;
reg [2:0] idx;

reg [7:0] test_message [4:0];

initial begin
    test_message[0] = "h";
    test_message[1] = "o";
    test_message[2] = "r";
    test_message[3] = "s";
    test_message[4] = "e";
end

always @(posedge i_clk) begin
    o_write <= 0;

    if(~i_busy & was_busy) begin
        idx <= idx + 1;
        if(idx == 4) begin
            idx <= 0;
        end;

        o_char <= test_message[idx];
        o_write <= 1;
    end

    was_busy <= i_busy;
end

endmodule
