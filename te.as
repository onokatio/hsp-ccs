	#include "sb.as"
dialog "bmp;*.jpg;*.gif", 16, "画像ファイル"  : if stat == 0  : mes "キャンセル"  : stop
    FileName = refstr

    picload FileName
    PicSizeX = ginfo_sx  : PicSizeY = ginfo_sy      ;画像の大きさを取得
    BarSize = ScrollBar_GetSystemSize()             ;バーの標準的な厚さ

    screen 1, PicSizeX + BarSize, PicSizeY + BarSize, , , , 320, 240    ;リサイズ可能ウィンドウ
    gcopy 0, 0, 0, PicSizeX, PicSizeY
    gosub *Window_PutScrollBar          ;ウィンドウにスクロールバーを配置する
    oncmd gosub *Window_PutScrollBar, 5 ;ウィンドウサイズが変更されると呼び出されるように
    ScrollBar_SetSubLabel *GetScroll    ;スクロールバー操作時にルーチンジャンプするように

    screen 0, 320, 20 * 6
    mes strf("画像サイズ：%4d×%4d", PicSizeX, PicSizeY)
    stop

*Window_PutScrollBar    ;ウィンドウの大きさが変更されたとき
    gsel 1  : clrobj                ;画面上のオブジェクトを破棄する

    ;横スクロールバーを配置する(まとめて設定する例)
    pos 0, ginfo_winy - BarSize     ;クライアント領域の底辺にくっつくように
    ScrollBar_Create ginfo_winx - BarSize, BarSize, 0, 0, PicSizeX - 1, ginfo_winx - BarSize, ginfo_vx, ginfo_winx / 4, ginfo_winx - BarSize
    XBarID = stat                   ;横スクのHSPオブジェクトID

    ;縦スクロールバーを配置する(個別に設定する例)
    pos ginfo_winx - BarSize, 0
    ScrollBar_Create BarSize, ginfo_winy - BarSize, 1
    YBarID = stat                   ;たてスクのHSPオブジェクトID
    ScrollBar_SetRange YBarID, 0, PicSizeY - 1, ginfo_winy - BarSize
    ScrollBar_SetStep  YBarID,  ginfo_winy / 4, ginfo_winy - BarSize
    ScrollBar_SetPos   YBarID,  ginfo_vy

    pos ginfo_winx - BarSize, ginfo_winy - BarSize  : winobj "STATIC", "", 0, $50000000, BarSize, BarSize   ;穴埋め

    ib = ginfo_vx, ginfo_vy, ginfo_winx - BarSize, ginfo_winy - BarSize
    gsel 0
    redraw 0  : color 255, 255, 255  : boxf  : color  : pos 0, 0
    mes strf("画像サイズ：%4d×%4d¥n表示サイズ：%4d×%4d¥nスクロール：%4d×%4d", PicSizeX, PicSizeY, ib(2), ib(3), ib, ib(1))
    redraw 1
    gsel 1      ;←戻しておかないとうまくいかないorz
    return

*GetScroll              ;スクロールバーが操作されてバーの値が変更されたとき
    gsel 1
    ib = ScrollBar_GetPos(XBarID), ScrollBar_GetPos(YBarID), ginfo_winx - BarSize, ginfo_winy - BarSize
    groll ib, ib(1)
    gsel 0
    redraw 0  : color 255, 255, 255  : boxf  : color  : pos 0, 0
    mes strf("画像サイズ：%4d×%4d¥n表示サイズ：%4d×%4d¥nスクロール：%4d×%4d", PicSizeX, PicSizeY, ib(2), ib(3), ib, ib(1))
    mes "ウィンドウID：" + ScrollBar_GetInfo(0)
    if ScrollBar_GetInfo(1) == $114  : mes "横スクロールバーを操作したです。"
    if ScrollBar_GetInfo(1) == $115  : mes "縦スクロールバーを操作したです。"
    if ScrollBar_GetInfo(3) == 0     : mes "矢印(減少)をつつきました。"
    if ScrollBar_GetInfo(3) == 1     : mes "矢印(増加)をつつきました。"
    if ScrollBar_GetInfo(3) == 2     : mes "空白(減少)をつつきました。"
    if ScrollBar_GetInfo(3) == 3     : mes "空白(増加)をつつきました。"
    if ScrollBar_GetInfo(3) == 5     : mes "つまみを動かしました。"
    redraw 1
    return
; http://www.tvg.ne.jp/menyukko/ ; Copyright(C) 2011-2012 衣日和 All rights reserved.