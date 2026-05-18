#include "Vtb_core.h"
#include "verilated.h"
#include "verilated_vcd_c.h"
#include "verilated_cov.h"

int main(int argc, char** argv) {
    Verilated::commandArgs(argc, argv);
    
    // Instantiate the generated Verilated module
    Vtb_core* top = new Vtb_core; 

    // Setup Waveform tracing
    Verilated::traceEverOn(true);
    VerilatedVcdC* tfp = new VerilatedVcdC;
    top->trace(tfp, 99); // Trace 99 levels deep
    tfp->open("waveform.vcd");

    int main_time = 0;
    top->rst_n = 0; // Start in reset
    top->clk = 0;

    // Run the simulation for 100 half-clock cycles
    while (main_time < 100 && !Verilated::gotFinish()) {
        if (main_time > 4) {
            top->rst_n = 1; // Release reset after 4 ticks
        }
        
        top->clk = !top->clk; // Toggle clock
        top->eval();          // Evaluate logic
        tfp->dump(main_time); // Write to waveform file
        
        main_time++;
    }

    // Cleanup
    top->final(); 
    tfp->close(); 
    delete top;

    VerilatedCov::write("coverage.dat");
    return 0;
}