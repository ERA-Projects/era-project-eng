@echo off
cls
color 0f
title ��ࠢ����� ।���� �������� ���� ������ ⥪�⮢�� 䠩��� �� WoG � h3bitmap.lod
color 0c

cd "%~dp0..\.."

echo ��������! �� ������ �� �������� ��� ��������� 㤠���� ���!
echo �� 㢥७�, �� ��� �த������ (y/n)?
set /P Answer=
if not %Answer%==y goto Exit
color 0f
echo.
echo ��ꥤ���� ��娢�, �������� ��������...
echo.

Tools\lodmerge.exe Data\h3bitmap.lod "%~dp0fix campaign editor.lod"

:Exit
pause