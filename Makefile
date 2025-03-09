SRC= \
	driver.cpp

OBJS=$(SRC:%.cpp=%.cpp.o)

# TODO: Rewrite the makefile to match e.g.
# https://github.com/Kode/verilator/blob/master/examples/tracing_c/Makefile_obj
TOP_V=cpu

SRC_V=\
	cpu.v \
	decoder.v \
	memory.v 

SRC_FILES= \
	$(SRC_V) \
	cpustate.vinc \
	initial_ram.txt \
	gowin-constrain.cst

GOWIN_FILES=$(SRC_FILES:%=favor-soc/%)

sim: $(OBJS) obj_dir/V$(TOP_V)__ALL.a
	g++ -I/usr/share/verilator/include \
		-I/usr/share/verilator/include/vltstd \
		-Iobj_dir \
		$^ \
		obj_dir/verilated.o obj_dir/verilated_threads.o \
		-o $@

%.cpp.o: %.cpp obj_dir/V$(TOP_V).h
	g++ -c $< -o $@ -Wall -I/usr/share/verilator/include -I/usr/share/verilator/include/vltstd -Iobj_dir 

obj_dir/V$(TOP_V)__ALL.a obj_dir/V$(TOP_V).h: $(TOP_V).v decoder.v memory.v initial_ram.txt
	verilator -Wall -cc $<
	cd obj_dir && make -f V$(TOP_V).mk

.PHONY: clean

clean:
	find . -name "*.o" -delete
	rm -rf obj_dir

-include .config

favor-soc/favor-soc.gprj: | $(SRC_FILES)
	echo "create_project -name favor-soc -pn GW5A-LV25MG121NC1/I0 -device_version A -force" > commands.txt
# Use the ready LED as a gpio
	echo "set_option -use_ready_as_gpio 1" >> commands.txt
# Use the CPU as a gpio so we can route the clock. TODO is this the correct way
# to set up the clock?
	echo "set_option -use_cpu_as_gpio 1" >> commands.txt
	$(foreach v,$(SRC_FILES),echo "add_file $(v)" >> commands.txt ;)
	$(GOWIN_SH) commands.txt

gowin-sh:
	$(GOWIN_SH)

gowin-build: $(GOWIN_FILES) favor-soc/favor-soc.gprj
	$(GOWIN_SH) gowin-build.txt

favor-soc/%: % 
	mkdir -p favor-soc
	cp $< $@

gowin-clean:
	rm -rf favor-soc

.PHONY: gowin-sh gowin-build gowin-clean