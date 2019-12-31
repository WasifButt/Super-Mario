
module marioReg 	(clk, go, ground, updateX, updateY, 
						erM, jump, jumpL, jumpCounter, jumping, falling, drStage1, drStage2, drStage3, 
						right, left, up, down, outofBounds, pipe, next, flag, start, lvl1, lvl2, lvl3, dead); 
						
	output reg [7:0] updateX, updateY; 
	input erM, jump, jumpL, jumpCounter, jumping, falling, drStage1, drStage2, drStage3, start, lvl1, lvl2, lvl3; 
	input right, left, up, down; 
	reg [7:0] initialx; 
	reg [7:0] initialy;
	
	output reg outofBounds, pipe, next, flag, dead; 
	initial outofBounds = 0; 
	input clk, go;
	
	reg goDown;
	initial goDown = 1; 
	output reg ground; 
	reg [4:0] counter; 
	
	reg facingLeft, facingRight; 
	
	initial initialx = 10'd4;
	initial initialy = 10'd89;
	
	reg update; 
	initial update = 0; 
	reg stop;
	initial stop = 1;
	reg stop2;
	initial stop2 = 1; 	
	reg stop3;
	initial stop3 = 1;
	
	always@(posedge clk) begin
	//movement
		//initial value
		if (start) begin
			stop <= 1; 
			stop2 <= 1; 
			stop3 <= 1;
			next <= 0;
			flag <= 0;
			pipe <= 0; 
			dead <= 0; 
		end
		else if (drStage1 && stop && lvl1) begin
			updateX <= 10'd4; 
			updateY <= 10'd89; 
			initialx <= 10'd4;
			initialy <= 10'd89;
			stop <= 0; 
		end
		else if (drStage2 && stop2 && lvl2) begin
			updateX <= 10'd20; 
			updateY <= 10'd20;
			initialx	<= 10'd20;
			initialy <= 10'd20;
			stop2 <= 0; 
		end
		else if (drStage3 && stop3 && lvl3) begin
			updateX <= 10'd2; 
			updateY <= 10'd89; 
			initialx	<= 10'd2;
			initialy <= 10'd89;
			stop3 <= 0; 
		end
		//jumping
		else if (jumping && right && !outofBounds) begin 
			updateY <= initialy - 8'b00000001;
			updateX <= initialx + 8'b00000001;
			update <= 1;
		end
		else if (jumping && left && !outofBounds) begin
			updateY <= initialy - 8'b00000001;
			updateX <= initialx - 8'b00000001;
			update <= 1;
		end
		else if (jumping) begin 
			updateY <= initialy - 8'b00000001;
			update <= 1; 
		end
		//falling
		else if (falling && right && !outofBounds) begin 
			updateY <= initialy + 8'b00000001;
			updateX <= initialx + 8'b00000001;
			update <= 1;
		end
		else if (falling && left && !outofBounds) begin
			updateY <= initialy + 8'b00000001;
			updateX <= initialx - 8'b00000001;
			update <= 1;
		end
		else if (falling) begin
			updateY <= initialy + 8'b00000001;
			update <= 1; 
		end
		//right
		else if (erM && right && !outofBounds) begin
			updateX <= initialx + 8'b00000001;
			update <= 1; 
		end
		//left
		else if (erM && left && !outofBounds) begin
			updateX <= initialx - 8'b00000001;
			update <= 1; 
		end
		//update position
		else if (update) begin
			initialx <= updateX;
			initialy <= updateY; 
			update <= 0; 
		end
		
		//out of bounds conditions
		if (lvl1) begin 
			if (updateX - 1'b1 == 8'd0) begin  
				outofBounds <= 1; 
				facingLeft <= 1; 
				facingRight <= 0;
			end
			else if (updateX + 5'd12 == 8'd160) begin
				outofBounds <= 1; 
				facingRight <= 1; 
				facingLeft <= 0;
			end
			else if (updateX + 5'd12 == 8'd39 && (updateY + 5'd16 > 8'd88)) begin
				outofBounds <= 1; 
				facingRight <= 1;
				facingLeft <= 0;
			end
			else if (updateX + 5'd12 == 8'd55 && (updateY > 8'd72)) begin
				outofBounds <= 1; 
				facingRight <= 1;
				facingLeft <= 0;
			end
			else if (updateX + 5'd12 == 8'd71 && (updateY > 8'd56)) begin
				outofBounds <= 1; 
				facingRight <= 1;
				facingLeft <= 0;
			end
			else if (updateX + 5'd12 == 8'd133 && (updateY > 8'd84)) begin
				outofBounds <= 1; 
				facingRight <= 1;
				facingLeft <= 0;
			end
			else if (updateX - 5'd1 == 8'd86) begin
				outofBounds <= 1; 
				facingRight <= 0;
				facingLeft <= 1;
			end
			else 
				outofBounds <= 0; 
		end 
		
		else if (lvl2) begin
			if (updateX - 1'b1 == 8'd14) begin  
				outofBounds <= 1; 
				facingLeft <= 1; 
				facingRight <= 0;
			end
			else if (updateY - 1'b1 < 8'd19) begin  
				outofBounds <= 1; 
				facingLeft <= 0; 
				facingRight <= 1;
			end
		end
		else if (lvl3) begin
			if (updateX - 1'b1 == 8'd0) begin  
				outofBounds <= 1; 
				facingLeft <= 1; 
				facingRight <= 0;
			end
			else if (updateX + 5'd12 == 8'd98 && (updateY + 5'd16 > 8'd88)) begin
				outofBounds <= 1; 
				facingRight <= 1;
				facingLeft <= 0;
			end
		end
		
		//out of bounds reset
		if (facingRight == 1 && left) begin
			outofBounds <= 0; 
			facingRight <= 0;
		end
		else if (facingLeft == 1 && right) begin
			outofBounds <= 0; 
			facingLeft <= 0;
		end
		
		//ground conditions
		if (updateY == 8'd194 && lvl1)
			ground <= 0; 
		else if ( ((updateY + 5'd16 > 8'd104 && !(updateX > 8'd86 && updateX + 5'd12 < 8'd106) ) || (updateY + 5'd16 == 8'd89 && (updateX + 5'd11 > 8'd38 && updateX < 8'd55)) 
					|| (updateY + 5'd16 == 8'd73 && (updateX + 5'd11 > 8'd54 && updateX < 8'd71)) || (updateY + 5'd16 == 8'd57 && (updateX + 5'd11 > 8'd70 && updateX < 8'd87))
					|| (updateY + 5'd16 == 8'd85 && (updateX + 5'd11 > 8'd132))) && lvl1)
			ground <= 1; 
		else if (updateY + 5'd16 > 8'd104 && (lvl2 || lvl3))
			ground <= 1; 
		else if (updateY + 5'd16 == 8'd89 && (updateX + 5'd12 > 8'd97 && updateX < 8'd114) && lvl3)
			ground <= 1;
		else
			ground <= 0; 
			
		//pipe conditions
		if (lvl1) begin 
			if (updateY + 5'd16 == 8'd85 && (updateX > 8'd132 && updateX + 5'd12 < 8'd154) && down)
				pipe <= 1;
			else 
				pipe <= 0;
		end 
		
		//next level conditions 
		if (lvl2) begin
			if (updateX == 8'd159)
				next <= 1; 
			else 
				next <= 0; 
		end
		
		//flag conditions 
		if (lvl3) begin
			if (updateX == 8'd100)
				flag <= 1; 
			else 
				flag <= 0; 
		end
		
		//dead
		if (lvl1) begin
			if (updateY + 5'd15 == 8'd119) 
				dead <= 1;
			else 
				dead <= 0; 
		end
	end
	
endmodule 	