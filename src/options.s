
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
  .elseif .not ((.ident(.string(name))=1) .or (.ident(.string(name))=0))
    ; if you get this error then you've set a boolean config option to something other than 0 or 1
    .error .sprintf("Boolean Option `%s` was set to a value other than 0 or 1", .string(name))
    .fatal "Invalid Options selected"
  .endif
  .ifdef PRINT_OPTIONS_FOR_C
    .if PRINT_OPTIONS_FOR_C
      .out .sprintf("#ifndef %s", .string(name))
      .out .sprintf("  #define %s %d", .string(name), DefaultVal)
      .out "#endif"
    .endif
  .endif
.endmacro

.macro num_option name, default
; Dumb work around to check if something is numeric
.local Num, DefaultVal
Num = 123
  .ifnblank default
  DefaultVal .set default
  .else
  DefaultVal .set 0
  .endif
  .if .not .defined(.ident(.string(name)))
    .ident(.string(name)) .set DefaultVal
    ; Check if its numeric
    ; match only checks that the types are the same between the two tokens.
  .elseif .not ( .match ( {.ident(.string(name))}, Num ) )
    ; if you get this error then you've set a numeric config option to something other than a number
    .error .sprintf("Number Option `%s` was set to a non numeric value %d", .string(name), .ident(.string(name)))
    .fatal "Invalid Options selected"
  .endif
  .ifdef PRINT_OPTIONS_FOR_C
    .if PRINT_OPTIONS_FOR_C
      .out .sprintf("#ifndef %s", .string(name))
      .out .sprintf("  #define %s %d", .string(name), DefaultVal)
      .out "#endif"
    .endif
  .endif
.endmacro

bool_option MAPPER_MMC3
bool_option MAPPER_MMC5
bool_option USE_SMB2J_FEATURES
bool_option ENABLE_C_CODE
bool_option USE_CUSTOM_TITLESCREEN
bool_option MULTIPLE_POWERUPS_ON_SCREEN
bool_option USE_LOOPING_ANIM_CYCLE
bool_option USE_MOUSE_SUPPORT


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

; Force disable mouse curose if mouse is not enabled
.if USE_MOUSE_SUPPORT = 0 && MOUSE_DISPLAY_CURSOR <> 0
  .error "Cannot display cursor without mouse support enabled"
  .fatal "Invalid Options selected"
.endif

; verify debug options

