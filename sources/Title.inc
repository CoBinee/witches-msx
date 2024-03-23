; Title.inc : タイトル
;


; マクロの定義
;

; スプライト
TITLE_SPRITE_NULL               =   0x00

; タイトル
TITLE_STATE                     =   0x00
TITLE_FLAG                      =   0x01
TITLE_FRAME_L                   =   0x02
TITLE_FRAME_H                   =   0x03
TITLE_SCORE_10000               =   0x04
TITLE_SCORE_01000               =   0x05
TITLE_SCORE_00100               =   0x06
TITLE_SCORE_00010               =   0x07
TITLE_SCORE_00001               =   0x08
TITLE_LENGTH                    =   0x09

; 状態
TITLE_STATE_NULL                =   0x00
TITLE_STATE_PLAY                =   0x10
TITLE_STATE_START               =   0x20

; フラグ
TITLE_FLAG_NULL                 =   0x00

; フレーム
TITLE_FRAME_NULL                =   0x00

; スコア
TITLE_SCORE_NULL                =   0x00
TITLE_SCORE_LENGTH              =   0x05

; 外部関数宣言
;

    .globl  _TitleInitialize
    .globl  _TitleUpdate

; 外部変数宣言
;

    .globl  _title
