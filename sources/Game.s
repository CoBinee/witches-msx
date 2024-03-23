; Game.s : ゲーム
;


; モジュール宣言
;
    .module Game

; 参照ファイル
;
    .include    "bios.inc"
    .include    "vdp.inc"
    .include    "System.inc"
    .include    "App.inc"
    .include    "Sound.inc"
    .include	"Game.inc"
    .include    "Back.inc"
    .include    "Player.inc"
    .include    "Rival.inc"
    .include    "Cat.inc"
    .include    "Shot.inc"
    .include    "Dust.inc"

; 外部変数宣言
;

; マクロの定義
;


; CODE 領域
;
    .area   _CODE

; ゲームを初期化する
;
_GameInitialize::
    
    ; レジスタの保存
    
    ; スプライトのクリア
    call    _SystemClearSprite

    ; 背景の初期化
    call    _BackInitialize

    ; プレイヤの初期化
    call    _PlayerInitialize

    ; ライバルの初期化
    call    _RivalInitialize

    ; キャットの初期化
    call    _CatInitialize

    ; ショットの初期化
    call    _ShotInitialize

    ; ダストの初期化
    call    _DustInitialize
    
    ; ゲームの初期化
    ld      hl, #gameDefault
    ld      de, #_game
    ld      bc, #GAME_LENGTH
    ldir
    
    ; 描画の開始
    ld      hl, #(_videoRegister + VDP_R1)
    set     #VDP_R1_BL, (hl)

    ; 状態の設定
    ld      a, #GAME_STATE_START
    ld      (_game + GAME_STATE), a
    ld      a, #APP_STATE_GAME_UPDATE
    ld      (_app + APP_STATE), a
    
    ; レジスタの復帰
    
    ; 終了
    ret

; ゲームを更新する
;
_GameUpdate::
    
    ; レジスタの保存
    
    ; スプライトのクリア
    call    _SystemClearSprite

    ; 状態別の処理
    ld      hl, #10$
    push    hl
    ld      a, (_game + GAME_STATE)
    and     #0xf0
    rrca
    rrca
    rrca
    ld      e, a
    ld      d, #0x00
    ld      hl, #gameProc
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
GameNull:

    ; レジスタの保存

    ; レジスタの復帰

    ; 終了
    ret

; ゲームを開始する
;
GameStart:

    ; レジスタの保存

    ; 初期化
    ld      a, (_game + GAME_STATE)
    and     #0x0f
    jr      nz, 09$

    ; フレームの設定
    xor     a
    ld      (_game + GAME_FRAME), a

    ; 初期化の完了
    ld      hl, #(_game + GAME_STATE)
    inc     (hl)
09$:

    ; ゲームサイクル
    call    GameCycle

    ; 開始の表示
    ld      a, (_game + GAME_STATE)
    and     #0x0f
10$:
    dec     a
    jr      nz, 20$
    ld      hl, #(_game + GAME_FRAME)
    inc     (hl)
    ld      c, (hl)
    ld      hl, #(gameStartPatternName + 0x0000)
    ld      de, #(_patternName + 0x0120)
    call    GamePrintLine
    ld      a, c
    cp      #0x38
    jr      c, 19$
    xor     a
    ld      (_game + GAME_FRAME), a
    ld      hl, #(_game + GAME_STATE)
    inc     (hl)
19$:
    jr      90$

    ; 開始の消去
20$:
;   dec     a
;   jr      nz, 30$
    ld      hl, #(_game + GAME_FRAME)
    inc     (hl)
    ld      c, (hl)
    ld      hl, #(gameStartPatternName + 0x0020)
    ld      de, #(_patternName + 0x0120)
    call    GamePrintLine
    ld      a, c
    cp      #0x10
    jr      c, 29$

    ; 状態の更新
    ld      a, #GAME_STATE_PLAY
    ld      (_game + GAME_STATE), a
29$:
;   jr      90$

    ; 開始の完了
