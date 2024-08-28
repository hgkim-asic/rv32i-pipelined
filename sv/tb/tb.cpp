// ------------------------------------------------------------
//	C++ Standard Libaries
// ------------------------------------------------------------
#include <stdlib.h>
#include <iostream>
#include <cstdlib>

// ------------------------------------------------------------
//	For Common Verilator Routines & VCD (value change dump) File
// ------------------------------------------------------------
#include <verilated.h>
#include <verilated_vcd_c.h>

// ------------------------------------------------------------
//	Verilated DUT
// ------------------------------------------------------------
#include <Vrv_top.h>

// ------------------------------------------------------------
//	User Defines
// ------------------------------------------------------------
#define		MAX_SIM_TIME	100000
vluint64_t	sim_time		= 0;
bool		sim_flag		= 1;

// ------------------------------------------------------------
//	Functions
// ------------------------------------------------------------
void dutReset(Vrv_top *dut, vluint64_t &sim_time){
	dut->i_top_rstn = 0;
	if (sim_time > 10) {
        dut->i_top_rstn = 1;
    }
}

// ------------------------------------------------------------
//	Main Function
// ------------------------------------------------------------
int main(int argc, char** argv, char** env)
{	
	//	Verilator Arguments
	Verilated::commandArgs(argc, argv);

	//	DUT Instanciate
    Vrv_top	*dut = new Vrv_top;

	//	Plus Arguments based VCD
	VerilatedVcdC *vcdTrace = new VerilatedVcdC;
	const char* flag_vcd = Verilated::commandArgsPlusMatch("vcd");
	if (flag_vcd && 0==strcmp(flag_vcd, "+vcd")) {
		Verilated::traceEverOn(true);
		dut->trace (vcdTrace, 99);
		vcdTrace->open("dut.vcd");
	}

	//	Stimulus & Evaluation
    while (sim_time < MAX_SIM_TIME)
	{
		dutReset(dut, sim_time);
        dut->i_top_clk ^= 1;
        dut->eval();
        if (flag_vcd && 0==strcmp(flag_vcd, "+vcd")) vcdTrace->dump(sim_time);
		if (sim_flag == 0) break;
        if (dut->o_top_dmem_wen && dut->o_top_dmem_addr == 0xfffffff0) {
            if (dut->o_top_dmem_wdata) {
				printf("PASS:");
            } else {
				printf("FAIL:");
            }
			sim_flag	= 0;
        }
        sim_time++;
    }

    if (flag_vcd && 0==strcmp(flag_vcd, "+vcd")) vcdTrace->close();
    delete vcdTrace;
    delete dut;
    exit(EXIT_SUCCESS);
}

