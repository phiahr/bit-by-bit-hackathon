#include "VL2NormAXIS.h"
#include "verilated.h"
#include <iostream>
#include <bitset>
#include <cstdint>
#include <cstring>

vluint64_t main_time = 0;
double sc_time_stamp() { return main_time; }

void tick(VL2NormAXIS* dut) {
    dut->clock = 0;
    dut->eval();
    main_time++;
    dut->clock = 1;
    dut->eval();
    main_time++;
}

double int_to_float(uint32_t raw_bits) {
    float f;
    std::memcpy(&f, &raw_bits, sizeof(float));
    return (double)f;
}

double fixed_to_float(int32_t value, int frac_bits) {
    return static_cast<double>(value) / static_cast<double>(1 << frac_bits);
}

void print32BitRepresentation(uint32_t value) {
    std::cout << "\tValue: " << value << std::endl;
    std::cout << "\tDecimal: " << std::dec << value << std::endl;
    std::cout << "\tHex: 0x" << std::hex << std::uppercase << value << std::endl;
    std::cout << "\tBinary: " << std::bitset<32>(value) << std::endl;
}

void send_input(VL2NormAXIS* dut, uint32_t data) {
    dut->io_in_tdata = data;
    dut->io_in_tvalid = 1;
    dut->io_in_tlast = 1;
    do {
        tick(dut);
    } while (!dut->io_in_tready);
    dut->io_in_tvalid = 0;
    dut->io_in_tlast = 0;
}

uint32_t read_output(VL2NormAXIS* dut) {
    dut->io_out_tready = 1;
    while (!dut->io_out_tvalid) tick(dut);
    tick(dut);
    dut->io_out_tready = 0;
    return dut->io_out_tdata;
}

int main(int argc, char** argv) {
    Verilated::commandArgs(argc, argv);
    VL2NormAXIS* dut = new VL2NormAXIS;

    dut->clock = 0;
    dut->reset = 1;
    for (int i = 0; i < 5; ++i) tick(dut);
    dut->reset = 0;

    uint32_t data_in = 0x3f800000;
    std::cout << "Input:" << std::endl;
    print32BitRepresentation(data_in);

    send_input(dut, data_in);
    uint32_t result = read_output(dut);

// #ifdef FIXED
//     double value = fixed_to_float(result, FIXED);
// #else
//     double value = int_to_float(result);
// #endif

    std::cout << "Output:" << std::endl;
    print32BitRepresentation(result);
    // std::cout << "Converted: " << value << std::endl;

    delete dut;
    return 0;
}
