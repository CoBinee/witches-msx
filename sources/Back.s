; Back.s : 背景
;


; モジュール宣言
;
    .module Back

; 参照ファイル
;
    .include    "bios.inc"
    .include    "vdp.inc"
    .include    "System.inc"
    .include    "App.inc"
    .include    "Sound.inc"
    .include    "Game.inc"
    .include	"Back.inc"

; 外部変数宣言
;

; マクロの定義
;


; CODE 領域
;
    .area   _CODE

; 背景を初期化する
;
_BackInitialize::
    
    ; レジスタの保存
    
    ; 背景の初期化
    ld      hl, #backDefault
    ld      de, #_back
    ld      bc, #BACK_LENGTH
    ldir

    ; 桁の初期化
    ld      hl, #(backColumn + 0x0000)
    ld      de, #(backColumn + 0x0001)
    ld      bc, #(BACK_SIZE_X - 0x0001)
    ld      (hl), #(BACK_SIZE_Y - 0x01)
    ldir

    ; パターンネームの初期化
    call    _BackPrintDark
    ld      hl, #backStatusPatternName
    ld      bc, #0x0080
    ldir
    
    ; レジスタの復帰
    
    ; 終了
    ret

; 背景を更新する
;
_BackUpdate::
    
    ; レジスタの保存

    ; 桁の更新
    ld      a, (_game + GAME_FLAG)
    bit     #GAME_FLAG_PLAY_BIT, a
    jr      z, 19$
    ld      hl, #_patternName
    ld      de, #backColumn
    ld      b, #BACK_SIZE_X
10$:
    push    bc
    push    hl
    ld      a, (de)
    ld      c, #0x00
    srl     a
    rr      c
    srl     a
    rr      c
    srl     a
    rr      c
    ld      b, a
    add     hl, bc
    ld      a, (hl)
    cp      #BACK_PATTERN_NAME_DARK
    jr      nc, 11$
    inc     a
    ld      (hl), a
    ld      c, #0x01
    call    BackSubAreaLight
    ld      a, (hl)
    cp      #BACK_PATTERN_NAME_DARK
    jr      c, 12$
11$:
    ld      a, (de)
    inc     a
    cp      #BACK_SIZE_Y
    jr      nc, 12$
    ld      (de), a
;   jr      12$
12$:
    inc     de
    pop     hl
    inc     hl
    pop     bc
    djnz    10$
19$:

    ; アニメーションの更新
    ld      hl, #(_back + BACK_ANIMATION)
    inc     (hl)

    ; 面積の集計
    ld      hl, (_back + BACK_AREA_LIGHT_L)
    ld      de, #(_back + BACK_AREA_LIGHT_10000)
    call    _AppGetDecimal
    ld      hl, #(BACK_SIZE_X * BACK_SIZE_Y * (BACK_PATTERN_NAME_DARK - BACK_PATTERN_NAME_LIGHT))
    ld      de, (_back + BACK_AREA_LIGHT_L)
    or      a
    sbc     hl, de
    ld      (_back + BACK_AREA_DARK_L), hl
    ld      de, #(_back + BACK_AREA_DARK_10000)
    call    _AppGetDecimal

    ; レジスタの復帰
    
    ; 終了
    ret

; 背景を描画する
;
_BackRender::
    
    ; レジスタの保存

    ; メーターの描画
    ld      de, (_back + BACK_AREA_LIGHT_L)
    ld      a, d
    or      a
    jr      nz, 10$
    or      e
    jr      z, 10$
    ld      a, e
    cp      #0x40
    jr      nc, 10$
    ld      e, #0x40
10$:
    ld      hl, #(_patternName + 0x02a6)
    ld      c, #0x00
    ld      a, e
    add     a, a
    rl      d
    add     a, a
    rl      d
    ld      a, d
    and     #0xf8
    jr      z, 12$
    rrca
    rrca
    rrca
    ld      b, a
    ld      a, #0x5e
11$:
    ld      (hl), a
    inc     hl
    inc     c
    djnz    11$
12$:
    ld      a, d
    and     #0x07
    jr      z, 13$
    add     a, #0x56
    ld      (hl), a
    inc     hl
    inc     c
13$:
    ld      a, #((BACK_SIZE_X * BACK_SIZE_Y * 0x0010) / (0x0040 * 0x0008))
    sub     c
    jr      z, 15$
    ld      b, a
    ld      a, #0x56
14$:
    ld      (hl), a
    inc     hl
    djnz    14$
