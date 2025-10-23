@set iasver=2.0
@setlocal DisableDelayedExpansion
@echo off

::============================================================================
::
::   IDM Activation Script (IAS) - Enhanced Edition
::
::   پروژه دانشجویی - نسخه بهبود یافته
::
::============================================================================

set "PATH=%SystemRoot%\System32;%SystemRoot%\System32\wbem;%SystemRoot%\System32\WindowsPowerShell\v1.0\"
if exist "%SystemRoot%\Sysnative\reg.exe" (
set "PATH=%SystemRoot%\Sysnative;%SystemRoot%\Sysnative\wbem;%SystemRoot%\Sysnative\WindowsPowerShell\v1.0\;%PATH%"
)

set "_cmdf=%~f0"
for %%# in (%*) do (
if /i "%%#"=="r1" set r1=1
if /i "%%#"=="r2" set r2=1
)

if exist %SystemRoot%\Sysnative\cmd.exe if not defined r1 (
setlocal EnableDelayedExpansion
start %SystemRoot%\Sysnative\cmd.exe /c ""!_cmdf!" %* r1"
exit /b
)

if exist %SystemRoot%\SysArm32\cmd.exe if %PROCESSOR_ARCHITECTURE%==AMD64 if not defined r2 (
setlocal EnableDelayedExpansion
start %SystemRoot%\SysArm32\cmd.exe /c ""!_cmdf!" %* r2"
exit /b
)

::========================================================================================================================================

set "blank="

sc query Null | find /i "RUNNING"
if %errorlevel% NEQ 0 (
echo:
echo [!] سرویس Null در حال اجرا نیست، ممکن است خطا رخ دهد...
echo:
ping 127.0.0.1 -n 5 >nul
)
cls

pushd "%~dp0"
>nul findstr /v "$" "%~nx0" && (
echo:
echo [خطا] مشکل در فرمت فایل یا خط خالی در انتهای اسکریپت
echo:
ping 127.0.0.1 -n 4 >nul
popd
exit /b
)
popd

::========================================================================================================================================

cls
title  IDM Activation Script v%iasver% - Enhanced Edition

set _args=
set _elev=
set _unattended=0
set _activate=0
set _freeze=0
set _reset=0

set _args=%*
if defined _args set _args=%_args:"=%
if defined _args (
for %%A in (%_args%) do (
if /i "%%A"=="-el"  set _elev=1
if /i "%%A"=="/res" set _reset=1
if /i "%%A"=="/frz" set _freeze=1
if /i "%%A"=="/act" set _activate=1
)
)

for %%A in (%_activate% %_freeze% %_reset%) do (if "%%A"=="1" set _unattended=1)

::========================================================================================================================================

set "nul1=1>nul"
set "nul2=2>nul"
set "nul6=2^>nul"
set "nul=>nul 2>&1"

set psc=powershell.exe
set winbuild=1
for /f "tokens=6 delims=[]. " %%G in ('ver') do set winbuild=%%G

set _NCS=1
if %winbuild% LSS 10586 set _NCS=0
if %winbuild% GEQ 10586 reg query "HKCU\Console" /v ForceV2 %nul2% | find /i "0x0" %nul1% && (set _NCS=0)

if %_NCS% EQU 1 (
for /F %%a in ('echo prompt $E ^| cmd') do set "esc=%%a"
set     "Red="41;97m""
set    "Gray="100;97m""
set   "Green="42;97m""
set   "Cyan="46;30m""
set    "Blue="44;97m""
set  "Purple="45;97m""
set  "_White="40;37m""
set  "_Green="40;92m""
set "_Yellow="40;93m""
set   "_Cyan="40;96m""
set "_Magenta="40;95m""
) else (
set     "Red="Red" "white""
set    "Gray="Darkgray" "white""
set   "Green="DarkGreen" "white""
set   "Cyan="Cyan" "Black""
set    "Blue="Blue" "white""
set  "Purple="Magenta" "white""
set  "_White="Black" "Gray""
set  "_Green="Black" "Green""
set "_Yellow="Black" "Yellow""
set   "_Cyan="Black" "Cyan""
set "_Magenta="Black" "Magenta""
)

set "nceline=echo: &echo ════ خطا ════ &echo:"
set "eline=echo: &call :_color %Red% "════ خطا ════" &echo:"
set "line=═══════════════════════════════════════════════════════════════════════════════"
set "_buf={$W=$Host.UI.RawUI.WindowSize;$B=$Host.UI.RawUI.BufferSize;$W.Height=38;$B.Height=300;$Host.UI.RawUI.WindowSize=$W;$Host.UI.RawUI.BufferSize=$B;}"

