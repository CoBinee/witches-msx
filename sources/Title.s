; Title.s : タイトル
;


; モジュール宣言
;
    .module Title

; 参照ファイル
;
    .include    "bios.inc"
    .include    "vdp.inc"
    .include    "System.inc"
    .include    "App.inc"
    .include    "Sound.inc"
    .include	"Title.inc"

; 外部変数宣言
;

; マクロの定義
;


; CODE 領域
;
    .area   _CODE

; タイトルを初期化する
;
_TitleInitialize::
    
    ; レジスタの保存
    
    ; スプライトのクリア
    call    _SystemClearSprite

    ; タイトルの初期化
    ld      hl, #titleDefault
    ld      de, #_title
    ld      bc, #TITLE_LENGTH
    ldir

    ; スコアの取得
    ld      hl, (_app + APP_SCORE_L)
    ld      de, #(_title + TITLE_SCORE_10000)
    ld      b, #TITLE_SCORE_LENGTH
    call    _AppGetDecimal
    
    ; 描画の開始
    ld      hl, #(_videoRegister + VDP_R1)
    set     #VDP_R1_BL, (hl)

    ; 状態の設定
    ld      a, #TITLE_STATE_PLAY
    ld      (_title + TITLE_STATE), a
    ld      a, #APP_STATE_TITLE_UPDATE
    ld      (_app + APP_STATE), a
    
    ; レジスタの復帰
    
    ; 終了
    ret

; タイトルを更新する
;
_TitleUpdate::
    
    ; レジスタの保存
    
    ; スプライトのクリア
    call    _SystemClearSprite

    ; 状態別の処理
    ld      hl, #10$
    push    hl
    ld      a, (_title + TITLE_STATE)
    and     #0xf0
    rrca
    rrca
    rrca
    ld      e, a
    ld      d, #0x00
    ld      hl, #titleProc
    add     hl, de
    ld      e, (hl)
    inc     hl
    ld      d, (hl)
    ex      de, hl
    jp      (hl)
;   pop     hl
10$:

    ; レジスタの復帰
    
    ; 終了
    ret

; 何もしない
;
TitleNull:

    ; レジスタの保存

    ; レジスタの復帰

    ; 終了
    ret

; タイトルをプレイする
;
TitlePlay:

    ; レジスタの保存

    ; 初期化
    ld      a, (_title + TITLE_STATE)
    and     #0x0f
    jr      nz, 09$

    ; フレームの設定
    ld      hl, #0x0000
    ld      (_title + TITLE_FRAME_L), hl

    ; 背景の描画
    call    TitlePrintBack

    ; 初期化の完了
    ld      hl, #(_title + TITLE_STATE)
    inc     (hl)
09$:

    ; フレームの更新
    ld      hl, (_title + TITLE_FRAME_L)
    inc     hl
    ld      (_title + TITLE_FRAME_L), hl

    ; キー入力待ち
    ld      a, (_input + INPUT_BUTTON_SPACE)
    dec     a
    jr      nz, 19$

    ; 状態の更新
    ld      a, #TITLE_STATE_START
    ld      (_title + TITLE_STATE), a
19$:

    ; HIT SPACE BAR の描画
    call    TitlePrintHitSpaceBar

    ; レジスタの復帰

    ; 終了
    ret

; タイトルを開始する
;
TitleStart:

    ; レジスタの保存

    ; 初期化
    ld      a, (_title + TITLE_STATE)
    and     #0x0f
    jr      nz, 09$

    ; フレームの設定
    ld      hl, #(0x0030 * 0x0008)
    ld      (_title + TITLE_FRAME_L), hl

    ; SE の再生
    ld      a, #SOUND_SE_BOOT
    call    _SoundPlaySe

    ; 初期化の完了
    ld      hl, #(_title + TITLE_STATE)
    inc     (hl)
09$:

    ; フレームの更新
    ld      hl, (_title + TITLE_FRAME_L)
    ld      de, #0x0008
    or      a
    sbc     hl, de
    ld      (_title + TITLE_FRAME_L), hl
    jr      nz, 19$

    ; 状態の更新
    ld      a, #APP_STATE_GAME_INITIALIZE
    ld      (_app + APP_STATE), a
19$:

    ; HIT SPACE BAR の描画
    call    TitlePrintHitSpaceBar

    ; レジスタの復帰

    ; 終了
    ret