15$:

    ; スコアの描画
    ld      hl, #(_back + BACK_AREA_LIGHT_10000)
    ld      de, #(_patternName + 0x02ca)
    ld      b, #BACK_AREA_LENGTH
    call    _AppPrintValueRight
    ld      hl, #(_back + BACK_AREA_DARK_10000)
    ld      de, #(_patternName + 0x02d1)
    ld      b, #BACK_AREA_LENGTH
    call    _AppPrintValueLeft

    ; タイムの描画
    ld      hl, #(_game + GAME_TIME_100)
    ld      de, #(_patternName + 0x02ef)
    ld      b, #GAME_TIME_LENGTH
    call    _AppPrintValueRight

    ; スプライトの描画
    ld      a, (_back + BACK_ANIMATION)
    and     #0x08
    ld      e, a
    ld      d, #0x00
    ld      hl, #backStatusSprite
    add     hl, de
    ld      de, #(_sprite + GAME_SPRITE_STATUS)
    ld      bc, #0x0008
    ldir

    ; レジスタの復帰
    
    ; 終了
    ret

; 背景を削る
;
_BackHit::

    ; レジスタの保存
    push    hl
    push    bc
    push    de

    ; de < Y/X 位置
    ; cf > 1 = ヒット

    ; ビットの取得
    ld      b, #0b11111111
    ld      a, e
    cp      #0x08
    jr      nc, 10$
    ld      a, b
    and     #0b01101011
    ld      b, a
    jr      11$
10$:
    cp      #0xf8
    jr      c, 11$
    ld      a, b
    and     #0b11010110
    ld      b, a
11$:
    ld      a, d
    cp      #0x08
    jr      nc, 12$
    ld      a, b
    and     #0b00011111
    ld      b, a
    jr      13$
12$:
    cp      #((BACK_SIZE_Y - 0x01) * 0x08)
    jr      c, 13$
    ld      a, b
    and     #0b11111000
    ld      b, a
13$:

    ; 背景を削る
    ld      a, d
    cp      #(BACK_SIZE_Y * 0x08)
    jp      nc, 290$
    ld      a, e
    and     #0xf8
    rrca
    rrca
    rrca
    ld      e, a
    ld      a, d
    and     #0xf8
    ld      d, #0x00
    add     a, a
    rl      d
    add     a, a
    rl      d
    add     a, e
    ld      e, a
    ld      hl, #_patternName
    add     hl, de
    ld      a, (hl)
    cp      #BACK_PATTERN_NAME_DARK
    jr      nc, 200$
    ld      c, #BACK_HIT_L
    call    210$
    or      a
    jp      290$
200$:
    ld      de, #-(BACK_SIZE_X + 0x01)
    add     hl, de
    ld      de, #(BACK_SIZE_X - 0x02)
    ld      c, #BACK_HIT_S
    rl      b
    call    c, 210$
    inc     hl
    ld      c, #BACK_HIT_M
    rl      b
    call    c, 210$
    inc     hl
    ld      c, #BACK_HIT_S
    rl      b
    call    c, 210$
    add     hl, de
    ld      c, #BACK_HIT_M
    rl      b
    call    c, 210$
    inc     hl
    ld      c, #BACK_HIT_L
    call    210$
    inc     hl
    ld      c, #BACK_HIT_M
    rl      b
    call    c, 210$
    add     hl, de
    ld      c, #BACK_HIT_S
    rl      b
    call    c, 210$
    inc     hl
    ld      c, #BACK_HIT_M
    rl      b
    call    c, 210$
    inc     hl
    ld      c, #BACK_HIT_S
    rl      b
    call    c, 210$
;   add     hl, de
    ld      a, #SOUND_SE_HIT
    call    _SoundPlaySe
    scf
    jr      290$
210$:
    ld      a, (hl)
    cp      #(BACK_PATTERN_NAME_LIGHT + 0x01)
    jr      c, 219$
    sub     c
    cp      #BACK_PATTERN_NAME_LIGHT
    jr      nc, 211$
    ld      a, (hl)
    sub     #BACK_PATTERN_NAME_LIGHT
    ld      c, a
    ld      a, #BACK_PATTERN_NAME_LIGHT
211$:
    ld      (hl), a
    call    BackAddAreaLight
    push    bc
    push    de
    push    hl
    ld      bc, #_patternName
    or      a
    sbc     hl, bc
    ld      c, l
    ld      b, h
    ld      a, c
    and     #0x1f
    ld      e, a
    ld      d, #0x00
    ld      hl, #backColumn
    add     hl, de
    ld      a, c
    add     a, a
    rl      b
    add     a, a
    rl      b
    add     a, a
    rl      b
    ld      a, b
    cp      (hl)
    jr      nc, 212$
    ld      (hl), a
212$:
    pop     hl
    pop     de
    pop     bc
219$:
    ret
290$:

    ; レジスタの復帰
    pop     de
    pop     bc
    pop     hl

    ; 終了
    ret

