; Player.s : プレイヤ
;


; モジュール宣言
;
    .module Player

; 参照ファイル
;
    .include    "bios.inc"
    .include    "vdp.inc"
    .include    "System.inc"
    .include    "App.inc"
    .include    "Sound.inc"
    .include    "Game.inc"
    .include	"Player.inc"
    .include    "Shot.inc"

; 外部変数宣言
;

; マクロの定義
;


; CODE 領域
;
    .area   _CODE

; プレイヤを初期化する
;
_PlayerInitialize::
    
    ; レジスタの保存
    
    ; プレイヤの初期化
    ld      hl, #playerDefault
    ld      de, #_player
    ld      bc, #PLAYER_LENGTH
    ldir

    ; 状態の設定
    ld      a, #PLAYER_STATE_PLAY
    ld      (_player + PLAYER_STATE), a
    
    ; レジスタの復帰
    
    ; 終了
    ret

; プレイヤを更新する
;
_PlayerUpdate::
    
    ; レジスタの保存
    
    ; 状態別の処理
    ld      hl, #10$
    push    hl
    ld      a, (_player + PLAYER_STATE)
    and     #0xf0
    rrca
    rrca
    rrca
    ld      e, a
    ld      d, #0x00
    ld      hl, #playerProc
    add     hl, de
    ld      e, (hl)
    inc     hl
    ld      d, (hl)
    ex      de, hl
    jp      (hl)
;   pop     hl
10$:

    ; スプライトの設定
    ld      a, (_player + PLAYER_DIRECTION)
    add     a, a
    add     a, a
    add     a, a
    ld      e, a
    ld      a, (_player + PLAYER_ANIMATION)
    and     #0x08
    rrca
    add     a, e
    ld      e, a
    ld      d, #0x00
    ld      hl, #playerSprite
    add     hl, de
    ld      (_player + PLAYER_SPRITE_L), hl

    ; レジスタの復帰
    
    ; 終了
    ret

; プレイヤを描画する
;
_PlayerRender::
    
    ; レジスタの保存

    ; ダメージの点滅
    ld      a, (_player + PLAYER_DAMAGE)
    and     #0x02
    jr      nz, 90$
    
    ; プレイヤの描画
    ld      de, #(_sprite + GAME_SPRITE_PLAYER)
    ld      hl, (_player + PLAYER_SPRITE_L)
    ld      a, (_player + PLAYER_POSITION_Y)
    add     a, (hl)
    ld      (de), a
    inc     hl
    inc     de
    ld      a, (_player + PLAYER_POSITION_X)
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
    ld      a, #VDP_COLOR_BLACK
    or      c
    ld      (de), a
;   inc     hl
;   inc     de
    ld      hl, #(_sprite + GAME_SPRITE_PLAYER + 0x0000)
    ld      de, #(_sprite + GAME_SPRITE_PLAYER + 0x0004)
    ldi
    ldi
    ld      a, (hl)
    add     a, #0x20
    ld      (de), a
    inc     hl
    inc     de
    ld      a, (hl)
    add     a, #(VDP_COLOR_LIGHT_BLUE - VDP_COLOR_BLACK)
    ld      (de), a
;   inc     hl
;   inc     de

    ; 狙いの描画
    ld      a, (_player + PLAYER_FLAG)
    bit     #PLAYER_FLAG_AIM_BIT, a
    jr      z, 20$
    ld      bc, (_player + PLAYER_AIM_POSITION_X)
    ld      de, #(_sprite + GAME_SPRITE_AIM)
    ld      a, (_player + PLAYER_AIM_ANIMATION)
    call    _ShotPrintAim
20$:

    ; 描画の完了
90$:

    ; レジスタの復帰
    
    ; 終了
    ret

; 何もしない
;
PlayerNull:

    ; レジスタの保存

    ; レジスタの復帰

    ; 終了
    ret

; プレイヤを操作する
;
PlayerPlay:

    ; レジスタの保存

    ; 初期化
    ld      a, (_player + PLAYER_STATE)
    and     #0x0f
    jr      nz, 09$

    ; 初期化の完了
    ld      hl, #(_player + PLAYER_STATE)
    inc     (hl)
09$:

    ; ダメージの更新
    ld      hl, #(_player + PLAYER_DAMAGE)
    ld      a, (hl)
    or      a
    jr      z, 10$
    dec     (hl)