90$:

    ; レジスタの復帰

    ; 終了
    ret

; ゲームをプレイする
;
GamePlay:

    ; レジスタの保存

    ; 初期化
    ld      a, (_game + GAME_STATE)
    and     #0x0f
    jr      nz, 09$

    ; フラグの設定
    ld      hl, #(_game + GAME_FLAG)
    set     #GAME_FLAG_PLAY_BIT, (hl)

    ; 闇の描画
    call    _BackPrintDark

    ; 初期化の完了
    ld      hl, #(_game + GAME_STATE)
    inc     (hl)
09$:

    ; ヒット処理
    call    GameHit

    ; ゲームサイクル
    call    GameCycle

    ; 時間の更新
    ld      hl, #(_game + GAME_TIME_100)
    ld      a, (hl)
    inc     hl
    or      (hl)
    inc     hl
    or      (hl)
    jr      z, 10$
    ld      a, #0x09
    dec     (hl)
    jp      p, 19$
    ld      (hl), a
    dec     hl
    dec     (hl)
    jp      p, 19$
    ld      (hl), a
    dec     hl
    dec     (hl)
    jr      19$
10$:
    ld      a, #GAME_STATE_TIMEUP
    ld      (_game + GAME_STATE), a
;   jr      19$
19$:

    ; レジスタの復帰

    ; 終了
    ret

; 時間切れになる
;
GameTimeUp:

    ; レジスタの保存

    ; 初期化
    ld      a, (_game + GAME_STATE)
    and     #0x0f
    jr      nz, 09$

    ; フラグの設定
    ld      hl, #(_game + GAME_FLAG)
    res     #GAME_FLAG_PLAY_BIT, (hl)

    ; フレームの設定
    xor     a
    ld      (_game + GAME_FRAME), a

    ; SE の再生
    ld      a, #SOUND_SE_TIMEUP
    call    _SoundPlaySe

    ; 初期化の完了
    ld      hl, #(_game + GAME_STATE)
    inc     (hl)
09$:

    ; ゲームサイクル
    call    GameCycle

    ; タイムアップの表示
    ld      hl, #(_game + GAME_FRAME)
    inc     (hl)
    ld      c, (hl)
    ld      hl, #gameTimeUpPatternName
    ld      de, #(_patternName + 0x0100)
    ld      b, #0x03
10$:
    push    bc
    call    GamePrintLine
    ld      bc, #0x0020
    add     hl, bc
    ex      de, hl
    add     hl, bc
    ex      de, hl
    pop     bc
    djnz    10$
    ld      a, c
    cp      #0x40
    jr      c, 19$

    ; 状態の更新
    ld      a, #GAME_STATE_RESULT
    ld      (_game + GAME_STATE), a
19$:

    ; レジスタの復帰

    ; 終了
    ret

; ゲームの結果を表示する
;
GameResult:

    ; レジスタの保存

    ; 初期化
    ld      a, (_game + GAME_STATE)
    and     #0x0f
    jr      nz, 09$

    ; 結果の作成
    ld      hl, #(gameResultLine + 0x0000)
    ld      de, #(gameResultLine + 0x0001)
    ld      bc, #(0x00a0 - 0x0001)
    ld      (hl), #0x00
    ldir
    ld      hl, (_back + BACK_AREA_LIGHT_L)
    ld      de, (_back + BACK_AREA_DARK_L)
    or      a
    sbc     hl, de
    jr      z, 01$
    jr      c, 00$
    ld      hl, #(gameResultPatternName + 0x0000)
    jr      02$
00$:
    ld      hl, #(gameResultPatternName + 0x0020)
    jr      02$
01$:
    ld      hl, #(gameResultPatternName + 0x0040)
