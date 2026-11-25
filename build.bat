@echo off

js65 build

if NOT ["%errorlevel%"]==["0"] ( 
   if NOT ["%1"]==["no_pause"] (
      echo.
      echo One or more build errors need to be resolved
      pause
   )
)
