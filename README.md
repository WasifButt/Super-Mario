# Super-Mario
Final project for ECE241 (Digital Systems)

Super Mario is hardware based game written in Verilog for the Altera DE1-SoC FPGA board. 

The game utilizes a VGA adapter to draw elements on a 140x120 pixel screen. Input is read from a keyboard using a PS/2 driver, players are able to move Mario through three different levels, and one title screen. Mario's basic movements include, moving left/right, jumping, and falling. The game also has background music produced from an audio driver. 

project.v is the top level module where all other modules are instantiated