10$:

    ; 左右の操作
    ld      hl, #(_player + PLAYER_SPEED_X)
    ld      b, #PLAYER_SPEED_X_ACCEL
    ld      a, (_input + INPUT_KEY_LEFT)
    or      a
    jr      z, 20$
    ld      a, #PLAYER_DIRECTION_L
    ld      (_player + PLAYER_DIRECTION), a
    ld      a, (hl)
    sub     b
    jp      p, 28$
    ld      c, #-PLAYER_SPEED_X_MAXIMUM
    cp      c
    jr      nc, 28$
    ld      a, c
    jr      28$
20$:
    ld      a, (_input + INPUT_KEY_RIGHT)
    or      a
    jr      z, 21$
    ld      a, #PLAYER_DIRECTION_R
    ld      (_player + PLAYER_DIRECTION), a
    ld      a, (hl)
    add     a, b
    jp      m, 28$
    ld      c, #PLAYER_SPEED_X_MAXIMUM
    cp      c
    jr      c, 28$
    ld      a, c
    jr      28$
21$:
    ld      b, #PLAYER_SPEED_X_BRAKE
    ld      a, (hl)
    or      a
    jr      z, 29$
    jp      p, 22$
    add     a, b
    jr      nc, 28$
    xor     a
    jr      28$
22$:
    sub     b
    jr      nc, 28$
    xor     a
;   jr      28$
28$:
    ld      (hl), a
;   jr      29$
29$:

    ; 上下の操作
    ld      hl, #(_player + PLAYER_FLAG)
    ld      de, #(_player + PLAYER_SPEED_Y)
    ld      a, (_player + PLAYER_POSITION_Y)
    cp      #PLAYER_POSITION_BOTTOM
    jr      c, 30$
    ld      a, (_input + INPUT_BUTTON_SHIFT)
    dec     a
    jr      nz, 39$
    set     #PLAYER_FLAG_JUMP_BIT, (hl)
    ld      a, #PLAYER_ANIMATION_JUMP
    ld      (_player + PLAYER_ANIMATION), a
    ld      a, #PLAYER_SPEED_Y_JUMP
    jr      38$
30$:
    ld      b, #PLAYER_SPEED_Y_GRAVITY
    bit     #PLAYER_FLAG_JUMP_BIT, (hl)
    jr      z, 32$
    ld      a, (_input + INPUT_BUTTON_SHIFT)
    or      a
    jr      z, 31$
    ld      b, #PLAYER_SPEED_Y_FLOAT
    jr      32$
31$:
    res     #PLAYER_FLAG_JUMP_BIT, (hl)
;   jr      32$
32$:
    ld      a, (de)
    add     a, b
    jp      m, 38$
    ld      c, #PLAYER_SPEED_Y_MAXIMUM
    cp      c
    jr      c, 38$
    ld      a, c
;   jr      38$
38$:
    ld      (de), a
;   jr      39$
39$:

    ; 左右の移動
    ld      hl, #(_player + PLAYER_POSITION_X)
    ld      a, (_player + PLAYER_SPEED_X)
    or      a
    jp      p, 40$
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
    jr      nc, 48$
    xor     a
    jr      48$
40$:
    add     a, #0x08
    and     #0xf0
    rrca
    rrca
    rrca
    rrca
    add     a, (hl)
    jr      nc, 48$
    ld      a, #PLAYER_POSITION_RIGHT
;   jr      48$
48$:
    ld      (hl), a
;   jr      49$
49$:

    ; 上下の移動
    ld      hl, #(_player + PLAYER_POSITION_Y)
    ld      a, (_player + PLAYER_SPEED_Y)
    or      a
    jp      p, 50$
    neg
    and     #0xf0
    rrca
    rrca
    rrca
    rrca
    neg
    jr      51$
50$:
    and     #0xf0
    rrca
    rrca
    rrca
    rrca
;   jr      51$
51$:
    add     a, (hl)
    cp      #PLAYER_POSITION_BOTTOM
    jr      c, 58$
    ld      a, #PLAYER_POSITION_BOTTOM
;   jr      58$
58$:
    ld      (hl), a
;   jr      59$
59$:

    ; 狙いの更新
    ld      hl, #(_player + PLAYER_AIM_ROTATION)
    ld      de, #(_player + PLAYER_AIM_DIRECTION)
600$:
    ld      a, (_input + INPUT_KEY_LEFT)
    or      a
    jr      z, 610$
    ld      a, (_input + INPUT_KEY_UP)
    or      a
    jr      nz, 601$
    ld      a, (de)
    cp      #SHOT_DIRECTION_0900
    jr      z, 681$
    jr      670$
601$:
    ld      a, (de)
    cp      #SHOT_DIRECTION_1030
    jr      z, 681$
    jr      nc, 670$
    cp      #(SHOT_DIRECTION_0430 + 0x01)
    jr      c, 670$
    jr      671$
