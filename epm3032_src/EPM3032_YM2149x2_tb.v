module EPM3032_YM2149x2_tb;

localparam DURATION =       200000000;
localparam INT_LEN =        9000;
localparam INT_PERIOD =     20000000;
localparam CLK_CONST =      71;  //---> ~7MHz
localparam CPU_CLK_NORMAL = 1'b0;
localparam CPU_CLK_TURBO =  1'b1;

reg [15:0]adr = 16'hffff;
reg [7:0]data = 16'hff;

reg cpu_clock = 1'b0;
reg m1 = 1'b1;
reg dos = 1'b1;
reg iorq = 1'b1;
reg rd = 1'b1;
reg wr = 1'b1;
reg int = 1'b1;
reg reset = 1'b1;

//reg d_0 = 1'b0, d_3 = 1'b0, d_4 = 1'b0, d_5 = 1'b0, d_6 = 1'b0, d_7 = 1'b0;                       

wire covox;
wire bc1;
wire bdir;
wire ym_clock;
wire ym_0;
wire ym_1;
wire beeper;
wire tapeout;
wire ioge_c;
//wire test;

EPM3032_YM2149x2 EPM3032_YM2149x2_inst(
  .a0(adr[0]),
  .a1(adr[1]),
  .a2(adr[2]),
  .a14(adr[14]),
  .a15(adr[15]),

  .cpu_clock(cpu_clock),
  .m1(m1),
  .dos(dos),
  .wr(wr),
  //.int(int),
  .iorq(iorq),
  .reset(reset),
  .d_0(data[0]),
  .d_4(data[4]),
  .d_5(data[5]),
  .d_6(data[6]),
  .d_7(data[7]),
  //.d7_alt(d7_alt),
  .covox(covox),
  .bc1(bc1),
  .bdir(bdir),
  .ym_clock(ym_0),
  .ym_0(ym_0),
  .ym_1(ym_1),
  .beeper(beeper),
  .tapeout(tapeout),
  .ioge_c(ioge_c),
  .rd(rd)
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
  #CLK_CONST clk70 = ~clk70;  
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
    clk_mux = CPU_CLK_NORMAL;
    reset = 1;
    #10;
    reset = 0;
    m1 = 1'b1;
    dos = 1'b1;
    iorq = 1'b1;

    // covox test
    $display("covox on port 0x00fb");
    wr = 0; //<----
    rd = 1; 
    adr = 16'h00fb;
    data = 8'hff;
    iorq = 0;
    #200
    if(covox != 1'b1) $display("covox FAIL");
    if(covox != 1'b0) $display("covox OK");
    wr = 1; //<----
    rd = 1; 
    adr = 16'h0000;
    iorq = 1;
    data = 8'h00;

    // beeper test
    $display("beeper & tapeout on port 0x00fe");
    wr = 0; //<----
    rd = 1; 
    adr = 16'h00fe;
    data = 8'hff;
    #20
    iorq = 0;
    #200
    if(beeper != 1'b1) $display("beeper FAIL");
    if(beeper != 1'b0) $display("beeper OK");
    wr = 1; //<----
    rd = 1; 
    adr = 16'h0000;
    iorq = 1;
    data = 8'h00;


    // BFFD WR
    #1000;
    wait(cpu_clock == 0);
    iorq = 0;
    #142;
    wr = 0; //<----
    rd = 1; 
    adr = 16'hBFFD;
    #560;
    $display("TEST BFFD WR");
    if(bc1 != 1'b0) $display("bc1 FAIL");
    if(bdir != 1'b1) $display("bdir FAIL");
    wr = 1;
    rd = 1; 
    iorq = 1;
    adr = 16'hFFFF;

    // FFFD WD
    #1000;
    wait(cpu_clock == 0);
    iorq = 0;
    #142;
    wr = 0; //<----
    rd = 1; 
    adr = 16'hFFFD;
    #560;
    $display("TEST BFFD WR");
    if(bc1 != 1'b1) $display("bc1 FAIL");
    if(bdir != 1'b1) $display("bdir FAIL");
    wr = 1;
    rd = 1; 
    iorq = 1;
    adr = 16'hFFFF;

    // FFFD RD
    #1000;
    wait(cpu_clock == 0);
    iorq = 0;
    #142;
    wr = 1; 
    rd = 0; //<----
    adr = 16'hFFFD;
    #560;
    $display("TEST FFFD RD");
    if(bc1 != 1'b1) $display("bc1 FAIL");
    if(bdir != 1'b0) $display("bdir FAIL");
    wr = 1;
    rd = 1; 
    iorq = 1;
    adr = 16'hFFFF;

    // 7FFD RD
    #1000;
    wait(cpu_clock == 0);
    iorq = 0;
    #142;
    wr = 1; 
    rd = 0; //<----
    adr = 16'h7FFD;
    #560;
    $display("TEST 7FFD RD");
    if(bc1 != 1'b0) $display("bc1 FAIL");
    if(bdir != 1'b0) $display("bdir FAIL");
    wr = 1;
    rd = 1; 
    iorq = 1;
    adr = 16'hFFFF;

        
    // 7FFD WR
    #1000;
    wait(cpu_clock == 0);
    iorq = 0;
    #142;
    wr = 0; //<----
    rd = 1; 
    adr = 16'h7FFD;
    #560;
    $display("TEST 7FFD WD");
    if(bc1 != 1'b0) $display("bc1 FAIL");
    if(bdir != 1'b0) $display("bdir FAIL");
    wr = 1;
    rd = 1; 
    iorq = 1;
    adr = 16'hFFFF;

    // BFFD RD
    #1000;
    wait(cpu_clock == 0);
    iorq = 0;
    #142;
    wr = 1; 
    rd = 0; //<----
    adr = 16'hBFFD;
    #560;
    $display("TEST BFFD RD");
    if(bc1 != 1'b0) $display("bc1 FAIL");
    if(bdir != 1'b0) $display("bdir FAIL");
    wr = 1;
    rd = 1; 
    iorq = 1;
    adr = 16'hFFFF;

    // BFFD WR
    #1000;
    wait(cpu_clock == 0);
    iorq = 0;
    #142;
    wr = 0; //<----
    rd = 1; 
    adr = 16'hBFFD;
    #560;
    $display("TEST BFFD WD");
    if(bc1 != 1'b0) $display("bc1 FAIL");
    if(bdir != 1'b0) $display("bdir FAIL");
    wr = 1;
    rd = 1; 
    iorq = 1;
    adr = 16'hFFFF;

    #(DURATION/2);
    clk_mux = CPU_CLK_TURBO;
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
