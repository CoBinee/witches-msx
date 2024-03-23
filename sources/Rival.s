; Rival.s : ライバル
;


; モジュール宣言
;
    .module Rival

; 参照ファイル
;
    .include    "bios.inc"
    .include    "vdp.inc"
    .include    "System.inc"
    .include    "App.inc"
    .include    "Game.inc"
    .include	"Rival.inc"

; 外部変数宣言
;

; マクロの定義
;


; CODE 領域
;
    .area   _CODE

; ライバルを初期化する
;
_RivalInitialize::
    
    ; レジスタの保存
    
    ; ライバルの初期化
    ld      hl, #rivalDefault
    ld      de, #_rival
    ld      bc, #RIVAL_LENGTH
    ldir

    ; 状態の設定
    ld      a, #RIVAL_STATE_PLAY
    ld      (_rival + RIVAL_STATE), a
    
    ; レジスタの復帰
    
    ; 終了
    ret

; ライバルを更新する
;
_RivalUpdate::
    
    ; レジスタの保存
    
    ; 状態別の処理
    ld      hl, #10$
    push    hl
    ld      a, (_rival + RIVAL_STATE)
    and     #0xf0
    rrca
    rrca
    rrca
    ld      e, a
    ld      d, #0x00
    ld      hl, #rivalProc
    add     hl, de
    ld      e, (hl)
    inc     hl
    ld      d, (hl)
    ex      de, hl
    jp      (hl)
;   pop     hl
10$:

    ; スプライトの設定
    ld      a, (_rival + RIVAL_DIRECTION)
    add     a, a
    add     a, a
    add     a, a
    ld      e, a
    ld      a, (_rival + RIVAL_ANIMATION)
    and     #0x08
    rrca
    add     a, e
    ld      e, a
    ld      d, #0x00
    ld      hl, #rivalSprite
    add     hl, de
    ld      (_rival + RIVAL_SPRITE_L), hl

    ; レジスタの復帰
    
    ; 終了
    ret

; ライバルを描画する
;
_RivalRender::
    
    ; レジスタの保存
    
    ; ライバルの描画
    ld      de, #(_sprite + GAME_SPRITE_RIVAL)
    ld      hl, (_rival + RIVAL_SPRITE_L)
    ld      a, (_rival + RIVAL_POSITION_Y)
    add     a, (hl)
    ld      (de), a
    inc     hl
    inc     de
    ld      a, (_rival + RIVAL_POSITION_X)
    ld      c, #0x00
    cp      #0x80
    jr      nc, 10$
    ld      c, #0x80
    add     a, #0x20
10$:
    add     a, (hl)
    ld      (de), a
    inc     hl
    inc     de
    ld      a, (hl)
    ld      (de), a
    inc     hl
    inc     de
;   ld      a, (hl)
    ld      a, #VDP_COLOR_LIGHT_BLUE
    or      c
    ld      (de), a
;   inc     hl
;   inc     de
    ld      hl, #(_sprite + GAME_SPRITE_RIVAL + 0x0000)
    ld      de, #(_sprite + GAME_SPRITE_RIVAL + 0x0004)
    ldi
    ldi
    ld      a, (hl)
    add     a, #0x20
    ld      (de), a
    inc     hl
    inc     de
    ld      a, (hl)
    add     a, #(VDP_COLOR_BLACK - VDP_COLOR_LIGHT_BLUE)
    ld      (de), a
;   inc     hl
;   inc     de

    ; レジスタの復帰
    
    ; 終了
    ret

; 何もしない
;
RivalNull:

    ; レジスタの保存

    ; レジスタの復帰

    ; 終了
    ret

; ライバルを操作する
;
RivalPlay:

    ; レジスタの保存

    ; 初期化
    ld      a, (_rival + RIVAL_STATE)
    and     #0x0f
    jr      nz, 09$

    ; 初期化の完了
    ld      hl, #(_rival + RIVAL_STATE)
    inc     (hl)
