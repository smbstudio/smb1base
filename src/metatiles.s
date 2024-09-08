.segment "RENDER"

BlockGfxData:
.byte $47, $47, $48, $48 ;brick with line
.byte $48, $48, $48, $48 ;brick without line
.byte $AE, $AF, $BE, $BF ;used block
.byte $24, $24, $24, $24 ;air
.byte $26, $26, $26, $26 ;air, different color

pal0 = 0 << 6
pal1 = 1 << 6
pal2 = 2 << 6
pal3 = 3 << 6

Metatile_Definitions:
.byte $24, $24, $24, $24 ;blank
.byte $27, $27, $27, $27 ;black metatile
.byte $24, $24, $24, $30 ;bush left
.byte $31, $25, $32, $25 ;bush middle
.byte $24, $33, $24, $24 ;bush right
.byte $24, $34, $34, $26 ;mountain left
.byte $26, $26, $38, $26 ;mountain left bottom/middle center
.byte $24, $35, $24, $36 ;mountain middle top
.byte $37, $26, $24, $37 ;mountain right
.byte $38, $26, $26, $26 ;mountain right bottom
.byte $26, $26, $26, $26 ;mountain middle bottom
.byte $24, $44, $24, $44 ;bridge guardrail
.byte $24, $CF, $CF, $24 ;chain
.byte $3E, $4E, $3F, $4F ;tall tree top, top half
.byte $3E, $4C, $3F, $4D ;short tree top
.byte $4E, $4C, $4F, $4D ;tall tree top, bottom half
.byte $50, $60, $51, $61 ;warp pipe end left, points up
.byte $52, $62, $53, $63 ;warp pipe end right, points up
.byte $50, $60, $51, $61 ;decoration pipe end left, points up
.byte $52, $62, $53, $63 ;decoration pipe end right, points up
.byte $70, $70, $71, $71 ;pipe shaft left
.byte $26, $26, $72, $72 ;pipe shaft right
.byte $59, $69, $5A, $6A ;tree ledge left edge
.byte $5A, $6C, $5A, $6C ;tree ledge middle
.byte $5A, $6A, $5B, $6B ;tree ledge right edge
.byte $A0, $B0, $A1, $B1 ;mushroom left edge
.byte $A2, $B2, $A3, $B3 ;mushroom middle
.byte $A4, $B4, $A5, $B5 ;mushroom right edge
.byte $54, $64, $55, $65 ;sideways pipe end top
.byte $56, $66, $56, $66 ;sideways pipe shaft top
.byte $57, $67, $71, $71 ;sideways pipe joint top
.byte $74, $84, $75, $85 ;sideways pipe end bottom
.byte $26, $76, $26, $76 ;sideways pipe shaft bottom
.byte $58, $68, $71, $71 ;sideways pipe joint bottom
.byte $8C, $9C, $8D, $9D ;seaplant
.byte $24, $24, $24, $24 ;blank, used on bricks or blocks that are hit
.byte $24, $5F, $24, $6F ;flagpole ball
.byte $7D, $7D, $7E, $7E ;flagpole shaft
.byte $24, $24, $24, $24 ;blank, used in conjunction with vines
.byte $7D, $7D, $7E, $7E ;vertical rope
.byte $5C, $24, $5C, $24 ;horizontal rope
.byte $24, $7D, $5D, $6D ;left pulley
.byte $5E, $6E, $24, $7E ;right pulley
.byte $24, $24, $24, $24 ;blank used for balance rope
.byte $77, $48, $78, $48 ;castle top
.byte $48, $48, $27, $27 ;castle window left
.byte $48, $48, $48, $48 ;castle brick wall
.byte $27, $27, $48, $48 ;castle window right
.byte $79, $48, $7A, $48 ;castle top w/ brick
.byte $7B, $27, $7C, $27 ;entrance top
.byte $27, $27, $27, $27 ;entrance bottom
.byte $73, $73, $73, $73 ;green ledge stump
.byte $3A, $4A, $3B, $4B ;fence
.byte $3C, $3C, $3D, $3D ;tree trunk
.byte $A6, $4E, $A7, $4F ;mushroom stump top
.byte $4E, $4E, $4F, $4F ;mushroom stump bottom
.byte $47, $48, $47, $48 ;breakable brick w/ line 
.byte $48, $48, $48, $48 ;breakable brick 
.byte $47, $48, $47, $48 ;breakable brick (not used)
.byte $82, $92, $83, $93 ;cracked rock terrain
.byte $47, $48, $47, $48 ;brick with line (power-up)
.byte $47, $48, $47, $48 ;brick with line (vine)
.byte $47, $48, $47, $48 ;brick with line (star)
.byte $47, $48, $47, $48 ;brick with line (coins)
.byte $47, $48, $47, $48 ;brick with line (1-up)
.byte $48, $48, $48, $48 ;brick (power-up)
.byte $48, $48, $48, $48 ;brick (vine)
.byte $48, $48, $48, $48 ;brick (star)
.byte $48, $48, $48, $48 ;brick (coins)
.byte $48, $48, $48, $48 ;brick (1-up)
.byte $24, $24, $24, $24 ;hidden block (1 coin)
.byte $24, $24, $24, $24 ;hidden block (1-up)
.byte $80, $90, $81, $91 ;solid block (3-d block)
.byte $B6, $B7, $B6, $B7 ;solid block (white wall)
.byte $45, $24, $45, $24 ;bridge
.byte $86, $96, $87, $97 ;bullet bill cannon barrel
.byte $88, $98, $89, $99 ;bullet bill cannon top
.byte $94, $94, $95, $95 ;bullet bill cannon bottom
.byte $24, $24, $24, $24 ;blank used for jumpspring
.byte $24, $48, $24, $48 ;half brick used for jumpspring
.byte $8A, $9A, $8B, $9B ;solid block (water level, green rock)
.byte $24, $48, $24, $48 ;half brick (???)
.byte $54, $64, $55, $65 ;water pipe top
.byte $74, $84, $75, $85 ;water pipe bottom
.byte $24, $5F, $24, $6F ;flag ball (residual object)
.byte $24, $24, $24, $30 ;cloud left
.byte $31, $25, $32, $25 ;cloud middle
.byte $24, $33, $24, $24 ;cloud right
.byte $24, $24, $40, $24 ;cloud bottom left
.byte $41, $24, $42, $24 ;cloud bottom middle
.byte $43, $24, $24, $24 ;cloud bottom right
.byte $46, $26, $46, $26 ;water/lava top
.byte $26, $26, $26, $26 ;water/lava
CLOUD_MT = $80 + (* - Metatile_Definitions) / 4
.byte $8E, $9E, $8F, $9F ;cloud level terrain
BRIDGE_MT = $80 + (* - Metatile_Definitions) / 4
.byte $39, $49, $39, $49 ;bowser's bridge
.byte $A8, $B8, $A9, $B9 ;question block (coin)
.byte $A8, $B8, $A9, $B9 ;question block (power-up)
.byte $AA, $BA, $AB, $BB ;coin
.byte $AC, $BC, $AD, $BD ;underwater coin
.byte $AE, $BE, $AF, $BF ;empty block
.byte $CB, $CD, $CC, $CE ;axe

