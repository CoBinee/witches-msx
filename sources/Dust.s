; Dust.s : ダスト
;


; モジュール宣言
;
    .module Dust

; 参照ファイル
;
    .include    "bios.inc"
    .include    "vdp.inc"
    .include    "System.inc"
    .include    "App.inc"
    .include    "Game.inc"
    .include	"Dust.inc"

; 外部変数宣言
;

; マクロの定義
;


; CODE 領域
;
    .area   _CODE

; ダストを初期化する
;
_DustInitialize::
    
    ; レジスタの保存
    
    ; ダストの初期化
    ld      hl, #(_dust + 0x0000)
    ld      de, #(_dust + 0x0001)
    ld      bc, #(DUST_LENGTH * DUST_ENTRY - 0x0001)
    ld      (hl), #0x00
    ldir

    ; フレームの初期化
    ld      a, #DUST_FRAME_INTERVAL
    ld      (dustFrame), a

    ; レジスタの復帰
    
    ; 終了
    ret

; ダストを更新する
;
_DustUpdate::
    
    ; レジスタの保存

    ; ダストの生成
    ld      hl, #dustFrame
    dec     (hl)
    jr      nz, 10$
    call    _SystemGetRandom
    and     #0xf8
    add     a, #0x04
    ld      e, a
    ld      d, #DUST_POSITION_TOP
    call    _DustFall
    ld      (hl), #DUST_FRAME_INTERVAL
10$:
    
    ; ダストの走査
    ld      ix, #_dust
    ld      b, #DUST_ENTRY
20$:
    push    bc
    ld      a, DUST_STATE(ix)
    or      a
    jr      z, 29$

    ; 移動
    ld      a, DUST_POSITION_Y(ix)
    add     a, #DUST_SPEED_Y_FALL
    cp      #DUST_POSITION_BOTTOM
    jr      nc, 28$
    ld      DUST_POSITION_Y(ix), a

    ; アニメーションの更新
    inc     DUST_ANIMATION(ix)
    jr      29$

    ; ダストの削除
28$:
    ld      DUST_STATE(ix), #DUST_STATE_NULL
;   jr      29$

    ; 次のダストへ
29$:
    ld      bc, #DUST_LENGTH
    add     ix, bc
    pop     bc
    djnz    20$

    ; レジスタの復帰
    
    ; 終了
    ret

; ダストを描画する
;
_DustRender::
    
    ; レジスタの保存
    
    ; スプライトの描画
    ld      de, #(_sprite + GAME_SPRITE_DUST)
    ld      ix, #_dust
    ld      b, #DUST_ENTRY
10$:
    push    bc
    ld      a, DUST_STATE(ix)
    or      a
    jr      z, 19$
    ld      a, DUST_ANIMATION(ix)
    and     #0x0c
    ld      c, a
    ld      b, #0x00
    ld      hl, #dustSprite
    add     hl, bc
    ld      a, DUST_POSITION_Y(ix)
    add     a, (hl)
    ld      (de), a
    inc     hl
    inc     de
    ld      a, DUST_POSITION_X(ix)
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
    inc     de
19$:
    ld      bc, #DUST_LENGTH
    add     ix, bc
    pop     bc
    djnz    10$

    ; レジスタの復帰
    
    ; 終了
    ret

; ダストを降らす
;
_DustFall::

    ; レジスタの保存
    push    hl
    push    bc
    push    de
    push    ix

    ; de < Y/X 位置

    ; ダストの登録
    ex      de, hl
    ld      ix, #_dust
    ld      de, #DUST_LENGTH
    ld      b, #DUST_ENTRY
10$:
    ld      a, DUST_STATE(ix)
    or      a
    jr      z, 11$
    add     ix, de
    djnz    10$
    jr      19$
11$:
    ld      DUST_STATE(ix), #DUST_STATE_FALL
    ld      DUST_POSITION_X(ix), l
    ld      DUST_POSITION_Y(ix), h
;   ld      DUST_ANIMATION(ix), #0x00
;   jr      19$
19$:

    ; レジスタの復帰
    pop     ix
    pop     de
    pop     bc
    pop     hl

    ; 終了
    ret

; 定数の定義
;

; スプライト
;
dustSprite:

    .db     -0x08 - 0x01, -0x08, 0x70, VDP_COLOR_LIGHT_BLUE
    .db     -0x08 - 0x01, -0x08, 0x74, VDP_COLOR_LIGHT_BLUE
    .db     -0x08 - 0x01, -0x08, 0x78, VDP_COLOR_LIGHT_BLUE
    .db     -0x08 - 0x01, -0x08, 0x7c, VDP_COLOR_LIGHT_BLUE


; DATA 領域
;
    .area   _DATA

; 変数の定義
;

; ダスト
;
_dust::
    
    .ds     DUST_LENGTH * DUST_ENTRY

; フレーム
;
dustFrame:

    .ds     0x01
