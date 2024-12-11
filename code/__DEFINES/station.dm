#define STATION_TRAIT_POSITIVE 1
#define STATION_TRAIT_NEUTRAL 2
#define STATION_TRAIT_NEGATIVE 3
#define STATION_TRAIT_EXCLUSIVE 4

/// For traits that shouldn't be selected, like abstract types (wow)
#define STATION_TRAIT_ABSTRACT (1<<0)
/// Only run on planet stations
#define STATION_TRAIT_PLANETARY (1<<1)
/// Only run on space stations
#define STATION_TRAIT_SPACE_BOUND (1<<2)

/// Not restricted by space or planet, can always just happen
#define STATION_TRAIT_MAP_UNRESTRICTED STATION_TRAIT_PLANETARY | STATION_TRAIT_SPACE_BOUND
