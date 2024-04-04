module textEngine (
    input clk,
    input [9:0] pixelAddress,
    output [7:0] pixelData
);
    reg [7:0] fontBuffer [1519:0];
    initial $readmemh("font.hex", fontBuffer);

    // Next we know how to split up the address from a pixel index to the desired character index column and whether or not we are on the top row:
    wire [5:0] charAddress;    
    wire [2:0] columnAddress;    
    wire topRow;    

    reg [7:0] outputBuffer;

    // We also need a buffer to store the output byte. Connecting these up is simple now that we understand the mapping:
    // The column address is the last 3 bits, the character address is made up of a lower 16 counter and the higher 4 counter for the rows. For the flag which indicates whether we are on the top row or bottom row we can just take a look at bit number 8 where it will be 0 if we are on the top row and 1 if it is the second iteration and we are on the bottom, so we invert it to match the flag name. Last but not least we hookup the outputBuffer to the pixelData output wires.
    assign charAddress = {pixelAddress[9:8],pixelAddress[6:3]};
    assign columnAddress = pixelAddress[2:0];
    assign topRow = !pixelAddress[7];

    assign pixelData = outputBuffer;
    
    // To get started we can create some more wires to store the current char and the current char we want to display.
    wire [7:0] charOutput, chosenChar;

    // We have two variables for this because our font memory only has values for the character codes 32-126 other character codes would give an undefined behavior. So charOutput will be the actual character we want to output, and chosenChar will check if it is in range and if not replace the character with a space (character code 32) so it will simply be blank:
    // If we look back at how we stored our font data, we stored the first column top byte then the first column second byte then the next column top byte and so on.
    assign chosenChar = (charOutput >= 32 && charOutput <= 126) ? charOutput : 32;
    // So if we want the letter "A" in memory, we know that its ascii code is 65 and our memory starts from ascii code 32 subtracting them gives us the number of characters from the start of memory we need to skip which in this case is 33. We need to multiply this number by 16 as each character is 16 bytes long giving us 528 bytes. Next if we wanted column index 3 we know each column is 2 bytes so we would need to skip another 6 bytes. Lastly once at the column boundary we know the first byte is for the top row and the second byte is for the bottom row of the character, so depending on which we need we optionally skip another byte.
    // We take the character we want to display, subtract 32 to get the offset from start of memory. Multiply by 16 (by shifting left 4 times) to get the start of the character. Add to this the column address multiplied by 2 (again by shifting left by 1) and optionally adding another 1 if we are on the bottom row.
    // This can be used to access the exact byte from the font memory needed:
    always @(posedge clk) begin
        // With this one line we are mapping the desired character to the exact pixels for the specific column and row.
        outputBuffer <= fontBuffer[((chosenChar-8'd32) << 4) + (columnAddress << 1) + (topRow ? 0 : 1)];
    end

    // The only thing missing is to know which character to output, but for now if we just add:
    assign charOutput = "A"; 

endmodule