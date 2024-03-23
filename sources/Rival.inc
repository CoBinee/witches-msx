; Rival.inc : ライバル
;


; マクロの定義
;

; ライバル
RIVAL_STATE                     =   0x00
RIVAL_FLAG                      =   0x01
RIVAL_POSITION_X                =   0x02
RIVAL_POSITION_Y                =   0x03
RIVAL_SPEED_X                   =   0x04
RIVAL_SPEED_Y                   =   0x05
RIVAL_ACCEL_X                   =   0x06
RIVAL_ACCEL_Y                   =   0x07
RIVAL_DIRECTION                 =   0x08
RIVAL_ANIMATION                 =   0x09
RIVAL_SPRITE_L                  =   0x0a
RIVAL_SPRITE_H                  =   0x0b
RIVAL_LENGTH                    =   0x0c

; 状態
RIVAL_STATE_NULL                =   0x00
RIVAL_STATE_PLAY                =   0x10

; フラグ
RIVAL_FLAG_NULL                 =   0x00

; 位置
RIVAL_POSITION_NULL             =   0x00
RIVAL_POSITION_LEFT             =   0x00
RIVAL_POSITION_RIGHT            =   0xff
RIVAL_POSITION_TOP              =   0x00
RIVAL_POSITION_BOTTOM           =   0x9f

; 速度
RIVAL_SPEED_NULL                =   0x00
RIVAL_SPEED_X_MAXIMUM           =   0x10
RIVAL_SPEED_Y_MAXIMUM           =   0x20

; 加速度
RIVAL_ACCEL_NULL                =   0x00
RIVAL_ACCEL_X_MAXIMUM           =   0x00
RIVAL_ACCEL_Y_MAXIMUM           =   0x02

; 向き
RIVAL_DIRECTION_L               =   0x00
RIVAL_DIRECTION_R               =   0x01

; アニメーション
RIVAL_ANIMATION_NULL            =   0x00

; スプライト
RIVAL_SPRITE_NULL               =   0x00

; 外部関数宣言
;

    .globl  _RivalInitialize
    .globl  _RivalUpdate
    .globl  _RivalRender

; 外部変数宣言
;

    .globl  _rival
