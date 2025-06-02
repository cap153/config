::后台运行
@echo off
if "%1" == "h" goto begin
mshta vbscript:createobject("wscript.shell").run("""%~nx0"" h",0)(window.close)&&exit
:begin
REM

::复制到桌面
copy disk_tools\colemak.exe %USERPROFILE%\Desktop

::开始执行
%USERPROFILE%\Desktop\colemak.exe