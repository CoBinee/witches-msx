; Cat.s : キャット
;


; モジュール宣言
;
    .module Cat

; 参照ファイル
;
    .include    "bios.inc"
    .include    "vdp.inc"
    .include    "System.inc"
    .include    "App.inc"
    .include    "Game.inc"
    .include    "Back.inc"
    .include    "Player.inc"
    .include	"Cat.inc"

; 外部変数宣言
;

; マクロの定義
;


; CODE 領域
;
    .area   _CODE

; キャットを初期化する
;
_CatInitialize::
    
    ; レジスタの保存
    
    ; キャットの初期化
    ld      hl, #catDefault
    ld      de, #_cat
    ld      bc, #CAT_LENGTH
    ldir

    ; 状態の設定
    ld      a, #CAT_STATE_STAY
    ld      (_cat + CAT_STATE), a
    
    ; レジスタの復帰
    
    ; 終了
    ret

; キャットを更新する
;
_CatUpdate::
    
    ; レジスタの保存
    
    ; 状態別の処理
    ld      hl, #10$
    push    hl
    ld      a, (_cat + CAT_STATE)
    and     #0xf0
    rrca
    rrca
    rrca
    ld      e, a
    ld      d, #0x00
    ld      hl, #catProc
    add     hl, de
    ld      e, (hl)
    inc     hl
    ld      d, (hl)
    ex      de, hl
    jp      (hl)
;   pop     hl
10$:

    ; スプライトの設定
    ld      a, (_cat + CAT_STATE)
    and     #0xf0
    ld      e, a
    ld      a, (_cat + CAT_DIRECTION)
    add     a, a
    add     a, a
    add     a, a
    add     a, e
    ld      e, a
    ld      a, (_cat + CAT_ANIMATION)
    and     #0x08
    rrca
    add     a, e
    ld      e, a
    ld      d, #0x00
    ld      hl, #catSprite
    add     hl, de
    ld      (_cat + CAT_SPRITE_L), hl

    ; レジスタの復帰
    
    ; 終了
    ret

; キャットを描画する
;
_CatRender::
    
    ; レジスタの保存
    
    ; キャットの描画
    ld      de, #(_sprite + GAME_SPRITE_CAT)
    ld      hl, (_cat + CAT_SPRITE_L)
    ld      a, (_cat + CAT_POSITION_Y)
    add     a, (hl)
    ld      (de), a
    inc     hl
    inc     de
    ld      a, (_cat + CAT_POSITION_X)
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
    push    de
    ld      de, (_cat + CAT_POSITION_X)
    call    _BackIsLight
    ld      a, #VDP_COLOR_BLACK
    jr      c, 11$
    ld      a, #VDP_COLOR_LIGHT_BLUE
11$:
    pop     de
    or      c
    ld      (de), a
;   inc     hl
;   inc     de

    ; レジスタの復帰
    
    ; 終了
    ret

; 何もしない
;
CatNull:

    ; レジスタの保存

    ; レジスタの復帰

    ; 終了
    ret

; キャットが待機する
;
CatStay:

    ; レジスタの保存

    ; 初期化
    ld      a, (_cat + CAT_STATE)
    and     #0x0f
    jr      nz, 09$

    ; アニメーションの設定
    call    _SystemGetRandom
    and     #0x3f
    add     a, #0x20
    ld      (_cat + CAT_ANIMATION), a

    ; 初期化の完了
    ld      hl, #(_cat + CAT_STATE)
    inc     (hl)
09$:

    ; アニメーションの更新
    ld      hl, #(_cat + CAT_ANIMATION)
    dec     (hl)
    jr      nz, 19$

    ; 状態の更新
    ld      a, (_player + PLAYER_POSITION_X)
    ld      c, a
    ld      a, (_cat + CAT_POSITION_X)
    cp      c
    ld      a, #CAT_STATE_STAY
    jr      z, 18$
    ld      a, #CAT_STATE_WALK
;   jr      18$
18$:
    ld      (_cat + CAT_STATE), a
19$:

    ; レジスタの復帰

    ; 終了
    ret

; キャットが歩く
;
CatWalk:

    ; レジスタの保存

    ; 初期化
    ld      a, (_cat + CAT_STATE)
    and     #0x0f
    jr      nz, 09$

    ; 目標の取得
    ld      a, (_player + PLAYER_POSITION_X)
    ld      (_cat + CAT_POSITION_TARGET), a

    ; 向きの設定
    ld      c, a
    ld      a, (_cat + CAT_POSITION_X)
    sub     c
    rla
    and     #0x01
    ld      (_cat + CAT_DIRECTION), a

    ; 初期化の完了
    ld      hl, #(_cat + CAT_STATE)
    inc     (hl)
09$:

    ; 移動
    ld      a, (_cat + CAT_ANIMATION)
    and     #0x01
    jr      nz, 19$
    ld      hl, #(_cat + CAT_POSITION_X)
    ld      a, (_cat + CAT_POSITION_TARGET)
    cp      (hl)
    jr      z, 18$
    jr      nc, 10$
    dec     (hl)
    jr      19$
10$:
    inc     (hl)
    jr      19$

    ; 状態の更新
18$:
    ld      a, #CAT_STATE_STAY
    ld      (_cat + CAT_STATE), a
19$:

    ; アニメーションの更新
    ld      hl, #(_cat + CAT_ANIMATION)
    inc     (hl)

    ; レジスタの復帰

    ; 終了
    ret

; 定数の定義
;

; 状態別の処理
;
catProc:
    
    .dw     CatNull
    .dw     CatStay
    .dw     CatWalk

; ゲームの初期値
;
catDefault:

    .db     CAT_STATE_NULL
    .db     0xc0 ; CAT_POSITION_NULL
    .db     0x9f ; CAT_POSITION_NULL
    .db     CAT_POSITION_NULL
    .db     CAT_DIRECTION_L
    .db     CAT_ANIMATION_NULL
    .dw     CAT_SPRITE_NULL

; スプライト
;
catSprite:

    .db     -0x0f - 0x01, -0x08, 0x80, VDP_COLOR_TRANSPARENT
    .db     -0x0f - 0x01, -0x08, 0x84, VDP_COLOR_TRANSPARENT
    .db     -0x0f - 0x01, -0x08, 0x88, VDP_COLOR_TRANSPARENT
    .db     -0x0f - 0x01, -0x08, 0x8c, VDP_COLOR_TRANSPARENT
    .db     -0x0f - 0x01, -0x08, 0x80, VDP_COLOR_TRANSPARENT
    .db     -0x0f - 0x01, -0x08, 0x84, VDP_COLOR_TRANSPARENT
    .db     -0x0f - 0x01, -0x08, 0x88, VDP_COLOR_TRANSPARENT
    .db     -0x0f - 0x01, -0x08, 0x8c, VDP_COLOR_TRANSPARENT
    .db     -0x0f - 0x01, -0x08, 0x60, VDP_COLOR_TRANSPARENT
    .db     -0x0f - 0x01, -0x08, 0x64, VDP_COLOR_TRANSPARENT
    .db     -0x0f - 0x01, -0x08, 0x68, VDP_COLOR_TRANSPARENT
    .db     -0x0f - 0x01, -0x08, 0x6c, VDP_COLOR_TRANSPARENT


; DATA 領域
;
    .area   _DATA

; 変数の定義
;

; キャット
;
_cat::
    
    .ds     CAT_LENGTH