::========================================================================================================================================

if %winbuild% LSS 7600 (
%nceline%
echo نسخه ویندوز پشتیبانی نمی‌شود [%winbuild%]
echo این پروژه فقط برای Windows 7/8/8.1/10/11 طراحی شده است
goto done2
)

for %%# in (powershell.exe) do @if "%%~$PATH:#"=="" (
%nceline%
echo PowerShell در سیستم یافت نشد
goto done2
)

::========================================================================================================================================

set "_work=%~dp0"
if "%_work:~-1%"=="\" set "_work=%_work:~0,-1%"

set "_batf=%~f0"
set "_batp=%_batf:'=''%"

set _PSarg="""%~f0""" -el %_args%
set _PSarg=%_PSarg:'=''%

set "_appdata=%appdata%"
set "_ttemp=%userprofile%\AppData\Local\Temp"

setlocal EnableDelayedExpansion

::========================================================================================================================================

echo "!_batf!" | find /i "!_ttemp!" %nul1% && (
if /i not "!_work!"=="!_ttemp!" (
%eline%
echo اسکریپت از پوشه Temp اجرا شده است
echo لطفا فایل را از حالت فشرده خارج کرده و سپس اجرا کنید
echo:
goto done2
)
)

::========================================================================================================================================

REM :PowerShellTest: $ExecutionContext.SessionState.LanguageMode :PowerShellTest:

%psc% "$f=[io.file]::ReadAllText('!_batp!') -split ':PowerShellTest:\s*';iex ($f[1])" | find /i "FullLanguage" %nul1% || (
%eline%
%psc% $ExecutionContext.SessionState.LanguageMode
echo:
echo PowerShell به درستی کار نمی‌کند
echo اگر محدودیتی روی PowerShell اعمال کرده‌اید، آن را بردارید
echo:
goto done2
)

::========================================================================================================================================

%nul1% fltmc || (
if not defined _elev %psc% "start cmd.exe -arg '/c \"!_PSarg!\"' -verb runas" && exit /b
%eline%
echo این اسکریپت نیاز به دسترسی مدیر (Administrator) دارد
echo روی فایل کلیک راست کرده و 'Run as administrator' را انتخاب کنید
goto done2
)

::========================================================================================================================================

set quedit=
set terminal=

if %_unattended%==1 (
set quedit=1
set terminal=1
)

for %%# in (%_args%) do (if /i "%%#"=="-qedit" set quedit=1)

if %winbuild% LSS 10586 (
reg query HKCU\Console /v QuickEdit %nul2% | find /i "0x0" %nul1% && set quedit=1
)

if %winbuild% GEQ 17763 (
set "launchcmd=start conhost.exe %psc%"
) else (
set "launchcmd=%psc%"
)

set "d1=$t=[AppDomain]::CurrentDomain.DefineDynamicAssembly(4, 1).DefineDynamicModule(2, $False).DefineType(0);"
set "d2=$t.DefinePInvokeMethod('GetStdHandle', 'kernel32.dll', 22, 1, [IntPtr], @([Int32]), 1, 3).SetImplementationFlags(128);"
set "d3=$t.DefinePInvokeMethod('SetConsoleMode', 'kernel32.dll', 22, 1, [Boolean], @([IntPtr], [Int32]), 1, 3).SetImplementationFlags(128);"
set "d4=$k=$t.CreateType(); $b=$k::SetConsoleMode($k::GetStdHandle(-10), 0x0080);"

if defined quedit goto :skipQE
%launchcmd% "%d1% %d2% %d3% %d4% & cmd.exe '/c' '!_PSarg! -qedit'" &exit /b
:skipQE

::========================================================================================================================================

cls
title  IDM Activation Script v%iasver% - پروژه دانشجویی

echo:
echo ▓ در حال بارگذاری...

::========================================================================================================================================

%psc% "Get-WmiObject -Class Win32_ComputerSystem | Select-Object -Property CreationClassName" %nul2% | find /i "computersystem" %nul1% || (
%eline%
%psc% "Get-WmiObject -Class Win32_ComputerSystem | Select-Object -Property CreationClassName"
echo:
echo WMI به درستی کار نمی‌کند
echo:
goto done2
)

::========================================================================================================================================

set _sid=
for /f "delims=" %%a in ('%psc% "([System.Security.Principal.NTAccount](Get-WmiObject -Class Win32_ComputerSystem).UserName).Translate([System.Security.Principal.SecurityIdentifier]).Value" %nul6%') do (set _sid=%%a)
 
