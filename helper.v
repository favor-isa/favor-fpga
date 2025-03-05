module helper(i_input, o_output);
    input wire i_input;
    output wire o_output;

    assign o_output = ~i_input;
endmodule