09$:

    ; 左右の移動
    ld      hl, #(_rival + RIVAL_POSITION_X)
    ld      a, (_rival + RIVAL_SPEED_X)
    or      a
    jp      p, 10$
    neg
    add     a, #0x08
    and     #0xf0
    rrca
    rrca
    rrca
    rrca
    ld      c, a
    ld      a, (hl)
    sub     c
    jr      nc, 18$
    ld      a, #RIVAL_SPEED_X_MAXIMUM
    ld      (_rival + RIVAL_SPEED_X), a
    ld      a, #RIVAL_DIRECTION_R
    ld      (_rival + RIVAL_DIRECTION), a
    xor     a
    jr      18$
10$:
    add     a, #0x08
    and     #0xf0
    rrca
    rrca
    rrca
    rrca
    add     a, (hl)
    jr      nc, 18$
    ld      a, #-RIVAL_SPEED_X_MAXIMUM
    ld      (_rival + RIVAL_SPEED_X), a
    ld      a, #RIVAL_DIRECTION_L
    ld      (_rival + RIVAL_DIRECTION), a
    ld      a, #RIVAL_POSITION_RIGHT
;   jr      18$
18$:
    ld      (hl), a
;   jr      19$
19$:

    ; 上下の移動
    ld      hl, #(_rival + RIVAL_SPEED_Y)
    ld      de, #(_rival + RIVAL_ACCEL_Y)
    ld      a, (de)
    add     a, (hl)
    ld      (hl), a
    jp      p, 20$
    cp      #-RIVAL_SPEED_Y_MAXIMUM
    jr      nc, 21$
    ld      a, #RIVAL_ACCEL_Y_MAXIMUM
    ld      (de), a
    jr      21$
20$:
    cp      #(RIVAL_SPEED_Y_MAXIMUM + 0x01)
    jr      c, 21$
    ld      a, #-RIVAL_ACCEL_Y_MAXIMUM
    ld      (de), a
;   jr      21$
21$:
    ld      a, (hl)
    ld      hl, #(_rival + RIVAL_POSITION_Y)
    or      a
    jp      p, 22$
    neg
    add     a, #0x08
    and     #0xf0
    rrca
    rrca
    rrca
    rrca
    ld      c, a
    ld      a, (hl)
    sub     c
    jr      28$
22$:
    add     a, #0x08
    and     #0xf0
    rrca
    rrca
    rrca
    rrca
    add     a, (hl)
;   jr      28$
28$:
    ld      (hl), a
;   jr      29$
29$:

    ; アニメーションの更新
    ld      hl, #(_rival + RIVAL_ANIMATION)
    inc     (hl)

    ; レジスタの復帰

    ; 終了
    ret

; 定数の定義
;

; 状態別の処理
;
rivalProc:
    
    .dw     RivalNull
    .dw     RivalPlay

; ゲームの初期値
;
rivalDefault:

    .db     RIVAL_STATE_NULL
    .db     RIVAL_FLAG_NULL
    .db     0xc0 ; RIVAL_POSITION_NULL
    .db     0x20 ; RIVAL_POSITION_NULL
    .db     -RIVAL_SPEED_X_MAXIMUM ; RIVAL_SPEED_NULL
    .db     RIVAL_SPEED_Y_MAXIMUM ; RIVAL_SPEED_NULL
    .db     RIVAL_ACCEL_NULL
    .db     -RIVAL_ACCEL_Y_MAXIMUM ; RIVAL_ACCEL_NULL
    .db     RIVAL_DIRECTION_L
    .db     RIVAL_ANIMATION_NULL
    .dw     RIVAL_SPRITE_NULL

; スプライト
;
rivalSprite:

    .db     -0x08 - 0x01, -0x08, 0x30, VDP_COLOR_TRANSPARENT
    .db     -0x08 - 0x01, -0x08, 0x34, VDP_COLOR_TRANSPARENT
    .db     -0x08 - 0x01, -0x08, 0x38, VDP_COLOR_TRANSPARENT
    .db     -0x08 - 0x01, -0x08, 0x3c, VDP_COLOR_TRANSPARENT


; DATA 領域
;
    .area   _DATA

; 変数の定義
;

; ライバル
;
_rival::
    
    .ds     RIVAL_LENGTH
