
#ifndef __OPTIONS_H
#define __OPTIONS_H



#ifndef MAPPER_MMC3
  #define MAPPER_MMC3 0
#endif
#ifndef MAPPER_MMC5
  #define MAPPER_MMC5 0
#endif
#ifndef USE_MMC5_AUDIO
  #define USE_MMC5_AUDIO 0
#endif
#ifndef USE_VRC7_AUDIO
  #define USE_VRC7_AUDIO 0
#endif
#ifndef USE_VANILLA_MUSIC
  #define USE_VANILLA_MUSIC 0
#endif
#ifndef USE_FAMISTUDIO_MUSIC
  #define USE_FAMISTUDIO_MUSIC 0
#endif
#ifndef DEBUG_WORLD_SELECT
  #define DEBUG_WORLD_SELECT 0
#endif
#ifndef PRINT_METASPRITE_IDS
  #define PRINT_METASPRITE_IDS 0
#endif
#ifndef USE_TILED_LEVELS
  #define USE_TILED_LEVELS 0
#endif

#ifdef __NES__

#ifndef ENABLE_C_CODE
  #define ENABLE_C_CODE 0
#endif
#ifndef USE_CUSTOM_TITLESCREEN
  #define USE_CUSTOM_TITLESCREEN 0
#endif

#else

// This is just here to make things look nicer for code editors
#define ENABLE_C_CODE 1
#define USE_CUSTOM_TITLESCREEN 1

#endif

#endif
