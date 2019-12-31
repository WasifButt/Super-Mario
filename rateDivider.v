
module rateDivider (enable, clock);
	input clock;
	output reg enable;
	reg [26:0] counter; 
	
	always @(posedge clock)
		begin 
			if(counter == 0) begin
				counter <= 27'd1000000;
				enable <= 1;
			end 
			else begin
				counter <= counter - 1; 
				enable <= 0;
		end
		end
endmodule 

module MarioJumpRateDivider (enable, clock);
	input clock;
	output reg enable;
	reg [26:0] counter; 
	
	always @(posedge clock)
		begin 
			if(counter == 0) begin
				counter <= 27'd10000;
				enable <= 1;
			end 
			else begin
				counter <= counter - 1; 
				enable <= 0;
		end
		end
endmodule 