reg query HKU\%_sid%\Software %nul% || (
for /f "delims=" %%a in ('%psc% "$explorerProc = Get-Process -Name explorer | Where-Object {$_.SessionId -eq (Get-Process -Id $pid).SessionId} | Select-Object -First 1; $sid = (gwmi -Query ('Select * From Win32_Process Where ProcessID=' + $explorerProc.Id)).GetOwnerSid().Sid; $sid" %nul6%') do (set _sid=%%a)
)

reg query HKU\%_sid%\Software %nul% || (
%eline%
echo:
echo [%_sid%]
echo شناسه کاربری (SID) یافت نشد
echo:
goto done2
)

::========================================================================================================================================

%nul% reg delete HKCU\IAS_TEST /f
%nul% reg delete HKU\%_sid%\IAS_TEST /f

set HKCUsync=$null
%nul% reg add HKCU\IAS_TEST
%nul% reg query HKU\%_sid%\IAS_TEST && (
set HKCUsync=1
)

%nul% reg delete HKCU\IAS_TEST /f
%nul% reg delete HKU\%_sid%\IAS_TEST /f

for /f "skip=2 tokens=2*" %%a in ('reg query "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment" /v PROCESSOR_ARCHITECTURE') do set arch=%%b
if /i not "%arch%"=="x86" set arch=x64

if "%arch%"=="x86" (
set "CLSID=HKCU\Software\Classes\CLSID"
set "CLSID2=HKU\%_sid%\Software\Classes\CLSID"
set "HKLM=HKLM\Software\Internet Download Manager"
) else (
set "CLSID=HKCU\Software\Classes\Wow6432Node\CLSID"
set "CLSID2=HKU\%_sid%\Software\Classes\Wow6432Node\CLSID"
set "HKLM=HKLM\SOFTWARE\Wow6432Node\Internet Download Manager"
)

for /f "tokens=2*" %%a in ('reg query "HKU\%_sid%\Software\DownloadManager" /v ExePath %nul6%') do call set "IDMan=%%b"

if not exist "%IDMan%" (
if %arch%==x64 set "IDMan=%ProgramFiles(x86)%\Internet Download Manager\IDMan.exe"
if %arch%==x86 set "IDMan=%ProgramFiles%\Internet Download Manager\IDMan.exe"
)

if not exist %SystemRoot%\Temp md %SystemRoot%\Temp
set "idmcheck=tasklist /fi "imagename eq idman.exe" | findstr /i "idman.exe" %nul1%"

%nul% reg add %CLSID2%\IAS_TEST
%nul% reg query %CLSID2%\IAS_TEST || (
%eline%
echo خطا در نوشتن رجیستری در %CLSID2%
echo:
goto done2
)

%nul% reg delete %CLSID2%\IAS_TEST /f

::========================================================================================================================================

if %_reset%==1 goto :_reset
if %_activate%==1 (set frz=0&goto :_activate)
if %_freeze%==1 (set frz=1&goto :_activate)

:MainMenu

cls
title  IDM Activation Script v%iasver% - منوی اصلی
if not defined terminal mode 80, 32

echo:
echo:
call :_color %Cyan% "        ╔═══════════════════════════════════════════════════════════════════╗"
call :_color %Cyan% "        ║                                                                   ║"
call :_color %Cyan% "        ║            IDM Activation Script - Enhanced Edition              ║"
call :_color %Cyan% "        ║                     پروژه دانشجویی v%iasver%                          ║"
call :_color %Cyan% "        ║                                                                   ║"
call :_color %Cyan% "        ╚═══════════════════════════════════════════════════════════════════╝"
echo:
echo:
call :_color %_Cyan% "        ┌───────────────────────────────────────────────────────────────────┐"
echo:
call :_color2 %_White% "           " %_Green% "[1] فریز کردن نسخه آزمایشی (Freeze Trial)"
echo:
call :_color2 %_White% "           " %_Green% "[2] فعال‌سازی (Activate)"
echo:
call :_color2 %_White% "           " %_Green% "[3] بازنشانی (Reset Activation)"
echo:
call :_color %_Cyan% "        ├───────────────────────────────────────────────────────────────────┤"
echo:
call :_color2 %_White% "           " %_Yellow% "[4] دانلود IDM"
echo:
call :_color2 %_White% "           " %_Yellow% "[5] راهنما و پشتیبانی"
echo:
call :_color2 %_White% "           " %_Yellow% "[0] خروج"
echo:
call :_color %_Cyan% "        └───────────────────────────────────────────────────────────────────┘"
echo:
echo:
call :_color2 %_White% "             " %_Magenta% "یک گزینه را انتخاب کنید [1,2,3,4,5,0]: "
choice /C:123450 /N
set _erl=%errorlevel%

