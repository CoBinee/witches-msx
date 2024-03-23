; Cat.inc : キャット
;


; マクロの定義
;

; キャット
CAT_STATE                       =   0x00
CAT_POSITION_X                  =   0x01
CAT_POSITION_Y                  =   0x02
CAT_POSITION_TARGET             =   0x03
CAT_DIRECTION                   =   0x04
CAT_ANIMATION                   =   0x05
CAT_SPRITE_L                    =   0x06
CAT_SPRITE_H                    =   0x07
CAT_LENGTH                      =   0x08

; 状態
CAT_STATE_NULL                  =   0x00
CAT_STATE_STAY                  =   0x10
CAT_STATE_WALK                  =   0x20

; フラグ
CAT_FLAG_NULL                   =   0x00

; 位置
CAT_POSITION_NULL               =   0x00
CAT_POSITION_LEFT               =   0x00
CAT_POSITION_RIGHT              =   0xff
CAT_POSITION_TOP                =   0x00
CAT_POSITION_BOTTOM             =   0x9f

; 向き
CAT_DIRECTION_L                 =   0x00
CAT_DIRECTION_R                 =   0x01

; アニメーション
CAT_ANIMATION_NULL              =   0x00

; スプライト
CAT_SPRITE_NULL                 =   0x00

; 大きさ
CAT_SIZE_HEIGHT                 =   0x06

; 外部関数宣言
;

    .globl  _CatInitialize
    .globl  _CatUpdate
    .globl  _CatRender

; 外部変数宣言
;

    .globl  _cat