610$:
    ld      a, (_input + INPUT_KEY_RIGHT)
    or      a
    jr      z, 620$
    ld      a, (_input + INPUT_KEY_UP)
    or      a
    jr      nz, 611$
    ld      a, (de)
    cp      #SHOT_DIRECTION_0300
    jr      z, 681$
    jr      671$
611$:
    ld      a, (de)
    cp      #SHOT_DIRECTION_0130
    jr      z, 681$
    jr      c, 671$
    cp      #SHOT_DIRECTION_0730
    jr      nc, 671$
    jr      670$
620$:
    ld      a, (_input + INPUT_KEY_UP)
    or      a
    jr      z, 630$
    ld      a, (de)
    or      a
    jr      z, 681$
    cp      #SHOT_DIRECTION_0600
    jr      nc, 671$
    jr      670$
630$:
    ld      a, (de)
    ld      c, #0x01
    jr      680$
670$:
    dec     a
    jr      672$
671$:
    inc     a
;   jr      672$
672$:
    dec     (hl)
    jr      z, 673$
    ld      a, (de)
    jr      681$
673$:
    and     #(SHOT_DIRECTION_LENGTH - 0x01)
    ld      (de), a
    ld      c, #PLAYER_AIM_ROTATION_INTERVAL
;   jr      680$
680$:
    ld      (hl), c
681$:
    add     a, a
    ld      e, a
    ld      d, #0x00
    ld      hl, #playerAimOffset
    add     hl, de
    ex      de, hl
    ld      hl, #(_player + PLAYER_POSITION_X)
    ld      a, (de)
    or      a
    jp      p, 682$
    neg
    ld      c, a
    ld      a, (hl)
    sub     c
    jr      c, 688$
    jr      683$
682$:
    add     a, (hl)
    jr      c, 688$
;   jr      683$
683$:
    ld      (_player + PLAYER_AIM_POSITION_X), a
    inc     de
    ld      hl, #(_player + PLAYER_POSITION_Y)
    ld      a, (de)
    or      a
    jp      p, 684$
    neg
    ld      c, a
    ld      a, (hl)
    sub     c
    jr      c, 688$
    jr      685$
684$:
    add     a, (hl)
    jr      c, 688$
;   jr      685$
685$:
    ld      (_player + PLAYER_AIM_POSITION_Y), a
    ld      hl, #(_player + PLAYER_FLAG)
    set     #PLAYER_FLAG_AIM_BIT, (hl)     
    jr      689$
688$:
    ld      hl, #(_player + PLAYER_FLAG)
    res     #PLAYER_FLAG_AIM_BIT, (hl)     
;   jr      689$
689$:

    ; ショットを撃つ
    ld      a, (_game + GAME_FLAG)
    bit     #GAME_FLAG_PLAY_BIT, a
    jr      z, 79$
    ld      a, (_player + PLAYER_DAMAGE)
    or      a
    jr      nz, 79$
    ld      a, (_player + PLAYER_FLAG)
    bit     #PLAYER_FLAG_AIM_BIT, a
    jr      z, 79$
    ld      hl, #(_player + PLAYER_FIRE)
    ld      a, (_input + INPUT_BUTTON_SPACE)
    or      a
    jr      z, 79$
    dec     a
    jr      z, 70$
    dec     (hl)
    jr      nz, 79$
70$:
    ld      de, (_player + PLAYER_AIM_POSITION_X)
    ld      a, (_player + PLAYER_AIM_DIRECTION)
    ld      c, a
    call    _ShotFire
    ld      (hl), #PLAYER_FIRE_INTERVAL
79$:

    ; 矩形の取得
    ld      hl, #(_player + PLAYER_RECT_LEFT)
    ld      de, (_player + PLAYER_POSITION_X)
    ld      a, e
    sub     #PLAYER_SIZE_LEFT
    jr      nc, 80$
    xor     a
80$:
    ld      (hl), a
    inc     hl
    ld      a, d
    sub     #PLAYER_SIZE_TOP
    jr      nc, 81$
    xor     a
81$:
    ld      (hl), a
    inc     hl
    ld      a, e
    add     a, #PLAYER_SIZE_RIGHT
    jr      nc, 82$
    ld      a, #0xff
82$:
    ld      (hl), a
    inc     hl
    ld      (hl), d

    ; アニメーションの更新
    ld      a, (_player + PLAYER_POSITION_Y)
    cp      #PLAYER_POSITION_BOTTOM
    jr      c, 90$
    ld      hl, #(_player + PLAYER_ANIMATION)
    inc     (hl)
