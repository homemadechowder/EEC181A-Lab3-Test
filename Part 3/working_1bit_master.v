// Samuel Sugimoto, Chen Xie
// EEC181A, W'16
// Group Name: Units
// Lab 3, sdram_master.v

module sdram_master(
	input clk,
	output reg read_n = 1,
	output reg write_n = 1,
	output reg chipselect,
	input waitrequest,
	output reg [31:0] address = 0,
	output reg [1:0] byteenable,
	input readdatavalid,
	input [15:0] readdata,
	output reg [15:0] writedata,
	input reset_n
	);
	
	reg [3:0] counter = 4'b0;
	reg [3:0] state = 4'b0;
	reg [15:0] readin = 16'b0;
	reg [15:0] readin_mod = 16'b0;
	reg [0:0] toggle = 1'b0;

	//Begin code here
	always @ (posedge clk)
	begin
		case(state [3:0])
			4'b0000:
			begin
				read_n <= 0;
				address [15:0] <= 0;
				chipselect <= 1;
				byteenable [1:0] <= 2'b11;
				if((waitrequest == 0) && (readin [15:0] != readdata [15:0]))
				begin
					readin [15:0] <= readdata[15:0];
					readin_mod[15:0] <= (readdata[15:0] + 1);
					read_n <= 1;
					chipselect <= 0;
					byteenable <= 0;
					state <= 4'b0001;
				end
			end
			4'b0001:
			begin
				write_n <= 0;
				//address [15:0] <= 0;
				chipselect <= 1;
				byteenable [1:0] <= 2'b11;
				//writedata [15:0] <= readin_mod [15:0];
				if(waitrequest == 0)
				begin
					case(toggle [0:0])
						1'b0:
						begin
							address [15:0] <= 0;
							writedata <= readin[15:0];
							toggle [0:0] <= 1'b1;
						end
						1'b1:
						begin
							address [15:0] <= 1;
							writedata <= readin_mod [15:0];
							toggle [0:0] <= 1'b0;
							state <= 4'b0010;
						end
					endcase
				end
			end
			4'b0010:
			begin
				
			end
			4'b0011:
			begin
				
			end
		endcase
	end

endmodule