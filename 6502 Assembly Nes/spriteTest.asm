.db "NES",$1A,2,1,0,0,0,0,0,0,0,0,0,0
.define PPUCTRL $2000
.define PPUMASK $2001
.define PPUSTATUS $2002
.define OAMADDR $2003
.define OAMDATA $2004
.define PPUSCROLL $2005
.define PPUADDR $2006
.define PPUDATA $2007
.define PALETTE_BG_0 $3F00
.define PALETTE_CHR_0 $3F10
.define LIGHTBLUE_COLOR $22
.define PURPLE_COLOR $13
.define BLACK_COLOR $3F
.define PINK_COLOR $35
.define SPRITE_X $203
.define SPRITE_Y $200
.define DMA $4014
.define COUNTER $10
.define JOYPAD01 $4016
.define BUTTONS $06

.org $8000
mario_sprites:
  .db $00, $04, $08, $0C
sprites:
  .db $80, $32, $00, $80   
  .db $80, $33, $00, $88   
  .db $88, $34, $00, $80   
  .db $88, $35, $00, $88   
  .db $40, $76, $00, $40
  .db $40, $77, $00, $48
  .db $48, $78, $00, $40
  .db $48, $79, $00, $48



reset:
    ;SET INTERRUPT PER ESSERE SICURO CHE QUANDO AVVIENE IL RESET, GLI INTERRUPT SIANO RESETTATI
    SEI
    ;DISABILITARE MODALITA' DECIMALE (ANCHE SE IL NES NON LO PREVEDEVA)
    CLD
    ;ACCERTARSI CHE LA PPU SIA INIZIALIZZATA
start:
    ;INIZIALIZZO STACK
    LDX #$FF
    TXS

    ;SPENGO NMI
    LDX #%00000000
    STX PPUCTRL
    ;SET PPUMASK
    STX PPUMASK
    LDA #$80
    STA SPRITE_X
    LDA #$80
    STA SPRITE_Y

wait_vblank:
    LDA PPUSTATUS
    AND #%10000000
    BEQ wait_vblank

initialize_background_palette:
    LDA #>PALETTE_BG_0
    STA PPUADDR
    LDA #<PALETTE_BG_0
    STA PPUADDR
    LDA #LIGHTBLUE_COLOR
    STA PPUDATA
    LDA #BLACK_COLOR
    STA PPUDATA
    LDA #PURPLE_COLOR
    STA PPUDATA
    LDA #PINK_COLOR
    STA PPUDATA

initialize_sprites_palette:
    LDA #>PALETTE_CHR_0
    STA PPUADDR
    LDA #<PALETTE_CHR_0
    STA PPUADDR
    LDA #LIGHTBLUE_COLOR
    STA PPUDATA
    LDA #BLACK_COLOR
    STA PPUDATA
    LDA #PURPLE_COLOR
    STA PPUDATA
    LDA #PINK_COLOR
    STA PPUDATA

LDX #%00010000
STX PPUMASK


LoadSprite:
    LDX #$00
LoadSpriteLoop:
    LDA sprites, X
    STA $0200,X
    INX
    CPX #$20
    BNE LoadSpriteLoop

LDX #%10000000
STX PPUCTRL

LDA #$01
STA COUNTER
       
gameloop:
    LDA COUNTER
    BEQ gameloop
    LDA #0
    STA COUNTER

    JSR ReadController1
        ;Controll Type Input
        LDA BUTTONS
        CMP #$00
        BEQ EndInput
        CMP #$01
        BEQ GoRight
        CMP #$02
        BEQ GoLeft
        CMP #$04
        BEQ GoDown
        CMP #$08
        BEQ GoUp
        CMP #$0A
        BEQ GoUpLeft
        CMP #$09
        BEQ GoUpRight
        CMP #$06
        BEQ GoDownLeft
        CMP #$05
        BEQ GoDownRight
        EndInput:
        JMP gameloop

 ;Reset Flag Input
        GoUp:
            LDY #$03
            JSR GoUpLoop
            JMP EndInput
        GoUpLeft:
            LDY #$03
            JSR GoUpLeftLoop
            JMP EndInput
        GoUpRight:
            LDY #$03
            JSR GoUpRightLoop
            JMP EndInput
        GoDown:
            LDY #$03
            JSR GoDownLoop
            JMP EndInput
        GoDownLeft:
            LDY #$03
            JSR GoDownLeftLoop
            JMP EndInput
        GoDownRight:
            LDY #$03
            JSR GoDownRightLoop
            JMP EndInput
        GoLeft:
            LDY #$03
            JSR GoLeftLoop
            JMP EndInput
        GoRight:
            LDY #$03
            JSR GoRightLoop
            JMP EndInput

        GoUpLoop:
            LDX mario_sprites, Y
            DEC SPRITE_Y, X
            DEY 
            BNE GoUpLoop
            DEC SPRITE_Y
            RTS
        GoUpLeftLoop:
            LDX mario_sprites, Y
            DEC SPRITE_Y, X
            DEC SPRITE_X, X
            DEY 
            BNE GoUpLeftLoop
            DEC SPRITE_Y
            DEC SPRITE_X
            RTS
        GoUpRightLoop:
            LDX mario_sprites, Y
            DEC SPRITE_Y, X
            INC SPRITE_X, X
            DEY 
            BNE GoUpRightLoop
            DEC SPRITE_Y
            INC SPRITE_X
            RTS
        GoDownLoop:
            LDX mario_sprites, Y
            INC SPRITE_Y, X
            DEY 
            BNE GoDownLoop
            INC SPRITE_Y
            RTS
        GoDownLeftLoop:
            LDX mario_sprites, Y
            INC SPRITE_Y, X
            DEC SPRITE_X, X
            DEY 
            BNE GoDownLeftLoop
            INC SPRITE_Y
            DEC SPRITE_X
            RTS
         GoDownRightLoop:
            LDX mario_sprites, Y
            INC SPRITE_Y, X
            INC SPRITE_X, X
            DEY 
            BNE GoDownRightLoop
            INC SPRITE_Y
            INC SPRITE_X
            RTS
        GoLeftLoop:
            LDX mario_sprites, Y
            DEC SPRITE_X, X
            DEY 
            BNE GoLeftLoop
            DEC SPRITE_X
            RTS
        GoRightLoop:
            LDX mario_sprites, Y
            INC SPRITE_X, X
            DEY 
            BNE GoRightLoop
            INC SPRITE_X
            RTS
        

    ReadController1:
        LDA #$01
        STA JOYPAD01
        LDA #$00
        STA JOYPAD01
        LDX #$08
    ReadController1Loop:
        LDA JOYPAD01
        LSR A
        ROL BUTTONS
        DEX
        BNE ReadController1Loop
        RTS

nmi:
    LDA #01
    STA COUNTER
    LDA #$02
    STA DMA
    LDA #$00
    STA PPUSCROLL
    LDA #$00
    STA PPUSCROLL

    RTI

irq:
    RTI

.goto $FFFA
.dw nmi ;NMI
.dw reset ;RESET
.dw irq ;IRQ

.org $0000
.incbin "mario0.chr"
.incbin "mario1.chr"