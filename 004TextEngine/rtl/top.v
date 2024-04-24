module top
(
    input clk,
    output ioSclk,
    output ioSdin,
    output ioCs,
    output ioDc,
    output ioReset
);
    wire [9:0] pixelAddress;
    wire [7:0] pixelData;

    wire sys_reset;
    assign sys_reset = 0;

    screen scr(
        .clk_i(clk),
        .reset_i(sys_reset),
        .io_sclk_o(ioSclk),
        .io_sdin_o(ioSdin),
        .io_cs_o(ioCs),
        .io_dc_o(ioDc),
        .io_reset_o(ioReset),
        .pixelAddress_i(pixelAddress),
        .pixelData_i(pixelData)
    );

    textEngine te(
        clk,
        pixelAddress,
        pixelData
    );

endmodule