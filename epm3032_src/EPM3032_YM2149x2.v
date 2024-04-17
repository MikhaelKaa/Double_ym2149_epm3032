module EPM3032_YM2149x2 (
input a0, a1, a2, a14, a15,
input cpu_clock, m1, iorq, wr, intr, 
input reset,  
input d_0, d_3, d_4, d_5, d_6, d_7,  
input d7_alt,
input dos,
output covox, 

output bc1, 
output bdir, 
output ym_clock, 
output ym_0, ym_1,
output beeper,
output tapeout,
output ioge_c,
output test
);

assign test = 1'bz;//dos;

// Для тактирования звукового генератора 1.75 MHz.
// TODO: Сделать переключатель на случай тактирования 7 MHz.
reg ym_clk_div = 1'b0;
always @(negedge cpu_clock) begin
	ym_clk_div = ~ym_clk_div;
end
assign ym_clock = ym_clk_div;

// covox
assign covox = ~(a2 | iorq | wr);

// Дешифрация звукового генератора.
wire   ssg 	= ~(a15 & (~(a1 | iorq)));
assign bc1  = ~(ssg | (~(a14 & m1)));
assign bdir = ~(ssg | wr);

// IOGE
wire iorqge = (a15 == 1) & (a1 == 0) & (m1 == 1);
assign ioge_c = iorqge;

// Turbo Sound
reg  YM_select;
wire TS_bit_sel = ~(d_3 & d_4 & d_5 & d_6 & d_7 & bdir & bc1); 
//wire TS_bit_sel = ~(d_3 & d_4 & d_5 & d_6 & d7_alt & bdir & bc1); 
always @(negedge TS_bit_sel or negedge reset) begin
	if(~reset) 	YM_select = 1'b0;
	else 			YM_select = d_0;
end
assign ym_0 = ~YM_select;
assign ym_1 = ~ym_0;


// Дешифрация бипера и tapeout. Аналогично пентагоновской схеме.
reg pre_beeper;
reg pre_tapeout;
wire port_fe = wr | iorq | a0;// | ~a1 | ~a2;
always @(negedge port_fe) begin
	pre_beeper  <= d_4;
	pre_tapeout <= d_3;
end
assign beeper = pre_beeper;
assign tapeout = pre_tapeout;

endmodule