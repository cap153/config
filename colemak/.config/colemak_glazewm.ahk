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

; --- 键盘布局重映射 (类似 Colemak 布局) ---
; 使用 "$" 前缀防止热键连锁触发
; $e::f
; $r::p
; $t::g
; $y::j
; $u::l
; $i::u
; $o::y
; $p::`;
; $s::r
; $d::s
; $f::t
; $g::d
; $j::n
; $k::e
; $l::i
; $`;::o
; $n::k

!Enter::Run("wsl.exe -d archlinux")
!+Enter::Run("D:\my_program\neovide.exe --frame none --wsl")
!x::Run("D:\my_program\zen-browser\zen.exe")