; 背景を描画する
;
TitlePrintBack:

    ; レジスタの保存

    ; パターンネームのクリア
    ld      hl, #(_patternName + 0x0000)
    ld      de, #(_patternName + 0x0001)
    ld      bc, #(0x0300 - 0x0001)
    ld      (hl), #0x00
    ldir

    ; ロゴの描画
    ld      hl, #titleBackLogoPatternName
    ld      de, #(_patternName + 0x00c0)
    ld      bc, #0x00c0
10$:
    ld      a, (hl)
    add     a, #0xa0
    ld      (de), a
    inc     hl
    inc     de
    dec     bc
    ld      a, b
    or      c
    jr      nz, 10$

    ; スコアの描画
    ld      hl, #titleBackScorePatternName
    ld      de, #(_patternName + 0x0200)
    ld      bc, #0x0020
    ldir
    ld      hl, #(_title + TITLE_SCORE_10000)
    ld      de, #(_patternName + 0x020f)
    ld      b, #TITLE_SCORE_LENGTH
    call    _AppPrintValueRight

    ; レジスタの復帰

    ; 終了
    ret

; HIT SPACE BAR を描画する
;
TitlePrintHitSpaceBar:

    ; レジスタの保存

    ; HIT SPACE BAR の描画

    ; スコアの描画
    ld      hl, #(titleHitSpaceBarPatternName + 0x0000)
    ld      a, (_title + TITLE_FRAME_L)
    and     #0x10
    jr      z, 10$
    ld      hl, #(titleHitSpaceBarPatternName + 0x0020)
10$:
    ld      de, #(_patternName + 0x0260)
    ld      bc, #0x0020
    ldir

    ; レジスタの復帰

    ; 終了
    ret

; 定数の定義
;

; 状態別の処理
;
titleProc:
    
    .dw     TitleNull
    .dw     TitlePlay
    .dw     TitleStart

; タイトルの初期値
;
titleDefault:

    .db     TITLE_STATE_NULL
    .db     TITLE_FLAG_NULL
    .dw     TITLE_FRAME_NULL
    .db     TITLE_SCORE_NULL
    .db     TITLE_SCORE_NULL
    .db     TITLE_SCORE_NULL
    .db     TITLE_SCORE_NULL
    .db     TITLE_SCORE_NULL

; 背景
;
titleBackLogoPatternName:

    .db     0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x02, 0x03, 0x00, 0x00, 0x00, 0x00, 0x00, 0x04
    .db     0x00, 0x05, 0x06, 0x07, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
    .db     0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x08, 0x09, 0x0A, 0x0B, 0x0C, 0x0D, 0x0E, 0x0F, 0x10
    .db     0x00, 0x00, 0x11, 0x12, 0x13, 0x14, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
    .db     0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x15, 0x16, 0x17, 0x18, 0x19, 0x1A, 0x1B, 0x1C, 0x1D
    .db     0x1E, 0x1F, 0x20, 0x21, 0x22, 0x23, 0x24, 0x25, 0x26, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
    .db     0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x15, 0x16, 0x27, 0x28, 0x19, 0x1A, 0x29, 0x2A, 0x2B
    .db     0x2C, 0x2D, 0x2E, 0x2A, 0x2F, 0x30, 0x31, 0x32, 0x33, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
    .db     0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x34, 0x35, 0x36, 0x37, 0x38, 0x39, 0x3A, 0x2A, 0x3B
    .db     0x3C, 0x3D, 0x3E, 0x2A, 0x3F, 0x40, 0x41, 0x42, 0x43, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
    .db     0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x44, 0x45, 0x46, 0x47, 0x48, 0x49, 0x4A, 0x4B
    .db     0x4C, 0x4D, 0x00, 0x4E, 0x4F, 0x50, 0x51, 0x52, 0x4F, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00

titleBackScorePatternName:

    .db     0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x34, 0x2f, 0x30, 0x0d, 0x00, 0x00
    .db     0x00, 0x00, 0x00, 0x00, 0x60, 0x61, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00

; HIT SPACE BAR
;
titleHitSpaceBarPatternName:

    ; HIT SPACE BAR
    .db     0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x28, 0x29, 0x34, 0x00, 0x33, 0x30, 0x21
    .db     0x23, 0x25, 0x00, 0x22, 0x21, 0x32, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
    ; 
    .db     0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
    .db     0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00


; DATA 領域
;
    .area   _DATA

; 変数の定義
;

; タイトル
;
_title::
    
    .ds     TITLE_LENGTH

