module top
(
    input clk,
    output ioSclk,
    output ioSdin,
    output ioCs,
    output ioDc,
    output ioReset,
    // LEDs
    output [5:0] led
);
    wire [9:0] pixelAddress;
    wire [7:0] pixelData;
    wire [5:0] LEDdata;

    screen scr(
        clk, 
        ioSclk, 
        ioSdin, 
        ioCs, 
        ioDc, 
        ioReset, 
        pixelAddress,
        pixelData,
        LEDdata
    );

    textEngine te(
        clk,
        pixelAddress,
        pixelData
    );

    assign led = LEDdata;

endmodule