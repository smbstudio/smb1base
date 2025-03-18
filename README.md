# SMB1Base

## ROM Hacking friendly version of SMB1

### What is this project?

Super Mario Bros. for the NES is a classic game and a popular game for ROM hackers to modify.
This repository is a collection of several new features and patches added to the original game to make
it easier to add new content and expand on what the original was capable of.
The goal is to make it both easy and fun to stretch the boundaries of whats possible when making a
mod for Mario!

### Features

- Easy to build; just run `build.sh` or `build.bat`

- Flexible feature set (check out `options.s` for all available options!)

- Multiple optional audio engines available to allow importing songs from modern tools like Famitracker or Famistudio
  - The latest DN famitracker is supported through bhop (https://github.com/Dn-Programming-Core-Management/Dn-FamiTracker/releases/)
  - Famistudio support is kept up to date with the latest (https://famistudio.org/)
  - Also supports using custom music engines along side the vanilla sound effect engine, since nothing can really replicate the crisp SFX from vanilla better than the vanilla engine.

- New code features including the following:
  - 8x16 sprite mode in use to double the maximum number of sprites on screen
  - New metasprite based rendering code to make it easy to add new enemies and animations to the game
  - Anti-lag code to hide lag frames and get smoother gameplay
  - RAM values are relocatable, making it easy to add new content that needs RAM

- Level data importer for use with tools like Greated or SMBUtil

- Code is split into banks of 8kb with only 16kb of fixed space required.
  - This frees up the $c000 region to be used for banked DPCM

- Minor optimizations for the original game, removing residual code and cleaning up some small oddities

- Optional VSCode integration with the following features
  - Syntax highlighting
  - Inline error reporting (error squigglies you can hover to see whats wrong)
  - Automatic compile on save

### How to use

### Features I want to have someday

- Sooner than later
  - Optional bugfixes for the vanilla game to disable
  - CC65 support (add C headers and callback/hook locations that can call into C code)
- Long term goals
  - Optional Tiled based level data for easily making levels without using vanilla mario data
  - Optional 4-way scrolling for interesting new maps
  - Code changes
    - use popslide for faster VRAM updates
    - increase number of enemy slots
