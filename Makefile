#SRC= \
#	driver.cpp

#OBJS=$(SRC:%.cpp=%.cpp.o)

sim: driver.cpp obj_dir/Vthruwire__ALL.a
	g++ -I/usr/share/verilator/include \
		-Iobj_dir \
		verilated_inst.cpp \
		$^ \
		obj_dir/Vthruwire__ALL.a \
		-o $@

obj_dir/Vthruwire__ALL.a: thruwire.v
	verilator -Wall -cc $^
	cd obj_dir && make -f Vthruwire.mk