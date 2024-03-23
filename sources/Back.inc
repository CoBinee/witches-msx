; Back.inc : 背景
;


; マクロの定義
;

; 背景
BACK_AREA_LIGHT_L               =   0x00
BACK_AREA_LIGHT_H               =   0x01
BACK_AREA_DARK_L                =   0x02
BACK_AREA_DARK_H                =   0x03
BACK_AREA_LIGHT_10000           =   0x04
BACK_AREA_LIGHT_01000           =   0x05
BACK_AREA_LIGHT_00100           =   0x06
BACK_AREA_LIGHT_00010           =   0x07
BACK_AREA_LIGHT_00001           =   0x08
BACK_AREA_DARK_10000            =   0x09
BACK_AREA_DARK_01000            =   0x0a
BACK_AREA_DARK_00100            =   0x0b
BACK_AREA_DARK_00010            =   0x0c
BACK_AREA_DARK_00001            =   0x0d
BACK_ANIMATION                  =   0x0e
BACK_LENGTH                     =   0x0f

; 面積
BACK_AREA_NULL                  =   0x00
BACK_AREA_LENGTH                =   0x05

; アニメーション
BACK_ANIMATION_NULL             =   0x00

; 大きさ
BACK_SIZE_X                     =   0x20
BACK_SIZE_Y                     =   0x14

; パターンネーム
BACK_PATTERN_NAME_LIGHT         =   0x40
BACK_PATTERN_NAME_DARK          =   0x50
BACK_PATTERN_NAME_HALF          =   0x48

; 削り
BACK_HIT_S                      =   0x06
BACK_HIT_M                      =   0x0c
BACK_HIT_L                      =   0x10

; 外部関数宣言
;

    .globl  _BackInitialize
    .globl  _BackUpdate
    .globl  _BackRender
    .globl  _BackHit
    .globl  _BackIsLight
    .globl  _BackPrintDark

; 外部変数宣言
;

    .globl  _back
