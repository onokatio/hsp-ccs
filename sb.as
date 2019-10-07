/*====================================================================
          スクロールバーモジュール(ControlObjectModule2.1号)
HSP3.3β3       2011. 7.25  プロトタイプ作成
HSP3.3RC1             8. 1  モジュール化
HSP3.3          2012. 3.10  作成：ScrollBar_GetSystemSize
----------------------------------------------------------------------
スクロールバーを配置する
    ScrollBar_Create 横幅, 縦幅, flag, 最小値, 最大値, サイズ, 位置, 移動量A, 移動量B
        横幅・縦幅      コントロールの大きさ
        flag            0(横スク) or 1(たてスク)
        最少値・最大値  スクロールバーの値の範囲
        サイズ          バー(つまみ部分)の大きさ
        位置            バーの現在位置
        移動量A         矢印部分をクリックしたときのバーの移動量
        移動量B         空白部分(バーの前後)をクリックしたときのバーの移動量
        stat            HSPオブジェクトID(以降の操作で必要になる)

スクロールバーの範囲を指定する
    ScrollBar_SetRange オブジェクトID, 最小値, 最大値, サイズ

スクロールバーを操作したときの移動量を指定する
    ScrollBar_SetStep オブジェクトID, 矢印の移動量, ブランクの移動量

スクロールバーの現在の位置を取得する関数
    ScrollBar_GetPos( オブジェクトID )

スクロールバーの位置を指定する
    ScrollBar_SetPos オブジェクトID, 新しい位置

スクロール時割り込み実行指定(#defineで定義)
    ScrollBar_SetSubLabel ジャンプ先ラベル(*xxx)
        ユーザーがスクロールバーを操作した時にサブルーチンジャンプを実行する(return必須)
        ラベル省略で割り込み無効

スクロール割り込み時に情報を取得する関数
    ScrollBar_GetInfo( 種類 )
        種類    0(ウィンドウID) or 1(メッセージID) or 2(操作要因) or 3(temp) or 4(ObjHandle)
                メッセージID    $114(276)横スクロール or $115(277)縦スクロール
                操作要因        5のときtempに位置が入る

スクロールバーの大きさ(システム設定値)を取得する関数
    ScrollBar_GetSystemSize()

====================================================================*/
#ifndef ScrollBarModuleIncluded
#define ScrollBarModuleIncluded
#module ScrollBarModule
#uselib "user32.dll"    ;スクロールバー
#func SetScrollInfo     "SetScrollInfo" int, int, var, int
#func GetScrollInfo     "GetScrollInfo" int, int, var
#define WS_CHILD            $40000000
#define WS_VISIBLE          $10000000
#define SBS_HORZ            0
#define SBS_VERT            1
#define WM_HSCROLL          $0114
#define WM_VSCROLL          $0115

#define SB_CTL              2

#define SB_LINEUP           0
#define SB_LINELEFT         0
#define SB_LINEDOWN         1
#define SB_LINERIGHT        1
#define SB_PAGEUP           2
#define SB_PAGELEFT         2
#define SB_PAGEDOWN         3
#define SB_PAGERIGHT        3
#define SB_THUMBTRACK       5

#define SIF_RANGE           $0001
#define SIF_PAGE            $0002
#define SIF_POS             $0004
#define SIF_DISABLENOSCROLL $0008
#define SIF_TRACKPOS        $0010
#define SIF_ALL             (SIF_RANGE | SIF_PAGE | SIF_POS | SIF_TRACKPOS)

#func GetWindowLong     "GetWindowLongA" int, int
#func SetWindowLong     "SetWindowLongA" int, int, int
#define GWL_USERDATA        -21     ;とりあえずここでいいや

#func GetSystemMetrics  "GetSystemMetrics" int  ;システムのいろいろ取得
#define SM_CXVSCROLL        2

#define global ScrollBar_SetSubLabel(%1=0) SbmLabel@ScrollBarModule=%1

#deffunc ScrollBar_Create int x, int y, int f, int n, int m, int s, int p, int a, int b, local i
    if f & 1  : ib(8) = SBS_VERT  : else  : ib(8) = SBS_HORZ
    winobj "SCROLLBAR", "", 0, WS_CHILD | WS_VISIBLE | ib(8), x, y, 0, 0  : i = stat
    ib = 7 * 4, SIF_ALL | SIF_DISABLENOSCROLL, n, m, s, p, 0
    SetScrollInfo objinfo(i, 2), SB_CTL, ib, 1
    if ib(8) == 0  : oncmd gosub *sbmGetMessageLabel, WM_HSCROLL
    if ib(8) == 1  : oncmd gosub *sbmGetMessageLabel, WM_VSCROLL
    ScrollBar_SetStep i, a, b
    return i

#deffunc ScrollBar_SetRange int i, int n, int m, int s
    ib = 7 * 4, SIF_ALL | SIF_DISABLENOSCROLL, 0, 0, 0, 0, 0
    GetScrollInfo objinfo(i, 2), SB_CTL, ib
    ib(2) = n, m, s
    SetScrollInfo objinfo(i, 2), SB_CTL, ib, 1
    return

#deffunc ScrollBar_SetStep int i, int a, int b
    SetWindowLong objinfo(i, 2), GWL_USERDATA, (a << 16 & $FFFF0000) | (b & $FFFF)
    return

#defcfunc ScrollBar_GetPos int i
    ib = 7 * 4, SIF_POS, 0, 0, 0, 0, 0
    GetScrollInfo objinfo(i, 2), SB_CTL, ib
    return ib(5)

#deffunc ScrollBar_SetPos int i, int p
    ib = 7 * 4, SIF_ALL | SIF_DISABLENOSCROLL, 0, 0, 0, 0, 0
    GetScrollInfo objinfo(i, 2), SB_CTL, ib
    ib(5) = p
    SetScrollInfo objinfo(i, 2), SB_CTL, ib, 1
    return

*sbmGetMessageLabel
    SBMI = ginfo_intid, iparam, wparam >> 16 & $FFFF, wparam & $FFFF, lparam
    if (0 <= SBMI(3) & SBMI(3) <= 3) | (SBMI(3) == 5) {
        ib = 7 * 4, SIF_ALL | SIF_DISABLENOSCROLL, 0, 0, 0, 0, 0, 0
        GetScrollInfo SBMI(4), SB_CTL, ib
        ib(7) = ib(5)       ;動いたチェック
        if SBMI(3) == 5 {
            ib(5) = ib(6)
        } else {
            GetWindowLong SBMI(4), GWL_USERDATA
            if SBMI(3) == 0  : ib(5) -= stat >> 16 & $FFFF
            if SBMI(3) == 1  : ib(5) += stat >> 16 & $FFFF
            if SBMI(3) == 2  : ib(5) -= stat       & $FFFF
            if SBMI(3) == 3  : ib(5) += stat       & $FFFF
        }
        SetScrollInfo SBMI(4), SB_CTL, ib, 1
        GetScrollInfo SBMI(4), SB_CTL, ib
        if vartype(SbmLabel) == 1 & ib(7) != ib(5) : gosub SbmLabel
    }
    return

#defcfunc ScrollBar_GetInfo int t
    return SBMI(t)

#defcfunc ScrollBar_GetSystemSize
    GetSystemMetrics SM_CXVSCROLL
    return stat

; http://www.tvg.ne.jp/menyukko/ ; Copyright(C) 2011-2012 衣日和 All rights reserved.
#global
#endif