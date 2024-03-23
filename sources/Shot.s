; Shot.s : ショット
;


; モジュール宣言
;
    .module Shot

; 参照ファイル
;
    .include    "bios.inc"
    .include    "vdp.inc"
    .include    "System.inc"
    .include    "App.inc"
    .include    "Game.inc"
    .include    "Back.inc"
    .include	"Shot.inc"

; 外部変数宣言
;

; マクロの定義
;


; CODE 領域
;
    .area   _CODE

; ショットを初期化する
;
_ShotInitialize::
    
    ; レジスタの保存
    
    ; ショットの初期化
    ld      hl, #(_shot + 0x0000)
    ld      de, #(_shot + 0x0001)
    ld      bc, #(SHOT_LENGTH * SHOT_ENTRY - 0x0001)
    ld      (hl), #0x00
    ldir

    ; スプライトの初期化
    xor     a
    ld      (shotSpriteRotation), a

    ; レジスタの復帰
    
    ; 終了
    ret

; ショットを更新する
;
_ShotUpdate::
    
    ; レジスタの保存
    
    ; ショットの走査
    ld      ix, #_shot
    ld      b, #SHOT_ENTRY
10$:
    push    bc
    ld      a, SHOT_STATE(ix)
    or      a
    jr      z, 19$
    and     #0x0f
    jr      nz, 11$
    inc     SHOT_STATE(ix)
    jr      19$

    ; 移動
11$:
    ld      a, SHOT_SPEED_X(ix)
    or      a
    jp      p, 12$
    neg
    ld      c, a
    ld      a, SHOT_POSITION_X(ix)
    sub     c
    jr      c, 18$
    jr      13$
12$:
    add     a, SHOT_POSITION_X(ix)
    jr      c, 18$
;   jr      13$
13$:
    ld      SHOT_POSITION_X(ix), a
    ld      a, SHOT_SPEED_Y(ix)
    add     a, SHOT_POSITION_Y(ix)
    cp      #0xa0
    jr      nc, 18$
    ld      SHOT_POSITION_Y(ix), a

    ; アニメーションの更新
    inc     SHOT_ANIMATION(ix)
    jr      19$

    ; ショットの削除
18$:
    ld      SHOT_STATE(ix), #SHOT_STATE_NULL

    ; 次のショットへ
19$:
    ld      bc, #SHOT_LENGTH
    add     ix, bc
    pop     bc
    djnz    10$

    ; スプライトの更新
    ld      hl, #shotSpriteRotation
    ld      a, (hl)
    add     a, #0x04
    and     #(0x04 * SHOT_ENTRY - 0x01)
    ld      (hl), a

    ; レジスタの復帰
    
    ; 終了
    ret

; ショットを描画する
;
_ShotRender::
    
    ; レジスタの保存
    
    ; スプライトの描画
    ld      a, (shotSpriteRotation)
    ld      e, a
    ld      d, #0x00
    ld      ix, #_shot
    ld      b, #SHOT_ENTRY
10$:
    push    bc
    ld      a, SHOT_STATE(ix)
    or      a
    jr      z, 19$
    push    de
    ld      hl, #(_sprite + GAME_SPRITE_SHOT)
    add     hl, de
    ex      de, hl
    ld      a, SHOT_ANIMATION(ix)
    and     #0x0e
;   add     a, a
    add     a, a
    ld      c, a
    ld      b, #0x00
    ld      hl, #shotSprite
    add     hl, bc
    ld      a, SHOT_POSITION_Y(ix)
    add     a, (hl)
    ld      (de), a
    inc     hl
    inc     de
    ld      a, SHOT_POSITION_X(ix)
    ld      c, #0x00
    cp      #0x80
    jr      nc, 11$
    ld      c, #0x80
    add     a, #0x20
11$:
    add     a, (hl)
    ld      (de), a
    inc     hl
    inc     de
    ld      a, (hl)
    ld      (de), a
    inc     hl
    inc     de
    ld      a, (hl)
    or      c
    ld      (de), a
;   inc     hl
;   inc     de
    pop     de
    ld      a, e
    add     a, #0x04
    and     #(0x04 * SHOT_ENTRY - 0x01)
    ld      e, a
19$:
    ld      bc, #SHOT_LENGTH
    add     ix, bc
    pop     bc
    djnz    10$

    ; レジスタの復帰
    
    ; 終了
    ret

; ショットを撃つ
;
_ShotFire::

    ; レジスタの保存
    push    hl
    push    bc
    push    de
    push    ix

    ; de < Y/X 位置
    ; c  < 向き

    ; ショットの登録
    ex      de, hl
    ld      ix, #_shot
    ld      de, #SHOT_LENGTH
    ld      b, #SHOT_ENTRY
10$:
    ld      a, SHOT_STATE(ix)
    or      a
    jr      z, 11$
    add     ix, de
    djnz    10$
    jr      19$
