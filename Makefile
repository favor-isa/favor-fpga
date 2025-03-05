SRC= \
	driver.cpp \
	verilated_inst.cpp

OBJS=$(SRC:%.cpp=%.cpp.o)

sim: $(OBJS) obj_dir/Vthruwire__ALL.a
	g++ -I/usr/share/verilator/include \
		-Iobj_dir \
		$^ \
		-o $@

%.cpp.o: %.cpp
	g++ -c -I/usr/share/verilator/include -Iobj_dir $^ -o $@ -Wall

obj_dir/Vthruwire__ALL.a: thruwire.v
	verilator -Wall -cc $^
	cd obj_dir && make -f Vthruwire.mk