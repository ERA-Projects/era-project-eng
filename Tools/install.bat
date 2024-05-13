cls
color 0f

rem [Constants]
set INSTALL=_Install_
set ROOT_FILES=%INSTALL%\Root
set MOD_FILES=%INSTALL%\Mods

rem [Clean garbage files and folders]
del /F /Q *.txt
del /F /Q *.doc
del /F /Q *.hlp
del /F /Q *.cnt
del /F /Q *.pdf
del /F /Q *.bat
del /F /Q *.isu
del /F /Q *.reg
del /F /Q *.ini
del /F /Q mplaynow.exe
del /F /Q regsetup.exe
rmdir /S /Q Data\s
rmdir /S /Q Heat
rmdir /S /Q mplayer
rmdir /S /Q online
rmdir /S /Q registersod

rem [Move Era root files to game root]
move /Y %ROOT_FILES%\*.* .

rem [Install mods]
if exist Mods (
  rmdir /S /Q Mods\WoG
  rmdir /S /Q "Mods\Era Erm Framework"
  for /d %%i in (%MOD_FILES%\*) do move /y "%%i" Mods
)

if not exist Mods (
  move /y %MOD_FILES% .
  Tools\installmod WoG
  Tools\installmod "Era Erm Framework"
  Tools\installmod "WoG Scripts"
  Tools\installmod "Fast Battle Animation"
  Tools\installmod Yona
  Tools\installmod "Secondary Skills Scrolling"
  Tools\installmod "Quick Savings"
)

rem Fix previous installations

if exist "Mods\WoG\EraPlugins\game bug fixes.era" (
  del "Mods\WoG\EraPlugins\game bug fixes.era"
)

if exist "Mods\WoG\EraPlugins\wog native dialogs.dll" (
  move "Mods\WoG\EraPlugins\wog native dialogs.dll" "Mods\WoG\EraPlugins\wog native dialogs.dll.off"
)

echo Installation was successfully completed!

rem [Open changes.txt]
rem "Help\Era manual\index.html"
rem "Help\Era manual\era ii.html"
rem "Help\Era manual\era ii changelog.txt"

rem [Delete installation folder]
rmdir /S /Q %INSTALL%

rem [Delete self]
(goto) 2>nul & del "%~f0"