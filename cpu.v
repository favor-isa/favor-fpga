module cpu(i_sw, o_led);
    input wire i_sw;
    output wire o_led;

    helper the_help(i_sw, o_led);
endmodule
