; Player.inc : プレイヤ
;


; マクロの定義
;

; プレイヤ
PLAYER_STATE                    =   0x00
PLAYER_FLAG                     =   0x01
PLAYER_POSITION_X               =   0x02
PLAYER_POSITION_Y               =   0x03
PLAYER_SPEED_X                  =   0x04
PLAYER_SPEED_Y                  =   0x05
PLAYER_DIRECTION                =   0x06
PLAYER_ANIMATION                =   0x07
PLAYER_SPRITE_L                 =   0x08
PLAYER_SPRITE_H                 =   0x09
PLAYER_AIM_POSITION_X           =   0x0a
PLAYER_AIM_POSITION_Y           =   0x0b
PLAYER_AIM_DIRECTION            =   0x0c
PLAYER_AIM_ROTATION             =   0x0d
PLAYER_AIM_ANIMATION            =   0x0e
PLAYER_FIRE                     =   0x0f
PLAYER_RECT_LEFT                =   0x10
PLAYER_RECT_TOP                 =   0x11
PLAYER_RECT_RIGHT               =   0x12
PLAYER_RECT_BOTTOM              =   0x13
PLAYER_DAMAGE                   =   0x14
PLAYER_LENGTH                   =   0x15

; 状態
PLAYER_STATE_NULL               =   0x00
PLAYER_STATE_PLAY               =   0x10

; フラグ
PLAYER_FLAG_NULL                =   0x00
PLAYER_FLAG_JUMP_BIT            =   0x00
PLAYER_FLAG_JUMP                =   (1 << PLAYER_FLAG_JUMP_BIT)
PLAYER_FLAG_AIM_BIT             =   0x01
PLAYER_FLAG_AIM                 =   (1 << PLAYER_FLAG_AIM_BIT)

; 位置
PLAYER_POSITION_NULL            =   0x00
PLAYER_POSITION_LEFT            =   0x00
PLAYER_POSITION_RIGHT           =   0xff
PLAYER_POSITION_TOP             =   0x00
PLAYER_POSITION_BOTTOM          =   0x9f

; 速度
PLAYER_SPEED_NULL               =   0x00
PLAYER_SPEED_X_MAXIMUM          =   0x20
PLAYER_SPEED_X_ACCEL            =   0x04
PLAYER_SPEED_X_BRAKE            =   0x02
PLAYER_SPEED_X_DAMAGE           =   0x28
PLAYER_SPEED_Y_MAXIMUM          =   0x40
PLAYER_SPEED_Y_JUMP             =   -0x40
PLAYER_SPEED_Y_GRAVITY          =   0x08
PLAYER_SPEED_Y_FLOAT            =   0x04

; 向き
PLAYER_DIRECTION_L              =   0x00
PLAYER_DIRECTION_R              =   0x01

; アニメーション
PLAYER_ANIMATION_NULL           =   0x00
PLAYER_ANIMATION_WALK           =   0x00
PLAYER_ANIMATION_JUMP           =   0x08

; スプライト
PLAYER_SPRITE_NULL              =   0x00

; 狙い
PLAYER_AIM_POSITION_NULL        =   0x00
PLAYER_AIM_DIRECTION_NULL       =   0x00
PLAYER_AIM_ROTATION_NULL        =   0x00
PLAYER_AIM_ROTATION_INTERVAL    =   0x02
PLAYER_AIM_ANIMATION_NULL       =   0x00

; 発射
PLAYER_FIRE_NULL                =   0x00
PLAYER_FIRE_INTERVAL            =   0x02

; 矩形
PLAYER_RECT_NULL                =   0x00

; 大きさ
PLAYER_SIZE_LEFT                =   0x04
PLAYER_SIZE_TOP                 =   0x0a
PLAYER_SIZE_RIGHT               =   0x03
PLAYER_SIZE_BOTTOM              =   0x00

; ダメージ
PLAYER_DAMAGE_NULL              =   0x00
PLAYER_DAMAGE_FRAME             =   0x18

; 外部関数宣言
;

    .globl  _PlayerInitialize
    .globl  _PlayerUpdate
    .globl  _PlayerRender
    .globl  _PlayerDamage

; 外部変数宣言
;

    .globl  _player
