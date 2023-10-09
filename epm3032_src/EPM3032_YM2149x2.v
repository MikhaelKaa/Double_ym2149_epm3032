module EPM3032_YM2149x2 (
input a0, a1, a2, a14, a15,
input cpu_clock, m1, iorq, wr, int, 
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

// Для тактирования звукового генератора 3.5.
//assign ym_clock = cpu_clock;


// Для тактирования звукового генератора при изменении частоты 7\3.5.
reg [11:0] clk_div_cnt;
reg [6:0] clk_cnt;
reg clk_check7;
reg clk_detect_70m;

always @(negedge cpu_clock) begin
	clk_div_cnt <= clk_div_cnt + 1;
end	
wire clk_for_cnt = clk_div_cnt[10];

always @(negedge int) begin
	clk_check7 = ~clk_check7;
end

always @(negedge clk_check7) begin
	clk_detect_70m = clk7_flag;
end
wire clk7_flag =  clk_cnt[6] & clk_cnt[2];

always @(negedge clk_for_cnt) begin
	if(clk_check7)clk_cnt = clk_cnt + 1;
	else clk_cnt = 0;
end	

assign ym_clock = (clk_detect_70m)?(clk_div_cnt[0]):(cpu_clock);


assign test = clk_detect_70m;

// covox
assign covox = ~(a2 | iorq | wr | ~dos);

// Дешифрация звукового генератора.
wire   ssg 	= ~(a15 & (~(a1 | iorq)));
assign bc1  = ~(ssg | (~(a14 & m1)));
assign bdir = ~(ssg | wr);

// IORQGE
assign ioge_c = bc1 | bdir;

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

// d7 on 26 pin
reg pre_beeper;
reg pre_tapeout;
always @(negedge wr) begin
	if( ~( iorq | a0) ) pre_beeper  = d_4;
	if( ~( iorq | a0) ) pre_tapeout = d_3;
end
assign beeper = pre_beeper;
assign tapeout = pre_tapeout;
//assign tapeout = dos;



/*
// d7 on 33 pin
reg pre_beeper;
reg pre_tapeout;
always @(negedge cpu_clock) begin
	if( ~(iorq | wr | a0) ) pre_beeper  = d[4];
	if( ~(iorq | wr | a0) ) pre_tapeout = d[3];
end

assign beeper = pre_beeper;
assign tapeout =  pre_tapeout;*/



//assign beeper = 1'bz;
//assign tapeout = 1'bz;

endmodule