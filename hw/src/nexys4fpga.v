module Nexys4fpga (
   input                clk,              // 100MHz clock from on-board oscillator
   input                btnL, btnR,       // pushbutton inputs - left (db_btns[4])and right (db_btns[2])
   input                btnU, btnD,       // pushbutton inputs - up (db_btns[3]) and down (db_btns[1])
   input                btnC,             // pushbutton inputs - center button -> db_btns[5]
   input                btnCpuReset,      // red pushbutton input -> db_btns[0]
   input        [15:0]  sw,               // switch inputs

   //output       [15:0]  led,              // LED outputs
   output        [3:0]  vgaRed,
   output        [3:0]  vgaBlue,
   output        [3:0]  vgaGreen,
   output               Hsync,
   output               Vsync
);

   parameter SIMULATE = 0;

   wire           sysclk;           // 75 MHz clk driven by IP
   wire           sysreset;         // system reset signal - asserted high to force reset

   // Debounced inputs
   wire  [15:0]   db_sw;
   wire  [5:0]    db_btns;

   // Stuff for nes
   wire  [2:0]    vga_r, vga_g;
   wire  [1:0]    vga_b;

   // I/O Assignments
   assign sysreset = ~db_btns[0]; // btnCpuReset is asserted low
   assign sysclk   = clk;

   assign vgaRed   = {vga_r, 1'b0};
   assign vgaGreen = {vga_g, 1'b0};
   assign vgaBlue  = {vga_b, 2'b0};

   // FPGA button and switch debouncing
   debounce
   #(
      .RESET_POLARITY_LOW(1),
      .SIMULATE(SIMULATE)
   )  DB
   (
      .clk(sysclk),
      .pbtn_in({btnC,btnL,btnU,btnR,btnD,btnCpuReset}),
      .switch_in(sw),
      .pbtn_db(db_btns),
      .swtch_db(db_sw)
   );

   nes_top nes
   (
      .CLK_100MHZ(sysclk),        // 100MHz system clock signal
      .BTN_SOUTH(sysreset),         // reset push button
      .BTN_EAST(sysreset),          // console reset
      .RXD(1'b0),               // rs-232 rx signal
      .SW(db_sw[3:0]),                // switches [3:0]
      .NES_JOYPAD_DATA1(1'b0),  // joypad 1 input signal
      .NES_JOYPAD_DATA2(1'b0),  // joypad 2 input signal

      .TXD(),               // rs-232 tx signal
      .VGA_HSYNC(Hsync),         // vga hsync signal
      .VGA_VSYNC(Vsync),         // vga vsync signal
      .VGA_RED(vga_r),           // vga red signal   [2:0]
      .VGA_GREEN(vga_g),         // vga green signal [2:0]
      .VGA_BLUE(vga_b),          // vga blue signal  [1:0]
      .NES_JOYPAD_CLK(),    // joypad output clk signal
      .NES_JOYPAD_LATCH(),  // joypad output latch signal
      .AUDIO()              // pwm output audio channel
   );

endmodule