if %_erl%==6 exit /b
if %_erl%==5 start https://github.com/nscl5/IDM-Activation & goto MainMenu
if %_erl%==4 start https://www.internetdownloadmanager.com/download.html & goto MainMenu
if %_erl%==3 goto _reset
if %_erl%==2 (set frz=0&goto :_activate)
if %_erl%==1 (set frz=1&goto :_activate)
goto :MainMenu

::========================================================================================================================================

:_reset

cls
if not %HKCUsync%==1 (
if not defined terminal mode 153, 38
) else (
if not defined terminal mode 113, 38
)
if not defined terminal %psc% "&%_buf%" %nul%

echo:
call :_color %Purple% "╔═══════════════════════════════════════════════════════════════════════════╗"
call :_color %Purple% "║                         بازنشانی فعال‌سازی                                ║"
call :_color %Purple% "╚═══════════════════════════════════════════════════════════════════════════╝"
echo:

%idmcheck% && (
echo ▓ بستن IDM...
taskkill /f /im idman.exe
)

set _time=
for /f %%a in ('%psc% "(Get-Date).ToString('yyyyMMdd-HHmmssfff')"') do set _time=%%a

echo:
echo ▓ ایجاد نسخه پشتیبان از کلیدهای رجیستری در %SystemRoot%\Temp

reg export %CLSID% "%SystemRoot%\Temp\_Backup_HKCU_CLSID_%_time%.reg"
if not %HKCUsync%==1 reg export %CLSID2% "%SystemRoot%\Temp\_Backup_HKU-%_sid%_CLSID_%_time%.reg"

call :delete_queue
%psc% "$sid = '%_sid%'; $HKCUsync = %HKCUsync%; $lockKey = $null; $deleteKey = 1; $f=[io.file]::ReadAllText('!_batp!') -split ':regscan\:.*';iex ($f[1])"

call :add_key

echo:
echo %line%
echo:
call :_color %Green% "✓ عملیات بازنشانی با موفقیت انجام شد"
echo:

goto done

:delete_queue

echo:
echo ▓ حذف کلیدهای رجیستری IDM...
echo:

for %%# in (
""HKCU\Software\DownloadManager" "/v" "FName""
""HKCU\Software\DownloadManager" "/v" "LName""
""HKCU\Software\DownloadManager" "/v" "Email""
""HKCU\Software\DownloadManager" "/v" "Serial""
""HKCU\Software\DownloadManager" "/v" "scansk""
""HKCU\Software\DownloadManager" "/v" "tvfrdt""
""HKCU\Software\DownloadManager" "/v" "radxcnt""
""HKCU\Software\DownloadManager" "/v" "LstCheck""
""HKCU\Software\DownloadManager" "/v" "ptrk_scdt""
""HKCU\Software\DownloadManager" "/v" "LastCheckQU""
"%HKLM%"
) do for /f "tokens=* delims=" %%A in ("%%~#") do (
set "reg="%%~A"" &reg query !reg! %nul% && call :del
)

if not %HKCUsync%==1 for %%# in (
""HKU\%_sid%\Software\DownloadManager" "/v" "FName""
""HKU\%_sid%\Software\DownloadManager" "/v" "LName""
""HKU\%_sid%\Software\DownloadManager" "/v" "Email""
""HKU\%_sid%\Software\DownloadManager" "/v" "Serial""
""HKU\%_sid%\Software\DownloadManager" "/v" "scansk""
""HKU\%_sid%\Software\DownloadManager" "/v" "tvfrdt""
""HKU\%_sid%\Software\DownloadManager" "/v" "radxcnt""
""HKU\%_sid%\Software\DownloadManager" "/v" "LstCheck""
""HKU\%_sid%\Software\DownloadManager" "/v" "ptrk_scdt""
""HKU\%_sid%\Software\DownloadManager" "/v" "LastCheckQU""
) do for /f "tokens=* delims=" %%A in ("%%~#") do (
set "reg="%%~A"" &reg query !reg! %nul% && call :del
)

exit /b

:del

reg delete %reg% /f %nul%

if "%errorlevel%"=="0" (
set "reg=%reg:"=%"
echo   ✓ حذف شد - !reg!
) else (
set "reg=%reg:"=%"
call :_color2 %Red% "  ✗ خطا - !reg!"
)

exit /b

::========================================================================================================================================

