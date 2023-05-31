VLOG_FLAGS = -source -lint -sv

fst:
	rm -rf transcript work *.vcd
	vlog $(VLOG_FLAGS) ALU.sv ALU_tb.sv
	vsim -c -voptargs=+acc=npr top1 -do "vcd file ALU_tb.vcd; vcd add -r top1/*; run -all; quit"

snd: 
	rm -rf transcript work *.vcd
	vlog $(VLOG_FLAGS) ALU.sv I2C.sv I2C_tb.sv
	vsim -c -voptargs=+acc=npr top2 -do "vcd file I2C_tb.vcd; vcd add -r top2/*; run -all; quit"

trd: 
	rm -rf transcript work *.vcd
	vlog $(VLOG_FLAGS) ALU.sv I2C.sv Mem_Contr.sv Mem_Contr_tb.sv
	vsim -c -voptargs=+acc=npr top3 -do "vcd file Mem_Contr_tb.vcd; vcd add -r top3/*; run -all; quit"

fr:
	rm -rf transcript work *.vcd
	vlog $(VLOG_FLAGS) ALU.sv I2C.sv Mem_Contr.sv Memory.sv Memory_tb.sv
	vsim -c -voptargs=+acc=npr top4 -do "vcd file Memory_tb.vcd; vcd add -r top4/*; run -all; quit"

fi:
	rm -rf transcript work *.vcd
	vlog $(VLOG_FLAGS) ALU.sv I2C.sv Mem_Contr.sv Memory.sv top.sv top_tb.sv
	vsim -c -voptargs=+acc=npr top -do "vcd file top.vcd; vcd add -r top/*; run -all; quit"

clean:
	rm -rf transcript work *.vcd