//Creators: Hannah Brooks, Wasif Butt
//if you steal this ill be very upset

module project
	(
		CLOCK_50,						//	On Board 50 MHz
		SW,						
		KEY,								// On Board Keys
		LEDR,
		VGA_CLK,   						//	VGA Clock
		VGA_HS,							//	VGA H_SYNC
		VGA_VS,							//	VGA V_SYNC
		VGA_BLANK_N,					//	VGA BLANK
		VGA_SYNC_N,						//	VGA SYNC
		VGA_R,   						//	VGA Red[9:0]
		VGA_G,	 						//	VGA Green[9:0]
		VGA_B,   						//	VGA Blue[9:0]
		PS2_CLK,
		PS2_DAT,
		AUD_ADCDAT,

		// Bidirectionals
		AUD_BCLK,
		AUD_ADCLRCK,
		AUD_DACLRCK,

		FPGA_I2C_SDAT,

		// Outputs
		AUD_XCK,
		AUD_DACDAT,

		FPGA_I2C_SCLK,
		HEX0,
		HEX1,
		HEX2,
		HEX3
	);

	/*************************************************************/
	// keyboard wires
	wire	[7:0]	the_command;
	wire			send_command;

	inout			PS2_CLK;
	inout		 	PS2_DAT;

	wire			command_was_sent;
	wire			error_communication_timed_out;

	wire	[7:0]	received_data;
	wire		 	received_data_en;
	/*************************************************************/
	//VGA stuff
	input			CLOCK_50;			//	50 MHz
	input	[3:0]	KEY;					
	input [9:0] SW;
	output [9:0] LEDR; 
	
	output			VGA_CLK;   				//	VGA Clock
	output			VGA_HS;					//	VGA H_SYNC
	output			VGA_VS;					//	VGA V_SYNC
	output			VGA_BLANK_N;			//	VGA BLANK
	output			VGA_SYNC_N;				//	VGA SYNC
	output	[7:0]	VGA_R;   				//	VGA Red[7:0] Changed from 10 to 8-bit DAC
	output	[7:0]	VGA_G;	 				//	VGA Green[7:0]
	output	[7:0]	VGA_B;					//	VGA Blue[7:0]
	output 	[6:0] HEX0;
	output 	[6:0] HEX1;
	output 	[6:0] HEX2;
	output 	[6:0] HEX3;
		
	
	vga_adapter VGA(
			.resetn(resetn),
			.clock(CLOCK_50),
			.colour(colour),
			.x(x),
			.y(y),
			.plot(writeEn),
			/* Signals for the DAC to drive the monitor. */
			.VGA_R(VGA_R),
			.VGA_G(VGA_G),
			.VGA_B(VGA_B),
			.VGA_HS(VGA_HS),
			.VGA_VS(VGA_VS),
			.VGA_BLANK(VGA_BLANK_N),
			.VGA_SYNC(VGA_SYNC_N),
			.VGA_CLK(VGA_CLK));
		defparam VGA.RESOLUTION = "160x120";
		defparam VGA.MONOCHROME = "FALSE";
		defparam VGA.BITS_PER_COLOUR_CHANNEL = 4;
		defparam VGA.BACKGROUND_IMAGE = "black.mif";
		
	
	//****************************************************************************************************

	wire outofBounds, ground;
	
	//keys using keyboard
	reg keyR, keyL, keyUp, keyDown, keySpace; 
	wire right, left, up, down, spaecbar; 

	assign right = keyR;
	assign left = keyL;
	assign up = keyUp;
	assign down = keyDown;
	assign spacebar = keySpace; 
	
	PS2_Controller ps2(
		// Inputs
		CLOCK_50,

		the_command,
		send_command,

		// Bidirectionals
		PS2_CLK,					// PS2 Clock
		PS2_DAT,					// PS2 Data

		// Outputs
		command_was_sent,
		error_communication_timed_out,

		received_data,
		received_data_en			// If 1 - new data has been received
	);
	reg moving;
	
	always @(posedge received_data_en) begin
		if ((received_data == 8'b1111_0000) && moving == 1) begin
			keySpace <= 0; 
			keyL <= 0;
			keyR <= 0;
			keyUp <= 0;
			keyDown <= 0; 
			moving <= 0;
		end
		if (moving == 0)
			moving <= 1;
		else if ((received_data == 7'b0101001) && start)
			keySpace <= 1;
		else if ((received_data == 7'b1110010) && moving == 1 && (lvl1 || lvl2))
			keyDown <= 1;
		else if ((received_data == 7'b1101011) && moving == 1 && (lvl1 || lvl2 || lvl3))
			keyL <= 1;
		else if ((received_data == 7'b1110100) && moving == 1 && (lvl1 || lvl2 || lvl3))
			keyR <= 1;
		else if ((received_data == 7'b1110101) && moving == 1 && (lvl1 || lvl2 || lvl3))
			keyUp <= 1;	
	end

	
	//VGA input controlling wires 
	reg [11:0] colour;
	reg [7:0] x, y;
	reg writeEn;
	wire resetn;
	assign resetn = KEY[3];

	//draw controls
	wire resetAddress, resetAddress2, resetAddress3, fall;
	wire drM, drML, jump, jumpL, drStage1; //draw controls level 1
	wire drM2, drML2, jump2, jumpL2, drStage2; //draw controls level 2
	wire drM3, drML3, jump3, jumpL3, drStage3; //draw controls level 3
	wire erM, jumping, falling, pipe, dead; //erase controls level 1 
	wire erM2, jumping2, falling2, next; //erase controls level 2
	wire erM3, jumping3, falling3, flag; //erase controls level 
	wire [11:0] marioColourRight, marioColourLeft, jumpColourRight, jumpColourLeft, stage1Colour, stage2Colour, stage3Colour, startColour; //colours
	wire [7:0] Mariox, Marioy, Jumpx, Jumpy, lvl1bkgx, lvl1bkgy; //x y controls for drawing
	wire moveRight, moveLeft, moveUp; //draw in direction ********TO BE DELETED********
	wire [7:0] px, py; //position tracker for mario
	wire [4:0] jumpCounter; //jumping position tracker 
	wire startEnable, lvl1Enable, lvl2Enable, lvl3Enable; //write enables 
	
	//overall FSM controls 
	wire start, draw, lvl1, lvl2; 
	
	//counters 
	wire done; 
	reg [14:0] address; 
	wire [14:0] outAddress; 
	
	//rate divider enable 
	wire go, goJump; 
	wire timer_enable;
	
	//accessing memories to draw images
	mario drawMarioRight(address, CLOCK_50, marioColourRight);
	marioLeft drawMarioLeft(address, CLOCK_50, marioColourLeft);
	jump jumpMarioRight(address, CLOCK_50, jumpColourRight);
	jumpLeft jumpMarioLeft(address, CLOCK_50, jumpColourLeft);
	start_screen startscreen(address, CLOCK_50, startColour);
	stage1_bkg stage1(address, CLOCK_50, stage1Colour);
	stage2_bkg stage2(address, CLOCK_50, stage2Colour); 
	stage3_bkg stage3(address, CLOCK_50, stage3Colour);

	always @(*) begin
		if (start) begin
			writeEn <= startEnable;
			if(draw) begin 
				colour <= startColour;
				x <= lvl1bkgx;
				y <= lvl1bkgy;
				address <= outAddress;
			end
			else begin
				address <= 0; 
				x <= 0; 
				y <= 0;
			end	
		end
		else if (lvl1) begin 
			writeEn <= lvl1Enable;
			if (resetAddress) 
				address <= 0; 
			else 
				address <= outAddress;
				
			if (drStage1 || erM || jumping || falling)  begin 
				colour <= stage1Colour;
				x <= lvl1bkgx;
				y <= lvl1bkgy;
			end
			
			else if(drM || drML || jump || jumpL) begin
				if (jump) begin
					colour <= jumpColourRight;
					address <= outAddress; 
				end
				else if (jumpL) begin
					colour <= jumpColourLeft;
					address <= outAddress;
				end
				else if (drM) begin
					colour <= marioColourRight;
					address <= outAddress; 
				end
				else begin
					colour <= marioColourLeft;
					address <= outAddress;
				end
					
				x <= Mariox;
				y <= Marioy;
			end
		end
		else if (lvl2) begin
			writeEn <= lvl2Enable;
			if (resetAddress2) 
				address <= 0; 
			else 
				address <= outAddress;
			
			if (drStage2 || erM2 || jumping2 || falling2)  begin 
				colour <= stage2Colour;
				x <= lvl1bkgx;
				y <= lvl1bkgy;
			end
			
			else if(drM2 || drML2 || jump2 || jumpL2) begin
				if (marioColourRight == 12'b000010101110 && drM2) begin
					address <= outAddress; 
					colour <= 12'b000000000000; 
				end
				else if (marioColourLeft == 12'b000010101110 && drML2) begin
					address <= outAddress; 
					colour <= 12'b000000000000; 
				end
				else if (jumpColourRight == 12'b000010101110 && jump2) begin
					address <= outAddress; 
					colour <= 12'b000000000000; 
				end
				else if (jumpColourLeft == 12'b000010101110 && jumpL2) begin
					address <= outAddress; 
					colour <= 12'b000000000000; 
				end
				else if (jump2) begin
					colour <= jumpColourRight;
					address <= outAddress; 
				end
				else if (jumpL2) begin
					colour <= jumpColourLeft;
					address <= outAddress;
				end
				else if (drM2) begin
					colour <= marioColourRight;
					address <= outAddress; 
				end
				else begin
					colour <= marioColourLeft;
					address <= outAddress;
				end
					
				x <= Mariox;
				y <= Marioy;
			end
		end
		else if (lvl3) begin
			writeEn <= lvl3Enable;
			if (resetAddress3) 
				address <= 0; 
			else 
				address <= outAddress;
			
			if (drStage3 || erM3 || jumping3 || falling3)  begin 
				colour <= stage3Colour;
				x <= lvl1bkgx;
				y <= lvl1bkgy;
			end
			
			else if(drM3 || drML3 || jump3 || jumpL3) begin
				if (flag && ((Mariox == 8'd105 && Marioy == 8'd70) || (Mariox == 8'd106 && Marioy == 8'd70) || (Mariox == 8'd105 && Marioy == 8'd71) || (Mariox == 8'd106 && Marioy == 8'd71))) begin
					address <= outAddress; 
					colour <= 12'b101111100001; 
				end
				else if (jump3) begin
					colour <= jumpColourRight;
					address <= outAddress; 
				end
				else if (jumpL3) begin
					colour <= jumpColourLeft;
					address <= outAddress;
				end
				else if (drM3) begin
					colour <= marioColourRight;
					address <= outAddress; 
				end
				else begin
					colour <= marioColourLeft;
					address <= outAddress;
				end
					
				x <= Mariox;
				y <= Marioy;
			end
		end
	end
	
	//FSMs
	overallFSM overall(CLOCK_50, resetn, spacebar, pipe, next, flag, done, start, draw, lvl1, lvl2, lvl3, startEnable, dead, timer_enable);
	
	lvl1FSM level1(CLOCK_50, resetn, go, goJump, right, left, up, down, 
						resetAddress, drM, drML, erM, jump, jumpL, jumping, falling, drStage1, moveRight, 
						done, jumpCounter, fall, 
						lvl1Enable, rightColour, leftColour, ground, outofBounds, pipe, lvl1, start, dead); 
	
	lvl2FSM level2(CLOCK_50, resetn, go, goJump, right, left, up, down, 
						resetAddress2, drM2, drML2, erM2, jump2, jumpL2, jumping2, falling2, drStage2, moveRight, 
						done, jumpCounter, fall, 
						lvl2Enable, rightColour, leftColour, ground, outofBounds, next, lvl2, start); 
						
	lvl3FSM level3(CLOCK_50, resetn, go, goJump, right, left, up, down, 
						resetAddress3, drM3, drML3, erM3, jump3, jumpL3, jumping3, falling3, drStage3, moveRight, 
						done, jumpCounter, fall, 
						lvl3Enable, rightColour, leftColour, ground, outofBounds, flag, lvl3, start); 

	//datapath
	drawStuff drawObjects(CLOCK_50, drM, drML, erM, jump, jumpL, jumping, falling, drStage1, 
							drM2, drML2, erM2, jump2, jumpL2, jumping2, falling2, drStage2,
							drM3, drML3, erM3, jump3, jumpL3, jumping3, falling3, drStage3,
							done, jumpCounter, outAddress, fall, 
							Mariox, Marioy, Jumpx, Jumpy, lvl1bkgx, lvl1bkgy, px, py, draw);
	
	//movement registers 
	marioReg marioMovement(CLOCK_50, go, ground, px, py, 
							erM, jump, jumpL, jumpCounter, jumping, falling, drStage1, drStage2, drStage3, 
							right, left, up, down, outofBounds, pipe, next, flag, start, lvl1, lvl2, lvl3, dead); 
	
	
	//refresh rate divider 
	rateDivider moverate(go, CLOCK_50); 
	MarioJumpRateDivider jumprate(goJump, CLOCK_50);
	
	//clock
	timer timer(HEX0, HEX1, HEX2, HEX3, CLOCK_50, timer_enable);

	input				AUD_ADCDAT;

	inout				AUD_BCLK;
	inout				AUD_ADCLRCK;
	inout				AUD_DACLRCK;

	inout				FPGA_I2C_SDAT;

	output				AUD_XCK;
	output				AUD_DACDAT;
	output				FPGA_I2C_SCLK;
	
	wire				audio_in_available;
	wire		[31:0]	left_channel_audio_in;
	wire		[31:0]	right_channel_audio_in;
	wire				read_audio_in;

	wire				audio_out_allowed;
	wire		[31:0]	left_channel_audio_out;
	wire		[31:0]	right_channel_audio_out;
	wire				write_audio_out;
	wire     [7:0] data_received;

	reg [18:0] delay_cnt;
	wire [18:0] delay;

	reg snd;

	reg [22:0] beatCountMario;
	reg [9:0] addressMario; 
														
	sound r1(.address(addressMario), .clock(CLOCK_50), .q(delay));

	always @(posedge CLOCK_50)
		if(delay_cnt == delay) begin
			delay_cnt <= 0;
			snd <= !snd;
		end else delay_cnt <= delay_cnt + 1;

	always @(posedge CLOCK_50) begin
		if(beatCountMario == 23'b10011000100101101000000)begin
			beatCountMario <= 23'b0;
			if(addressMario < 10'd999)
				addressMario <= addressMario + 1;
			else begin
				addressMario <= 0;
				beatCountMario <= 0;
			end
		end
		else 
			beatCountMario <= beatCountMario + 1;
	end

	wire [31:0] sound = snd ? 32'd100000000 : -32'd100000000;

	assign read_audio_in			= audio_in_available & audio_out_allowed;
	assign left_channel_audio_out	= left_channel_audio_in+sound;
	assign right_channel_audio_out	= left_channel_audio_in+sound;
	assign write_audio_out			= audio_in_available & audio_out_allowed;

	Audio_Controller Audio_Controller (
		// Inputs
		.CLOCK_50						(CLOCK_50),
		.reset						(~KEY[0]),

		.clear_audio_in_memory		(),
		.read_audio_in				(read_audio_in),
		
		.clear_audio_out_memory		(),
		.left_channel_audio_out		(left_channel_audio_out),
		.right_channel_audio_out	(right_channel_audio_out),
		.write_audio_out			(write_audio_out),

		.AUD_ADCDAT					(AUD_ADCDAT),

		// Bidirectionals
		.AUD_BCLK					(AUD_BCLK),
		.AUD_ADCLRCK				(AUD_ADCLRCK),
		.AUD_DACLRCK				(AUD_DACLRCK),


		// Outputs
		.audio_in_available			(audio_in_available),
		.left_channel_audio_in		(left_channel_audio_in),
		.right_channel_audio_in		(right_channel_audio_in),

		.audio_out_allowed			(audio_out_allowed),

		.AUD_XCK					(AUD_XCK),
		.AUD_DACDAT					(AUD_DACDAT)

	);

	avconf #(.USE_MIC_INPUT(1)) avc (
		.FPGA_I2C_SCLK					(FPGA_I2C_SCLK),
		.FPGA_I2C_SDAT					(FPGA_I2C_SDAT),
		.CLOCK_50					(CLOCK_50),
		.reset						(~KEY[0])
	);

		
endmodule