;   jr      02$
02$:
    ld      de, #(gameResultLine + 0x0020)
    ld      bc, #0x0020
    ldir

    ; トップスコアの更新
    ld      hl, (_back + BACK_AREA_LIGHT_L)
    call    _AppUpdateScore
    jr      nc, 03$
    ld      hl, #(gameResultPatternName + 0x0080)
    ld      de, #(gameResultLine + 0x006f)
    jr      04$
03$:
    ld      hl, #(gameResultPatternName + 0x0060)
    ld      de, #(gameResultLine + 0x006d)
;   jr      04$
04$:
    push    de
    ld      de, #(gameResultLine + 0x0060)
    ld      bc, #0x0020
    ldir
    pop     de
    ld      hl, #(_back + BACK_AREA_LIGHT_10000)
    ld      b, #BACK_AREA_LENGTH
    call    _AppPrintValueRight

    ; フレームの設定
    xor     a
    ld      (_game + GAME_FRAME), a

    ; 初期化の完了
    ld      hl, #(_game + GAME_STATE)
    inc     (hl)
09$:

    ; ゲームサイクル
    call    GameCycle

    ; 結果の表示
    ld      hl, #(_game + GAME_FRAME)
    ld      a, (hl)
    cp      #0x10
    jr      nc, 11$
    inc     a
    ld      (hl), a
    ld      c, a
    ld      hl, #gameResultLine
    ld      de, #(_patternName + 0x00e0)
    ld      b, #0x05
10$:
    push    bc
    call    GamePrintLine
    ld      bc, #0x0020
    add     hl, bc
    ex      de, hl
    add     hl, bc
    ex      de, hl
    pop     bc
    djnz    10$
    jr      19$

    ; キー入力待ち
11$:
    ld      a, (_input + INPUT_BUTTON_SPACE)
    dec     a
    jr      nz, 19$

    ; SE の再生
    ld      a, #SOUND_SE_CLICK
    call    _SoundPlaySe

    ; 状態の更新
    ld      a, #APP_STATE_TITLE_INITIALIZE
    ld      (_app + APP_STATE), a
19$:

    ; レジスタの復帰

    ; 終了
    ret

; ヒットを判定する
;
GameHit:

    ; レジスタの保存

    ; ショットとの判定
    ld      ix, #_shot
    ld      b, #SHOT_ENTRY
100$:
    push    bc
    ld      a, SHOT_STATE(ix)
    or      a
    jr      z, 190$

    ; ショットと背景のヒット
    ld      e, SHOT_POSITION_X(ix)
    ld      d, SHOT_POSITION_Y(ix)
    call    _BackHit
    jr      c, 180$
    jr      190$

    ; ショットの削除
180$:
    ld      SHOT_STATE(ix), #SHOT_STATE_NULL
;   jr      190$

    ; ショットとの判定の完了
190$:
    ld      bc, #SHOT_LENGTH
    add     ix, bc
    pop     bc
    djnz    100$

    ; プレイヤとの判定
    ld      a, (_player + PLAYER_DAMAGE)
    or      a
    jr      nz, 290$
    ld      hl, (_player + PLAYER_RECT_LEFT)
    ld      de, (_player + PLAYER_RECT_RIGHT)
    inc     e
    inc     d
    
    ; キャットとの判定
    ld      a, (_cat + CAT_POSITION_X)
    cp      l
    jr      c, 209$
    cp      e
    jr      nc, 209$
    ld      a, (_cat + CAT_POSITION_Y)
    sub     #CAT_SIZE_HEIGHT
    cp      h
    jr      c, 209$
    cp      d
    jr      nc, 209$
    ld      de, (_cat + CAT_POSITION_X)
    call    _PlayerDamage
    jr      290$
209$:
    jr      290$

    ; プレイヤとの判定の完了
290$:

    ; レジスタの復帰

    ; 終了
    ret

