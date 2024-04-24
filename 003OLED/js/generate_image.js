/*

https://learn.microsoft.com/en-us/windows/dev-environment/javascript/nodejs-on-wsl


Step 1: Save your javascript with .js extension.

Step 2: Open the command prompt

Step 3:  Locate your path where the .js file is saved.

Step 4: To compile the .js file we have to write

Node <Filename>.js

Step 5: Press the Enter key.

*/

const fs = require("fs");
const PNG = require("pngjs").PNG;

fs.createReadStream("/mnt/c/Workspace/NES/NESTang/LushayLabs/003OLED/image.png")
  .pipe(new PNG())
  .on("parsed", function () {
    const bytes = [];

    for (var y = 0; y < this.height; y+=8) {
      for (var x = 0; x < this.width; x+=1) {
        let byte = 0;

        for (var j = 7; j >= 0; j -= 1) {
            let idx = (this.width * (y+j) + x) * 4;
            if (this.data[idx+3] > 128) {
                byte = (byte << 1) + 1;
            } else {
                byte = (byte << 1) + 0;
            }
        }

        bytes.push(byte);
      }
    }
    const hexData = bytes.map((b) => b.toString('16').padStart(2, '0'));
    fs.writeFileSync('image.hex', hexData.join(' '));
});