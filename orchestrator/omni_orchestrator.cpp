#include <iostream>
#include <thread>
#include <chrono>
#include <cstdlib>

int main() {
    std::cout << "🧠 OmniUtil C++ Orchestrator DEMO/LIVE" << std::endl;

    while (true) {
        system("curl -s http://localhost:3000/simulate > /dev/null");
        std::cout << "⚙️ Cycle récompense exécuté" << std::endl;
        std::this_thread::sleep_for(std::chrono::seconds(10));
    }

    return 0;
}
