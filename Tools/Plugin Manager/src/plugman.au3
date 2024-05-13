#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=puzzle.ico
#AutoIt3Wrapper_Res_SaveSource=y
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
#cs ----------------------------------------------------------------------------
 AutoIt Version: 3.3.9.0 (beta)
 Author:         SyDr
#ce ----------------------------------------------------------------------------

#include <Array.au3>
#include <File.au3>
#include <GUIConstantsEx.au3>
AutoItSetOption("MustDeclareVars", 1)
Dim $sBasePath, $aGlobal, $aBeforeWog, $aAfterWog
Dim $hCheckboxes[1], $hNames[1], $hPathes[1]
Dim $k, $iBaseOffset = 28
Dim $hGUI, $hCombo, $aMods, $msg, $wPos
DIm $sMod = "WoG"
Dim $bShowIgnored = False, $hShowIgnored

CreateGUI($sMod, Default, Default)

While 1
	$msg = GUIGetMsg()
	If $msg = $GUI_EVENT_CLOSE Then ExitLoop
;~ 	If $msg<>0 Then MsgBox(4096, Default, $hCheckboxes[0] & @CRLf & $msg)
	If IsArray($aGlobal) Or IsArray($aBeforeWog) Or IsArray($aAfterWog) Then
		For $k = 0 To UBound($hCheckboxes)-1
			If $msg = $hCheckboxes[$k] Then
				ChangeState($k)
				ExitLoop
		EndIf
	Next
		EndIf
	If $msg = $hCombo Then
		$sMod = GUICtrlRead($hCombo)
		$wPos = WinGetPos($hGUI)
		GUIDelete($hGUI)
		CreateGUI($sMod, $wPos[0], $wPos[1])
	EndIf

	If $msg = $hShowIgnored Then
		If BitAND(GUICtrlRead($hShowIgnored), $GUI_CHECKED) Then
			$bShowIgnored = True
		Else
			$bShowIgnored = False
		EndIf
		$sMod = GUICtrlRead($hCombo)
		$wPos = WinGetPos($hGUI)
		GUIDelete($hGUI)
		CreateGUI($sMod, $wPos[0], $wPos[1])
	EndIf
	Sleep(10)
WEnd

Func SetState($sCS)
	If StringRight($sCS, 3) = "off" Then
;~ 		GUICtrlSetData(-1, StringTrimRight($aArray[$i], 4))
	Else
		GuiCtrlSetState(-1, $GUI_CHECKED)
	EndIf
EndFunc

Func ChangeState($i)
	If BitAND(GUICtrlRead($hCheckboxes[$i]), $GUI_CHECKED) Then
		FileMove($hPathes[$i], StringTrimRight($hPathes[$i], 4))
		$hPathes[$i] = StringTrimRight($hPathes[$i], 4)
		$hNames[$i] = StringTrimRight($hNames[$i], 4)
		GUICtrlSetData($hCheckboxes[$i], $hNames[$i])
	Else
		FileMove($hPathes[$i], $hPathes[$i] & ".off")
		$hPathes[$i] = $hPathes[$i] & ".off"
		$hNames[$i] = $hNames[$i] & ".off"
		GUICtrlSetData($hCheckboxes[$i], $hNames[$i])
	EndIf
EndFunc

