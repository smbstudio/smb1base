.segment "FIXED"

BlockGfxData:
.byte $47, $47, $48, $48 ;brick with line
.byte $48, $48, $48, $48 ;brick without line
.byte $AE, $AF, $BE, $BF ;used block
.byte $24, $24, $24, $24 ;air
.byte $26, $26, $26, $26 ;air, different color

interactable = 1 ;mtile is interactable
hard = 2 ;mtile is completely hard from below (e.g. 3d solid block) 
climbable = 4 ;mtile is climbable (e.g. residual ball block)

pal0 = 0 << 6
pal1 = 1 << 6
pal2 = 2 << 6
pal3 = 3 << 6

.macro DefineMTile name, topleft, bottomleft, topright, bottomright, attribute
  .ident(name) = (* - Metatile_Definitions) / 4
  .byte topleft, bottomleft, topright, bottomright
  .ident(.concat("ATTR_OF_",name)) = attribute
.endmacro

Metatile_Definitions:
DefineMTile "MT_BLANK", \
  $24, $24, $24, $24, \
  pal0
DefineMTile "MT_BLACK_METATILE", \
  $27, $27, $27, $27, \
  pal0
DefineMTile "MT_BUSH_LEFT", \
  $24, $24, $24, $30, \
  pal0
DefineMTile "MT_BUSH_MIDDLE", \
  $31, $25, $32, $25, \
  pal0
DefineMTile "MT_BUSH_RIGHT", \
  $24, $33, $24, $24, \
  pal0
DefineMTile "MT_MOUNTAIN_LEFT", \
  $24, $34, $34, $26, \
  pal0
DefineMTile "MT_MOUNTAIN_LEFT_BOTTOM_MIDDLE_CENTER", \
  $26, $26, $38, $26, \
  pal0
DefineMTile "MT_MOUNTAIN_MIDDLE_TOP", \
  $24, $35, $24, $36, \
  pal0
DefineMTile "MT_MOUNTAIN_RIGHT", \
  $37, $26, $24, $37, \
  pal0
DefineMTile "MT_MOUNTAIN_RIGHT_BOTTOM", \
  $38, $26, $26, $26, \
  pal0
DefineMTile "MT_MOUNTAIN_MIDDLE_BOTTOM", \
  $26, $26, $26, $26, \
  pal0
DefineMTile "MT_BRIDGE_GUARDRAIL", \
  $24, $44, $24, $44, \
  pal0
DefineMTile "MT_CHAIN", \
  $24, $CF, $CF, $24, \
  pal0
DefineMTile "MT_TALL_TREE_TOP_AND_TOP_HALF", \
  $3E, $4E, $3F, $4F, \
  pal0
DefineMTile "MT_SHORT_TREE_TOP", \
  $3E, $4C, $3F, $4D, \
  pal0
DefineMTile "MT_TALL_TREE_TOP_AND_BOTTOM_HALF", \
  $4E, $4C, $4F, $4D, \
  pal0
DefineMTile "MT_WARP_PIPE_END_LEFT_AND_POINTS_UP", \
  $50, $60, $51, $61, \
  pal0 + interactable + hard
DefineMTile "MT_WARP_PIPE_END_RIGHT_AND_POINTS_UP", \
  $52, $62, $53, $63, \
  pal0 + interactable + hard
DefineMTile "MT_DECORATION_PIPE_END_LEFT_AND_POINTS_UP", \
  $50, $60, $51, $61, \
  pal0 + interactable + hard
DefineMTile "MT_DECORATION_PIPE_END_RIGHT_AND_POINTS_UP", \
  $52, $62, $53, $63, \
  pal0 + interactable + hard
DefineMTile "MT_PIPE_SHAFT_LEFT", \
  $70, $70, $71, $71, \
  pal0 + interactable + hard
DefineMTile "MT_PIPE_SHAFT_RIGHT", \
  $26, $26, $72, $72, \
  pal0 + interactable + hard
DefineMTile "MT_TREE_LEDGE_LEFT_EDGE", \
  $59, $69, $5A, $6A, \
  pal0 + interactable + hard
DefineMTile "MT_TREE_LEDGE_MIDDLE", \
  $5A, $6C, $5A, $6C, \
  pal0 + interactable + hard
DefineMTile "MT_TREE_LEDGE_RIGHT_EDGE", \
  $5A, $6A, $5B, $6B, \
  pal0 + interactable + hard
DefineMTile "MT_MUSHROOM_LEFT_EDGE", \
  $A0, $B0, $A1, $B1, \
  pal0 + interactable + hard
