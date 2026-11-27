.include "build_options.inc"


;;;;;;;;;;;;;;;;;;;
; Internal validation for the options. If you see one of these error messages, you need to follow the instructions and
; update the options above.

.macro bool_option name, default
.local DefaultVal
  .ifnblank default
  DefaultVal .set default
  .else
  DefaultVal .set 0
  .endif
  .if .not .defined(.ident(.string(name)))
    .ident(.string(name)) .set DefaultVal
  .elseif .not .const(.ident(.string(name)))
    .error .sprintf("Boolean Option `%s` must be a numeric constant", .string(name))
    .fatal "Invalid Options selected"
  .elseif .not ((.ident(.string(name))=1) .or (.ident(.string(name))=0))
    ; if you get this error then you've set a boolean config option to something other than 0 or 1
    .error .sprintf("Boolean Option `%s` was set to a value other than 0 or 1", .string(name))
    .fatal "Invalid Options selected"
  .endif
.endmacro

.macro num_option name, default
.local DefaultVal
  .ifnblank default
  DefaultVal .set default
  .else
  DefaultVal .set 0
  .endif
  .if .not .defined(.ident(.string(name)))
    .ident(.string(name)) .set DefaultVal
  .elseif .not .const(.ident(.string(name)))
    .error .sprintf("Number Option `%s` must be a numeric constant", .string(name))
    .fatal "Invalid Options selected"
  .endif
.endmacro

bool_option MAPPER_MMC3
bool_option MAPPER_MMC5
bool_option USE_SMB2J_FEATURES
bool_option MULTIPLE_POWERUPS_ON_SCREEN
bool_option USE_LOOPING_ANIM_CYCLE
bool_option USE_MOUSE_SUPPORT

bool_option LEVEL_FORMAT_LDTK
num_option HUD_MODE
num_option USER_SRAM_SIZE


num_option MOUSE_CONFIG_CONTROLLER_SIZE
num_option MOUSE_READ_FROM_PORT
bool_option MOUSE_CONFIG_SENSITIVITY
bool_option MOUSE_DISPLAY_CURSOR
num_option MOUSE_X_MINIMUM
num_option MOUSE_X_MAXIMUM
num_option MOUSE_Y_MINIMUM
num_option MOUSE_Y_MAXIMUM

bool_option USE_MMC5_AUDIO
bool_option USE_VRC7_AUDIO
bool_option USE_VANILLA_MUSIC
bool_option USE_FAMISTUDIO_MUSIC
bool_option USE_BHOP_MUSIC

bool_option USE_VANILLA_SFX
bool_option USE_CUSTOM_ENGINE_SFX
num_option DPCM_BANK_COUNT
num_option VANILLA_SRAM_RESERVE
num_option FAMISTUDIO_SRAM_RESERVE, 139
num_option BHOP_SRAM_RESERVE, 292

bool_option DEBUG_WORLD_SELECT
bool_option PRINT_METASPRITE_IDS
num_option DEBUG_ADD_EXTRA_LAG
bool_option DEBUG_DISPLAY_VISUAL_FRAMETIME

; Verify mapper selection

.if MAPPER_MMC3 + MAPPER_MMC5 > 1
  ; Check that `MAPPER_MMC3` and `MAPPER_MMC5` aren't both uncommented and that only one of them are set to 1
  .error "Multiple mappers selected at the same time! Only one mapper can be chosen at once"
  .fatal "Invalid Options selected"
.endif

.if MAPPER_MMC3 + MAPPER_MMC5=0
  ; Check that exactly one mapper option is uncommented and that it is set to 1
  .error "Must select one of MAPPER_MMC3 or MAPPER_MMC5"
  .fatal "Invalid Options selected"
.endif

; verify audio options

.if (.not MAPPER_MMC5) .and USE_MMC5_AUDIO
  ; Either disable USE_MMC5_AUDIO or switch to using MAPPER_MMC5 for this feature to work
  .error "Cannot use MMC5 Audio channels if the mapper isn't MMC5"
  .fatal "Invalid Options selected"
.endif

.if (.not USE_VANILLA_MUSIC) .and (.not USE_FAMISTUDIO_MUSIC) .and (.not USE_BHOP_MUSIC)
  .error "Must select at least one audio engine. Either VANILLA or FAMISTUDIO"
  .fatal "Invalid Options selected"
.endif

.if LEVEL_FORMAT_LDTK
  .error "LEVEL_FORMAT_LDTK=1: LDtk runtime not yet implemented"
  .fatal "Invalid Options selected"
.endif

HUD_TOP = 0
HUD_BOTTOM = 1
HUD_SPRITE = 2
HUD_NONE = 3

.if HUD_MODE < HUD_TOP .or HUD_MODE > HUD_NONE
  .error "HUD_MODE must be in the range 0 to 3 (TOP, BOTTOM, SPRITE, NONE)"
  .fatal "Invalid Options selected"
.elseif HUD_MODE > HUD_BOTTOM
  .error "HUD_MODE: SPRITE and NONE are not yet implemented"
  .fatal "Invalid Options selected"
.endif

.macro sram_size_option name
  .if name < 0 .or name > $2000
    .error .sprintf("%s must be in the range 0 to 8192 bytes", .string(name))
    .fatal "Invalid Options selected"
  .endif
.endmacro

sram_size_option USER_SRAM_SIZE
sram_size_option VANILLA_SRAM_RESERVE
sram_size_option FAMISTUDIO_SRAM_RESERVE
sram_size_option BHOP_SRAM_RESERVE

; Force disable mouse curose if mouse is not enabled
.if USE_MOUSE_SUPPORT = 0 && MOUSE_DISPLAY_CURSOR <> 0
  .error "Cannot display cursor without mouse support enabled"
  .fatal "Invalid Options selected"
.endif

; verify debug options