11$:
    ld      SHOT_STATE(ix), #SHOT_STATE_FIRE
    ld      SHOT_POSITION_X(ix), l
    ld      SHOT_POSITION_Y(ix), h
    ld      a, c
    add     a, a
    ld      e, a
    ld      d, #0x00
    ld      hl, #shotSpeed
    add     hl, de
    ld      a, (hl)
    ld      SHOT_SPEED_X(ix), a
    inc     hl
    ld      a, (hl)
    ld      SHOT_SPEED_Y(ix), a
;   inc     hl
;   ld      SHOT_ANIMATION(ix), #0x00
;   jr      19$
19$:

    ; レジスタの復帰
    pop     ix
    pop     de
    pop     bc
    pop     hl

    ; 終了
    ret

; 狙いを描画する
;
_ShotPrintAim::

    ; レジスタの保存
    push    hl
    push    bc
    push    de

    ; de < スプライト
    ; bc < Y/X 位置
    ; a  < アニメーション

    ; スプライトの描画
    push    de
    push    bc
    and     #0x0e
;   add     a, a
    add     a, a
    ld      e, a
    ld      d, #0x00
    ld      hl, #shotSprite
    add     hl, de
    pop     de
    call    _BackIsLight
    jr      c, 10$
    ld      de, #0x0020
    add     hl, de
10$:
    pop     de
    ld      a, b
    add     a, (hl)
    ld      (de), a
    inc     hl
    inc     de
    ld      a, c
    ld      b, #0x00
    cp      #0x80
    jr      nc, 11$
    ld      b, #0x80
    add     a, #0x20
11$:
    add     a, (hl)
    ld      (de), a
    inc     hl
    inc     de
    ld      a, (hl)
    ld      (de), a
    inc     hl
    inc     de
    ld      a, (hl)
    or      b
    ld      (de), a
;   inc     hl
;   inc     de

    ; レジスタの復帰
    pop     de
    pop     bc
    pop     hl
    
    ; 終了
    ret

; 定数の定義
;

; スプライト
;
shotSprite:

    ; on LIGHT
    .db     -0x08 - 0x01, -0x08, 0x0c, VDP_COLOR_BLACK
    .db     -0x08 - 0x01, -0x08, 0x10, VDP_COLOR_BLACK
    .db     -0x08 - 0x01, -0x08, 0x14, VDP_COLOR_BLACK
    .db     -0x08 - 0x01, -0x08, 0x10, VDP_COLOR_BLACK
    .db     -0x08 - 0x01, -0x08, 0x0c, VDP_COLOR_BLACK
    .db     -0x08 - 0x01, -0x08, 0x18, VDP_COLOR_BLACK
    .db     -0x08 - 0x01, -0x08, 0x1c, VDP_COLOR_BLACK
    .db     -0x08 - 0x01, -0x08, 0x18, VDP_COLOR_BLACK
    ; on DARK
    .db     -0x08 - 0x01, -0x08, 0x0c, VDP_COLOR_LIGHT_BLUE
    .db     -0x08 - 0x01, -0x08, 0x10, VDP_COLOR_LIGHT_BLUE
    .db     -0x08 - 0x01, -0x08, 0x14, VDP_COLOR_LIGHT_BLUE
    .db     -0x08 - 0x01, -0x08, 0x10, VDP_COLOR_LIGHT_BLUE
    .db     -0x08 - 0x01, -0x08, 0x0c, VDP_COLOR_LIGHT_BLUE
    .db     -0x08 - 0x01, -0x08, 0x18, VDP_COLOR_LIGHT_BLUE
    .db     -0x08 - 0x01, -0x08, 0x1c, VDP_COLOR_LIGHT_BLUE
    .db     -0x08 - 0x01, -0x08, 0x18, VDP_COLOR_LIGHT_BLUE

; 速度
;
shotSpeed:

    .db      0x00, -0x08
    .db      0x01, -0x07
    .db      0x03, -0x07
    .db      0x04, -0x06
    .db      0x05, -0x05
    .db      0x06, -0x04
    .db      0x07, -0x03
    .db      0x07, -0x01
    .db      0x08,  0x00
    .db      0x07,  0x01
    .db      0x07,  0x03
    .db      0x06,  0x04
    .db      0x05,  0x05
    .db      0x04,  0x06
    .db      0x03,  0x07
    .db      0x01,  0x07
    .db      0x00,  0x08
    .db     -0x01,  0x07
    .db     -0x03,  0x07
    .db     -0x04,  0x06
    .db     -0x05,  0x05
    .db     -0x06,  0x04
    .db     -0x07,  0x03
    .db     -0x07,  0x01
    .db     -0x08,  0x00
    .db     -0x07, -0x01
    .db     -0x07, -0x03
    .db     -0x06, -0x04
    .db     -0x05, -0x05
    .db     -0x04, -0x06
    .db     -0x03, -0x07
    .db     -0x01, -0x07


; DATA 領域
;
    .area   _DATA

; 変数の定義
;

; ショット
;
_shot::
    
    .ds     SHOT_LENGTH * SHOT_ENTRY

; スプライト
;
shotSpriteRotation:

    .ds     0x01
