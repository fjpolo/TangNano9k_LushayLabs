`default_nettype none

module toHex(
    input clk,
    input [3:0] value,
    output reg [7:0] hexChar = "0"
);
    always @(posedge clk) begin
        hexChar <= (value <= 9) ? 8'd48 + value : 8'd55 + value;
    end
endmodule

module flashNavigator
#(
  parameter STARTUP_WAIT = 32'd10000000
)
(
    input clk,                              // 27Mhz main clock signal
    output reg flashClk = 0,                // SPI clock for the flash IC
    input flashMiso,                        // SPI data in from the flash to the tang nano
    output reg flashMosi = 0,               // SPI data out from the tang nano to flash
    output reg flashCs = 1,                 // SPI chip select, active low
    input [5:0] charAddress,                // current char to display to the screen
    output reg [7:0] charOutput = 0,        // character in ASCII format that we want to be displayed at charAddress
    input btn1,                             // two buttons on the tang nano board 
    input btn2                              // two buttons on the tang nano board   
);

reg [23:0] readAddress;     // register to store the 24-bit address we want to read from flash
reg [7:0] command;          // stores the command we want to send the flash IC
reg [7:0] currentByteOut;   // store the current data byte from flash
reg [7:0] currentByteNum;   // counter to count which byte we are on from the 32 bytes we want to read
reg [255:0] dataIn;         
reg [255:0] dataInBuffer;

initial readAddress = 0;
initial command = 8'h03;        // 03 is the READ command
initial currentByteOut = 0;
initial currentByteNum = 0;
initial dataIn = 0;
initial dataInBuffer = 0;

//  The reason we have a separate register for the entire 32 bytes and a separate register for the current byte 
// is just because it sends each byte MSB first, but the bytes come least significant byte first so they have 
// opposite directions if we wanted to shift the data in. We would have to jump 8 bits forward and then backtrack 
// when updating the memory which would make the code more complex.
//  So by separating them we can shift the current byte in by shifting the MSB left and then just add it to the 
// dataIn register which stores the entire frame.

//  The reason we have two buffers for the current frame is so that one will be controlled by the reading code and one 
// will be used by the other components consuming the data. This way we don't have to synchronize between them we simply 
// read bits into dataIn and only when we have a complete frame we update dataInBuffer all at once so components consuming 
// the data always have an up to date frame they can read from.

//  Our flash navigator module will have the following states to perform the read sequence.

//  We will wait for the IC to initialize, then load the command we want to send, we can then send the command in the state 
// STATE_SEND. After sending the command we need to send the address, this can be done by loading the address and reusing the 
// same STATE_SEND state to send the loaded register.

//  After sending both the command to read and address we want, we need to read 32 bytes out, this can be done in the STATE_READ_DATA 
// state. Once all 32 bytes are read we will go to the done state and transfer our dataIn register into dataInBuffer.
localparam STATE_INIT_POWER = 8'd0;
localparam STATE_LOAD_CMD_TO_SEND = 8'd1;
localparam STATE_SEND = 8'd2;
localparam STATE_LOAD_ADDRESS_TO_SEND = 8'd3;
localparam STATE_READ_DATA = 8'd4;
localparam STATE_DONE = 8'd5;

reg [23:0] dataToSend;
reg [8:0] bitsToSend;
reg [32:0] counter;
reg [2:0] state;
reg [2:0] returnState;
reg dataReady;

assign dataToSend = 0;
assign bitsToSend = 0;
assign counter = 0;
assign state = 0;
assign returnState = 0;
assign dataReady = 0;

//
// FSM
//
always @(posedge clk) begin
  case (state)
    //  The first state increments the counter until we reach the desired startup delay 
    // in which case it will clear some registers and move onto loading the command to 
    // send in the next state.
    STATE_INIT_POWER: begin
      if (counter > STARTUP_WAIT) begin
          state <= STATE_LOAD_CMD_TO_SEND;
          counter <= 32'b0;
          currentByteNum <= 0;
          currentByteOut <= 0;
      end else begin
          counter <= counter + 1;
      end
    end
    //  In this state we set the chip select low to activate the flash chip as we are about
    // to start sending data to it as per the datasheet. Other then that we load the command
    // into the send buffer, set the number of bits to send to 8 since our command is 8 bits,
    // and move onto the send state. The last line sets the return state after sending data
    // to be load address state so once it finishes sending the command it will go there.
    STATE_LOAD_CMD_TO_SEND: begin
      flashCs <= 0;
      //  One thing to notice is we put the command at the top 8 bits instead of the bottom 8 bits
      // from the 24-bit dataToSend register. This is because with this flash chip we are sending
      // MSB first so by putting it at the top 8 bits we can easily shift them off the end.
      dataToSend[23-:8] <= command;
      bitsToSend <= 8;
      state <= STATE_SEND;
      returnState <= STATE_LOAD_ADDRESS_TO_SEND;
    end
    //  We will be splitting our main clock into two SPI clocks. Theoretically we can set the data on 
    // the falling edge of the clock and have it read on the rising edge doubling our transfer rate. But 
    // to keep everything together we perform the rising and falling edge of the SPI clock in the rising 
    // edge of our main clock. 
    //  So when the counter is 0 we set the clock low performing the "falling edge" of the spi clock and 
    // when the counter is 1 we set the SPI clock high letting the flash chip read the data we set.
    //  On the falling edge we set the output pin to be the most significant bit of dataToSend and then we
    // shift dataToSend one bit to the left since we already handled the last bit. We also decrement bitsToSend
    // and set the counter to 1 so we can move onto the rising edge in the next clock cycle.
    //  On the rising edge, besides for setting the spi clock high and resetting counter we are also checking 
    // if this was the last bit in which case we move onto the next state which was stored in returnState
    STATE_SEND: begin
        if (counter == 32'd0) begin
            flashClk <= 0;
            flashMosi <= dataToSend[23];
            dataToSend <= {dataToSend[22:0],1'b0};
            bitsToSend <= bitsToSend - 1;
            counter <= 1;
        end
        else begin
            counter <= 32'd0;
            flashClk <= 1;
            if (bitsToSend == 0)
                state <= returnState;
        end
    end
    //  The load address state is very similar to loading a command except that the register is 24 bits long,
    // we also set the return state to read data, as we saw from the datasheet after sending the address the
    // flash will start outputting the data which we need to read.
    STATE_LOAD_ADDRESS_TO_SEND: begin
      dataToSend <= readAddress;
      bitsToSend <= 24;
      state <= STATE_SEND;
      returnState <= STATE_READ_DATA;
      currentByteNum <= 0;
    end
    //  The read data state is almost like the flip side of the send data, here we also split our clock into one
    // cycle for the rising edge and one cycle for the falling edge of the SPI clock. The main difference being
    // that when sending data we didn't really care about individual bytes, in both the case of sending 1 byte for
    // the command or 3 bytes for the address we simply had to shift the bytes MSB first from start to end in order.
    //  In the case of reading data, like mentioned above, each byte is read most significant bit first, but the bytes 
    // themselves are arranged least significant byte first (or at least lowest address first). So because of these 
    // two different directions we will be reading each byte separately and only after reading a full byte we will place 
    // it into the final input buffer.
    //  Because of this we need to be able to count each time we have read 8 bits so we will be using counter for this 
    // as well, besides for just counting whether or not we are on the rising or falling edge.
    //  So in the top if section where we handle the falling edge, we check if the last 4 bits equal zero, which is 
    // another way of saying we have no remainder when dividing by 16 (8 bits * 2 clock cycles per bit) then we know 
    // we have read a full byte and we store currentByteOut into the dataIn register. The index where we store it is the 
    // currentByteNum multiplied by 8 which is like shifting by 3.
    //  Besides for that we increment the number of bytes read and check if we are already on 31 bytes read and we just 
    // incremented the counter then we have finished reading all 32 bytes so we move onto the done state.
    //  In the else block where we handle the rising edge of the SPI clock we read the current bit from flashMosi 
    // and shift it into the currentByteOut register. Since the data is sent MSB first we shift left, so that after 
    // 8 shifts the first bit we put in will be the most significant bit.
    STATE_READ_DATA: begin
        if (counter[0] == 1'd0) begin
            flashClk <= 0;
            counter <= counter + 1;
            if (counter[3:0] == 0 && counter > 0) begin
                dataIn[(currentByteNum << 3)+:8] <= currentByteOut;
                currentByteNum <= currentByteNum + 1;
                if (currentByteNum == 31)
                    state <= STATE_DONE;
            end
        end
        else begin
            flashClk <= 1;
            currentByteOut <= {currentByteOut[6:0], flashMiso};
            counter <= counter + 1;
        end
    end
    //  Our final state turns off the flash chip by setting the chip select pin high stopping the read operation
    // and we copy the data read from dataIn to dataInBuffer making the new data available to other components to 
    // use. We set the dataReady flag to 1 to tell other components that the register dataInBuffer contains the 
    // contents from flash for the address requested.
    //  We also reset counter to be the startup delay and go back to the first state to repeat the cycle but this
    // time without a delay.
    //  With that we should now be able to read the first 32 bytes of memory.
    STATE_DONE: begin
        dataReady <= 1;
        flashCs <= 1;
        dataInBuffer <= dataIn;
        counter <= STARTUP_WAIT;
        state <= STATE_INIT_POWER;
    end

  endcase
end

//
// Displaying data
//
reg [7:0] chosenByte = 0;       // Store the current byte we want to display from the 32 different bytes we have read from memory
wire [7:0] byteDisplayNumber;   // Index of the byte we want so again this can be from 0-31
wire lowerBit;                  // Each byte is represented by 2 hex characters so we need to know if we are on the first or second character
wire [7:0] hexCharOutput;       // Store the ASCII value we get back from the hex conversion
wire [3:0] currentHexVal;       // Store the 4 bits we are currently converting

assign byteDisplayNumber = charAddress[5:1];
assign lowerBit = charAddress[0];
assign currentHexVal = lowerBit ? chosenByte[3:0] : chosenByte[7:4];

toHex hexConvert(
    clk,
    currentHexVal,
    hexCharOutput
);


endmodule       