90$:
    ld      hl, #(_player + PLAYER_AIM_ANIMATION)
    inc     (hl)

    ; レジスタの復帰

    ; 終了
    ret

; プレイヤがダメージを受ける
;
_PlayerDamage::

    ; レジスタの保存

    ; de < ダメージを与えたものの Y/X 位置

    ; ダメージの設定
    ld      a, #PLAYER_DAMAGE_FRAME
    ld      (_player + PLAYER_DAMAGE), a
    ld      a, (_player + PLAYER_POSITION_X)
    cp      e
    ld      a, #PLAYER_SPEED_X_DAMAGE
    jr      nc, 10$
    neg
10$:
    ld      (_player + PLAYER_SPEED_X), a

    ; SE の再生
    ld      a, #SOUND_SE_DAMAGE
    call    _SoundPlaySe

    ; レジスタの復帰

    ; 終了
    ret

; 定数の定義
;

; 状態別の処理
;
playerProc:
    
    .dw     PlayerNull
    .dw     PlayerPlay

; ゲームの初期値
;
playerDefault:

    .db     PLAYER_STATE_NULL
    .db     PLAYER_FLAG_NULL
    .db     0x60 ; PLAYER_POSITION_NULL
    .db     PLAYER_POSITION_BOTTOM ; PLAYER_POSITION_NULL
    .db     PLAYER_SPEED_NULL
    .db     PLAYER_SPEED_NULL
    .db     PLAYER_DIRECTION_R
    .db     PLAYER_ANIMATION_NULL
    .dw     PLAYER_SPRITE_NULL
    .db     PLAYER_AIM_POSITION_NULL
    .db     PLAYER_AIM_POSITION_NULL
    .db     SHOT_DIRECTION_0300 ; PLAYER_AIM_DIRECTION_NULL
    .db     PLAYER_AIM_ROTATION_NULL
    .db     PLAYER_AIM_ANIMATION_NULL
    .db     0x01 ; PLAYER_FIRE_NULL
    .db     PLAYER_RECT_NULL
    .db     PLAYER_RECT_NULL
    .db     PLAYER_RECT_NULL
    .db     PLAYER_RECT_NULL
    .db     PLAYER_DAMAGE_NULL

; スプライト
;
playerSprite:

    .db     -0x0f - 0x01, -0x08, 0x20, VDP_COLOR_TRANSPARENT
    .db     -0x0f - 0x01, -0x08, 0x24, VDP_COLOR_TRANSPARENT
    .db     -0x0f - 0x01, -0x08, 0x28, VDP_COLOR_TRANSPARENT
    .db     -0x0f - 0x01, -0x08, 0x2c, VDP_COLOR_TRANSPARENT

; 狙い
;
playerAimOffset:

    .db      0x00, -0x0e - 0x04
    .db      0x02, -0x0d - 0x04
    .db      0x04, -0x0c - 0x04
    .db      0x06, -0x0b - 0x04
    .db      0x08, -0x09 - 0x04
    .db      0x09, -0x07 - 0x04
    .db      0x0b, -0x05 - 0x04
    .db      0x0b, -0x02 - 0x04
    .db      0x0c,  0x00 - 0x04
    .db      0x0b,  0x02 - 0x04
    .db      0x0b,  0x04 - 0x04
    .db      0x09,  0x06 - 0x04
    .db      0x08,  0x08 - 0x04
    .db      0x06,  0x09 - 0x04
    .db      0x04,  0x0b - 0x04
    .db      0x02,  0x0b - 0x04
    .db      0x00,  0x0c - 0x04
    .db     -0x02,  0x0b - 0x04
    .db     -0x04,  0x0b - 0x04
    .db     -0x06,  0x09 - 0x04
    .db     -0x08,  0x08 - 0x04
    .db     -0x09,  0x06 - 0x04
    .db     -0x0b,  0x04 - 0x04
    .db     -0x0b,  0x02 - 0x04
    .db     -0x0c,  0x00 - 0x04
    .db     -0x0b, -0x02 - 0x04
    .db     -0x0b, -0x05 - 0x04
    .db     -0x09, -0x07 - 0x04
    .db     -0x08, -0x09 - 0x04
    .db     -0x06, -0x0b - 0x04
    .db     -0x04, -0x0c - 0x04
    .db     -0x02, -0x0d - 0x04


; DATA 領域
;
    .area   _DATA

; 変数の定義
;

; プレイヤ
;
_player::
    
    .ds     PLAYER_LENGTH
