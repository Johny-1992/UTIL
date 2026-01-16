#include <iostream>
#include <string>
#include <cstdlib>

int main(int argc, char* argv[]) {
    if (argc < 4) {
        std::cerr << "INVALID_ARGS" << std::endl;
        return 1;
    }

    std::string qrEvent = argv[1];
    std::string aiDecision = argv[2];
    double reward = atof(argv[3]);

    std::string finalDecision = aiDecision;
    double finalReward = reward;

    // 🌌 LOGIQUE MÈRE OMNIUTIL
    if (aiDecision == "REJECTED") {
        finalReward = 0;
    } 
    else if (aiDecision == "PENDING") {
        finalReward = reward * 0.2;
    } 
    else if (aiDecision == "AUTO_ACCEPTED") {
        if (finalReward > 1000) finalReward = 1000; // plafond anti-inflation
    }

    if (finalReward < 0) finalReward = 0;

    std::cout
        << "ORCHESTRATE_OK "
        << finalDecision << " "
        << finalReward
        << std::endl;

    return 0;
}
