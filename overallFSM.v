
module overallFSM(clk, reset, spacebar, pipe, next, flag, done, start, draw, lvl1, lvl2, lvl3, writeEn, dead, timer_enable);

	input clk, reset, spacebar, pipe, next, done, flag, dead; 
	output reg start, draw, lvl1, lvl2, lvl3, writeEn, timer_enable; 
	reg [10:0] current_state, next_state; 
	
	localparam	startscreen		= 10'd0,
					level1 			= 10'd1,
					level2			= 10'd2,
					level3			= 10'd3,
					gameover			= 10'd4,
					drawstart		= 10'd5;
					
	always @(*)
	begin: state_table 
		case(current_state)
			drawstart: next_state =  done ? startscreen : drawstart; 
			startscreen: next_state = spacebar ? level1 : startscreen; 
			level1: next_state = pipe ? level2 : level1; 
			level2: next_state = next ? level3 : level2; 
			level3: next_state = flag ? drawstart : level3; 
			default: next_state = drawstart;
		endcase
	end
	
	always@(*) 
	begin: logic
	
		draw = 0;
		lvl1 = 0;
		lvl2 = 0; 
		lvl3 = 0; 
		start = 0; 
		writeEn = 0;
		timer_enable = 0;
		
		case(current_state)
			
			drawstart: begin
				draw = 1;
				start = 1; 
				writeEn = 1; 
			end
			startscreen: begin
				start = 1;
				timer_enable = 0;
			end
			level1: begin
				lvl1 = 1;
				timer_enable = 1;
			end
			level2: begin
				lvl2 = 1;
				timer_enable = 1;
			end
			level3: begin
				lvl3 = 1; 
				timer_enable = 1;
			end
		endcase
	end
	
	always@(posedge clk)
    begin: state_FFs
		if (dead)
			current_state <= drawstart;
		else
        current_state <= next_state; 
    end 
	
endmodule 