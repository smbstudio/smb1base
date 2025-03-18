
@echo off
setlocal EnableDelayedExpansion

if not exist build mkdir build

for /f "delims=" %%a in ('type build_options.ini ^| findstr /v "^[;#\[]"') do (
   set options=!options! --asm-define %%a -D %%a
)

@REM echo %options%

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

if NOT ["%errorlevel%"]==["0"] ( 
   if NOT ["%1"]==["no_pause"] (
      echo.
      echo One or more build errors need to be resolved
      pause
   )
)
