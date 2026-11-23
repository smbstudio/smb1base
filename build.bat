
@echo off
setlocal EnableDelayedExpansion

if not exist build mkdir build

for /f "delims=" %%a in ('type build_options.ini ^| findstr /v "^[;#\[]"') do (
   set options=!options! --asm-define %%a -D %%a
)

@REM echo %options%

@REM Copies the custom audio driver over each AUDIODRV_COPYn marker so every DPCM bank has the same driver.
@REM See the PRGC memory areas in smb1base.cfg. ROM offsets (ooffs) come from the ld65 debug file.
@REM Built up here since it can't contain double quotes or carets. \x22 is a double quote in the regex.
set "copydriver=$s=@{}; foreach ($l in Get-Content 'build\smb1base.dbg') {"
set "copydriver=!copydriver! if ($l -match 'name=\x22(AUDIODRV(_COPY\d+)?)\x22,.*size=0x([0-9A-Fa-f]+),.*ooffs=(\d+)') {"
set "copydriver=!copydriver! $s[$Matches[1]] = @([Convert]::ToInt32($Matches[3], 16), [int]$Matches[4]) } };"
set "copydriver=!copydriver! if ($s.ContainsKey('AUDIODRV')) { $p = (Resolve-Path 'build\smb1base.nes').Path;"
set "copydriver=!copydriver! $b = [IO.File]::ReadAllBytes($p); $d = $s['AUDIODRV'];"
set "copydriver=!copydriver! foreach ($k in $s.Keys) { if ($k -ne 'AUDIODRV') { [Array]::Copy($b, $d[1], $b, $s[$k][1], $d[0]) } };"
set "copydriver=!copydriver! [IO.File]::WriteAllBytes($p, $b) }"

tools\Windows\cc65\bin\cl65 ^
  --cpu 6502x -t nes  -g -Oisr -vm -T ^
  -C smb1base.cfg ^
  --ld-args --dbgfile,build\smb1base.dbg ^
  --include-dir . ^
  --asm-include-dir . ^
  --bin-include-dir . ^
  -l build\smb1base.lst ^
  -m build\smb1base.map ^
  -o build\smb1base.nes ^
  !options! ^
   ./src/main.c ./src/entrypoint.s

if ["%errorlevel%"]==["0"] powershell -NoProfile -Command "!copydriver!"

if NOT ["%errorlevel%"]==["0"] ( 
   if NOT ["%1"]==["no_pause"] (
      echo.
      echo One or more build errors need to be resolved
      pause
   )
)
