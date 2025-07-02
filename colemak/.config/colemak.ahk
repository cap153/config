SetCapsLockState "AlwaysOff"
$*CapsLock::Control

; --- CapsLock 增强功能 (最终版) ---
; 使用 "$" 前缀强制使用键盘钩子, 并阻止热键被自身触发。
; 这是阻止原生 CapsLock 功能在所有环境下(包括RDP)生效的最可靠方法。
; 使用 "*" 前缀确保即使有修饰键(如Shift)也能触发。
;$*CapsLock::Control
;{
;    ; 等待 CapsLock 键被释放, 超时设为 150 毫秒
;    if KeyWait("CapsLock", "T0.15")
;    {
;        ; --- 短按 ---
;        ; 在 150ms 内释放, 发送 Escape
;        Send "{Escape}"
;    }
;    else
;    {
;        ; --- 长按 ---
;        ; 按下超过 200ms, 将其变为 Ctrl 键
;        Send "{Control Down}"
;        ; 等待 CapsLock 最终被物理释放
;        KeyWait "CapsLock"
;        Send "{Control Up}"
;    }
;    ; 'return' 在此至关重要, 它会消费掉物理的 CapsLock 按键事件,
;    ; 阻止操作系统执行默认的大小写切换。
;    return
;}

; --- 窗口切换 (Alt + 1-9) ---
!1::Send "^#1"
!2::Send "^#2"
!3::Send "^#3"
!4::Send "^#4"
!5::Send "^#5"
!6::Send "^#6"
!7::Send "^#7"
!8::Send "^#8"
!9::Send "^#9"

; 窗口循环切换和关闭
LAlt & l::AltTab
LAlt & j::ShiftAltTab
LAlt & q::Send "!{F4}"

; Alt + d 创建信号文件切换obs录屏状态
!d::
{
	; 获取系统临时文件夹的路径。
	TempPath := EnvGet("TEMP")

	; 构建触发文件的完整路径。
	TriggerFilePath := TempPath . "\obs_mpv_toggle_pause"
	
	; 创建触发文件。
	FileAppend("", TriggerFilePath)
}

; --- 键盘布局重映射 (类似 Colemak 布局) ---
; 使用 "$" 前缀防止热键连锁触发
$e::f
$r::p
$t::g
$y::j
$u::l
$i::u
$o::y
$p::`;
$s::r
$d::s
$f::t
$g::d
$j::n
$k::e
$l::i
$`;::o
$n::k