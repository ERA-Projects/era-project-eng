@echo off
cls
color 0f
title Исправление редактора кампаний путём импорта текстовых файлов из WoG в h3bitmap.lod
color 0c

cd "%~dp0..\.."

echo ВНИМАНИЕ! Эта операция не позволит Вам полностью удалить Эру!
echo Вы уверены, что хотите продолжить (y/n)?
set /P Answer=
if not %Answer%==y goto Exit
color 0f
echo.
echo Объединяю архивы, пожалуйста подождите...
echo.

Tools\lodmerge.exe Data\h3bitmap.lod "%~dp0fix campaign editor.lod"

:Exit
pause