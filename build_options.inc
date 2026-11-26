

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; Easy edit options for controlling the basic feature set available

;; 
;; IMPORTANT TUTORIAL ON HOW TO USE THIS FILE
;;

; Each line will have a setting and a description for what that setting does.
; IF A LINE STARTS WITH A SEMI COLON (;) THEN IT IS A COMMENT AND WILL NOT BE SET
; That means if you see a line that says
;
; MAPPER_MMC5=1
;
; because it has a ; in front of it, it WILL NOT BE ACTIVE
; Putting a ; in front of a line uses the option's default value.

; This file is plain assembly that is included at the top of options.s. Set an option with name=value, for example
; MAPPER_MMC5=1
; Spaces around the equals sign are fine. Most options default to 0.

; If you don't understand what an option means, then its best to ignore it for now. We chose solid defaults
; for each option that will give you the most configurability out of the box without adding too much complexity.


;;;;;;;;;;;;;;;;;;;;;;
; [GENERAL]

; Add in backported features such as new sfx and wind from SMB2J
; NOTE: Not all features are backported yet.
USE_SMB2J_FEATURES=0

; Mapper MMC5 is a more powerful mapper, but may have some compatibility issues with older emulators
; and powerpaks that aren't using the latest mapper set.
; It still has very high compatibility, and with the extra features and audio channels, its the recommended option
MAPPER_MMC5=1

; Mapper MMC3 is the most compatible while still being reasonable feature rich target. Enabling this will reduce
; the amount of CHR available, so its only included for scenarios like making a repro cart and can work around the
; missing features.
MAPPER_MMC3=0

; Enable PowerUps and Flags to spawn on slot others than the special slot (slot 6)
MULTIPLE_POWERUPS_ON_SCREEN=1

; Instead of player animation cycles going 1, 2, 3, 1, 2 ,3 changes them to go backwards
; instead of looping. So for a 3 cycle anim it will do 1, 2, 3, 2, 1, 2, 3, 2, 1
USE_LOOPING_ANIM_CYCLE=0

; Level format. Set to 0 for vanilla levels. LDtk (1) requires a runtime that is not yet implemented.
LEVEL_FORMAT_LDTK=0

; HUD placement. 0: TOP, 1: BOTTOM, 2: SPRITE, 3: NONE. Only TOP is implemented.
HUD_MODE=0

; Reserve this many bytes of battery-backed SRAM starting at $6000 for user save data.
; The engine leaves this area untouched. 0 leaves all 8 KiB available for engine allocations.
USER_SRAM_SIZE=0

;;;;;;;;;;;;;;;;;;;;;;
; [AUDIO]

; ---- MUSIC ----
; Enable one of the follow music engines by uncommenting the one you want to use

; Use the original game audio engine for music
USE_VANILLA_MUSIC=1

; Use the Famistudio engine for music.
; SEE the file `driver_famistudio.s` for more instructions on how to use this
USE_FAMISTUDIO_MUSIC=0


; Use the BHOP engine for Famitracker music playback.
; SEE the file `driver_bhop.s` for more instructions on how to use this
USE_BHOP_MUSIC=0

; When using a custom audio engine with banked dpcm, you will need to specify here how many banks you are using
; If you aren't using DPCM, set it to 0.
; If you are using DPCM but not banked, set it to 1.
; If you are using banked dpcm, set it to however many banks you have.
DPCM_BANK_COUNT=0

; SRAM budgets in bytes for each music driver. Update the applicable budget if driver settings
; increase its memory use so the level importer can account for it.
VANILLA_SRAM_RESERVE=0
FAMISTUDIO_SRAM_RESERVE=139
BHOP_SRAM_RESERVE=292


; ---- SFX ----
; Use the original SFX audio engine.
USE_VANILLA_SFX=1

; Use the custom music engine for SFX. Cannot be used with the vanilla music engine
USE_CUSTOM_ENGINE_SFX=0


; ---- CUSTOM AUDIO CONFIGURATION ----
; If you are using a custom audio engine, then you likely need to add some configuration here too then
; For Famistudio, see `driver_famistudio` for more details. The settings below are for the `disco_mario`
; sample music and will very likely not work for your project.

FAMISTUDIO_USE_FAMITRACKER_TEMPO=1
FAMISTUDIO_USE_VOLUME_TRACK=1
FAMISTUDIO_CFG_DPCM_SUPPORT=1

BHOP_PATTERN_BANKING=1

;;;;;;;;;;;;;;;;;;;;;;
; [MOUSE]

; Enable reading the SNES mouse plugged into port 2 instead of using a second player.
; This will certainly break the vanilla 2 player mode.
USE_MOUSE_SUPPORT=0

; Add a cursor to the screen where the mouse is (pointer is located at the X,Y coord for it)
MOUSE_DISPLAY_CURSOR=0

; Change this option to 2 to read the mouse from the second controller port instead of port 1
; The controller will be read from the other port.
MOUSE_READ_FROM_PORT=1

; 1 or 2 bytes. Change to 2 to allow using the SNES controller extra buttons like L/R
MOUSE_CONFIG_CONTROLLER_SIZE=1
; 1: Allow mouse sensitivity to be clocked. 0: Disable.
MOUSE_CONFIG_SENSITIVITY=0
; Bounds for the mouse (min 1 - max 255) The defaults are provided for a reasonable "on screen" representation
MOUSE_X_MINIMUM=1
MOUSE_X_MAXIMUM=255
MOUSE_Y_MINIMUM=1
MOUSE_Y_MAXIMUM=239

;;;;;;;;;;;;;;;;;;;;;;
; [DEBUG]

; Enable DEBUG_WORLD_SELECT to turn on world select. When in the level loading screen, press b to increase the level number and
; press a to increase the world number.
DEBUG_WORLD_SELECT=1

; Enable to print out all metasprite IDs when compiling. This can be useful to help when debugging
; or need to update the C headers
PRINT_METASPRITE_IDS=0

; DO NOT USE - Adds extra lag for testing frame lag hiding code.
; Set to the value of number of cycles to burn
DEBUG_ADD_EXTRA_LAG=0

; Enable to show a red overlay on the screen that is a visual estimate for how long it took
; to process the frame. The larger the red overlay, the more time it took to process the frame
DEBUG_DISPLAY_VISUAL_FRAMETIME=0
