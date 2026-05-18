#Requires AutoHotkey v2.0
; 添加此行，以获得更好的性能和可靠性
SendMode "Input"

Esc::Capslock

; 禁用CapsLock键本身的切换大写功能
SetCapsLockState "AlwaysOff"

; 当CapsLock键被按下时
*CapsLock::
{
    ; 发送一个“盲”模式的Ctrl按下事件。
    ; 这使得CapsLock可以像Ctrl一样作为修饰键。
    ; 星号通配符允许在按住其他修饰键如 Shift 时也能触发此热键。
    Send "{Blind}{Ctrl Down}"
}

; 当CapsLock键被弹起时
*CapsLock Up::
{
    Send "{Blind}{Ctrl Up}"
    ; A_PriorKey是内置变量，记录了在此热键之前按下的键。
    ; 如果在按下和弹起CapsLock之间没有按过其他键，A_PriorKey的值就是"CapsLock"。
    if (A_PriorKey = "CapsLock")
    {
        ; 如果是单独按下并弹起，则发送Esc键。
        Send "{Esc}"
    }
}

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

; 创建信号文件切换obs/mpv状态
; Alt + D: 切换 暂停/恢复
!d:: {
    FileAppend("", EnvGet("TEMP") . "\obs_mpv_toggle_pause")
}

; Alt + S: 下一曲 (切换文件并恢复录制)
!S:: {
    FileAppend("", EnvGet("TEMP") . "\mpv_toggle_next")
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
