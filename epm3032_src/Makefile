# Для тестирования модуля неодходимо чтобы тест назывался %имя_модуля%_tb

TARGET = EPM3032_YM2149x2
ICARUS = iverilog

#mv out.vcd $(TARGET).vcd
all: 
	$(ICARUS) -o $(TARGET)  $(TARGET).v $(TARGET)_tb.v
	vvp $(TARGET)
clean:
	rm -f $(TARGET) $(TARGET).vcd

.PHONY: all clean
