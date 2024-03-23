; Dust.inc : ダスト
;


; マクロの定義
;

; ダスト
DUST_STATE                      =   0x00
DUST_POSITION_X                 =   0x01
DUST_POSITION_Y                 =   0x02
DUST_ANIMATION                  =   0x03
DUST_LENGTH                     =   0x04
DUST_ENTRY                      =   0x08

; 状態
DUST_STATE_NULL                 =   0x00
DUST_STATE_FALL                 =   0x10

; 位置
DUST_POSITION_NULL              =   0x00
DUST_POSITION_LEFT              =   0x00
DUST_POSITION_RIGHT             =   0xff
DUST_POSITION_TOP               =   0x00
DUST_POSITION_BOTTOM            =   0x9c

; アニメーション
DUST_ANIMATION_NULL             =   0x00

; 速度
DUST_SPEED_Y_FALL               =   0x01

; フレーム
DUST_FRAME_NULL                 =   0x00
DUST_FRAME_INTERVAL             =   0x18

; 外部関数宣言
;

    .globl  _DustInitialize
    .globl  _DustUpdate
    .globl  _DustRender
    .globl  _DustFall

; 外部変数宣言
;

    .globl  _dust
