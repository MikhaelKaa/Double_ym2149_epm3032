module EPM3032_YM2149x2_tb;

localparam DURATION = 200000000;
localparam INT_LEN = 3000;
localparam INT_PERIOD = 20000000;

reg a0 = 1'b0;
reg a1 = 1'b0;
reg a2 = 1'b0;
reg a14 = 1'b0;
reg a15 = 1'b0;

reg cpu_clock = 1'b0;
reg m1 = 1'b0;
reg iorq = 1'b0;
reg wr = 1'b0;
reg int = 1'b1;
reg reset = 1'b0;
reg d_0 = 1'b0, d_3 = 1'b0, d_4 = 1'b0, d_5 = 1'b0, d_6 = 1'b0, d_7 = 1'b0;
//reg d7_alt = 1'b0;

wire covox;
wire bc1;
wire bdir;
wire ym_clock;
wire ym_0;
wire ym_1;
wire beeper;
wire tapeout;
wire ioge_c;
wire test;

EPM3032_YM2149x2 EPM3032_YM2149x2_inst(
  .a0(a0),
  .a1(a1),
  .a2(a2),
  .a14(a14),
  .a15(a15),

  .cpu_clock(cpu_clock),
  .m1(m1),
  .wr(wr),
  .int(int),
  .reset(reset),
  .d_0(d_0),
  .d_4(d_4),
  .d_5(d_5),
  .d_6(d_6),
  .d_7(d_7),
  //.d7_alt(d7_alt),
  .covox(),
  .bc1(bc1),
  .bdir(bdir),
  .ym_clock(ym_0),
  .ym_0(ym_0),
  .ym_1(ym_1),
  .beeper(beeper),
  .tapeout(tapeout),
  .ioge_c(ioge_c),
  .test(test)
);


// Регистр для переключения частоты клока.
reg clk_mux = 1'b0;
always@(*)begin
  cpu_clock = clk_mux?clk70:clk35;
end

// Сигналы тактовой частоты.
reg clk70 = 1'b0;
reg clk35 = 1'b0;

always begin
#(142/4) clk70 = ~clk70; // 142/4 ---> ~7MHz
end

always@(negedge clk70) begin
  clk35 = ~clk35;
end


// Сигнал int.
always begin
#INT_PERIOD int = 1'b0;
#INT_LEN int = 1'b1;
end

//
initial
  begin
    reset = 1;
    #10;
    reset = 0;
    #(DURATION/2);
    clk_mux = 1'b1;
end

// Заканчиваем симуляцию в момент времени DURATION.
initial
begin
  #DURATION $finish;
end

// Создаем файл VCD для последующего анализа сигналов.
initial
begin
  $dumpfile("EPM3032_YM2149x2.vcd");
  $dumpvars(0,EPM3032_YM2149x2_inst);
end

// Наблюдаем на некоторыми сигналами системы.
//initial
//$monitor($stime,, reset,, cpu_clock);

endmodule
