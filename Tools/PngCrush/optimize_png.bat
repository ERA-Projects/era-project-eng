@echo off

rem Pass directory path as the only argument to batch file, otherwise current working directory will be used

rem Replace PNG_CRUSH_PATH value with fixed absolute path if the utility is not in bat file directory
set "PNG_CRUSH_PATH=%~dp0pngcrush.exe"
set "PNG_DIR=%~1"

if "%PNG_DIR%."=="." set "PNG_DIR=%CD%"

echo PNG files directory path: "%PNG_DIR%"

for /R %%i in ("%PNG_DIR%\*.png") do %PNG_CRUSH_PATH% "%%i"
pause
exit