Metatile_Attributes:
.byte pal0 ;blank
.byte pal0 ;black metatile
.byte pal0 ;bush left
.byte pal0 ;bush middle
.byte pal0 ;bush right
.byte pal0 ;mountain left
.byte pal0 ;mountain left bottom/middle center
.byte pal0 ;mountain middle top
.byte pal0 ;mountain right
.byte pal0 ;mountain right bottom
.byte pal0 ;mountain middle bottom
.byte pal0 ;bridge guardrail
.byte pal0 ;chain
.byte pal0 ;tall tree top, top half
.byte pal0 ;short tree top
.byte pal0 ;tall tree top, bottom half
.byte pal0 ;warp pipe end left, points up
.byte pal0 ;warp pipe end right, points up
.byte pal0 ;decoration pipe end left, points up
.byte pal0 ;decoration pipe end right, points up
.byte pal0 ;pipe shaft left
.byte pal0 ;pipe shaft right
.byte pal0 ;tree ledge left edge
.byte pal0 ;tree ledge middle
.byte pal0 ;tree ledge right edge
.byte pal0 ;mushroom left edge
.byte pal0 ;mushroom middle
.byte pal0 ;mushroom right edge
.byte pal0 ;sideways pipe end top
.byte pal0 ;sideways pipe shaft top
.byte pal0 ;sideways pipe joint top
.byte pal0 ;sideways pipe end bottom
.byte pal0 ;sideways pipe shaft bottom
.byte pal0 ;sideways pipe joint bottom
.byte pal0 ;seaplant
.byte pal0 ;blank, used on bricks or blocks that are hit
.byte pal0 ;flagpole ball
.byte pal0 ;flagpole shaft
.byte pal0 ;blank, used in conjunction with vines
.byte pal1 ;vertical rope
.byte pal1 ;horizontal rope
.byte pal1 ;left pulley
.byte pal1 ;right pulley
.byte pal1 ;blank used for balance rope
.byte pal1 ;castle top
.byte pal1 ;castle window left
.byte pal1 ;castle brick wall
.byte pal1 ;castle window right
.byte pal1 ;castle top w/ brick
.byte pal1 ;entrance top
.byte pal1 ;entrance bottom
.byte pal1 ;green ledge stump
.byte pal1 ;fence
.byte pal1 ;tree trunk
.byte pal1 ;mushroom stump top
.byte pal1 ;mushroom stump bottom
.byte pal1 ;breakable brick w/ line 
.byte pal1 ;breakable brick 
.byte pal1 ;breakable brick (not used)
.byte pal1 ;cracked rock terrain
.byte pal1 ;brick with line (power-up)
.byte pal1 ;brick with line (vine)
.byte pal1 ;brick with line (star)
.byte pal1 ;brick with line (coins)
.byte pal1 ;brick with line (1-up)
.byte pal1 ;brick (power-up)
.byte pal1 ;brick (vine)
.byte pal1 ;brick (star)
.byte pal1 ;brick (coins)
.byte pal1 ;brick (1-up)
.byte pal1 ;hidden block (1 coin)
.byte pal1 ;hidden block (1-up)
.byte pal1 ;solid block (3-d block)
.byte pal1 ;solid block (white wall)
.byte pal1 ;bridge
.byte pal1 ;bullet bill cannon barrel
.byte pal1 ;bullet bill cannon top
.byte pal1 ;bullet bill cannon bottom
.byte pal1 ;blank used for jumpspring
.byte pal1 ;half brick used for jumpspring
.byte pal1 ;solid block (water level, green rock)
.byte pal1 ;half brick (???)
.byte pal1 ;water pipe top
.byte pal1 ;water pipe bottom
.byte pal1 ;slope indicator
.byte pal1 ;flag ball (residual object) 
.byte pal2 ;cloud left
.byte pal2 ;cloud middle
.byte pal2 ;cloud right
.byte pal2 ;cloud bottom left
.byte pal2 ;cloud bottom middle
.byte pal2 ;cloud bottom right
.byte pal2 ;water/lava top
.byte pal2 ;water/lava
.byte pal2 ;cloud level terrain
.byte pal2 ;bowser's bridge
.byte pal3 ;question block (coin)
.byte pal3 ;question block (power-up)
.byte pal3 ;coin
.byte pal3 ;underwater coin
.byte pal3 ;empty block
.byte pal3 ;axe