:_activate

cls
if not %HKCUsync%==1 (
if not defined terminal mode 153, 38
) else (
if not defined terminal mode 113, 38
)
if not defined terminal %psc% "&%_buf%" %nul%

echo:
if not exist "%IDMan%" (
call :_color %Red% "✗ نرم‌افزار IDM نصب نشده است"
echo:
echo می‌توانید از لینک زیر دانلود کنید:
echo https://www.internetdownloadmanager.com/download.html
goto done
)

set _int=
for /f "delims=[] tokens=2" %%# in ('ping -n 1 internetdownloadmanager.com') do (if not [%%#]==[] set _int=1)

if not defined _int (
%psc% "$t = New-Object Net.Sockets.TcpClient;try{$t.Connect("""internetdownloadmanager.com""", 80)}catch{};$t.Connected" | findstr /i "true" %nul1% || (
call :_color %Red% "✗ عدم اتصال به internetdownloadmanager.com"
goto done
)
call :_color %Gray% "⚠ دستور Ping با خطا مواجه شد"
echo:
)

for /f "skip=2 tokens=2*" %%a in ('reg query "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion" /v ProductName 2^>nul') do set "regwinos=%%b"
for /f "skip=2 tokens=2*" %%a in ('reg query "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment" /v PROCESSOR_ARCHITECTURE') do set "regarch=%%b"
for /f "tokens=6-7 delims=[]. " %%i in ('ver') do if "%%j"=="" (set fullbuild=%%i) else (set fullbuild=%%i.%%j)
for /f "tokens=2*" %%a in ('reg query "HKU\%_sid%\Software\DownloadManager" /v idmvers %nul6%') do set "IDMver=%%b"

call :_color %_Cyan% "▓ اطلاعات سیستم: [%regwinos% | %fullbuild% | %regarch% | IDM: %IDMver%]"
echo:

%idmcheck% && (echo ▓ بستن IDM... & taskkill /f /im idman.exe)

set _time=
for /f %%a in ('%psc% "(Get-Date).ToString('yyyyMMdd-HHmmssfff')"') do set _time=%%a

echo:
echo ▓ ایجاد نسخه پشتیبان از کلیدهای رجیستری در %SystemRoot%\Temp

reg export %CLSID% "%SystemRoot%\Temp\_Backup_HKCU_CLSID_%_time%.reg"
if not %HKCUsync%==1 reg export %CLSID2% "%SystemRoot%\Temp\_Backup_HKU-%_sid%_CLSID_%_time%.reg"

call :delete_queue
call :add_key

%psc% "$sid = '%_sid%'; $HKCUsync = %HKCUsync%; $lockKey = 1; $deleteKey = $null; $toggle = 1; $f=[io.file]::ReadAllText('!_batp!') -split ':regscan\:.*';iex ($f[1])"

if %frz%==0 call :register_IDM

call :download_files
if not defined _fileexist (
%eline%
echo ✗ خطا در دانلود فایل‌ها با IDM
echo:
goto :done
)

%psc% "$sid = '%_sid%'; $HKCUsync = %HKCUsync%; $lockKey = 1; $deleteKey = $null; $f=[io.file]::ReadAllText('!_batp!') -split ':regscan\:.*';iex ($f[1])"

echo:
echo %line%
echo:
if %frz%==0 (
call :_color %Green% "✓ فعال‌سازی IDM با موفقیت انجام شد"
echo:
call :_color %Gray% "⚠ در صورت مشاهده پنجره سریال جعلی، از گزینه Freeze Trial استفاده کنید"
) else (
call :_color %Green% "✓ دوره آزمایشی 30 روزه IDM با موفقیت فریز شد"
echo:
call :_color %Gray% "⚠ در صورت مشاهده پیام ثبت‌نام، IDM را مجددا نصب کنید"
)

::========================================================================================================================================

:done

echo %line%
echo:
echo:
if %_unattended%==1 timeout /t 2 & exit /b

if defined terminal (
call :_color %_Yellow% "▶ برای بازگشت کلید 0 را فشار دهید..."
choice /c 0 /n
) else (
call :_color %_Yellow% "▶ برای بازگشت هر کلیدی را فشار دهید..."
pause %nul1%
)
goto MainMenu

:done2

if %_unattended%==1 timeout /t 2 & exit /b

if defined terminal (
echo ▶ برای خروج کلید 0 را فشار دهید...
choice /c 0 /n
) else (
echo ▶ برای خروج هر کلیدی را فشار دهید...
pause %nul1%
)
exit /b

::========================================================================================================================================

:_rcont

reg add %reg% %nul%
call :add
exit /b

:register_IDM

echo:
echo ▓ اعمال اطلاعات ثبت‌نام...
echo:

set /a fname = %random% %% 9999 + 1000
set /a lname = %random% %% 9999 + 1000
set email=%fname%.%lname%@tonec.com

for /f "delims=" %%a in ('%psc% "$key = -join ((Get-Random -Count  20 -InputObject ([char[]]('ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789'))));$key = ($key.Substring(0,  5) + '-' + $key.Substring(5,  5) + '-' + $key.Substring(10,  5) + '-' + $key.Substring(15,  5) + $key.Substring(20));Write-Output $key" %nul6%') do (set key=%%a)

set "reg=HKCU\SOFTWARE\DownloadManager /v FName /t REG_SZ /d "%fname%"" & call :_rcont
set "reg=HKCU\SOFTWARE\DownloadManager /v LName /t REG_SZ /d "%lname%"" & call :_rcont
set "reg=HKCU\SOFTWARE\DownloadManager /v Email /t REG_SZ /d "%email%"" & call :_rcont
set "reg=HKCU\SOFTWARE\DownloadManager /v Serial /t REG_SZ /d "%key%"" & call :_rcont


if not %HKCUsync%==1 (
set "reg=HKU\%_sid%\SOFTWARE\DownloadManager /v FName /t REG_SZ /d "%fname%"" & call :_rcont
set "reg=HKU\%_sid%\SOFTWARE\DownloadManager /v LName /t REG_SZ /d "%lname%"" & call :_rcont
set "reg=HKU\%_sid%\SOFTWARE\DownloadManager /v Email /t REG_SZ /d "%email%"" & call :_rcont
set "reg=HKU\%_sid%\SOFTWARE\DownloadManager /v Serial /t REG_SZ /d "%key%"" & call :_rcont
)
exit /b

:download_files

echo:
echo ▓ در حال انجام چند دانلود برای ایجاد کلیدهای رجیستری، لطفا صبر کنید...
echo:

set "file=%SystemRoot%\Temp\temp.png"
set _fileexist=

set link=https://www.internetdownloadmanager.com/images/idm_box_min.png
call :download
set link=https://www.internetdownloadmanager.com/register/IDMlib/images/idman_logos.png
call :download
set link=https://www.internetdownloadmanager.com/pictures/idm_about.png
call :download

echo:
timeout /t 3 %nul1%
%idmcheck% && taskkill /f /im idman.exe
if exist "%file%" del /f /q "%file%"
exit /b

:download

set /a attempt=0
if exist "%file%" del /f /q "%file%"
start "" /B "%IDMan%" /n /d "%link%" /p "%SystemRoot%\Temp" /f temp.png

:check_file

timeout /t 1 %nul1%
set /a attempt+=1
if exist "%file%" set _fileexist=1&exit /b
if %attempt% GEQ 20 exit /b
goto :Check_file

::========================================================================================================================================

:add_key

echo:
echo ▓ در حال افزودن کلید رجیستری...
echo:

set "reg="%HKLM%" /v "AdvIntDriverEnabled2""

reg add %reg% /t REG_DWORD /d "1" /f %nul%

:add

if "%errorlevel%"=="0" (
set "reg=%reg:"=%"
echo   ✓ اضافه شد - !reg!
) else (
set "reg=%reg:"=%"
call :_color2 %Red% "  ✗ خطا - !reg!"
)
exit /b

::========================================================================================================================================

:regscan:
$finalValues = @()

$arch = (Get-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Environment').PROCESSOR_ARCHITECTURE
if ($arch -eq "x86") {
  $regPaths = @("HKCU:\Software\Classes\CLSID", "Registry::HKEY_USERS\$sid\Software\Classes\CLSID")
} else {
  $regPaths = @("HKCU:\Software\Classes\WOW6432Node\CLSID", "Registry::HKEY_USERS\$sid\Software\Classes\Wow6432Node\CLSID")
}

foreach ($regPath in $regPaths) {
    if (($regPath -match "HKEY_USERS") -and ($HKCUsync -ne $null)) {
        continue
    }
	
	Write-Host
	Write-Host "▓ در حال جستجوی کلیدهای رجیستری IDM CLSID در $regPath"
	Write-Host
	
    $subKeys = Get-ChildItem -Path $regPath -ErrorAction SilentlyContinue -ErrorVariable lockedKeys | Where-Object { $_.PSChildName -match '^\{[A-F0-9]{8}-[A-F0-9]{4}-[A-F0-9]{4}-[A-F0-9]{4}-[A-F0-9]{12}\}$' }

    foreach ($lockedKey in $lockedKeys) {
        $leafValue = Split-Path -Path $lockedKey.TargetObject -Leaf
        $finalValues += $leafValue
        Write-Output "$leafValue - کلید قفل شده پیدا شد"
    }

    if ($subKeys -eq $null) {
	continue
	}
	
	$subKeysToExclude = "LocalServer32", "InProcServer32", "InProcHandler32"

    $filteredKeys = $subKeys | Where-Object { !($_.GetSubKeyNames() | Where-Object { $subKeysToExclude -contains $_ }) }

    foreach ($key in $filteredKeys) {
        $fullPath = $key.PSPath
        $keyValues = Get-ItemProperty -Path $fullPath -ErrorAction SilentlyContinue
        $defaultValue = $keyValues.PSObject.Properties | Where-Object { $_.Name -eq '(default)' } | Select-Object -ExpandProperty Value

        if (($defaultValue -match "^\d+$") -and ($key.SubKeyCount -eq 0)) {
            $finalValues += $($key.PSChildName)
            Write-Output "$($key.PSChildName) - پیدا شد: مقدار پیش‌فرض عددی و بدون زیرکلید"
            continue
        }
        if (($defaultValue -match "\+|=") -and ($key.SubKeyCount -eq 0)) {
            $finalValues += $($key.PSChildName)
            Write-Output "$($key.PSChildName) - پیدا شد: مقدار پیش‌فرض حاوی + یا = و بدون زیرکلید"
            continue
        }
        $versionValue = Get-ItemProperty -Path "$fullPath\Version" -ErrorAction SilentlyContinue | Select-Object -ExpandProperty '(default)' -ErrorAction SilentlyContinue
        if (($versionValue -match "^\d+$") -and ($key.SubKeyCount -eq 1)) {
            $finalValues += $($key.PSChildName)
            Write-Output "$($key.PSChildName) - پیدا شد: مقدار عددی در Version و بدون زیرکلید دیگر"
            continue
        }
        $keyValues.PSObject.Properties | ForEach-Object {
            if ($_.Name -match "MData|Model|scansk|Therad") {
                $finalValues += $($key.PSChildName)
                Write-Output "$($key.PSChildName) - پیدا شد: کلید حاوی MData, Model, scansk, Therad"
                continue
            }
        }
        if (($key.ValueCount -eq 0) -and ($key.SubKeyCount -eq 0)) {
            $finalValues += $($key.PSChildName)
            Write-Output "$($key.PSChildName) - پیدا شد: کلید خالی"
            continue
        }
    }
}

$finalValues = @($finalValues | Select-Object -Unique)

if ($finalValues -ne $null) {
    Write-Host
    if ($lockKey -ne $null) {
        Write-Host "▓ در حال قفل کردن کلیدهای رجیستری IDM CLSID..."
    }
    if ($deleteKey -ne $null) {
        Write-Host "▓ در حال حذف کلیدهای رجیستری IDM CLSID..."
    }
    Write-Host
} else {
    Write-Host "کلیدهای رجیستری IDM CLSID یافت نشد."
	Exit
}

if (($finalValues.Count -gt 20) -and ($toggle -ne $null)) {
	$lockKey = $null
	$deleteKey = 1
    Write-Host "تعداد کلیدهای IDM بیشتر از 20 است. در حال حذف به جای قفل کردن..."
	Write-Host
}

function Take-Permissions {
    param($rootKey, $regKey)
    $AssemblyBuilder = [AppDomain]::CurrentDomain.DefineDynamicAssembly(4, 1)
    $ModuleBuilder = $AssemblyBuilder.DefineDynamicModule(2, $False)
    $TypeBuilder = $ModuleBuilder.DefineType(0)

    $TypeBuilder.DefinePInvokeMethod('RtlAdjustPrivilege', 'ntdll.dll', 'Public, Static', 1, [int], @([int], [bool], [bool], [bool].MakeByRefType()), 1, 3) | Out-Null
    9,17,18 | ForEach-Object { $TypeBuilder.CreateType()::RtlAdjustPrivilege($_, $true, $false, [ref]$false) | Out-Null }

    $SID = New-Object System.Security.Principal.SecurityIdentifier('S-1-5-32-544')
    $IDN = ($SID.Translate([System.Security.Principal.NTAccount])).Value
    $Admin = New-Object System.Security.Principal.NTAccount($IDN)

    $everyone = New-Object System.Security.Principal.SecurityIdentifier('S-1-1-0')
    $none = New-Object System.Security.Principal.SecurityIdentifier('S-1-0-0')

    $key = [Microsoft.Win32.Registry]::$rootKey.OpenSubKey($regkey, 'ReadWriteSubTree', 'TakeOwnership')

    $acl = New-Object System.Security.AccessControl.RegistrySecurity
    $acl.SetOwner($Admin)
    $key.SetAccessControl($acl)

    $key = $key.OpenSubKey('', 'ReadWriteSubTree', 'ChangePermissions')
    $rule = New-Object System.Security.AccessControl.RegistryAccessRule($everyone, 'FullControl', 'ContainerInherit', 'None', 'Allow')
    $acl.ResetAccessRule($rule)
    $key.SetAccessControl($acl)

    if ($lockKey -ne $null) {
        $acl = New-Object System.Security.AccessControl.RegistrySecurity
        $acl.SetOwner($none)
        $key.SetAccessControl($acl)

        $key = $key.OpenSubKey('', 'ReadWriteSubTree', 'ChangePermissions')
        $rule = New-Object System.Security.AccessControl.RegistryAccessRule($everyone, 'FullControl', 'Deny')
        $acl.ResetAccessRule($rule)
        $key.SetAccessControl($acl)
    }
}

foreach ($regPath in $regPaths) {
    if (($regPath -match "HKEY_USERS") -and ($HKCUsync -ne $null)) {
        continue
    }
    foreach ($finalValue in $finalValues) {
        $fullPath = Join-Path -Path $regPath -ChildPath $finalValue
        if ($fullPath -match 'HKCU:') {
            $rootKey = 'CurrentUser'
        } else {
            $rootKey = 'Users'
        }

        $position = $fullPath.IndexOf("\")
        $regKey = $fullPath.Substring($position + 1)

        if ($lockKey -ne $null) {
            if (-not (Test-Path -Path $fullPath -ErrorAction SilentlyContinue)) { New-Item -Path $fullPath -Force -ErrorAction SilentlyContinue | Out-Null }
            Take-Permissions $rootKey $regKey
            try {
                Remove-Item -Path $fullPath -Force -Recurse -ErrorAction Stop
                Write-Host -back 'DarkRed' -fore 'white' "Failed - $fullPath"
            }
            catch {
                Write-Host "Locked - $fullPath"
            }
        }

        if ($deleteKey -ne $null) {
            if (Test-Path -Path $fullPath) {
                Remove-Item -Path $fullPath -Force -Recurse -ErrorAction SilentlyContinue
                if (Test-Path -Path $fullPath) {
                    Take-Permissions $rootKey $regKey
                    try {
                        Remove-Item -Path $fullPath -Force -Recurse -ErrorAction Stop
                        Write-Host "Deleted - $fullPath"
                    }
                    catch {
                        Write-Host -back 'DarkRed' -fore 'white' "Failed - $fullPath"
                    }
                }
                else {
                    Write-Host "Deleted - $fullPath"
                }
            }
        }
    }
}
:regscan:

::========================================================================================================================================
::
::   توابع کمکی برای رنگی کردن خروجی در کنسول
::
::========================================================================================================================================

:_color
:: این تابع یک رشته متن را با یک رنگ پس‌زمینه و متن مشخص چاپ می‌کند
:: %1: رنگ پس‌زمینه
:: %2: رنگ متن (برای حالت غیر-NCS) یا رشته متن (برای حالت NCS)
:: %3: رشته متن (برای حالت غیر-NCS)

if %_NCS% EQU 1 (
    :: استفاده از کدهای ANSI escape برای کنسول‌های مدرن
    echo %esc%[%~1%~2%esc%[0m
) else (
    :: استفاده از PowerShell برای سازگاری با کنسول‌های قدیمی
    %psc% write-host -back '%1' -fore '%2' '%3'
)
exit /b

:_color2
:: این تابع دو رشته متن را با دو جفت رنگ متفاوت در یک خط چاپ می‌کند
:: برای حالت غیر-NCS، متغیرهای رنگی به دو بخش (مثلاً "Black" "Gray") تقسیم می‌شوند

if %_NCS% EQU 1 (
    :: استفاده از کدهای ANSI escape
    echo %esc%[%~1%~2%esc%[%~3%~4%esc%[0m
) else (
    :: استفاده از PowerShell
    %psc% write-host -back '%1' -fore '%2' '%3' -NoNewline; write-host -back '%4' -fore '%5' '%6'
)
exit /b

::========================================================================================================================================
:: خط خالی زیر را رها کنید
