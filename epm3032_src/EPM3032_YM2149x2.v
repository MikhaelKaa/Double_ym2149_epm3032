module EPM3032_YM2149x2 (
input a0, a1, a2, a3, a13, a14, a15,
input cpu_clock, m1, iorq, wr, rd, 
input reset,  
input d_0, d_3, d_4, d_5, d_6, d_7,  
input dos,
output covox, 
input div2,

output bc1, 
output bdir, 
output ym_clock, 
output ym_0, ym_1,
output beeper,
output tapeout,
output ioge_c
);

// Для тактирования звукового генератора 3.5 MHz - в ямахе использован встроенный делитель на два.
// На плате версии 1.5 26 пин звукчипа посажен на землю намертво - поэтому пока так.
reg ym_clk_div = 1'b0;
reg iorqge_filter = 1'b0;

always @(posedge cpu_clock) begin
	ym_clk_div = ~ym_clk_div; 
	iorqge_filter = iorqge;
end
assign ym_clock = div2?(cpu_clock):(ym_clk_div); 

// Вариант дешифрации.
wire port_          = ~(~a0 | a1 | ~a2 | ~a3               | ~a15);
wire port_bffd      = ~(~a0 | a1 | ~a2 | ~a3        |  a14 | ~a15);
wire port_fffd      = ~(~a0 | a1 | ~a2 | ~a3        | ~a14 | ~a15);
wire port_fffd_full = ~(~a0 | a1 | ~a2 | ~a3 | ~a13 | ~a14 | ~a15);

assign bdir = (port_ | ~iorq)?( ( (((a14==0)&(wr==0)&(rd==1)) | ((a14==1))&(wr==0)&(rd==1)) )?(1'b1):(1'b0) ):(1'b0); // #bffd
assign bc1  = (port_ | ~iorq)?( ( (((a14==1)&(wr==0)&(rd==1)) | ((a14==1))&(wr==1)&(rd==0)) )?(1'b1):(1'b0) ):(1'b0); // #fffd_full with #dffd compat

// IOGE
wire iorqge = (m1 && (port_fffd_full || port_bffd))? 1'b1 : 1'b0;
//assign ioge_c = iorqge;
assign ioge_c = iorqge_filter;


// Turbo Sound
reg  YM_select;
wire TS_bit_sel = ~(d_3 & d_4 & d_5 & d_6 & d_7 & bdir & bc1); 
always @(negedge TS_bit_sel or negedge reset) begin
	if(~reset) 	YM_select = 1'b0;
	else 			YM_select = d_0;
end
assign ym_0 = YM_select;
assign ym_1 = ~ym_0;

// covox 0xfb
assign covox = ~(~a0 | ~a1 | a2 | ~a3 | iorq | wr);

// beeper и tapeout 0xfe.
reg pre_beeper = 0;
reg pre_tapeout = 0;
wire port_fe = wr | iorq | a0 | ~a1 | ~a2 | ~a3;
always @(negedge port_fe) begin
	pre_beeper  <= d_4;
	pre_tapeout <= d_3;
end
assign beeper = pre_beeper;
assign tapeout = pre_tapeout;

endmodule
