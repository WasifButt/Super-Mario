
module drawStuff (clk, 
						drM, drML, erM, jump, jumpL, jumping, falling, drStage1, 
						drM2, drML2, erM2, jump2, jumpL2, jumping2, falling2, drStage2,
						drM3, drML3, erM3, jump3, jumpL3, jumping3, falling3, drStage3,
						done, jumpCounter, address, fall, 
						Mariox, Marioy, Jumpx, Jumpy, lvl1bkgx, lvl1bkgy,
						px, py, draw);
						
	output reg [4:0] jumpCounter; 
	initial jumpCounter = 0;
	reg [4:0] jumpCounterReg; 
	initial jumpCounterReg = 0; 
	
	input clk, drM, drML, erM, jump, jumpL, jumping, falling, drStage1, draw;
	input drM2, drML2, erM2, jump2, jumpL2, jumping2, falling2, drStage2; 
	input drM3, drML3, erM3, jump3, jumpL3, jumping3, falling3, drStage3;
	output reg [14:0] address; 
	reg [7:0] ycountMario, xcountMario; 
	reg [7:0] ybkg1, xbkg1;
	reg [7:0] ycountJump, xcountJump; 
	output reg done, fall; 
	output reg [7:0] Mariox, Marioy, Jumpx, Jumpy, lvl1bkgx, lvl1bkgy;
	
	input [7:0] px, py; 
	initial address = 0; 
	initial done = 0; 
	
	always @(posedge clk) begin
		
		//reset
		if (done) begin 
			done <= 0;
		end
		
		// 12 x 16 size
		else if ((drM || drML || jump || jumpL) || (drM2 || drML2 || jump2 || jumpL2) || (drM3 || drML3 || jump3 || jumpL3)) begin
				if (ycountMario < 10'd16 && xcountMario == 10'd11) begin
					ycountMario <= ycountMario + 1; 
					xcountMario <= 0; 
				end
				else if (xcountMario < 10'd12) begin
					xcountMario <= xcountMario + 1;
				end
				
				if ((xcountMario != 12) && (ycountMario != 16) && !done) begin
					Mariox <= xcountMario + px;
					Marioy <= ycountMario + py;
					address <= address + 1;
					//done <= 0; 
				end
				
				if(ycountMario == 10'd15 && xcountMario == 10'd11) begin
					done <= 1; 
					address <= 0;
					ycountMario <= 0; 
					xcountMario <= 0;
				end
				if (drM || drML || drM2 || drML2 || drM3 || drML3)
					fall <= 0; 
			end	
			
		//120 x 160 size
		else if ((drStage1 || erM || jumping || falling) || draw || (drStage2 || erM2 || jumping2 || falling2) || (drStage3 || erM3 || jumping3 || falling3)) begin
			if (ybkg1 < 10'd120 && xbkg1 == 10'd159) begin
				ybkg1 <= ybkg1 +1; 
				xbkg1 <= 0; 
			end
			else if (xbkg1 < 10'd160) begin
				xbkg1 <= xbkg1 + 1;
			end
			
			if((ybkg1 != 10'd121) && (xbkg1 != 10'd160) && !done) begin
				address <= address + 1;
				lvl1bkgx <= xbkg1; 
				lvl1bkgy <= ybkg1; 
			end 

			if(ybkg1 == 10'd120 && xbkg1 == 10'd0) begin
				done <= 1;
				address <= 0;
				ybkg1 <= 0; 
				xbkg1 <= 0;
			end
			
			if ((jumping || jumping2 || jumping3) && ybkg1 == 10'd119 && xbkg1 == 10'd159) begin
				jumpCounter <= jumpCounterReg; 
				jumpCounterReg <= jumpCounterReg + 1;
			end
			if (erM || erM2 || erM3) begin
				jumpCounter <= jumpCounterReg; 
				jumpCounterReg <= 0; 
			end
			if (falling || falling2 || falling3) begin
				fall <= 1; 
			end
			else if (erM || erM2 || erM3) begin
				fall <= 0; 
			end
		end
	end

	
endmodule 