; Game.inc : ゲーム
;


; マクロの定義
;

; スプライト
GAME_SPRITE_NULL                =   0x00
GAME_SPRITE_PLAYER              =   0x00
GAME_SPRITE_RIVAL               =   0x08
GAME_SPRITE_CAT                 =   0x10
GAME_SPRITE_SHOT                =   0x14
GAME_SPRITE_AIM                 =   0x54
GAME_SPRITE_DUST                =   0x58
GAME_SPRITE_STATUS              =   0x78

; ゲーム
GAME_STATE                      =   0x00
GAME_FLAG                       =   0x01
GAME_FRAME                      =   0x02
GAME_TIME_100                   =   0x03
GAME_TIME_010                   =   0x04
GAME_TIME_001                   =   0x05
GAME_LENGTH                     =   0x08

; 状態
GAME_STATE_NULL                 =   0x00
GAME_STATE_START                =   0x10
GAME_STATE_PLAY                 =   0x20
GAME_STATE_TIMEUP               =   0x30
GAME_STATE_RESULT               =   0x40

; フラグ
GAME_FLAG_NULL                  =   0x00
GAME_FLAG_PLAY_BIT              =   0x00
GAME_FLAG_PLAY                  =   (1 << GAME_FLAG_PLAY_BIT)

; フレーム
GAME_FRAME_NULL                 =   0x00

; タイム
GAME_TIME_NULL                  =   0x00
GAME_TIME_LENGTH                =   0x03

; 外部関数宣言
;

    .globl  _GameInitialize
    .globl  _GameUpdate

; 外部変数宣言
;

    .globl  _game