Func CreateGUI($sMod, $wLeft, $wTop)
	Dim $aIgnMods[1], $aIgnPlugins[1]
	GetIngnoreList($aIgnMods, $aIgnPlugins, $sMod)
	$sBasePath = @ScriptDir & "\..\..\Mods\" & $sMod
	If $sMod="" Or Not FileExists($sBasePath) Or (Not $bShowIgnored And _ArraySearch($aIgnMods, $sMod, 1)>0) Then
		$sMod="WoG"
		$sBasePath = @ScriptDir & "\..\..\Mods\" & $sMod
	EndIf
	$aGlobal = _FileListToArray($sBasePath & "\EraPlugins\", "*", 1)
	$aBeforeWog = _FileListToArray($sBasePath & "\EraPlugins\BeforeWoG\", "*", 1)
	$aAfterWog = _FileListToArray($sBasePath & "\EraPlugins\AfterWoG\", "*", 1)

;~ 	_ArrayDisplay($aIgnMods)
	If IsArray($aGlobal) Then
		For $iCount = $aGlobal[0] To 1 Step -1
			If FileGetSize($sBasePath & "\EraPlugins\" & $aGlobal[$iCount])=0 Or _ArraySearch($aIgnPlugins, $aGlobal[$iCount], 1)>0 Then
				_ArrayDelete($aGlobal, $iCount)
				$aGlobal[0] -= 1
			EndIf
		Next
	EndIf

	If IsArray($aBeforeWog) Then
		For $iCount = $aBeforeWog[0] To 1 Step -1
			If FileGetSize($sBasePath & "\EraPlugins\BeforeWoG\" & $aBeforeWog[$iCount])=0  Or _ArraySearch($aIgnPlugins, $aBeforeWog[$iCount], 1)>0 Then
				_ArrayDelete($aBeforeWog, $iCount)
				$aBeforeWog[0] -= 1
			EndIf
		Next
	EndIf

	If IsArray($aAfterWog) Then
		For $iCount = $aAfterWog[0] To 1 Step -1
			If FileGetSize($sBasePath & "\EraPlugins\AfterWoG\" & $aAfterWog[$iCount])=0  Or _ArraySearch($aIgnPlugins, $aAfterWog[$iCount], 1)>0 Then
				_ArrayDelete($aAfterWog, $iCount)
				$aAfterWog[0] -= 1
			EndIf
		Next
	EndIf

	Dim $iTotalPlugins = 0, $iTotalSections = 0
	If IsArray($aGlobal) Then
		$iTotalPlugins += $aGlobal[0]
		$iTotalSections += 1
	EndIf
	If IsArray($aBeforeWog) Then
		$iTotalPlugins += $aBeforeWog[0]
		$iTotalSections += 1
	EndIf
	If IsArray($aAfterWog) Then
		$iTotalPlugins += $aAfterWog[0]
		$iTotalSections += 1
	EndIf

	If $iTotalPlugins>0 Then
		ReDim $hCheckboxes[$iTotalPlugins]
		ReDim $hNames[$iTotalPlugins]
		ReDim $hPathes[$iTotalPlugins]
	EndIf
	$k = 0

	$hGUI = GUICreate("Era II WoG Plugin Manager v. 0.003", 252, $iBaseOffset + $iTotalPlugins*17+13+$iTotalSections*17+17, $wLeft, $wTop)
	GUISetState(@SW_SHOW)

	GUICtrlCreateLabel("Select mod", 8, 8, 100, 17)
	$hCombo = GUICtrlCreateCombo("WoG", 109, 8, 140, 17)
	Dim $aMods = _FileListToArray($sBasePath & "\..\", "*", 2)
	Dim $iTmp = _ArraySearch($aMods, "_Off_", 1)
	If $iTmp>0 Then _ArrayDelete($aMods, $iTmp)
	For $iCount = 1 To $aIgnMods[0]
		$iTmp = _ArraySearch($aMods, $aIgnMods[$iCount], 1)
		If $iTmp>0 Then _ArrayDelete($aMods, $iTmp)
	Next

	GUICtrlSetData (-1, "|" & _ArrayToString($aMods, "|", 1), $sMod)

	If IsArray($aGlobal) Then
		GUICtrlCreateGroup("Global", 1, $iBaseOffset + 1, 250, 17*($aGlobal[0]+1))
		For $i=1 To $aGlobal[0]
			$hCheckboxes[$k] = GUICtrlCreateCheckbox($aGlobal[$i], 8, $iBaseOffset + 16 + 17*($i-1), 200, 17)
			$hNames[$k] = $aGlobal[$i]
			$hPathes[$k] = $sBasePath & "\EraPlugins\" & $aGlobal[$i]
			$k += 1
			SetState($aGlobal[$i])
		Next
		GUICtrlCreateGroup("Global", 1, $iBaseOffset + 1, 250, 17*($aGlobal[0]+1))
	EndIf

	If IsArray($aBeforeWog) Then
		Local $iGlobal=-1
		If IsArray($aGlobal) Then $iGlobal=$aGlobal[0]
		GUICtrlCreateGroup("BeforeWoG", 1, $iBaseOffset + 1 + 17*($iGlobal+1) + 1, 250, 17*($aBeforeWog[0]+1))
		For $i=1 To $aBeforeWog[0]
			$hCheckboxes[$k] = GUICtrlCreateCheckbox($aBeforeWog[$i], 8, $iBaseOffset + 17*($iGlobal+1) + 1 + 16 + 17*($i-1), 200, 17)
			$hNames[$k] = $aBeforeWog[$i]
			$hPathes[$k] = $sBasePath & "\EraPlugins\BeforeWoG\" & $aBeforeWog[$i]
			$k += 1
			SetState($aBeforeWog[$i])
		Next
		GUICtrlCreateGroup("BeforeWoG", 1, $iBaseOffset + 1 + 17*($iGlobal+1) + 1, 250, 17*($aBeforeWog[0]+1))
	EndIf

	If IsArray($aAfterWog) Then
		Local $iGlobal=-1
		Local $iBeforeWog=-1
		If IsArray($aBeforeWog) Then $iBeforeWog=$aBeforeWog[0]
		If IsArray($aGlobal) Then $iGlobal=$aGlobal[0]
		GUICtrlCreateGroup("AfterWoG", 1, $iBaseOffset + 1 + 17*($iGlobal+1) + 1 + 17*($iBeforeWog+1) + 1, 250, 17*($aAfterWog[0]+1))
		For $i=1 To $aAfterWog[0]
			$hCheckboxes[$k] = GUICtrlCreateCheckbox($aAfterWog[$i], 8, $iBaseOffset + 17*($iBeforeWog+1) + 1 + 17*($iGlobal+1) + 1 + 16 + 17*($i-1), 200, 17)
			$hNames[$k] = $aAfterWog[$i]
			$hPathes[$k] = $sBasePath & "\EraPlugins\AfterWoG\" & $aAfterWog[$i]
			$k += 1
			SetState($aAfterWog[$i])
		Next
		GUICtrlCreateGroup("AfterWoG", 1, $iBaseOffset + 1 + 17*($iGlobal+1) + 1 + 17*($iBeforeWog+1) + 1, 250, 17*($aAfterWog[0]+1))
	EndIf

	$hShowIgnored = GUICtrlCreateCheckbox("Show ignored", 8, $iBaseOffset + $iTotalPlugins*17+7+$iTotalSections*17, 200, 17)
	If $bShowIgnored Then GUICtrlSetState($hShowIgnored, $GUI_CHECKED)
	ControlFocus($hGUI, "", $hCombo)
EndFunc

Func GetIngnoreList(ByRef $aIgnMods, ByRef $aIgnPlugins, $sMod)
	Local $aMods = IniReadSection(@ScriptDir & "\ignore.ini", "IgnoreMods")
	If @error Or $bShowIgnored Then
		ReDim $aIgnMods[1]
		$aIgnMods[0]=0
	Else
		ReDim $aIgnMods[UBound($aMods, 1)]
		For $iCount = 0 To UBound($aMods, 1)-1
			$aIgnMods[$iCount]=$aMods[$iCount][0]
		Next
	EndIf

	Local $aPlugins = IniReadSection(@ScriptDir & "\ignore.ini", $sMod)
	If @error Or $bShowIgnored Then
		ReDim $aIgnPlugins[1]
		$aIgnPlugins[0]=0
	Else
		ReDim $aIgnPlugins[UBound($aPlugins, 1)*2-1]
		$aIgnPlugins[0]=$aPlugins[0][0]*2
		For $iCount = 1 To UBound($aPlugins, 1)-1
			$aIgnPlugins[$iCount]=$aPlugins[$iCount][0]
			If StringRight($aIgnPlugins[$iCount], 4)=".off" Then
				$aIgnPlugins[$iCount+UBound($aPlugins, 1)-1]=StringTrimRight($aIgnPlugins[$iCount], 4)
			Else
				$aIgnPlugins[$iCount+UBound($aPlugins, 1)-1]=$aIgnPlugins[$iCount] & ".off"
			EndIf
		Next
	EndIf
EndFunc
