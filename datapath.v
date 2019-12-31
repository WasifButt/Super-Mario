
/*module datapath (clk, enable, x, y, inC, colour); 
	input clk; 
	input enable; 
	input [23:0] inC;

	output reg [7:0] x;
	output reg [6:0] y;  
	output reg [23:0] colour; 
	
	wire px, py;
	initial px = 40;
	initial py = 40; 
	
	always@(posedge clk) begin
		if (enable) begin
			if (xcounter < 69'd12)
				xcounter <= xcounter + 1;
			else if (xcounter == 69'd12)
				xcounter <= 0; 
			
			if (ycounter < 69'd16)
				ycounter <= ycounter + 1;
			else if (ycounter == 69'd16)
				ycounter <= 0; 
			
			colour <= inC;
			x <= xcounter + px;
			y <= ycounter + py;
		end
	end


endmodule */