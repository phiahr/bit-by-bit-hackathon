#include "VL2NormAXIS.h"
#include "verilated.h"
#include <cmath>
#include <cstdlib>
#include <ctime>
#include <vector>
#include <iostream>
#include <random>
#include <bitset>

#define DATA_WIDTH 64
#define OUT_WIDTH 32
#define ELEM_WIDTH 8
#define NUM_ELEMS (DATA_WIDTH / ELEM_WIDTH)
#define NUM_VECTORS 1000
#define MAX_NUM_BEATS 64
// #define FLOAT
#define FIXED 8

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
    return (double) f;
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

int main(int argc, char** argv) {
    Verilated::commandArgs(argc, argv);
    VL2NormAXIS* dut = new VL2NormAXIS;

    std::srand(std::time(nullptr));
    std::random_device rd;
    std::mt19937 gen(rd());  // Mersenne Twister RNG
    std::normal_distribution<> dist(0.0, 32.0);  // mean = 0, stddev = 32

    // Reset
    dut->clock = 0;
    dut->reset = 1;
    for (int i = 0; i < 5; ++i) tick(dut);
    dut->reset = 0;

    std::vector<double> expected_vec(NUM_VECTORS);
    std::vector<double> received_vec(NUM_VECTORS);
    std::vector<int> latency_vec(NUM_VECTORS);
    double mse = 0.0f;
    int total_latency = 0;

    for (int vec = 0; vec < NUM_VECTORS; ++vec) {
        int sum_sq = 0;
        int num_beats = std::rand() % MAX_NUM_BEATS + 1;

        for (int beat = 0; beat < num_beats; ++beat) {
            uint64_t tdata = 0;
            for (int i = 0; i < NUM_ELEMS; ++i) {
                int val = std::lround(dist(gen));
                if (val > 127) val = 127;
                if (val < -128) val = -128;
                int8_t signed_val = static_cast<int8_t>(val);
                sum_sq += signed_val * signed_val;
                tdata |= (static_cast<uint64_t>(signed_val) & 0xFF) << (i * 8);
            }

            dut->io_in_tdata = tdata;
            dut->io_in_tvalid = 1;
            dut->io_in_tlast = (beat == num_beats - 1);

            do {
                tick(dut);
            } while (!dut->io_in_tready);
        }

        // Done sending vector
        dut->io_in_tvalid = 0;
        dut->io_in_tlast = 0;

        // Wait for output
        dut->io_out_tready = 1;
        int latency = 0;
        while (!dut->io_out_tvalid) {
            tick(dut);
            if (++latency > 10000) {
                std::cerr << "Timeout on vector " << vec << std::endl;
                return 1;
            }
        }
        tick(dut);
        dut->io_out_tready = 0;

        double expected = std::sqrt(static_cast<double>(sum_sq));
        #ifdef FIXED
            double received = fixed_to_float(dut->io_out_tdata, FIXED);
            std::cout << "Using fixed-point representation with " << FIXED << " fractional bits." << std::endl;
        #else
            double received = int_to_float(dut->io_out_tdata);
            std::cout << "Using floating-point representation." << std::endl;
            std::cout << "RESULT:" << std::endl;
            print32BitRepresentation(dut->io_out_tdata);
#endif

        expected_vec[vec] = expected;
        received_vec[vec] = received;
        latency_vec[vec] = latency;

        std::cout << "Vector " << vec << " | Expected: " << expected
                  << ", Received: " << received
                  << ", Latency: " << latency << std::endl;
    }

    for (int i = 0; i < NUM_VECTORS; ++i) {
        double err = received_vec[i] - expected_vec[i];
        mse += err * err;
        total_latency += latency_vec[i];
    }
    mse /= NUM_VECTORS;

    std::cout << std::scientific << "MSE = " << mse << std::endl;
    std::cout << "Average Latency = " << (total_latency / NUM_VECTORS) << " cycles" << std::endl;

    if (mse > 4.0)
        std::cerr << "FAIL: MSE too high!" << std::endl;
    else
        std::cout << "PASS: MSE is within acceptable range." << std::endl;

    delete dut;
    return 0;
}