; 背景が光かどうかを判定する
;
_BackIsLight::

    ; レジスタの保存
    push    hl
    push    de

    ; de < Y/X 位置
    ; cf > 1 = 光

    ; 背景の判定
    ld      a, d
    cp      #(BACK_SIZE_Y * 0x08)
    jr      nc, 19$
    ld      a, e
    and     #0xf8
    rrca
    rrca
    rrca
    ld      e, a
    ld      a, d
    and     #0xf8
    ld      d, #0x00
    add     a, a
    rl      d
    add     a, a
    rl      d
    add     a, e
    ld      e, a
    ld      hl, #_patternName
    add     hl, de
    ld      a, (hl)
    cp      #BACK_PATTERN_NAME_HALF
19$:

    ; レジスタの復帰
    pop     de
    pop     hl

    ; 終了
    ret

; 光の面積を増やす
;
BackAddAreaLight:

    ; レジスタの保存
    push    hl
    push    bc

    ; c < 面積

    ; 面積の更新
    ld      b, #0x00
    ld      hl, (_back + BACK_AREA_LIGHT_L)
    add     hl, bc
    ld      (_back + BACK_AREA_LIGHT_L), hl
;   ld      hl, (_back + BACK_AREA_DARK_L)
;   or      a
;   sbc     hl, bc
;   ld      (_back + BACK_AREA_DARK_L), hl

    ; レジスタの復帰
    pop     bc
    pop     hl

    ; 終了
    ret

; 光の面積を減らす
;
BackSubAreaLight:

    ; レジスタの保存
    push    hl
    push    bc

    ; c < 面積

    ; 面積の更新
    ld      b, #0x00
    ld      hl, (_back + BACK_AREA_LIGHT_L)
    or      a
    sbc     hl, bc
    ld      (_back + BACK_AREA_LIGHT_L), hl
;   ld      hl, (_back + BACK_AREA_DARK_L)
;   add     hl, bc
;   ld      (_back + BACK_AREA_DARK_L), hl

    ; レジスタの復帰
    pop     bc
    pop     hl

    ; 終了
    ret

; 闇を描画する
;
_BackPrintDark::

    ; レジスタの保存

    ; パターンネームの設定
    ld      hl, #(_patternName + 0x0000)
    ld      de, #(_patternName + 0x0001)
    ld      bc, #(BACK_SIZE_X * BACK_SIZE_Y - 0x0001)
    ld      (hl), #BACK_PATTERN_NAME_DARK
    ldir

    ; レジスタの復帰

    ; 終了
    ret

; 定数の定義
;

; 背景の初期値
;
backDefault:

    .dw     BACK_AREA_NULL
    .dw     BACK_AREA_NULL
    .db     0x00 ; BACK_AREA_NULL
    .db     0x00 ; BACK_AREA_NULL
    .db     0x00 ; BACK_AREA_NULL
    .db     0x00 ; BACK_AREA_NULL
    .db     0x00 ; BACK_AREA_NULL
    .db     0x01 ; BACK_AREA_NULL
    .db     0x00 ; BACK_AREA_NULL
    .db     0x02 ; BACK_AREA_NULL
    .db     0x04 ; BACK_AREA_NULL
    .db     0x00 ; BACK_AREA_NULL
    .db     BACK_ANIMATION_NULL

; ステータス
;
backStatusPatternName:

    .db     0x51, 0x51, 0x51, 0x51, 0x51, 0x51, 0x51, 0x51, 0x51, 0x51, 0x51, 0x51, 0x51, 0x51, 0x51, 0x51
    .db     0x51, 0x51, 0x51, 0x51, 0x51, 0x51, 0x51, 0x51, 0x51, 0x51, 0x51, 0x51, 0x51, 0x51, 0x51, 0x51
    .db     0x00, 0x00, 0x00, 0x00, 0x00, 0x55, 0x56, 0x56, 0x56, 0x56, 0x56, 0x56, 0x56, 0x56, 0x56, 0x56
    .db     0x56, 0x56, 0x56, 0x56, 0x56, 0x56, 0x56, 0x56, 0x56, 0x56, 0x5f, 0x00, 0x00, 0x00, 0x00, 0x00
    .db     0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x10, 0x53
    .db     0x54, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
    .db     0x00, 0x39, 0x2f, 0x35, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x52, 0x19
    .db     0x19, 0x19, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x32, 0x29, 0x36, 0x21, 0x2c

backStatusSprite:

    .db     0xa4 - 0x01, 0x0c, 0x28, VDP_COLOR_LIGHT_BLUE
    .db     0xa4 - 0x01, 0xe4, 0x30, VDP_COLOR_LIGHT_BLUE
    .db     0xa4 - 0x01, 0x0c, 0x2c, VDP_COLOR_LIGHT_BLUE
    .db     0xa5 - 0x01, 0xe4, 0x34, VDP_COLOR_LIGHT_BLUE


; DATA 領域
;
    .area   _DATA

; 変数の定義
;

; 背景
;
_back::

    .ds     BACK_LENGTH

; 桁
;
backColumn:

    .ds     BACK_SIZE_X