DefineMTile "MT_MUSHROOM_MIDDLE", \
  $A2, $B2, $A3, $B3, \
  pal0 + interactable + hard
DefineMTile "MT_MUSHROOM_RIGHT_EDGE", \
  $A4, $B4, $A5, $B5, \
  pal0 + interactable + hard
DefineMTile "MT_SIDEWAYS_PIPE_END_TOP", \
  $54, $64, $55, $65, \
  pal0 + interactable + hard
DefineMTile "MT_SIDEWAYS_PIPE_SHAFT_TOP", \
  $56, $66, $56, $66, \
  pal0 + interactable + hard
DefineMTile "MT_SIDEWAYS_PIPE_JOINT_TOP", \
  $57, $67, $71, $71, \
  pal0 + interactable + hard
DefineMTile "MT_SIDEWAYS_PIPE_END_BOTTOM", \
  $74, $84, $75, $85, \
  pal0 + interactable + hard
DefineMTile "MT_SIDEWAYS_PIPE_SHAFT_BOTTOM", \
  $26, $76, $26, $76, \
  pal0 + interactable + hard
DefineMTile "MT_SIDEWAYS_PIPE_JOINT_BOTTOM", \
  $58, $68, $71, $71, \
  pal0 + interactable + hard
DefineMTile "MT_SEAPLANT", \
  $8C, $9C, $8D, $9D, \
  pal0 + interactable + hard
DefineMTile "MT_BLANK_USED_ON_BRICKS_OR_BLOCKS_THAT_ARE_HIT", \
  $24, $24, $24, $24, \
  pal0 + interactable + hard
DefineMTile "MT_FLAGPOLE_BALL", \
  $24, $5F, $24, $6F, \
  pal0 + interactable + hard + climbable
DefineMTile "MT_FLAGPOLE_SHAFT", \
  $7D, $7D, $7E, $7E, \
  pal0 + interactable + hard + climbable
DefineMTile "MT_BLANK_USED_IN_CONJUNCTION_WITH_VINES", \
  $24, $24, $24, $24, \
  pal0 + interactable + hard + climbable
DefineMTile "MT_VERTICAL_ROPE", \
  $7D, $7D, $7E, $7E, \
  pal1
DefineMTile "MT_HORIZONTAL_ROPE", \
  $5C, $24, $5C, $24, \
  pal1
DefineMTile "MT_LEFT_PULLEY", \
  $24, $7D, $5D, $6D, \
  pal1
DefineMTile "MT_RIGHT_PULLEY", \
  $5E, $6E, $24, $7E, \
  pal1
DefineMTile "MT_BLANK_USED_FOR_BALANCE_ROPE", \
  $24, $24, $24, $24, \
  pal1
DefineMTile "MT_CASTLE_TOP", \
  $77, $48, $78, $48, \
  pal1
DefineMTile "MT_CASTLE_WINDOW_LEFT", \
  $48, $48, $27, $27, \
  pal1
DefineMTile "MT_CASTLE_BRICK_WALL", \
  $48, $48, $48, $48, \
  pal1
DefineMTile "MT_CASTLE_WINDOW_RIGHT", \
  $27, $27, $48, $48, \
  pal1
DefineMTile "MT_CASTLE_TOP_WITH_BRICK", \
  $79, $48, $7A, $48, \
  pal1
DefineMTile "MT_ENTRANCE_TOP", \
  $7B, $27, $7C, $27, \
  pal1
DefineMTile "MT_ENTRANCE_BOTTOM", \
  $27, $27, $27, $27, \
  pal1
DefineMTile "MT_GREEN_LEDGE_STUMP", \
  $73, $73, $73, $73, \
  pal1
DefineMTile "MT_FENCE", \
  $3A, $4A, $3B, $4B, \
  pal1
DefineMTile "MT_TREE_TRUNK", \
  $3C, $3C, $3D, $3D, \
  pal1
DefineMTile "MT_MUSHROOM_STUMP_TOP", \
  $A6, $4E, $A7, $4F, \
  pal1
DefineMTile "MT_MUSHROOM_STUMP_BOTTOM", \
  $4E, $4E, $4F, $4F, \
  pal1
DefineMTile "MT_BREAKABLE_BRICK_WITH_LINE", \
  $47, $48, $47, $48, \
  pal1 + interactable
DefineMTile "MT_BREAKABLE_BRICK", \
  $48, $48, $48, $48, \
  pal1 + interactable
DefineMTile "MT_BREAKABLE_BRICK_NOT_USED", \
  $47, $48, $47, $48, \
  pal1 + interactable
