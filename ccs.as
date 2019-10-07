title "CCS"
#packopt type 0
#include "user32.as"
#const IDW_Main 0	// メイン画面
#const IDW_Sub  1	// サブの画面
#define DIID_DWebBrowserEvents2     "{34A715A0-6587-11D0-924A-0020AFC7AC4D}"
#define DISPID_NAVIGATECOMPLETE2    252
#define OLECMDID_CUT 11    ; 切り取り  ctrl+x
#define OLECMDID_COPY 12   ; コピー    ctrl+c
#define OLECMDID_PASTE 13  ; 貼り付け  ctrl+v
#define OLECMDID_UNDO 15   ; 元に戻す  ctrl+z
#define OLECMDID_DELETE 33 ; 削除 del
screen 0, ginfo(20), ginfo(21) ;最初の画面をスクリーン最大に
;return 