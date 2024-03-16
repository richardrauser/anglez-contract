
struct Tint {
    uint8 red; // 0 - 255
    uint8 green; // 0 - 255
    uint8 blue; // 0 - 255
    uint8 alpha; // 0 - 255
}

struct TokenParams {
    uint24 randomSeed;
    uint8 zoom; // 0 - 100
    Tint tint;
    uint8 shapes; // 1 - 20
    bool cyclic; // 25 - 250 
    bool custom; // 25 - 250
}

