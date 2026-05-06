#Requires AutoHotkey v2.0
; 添加此行，以获得更好的性能和可靠性
SendMode "Input"

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

; 当右Shift键被按下时
*RShift::
{
    ; 发送一个“盲”模式的右Shift按下事件。
    ; 这使得右Shift可以像往常一样作为修饰键（配合其他键打出大写字母等）。
    Send "{Blind}{RShift Down}"
}

; 当右Shift键被弹起时
*RShift Up::
{
    ; 先执行原本的右Shift弹起事件
    ; （此时小狼毫会接收到完整的 Shift 击键，从而触发 commit_code 把字母上屏）
    Send "{Blind}{RShift Up}"
    ; A_PriorKey记录了在此热键之前按下的键
    if (A_PriorKey = "RShift")
    {
        ; 稍微给小狼毫留 50 毫秒的反应时间，让它把英文字母稳稳打在屏幕上
        Sleep 50
        ; 然后执行 Win+空格，切走系统键盘
        Send "#{Space}"
    }
}

; --- 窗口切换 (Alt + 1-9) ---
;!1::Send "^#1"
;!2::Send "^#2"
;!3::Send "^#3"
;!4::Send "^#4"
;!5::Send "^#5"
;!6::Send "^#6"
;!7::Send "^#7"
;!8::Send "^#8"
;!9::Send "^#9"

; 窗口循环切换和关闭
;LAlt & l::AltTab
;LAlt & j::ShiftAltTab
;LAlt & q::Send "!{F4}"

; 创建信号文件切换obs/mpv状态
; Alt + D: 切换 暂停/恢复
;!d:: {
;    FileAppend("", EnvGet("TEMP") . "\obs_mpv_toggle_pause")
;}

; Alt + S: 下一曲 (切换文件并恢复录制)
;!S:: {
;    FileAppend("", EnvGet("TEMP") . "\mpv_toggle_next")
;}

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

Komorebic(cmd) {
    RunWait(format("komorebic.exe {}", cmd), , "Hide")
}

!q::Komorebic("close")
!m::Komorebic("minimize")
!e::Komorebic("toggle-maximize")

; Focus windows
!j::Komorebic("focus left")
!k::Komorebic("focus down")
!i::Komorebic("focus up")
!l::Komorebic("focus right")

; Move windows
!+j::Komorebic("move left")
!+k::Komorebic("move down")
!+i::Komorebic("move up")
!+l::Komorebic("move right")

; Workspaces
!1::Komorebic("focus-workspace 0")
!2::Komorebic("focus-workspace 1")
!3::Komorebic("focus-workspace 2")
!4::Komorebic("focus-workspace 3")
!5::Komorebic("focus-workspace 4")
!6::Komorebic("focus-workspace 5")
!7::Komorebic("focus-workspace 6")
!8::Komorebic("focus-workspace 7")

; Move windows across workspaces
!+1::Komorebic("move-to-workspace 0")
!+2::Komorebic("move-to-workspace 1")
!+3::Komorebic("move-to-workspace 2")
!+4::Komorebic("move-to-workspace 3")
!+5::Komorebic("move-to-workspace 4")
!+6::Komorebic("move-to-workspace 5")
!+7::Komorebic("move-to-workspace 6")
!+8::Komorebic("move-to-workspace 7")

!Enter::
{
	Komorebic("focus-workspace 2")
	Sleep(50)
	if WinExist("C:\WINDOWS\SYSTEM32\wsl.exe")
	{
		WinActivate("C:\WINDOWS\SYSTEM32\wsl.exe")
	}
	else
	{
		Run("wsl.exe -d archlinux")
	}
}

!+Enter::
{
	Komorebic("focus-workspace 1")
	Sleep(50)
	if WinExist("ahk_exe neovide.exe")
	{
		WinActivate("ahk_exe neovide.exe")
	}
	else
	{
		Run("D:\my_program\neovide.exe --frame none --wsl")
	}
}


!x::Run("D:\my_program\zen-browser\zen.exe")
