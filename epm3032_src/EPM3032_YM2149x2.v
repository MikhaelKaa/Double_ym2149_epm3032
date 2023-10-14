`timescale 1ns/10ps
module EPM3032_YM2149x2 (
input a0, a1, a2, a14, a15,
input cpu_clock, m1, wr, int, rd,
input iorq,
input reset,  
input d_0, d_3, d_4, d_5, d_6, d_7,  
//input d7_alt,
input dos,
output covox, 

output bc1, 
output bdir, 
output reg ym_clock, 
output ym_0, ym_1,
output beeper,
output tapeout,
output ioge_c
);

// Для тактирования звукового генератора 3.5.
//reg pre_clock = 1'b0;
always @* begin
	ym_clock = cpu_clock;
end
//assign ym_clock = pre_clock;

// covox
assign covox = ~(a2 | iorq | wr | ~dos);

// Дешифрация звукового генератора.
/*wire   ssg 	= ~(a15 & (~(a1 | iorq)));
assign bc1  = ~(ssg | (~(a14 & m1)));
assign bdir = ~(ssg | wr);*/

// AY control
wire [1:0]ay_a = {a15, a14};
reg pre_bc1, pre_bdir;

always @*
begin
	pre_bc1 = 1'b0;
	pre_bdir = 1'b0;

	if(a1==1'b0 & a0==1'b1 & a2==1'b1 )
	begin
		if( ay_a==2'b11 )
		begin
			pre_bc1=1'b1;
			pre_bdir=1'b1;
		end
		else if( ay_a==2'b10 )
		begin
			pre_bc1=1'b0;
			pre_bdir=1'b1;
		end
	end
end

assign bc1  = pre_bc1  & (~iorq) & ((~rd)|(~wr)) & m1 & dos;
assign bdir = pre_bdir & (~iorq) & (~wr)  & m1 & dos;


// IORQGE
assign ioge_c = (bc1 | bdir); 

// Turbo Sound
reg  YM_select = 1'b0;
wire TS_bit_sel = ~(d_3 & d_4 & d_5 & d_6 & d_7 & bdir & bc1); 
//wire TS_bit_sel = ~(d_3 & d_4 & d_5 & d_6 & d7_alt & bdir & bc1); 
always @(negedge TS_bit_sel or negedge reset) begin
	if(~reset) 	YM_select = 1'b0;
	else 			YM_select = d_0;
end
assign ym_0 = ~YM_select;
assign ym_1 = ~ym_0;



// Дешифрация бипера и tapeout. Аналогично пентагоновской схеме.

// d7 on 26 pin
reg pre_beeper = 0;
reg pre_tapeout = 0;
always @(negedge wr) begin
	if( ~( iorq | a0) ) pre_beeper  = d_4;
	if( ~( iorq | a0) ) pre_tapeout = d_3;
end
assign beeper = pre_beeper;
assign tapeout = pre_tapeout;
//	 tapeout = dos;



/*
// d7 on 33 pin
reg pre_beeper;
reg pre_tapeout;
always @(negedge cpu_clock) begin
	if( ~(iorq | wr | a0) ) pre_beeper  = d[4];
	if( ~(iorq | wr | a0) ) pre_tapeout = d[3];
end

	beeper = pre_beeper;
	tapeout =  pre_tapeout;*/



//	 beeper = 1'bz;
//	 tapeout = 1'bz;

endmodule

/*
#FFFD - регистр адреса AY-3-8910  61437  1111111111111101
#BFFD - регистр данных AY-3-8910  49149  1011111111111101
*/

/*
https://github.com/tslabs/zx-evo/blob/master/pentevo/fpga/base/z80/zports.v
	localparam PORTFD = 8'hFD;
	wire [7:0] loa; <-- low addres
	reg pre_bc1,pre_bdir;
	// AY control
	always @*
	begin
		pre_bc1 = 1'b0;
		pre_bdir = 1'b0;

		if( loa==PORTFD )
		begin
			if( a[15:14]==2'b11 )
			begin
				pre_bc1=1'b1;
				pre_bdir=1'b1;
			end
			else if( a[15:14]==2'b10 )
			begin
				pre_bc1=1'b0;
				pre_bdir=1'b1;
			end
		end
	end

		ay_bc1  = pre_bc1  & (~iorq_n) & ((~rd_n)|(~wr_n));
		ay_bdir = pre_bdir & (~iorq_n) & (~wr_n);

*/