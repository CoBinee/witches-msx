; Shot.inc : ショット
;


; マクロの定義
;

; ショット
SHOT_STATE                      =   0x00
SHOT_POSITION_X                 =   0x01
SHOT_POSITION_Y                 =   0x02
SHOT_SPEED_X                    =   0x03
SHOT_SPEED_Y                    =   0x04
SHOT_ANIMATION                  =   0x05
SHOT_LENGTH                     =   0x06
SHOT_ENTRY                      =   0x10

; 状態
SHOT_STATE_NULL                 =   0x00
SHOT_STATE_FIRE                 =   0x10

; 位置
SHOT_POSITION_NULL              =   0x00

; 速度
SHOT_SPEED_NULL                 =   0x00

; アニメーション
SHOT_ANIMATION_NULL             =   0x00

; 向き
SHOT_DIRECTION_0000             =   0x00
SHOT_DIRECTION_0022             =   0x01
SHOT_DIRECTION_0045             =   0x02
SHOT_DIRECTION_0107             =   0x03
SHOT_DIRECTION_0130             =   0x04
SHOT_DIRECTION_0152             =   0x05
SHOT_DIRECTION_0215             =   0x06
SHOT_DIRECTION_0237             =   0x07
SHOT_DIRECTION_0300             =   0x08
SHOT_DIRECTION_0322             =   0x09
SHOT_DIRECTION_0345             =   0x0a
SHOT_DIRECTION_0407             =   0x0b
SHOT_DIRECTION_0430             =   0x0c
SHOT_DIRECTION_0452             =   0x0d
SHOT_DIRECTION_0515             =   0x0e
SHOT_DIRECTION_0537             =   0x0f
SHOT_DIRECTION_0600             =   0x10
SHOT_DIRECTION_0622             =   0x11
SHOT_DIRECTION_0645             =   0x12
SHOT_DIRECTION_0707             =   0x13
SHOT_DIRECTION_0730             =   0x14
SHOT_DIRECTION_0752             =   0x15
SHOT_DIRECTION_0815             =   0x16
SHOT_DIRECTION_0837             =   0x17
SHOT_DIRECTION_0900             =   0x18
SHOT_DIRECTION_0922             =   0x19
SHOT_DIRECTION_0945             =   0x1a
SHOT_DIRECTION_1007             =   0x1b
SHOT_DIRECTION_1030             =   0x1c
SHOT_DIRECTION_1052             =   0x1d
SHOT_DIRECTION_1115             =   0x1e
SHOT_DIRECTION_1137             =   0x1f
SHOT_DIRECTION_LENGTH           =   0x20

; 外部関数宣言
;

    .globl  _ShotInitialize
    .globl  _ShotUpdate
    .globl  _ShotRender
    .globl  _ShotFire
    .globl  _ShotPrintAim

; 外部変数宣言
;

    .globl  _shot