DefineMTile "MT_CRACKED_ROCK_TERRAIN", \
  $82, $92, $83, $93, \
  pal1 + interactable
DefineMTile "MT_BRICK_WITH_LINE_POWER_UP", \
  $47, $48, $47, $48, \
  pal1 + interactable
DefineMTile "MT_BRICK_WITH_LINE_VINE", \
  $47, $48, $47, $48, \
  pal1 + interactable
DefineMTile "MT_BRICK_WITH_LINE_STAR", \
  $47, $48, $47, $48, \
  pal1 + interactable
DefineMTile "MT_BRICK_WITH_LINE_COINS", \
  $47, $48, $47, $48, \
  pal1 + interactable
DefineMTile "MT_BRICK_WITH_LINE_1_UP", \
  $47, $48, $47, $48, \
  pal1 + interactable
DefineMTile "MT_BRICK_POWER_UP", \
  $48, $48, $48, $48, \
  pal1 + interactable
DefineMTile "MT_BRICK_VINE", \
  $48, $48, $48, $48, \
  pal1 + interactable
DefineMTile "MT_BRICK_STAR", \
  $48, $48, $48, $48, \
  pal1 + interactable
DefineMTile "MT_BRICK_COINS", \
  $48, $48, $48, $48, \
  pal1 + interactable
DefineMTile "MT_BRICK_1_UP", \
  $48, $48, $48, $48, \
  pal1 + interactable
DefineMTile "MT_HIDDEN_BLOCK_1_COIN", \
  $24, $24, $24, $24, \
  pal1 + interactable
DefineMTile "MT_HIDDEN_BLOCK_1_UP", \
  $24, $24, $24, $24, \
  pal1 + interactable
DefineMTile "MT_SOLID_BLOCK_3D_BLOCK", \
  $80, $90, $81, $91, \
  pal1 + interactable + hard
DefineMTile "MT_SOLID_BLOCK_WHITE_WALL", \
  $B6, $B7, $B6, $B7, \
  pal1 + interactable + hard
DefineMTile "MT_BRIDGE", \
  $45, $24, $45, $24, \
  pal1 + interactable + hard
DefineMTile "MT_BULLET_BILL_CANNON_BARREL", \
  $86, $96, $87, $97, \
  pal1 + interactable + hard
DefineMTile "MT_BULLET_BILL_CANNON_TOP", \
  $88, $98, $89, $99, \
  pal1 + interactable + hard
DefineMTile "MT_BULLET_BILL_CANNON_BOTTOM", \
  $94, $94, $95, $95, \
  pal1 + interactable + hard
DefineMTile "MT_BLANK_USED_FOR_JUMPSPRING", \
  $24, $24, $24, $24, \
  pal1 + interactable + hard
DefineMTile "MT_HALF_BRICK_USED_FOR_JUMPSPRING", \
  $24, $48, $24, $48, \
  pal1 + interactable + hard
DefineMTile "MT_SOLID_BLOCK_WATER_LEVEL_GREEN_ROCK", \
  $8A, $9A, $8B, $9B, \
  pal1 + interactable + hard
DefineMTile "MT_HALF_BRICK", \
  $24, $48, $24, $48, \
  pal1 + interactable + hard
DefineMTile "MT_WATER_PIPE_TOP", \
  $54, $64, $55, $65, \
  pal1 + interactable + hard
DefineMTile "MT_WATER_PIPE_BOTTOM", \
  $74, $84, $75, $85, \
  pal1 + interactable + hard
DefineMTile "MT_FLAG_BALL_RESIDUAL_OBJECT", \
  $24, $5F, $24, $6F, \
  pal1 + interactable + hard + climbable
DefineMTile "MT_CLOUD_LEFT", \
  $24, $24, $24, $30, \
  pal2
DefineMTile "MT_CLOUD_MIDDLE", \
  $31, $25, $32, $25, \
  pal2
DefineMTile "MT_CLOUD_RIGHT", \
  $24, $33, $24, $24, \
  pal2
DefineMTile "MT_CLOUD_BOTTOM_LEFT", \
  $24, $24, $40, $24, \
  pal2
DefineMTile "MT_CLOUD_BOTTOM_MIDDLE", \
  $41, $24, $42, $24, \
  pal2
DefineMTile "MT_CLOUD_BOTTOM_RIGHT", \
  $43, $24, $24, $24, \
  pal2
DefineMTile "MT_WATER_OR_LAVA_TOP", \
  $46, $26, $46, $26, \
  pal2
