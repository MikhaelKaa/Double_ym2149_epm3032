module EPM3032_YM2149x2 (
input a1, input a14, input a15,
input a0,
input m1, 
input iorq, 
input wr, 
input clk350, 
input reset, 
input [7:0]d, 

output bc1, 
output bdir, 
output clk175, 
output [1:0]a8,
output beeper,
output tapeout
);

// Дешифрация звукового генератора.
wire	ssg;
assign ssg = ~(a15 & ( ~(a1 | iorq)));
assign bc1  = ~( ssg | (~(a14 & m1)));
assign bdir = ~( ssg | wr);

wire dd = ~(d[3] & d[4] & d[5] & d[6] & d[7] & bdir & bc1); 
wire vcc = 1'b1;

ttl_7474 tm2(
  .Preset_bar(reset),
  .Clear_bar(vcc),
  .Clk(dd),
  .D(d[0]),
  .Q(a8[1]),
  .Q_bar(a8[0])
);

// Деление 3.5 МГц на 2 для тактирования звукового генератора.
always @(negedge clk350) begin
	clk_div_cnt <= ~clk_div_cnt;
end	
reg clk_div_cnt 	= 1'd0;
assign clk175 = clk_div_cnt;

// Дешифрация бипера. Работает аналогично пентагоновской схеме.
reg pre_beeper;
reg pre_tapeout;
always @(negedge clk350) begin
	if( ~(iorq | wr | a0) ) pre_beeper = d[4];
	if( ~(iorq | wr | a0) ) pre_tapeout = d[3];
end
assign beeper = pre_beeper;
assign tapeout = pre_tapeout;

endmodule

// https://github.com/TimRudy/ice-chips-verilog/blob/master/source-7400/7474.v
// Dual D flip-flop with set and clear; positive-edge-triggered

// Note: Preset_bar is synchronous, not asynchronous as specified in datasheet for this device,
//       in order to meet requirements for FPGA circuit design (see IceChips Technical Notes)

module ttl_7474 #(parameter BLOCKS = 1, DELAY_RISE = 0, DELAY_FALL = 0)
(
  input [BLOCKS-1:0] Preset_bar,
  input [BLOCKS-1:0] Clear_bar,
  input [BLOCKS-1:0] D,
  input [BLOCKS-1:0] Clk,
  output [BLOCKS-1:0] Q,
  output [BLOCKS-1:0] Q_bar
);

//------------------------------------------------//
reg [BLOCKS-1:0] Q_current;
reg [BLOCKS-1:0] Preset_bar_previous;

generate
  genvar i;
  for (i = 0; i < BLOCKS; i = i + 1)
  begin: gen_blocks
    always @(posedge Clk[i] or negedge Clear_bar[i])
    begin
      if (!Clear_bar[i])
        Q_current[i] <= 1'b0;
      else if (!Preset_bar[i] && Preset_bar_previous[i])  // falling edge has occurred
        Q_current[i] <= 1'b1;
      else
      begin
        Q_current[i] <= D[i];
        Preset_bar_previous[i] <= Preset_bar[i];
      end
    end
  end
endgenerate
//------------------------------------------------//

assign #(DELAY_RISE, DELAY_FALL) Q = Q_current;
assign #(DELAY_RISE, DELAY_FALL) Q_bar = ~Q_current;

endmodule

