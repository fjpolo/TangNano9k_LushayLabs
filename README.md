# Tang Nano 9K Series

This is a free beginners series to FPGA development. Throughout the course we will be using the Tang Nano 9K development board created by Sipeed.

This board was chosen as it packs a very powerful FPGA core in a very compact and affordable package, so for beginners you won't have to worry about size problems or optimizing your design, allowing you to focus on learning and building cool projects.

This series uses a completely open source toolchain which makes development open / fast and lightweight.

Learn by example with our on-going series of articles showcasing how to use FPGAs in your next project.

# Series Index

- [Installation & Getting Started](https://learn.lushaylabs.com/getting-setup-with-the-tang-nano-9k/) - goes over the process of getting setup, installing the toolchain and goes over the basics to programming a basic example on the Tang Nano 9K.

- [Debugging & UART](https://learn.lushaylabs.com/tang-nano-9k-debugging/) - goes through common debugging methods when working on the tang nano or really any FPGA and we go through the process of creating a UART module to communicate with a computer.

- [OLED 101](https://learn.lushaylabs.com/tang-nano-9k-graphics/) - The first mini project creating an OLED text engine core. This part covers creating the physical driver to interface and display images on an OLED screen.

- [Creating a Text Engine](https://learn.lushaylabs.com/tang-nano-9k-creating-a-text-engine/) - A continuation of the OLED mini project, implementing a text core which allows us to render ASCII text to pixels on the screen using font files.

- [Data Conversion & Visualization](https://learn.lushaylabs.com/tang-nano-9k-data-visualization/) - Part 3 of the OLED mini project, shows ways to convert binary numbers into different formats and how to visualize them on the OLED display.

- [Reading from the External Flash](https://learn.lushaylabs.com/tang-nano-9k-reading-the-external-flash/) - Learn about the external flash storage IC onboard the Tang Nano 9K and how to program and read data from it in your applications. In this section we build a hex viewer for the flash memory as an example project which reads data by address.

- [Generating Random Numbers](https://learn.lushaylabs.com/tang-nano-9k-generating-random/) - Dive into LFSRs and how they can be used to generate pseudo random numbers. In this section as an example use-case we build a scrolling graph by plotting the random numbers on screen.

- [Sharing Resources](https://learn.lushaylabs.com/tang-nano-9k-sharing-resources/) - A look at the problem of sharing common resources as-well as different methods on how to safely share resources between components and the pros and cons for each method.

- [I2C, ADC and Micro Procedures](https://learn.lushaylabs.com/i2c-adc-micro-procedures/) - Designing modules in layers, using nested state machines to create the right building blocks for simplifying your overall design. In this article we build modules for the ADS1115 ADC and the I2C protocol to get analog values into our digital circuits.

- [Our First CPU](https://learn.lushaylabs.com/tang-nano-9k-first-processor/) - This section goes through the entire process of creating a general purpose CPU core on the tang nano. In this section we will build in instruction set architecture, a cpu core and an assembler to allow us to write, compile and run software on the tang nano.

- [Composite Video](https://learn.lushaylabs.com/tang-nano-9k-composite-video/) - This article dives through the classic composite video protocol and how to implement the NTSC 240p video standard to draw grayscale images on screen.

- [Hub75 Panels](https://learn.lushaylabs.com/led-panel-hub75/) - Learn the protocol used for creating massive screens and billboard displays, this article goes over building multiple drivers while exploring the features of these panels.

# Projects

Projects with the Tang Nano 9K that may require extra components / might not be supported yet by the Open source toolchain:

- [Project EDID](https://learn.lushaylabs.com/tang-nano-9k-project-edid/) - Exploration into the EDID protocol used by HDMI screens for identifying the display and the functionality the screen supports.

# Extra Credits

These articles with extra info going outside the scope of the main series:

- [Manually Installing the OS Toolchain](https://learn.lushaylabs.com/os-toolchain-manual-installation/) - An article with the steps required to manually install the open-source toolchain for each operating system.

- [Bitstream to FPGA](https://learn.lushaylabs.com/bitstream-to-fpga/) - An article exploring the internals of the protocols and path used to program the Tang Nano.