DefineMTile "MT_WATER_OR_LAVA", \
  $26, $26, $26, $26, \
  pal2
DefineMTile "MT_CLOUD_LEVEL_TERRAIN", \
  $8E, $9E, $8F, $9F, \
  pal2 + interactable + hard
DefineMTile "MT_BOWSERS_BRIDGE", \
  $39, $49, $39, $49, \
  pal2 + interactable + hard
DefineMTile "MT_QUESTION_BLOCK_COIN", \
  $A8, $B8, $A9, $B9, \
  pal3 + interactable
DefineMTile "MT_QUESTION_BLOCK_POWER_UP", \
  $A8, $B8, $A9, $B9, \
  pal3 + interactable
DefineMTile "MT_COIN", \
  $AA, $BA, $AB, $BB, \
  pal3 + interactable
DefineMTile "MT_UNDERWATER_COIN", \
  $AC, $BC, $AD, $BD, \
  pal3 + interactable
DefineMTile "MT_EMPTY_BLOCK", \
  $AE, $BE, $AF, $BF, \
  pal3 + interactable + hard
DefineMTile "MT_AXE", \
  $CB, $CD, $CC, $CE, \
  pal3 + interactable + hard

Metatile_Attributes:
.byte ATTR_OF_MT_BLANK
.byte ATTR_OF_MT_BLACK_METATILE
.byte ATTR_OF_MT_BUSH_LEFT
.byte ATTR_OF_MT_BUSH_MIDDLE
.byte ATTR_OF_MT_BUSH_RIGHT
.byte ATTR_OF_MT_MOUNTAIN_LEFT
.byte ATTR_OF_MT_MOUNTAIN_LEFT_BOTTOM_MIDDLE_CENTER
.byte ATTR_OF_MT_MOUNTAIN_MIDDLE_TOP
.byte ATTR_OF_MT_MOUNTAIN_RIGHT
.byte ATTR_OF_MT_MOUNTAIN_RIGHT_BOTTOM
.byte ATTR_OF_MT_MOUNTAIN_MIDDLE_BOTTOM
.byte ATTR_OF_MT_BRIDGE_GUARDRAIL
.byte ATTR_OF_MT_CHAIN
.byte ATTR_OF_MT_TALL_TREE_TOP_AND_TOP_HALF
.byte ATTR_OF_MT_SHORT_TREE_TOP
.byte ATTR_OF_MT_TALL_TREE_TOP_AND_BOTTOM_HALF
.byte ATTR_OF_MT_WARP_PIPE_END_LEFT_AND_POINTS_UP
.byte ATTR_OF_MT_WARP_PIPE_END_RIGHT_AND_POINTS_UP
.byte ATTR_OF_MT_DECORATION_PIPE_END_LEFT_AND_POINTS_UP
.byte ATTR_OF_MT_DECORATION_PIPE_END_RIGHT_AND_POINTS_UP
.byte ATTR_OF_MT_PIPE_SHAFT_LEFT
.byte ATTR_OF_MT_PIPE_SHAFT_RIGHT
.byte ATTR_OF_MT_TREE_LEDGE_LEFT_EDGE
.byte ATTR_OF_MT_TREE_LEDGE_MIDDLE
.byte ATTR_OF_MT_TREE_LEDGE_RIGHT_EDGE
.byte ATTR_OF_MT_MUSHROOM_LEFT_EDGE
.byte ATTR_OF_MT_MUSHROOM_MIDDLE
.byte ATTR_OF_MT_MUSHROOM_RIGHT_EDGE
.byte ATTR_OF_MT_SIDEWAYS_PIPE_END_TOP
.byte ATTR_OF_MT_SIDEWAYS_PIPE_SHAFT_TOP
.byte ATTR_OF_MT_SIDEWAYS_PIPE_JOINT_TOP
.byte ATTR_OF_MT_SIDEWAYS_PIPE_END_BOTTOM
.byte ATTR_OF_MT_SIDEWAYS_PIPE_SHAFT_BOTTOM
.byte ATTR_OF_MT_SIDEWAYS_PIPE_JOINT_BOTTOM
.byte ATTR_OF_MT_SEAPLANT
.byte ATTR_OF_MT_BLANK_USED_ON_BRICKS_OR_BLOCKS_THAT_ARE_HIT
.byte ATTR_OF_MT_FLAGPOLE_BALL
.byte ATTR_OF_MT_FLAGPOLE_SHAFT
.byte ATTR_OF_MT_BLANK_USED_IN_CONJUNCTION_WITH_VINES
.byte ATTR_OF_MT_VERTICAL_ROPE
.byte ATTR_OF_MT_HORIZONTAL_ROPE
.byte ATTR_OF_MT_LEFT_PULLEY
.byte ATTR_OF_MT_RIGHT_PULLEY
.byte ATTR_OF_MT_BLANK_USED_FOR_BALANCE_ROPE
.byte ATTR_OF_MT_CASTLE_TOP
.byte ATTR_OF_MT_CASTLE_WINDOW_LEFT
.byte ATTR_OF_MT_CASTLE_BRICK_WALL
.byte ATTR_OF_MT_CASTLE_WINDOW_RIGHT
.byte ATTR_OF_MT_CASTLE_TOP_WITH_BRICK
.byte ATTR_OF_MT_ENTRANCE_TOP
.byte ATTR_OF_MT_ENTRANCE_BOTTOM
.byte ATTR_OF_MT_GREEN_LEDGE_STUMP
.byte ATTR_OF_MT_FENCE
.byte ATTR_OF_MT_TREE_TRUNK
.byte ATTR_OF_MT_MUSHROOM_STUMP_TOP
.byte ATTR_OF_MT_MUSHROOM_STUMP_BOTTOM
.byte ATTR_OF_MT_BREAKABLE_BRICK_WITH_LINE
.byte ATTR_OF_MT_BREAKABLE_BRICK
.byte ATTR_OF_MT_BREAKABLE_BRICK_NOT_USED
.byte ATTR_OF_MT_CRACKED_ROCK_TERRAIN
.byte ATTR_OF_MT_BRICK_WITH_LINE_POWER_UP
.byte ATTR_OF_MT_BRICK_WITH_LINE_VINE
.byte ATTR_OF_MT_BRICK_WITH_LINE_STAR
.byte ATTR_OF_MT_BRICK_WITH_LINE_COINS
.byte ATTR_OF_MT_BRICK_WITH_LINE_1_UP
.byte ATTR_OF_MT_BRICK_POWER_UP
.byte ATTR_OF_MT_BRICK_VINE
.byte ATTR_OF_MT_BRICK_STAR
.byte ATTR_OF_MT_BRICK_COINS
.byte ATTR_OF_MT_BRICK_1_UP
.byte ATTR_OF_MT_HIDDEN_BLOCK_1_COIN
.byte ATTR_OF_MT_HIDDEN_BLOCK_1_UP
.byte ATTR_OF_MT_SOLID_BLOCK_3D_BLOCK
.byte ATTR_OF_MT_SOLID_BLOCK_WHITE_WALL
.byte ATTR_OF_MT_BRIDGE
.byte ATTR_OF_MT_BULLET_BILL_CANNON_BARREL
.byte ATTR_OF_MT_BULLET_BILL_CANNON_TOP
.byte ATTR_OF_MT_BULLET_BILL_CANNON_BOTTOM
.byte ATTR_OF_MT_BLANK_USED_FOR_JUMPSPRING
.byte ATTR_OF_MT_HALF_BRICK_USED_FOR_JUMPSPRING
.byte ATTR_OF_MT_SOLID_BLOCK_WATER_LEVEL_GREEN_ROCK
.byte ATTR_OF_MT_HALF_BRICK
.byte ATTR_OF_MT_WATER_PIPE_TOP
.byte ATTR_OF_MT_WATER_PIPE_BOTTOM
.byte ATTR_OF_MT_FLAG_BALL_RESIDUAL_OBJECT
.byte ATTR_OF_MT_CLOUD_LEFT
.byte ATTR_OF_MT_CLOUD_MIDDLE
.byte ATTR_OF_MT_CLOUD_RIGHT
.byte ATTR_OF_MT_CLOUD_BOTTOM_LEFT
.byte ATTR_OF_MT_CLOUD_BOTTOM_MIDDLE
.byte ATTR_OF_MT_CLOUD_BOTTOM_RIGHT
.byte ATTR_OF_MT_WATER_OR_LAVA_TOP
.byte ATTR_OF_MT_WATER_OR_LAVA
.byte ATTR_OF_MT_CLOUD_LEVEL_TERRAIN
.byte ATTR_OF_MT_BOWSERS_BRIDGE
.byte ATTR_OF_MT_QUESTION_BLOCK_COIN
.byte ATTR_OF_MT_QUESTION_BLOCK_POWER_UP
.byte ATTR_OF_MT_COIN
.byte ATTR_OF_MT_UNDERWATER_COIN
.byte ATTR_OF_MT_EMPTY_BLOCK
.byte ATTR_OF_MT_AXE
