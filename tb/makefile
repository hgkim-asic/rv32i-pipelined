# --------------------------------------------------
#	Common Environment
# --------------------------------------------------
PRJ_PATH	=	$(CURDIR)/..

# --------------------------------------------------
#	RTL Path & Top Design Name
# --------------------------------------------------
CPU_TYPE	=	pipelined
RTL_PATH	=	$(PRJ_PATH)
RTL_NAME	=	rv_top
RTL_FILE	=	$(RTL_PATH)/$(CPU_TYPE)/$(RTL_NAME).v

# --------------------------------------------------
#	Verilator
# --------------------------------------------------
VRL_TBCPP	=	tb.cpp
VRL_FLAGS	=	-Wno-fatal --trace
VRL_FLAGS	+=	-I$(RTL_PATH)/common
VRL_FLAGS	+=	-I$(RTL_PATH)/$(CPU_TYPE)
VCD_FLAG	=	+vcd

# --------------------------------------------------
#	RISC-V Test
# --------------------------------------------------
TEST_PATH	=	$(CURDIR)/mif
TEST_VECS	=	$(notdir $(basename $(wildcard $(TEST_PATH)/*.S)))

all:		run

verilate:	$(RTL_FILE) $(VRL_TBCPP)
	@verilator $(VRL_FLAGS) --cc $(RTL_FILE) --exe $(VRL_TBCPP) --Mdir $(CPU_TYPE)

build:		verilate
	@make -C $(CPU_TYPE) -f V$(RTL_NAME).mk

%.run:		build
	@./$(CPU_TYPE)/V$(RTL_NAME) $(VCD_FLAG) +data_mif="$(TEST_PATH)/$(@:.run=).data.mif" +text_mif="$(TEST_PATH)/$(@:.run=).text.mif"
	@mkdir -p vcd
	@mv dut.vcd ./vcd/$(@:.run=).vcd
	@echo ":$(@:.run=)"

run:		$(addsuffix .run, $(TEST_VECS))

clean:
	rm -rf $(CPU_TYPE) ./vcd