; ゲームの 1 サイクルを処理する
;
GameCycle:

    ; レジスタの保存

    ; 背景の更新
    call    _BackUpdate

    ; プレイヤの更新
    call    _PlayerUpdate

    ; ライバルの更新
    call    _RivalUpdate

    ; キャットの更新
    call    _CatUpdate

    ; ショットの更新
    call    _ShotUpdate

    ; ダストの更新
    call    _DustUpdate

    ; 背景の描画
    call    _BackRender

    ; プレイヤの描画
    call    _PlayerRender

    ; ライバルの描画
    call    _RivalRender

    ; キャットの描画
    call    _CatRender

    ; ショットの描画
    call    _ShotRender
    
    ; ダストの描画
    call    _DustRender

    ; レジスタの復帰

    ; 終了
    ret

; １行の演出表示を行う
;
GamePrintLine:

    ; レジスタの保存
    push    hl
    push    bc
    push    de

    ; hl < 転送元パターンネーム
    ; de < 転送先パターンネーム
    ; c  < フレーム数

    ; １行の表示
    ld      a, c
    cp      #0x10
    jr      c, 10$
    ld      c, #0x10
10$:
    ld      b, #0x00
    push    bc
    ld      a, #0x10
    sub     c
    ld      c, a
    add     hl, bc
    ex      de, hl
    add     hl, bc
    ex      de, hl
    pop     bc
    sla     c
    ldir

    ; レジスタの復帰
    pop     de
    pop     bc
    pop     hl

    ; 終了
    ret

; 定数の定義
;

; 状態別の処理
;
gameProc:
    
    .dw     GameNull
    .dw     GameStart
    .dw     GamePlay
    .dw     GameTimeUp
    .dw     GameResult

; ゲームの初期値
;
gameDefault:

    .db     GAME_STATE_NULL
    .db     GAME_FLAG_NULL
    .db     GAME_FRAME_NULL
    .db     0x09 ; GAME_TIME_NULL
    .db     0x09 ; GAME_TIME_NULL
    .db     0x09 ; GAME_TIME_NULL
    .db     0x00, 0x00

; 開始
;
gameStartPatternName:

    ; LIGHT UP THE DARKNESS
    .db     0x00, 0x00, 0x00, 0x00, 0x00, 0x2c, 0x29, 0x27, 0x28, 0x34, 0x00, 0x35, 0x30, 0x00, 0x34, 0x28
    .db     0x25, 0x00, 0x24, 0x21, 0x32, 0x2b, 0x2e, 0x25, 0x33, 0x33, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
    ; 
    .db     0x50, 0x50, 0x50, 0x50, 0x50, 0x50, 0x50, 0x50, 0x50, 0x50, 0x50, 0x50, 0x50, 0x50, 0x50, 0x50
    .db     0x50, 0x50, 0x50, 0x50, 0x50, 0x50, 0x50, 0x50, 0x50, 0x50, 0x50, 0x50, 0x50, 0x50, 0x50, 0x50

; 時間切れ
;
gameTimeUpPatternName:

    .db     0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
    .db     0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
    .db     0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x34, 0x29, 0x2d, 0x25
    .db     0x00, 0x35, 0x30, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
    .db     0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
    .db     0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00

; 結果
;
gameResultPatternName:

    ; YOU WIN!
    .db     0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x39, 0x2f, 0x35, 0x00
    .db     0x37, 0x29, 0x2e, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
    ; YOU LOSE
    .db     0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x39, 0x2f, 0x35, 0x00
    .db     0x2c, 0x2f, 0x33, 0x25, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
    ; DRAW
    .db     0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x24, 0x32
    .db     0x21, 0x37, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
    ; pt
    .db     0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
    .db     0x00, 0x00, 0x60, 0x61, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
    ; TOP! pt
    .db     0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x34, 0x2f, 0x30, 0x01, 0x00, 0x00
    .db     0x00, 0x00, 0x00, 0x00, 0x60, 0x61, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00


; DATA 領域
;
    .area   _DATA

; 変数の定義
;

; ゲーム
;
_game::
    
    .ds     GAME_LENGTH

; 結果
;
gameResultLine:

    .ds     0xa0
