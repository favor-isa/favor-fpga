SRC= \
	driver.cpp

OBJS=$(SRC:%.cpp=%.cpp.o)

# TODO: Rewrite the makefile to match e.g.
# https://github.com/Kode/verilator/blob/master/examples/tracing_c/Makefile_obj
TOP_V=cpu

sim: $(OBJS) obj_dir/V$(TOP_V)__ALL.a
	g++ -I/usr/share/verilator/include \
		-Iobj_dir \
		$^ \
		obj_dir/verilated.o obj_dir/verilated_threads.o \
		-o $@

%.cpp.o: %.cpp obj_dir/V$(TOP_V).h
	g++ -c $< -o $@ -Wall -I/usr/share/verilator/include -Iobj_dir 

obj_dir/V$(TOP_V)__ALL.a obj_dir/V$(TOP_V).h: $(TOP_V).v
	verilator -Wall -cc $^ "-GCOUNT_VALUE=25'd2"
	cd obj_dir && make -f V$(TOP_V).mk

.PHONY: clean

clean:
	find . -name "*.o" -delete
	rm -rf obj_dir