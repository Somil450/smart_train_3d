@echo off
title SmartRail AI - Build Release Executable
echo ========================================================
echo   SmartRail AI - Building Windows Standalone Release .exe
echo ========================================================
echo.
flutter build windows --release
echo.
echo ========================================================
echo Build Complete!
echo Executable Location:
echo %~dp0build\windows\x64\runner\Release\smartrail_ai.exe
echo ========================================================
pause
