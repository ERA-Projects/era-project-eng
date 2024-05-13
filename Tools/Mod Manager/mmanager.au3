#NoTrayIcon
#Au3Stripper_Ignore_Funcs=SD_GUI_*
#Au3Stripper_Ignore_Funcs=GUIRegisterMsgStateful
#Au3Stripper_Ignore_Funcs=WM_*
#Au3Stripper_Ignore_Funcs=__UI_*
#Au3Stripper_Ignore_Funcs=__WO_*
AutoItSetOption("MustDeclareVars", 1)
AutoItSetOption("GUIOnEventMode", 1)
AutoItSetOption("GUICloseOnESC", 1)
AutoItSetOption("TrayIconHide", 1)
If FileExists(@ScriptDir & "\debug") Then
Global $__DEBUG_TO_FILE
FileMove(@ScriptDir & "\debug2.log", @ScriptDir & "\debug3.log", 1)
FileMove(@ScriptDir & "\debug1.log", @ScriptDir & "\debug2.log", 1)
FileMove(@ScriptDir & "\debug0.log", @ScriptDir & "\debug1.log", 1)
EndIf
Global Const $OPT_MATCHSTART = 1
Global Const $DLG_NOTONTOP = 2
Global Const $DLG_MOVEABLE = 16
Global Const $STDOUT_CHILD = 2
Global Const $STDERR_CHILD = 4
Global Const $UBOUND_DIMENSIONS = 0
Global Const $UBOUND_ROWS = 1
Global Const $UBOUND_COLUMNS = 2
Global Const $KEYWORD_DEFAULT = 1
Global Const $MB_OK = 0
Global Const $MB_YESNO = 4
Global Const $MB_ICONQUESTION = 32
Global Const $MB_ICONINFORMATION = 64
Global Const $MB_DEFBUTTON2 = 256
Global Const $MB_SYSTEMMODAL = 4096
Global Const $MB_TASKMODAL = 8192
Global Const $IDYES = 6
Global Const $IDNO = 7
Global Const $STR_CHRSPLIT = 0
Global Const $STR_ENTIRESPLIT = 1
Global Const $STR_NOCOUNT = 2
Global Const $STR_REGEXPARRAYMATCH = 1
Global Const $STR_REGEXPARRAYGLOBALMATCH = 3
Global Enum $ARRAYFILL_FORCE_DEFAULT, $ARRAYFILL_FORCE_SINGLEITEM, $ARRAYFILL_FORCE_INT, $ARRAYFILL_FORCE_NUMBER, $ARRAYFILL_FORCE_PTR, $ARRAYFILL_FORCE_HWND, $ARRAYFILL_FORCE_STRING, $ARRAYFILL_FORCE_BOOLEAN
Func _ArrayAdd(ByRef $aArray, $vValue, $iStart = 0, $sDelim_Item = "|", $sDelim_Row = @CRLF, $iForce = $ARRAYFILL_FORCE_DEFAULT)
If $iStart = Default Then $iStart = 0
If $sDelim_Item = Default Then $sDelim_Item = "|"
If $sDelim_Row = Default Then $sDelim_Row = @CRLF
If $iForce = Default Then $iForce = $ARRAYFILL_FORCE_DEFAULT
If Not IsArray($aArray) Then Return SetError(1, 0, -1)
Local $iDim_1 = UBound($aArray, $UBOUND_ROWS)
Local $hDataType = 0
Switch $iForce
Case $ARRAYFILL_FORCE_INT
$hDataType = Int
Case $ARRAYFILL_FORCE_NUMBER
$hDataType = Number
Case $ARRAYFILL_FORCE_PTR
$hDataType = Ptr
Case $ARRAYFILL_FORCE_HWND
$hDataType = Hwnd
Case $ARRAYFILL_FORCE_STRING
$hDataType = String
Case $ARRAYFILL_FORCE_BOOLEAN
$hDataType = "Boolean"
EndSwitch
Switch UBound($aArray, $UBOUND_DIMENSIONS)
Case 1
If $iForce = $ARRAYFILL_FORCE_SINGLEITEM Then
ReDim $aArray[$iDim_1 + 1]
$aArray[$iDim_1] = $vValue
Return $iDim_1
EndIf
If IsArray($vValue) Then
If UBound($vValue, $UBOUND_DIMENSIONS) <> 1 Then Return SetError(5, 0, -1)
$hDataType = 0
Else
Local $aTmp = StringSplit($vValue, $sDelim_Item, $STR_NOCOUNT + $STR_ENTIRESPLIT)
If UBound($aTmp, $UBOUND_ROWS) = 1 Then
$aTmp[0] = $vValue
EndIf
$vValue = $aTmp
EndIf
Local $iAdd = UBound($vValue, $UBOUND_ROWS)
ReDim $aArray[$iDim_1 + $iAdd]
For $i = 0 To $iAdd - 1
If String($hDataType) = "Boolean" Then
Switch $vValue[$i]
Case "True", "1"
$aArray[$iDim_1 + $i] = True
Case "False", "0", ""
$aArray[$iDim_1 + $i] = False
EndSwitch
ElseIf IsFunc($hDataType) Then
$aArray[$iDim_1 + $i] = $hDataType($vValue[$i])
Else
$aArray[$iDim_1 + $i] = $vValue[$i]
EndIf
Next
Return $iDim_1 + $iAdd - 1
Case 2
Local $iDim_2 = UBound($aArray, $UBOUND_COLUMNS)
If $iStart < 0 Or $iStart > $iDim_2 - 1 Then Return SetError(4, 0, -1)
Local $iValDim_1, $iValDim_2 = 0, $iColCount
If IsArray($vValue) Then
If UBound($vValue, $UBOUND_DIMENSIONS) <> 2 Then Return SetError(5, 0, -1)
$iValDim_1 = UBound($vValue, $UBOUND_ROWS)
$iValDim_2 = UBound($vValue, $UBOUND_COLUMNS)
$hDataType = 0
Else
Local $aSplit_1 = StringSplit($vValue, $sDelim_Row, $STR_NOCOUNT + $STR_ENTIRESPLIT)
$iValDim_1 = UBound($aSplit_1, $UBOUND_ROWS)
Local $aTmp[$iValDim_1][0], $aSplit_2
For $i = 0 To $iValDim_1 - 1
$aSplit_2 = StringSplit($aSplit_1[$i], $sDelim_Item, $STR_NOCOUNT + $STR_ENTIRESPLIT)
$iColCount = UBound($aSplit_2)
If $iColCount > $iValDim_2 Then
$iValDim_2 = $iColCount
ReDim $aTmp[$iValDim_1][$iValDim_2]
EndIf
For $j = 0 To $iColCount - 1
$aTmp[$i][$j] = $aSplit_2[$j]
Next
Next
$vValue = $aTmp
EndIf
If UBound($vValue, $UBOUND_COLUMNS) + $iStart > UBound($aArray, $UBOUND_COLUMNS) Then Return SetError(3, 0, -1)
ReDim $aArray[$iDim_1 + $iValDim_1][$iDim_2]
For $iWriteTo_Index = 0 To $iValDim_1 - 1
For $j = 0 To $iDim_2 - 1
If $j < $iStart Then
$aArray[$iWriteTo_Index + $iDim_1][$j] = ""
ElseIf $j - $iStart > $iValDim_2 - 1 Then
$aArray[$iWriteTo_Index + $iDim_1][$j] = ""
Else
If String($hDataType) = "Boolean" Then
Switch $vValue[$iWriteTo_Index][$j - $iStart]
Case "True", "1"
$aArray[$iWriteTo_Index + $iDim_1][$j] = True
Case "False", "0", ""
$aArray[$iWriteTo_Index + $iDim_1][$j] = False
EndSwitch
ElseIf IsFunc($hDataType) Then
$aArray[$iWriteTo_Index + $iDim_1][$j] = $hDataType($vValue[$iWriteTo_Index][$j - $iStart])
Else
$aArray[$iWriteTo_Index + $iDim_1][$j] = $vValue[$iWriteTo_Index][$j - $iStart]
EndIf
EndIf
Next
Next
Case Else
Return SetError(2, 0, -1)
EndSwitch
Return UBound($aArray, $UBOUND_ROWS) - 1
EndFunc
Func _ArrayDelete(ByRef $aArray, $vRange)
If Not IsArray($aArray) Then Return SetError(1, 0, -1)
Local $iDim_1 = UBound($aArray, $UBOUND_ROWS) - 1
If IsArray($vRange) Then
If UBound($vRange, $UBOUND_DIMENSIONS) <> 1 Or UBound($vRange, $UBOUND_ROWS) < 2 Then Return SetError(4, 0, -1)
Else
Local $iNumber, $aSplit_1, $aSplit_2
$vRange = StringStripWS($vRange, 8)
$aSplit_1 = StringSplit($vRange, ";")
$vRange = ""
For $i = 1 To $aSplit_1[0]
If Not StringRegExp($aSplit_1[$i], "^\d+(-\d+)?$") Then Return SetError(3, 0, -1)
$aSplit_2 = StringSplit($aSplit_1[$i], "-")
Switch $aSplit_2[0]
Case 1
$vRange &= $aSplit_2[1] & ";"
Case 2
If Number($aSplit_2[2]) >= Number($aSplit_2[1]) Then
$iNumber = $aSplit_2[1] - 1
Do
$iNumber += 1
$vRange &= $iNumber & ";"
Until $iNumber = $aSplit_2[2]
EndIf
EndSwitch
Next
$vRange = StringSplit(StringTrimRight($vRange, 1), ";")
EndIf
For $i = 1 To $vRange[0]
$vRange[$i] = Number($vRange[$i])
Next
If $vRange[1] < 0 Or $vRange[$vRange[0]] > $iDim_1 Then Return SetError(5, 0, -1)
Local $iCopyTo_Index = 0
Switch UBound($aArray, $UBOUND_DIMENSIONS)
Case 1
For $i = 1 To $vRange[0]
$aArray[$vRange[$i]] = ChrW(0xFAB1)
Next
For $iReadFrom_Index = 0 To $iDim_1
If $aArray[$iReadFrom_Index] == ChrW(0xFAB1) Then
ContinueLoop
Else
If $iReadFrom_Index <> $iCopyTo_Index Then
$aArray[$iCopyTo_Index] = $aArray[$iReadFrom_Index]
EndIf
$iCopyTo_Index += 1
EndIf
Next
ReDim $aArray[$iDim_1 - $vRange[0] + 1]
Case 2
Local $iDim_2 = UBound($aArray, $UBOUND_COLUMNS) - 1
For $i = 1 To $vRange[0]
$aArray[$vRange[$i]][0] = ChrW(0xFAB1)
Next
For $iReadFrom_Index = 0 To $iDim_1
If $aArray[$iReadFrom_Index][0] == ChrW(0xFAB1) Then
ContinueLoop
Else
If $iReadFrom_Index <> $iCopyTo_Index Then
For $j = 0 To $iDim_2
$aArray[$iCopyTo_Index][$j] = $aArray[$iReadFrom_Index][$j]
Next
EndIf
$iCopyTo_Index += 1
EndIf
Next
ReDim $aArray[$iDim_1 - $vRange[0] + 1][$iDim_2 + 1]
Case Else
Return SetError(2, 0, False)
EndSwitch
Return UBound($aArray, $UBOUND_ROWS)
EndFunc
Func _ArrayReverse(ByRef $aArray, $iStart = 0, $iEnd = 0)
If $iStart = Default Then $iStart = 0
If $iEnd = Default Then $iEnd = 0
If Not IsArray($aArray) Then Return SetError(1, 0, 0)
If UBound($aArray, $UBOUND_DIMENSIONS) <> 1 Then Return SetError(3, 0, 0)
If Not UBound($aArray) Then Return SetError(4, 0, 0)
Local $vTmp, $iUBound = UBound($aArray) - 1
If $iEnd < 1 Or $iEnd > $iUBound Then $iEnd = $iUBound
If $iStart < 0 Then $iStart = 0
If $iStart > $iEnd Then Return SetError(2, 0, 0)
For $i = $iStart To Int(($iStart + $iEnd - 1) / 2)
$vTmp = $aArray[$i]
$aArray[$i] = $aArray[$iEnd]
$aArray[$iEnd] = $vTmp
$iEnd -= 1
Next
Return 1
EndFunc
Func _ArraySearch(Const ByRef $aArray, $vValue, $iStart = 0, $iEnd = 0, $iCase = 0, $iCompare = 0, $iForward = 1, $iSubItem = -1, $bRow = False)
If $iStart = Default Then $iStart = 0
If $iEnd = Default Then $iEnd = 0
If $iCase = Default Then $iCase = 0
If $iCompare = Default Then $iCompare = 0
If $iForward = Default Then $iForward = 1
If $iSubItem = Default Then $iSubItem = -1
If $bRow = Default Then $bRow = False
If Not IsArray($aArray) Then Return SetError(1, 0, -1)
Local $iDim_1 = UBound($aArray) - 1
If $iDim_1 = -1 Then Return SetError(3, 0, -1)
Local $iDim_2 = UBound($aArray, $UBOUND_COLUMNS) - 1
Local $bCompType = False
If $iCompare = 2 Then
$iCompare = 0
$bCompType = True
EndIf
If $bRow Then
If UBound($aArray, $UBOUND_DIMENSIONS) = 1 Then Return SetError(5, 0, -1)
If $iEnd < 1 Or $iEnd > $iDim_2 Then $iEnd = $iDim_2
If $iStart < 0 Then $iStart = 0
If $iStart > $iEnd Then Return SetError(4, 0, -1)
Else
If $iEnd < 1 Or $iEnd > $iDim_1 Then $iEnd = $iDim_1
If $iStart < 0 Then $iStart = 0
If $iStart > $iEnd Then Return SetError(4, 0, -1)
EndIf
Local $iStep = 1
If Not $iForward Then
Local $iTmp = $iStart
$iStart = $iEnd
$iEnd = $iTmp
$iStep = -1
EndIf
Switch UBound($aArray, $UBOUND_DIMENSIONS)
Case 1
If Not $iCompare Then
If Not $iCase Then
For $i = $iStart To $iEnd Step $iStep
If $bCompType And VarGetType($aArray[$i]) <> VarGetType($vValue) Then ContinueLoop
If $aArray[$i] = $vValue Then Return $i
Next
Else
For $i = $iStart To $iEnd Step $iStep
If $bCompType And VarGetType($aArray[$i]) <> VarGetType($vValue) Then ContinueLoop
If $aArray[$i] == $vValue Then Return $i
Next
EndIf
Else
For $i = $iStart To $iEnd Step $iStep
If $iCompare = 3 Then
If StringRegExp($aArray[$i], $vValue) Then Return $i
Else
If StringInStr($aArray[$i], $vValue, $iCase) > 0 Then Return $i
EndIf
Next
EndIf
Case 2
Local $iDim_Sub
If $bRow Then
$iDim_Sub = $iDim_1
If $iSubItem > $iDim_Sub Then $iSubItem = $iDim_Sub
If $iSubItem < 0 Then
$iSubItem = 0
Else
$iDim_Sub = $iSubItem
EndIf
Else
$iDim_Sub = $iDim_2
If $iSubItem > $iDim_Sub Then $iSubItem = $iDim_Sub
If $iSubItem < 0 Then
$iSubItem = 0
Else
$iDim_Sub = $iSubItem
EndIf
EndIf
For $j = $iSubItem To $iDim_Sub
If Not $iCompare Then
If Not $iCase Then
For $i = $iStart To $iEnd Step $iStep
If $bRow Then
If $bCompType And VarGetType($aArray[$j][$i]) <> VarGetType($vValue) Then ContinueLoop
If $aArray[$j][$i] = $vValue Then Return $i
Else
If $bCompType And VarGetType($aArray[$i][$j]) <> VarGetType($vValue) Then ContinueLoop
If $aArray[$i][$j] = $vValue Then Return $i
EndIf
Next
Else
For $i = $iStart To $iEnd Step $iStep
If $bRow Then
If $bCompType And VarGetType($aArray[$j][$i]) <> VarGetType($vValue) Then ContinueLoop
If $aArray[$j][$i] == $vValue Then Return $i
Else
If $bCompType And VarGetType($aArray[$i][$j]) <> VarGetType($vValue) Then ContinueLoop
If $aArray[$i][$j] == $vValue Then Return $i
EndIf
Next
EndIf
Else
For $i = $iStart To $iEnd Step $iStep
If $iCompare = 3 Then
If $bRow Then
If StringRegExp($aArray[$j][$i], $vValue) Then Return $i
Else
If StringRegExp($aArray[$i][$j], $vValue) Then Return $i
EndIf
Else
If $bRow Then
If StringInStr($aArray[$j][$i], $vValue, $iCase) > 0 Then Return $i
Else
If StringInStr($aArray[$i][$j], $vValue, $iCase) > 0 Then Return $i
EndIf
EndIf
Next
EndIf
Next
Case Else
Return SetError(2, 0, -1)
EndSwitch
Return SetError(6, 0, -1)
EndFunc
Func _ArraySort(ByRef $aArray, $iDescending = 0, $iStart = 0, $iEnd = 0, $iSubItem = 0, $iPivot = 0)
If $iDescending = Default Then $iDescending = 0
If $iStart = Default Then $iStart = 0
If $iEnd = Default Then $iEnd = 0
If $iSubItem = Default Then $iSubItem = 0
If $iPivot = Default Then $iPivot = 0
If Not IsArray($aArray) Then Return SetError(1, 0, 0)
Local $iUBound = UBound($aArray) - 1
If $iUBound = -1 Then Return SetError(5, 0, 0)
If $iEnd = Default Then $iEnd = 0
If $iEnd < 1 Or $iEnd > $iUBound Or $iEnd = Default Then $iEnd = $iUBound
If $iStart < 0 Or $iStart = Default Then $iStart = 0
If $iStart > $iEnd Then Return SetError(2, 0, 0)
Switch UBound($aArray, $UBOUND_DIMENSIONS)
Case 1
If $iPivot Then
__ArrayDualPivotSort($aArray, $iStart, $iEnd)
Else
__ArrayQuickSort1D($aArray, $iStart, $iEnd)
EndIf
If $iDescending Then _ArrayReverse($aArray, $iStart, $iEnd)
Case 2
If $iPivot Then Return SetError(6, 0, 0)
Local $iSubMax = UBound($aArray, $UBOUND_COLUMNS) - 1
If $iSubItem > $iSubMax Then Return SetError(3, 0, 0)
If $iDescending Then
$iDescending = -1
Else
$iDescending = 1
EndIf
__ArrayQuickSort2D($aArray, $iDescending, $iStart, $iEnd, $iSubItem, $iSubMax)
Case Else
Return SetError(4, 0, 0)
EndSwitch
Return 1
EndFunc
Func __ArrayQuickSort1D(ByRef $aArray, Const ByRef $iStart, Const ByRef $iEnd)
If $iEnd <= $iStart Then Return
Local $vTmp
If($iEnd - $iStart) < 15 Then
Local $vCur
For $i = $iStart + 1 To $iEnd
$vTmp = $aArray[$i]
If IsNumber($vTmp) Then
For $j = $i - 1 To $iStart Step -1
$vCur = $aArray[$j]
If($vTmp >= $vCur And IsNumber($vCur)) Or(Not IsNumber($vCur) And StringCompare($vTmp, $vCur) >= 0) Then ExitLoop
$aArray[$j + 1] = $vCur
Next
Else
For $j = $i - 1 To $iStart Step -1
If(StringCompare($vTmp, $aArray[$j]) >= 0) Then ExitLoop
$aArray[$j + 1] = $aArray[$j]
Next
EndIf
$aArray[$j + 1] = $vTmp
Next
Return
EndIf
Local $L = $iStart, $R = $iEnd, $vPivot = $aArray[Int(($iStart + $iEnd) / 2)], $bNum = IsNumber($vPivot)
Do
If $bNum Then
While($aArray[$L] < $vPivot And IsNumber($aArray[$L])) Or(Not IsNumber($aArray[$L]) And StringCompare($aArray[$L], $vPivot) < 0)
$L += 1
WEnd
While($aArray[$R] > $vPivot And IsNumber($aArray[$R])) Or(Not IsNumber($aArray[$R]) And StringCompare($aArray[$R], $vPivot) > 0)
$R -= 1
WEnd
Else
While(StringCompare($aArray[$L], $vPivot) < 0)
$L += 1
WEnd
While(StringCompare($aArray[$R], $vPivot) > 0)
$R -= 1
WEnd
EndIf
If $L <= $R Then
$vTmp = $aArray[$L]
$aArray[$L] = $aArray[$R]
$aArray[$R] = $vTmp
$L += 1
$R -= 1
EndIf
Until $L > $R
__ArrayQuickSort1D($aArray, $iStart, $R)
__ArrayQuickSort1D($aArray, $L, $iEnd)
EndFunc
Func __ArrayQuickSort2D(ByRef $aArray, Const ByRef $iStep, Const ByRef $iStart, Const ByRef $iEnd, Const ByRef $iSubItem, Const ByRef $iSubMax)
If $iEnd <= $iStart Then Return
Local $vTmp, $L = $iStart, $R = $iEnd, $vPivot = $aArray[Int(($iStart + $iEnd) / 2)][$iSubItem], $bNum = IsNumber($vPivot)
Do
If $bNum Then
While($iStep *($aArray[$L][$iSubItem] - $vPivot) < 0 And IsNumber($aArray[$L][$iSubItem])) Or(Not IsNumber($aArray[$L][$iSubItem]) And $iStep * StringCompare($aArray[$L][$iSubItem], $vPivot) < 0)
$L += 1
WEnd
While($iStep *($aArray[$R][$iSubItem] - $vPivot) > 0 And IsNumber($aArray[$R][$iSubItem])) Or(Not IsNumber($aArray[$R][$iSubItem]) And $iStep * StringCompare($aArray[$R][$iSubItem], $vPivot) > 0)
$R -= 1
WEnd
Else
While($iStep * StringCompare($aArray[$L][$iSubItem], $vPivot) < 0)
$L += 1
WEnd
While($iStep * StringCompare($aArray[$R][$iSubItem], $vPivot) > 0)
$R -= 1
WEnd
EndIf
If $L <= $R Then
For $i = 0 To $iSubMax
$vTmp = $aArray[$L][$i]
$aArray[$L][$i] = $aArray[$R][$i]
$aArray[$R][$i] = $vTmp
Next
$L += 1
$R -= 1
EndIf
Until $L > $R
__ArrayQuickSort2D($aArray, $iStep, $iStart, $R, $iSubItem, $iSubMax)
__ArrayQuickSort2D($aArray, $iStep, $L, $iEnd, $iSubItem, $iSubMax)
EndFunc
Func __ArrayDualPivotSort(ByRef $aArray, $iPivot_Left, $iPivot_Right, $bLeftMost = True)
If $iPivot_Left > $iPivot_Right Then Return
Local $iLength = $iPivot_Right - $iPivot_Left + 1
Local $i, $j, $k, $iAi, $iAk, $iA1, $iA2, $iLast
If $iLength < 45 Then
If $bLeftMost Then
$i = $iPivot_Left
While $i < $iPivot_Right
$j = $i
$iAi = $aArray[$i + 1]
While $iAi < $aArray[$j]
$aArray[$j + 1] = $aArray[$j]
$j -= 1
If $j + 1 = $iPivot_Left Then ExitLoop
WEnd
$aArray[$j + 1] = $iAi
$i += 1
WEnd
Else
While 1
If $iPivot_Left >= $iPivot_Right Then Return 1
$iPivot_Left += 1
If $aArray[$iPivot_Left] < $aArray[$iPivot_Left - 1] Then ExitLoop
WEnd
While 1
$k = $iPivot_Left
$iPivot_Left += 1
If $iPivot_Left > $iPivot_Right Then ExitLoop
$iA1 = $aArray[$k]
$iA2 = $aArray[$iPivot_Left]
If $iA1 < $iA2 Then
$iA2 = $iA1
$iA1 = $aArray[$iPivot_Left]
EndIf
$k -= 1
While $iA1 < $aArray[$k]
$aArray[$k + 2] = $aArray[$k]
$k -= 1
WEnd
$aArray[$k + 2] = $iA1
While $iA2 < $aArray[$k]
$aArray[$k + 1] = $aArray[$k]
$k -= 1
WEnd
$aArray[$k + 1] = $iA2
$iPivot_Left += 1
WEnd
$iLast = $aArray[$iPivot_Right]
$iPivot_Right -= 1
While $iLast < $aArray[$iPivot_Right]
$aArray[$iPivot_Right + 1] = $aArray[$iPivot_Right]
$iPivot_Right -= 1
WEnd
$aArray[$iPivot_Right + 1] = $iLast
EndIf
Return 1
EndIf
Local $iSeventh = BitShift($iLength, 3) + BitShift($iLength, 6) + 1
Local $iE1, $iE2, $iE3, $iE4, $iE5, $t
$iE3 = Ceiling(($iPivot_Left + $iPivot_Right) / 2)
$iE2 = $iE3 - $iSeventh
$iE1 = $iE2 - $iSeventh
$iE4 = $iE3 + $iSeventh
$iE5 = $iE4 + $iSeventh
If $aArray[$iE2] < $aArray[$iE1] Then
$t = $aArray[$iE2]
$aArray[$iE2] = $aArray[$iE1]
$aArray[$iE1] = $t
EndIf
If $aArray[$iE3] < $aArray[$iE2] Then
$t = $aArray[$iE3]
$aArray[$iE3] = $aArray[$iE2]
$aArray[$iE2] = $t
If $t < $aArray[$iE1] Then
$aArray[$iE2] = $aArray[$iE1]
$aArray[$iE1] = $t
EndIf
EndIf
If $aArray[$iE4] < $aArray[$iE3] Then
$t = $aArray[$iE4]
$aArray[$iE4] = $aArray[$iE3]
$aArray[$iE3] = $t
If $t < $aArray[$iE2] Then
$aArray[$iE3] = $aArray[$iE2]
$aArray[$iE2] = $t
If $t < $aArray[$iE1] Then
$aArray[$iE2] = $aArray[$iE1]
$aArray[$iE1] = $t
EndIf
EndIf
EndIf
If $aArray[$iE5] < $aArray[$iE4] Then
$t = $aArray[$iE5]
$aArray[$iE5] = $aArray[$iE4]
$aArray[$iE4] = $t
If $t < $aArray[$iE3] Then
$aArray[$iE4] = $aArray[$iE3]
$aArray[$iE3] = $t
If $t < $aArray[$iE2] Then
$aArray[$iE3] = $aArray[$iE2]
$aArray[$iE2] = $t
If $t < $aArray[$iE1] Then
$aArray[$iE2] = $aArray[$iE1]
$aArray[$iE1] = $t
EndIf
EndIf
EndIf
EndIf
Local $iLess = $iPivot_Left
Local $iGreater = $iPivot_Right
If(($aArray[$iE1] <> $aArray[$iE2]) And($aArray[$iE2] <> $aArray[$iE3]) And($aArray[$iE3] <> $aArray[$iE4]) And($aArray[$iE4] <> $aArray[$iE5])) Then
Local $iPivot_1 = $aArray[$iE2]
Local $iPivot_2 = $aArray[$iE4]
$aArray[$iE2] = $aArray[$iPivot_Left]
$aArray[$iE4] = $aArray[$iPivot_Right]
Do
$iLess += 1
Until $aArray[$iLess] >= $iPivot_1
Do
$iGreater -= 1
Until $aArray[$iGreater] <= $iPivot_2
$k = $iLess
While $k <= $iGreater
$iAk = $aArray[$k]
If $iAk < $iPivot_1 Then
$aArray[$k] = $aArray[$iLess]
$aArray[$iLess] = $iAk
$iLess += 1
ElseIf $iAk > $iPivot_2 Then
While $aArray[$iGreater] > $iPivot_2
$iGreater -= 1
If $iGreater + 1 = $k Then ExitLoop 2
WEnd
If $aArray[$iGreater] < $iPivot_1 Then
$aArray[$k] = $aArray[$iLess]
$aArray[$iLess] = $aArray[$iGreater]
$iLess += 1
Else
$aArray[$k] = $aArray[$iGreater]
EndIf
$aArray[$iGreater] = $iAk
$iGreater -= 1
EndIf
$k += 1
WEnd
$aArray[$iPivot_Left] = $aArray[$iLess - 1]
$aArray[$iLess - 1] = $iPivot_1
$aArray[$iPivot_Right] = $aArray[$iGreater + 1]
$aArray[$iGreater + 1] = $iPivot_2
__ArrayDualPivotSort($aArray, $iPivot_Left, $iLess - 2, True)
__ArrayDualPivotSort($aArray, $iGreater + 2, $iPivot_Right, False)
If($iLess < $iE1) And($iE5 < $iGreater) Then
While $aArray[$iLess] = $iPivot_1
$iLess += 1
WEnd
While $aArray[$iGreater] = $iPivot_2
$iGreater -= 1
WEnd
$k = $iLess
While $k <= $iGreater
$iAk = $aArray[$k]
If $iAk = $iPivot_1 Then
$aArray[$k] = $aArray[$iLess]
$aArray[$iLess] = $iAk
$iLess += 1
ElseIf $iAk = $iPivot_2 Then
While $aArray[$iGreater] = $iPivot_2
$iGreater -= 1
If $iGreater + 1 = $k Then ExitLoop 2
WEnd
If $aArray[$iGreater] = $iPivot_1 Then
$aArray[$k] = $aArray[$iLess]
$aArray[$iLess] = $iPivot_1
$iLess += 1
Else
$aArray[$k] = $aArray[$iGreater]
EndIf
$aArray[$iGreater] = $iAk
$iGreater -= 1
EndIf
$k += 1
WEnd
EndIf
__ArrayDualPivotSort($aArray, $iLess, $iGreater, False)
Else
Local $iPivot = $aArray[$iE3]
$k = $iLess
While $k <= $iGreater
If $aArray[$k] = $iPivot Then
$k += 1
ContinueLoop
EndIf
$iAk = $aArray[$k]
If $iAk < $iPivot Then
$aArray[$k] = $aArray[$iLess]
$aArray[$iLess] = $iAk
$iLess += 1
Else
While $aArray[$iGreater] > $iPivot
$iGreater -= 1
WEnd
If $aArray[$iGreater] < $iPivot Then
$aArray[$k] = $aArray[$iLess]
$aArray[$iLess] = $aArray[$iGreater]
$iLess += 1
Else
$aArray[$k] = $iPivot
EndIf
$aArray[$iGreater] = $iAk
$iGreater -= 1
EndIf
$k += 1
WEnd
__ArrayDualPivotSort($aArray, $iPivot_Left, $iLess - 1, True)
__ArrayDualPivotSort($aArray, $iGreater + 1, $iPivot_Right, False)
EndIf
EndFunc
Func _ArrayToString(Const ByRef $aArray, $sDelim_Col = "|", $iStart_Row = Default, $iEnd_Row = Default, $sDelim_Row = @CRLF, $iStart_Col = Default, $iEnd_Col = Default)
If $sDelim_Col = Default Then $sDelim_Col = "|"
If $sDelim_Row = Default Then $sDelim_Row = @CRLF
If $iStart_Row = Default Then $iStart_Row = -1
If $iEnd_Row = Default Then $iEnd_Row = -1
If $iStart_Col = Default Then $iStart_Col = -1
If $iEnd_Col = Default Then $iEnd_Col = -1
If Not IsArray($aArray) Then Return SetError(1, 0, -1)
Local $iDim_1 = UBound($aArray, $UBOUND_ROWS) - 1
If $iDim_1 = -1 Then Return ""
If $iStart_Row = -1 Then $iStart_Row = 0
If $iEnd_Row = -1 Then $iEnd_Row = $iDim_1
If $iStart_Row < -1 Or $iEnd_Row < -1 Then Return SetError(3, 0, -1)
If $iStart_Row > $iDim_1 Or $iEnd_Row > $iDim_1 Then Return SetError(3, 0, "")
If $iStart_Row > $iEnd_Row Then Return SetError(4, 0, -1)
Local $sRet = ""
Switch UBound($aArray, $UBOUND_DIMENSIONS)
Case 1
For $i = $iStart_Row To $iEnd_Row
$sRet &= $aArray[$i] & $sDelim_Col
Next
Return StringTrimRight($sRet, StringLen($sDelim_Col))
Case 2
Local $iDim_2 = UBound($aArray, $UBOUND_COLUMNS) - 1
If $iDim_2 = -1 Then Return ""
If $iStart_Col = -1 Then $iStart_Col = 0
If $iEnd_Col = -1 Then $iEnd_Col = $iDim_2
If $iStart_Col < -1 Or $iEnd_Col < -1 Then Return SetError(5, 0, -1)
If $iStart_Col > $iDim_2 Or $iEnd_Col > $iDim_2 Then Return SetError(5, 0, -1)
If $iStart_Col > $iEnd_Col Then Return SetError(6, 0, -1)
Local $iDelimColLen = StringLen($sDelim_Col)
For $i = $iStart_Row To $iEnd_Row
For $j = $iStart_Col To $iEnd_Col
$sRet &= $aArray[$i][$j] & $sDelim_Col
Next
$sRet = StringTrimRight($sRet, $iDelimColLen) & $sDelim_Row
Next
Return StringTrimRight($sRet, StringLen($sDelim_Row))
Case Else
Return SetError(2, 0, -1)
EndSwitch
Return 1
EndFunc
Global Const $BS_MULTILINE = 0x2000
Global Const $BS_PUSHLIKE = 0x1000
Global Const $BS_ICON = 0x0040
Global Const $CBS_AUTOHSCROLL = 0x40
Global Const $CBS_DROPDOWN = 0x2
Global Const $CBS_DROPDOWNLIST = 0x3
Global Const $GMEM_FIXED = 0x0000
Global Const $GMEM_ZEROINIT = 0x0040
Global Const $GPTR = BitOR($GMEM_FIXED, $GMEM_ZEROINIT)
Global Const $MEM_COMMIT = 0x00001000
Global Const $MEM_RESERVE = 0x00002000
Global Const $PAGE_READWRITE = 0x00000004
Global Const $PAGE_EXECUTE_READWRITE = 0x00000040
Global Const $MEM_RELEASE = 0x00008000
Global Const $PROCESS_VM_OPERATION = 0x00000008
Global Const $PROCESS_VM_READ = 0x00000010
Global Const $PROCESS_VM_WRITE = 0x00000020
Global Const $SE_DEBUG_NAME = "SeDebugPrivilege"
Global Const $SE_PRIVILEGE_ENABLED = 0x00000002
Global Enum $SECURITYANONYMOUS = 0, $SECURITYIDENTIFICATION, $SECURITYIMPERSONATION, $SECURITYDELEGATION
Global Const $TOKEN_QUERY = 0x00000008
Global Const $TOKEN_ADJUST_PRIVILEGES = 0x00000020
Global Const $FORMAT_MESSAGE_ALLOCATE_BUFFER = 0x00000100
Global Const $FORMAT_MESSAGE_IGNORE_INSERTS = 0x00000200
Global Const $FORMAT_MESSAGE_FROM_SYSTEM = 0x00001000
Func _WinAPI_FormatMessage($iFlags, $pSource, $iMessageID, $iLanguageID, ByRef $pBuffer, $iSize, $vArguments)
Local $sBufferType = "struct*"
If IsString($pBuffer) Then $sBufferType = "wstr"
Local $aCall = DllCall("kernel32.dll", "dword", "FormatMessageW", "dword", $iFlags, "struct*", $pSource, "dword", $iMessageID, "dword", $iLanguageID, $sBufferType, $pBuffer, "dword", $iSize, "ptr", $vArguments)
If @error Then Return SetError(@error, @extended, 0)
If Not $aCall[0] Then Return SetError(10, _WinAPI_GetLastError(), 0)
If $sBufferType = "wstr" Then $pBuffer = $aCall[5]
Return $aCall[0]
EndFunc
Func _WinAPI_GetLastError(Const $_iCallerError = @error, Const $_iCallerExtended = @extended)
Local $aCall = DllCall("kernel32.dll", "dword", "GetLastError")
Return SetError($_iCallerError, $_iCallerExtended, $aCall[0])
EndFunc
Func _WinAPI_GetLastErrorMessage(Const $_iCallerError = @error, Const $_iCallerExtended = @extended)
Local $iLastError = _WinAPI_GetLastError()
Local $tBufferPtr = DllStructCreate("ptr")
Local $nCount = _WinAPI_FormatMessage(BitOR($FORMAT_MESSAGE_ALLOCATE_BUFFER, $FORMAT_MESSAGE_FROM_SYSTEM, $FORMAT_MESSAGE_IGNORE_INSERTS), 0, $iLastError, 0, $tBufferPtr, 0, 0)
If @error Then Return SetError(-@error, @extended, "")
Local $sText = ""
Local $pBuffer = DllStructGetData($tBufferPtr, 1)
If $pBuffer Then
If $nCount > 0 Then
Local $tBuffer = DllStructCreate("wchar[" &($nCount + 1) & "]", $pBuffer)
$sText = DllStructGetData($tBuffer, 1)
If StringRight($sText, 2) = @CRLF Then $sText = StringTrimRight($sText, 2)
EndIf
DllCall("kernel32.dll", "handle", "LocalFree", "handle", $pBuffer)
EndIf
Return SetError($_iCallerError, $_iCallerExtended, $sText)
EndFunc
Func _WinAPI_SetLastError($iErrorCode, Const $_iCallerError = @error, Const $_iCallerExtended = @extended)
DllCall("kernel32.dll", "none", "SetLastError", "dword", $iErrorCode)
Return SetError($_iCallerError, $_iCallerExtended, Null)
EndFunc
Func _Security__AdjustTokenPrivileges($hToken, $bDisableAll, $tNewState, $iBufferLen, $tPrevState = 0, $pRequired = 0)
Local $aCall = DllCall("advapi32.dll", "bool", "AdjustTokenPrivileges", "handle", $hToken, "bool", $bDisableAll, "struct*", $tNewState, "dword", $iBufferLen, "struct*", $tPrevState, "struct*", $pRequired)
If @error Then Return SetError(@error, @extended, False)
Return Not($aCall[0] = 0)
EndFunc
Func _Security__ImpersonateSelf($iLevel = $SECURITYIMPERSONATION)
Local $aCall = DllCall("advapi32.dll", "bool", "ImpersonateSelf", "int", $iLevel)
If @error Then Return SetError(@error, @extended, False)
Return Not($aCall[0] = 0)
EndFunc
Func _Security__LookupPrivilegeValue($sSystem, $sName)
Local $aCall = DllCall("advapi32.dll", "bool", "LookupPrivilegeValueW", "wstr", $sSystem, "wstr", $sName, "int64*", 0)
If @error Or Not $aCall[0] Then Return SetError(@error + 10, @extended, 0)
Return $aCall[3]
EndFunc
Func _Security__OpenThreadToken($iAccess, $hThread = 0, $bOpenAsSelf = False)
Local $aCall
If $hThread = 0 Then
$aCall = DllCall("kernel32.dll", "handle", "GetCurrentThread")
If @error Then Return SetError(@error + 20, @extended, 0)
$hThread = $aCall[0]
EndIf
$aCall = DllCall("advapi32.dll", "bool", "OpenThreadToken", "handle", $hThread, "dword", $iAccess, "bool", $bOpenAsSelf, "handle*", 0)
If @error Or Not $aCall[0] Then Return SetError(@error + 10, @extended, 0)
Return $aCall[4]
EndFunc
Func _Security__OpenThreadTokenEx($iAccess, $hThread = 0, $bOpenAsSelf = False)
Local $hToken = _Security__OpenThreadToken($iAccess, $hThread, $bOpenAsSelf)
If $hToken = 0 Then
Local Const $ERROR_NO_TOKEN = 1008
If _WinAPI_GetLastError() <> $ERROR_NO_TOKEN Then Return SetError(20, _WinAPI_GetLastError(), 0)
If Not _Security__ImpersonateSelf() Then Return SetError(@error + 10, _WinAPI_GetLastError(), 0)
$hToken = _Security__OpenThreadToken($iAccess, $hThread, $bOpenAsSelf)
If $hToken = 0 Then Return SetError(@error, _WinAPI_GetLastError(), 0)
EndIf
Return $hToken
EndFunc
Func _Security__SetPrivilege($hToken, $sPrivilege, $bEnable)
Local $iLUID = _Security__LookupPrivilegeValue("", $sPrivilege)
If $iLUID = 0 Then Return SetError(@error + 10, @extended, False)
Local Const $tagTOKEN_PRIVILEGES = "dword Count;align 4;int64 LUID;dword Attributes"
Local $tCurrState = DllStructCreate($tagTOKEN_PRIVILEGES)
Local $iCurrState = DllStructGetSize($tCurrState)
Local $tPrevState = DllStructCreate($tagTOKEN_PRIVILEGES)
Local $iPrevState = DllStructGetSize($tPrevState)
Local $tRequired = DllStructCreate("int Data")
DllStructSetData($tCurrState, "Count", 1)
DllStructSetData($tCurrState, "LUID", $iLUID)
If Not _Security__AdjustTokenPrivileges($hToken, False, $tCurrState, $iCurrState, $tPrevState, $tRequired) Then Return SetError(2, @error, False)
DllStructSetData($tPrevState, "Count", 1)
DllStructSetData($tPrevState, "LUID", $iLUID)
Local $iAttributes = DllStructGetData($tPrevState, "Attributes")
If $bEnable Then
$iAttributes = BitOR($iAttributes, $SE_PRIVILEGE_ENABLED)
Else
$iAttributes = BitAND($iAttributes, BitNOT($SE_PRIVILEGE_ENABLED))
EndIf
DllStructSetData($tPrevState, "Attributes", $iAttributes)
If Not _Security__AdjustTokenPrivileges($hToken, False, $tPrevState, $iPrevState, $tCurrState, $tRequired) Then Return SetError(3, @error, False)
Return True
EndFunc
Global Const $tagPOINT = "struct;long X;long Y;endstruct"
Global Const $tagNMHDR = "struct;hwnd hWndFrom;uint_ptr IDFrom;INT Code;endstruct"
Global Const $tagGDIPSTARTUPINPUT = "uint Version;ptr Callback;bool NoThread;bool NoCodecs"
Global Const $tagLVITEM = "struct;uint Mask;int Item;int SubItem;uint State;uint StateMask;ptr Text;int TextMax;int Image;lparam Param;" & "int Indent;int GroupID;uint Columns;ptr pColumns;ptr piColFmt;int iGroup;endstruct"
Global Const $tagTVITEM = "struct;uint Mask;handle hItem;uint State;uint StateMask;ptr Text;int TextMax;int Image;int SelectedImage;" & "int Children;lparam Param;endstruct"
Global Const $tagTVITEMEX = "struct;" & $tagTVITEM & ";int Integral;uint uStateEx;hwnd hwnd;int iExpandedImage;int iReserved;endstruct"
Global Const $tagTVHITTESTINFO = $tagPOINT & ";uint Flags;handle Item"
Global Const $tagSECURITY_ATTRIBUTES = "dword Length;ptr Descriptor;bool InheritHandle"
Global Const $tagMEMMAP = "handle hProc;ulong_ptr Size;ptr Mem"
Func _MemFree(ByRef $tMemMap)
Local $pMemory = DllStructGetData($tMemMap, "Mem")
Local $hProcess = DllStructGetData($tMemMap, "hProc")
Local $bResult = _MemVirtualFreeEx($hProcess, $pMemory, 0, $MEM_RELEASE)
DllCall("kernel32.dll", "bool", "CloseHandle", "handle", $hProcess)
If @error Then Return SetError(@error, @extended, False)
Return $bResult
EndFunc
Func _MemGlobalAlloc($iBytes, $iFlags = 0)
Local $aCall = DllCall("kernel32.dll", "handle", "GlobalAlloc", "uint", $iFlags, "ulong_ptr", $iBytes)
If @error Then Return SetError(@error, @extended, 0)
Return $aCall[0]
EndFunc
Func _MemGlobalFree($hMemory)
Local $aCall = DllCall("kernel32.dll", "ptr", "GlobalFree", "handle", $hMemory)
If @error Then Return SetError(@error, @extended, False)
Return $aCall[0]
EndFunc
Func _MemInit($hWnd, $iSize, ByRef $tMemMap)
Local $aCall = DllCall("user32.dll", "dword", "GetWindowThreadProcessId", "hwnd", $hWnd, "dword*", 0)
If @error Then Return SetError(@error + 10, @extended, 0)
Local $iProcessID = $aCall[2]
If $iProcessID = 0 Then Return SetError(1, 0, 0)
Local $iAccess = BitOR($PROCESS_VM_OPERATION, $PROCESS_VM_READ, $PROCESS_VM_WRITE)
Local $hProcess = __Mem_OpenProcess($iAccess, False, $iProcessID, True)
Local $iAlloc = BitOR($MEM_RESERVE, $MEM_COMMIT)
Local $pMemory = _MemVirtualAllocEx($hProcess, 0, $iSize, $iAlloc, $PAGE_READWRITE)
If $pMemory = 0 Then Return SetError(2, 0, 0)
$tMemMap = DllStructCreate($tagMEMMAP)
DllStructSetData($tMemMap, "hProc", $hProcess)
DllStructSetData($tMemMap, "Size", $iSize)
DllStructSetData($tMemMap, "Mem", $pMemory)
Return $pMemory
EndFunc
Func _MemRead(ByRef $tMemMap, $pSrce, $pDest, $iSize)
Local $aCall = DllCall("kernel32.dll", "bool", "ReadProcessMemory", "handle", DllStructGetData($tMemMap, "hProc"), "ptr", $pSrce, "struct*", $pDest, "ulong_ptr", $iSize, "ulong_ptr*", 0)
If @error Then Return SetError(@error, @extended, False)
Return $aCall[0]
EndFunc
Func _MemWrite(ByRef $tMemMap, $pSrce, $pDest = 0, $iSize = 0, $sSrce = "struct*")
If $pDest = 0 Then $pDest = DllStructGetData($tMemMap, "Mem")
If $iSize = 0 Then $iSize = DllStructGetData($tMemMap, "Size")
Local $aCall = DllCall("kernel32.dll", "bool", "WriteProcessMemory", "handle", DllStructGetData($tMemMap, "hProc"), "ptr", $pDest, $sSrce, $pSrce, "ulong_ptr", $iSize, "ulong_ptr*", 0)
If @error Then Return SetError(@error, @extended, False)
Return $aCall[0]
EndFunc
Func _MemVirtualAlloc($pAddress, $iSize, $iAllocation, $iProtect)
Local $aCall = DllCall("kernel32.dll", "ptr", "VirtualAlloc", "ptr", $pAddress, "ulong_ptr", $iSize, "dword", $iAllocation, "dword", $iProtect)
If @error Then Return SetError(@error, @extended, 0)
Return $aCall[0]
EndFunc
Func _MemVirtualAllocEx($hProcess, $pAddress, $iSize, $iAllocation, $iProtect)
Local $aCall = DllCall("kernel32.dll", "ptr", "VirtualAllocEx", "handle", $hProcess, "ptr", $pAddress, "ulong_ptr", $iSize, "dword", $iAllocation, "dword", $iProtect)
If @error Then Return SetError(@error, @extended, 0)
Return $aCall[0]
EndFunc
Func _MemVirtualFree($pAddress, $iSize, $iFreeType)
Local $aCall = DllCall("kernel32.dll", "bool", "VirtualFree", "ptr", $pAddress, "ulong_ptr", $iSize, "dword", $iFreeType)
If @error Then Return SetError(@error, @extended, False)
Return $aCall[0]
EndFunc
Func _MemVirtualFreeEx($hProcess, $pAddress, $iSize, $iFreeType)
Local $aCall = DllCall("kernel32.dll", "bool", "VirtualFreeEx", "handle", $hProcess, "ptr", $pAddress, "ulong_ptr", $iSize, "dword", $iFreeType)
If @error Then Return SetError(@error, @extended, False)
Return $aCall[0]
EndFunc
Func __Mem_OpenProcess($iAccess, $bInherit, $iPID, $bDebugPriv = False)
Local $aCall = DllCall("kernel32.dll", "handle", "OpenProcess", "dword", $iAccess, "bool", $bInherit, "dword", $iPID)
If @error Then Return SetError(@error, @extended, 0)
If $aCall[0] Then Return $aCall[0]
If Not $bDebugPriv Then Return SetError(100, 0, 0)
Local $hToken = _Security__OpenThreadTokenEx(BitOR($TOKEN_ADJUST_PRIVILEGES, $TOKEN_QUERY))
If @error Then Return SetError(@error + 10, @extended, 0)
_Security__SetPrivilege($hToken, $SE_DEBUG_NAME, True)
Local $iError = @error
Local $iExtended = @extended
Local $iRet = 0
If Not @error Then
$aCall = DllCall("kernel32.dll", "handle", "OpenProcess", "dword", $iAccess, "bool", $bInherit, "dword", $iPID)
$iError = @error
$iExtended = @extended
If $aCall[0] Then $iRet = $aCall[0]
_Security__SetPrivilege($hToken, $SE_DEBUG_NAME, False)
If @error Then
$iError = @error + 20
$iExtended = @extended
EndIf
Else
$iError = @error + 30
EndIf
DllCall("kernel32.dll", "bool", "CloseHandle", "handle", $hToken)
Return SetError($iError, $iExtended, $iRet)
EndFunc
Global Const $FC_OVERWRITE = 1
Global Const $FC_CREATEPATH = 8
Global Const $FO_READ = 0
Global Const $FO_OVERWRITE = 2
Global Const $FO_CREATEPATH = 8
Global Const $FO_BINARY = 16
Global Const $FO_UTF8 = 128
Global Const $FD_FILEMUSTEXIST = 1
Global Const $FD_PATHMUSTEXIST = 2
Global Const $FD_MULTISELECT = 4
Global Const $FD_PROMPTOVERWRITE = 16
Global Const $CREATE_NEW = 1
Global Const $CREATE_ALWAYS = 2
Global Const $OPEN_EXISTING = 3
Global Const $OPEN_ALWAYS = 4
Global Const $TRUNCATE_EXISTING = 5
Global Const $FILE_BEGIN = 0
Global Const $FILE_ATTRIBUTE_READONLY = 0x00000001
Global Const $FILE_ATTRIBUTE_HIDDEN = 0x00000002
Global Const $FILE_ATTRIBUTE_SYSTEM = 0x00000004
Global Const $FILE_ATTRIBUTE_ARCHIVE = 0x00000020
Global Const $FILE_SHARE_READ = 0x00000001
Global Const $FILE_SHARE_WRITE = 0x00000002
Global Const $FILE_SHARE_DELETE = 0x00000004
Global Const $GENERIC_EXECUTE = 0x20000000
Global Const $GENERIC_WRITE = 0x40000000
Global Const $GENERIC_READ = 0x80000000
Global Const $FRTA_NOCOUNT = 0
Global Const $FRTA_COUNT = 1
Global Const $FRTA_INTARRAYS = 2
Global Const $FRTA_ENTIRESPLIT = 4
Global Const $FLTA_FILESFOLDERS = 0
Global Const $FLTA_FILES = 1
Global Const $FLTA_FOLDERS = 2
Global Const $PATH_ORIGINAL = 0
Global Const $PATH_DRIVE = 1
Global Const $PATH_DIRECTORY = 2
Global Const $PATH_FILENAME = 3
Global Const $PATH_EXTENSION = 4
Global Const $IMAGE_BITMAP = 0
Func _WinAPI_CreateFile($sFileName, $iCreation, $iAccess = 4, $iShare = 0, $iAttributes = 0, $tSecurity = 0)
Local $iDA = 0, $iSM = 0, $iCD = 0, $iFA = 0
If BitAND($iAccess, 1) <> 0 Then $iDA = BitOR($iDA, $GENERIC_EXECUTE)
If BitAND($iAccess, 2) <> 0 Then $iDA = BitOR($iDA, $GENERIC_READ)
If BitAND($iAccess, 4) <> 0 Then $iDA = BitOR($iDA, $GENERIC_WRITE)
If BitAND($iShare, 1) <> 0 Then $iSM = BitOR($iSM, $FILE_SHARE_DELETE)
If BitAND($iShare, 2) <> 0 Then $iSM = BitOR($iSM, $FILE_SHARE_READ)
If BitAND($iShare, 4) <> 0 Then $iSM = BitOR($iSM, $FILE_SHARE_WRITE)
Switch $iCreation
Case 0
$iCD = $CREATE_NEW
Case 1
$iCD = $CREATE_ALWAYS
Case 2
$iCD = $OPEN_EXISTING
Case 3
$iCD = $OPEN_ALWAYS
Case 4
$iCD = $TRUNCATE_EXISTING
EndSwitch
If BitAND($iAttributes, 1) <> 0 Then $iFA = BitOR($iFA, $FILE_ATTRIBUTE_ARCHIVE)
If BitAND($iAttributes, 2) <> 0 Then $iFA = BitOR($iFA, $FILE_ATTRIBUTE_HIDDEN)
If BitAND($iAttributes, 4) <> 0 Then $iFA = BitOR($iFA, $FILE_ATTRIBUTE_READONLY)
If BitAND($iAttributes, 8) <> 0 Then $iFA = BitOR($iFA, $FILE_ATTRIBUTE_SYSTEM)
Local $aCall = DllCall("kernel32.dll", "handle", "CreateFileW", "wstr", $sFileName, "dword", $iDA, "dword", $iSM, "struct*", $tSecurity, "dword", $iCD, "dword", $iFA, "ptr", 0)
If @error Or($aCall[0] = Ptr(-1)) Then Return SetError(@error, @extended, 0)
Return $aCall[0]
EndFunc
Func _WinAPI_GetDlgCtrlID($hWnd)
Local $aCall = DllCall("user32.dll", "int", "GetDlgCtrlID", "hwnd", $hWnd)
If @error Then Return SetError(@error, @extended, 0)
Return $aCall[0]
EndFunc
Func _WinAPI_GetModuleHandle($sModuleName)
If $sModuleName = "" Then $sModuleName = Null
Local $aCall = DllCall("kernel32.dll", "handle", "GetModuleHandleW", "wstr", $sModuleName)
If @error Then Return SetError(@error, @extended, 0)
Return $aCall[0]
EndFunc
Func _WinAPI_ReadFile($hFile, $pBuffer, $iToRead, ByRef $iRead, $tOverlapped = 0)
Local $aCall = DllCall("kernel32.dll", "bool", "ReadFile", "handle", $hFile, "struct*", $pBuffer, "dword", $iToRead, "dword*", 0, "struct*", $tOverlapped)
If @error Then Return SetError(@error, @extended, False)
$iRead = $aCall[4]
Return $aCall[0]
EndFunc
Func _WinAPI_CloseHandle($hObject)
Local $aCall = DllCall("kernel32.dll", "bool", "CloseHandle", "handle", $hObject)
If @error Then Return SetError(@error, @extended, False)
Return $aCall[0]
EndFunc
Func _WinAPI_DeleteObject($hObject)
Local $aCall = DllCall("gdi32.dll", "bool", "DeleteObject", "handle", $hObject)
If @error Then Return SetError(@error, @extended, False)
Return $aCall[0]
EndFunc
Func _WinAPI_GetStockObject($iObject)
Local $aCall = DllCall("gdi32.dll", "handle", "GetStockObject", "int", $iObject)
If @error Then Return SetError(@error, @extended, 0)
Return $aCall[0]
EndFunc
Func _SendMessage($hWnd, $iMsg, $wParam = 0, $lParam = 0, $iReturn = 0, $wParamType = "wparam", $lParamType = "lparam", $sReturnType = "lresult")
Local $aCall = DllCall("user32.dll", $sReturnType, "SendMessageW", "hwnd", $hWnd, "uint", $iMsg, $wParamType, $wParam, $lParamType, $lParam)
If @error Then Return SetError(@error, @extended, "")
If $iReturn >= 0 And $iReturn <= 4 Then Return $aCall[$iReturn]
Return $aCall
EndFunc
Global Const $__g_sReportWindowText_Debug = "Debug Window hidden text"
Global $__g_sReportTitle_Debug = "AutoIt Debug Report"
Global $__g_iReportType_Debug = 0
Global $__g_bReportWindowWaitClose_Debug = True, $__g_bReportWindowClosed_Debug = True
Global $__g_hReportEdit_Debug = 0
Global $__g_sReportCallBack_Debug
Global $__g_bReportTimeStamp_Debug = False
Func _DebugReport($sData, $bLastError = False, $bExit = False, Const $_iCallerError = @error, $_iCallerExtended = @extended)
If $__g_iReportType_Debug <= 0 Or $__g_iReportType_Debug > 6 Then Return SetError($_iCallerError, $_iCallerExtended, 0)
Local $iLastError = _WinAPI_GetLastError()
__Debug_ReportWrite($sData, $bLastError, $iLastError)
If $bExit Then Exit
_WinAPI_SetLastError($iLastError)
If $bLastError Then $_iCallerExtended = $iLastError
Return SetError($_iCallerError, $_iCallerExtended, 1)
EndFunc
Func __Debug_ReportWindowCreate()
Local $nOld = Opt("WinDetectHiddenText", $OPT_MATCHSTART)
Local $bExists = WinExists($__g_sReportTitle_Debug, $__g_sReportWindowText_Debug)
If $bExists Then
If $__g_hReportEdit_Debug = 0 Then
$__g_hReportEdit_Debug = ControlGetHandle($__g_sReportTitle_Debug, $__g_sReportWindowText_Debug, "Edit1")
$__g_bReportWindowWaitClose_Debug = False
EndIf
EndIf
Opt("WinDetectHiddenText", $nOld)
$__g_bReportWindowClosed_Debug = False
If Not $__g_bReportWindowWaitClose_Debug Then Return 0
Local Const $WS_OVERLAPPEDWINDOW = 0x00CF0000
Local Const $WS_HSCROLL = 0x00100000
Local Const $WS_VSCROLL = 0x00200000
Local Const $ES_READONLY = 2048
Local Const $EM_LIMITTEXT = 0xC5
Local Const $GUI_HIDE = 32
Local $w = 580, $h = 380
GUICreate($__g_sReportTitle_Debug, $w, $h, -1, -1, $WS_OVERLAPPEDWINDOW)
Local $idLabelHidden = GUICtrlCreateLabel($__g_sReportWindowText_Debug, 0, 0, 1, 1)
GUICtrlSetState($idLabelHidden, $GUI_HIDE)
Local $idEdit = GUICtrlCreateEdit("", 4, 4, $w - 8, $h - 8, BitOR($WS_HSCROLL, $WS_VSCROLL, $ES_READONLY))
$__g_hReportEdit_Debug = GUICtrlGetHandle($idEdit)
GUICtrlSetBkColor($idEdit, 0xFFFFFF)
GUICtrlSendMsg($idEdit, $EM_LIMITTEXT, 0, 0)
GUISetState()
$__g_bReportWindowWaitClose_Debug = True
Return 1
EndFunc
#Au3Stripper_Ignore_Funcs=__Debug_ReportWindowWrite
Func __Debug_ReportWindowWrite($sData)
If $__g_bReportWindowClosed_Debug Then __Debug_ReportWindowCreate()
Local Const $WM_GETTEXTLENGTH = 0x000E
Local Const $EM_SETSEL = 0xB1
Local Const $EM_REPLACESEL = 0xC2
Local $nLen = _SendMessage($__g_hReportEdit_Debug, $WM_GETTEXTLENGTH, 0, 0, 0, "int", "int")
_SendMessage($__g_hReportEdit_Debug, $EM_SETSEL, $nLen, $nLen, 0, "int", "int")
_SendMessage($__g_hReportEdit_Debug, $EM_REPLACESEL, True, $sData, 0, "int", "wstr")
EndFunc
Func __Debug_ReportNotepadCreate()
Local $bExists = WinExists($__g_sReportTitle_Debug)
If $bExists Then
If $__g_hReportEdit_Debug = 0 Then
$__g_hReportEdit_Debug = WinGetHandle($__g_sReportTitle_Debug)
Return 0
EndIf
EndIf
Local $pNotepad = Run("Notepad.exe")
$__g_hReportEdit_Debug = WinWait("[CLASS:Notepad]")
If $pNotepad <> WinGetProcess($__g_hReportEdit_Debug) Then
Return SetError(3, 0, 0)
EndIf
WinActivate($__g_hReportEdit_Debug)
WinSetTitle($__g_hReportEdit_Debug, "", String($__g_sReportTitle_Debug))
Return 1
EndFunc
#Au3Stripper_Ignore_Funcs=__Debug_ReportNotepadWrite
Func __Debug_ReportNotepadWrite($sData)
If $__g_hReportEdit_Debug = 0 Then __Debug_ReportNotepadCreate()
ControlCommand($__g_hReportEdit_Debug, "", "Edit1", "EditPaste", String($sData))
EndFunc
Func __Debug_ReportWrite($sData, $bLastError = False, $iLastError = 0)
Local $sError = ""
If $__g_bReportTimeStamp_Debug And($sData <> "") Then $sData = @YEAR & "/" & @MON & "/" & @MDAY & " " & @HOUR & ":" & @MIN & ":" & @SEC & " " & $sData
If $bLastError Then
$sError = " LastError = " & $iLastError & " : (" & _WinAPI_GetLastErrorMessage() & ")" & @CRLF
EndIf
$sData &= $sError
$sData = StringReplace($sData, "'", "''")
Local Static $sERROR_CODE = ">Error code:"
If StringInStr($sData, $sERROR_CODE) Then
$sData = StringReplace($sData, $sERROR_CODE, @TAB & $sERROR_CODE)
If(StringInStr($sData, $sERROR_CODE & " 0") = 0) Then
$sData = StringReplace($sData, $sERROR_CODE, $sERROR_CODE & @TAB & @TAB & @TAB & @TAB)
EndIf
EndIf
Execute($__g_sReportCallBack_Debug & "'" & $sData & "')")
Return
EndFunc
Global Const $ES_MULTILINE = 4
Global Const $ES_READONLY = 2048
Global Const $EN_CHANGE = 0x300
Func _FileListToArray($sFilePath, $sFilter = "*", $iFlag = $FLTA_FILESFOLDERS, $bReturnPath = False)
Local $sDelimiter = "|", $sFileList = "", $sFileName = "", $sFullPath = ""
$sFilePath = StringRegExpReplace($sFilePath, "[\\/]+$", "") & "\"
If $iFlag = Default Then $iFlag = $FLTA_FILESFOLDERS
If $bReturnPath Then $sFullPath = $sFilePath
If $sFilter = Default Then $sFilter = "*"
If Not FileExists($sFilePath) Then Return SetError(1, 0, 0)
If StringRegExp($sFilter, "[\\/:><\|]|(?s)^\s*$") Then Return SetError(2, 0, 0)
If Not($iFlag = 0 Or $iFlag = 1 Or $iFlag = 2) Then Return SetError(3, 0, 0)
Local $hSearch = FileFindFirstFile($sFilePath & $sFilter)
If @error Then Return SetError(4, 0, 0)
While 1
$sFileName = FileFindNextFile($hSearch)
If @error Then ExitLoop
If($iFlag + @extended = 2) Then ContinueLoop
$sFileList &= $sDelimiter & $sFullPath & $sFileName
WEnd
FileClose($hSearch)
If $sFileList = "" Then Return SetError(4, 0, 0)
Return StringSplit(StringTrimLeft($sFileList, 1), $sDelimiter)
EndFunc
Func _FileReadToArray($sFilePath, ByRef $vReturn, $iFlags = $FRTA_COUNT, $sDelimiter = "")
$vReturn = 0
If $iFlags = Default Then $iFlags = $FRTA_COUNT
If $sDelimiter = Default Then $sDelimiter = ""
Local $bExpand = True
If BitAND($iFlags, $FRTA_INTARRAYS) Then
$bExpand = False
$iFlags -= $FRTA_INTARRAYS
EndIf
Local $iEntire = $STR_CHRSPLIT
If BitAND($iFlags, $FRTA_ENTIRESPLIT) Then
$iEntire = $STR_ENTIRESPLIT
$iFlags -= $FRTA_ENTIRESPLIT
EndIf
Local $iNoCount = 0
If $iFlags <> $FRTA_COUNT Then
$iFlags = $FRTA_NOCOUNT
$iNoCount = $STR_NOCOUNT
EndIf
If $sDelimiter Then
Local $aLines = FileReadToArray($sFilePath)
If @error Then Return SetError(@error, 0, 0)
Local $iDim_1 = UBound($aLines) + $iFlags
If $bExpand Then
Local $iDim_2 = UBound(StringSplit($aLines[0], $sDelimiter, $iEntire + $STR_NOCOUNT))
Local $aTemp_Array[$iDim_1][$iDim_2]
Local $iFields, $aSplit
For $i = 0 To $iDim_1 - $iFlags - 1
$aSplit = StringSplit($aLines[$i], $sDelimiter, $iEntire + $STR_NOCOUNT)
$iFields = UBound($aSplit)
If $iFields <> $iDim_2 Then
Return SetError(3, 0, 0)
EndIf
For $j = 0 To $iFields - 1
$aTemp_Array[$i + $iFlags][$j] = $aSplit[$j]
Next
Next
If $iDim_2 < 2 Then Return SetError(4, 0, 0)
If $iFlags Then
$aTemp_Array[0][0] = $iDim_1 - $iFlags
$aTemp_Array[0][1] = $iDim_2
EndIf
Else
Local $aTemp_Array[$iDim_1]
For $i = 0 To $iDim_1 - $iFlags - 1
$aTemp_Array[$i + $iFlags] = StringSplit($aLines[$i], $sDelimiter, $iEntire + $iNoCount)
Next
If $iFlags Then
$aTemp_Array[0] = $iDim_1 - $iFlags
EndIf
EndIf
$vReturn = $aTemp_Array
Else
If $iFlags Then
Local $hFileOpen = FileOpen($sFilePath, $FO_READ)
If $hFileOpen = -1 Then Return SetError(1, 0, 0)
Local $sFileRead = FileRead($hFileOpen)
FileClose($hFileOpen)
If StringLen($sFileRead) Then
$vReturn = StringRegExp(@LF & $sFileRead, "(?|(\N+)\z|(\N*)(?:\R))", $STR_REGEXPARRAYGLOBALMATCH)
$vReturn[0] = UBound($vReturn) - 1
Else
Return SetError(2, 0, 0)
EndIf
Else
$vReturn = FileReadToArray($sFilePath)
If @error Then
$vReturn = 0
Return SetError(@error, 0, 0)
EndIf
EndIf
EndIf
Return 1
EndFunc
Func _PathFull($sRelativePath, $sBasePath = @WorkingDir)
If Not $sRelativePath Or $sRelativePath = "." Then Return $sBasePath
Local $sFullPath = StringReplace($sRelativePath, "/", "\")
Local Const $sFullPathConst = $sFullPath
Local $sPath
Local $bRootOnly = StringLeft($sFullPath, 1) = "\" And StringMid($sFullPath, 2, 1) <> "\"
If $sBasePath = Default Then $sBasePath = @WorkingDir
For $i = 1 To 2
$sPath = StringLeft($sFullPath, 2)
If $sPath = "\\" Then
$sFullPath = StringTrimLeft($sFullPath, 2)
Local $nServerLen = StringInStr($sFullPath, "\") - 1
$sPath = "\\" & StringLeft($sFullPath, $nServerLen)
$sFullPath = StringTrimLeft($sFullPath, $nServerLen)
ExitLoop
ElseIf StringRight($sPath, 1) = ":" Then
$sFullPath = StringTrimLeft($sFullPath, 2)
ExitLoop
Else
$sFullPath = $sBasePath & "\" & $sFullPath
EndIf
Next
If StringLeft($sFullPath, 1) <> "\" Then
If StringLeft($sFullPathConst, 2) = StringLeft($sBasePath, 2) Then
$sFullPath = $sBasePath & "\" & $sFullPath
Else
$sFullPath = "\" & $sFullPath
EndIf
EndIf
Local $aTemp = StringSplit($sFullPath, "\")
Local $aPathParts[$aTemp[0]], $j = 0
For $i = 2 To $aTemp[0]
If $aTemp[$i] = ".." Then
If $j Then $j -= 1
ElseIf Not($aTemp[$i] = "" And $i <> $aTemp[0]) And $aTemp[$i] <> "." Then
$aPathParts[$j] = $aTemp[$i]
$j += 1
EndIf
Next
$sFullPath = $sPath
If Not $bRootOnly Then
For $i = 0 To $j - 1
$sFullPath &= "\" & $aPathParts[$i]
Next
Else
$sFullPath &= $sFullPathConst
If StringInStr($sFullPath, "..") Then $sFullPath = _PathFull($sFullPath)
EndIf
Do
$sFullPath = StringReplace($sFullPath, ".\", "\")
Until @extended = 0
Return $sFullPath
EndFunc
Func _PathSplit($sFilePath, ByRef $sDrive, ByRef $sDir, ByRef $sFileName, ByRef $sExtension)
Local $aArray = StringRegExp($sFilePath, "^\h*((?:\\\\\?\\)*(\\\\[^\?\/\\]+|[A-Za-z]:)?(.*[\/\\]\h*)?((?:[^\.\/\\]|(?(?=\.[^\/\\]*\.)\.))*)?([^\/\\]*))$", $STR_REGEXPARRAYMATCH)
If @error Then
ReDim $aArray[5]
$aArray[$PATH_ORIGINAL] = $sFilePath
EndIf
$sDrive = $aArray[$PATH_DRIVE]
If StringLeft($aArray[$PATH_DIRECTORY], 1) == "/" Then
$sDir = StringRegExpReplace($aArray[$PATH_DIRECTORY], "\h*[\/\\]+\h*", "\/")
Else
$sDir = StringRegExpReplace($aArray[$PATH_DIRECTORY], "\h*[\/\\]+\h*", "\\")
EndIf
$aArray[$PATH_DIRECTORY] = $sDir
$sFileName = $aArray[$PATH_FILENAME]
$sExtension = $aArray[$PATH_EXTENSION]
Return $aArray
EndFunc
Func _TempFile($sDirectoryName = @TempDir, $sFilePrefix = "~", $sFileExtension = ".tmp", $iRandomLength = 7)
If $iRandomLength = Default Or $iRandomLength <= 0 Then $iRandomLength = 7
If $sDirectoryName = Default Or(Not FileExists($sDirectoryName)) Then $sDirectoryName = @TempDir
If $sFileExtension = Default Then $sFileExtension = ".tmp"
If $sFilePrefix = Default Then $sFilePrefix = "~"
If Not FileExists($sDirectoryName) Then $sDirectoryName = @ScriptDir
$sDirectoryName = StringRegExpReplace($sDirectoryName, "[\\/]+$", "")
$sFileExtension = StringRegExpReplace($sFileExtension, "^\.+", "")
$sFilePrefix = StringRegExpReplace($sFilePrefix, '[\\/:*?"<>|]', "")
Local $sTempName = ""
Do
$sTempName = ""
While StringLen($sTempName) < $iRandomLength
$sTempName &= Chr(Random(97, 122, 1))
WEnd
$sTempName = $sDirectoryName & "\" & $sFilePrefix & $sTempName & "." & $sFileExtension
Until Not FileExists($sTempName)
Return $sTempName
EndFunc
Func _WinAPI_HiWord($iLong)
Return BitShift($iLong, 16)
EndFunc
Func _WinAPI_MultiByteToWideChar($vText, $iCodePage = 0, $iFlags = 0, $bRetString = False)
Local $sTextType = ""
If IsString($vText) Then $sTextType = "str"
If(IsDllStruct($vText) Or IsPtr($vText)) Then $sTextType = "struct*"
If $sTextType = "" Then Return SetError(1, 0, 0)
Local $aCall = DllCall("kernel32.dll", "int", "MultiByteToWideChar", "uint", $iCodePage, "dword", $iFlags, $sTextType, $vText, "int", -1, "ptr", 0, "int", 0)
If @error Or Not $aCall[0] Then Return SetError(@error + 10, @extended, 0)
Local $iOut = $aCall[0]
Local $tOut = DllStructCreate("wchar[" & $iOut & "]")
$aCall = DllCall("kernel32.dll", "int", "MultiByteToWideChar", "uint", $iCodePage, "dword", $iFlags, $sTextType, $vText, "int", -1, "struct*", $tOut, "int", $iOut)
If @error Or Not $aCall[0] Then Return SetError(@error + 20, @extended, 0)
If $bRetString Then Return DllStructGetData($tOut, 1)
Return $tOut
EndFunc
Func _WinAPI_ScreenToClient($hWnd, ByRef $tPoint)
Local $aCall = DllCall("user32.dll", "bool", "ScreenToClient", "hwnd", $hWnd, "struct*", $tPoint)
If @error Then Return SetError(@error, @extended, False)
Return $aCall[0]
EndFunc
Func _WinAPI_GetMousePos($bToClient = False, $hWnd = 0)
Local $iMode = Opt("MouseCoordMode", 1)
Local $aPos = MouseGetPos()
Opt("MouseCoordMode", $iMode)
Local $tPOINT = DllStructCreate($tagPOINT)
DllStructSetData($tPOINT, "X", $aPos[0])
DllStructSetData($tPOINT, "Y", $aPos[1])
If $bToClient And Not _WinAPI_ScreenToClient($hWnd, $tPOINT) Then Return SetError(@error + 20, @extended, 0)
Return $tPOINT
EndFunc
Func _WinAPI_DestroyIcon($hIcon)
Local $aCall = DllCall("user32.dll", "bool", "DestroyIcon", "handle", $hIcon)
If @error Then Return SetError(@error, @extended, False)
Return $aCall[0]
EndFunc
Func _WinAPI_ExtractIconEx($sFilePath, $iIndex, $paLarge, $paSmall, $iIcons)
Local $aCall = DllCall("shell32.dll", "uint", "ExtractIconExW", "wstr", $sFilePath, "int", $iIndex, "struct*", $paLarge, "struct*", $paSmall, "uint", $iIcons)
If @error Then Return SetError(@error, @extended, 0)
Return $aCall[0]
EndFunc
Global $__g_hGDIPDll = 0
Global $__g_iGDIPRef = 0
Global $__g_iGDIPToken = 0
Global $__g_bGDIP_V1_0 = True
Func _GDIPlus_BitmapCreateHBITMAPFromBitmap($hBitmap, $iARGB = 0xFF000000)
Local $aCall = DllCall($__g_hGDIPDll, "int", "GdipCreateHBITMAPFromBitmap", "handle", $hBitmap, "handle*", 0, "dword", $iARGB)
If @error Then Return SetError(@error, @extended, 0)
If $aCall[0] Then Return SetError(10, $aCall[0], 0)
Return $aCall[2]
EndFunc
Func _GDIPlus_ImageDispose($hImage)
Local $aCall = DllCall($__g_hGDIPDll, "int", "GdipDisposeImage", "handle", $hImage)
If @error Then Return SetError(@error, @extended, False)
If $aCall[0] Then Return SetError(10, $aCall[0], False)
Return True
EndFunc
Func _GDIPlus_ImageGetHeight($hImage)
Local $aCall = DllCall($__g_hGDIPDll, "int", "GdipGetImageHeight", "handle", $hImage, "uint*", 0)
If @error Then Return SetError(@error, @extended, -1)
If $aCall[0] Then Return SetError(10, $aCall[0], -1)
Return $aCall[2]
EndFunc
Func _GDIPlus_ImageGetWidth($hImage)
Local $aCall = DllCall($__g_hGDIPDll, "int", "GdipGetImageWidth", "handle", $hImage, "uint*", -1)
If @error Then Return SetError(@error, @extended, -1)
If $aCall[0] Then Return SetError(10, $aCall[0], -1)
Return $aCall[2]
EndFunc
Func _GDIPlus_ImageLoadFromFile($sFileName)
Local $aCall = DllCall($__g_hGDIPDll, "int", "GdipLoadImageFromFile", "wstr", $sFileName, "handle*", 0)
If @error Then Return SetError(@error, @extended, 0)
If $aCall[0] Then Return SetError(10, $aCall[0], 0)
Return $aCall[2]
EndFunc
Func _GDIPlus_Shutdown()
If $__g_hGDIPDll = 0 Then Return SetError(-1, -1, False)
$__g_iGDIPRef -= 1
If $__g_iGDIPRef = 0 Then
DllCall($__g_hGDIPDll, "none", "GdiplusShutdown", "ulong_ptr", $__g_iGDIPToken)
DllClose($__g_hGDIPDll)
$__g_hGDIPDll = 0
EndIf
Return True
EndFunc
Func _GDIPlus_Startup($sGDIPDLL = Default, $bRetDllHandle = False)
$__g_iGDIPRef += 1
If $__g_iGDIPRef > 1 Then Return True
If $sGDIPDLL = Default Then $sGDIPDLL = "gdiplus.dll"
$__g_hGDIPDll = DllOpen($sGDIPDLL)
If $__g_hGDIPDll = -1 Then
$__g_iGDIPRef = 0
Return SetError(1, 2, False)
EndIf
Local $sVer = FileGetVersion($sGDIPDLL)
$sVer = StringSplit($sVer, ".")
If $sVer[1] > 5 Then $__g_bGDIP_V1_0 = False
Local $tInput = DllStructCreate($tagGDIPSTARTUPINPUT)
Local $tToken = DllStructCreate("ulong_ptr Data")
DllStructSetData($tInput, "Version", 1)
Local $aCall = DllCall($__g_hGDIPDll, "int", "GdiplusStartup", "struct*", $tToken, "struct*", $tInput, "ptr", 0)
If @error Then Return SetError(@error, @extended, False)
If $aCall[0] Then Return SetError(10, $aCall[0], False)
$__g_iGDIPToken = DllStructGetData($tToken, "Data")
If $bRetDllHandle Then Return $__g_hGDIPDll
Return SetExtended($sVer[1], True)
EndFunc
Global Const $GUI_EVENT_CLOSE = -3
Global Const $GUI_RUNDEFMSG = 'GUI_RUNDEFMSG'
Global Const $GUI_CHECKED = 1
Global Const $GUI_UNCHECKED = 4
Global Const $GUI_SHOW = 16
Global Const $GUI_HIDE = 32
Global Const $GUI_ENABLE = 64
Global Const $GUI_DISABLE = 128
Global Const $GUI_FOCUS = 256
Global Const $GUI_EXPAND = 1024
Global Const $GUI_GR_LINE = 2
Global Const $_UDF_GlobalIDs_OFFSET = 2
Global Const $_UDF_GlobalID_MAX_WIN = 16
Global Const $_UDF_STARTID = 10000
Global Const $_UDF_GlobalID_MAX_IDS = 55535
Global Const $__UDFGUICONSTANT_WS_VISIBLE = 0x10000000
Global Const $__UDFGUICONSTANT_WS_CHILD = 0x40000000
Global $__g_aUDF_GlobalIDs_Used[$_UDF_GlobalID_MAX_WIN][$_UDF_GlobalID_MAX_IDS + $_UDF_GlobalIDs_OFFSET + 1]
Func __UDF_GetNextGlobalID($hWnd)
Local $nCtrlID, $iUsedIndex = -1, $bAllUsed = True
If Not WinExists($hWnd) Then Return SetError(-1, -1, 0)
For $iIndex = 0 To $_UDF_GlobalID_MAX_WIN - 1
If $__g_aUDF_GlobalIDs_Used[$iIndex][0] <> 0 Then
If Not WinExists($__g_aUDF_GlobalIDs_Used[$iIndex][0]) Then
For $x = 0 To UBound($__g_aUDF_GlobalIDs_Used, $UBOUND_COLUMNS) - 1
$__g_aUDF_GlobalIDs_Used[$iIndex][$x] = 0
Next
$__g_aUDF_GlobalIDs_Used[$iIndex][1] = $_UDF_STARTID
$bAllUsed = False
EndIf
EndIf
Next
For $iIndex = 0 To $_UDF_GlobalID_MAX_WIN - 1
If $__g_aUDF_GlobalIDs_Used[$iIndex][0] = $hWnd Then
$iUsedIndex = $iIndex
ExitLoop
EndIf
Next
If $iUsedIndex = -1 Then
For $iIndex = 0 To $_UDF_GlobalID_MAX_WIN - 1
If $__g_aUDF_GlobalIDs_Used[$iIndex][0] = 0 Then
$__g_aUDF_GlobalIDs_Used[$iIndex][0] = $hWnd
$__g_aUDF_GlobalIDs_Used[$iIndex][1] = $_UDF_STARTID
$bAllUsed = False
$iUsedIndex = $iIndex
ExitLoop
EndIf
Next
EndIf
If $iUsedIndex = -1 And $bAllUsed Then Return SetError(16, 0, 0)
If $__g_aUDF_GlobalIDs_Used[$iUsedIndex][1] = $_UDF_STARTID + $_UDF_GlobalID_MAX_IDS Then
For $iIDIndex = $_UDF_GlobalIDs_OFFSET To UBound($__g_aUDF_GlobalIDs_Used, $UBOUND_COLUMNS) - 1
If $__g_aUDF_GlobalIDs_Used[$iUsedIndex][$iIDIndex] = 0 Then
$nCtrlID =($iIDIndex - $_UDF_GlobalIDs_OFFSET) + 10000
$__g_aUDF_GlobalIDs_Used[$iUsedIndex][$iIDIndex] = $nCtrlID
Return $nCtrlID
EndIf
Next
Return SetError(-1, $_UDF_GlobalID_MAX_IDS, 0)
EndIf
$nCtrlID = $__g_aUDF_GlobalIDs_Used[$iUsedIndex][1]
$__g_aUDF_GlobalIDs_Used[$iUsedIndex][1] += 1
$__g_aUDF_GlobalIDs_Used[$iUsedIndex][($nCtrlID - 10000) + $_UDF_GlobalIDs_OFFSET] = $nCtrlID
Return $nCtrlID
EndFunc
Global $__g_aInProcess_WinAPI[64][2] = [[0, 0]]
Func _WinAPI_CreateWindowEx($iExStyle, $sClass, $sName, $iStyle, $iX, $iY, $iWidth, $iHeight, $hParent, $hMenu = 0, $hInstance = 0, $pParam = 0)
If $hInstance = 0 Then $hInstance = _WinAPI_GetModuleHandle("")
Local $aCall = DllCall("user32.dll", "hwnd", "CreateWindowExW", "dword", $iExStyle, "wstr", $sClass, "wstr", $sName, "dword", $iStyle, "int", $iX, "int", $iY, "int", $iWidth, "int", $iHeight, "hwnd", $hParent, "handle", $hMenu, "handle", $hInstance, "struct*", $pParam)
If @error Then Return SetError(@error, @extended, 0)
Return $aCall[0]
EndFunc
Func _WinAPI_GetClassName($hWnd)
If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)
Local $aCall = DllCall("user32.dll", "int", "GetClassNameW", "hwnd", $hWnd, "wstr", "", "int", 4096)
If @error Or Not $aCall[0] Then Return SetError(@error, @extended, '')
Return SetExtended($aCall[0], $aCall[2])
EndFunc
Func _WinAPI_GetWindowThreadProcessId($hWnd, ByRef $iPID)
Local $aCall = DllCall("user32.dll", "dword", "GetWindowThreadProcessId", "hwnd", $hWnd, "dword*", 0)
If @error Then Return SetError(@error, @extended, 0)
$iPID = $aCall[2]
Return $aCall[0]
EndFunc
Func _WinAPI_InProcess($hWnd, ByRef $hLastWnd)
If $hWnd = $hLastWnd Then Return True
For $iI = $__g_aInProcess_WinAPI[0][0] To 1 Step -1
If $hWnd = $__g_aInProcess_WinAPI[$iI][0] Then
If $__g_aInProcess_WinAPI[$iI][1] Then
$hLastWnd = $hWnd
Return True
Else
Return False
EndIf
EndIf
Next
Local $iPID
_WinAPI_GetWindowThreadProcessId($hWnd, $iPID)
Local $iCount = $__g_aInProcess_WinAPI[0][0] + 1
If $iCount >= 64 Then $iCount = 1
$__g_aInProcess_WinAPI[0][0] = $iCount
$__g_aInProcess_WinAPI[$iCount][0] = $hWnd
$__g_aInProcess_WinAPI[$iCount][1] =($iPID = @AutoItPID)
Return $__g_aInProcess_WinAPI[$iCount][1]
EndFunc
Func _WinAPI_InvalidateRect($hWnd, $tRECT = 0, $bErase = True)
If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)
Local $aCall = DllCall("user32.dll", "bool", "InvalidateRect", "hwnd", $hWnd, "struct*", $tRECT, "bool", $bErase)
If @error Then Return SetError(@error, @extended, False)
Return $aCall[0]
EndFunc
Func _WinAPI_IsClassName($hWnd, $sClassName)
Local $sSeparator = Opt("GUIDataSeparatorChar")
Local $aClassName = StringSplit($sClassName, $sSeparator)
If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)
Local $sClassCheck = _WinAPI_GetClassName($hWnd)
For $x = 1 To UBound($aClassName) - 1
If StringUpper(StringMid($sClassCheck, 1, StringLen($aClassName[$x]))) = StringUpper($aClassName[$x]) Then Return True
Next
Return False
EndFunc
Func _WinAPI_SetWindowText($hWnd, $sText)
Local $aCall = DllCall("user32.dll", "bool", "SetWindowTextW", "hwnd", $hWnd, "wstr", $sText)
If @error Then Return SetError(@error, @extended, False)
Return $aCall[0]
EndFunc
Global Const $ILC_MASK = 0x00000001
Global Const $ILC_COLOR = 0x00000000
Global Const $ILC_COLORDDB = 0x000000FE
Global Const $ILC_COLOR4 = 0x00000004
Global Const $ILC_COLOR8 = 0x00000008
Global Const $ILC_COLOR16 = 0x00000010
Global Const $ILC_COLOR24 = 0x00000018
Global Const $ILC_COLOR32 = 0x00000020
Global Const $ILC_MIRROR = 0x00002000
Global Const $ILC_PERITEMMIRROR = 0x00008000
Global Const $HGDI_ERROR = Ptr(-1)
Global Const $INVALID_HANDLE_VALUE = Ptr(-1)
Global Const $KF_EXTENDED = 0x0100
Global Const $KF_ALTDOWN = 0x2000
Global Const $KF_UP = 0x8000
Global Const $LLKHF_EXTENDED = BitShift($KF_EXTENDED, 8)
Global Const $LLKHF_ALTDOWN = BitShift($KF_ALTDOWN, 8)
Global Const $LLKHF_UP = BitShift($KF_UP, 8)
Func _GUIImageList_AddIcon($hWnd, $sFilePath, $iIndex = 0, $bLarge = False)
Local $iRet, $tIcon = DllStructCreate("handle Handle")
If $bLarge Then
$iRet = _WinAPI_ExtractIconEx($sFilePath, $iIndex, $tIcon, 0, 1)
Else
$iRet = _WinAPI_ExtractIconEx($sFilePath, $iIndex, 0, $tIcon, 1)
EndIf
If $iRet <= 0 Then Return SetError(-1, $iRet, -1)
Local $hIcon = DllStructGetData($tIcon, "Handle")
$iRet = _GUIImageList_ReplaceIcon($hWnd, -1, $hIcon)
_WinAPI_DestroyIcon($hIcon)
If $iRet = -1 Then Return SetError(-2, $iRet, -1)
Return $iRet
EndFunc
Func _GUIImageList_Create($iCX = 16, $iCY = 16, $iColor = 4, $iOptions = 0, $iInitial = 4, $iGrow = 4)
Local Const $aColor[7] = [$ILC_COLOR, $ILC_COLOR4, $ILC_COLOR8, $ILC_COLOR16, $ILC_COLOR24, $ILC_COLOR32, $ILC_COLORDDB]
Local $iFlags = 0
If BitAND($iOptions, 1) <> 0 Then $iFlags = BitOR($iFlags, $ILC_MASK)
If BitAND($iOptions, 2) <> 0 Then $iFlags = BitOR($iFlags, $ILC_MIRROR)
If BitAND($iOptions, 4) <> 0 Then $iFlags = BitOR($iFlags, $ILC_PERITEMMIRROR)
$iFlags = BitOR($iFlags, $aColor[$iColor])
Local $aCall = DllCall("comctl32.dll", "handle", "ImageList_Create", "int", $iCX, "int", $iCY, "uint", $iFlags, "int", $iInitial, "int", $iGrow)
If @error Then Return SetError(@error, @extended, 0)
Return $aCall[0]
EndFunc
Func _GUIImageList_ReplaceIcon($hWnd, $iIndex, $hIcon)
Local $aCall = DllCall("comctl32.dll", "int", "ImageList_ReplaceIcon", "handle", $hWnd, "int", $iIndex, "handle", $hIcon)
If @error Then Return SetError(@error, @extended, -1)
Return $aCall[0]
EndFunc
Global $__g_hGUICtrl_LastWnd
Func __GUICtrl_SendMsg($hWnd, $iMsg, $iIndex, ByRef $tItem, $tBuffer = 0, $bRetItem = False, $iElement = -1, $bRetBuffer = False, $iElementMax = $iElement)
If $iElement > 0 Then
DllStructSetData($tItem, $iElement, DllStructGetPtr($tBuffer))
If $iElement = $iElementMax Then DllStructSetData($tItem, $iElement + 1, DllStructGetSize($tBuffer))
EndIf
Local $iRet
If IsHWnd($hWnd) Then
If _WinAPI_InProcess($hWnd, $__g_hGUICtrl_LastWnd) Then
$iRet = DllCall("user32.dll", "lresult", "SendMessageW", "hwnd", $hWnd, "uint", $iMsg, "wparam", $iIndex, "struct*", $tItem)[0]
Else
Local $iItem = DllStructGetSize($tItem)
Local $tMemMap, $pText
Local $iBuffer = 0
If($iElement > 0) Or($iElementMax = 0) Then $iBuffer = DllStructGetSize($tBuffer)
Local $pMemory = _MemInit($hWnd, $iItem + $iBuffer, $tMemMap)
If $iBuffer Then
$pText = $pMemory + $iItem
If $iElementMax Then
DllStructSetData($tItem, $iElement, $pText)
Else
$iIndex = $pText
EndIf
_MemWrite($tMemMap, $tBuffer, $pText, $iBuffer)
EndIf
_MemWrite($tMemMap, $tItem, $pMemory, $iItem)
$iRet = DllCall("user32.dll", "lresult", "SendMessageW", "hwnd", $hWnd, "uint", $iMsg, "wparam", $iIndex, "ptr", $pMemory)[0]
If $iBuffer And $bRetBuffer Then _MemRead($tMemMap, $pText, $tBuffer, $iBuffer)
If $bRetItem Then _MemRead($tMemMap, $pMemory, $tItem, $iItem)
_MemFree($tMemMap)
EndIf
Else
$iRet = GUICtrlSendMsg($hWnd, $iMsg, $iIndex, DllStructGetPtr($tItem))
EndIf
Return $iRet
EndFunc
Global Const $LVGS_NORMAL = 0x00000000
Global Const $LVGS_SELECTED = 0x00000020
Global Const $LVGA_HEADER_LEFT = 0x00000001
Global Const $LVGA_HEADER_CENTER = 0x00000002
Global Const $LVGA_HEADER_RIGHT = 0x00000004
Global Const $LVGF_ALIGN = 0x00000008
Global Const $LVGF_GROUPID = 0x00000010
Global Const $LVGF_HEADER = 0x00000001
Global Const $LVGF_ITEMS = 0x00004000
Global Const $LVGF_STATE = 0x00000004
Global Const $LVIF_GROUPID = 0x00000100
Global Const $LVIF_IMAGE = 0x00000002
Global Const $LVIF_PARAM = 0x00000004
Global Const $LVIF_TEXT = 0x00000001
Global Const $LVS_NOCOLUMNHEADER = 0x4000
Global Const $LVS_SHOWSELALWAYS = 0x0008
Global Const $LVS_SINGLESEL = 0x0004
Global Const $LVS_EX_FULLROWSELECT = 0x00000020
Global Const $LVM_FIRST = 0x1000
Global Const $LVM_DELETEALLITEMS =($LVM_FIRST + 9)
Global Const $LVM_ENABLEGROUPVIEW =($LVM_FIRST + 157)
Global Const $LVM_GETGROUPINFO =($LVM_FIRST + 149)
Global Const $LVM_GETHEADER =($LVM_FIRST + 31)
Global Const $LVM_GETITEMA =($LVM_FIRST + 5)
Global Const $LVM_GETITEMW =($LVM_FIRST + 75)
Global Const $LVM_GETITEMCOUNT =($LVM_FIRST + 4)
Global Const $LVM_GETITEMTEXTA =($LVM_FIRST + 45)
Global Const $LVM_GETITEMTEXTW =($LVM_FIRST + 115)
Global Const $LVM_GETNEXTITEM =($LVM_FIRST + 12)
Global Const $LVM_GETSELECTEDCOUNT =($LVM_FIRST + 50)
Global Const $LVM_GETUNICODEFORMAT = 0x2000 + 6
Global Const $LVM_INSERTGROUP =($LVM_FIRST + 145)
Global Const $LVM_INSERTITEMA =($LVM_FIRST + 7)
Global Const $LVM_INSERTITEMW =($LVM_FIRST + 77)
Global Const $LVM_SETCOLUMNWIDTH =($LVM_FIRST + 30)
Global Const $LVM_SETGROUPINFO =($LVM_FIRST + 147)
Global Const $LVM_SETIMAGELIST =($LVM_FIRST + 3)
Global Const $LVM_SETITEMA =($LVM_FIRST + 6)
Global Const $LVM_SETITEMW =($LVM_FIRST + 76)
Global Const $LVN_FIRST = -100
Global Const $LVN_BEGINDRAG =($LVN_FIRST - 9)
Global Const $LVN_ITEMCHANGED =($LVN_FIRST - 1)
Global Const $LVNI_SELECTED = 0x0002
Global Const $LVSCW_AUTOSIZE_USEHEADER = -2
Global Const $LVSIL_NORMAL = 0
Global Const $LVSIL_SMALL = 1
Global Const $LVSIL_STATE = 2
Global Const $__LISTVIEWCONSTANT_SORTINFOSIZE = 11
Global $__g_aListViewSortInfo[1][$__LISTVIEWCONSTANT_SORTINFOSIZE]
Global $__g_tListViewBuffer, $__g_tListViewBufferANSI
Global $__g_tListViewItem = DllStructCreate($tagLVITEM)
Global Const $__LISTVIEWCONSTANT_WM_SETREDRAW = 0x000B
Global Const $tagLVGROUP = "uint Size;uint Mask;ptr Header;int HeaderMax;ptr Footer;int FooterMax;int GroupID;uint StateMask;uint State;uint Align;" & "ptr  pszSubtitle;uint cchSubtitle;ptr pszTask;uint cchTask;ptr pszDescriptionTop;uint cchDescriptionTop;ptr pszDescriptionBottom;" & "uint cchDescriptionBottom;int iTitleImage;int iExtendedImage;int iFirstItem;uint cItems;ptr pszSubsetTitle;uint cchSubsetTitle"
Func _GUICtrlListView_AddItem($hWnd, $sText, $iImage = -1, $iParam = 0)
Return _GUICtrlListView_InsertItem($hWnd, $sText, -1, $iImage, $iParam)
EndFunc
Func _GUICtrlListView_AddSubItem($hWnd, $iIndex, $sText, $iSubItem, $iImage = -1)
Local $tBuffer, $iMsg
If _GUICtrlListView_GetUnicodeFormat($hWnd) Then
$tBuffer = $__g_tListViewBuffer
$iMsg = $LVM_SETITEMW
Else
$tBuffer = $__g_tListViewBufferANSI
$iMsg = $LVM_SETITEMA
EndIf
Local $tItem = $__g_tListViewItem
Local $iMask = $LVIF_TEXT
If $iImage <> -1 Then $iMask = BitOR($iMask, $LVIF_IMAGE)
DllStructSetData($tBuffer, 1, $sText)
DllStructSetData($tItem, "Mask", $iMask)
DllStructSetData($tItem, "Item", $iIndex)
DllStructSetData($tItem, "SubItem", $iSubItem)
DllStructSetData($tItem, "Image", $iImage)
Local $iRet = __GUICtrl_SendMsg($hWnd, $iMsg, 0, $tItem, $tBuffer, False, 6, False, -1)
Return $iRet <> 0
EndFunc
Func _GUICtrlListView_BeginUpdate($hWnd)
If IsHWnd($hWnd) Then
Return _SendMessage($hWnd, $__LISTVIEWCONSTANT_WM_SETREDRAW, False) = 0
Else
Return GUICtrlSendMsg($hWnd, $__LISTVIEWCONSTANT_WM_SETREDRAW, False, 0) = 0
EndIf
EndFunc
Func _GUICtrlListView_DeleteAllItems($hWnd)
If _GUICtrlListView_GetItemCount($hWnd) = 0 Then Return True
Local $vCID = 0
If IsHWnd($hWnd) Then
$vCID = _WinAPI_GetDlgCtrlID($hWnd)
Else
$vCID = $hWnd
$hWnd = GUICtrlGetHandle($hWnd)
EndIf
If $vCID < $_UDF_STARTID Then
Local $iParam = 0
For $iIndex = _GUICtrlListView_GetItemCount($hWnd) - 1 To 0 Step -1
$iParam = _GUICtrlListView_GetItemParam($hWnd, $iIndex)
If GUICtrlGetState($iParam) > 0 And GUICtrlGetHandle($iParam) = 0 Then
GUICtrlDelete($iParam)
EndIf
Next
If _GUICtrlListView_GetItemCount($hWnd) = 0 Then Return True
EndIf
Return _SendMessage($hWnd, $LVM_DELETEALLITEMS) <> 0
EndFunc
Func _GUICtrlListView_EnableGroupView($hWnd, $bEnable = True)
If IsHWnd($hWnd) Then
Return _SendMessage($hWnd, $LVM_ENABLEGROUPVIEW, $bEnable)
Else
Return GUICtrlSendMsg($hWnd, $LVM_ENABLEGROUPVIEW, $bEnable, 0)
EndIf
EndFunc
Func _GUICtrlListView_EndUpdate($hWnd)
If IsHWnd($hWnd) Then
Return _SendMessage($hWnd, $__LISTVIEWCONSTANT_WM_SETREDRAW, True) = 0
Else
Return GUICtrlSendMsg($hWnd, $__LISTVIEWCONSTANT_WM_SETREDRAW, True, 0) = 0
EndIf
EndFunc
Func _GUICtrlListView_GetColumnCount($hWnd)
Return _SendMessage(_GUICtrlListView_GetHeader($hWnd), 0x1200)
EndFunc
Func __GUICtrlListView_GetGroupInfoEx($hWnd, $iGroupID, $iMask)
Local $tGroup = DllStructCreate($tagLVGROUP)
Local $iGroup = DllStructGetSize($tGroup)
DllStructSetData($tGroup, "Size", $iGroup)
DllStructSetData($tGroup, "Mask", $iMask)
Local $iRet = __GUICtrl_SendMsg($hWnd, $LVM_GETGROUPINFO, $iGroupID, $tGroup, 0, True, -1)
Return SetError($iRet <> $iGroupID, 0, $tGroup)
EndFunc
Func _GUICtrlListView_GetHeader($hWnd)
If IsHWnd($hWnd) Then
Return HWnd(_SendMessage($hWnd, $LVM_GETHEADER))
Else
Return HWnd(GUICtrlSendMsg($hWnd, $LVM_GETHEADER, 0, 0))
EndIf
EndFunc
Func _GUICtrlListView_GetItemCount($hWnd)
If IsHWnd($hWnd) Then
Return _SendMessage($hWnd, $LVM_GETITEMCOUNT)
Else
Return GUICtrlSendMsg($hWnd, $LVM_GETITEMCOUNT, 0, 0)
EndIf
EndFunc
Func _GUICtrlListView_GetItemEx($hWnd, ByRef $tItem)
Local $iMsg
If _GUICtrlListView_GetUnicodeFormat($hWnd) Then
$iMsg = $LVM_GETITEMW
Else
$iMsg = $LVM_GETITEMA
EndIf
Local $iRet = __GUICtrl_SendMsg($hWnd, $iMsg, 0, $tItem, 0, True, -1)
Return $iRet <> 0
EndFunc
Func _GUICtrlListView_GetItemParam($hWnd, $iIndex)
Local $tItem = $__g_tListViewItem
DllStructSetData($tItem, "Mask", $LVIF_PARAM)
DllStructSetData($tItem, "Item", $iIndex)
DllStructSetData($tItem, "SubItem", 0)
_GUICtrlListView_GetItemEx($hWnd, $tItem)
Return DllStructGetData($tItem, "Param")
EndFunc
Func _GUICtrlListView_GetSelectedCount($hWnd)
If IsHWnd($hWnd) Then
Return _SendMessage($hWnd, $LVM_GETSELECTEDCOUNT)
Else
Return GUICtrlSendMsg($hWnd, $LVM_GETSELECTEDCOUNT, 0, 0)
EndIf
EndFunc
Func _GUICtrlListView_GetSelectedIndices($hWnd, $bArray = False)
Local $sIndices, $aIndices[1] = [0]
Local $iSelectedCount = _GUICtrlListView_GetSelectedCount($hWnd)
If $iSelectedCount Then
Local $iSelected, $iStart = -1
For $i = 1 To $iSelectedCount
If IsHWnd($hWnd) Then
$iSelected = _SendMessage($hWnd, $LVM_GETNEXTITEM, $iStart, $LVNI_SELECTED)
Else
$iSelected = GUICtrlSendMsg($hWnd, $LVM_GETNEXTITEM, $iStart, $LVNI_SELECTED)
EndIf
If(Not $bArray) Then
If StringLen($sIndices) Then
$sIndices &= "|" & $iSelected
Else
$sIndices = $iSelected
EndIf
Else
ReDim $aIndices[UBound($aIndices) + 1]
$aIndices[0] = UBound($aIndices) - 1
$aIndices[UBound($aIndices) - 1] = $iSelected
EndIf
$iStart = $iSelected
Next
EndIf
If(Not $bArray) Then
Return String($sIndices)
Else
Return $aIndices
EndIf
EndFunc
Func _GUICtrlListView_GetUnicodeFormat($hWnd)
If Not IsDllStruct($__g_tListViewBuffer) Then
$__g_tListViewBuffer = DllStructCreate("wchar Text[4096]")
$__g_tListViewBufferANSI = DllStructCreate("char Text[4096]", DllStructGetPtr($__g_tListViewBuffer))
EndIf
If IsHWnd($hWnd) Then
Return _SendMessage($hWnd, $LVM_GETUNICODEFORMAT) <> 0
Else
Return GUICtrlSendMsg($hWnd, $LVM_GETUNICODEFORMAT, 0, 0) <> 0
EndIf
EndFunc
Func _GUICtrlListView_InsertGroup($hWnd, $iIndex, $iGroupID, $sHeader, $iAlign = 0)
Local $aAlign[3] = [$LVGA_HEADER_LEFT, $LVGA_HEADER_CENTER, $LVGA_HEADER_RIGHT]
If $iAlign < 0 Or $iAlign > 2 Then $iAlign = 0
Local $tHeader = _WinAPI_MultiByteToWideChar($sHeader)
Local $tGroup = DllStructCreate($tagLVGROUP)
Local $iMask = BitOR($LVGF_HEADER, $LVGF_ALIGN, $LVGF_GROUPID)
DllStructSetData($tGroup, "Size", DllStructGetSize($tGroup))
DllStructSetData($tGroup, "Mask", $iMask)
DllStructSetData($tGroup, "GroupID", $iGroupID)
DllStructSetData($tGroup, "Align", $aAlign[$iAlign])
Local $iRet = __GUICtrl_SendMsg($hWnd, $LVM_INSERTGROUP, $iIndex, $tGroup, $tHeader, False, 3)
Return $iRet
EndFunc
Func _GUICtrlListView_InsertItem($hWnd, $sText, $iIndex = -1, $iImage = -1, $iParam = 0)
Local $tBuffer, $iMsg
If _GUICtrlListView_GetUnicodeFormat($hWnd) Then
$tBuffer = $__g_tListViewBuffer
$iMsg = $LVM_INSERTITEMW
Else
$tBuffer = $__g_tListViewBufferANSI
$iMsg = $LVM_INSERTITEMA
EndIf
Local $tItem = $__g_tListViewItem
If $iIndex = -1 Then $iIndex = 999999999
DllStructSetData($tBuffer, 1, $sText)
Local $iMask = BitOR($LVIF_TEXT, $LVIF_PARAM)
If $iImage >= 0 Then $iMask = BitOR($iMask, $LVIF_IMAGE)
DllStructSetData($tItem, "Mask", $iMask)
DllStructSetData($tItem, "Item", $iIndex)
DllStructSetData($tItem, "SubItem", 0)
DllStructSetData($tItem, "Image", $iImage)
DllStructSetData($tItem, "Param", $iParam)
Local $iRet = __GUICtrl_SendMsg($hWnd, $iMsg, 0, $tItem, $tBuffer, False, 6)
Return $iRet
EndFunc
Func _GUICtrlListView_SetColumnWidth($hWnd, $iCol, $iWidth)
If IsHWnd($hWnd) Then
Return _SendMessage($hWnd, $LVM_SETCOLUMNWIDTH, $iCol, $iWidth)
Else
Return GUICtrlSendMsg($hWnd, $LVM_SETCOLUMNWIDTH, $iCol, $iWidth)
EndIf
EndFunc
Func _GUICtrlListView_SetGroupInfo($hWnd, $iGroupID, $sHeader, $iAlign = 0, $iState = $LVGS_NORMAL)
Local $tGroup = 0
If BitAND($iState, $LVGS_SELECTED) Then
$tGroup = __GUICtrlListView_GetGroupInfoEx($hWnd, $iGroupID, BitOR($LVGF_GROUPID, $LVGF_ITEMS))
If @error Or DllStructGetData($tGroup, "cItems") = 0 Then Return False
EndIf
Local $aAlign[3] = [$LVGA_HEADER_LEFT, $LVGA_HEADER_CENTER, $LVGA_HEADER_RIGHT]
If $iAlign < 0 Or $iAlign > 2 Then $iAlign = 0
Local $tHeader = _WinAPI_MultiByteToWideChar($sHeader)
$tGroup = DllStructCreate($tagLVGROUP)
Local $iMask = BitOR($LVGF_HEADER, $LVGF_ALIGN, $LVGF_STATE)
DllStructSetData($tGroup, "Size", DllStructGetSize($tGroup))
DllStructSetData($tGroup, "Mask", $iMask)
DllStructSetData($tGroup, "Align", $aAlign[$iAlign])
DllStructSetData($tGroup, "State", $iState)
DllStructSetData($tGroup, "StateMask", $iState)
Local $iRet = __GUICtrl_SendMsg($hWnd, $LVM_SETGROUPINFO, $iGroupID, $tGroup, $tHeader, False, 3)
DllStructSetData($tGroup, "Mask", $LVGF_GROUPID)
DllStructSetData($tGroup, "GroupID", $iGroupID)
__GUICtrl_SendMsg($hWnd, $LVM_SETGROUPINFO, 0, $tGroup, 0, False, -1)
_WinAPI_InvalidateRect($hWnd)
Return $iRet <> 0
EndFunc
Func _GUICtrlListView_SetImageList($hWnd, $hHandle, $iType = 0)
$iType = Int($iType)
If $iType < 0 Or $iType > 2 Then
$iType = 0
EndIf
Local $aType[3] = [$LVSIL_NORMAL, $LVSIL_SMALL, $LVSIL_STATE]
If IsHWnd($hWnd) Then
Return _SendMessage($hWnd, $LVM_SETIMAGELIST, $aType[$iType], $hHandle, 0, "wparam", "handle", "handle")
Else
Return Ptr(GUICtrlSendMsg($hWnd, $LVM_SETIMAGELIST, $aType[$iType], $hHandle))
EndIf
EndFunc
Func _GUICtrlListView_SetItemEx($hWnd, ByRef $tItem, $iNested = 0)
Local $tBuffer, $iMsg
If _GUICtrlListView_GetUnicodeFormat($hWnd) Then
$tBuffer = $__g_tListViewBuffer
$iMsg = $LVM_SETITEMW
Else
$tBuffer = $__g_tListViewBufferANSI
$iMsg = $LVM_SETITEMA
EndIf
Local $iBuffer = 0
If $iNested Then
$tBuffer = 0
DllStructSetData($tItem, "Text", 0)
Else
If DllStructGetData($tItem, "Text") <> -1 Then
$iBuffer = DllStructGetSize($tBuffer)
Else
EndIf
EndIf
DllStructSetData($tItem, "TextMax", $iBuffer)
Local $iRet = __GUICtrl_SendMsg($hWnd, $iMsg, 0, $tItem, $tBuffer, False, -1)
Return $iRet <> 0
EndFunc
Func _GUICtrlListView_SetItemGroupID($hWnd, $iIndex, $iGroupID)
Local $tItem = $__g_tListViewItem
DllStructSetData($tItem, "Mask", $LVIF_GROUPID)
DllStructSetData($tItem, "Item", $iIndex)
DllStructSetData($tItem, "SubItem", 0)
DllStructSetData($tItem, "GroupID", $iGroupID)
Return _GUICtrlListView_SetItemEx($hWnd, $tItem, 1)
EndFunc
Func _GUICtrlListView_SetItemImage($hWnd, $iIndex, $iImage, $iSubItem = 0)
Local $tItem = $__g_tListViewItem
DllStructSetData($tItem, "Mask", $LVIF_IMAGE)
DllStructSetData($tItem, "Item", $iIndex)
DllStructSetData($tItem, "SubItem", $iSubItem)
DllStructSetData($tItem, "Image", $iImage)
Return _GUICtrlListView_SetItemEx($hWnd, $tItem, 1)
EndFunc
Func _GUICtrlListView_SetItemText($hWnd, $iIndex, $sText, $iSubItem = 0)
Local $iRet
If $iSubItem = -1 Then
Local $sSeparatorChar = Opt('GUIDataSeparatorChar')
Local $i_Cols = _GUICtrlListView_GetColumnCount($hWnd)
Local $a_Text = StringSplit($sText, $sSeparatorChar)
If $i_Cols > $a_Text[0] Then $i_Cols = $a_Text[0]
For $i = 1 To $i_Cols
$iRet = _GUICtrlListView_SetItemText($hWnd, $iIndex, $a_Text[$i], $i - 1)
If Not $iRet Then ExitLoop
Next
Return $iRet
EndIf
Local $tBuffer, $iMsg
If _GUICtrlListView_GetUnicodeFormat($hWnd) Then
$tBuffer = $__g_tListViewBuffer
$iMsg = $LVM_SETITEMW
Else
$tBuffer = $__g_tListViewBufferANSI
$iMsg = $LVM_SETITEMA
EndIf
Local $tItem = $__g_tListViewItem
DllStructSetData($tBuffer, 1, $sText)
DllStructSetData($tItem, "Mask", $LVIF_TEXT)
DllStructSetData($tItem, "Item", $iIndex)
DllStructSetData($tItem, "SubItem", $iSubItem)
$iRet = __GUICtrl_SendMsg($hWnd, $iMsg, 0, $tItem, $tBuffer, False, 6, False, -1)
Return $iRet <> 0
EndFunc
#Au3Stripper_Ignore_Funcs=__GUICtrlListView_Sort
Func __GUICtrlListView_Sort($nItem1, $nItem2, $hWnd)
Local $iIndex, $sVal1, $sVal2, $nResult
Local $tBuffer, $iMsg
If $__g_aListViewSortInfo[$iIndex][0] Then
$tBuffer = $__g_tListViewBuffer
$iMsg = $LVM_GETITEMTEXTW
Else
$tBuffer = $__g_tListViewBufferANSI
$iMsg = $LVM_GETITEMTEXTA
EndIf
Local $tItem = $__g_tListViewItem
For $x = 1 To $__g_aListViewSortInfo[0][0]
If $hWnd = $__g_aListViewSortInfo[$x][1] Then
$iIndex = $x
ExitLoop
EndIf
Next
If $__g_aListViewSortInfo[$iIndex][3] = $__g_aListViewSortInfo[$iIndex][4] Then
If Not $__g_aListViewSortInfo[$iIndex][7] Then
$__g_aListViewSortInfo[$iIndex][5] *= -1
$__g_aListViewSortInfo[$iIndex][7] = 1
EndIf
Else
$__g_aListViewSortInfo[$iIndex][7] = 1
EndIf
$__g_aListViewSortInfo[$iIndex][6] = $__g_aListViewSortInfo[$iIndex][3]
DllStructSetData($tItem, "Mask", $LVIF_TEXT)
DllStructSetData($tItem, "SubItem", $__g_aListViewSortInfo[$iIndex][3])
__GUICtrl_SendMsg($hWnd, $iMsg, $nItem1, $tItem, $tBuffer, False, 6, True)
$sVal1 = DllStructGetData($tBuffer, 1)
__GUICtrl_SendMsg($hWnd, $iMsg, $nItem2, $tItem, $tBuffer, False, 6, True)
$sVal2 = DllStructGetData($tBuffer, 1)
If $__g_aListViewSortInfo[$iIndex][8] = 1 Then
If(StringIsFloat($sVal1) Or StringIsInt($sVal1)) Then $sVal1 = Number($sVal1)
If(StringIsFloat($sVal2) Or StringIsInt($sVal2)) Then $sVal2 = Number($sVal2)
EndIf
If $__g_aListViewSortInfo[$iIndex][8] < 2 Then
$nResult = 0
If $sVal1 < $sVal2 Then
$nResult = -1
ElseIf $sVal1 > $sVal2 Then
$nResult = 1
EndIf
Else
$nResult = DllCall('shlwapi.dll', 'int', 'StrCmpLogicalW', 'wstr', $sVal1, 'wstr', $sVal2)[0]
EndIf
$nResult = $nResult * $__g_aListViewSortInfo[$iIndex][5]
Return $nResult
EndFunc
Global Const $TVS_DISABLEDRAGDROP = 0x00000010
Global Const $TVS_SHOWSELALWAYS = 0x00000020
Global Const $TVS_FULLROWSELECT = 0x00001000
Global Const $TVE_COLLAPSE = 0x0001
Global Const $TVE_EXPAND = 0x0002
Global Const $TVGN_ROOT = 0x00000000
Global Const $TVGN_NEXT = 0x00000001
Global Const $TVGN_PREVIOUS = 0x00000002
Global Const $TVGN_PARENT = 0x00000003
Global Const $TVGN_CHILD = 0x00000004
Global Const $TVGN_FIRSTVISIBLE = 0x00000005
Global Const $TVGN_CARET = 0x00000009
Global Const $TVHT_ONITEMRIGHT = 0x00000020
Global Const $TVHT_ONITEM = 0x00000046
Global Const $TVI_ROOT = 0xFFFF0000
Global Const $TVI_FIRST = 0xFFFF0001
Global Const $TVI_LAST = 0xFFFF0002
Global Const $TVIF_TEXT = 0x00000001
Global Const $TVIF_IMAGE = 0x00000002
Global Const $TVIF_PARAM = 0x00000004
Global Const $TVIF_STATE = 0x00000008
Global Const $TVIF_HANDLE = 0x00000010
Global Const $TVIF_SELECTEDIMAGE = 0x00000020
Global Const $TVIS_STATEIMAGEMASK = 0x0000F000
Global Const $TVNA_ADD = 1
Global Const $TVNA_ADDFIRST = 2
Global Const $TVNA_ADDCHILD = 3
Global Const $TVNA_ADDCHILDFIRST = 4
Global Const $TVTA_ADDFIRST = 1
Global Const $TVTA_ADD = 2
Global Const $TVTA_INSERT = 3
Global Const $TV_FIRST = 0x1100
Global Const $TVM_INSERTITEMA = $TV_FIRST + 0
Global Const $TVM_DELETEITEM = $TV_FIRST + 1
Global Const $TVM_EXPAND = $TV_FIRST + 2
Global Const $TVM_GETCOUNT = $TV_FIRST + 5
Global Const $TVM_GETIMAGELIST = $TV_FIRST + 8
Global Const $TVM_SETIMAGELIST = $TV_FIRST + 9
Global Const $TVM_GETNEXTITEM = $TV_FIRST + 10
Global Const $TVM_SELECTITEM = $TV_FIRST + 11
Global Const $TVM_GETITEMA = $TV_FIRST + 12
Global Const $TVM_SETITEMA = $TV_FIRST + 13
Global Const $TVM_HITTEST = $TV_FIRST + 17
Global Const $TVM_ENSUREVISIBLE = $TV_FIRST + 20
Global Const $TVM_INSERTITEMW = $TV_FIRST + 50
Global Const $TVM_GETITEMW = $TV_FIRST + 62
Global Const $TVM_SETITEMW = $TV_FIRST + 63
Global Const $TVM_GETUNICODEFORMAT = 0x2000 + 6
Global Const $TVN_FIRST = -400
Global Const $TVN_SELCHANGEDA = $TVN_FIRST - 2
Global Const $TVN_SELCHANGEDW = $TVN_FIRST - 51
Global $__g_tTVBuffer, $__g_tTVBufferANSI
Global $__g_tTVItemEx = DllStructCreate($tagTVITEMEX)
Global Const $__TREEVIEWCONSTANT_WM_SETREDRAW = 0x000B
Global Const $tagTVINSERTSTRUCT = "struct; handle Parent;handle InsertAfter;" & $tagTVITEMEX & " ;endstruct"
Func _GUICtrlTreeView_Add($hWnd, $hSibling, $sText, $iImage = -1, $iSelImage = -1)
Return __GUICtrlTreeView_AddItem($hWnd, $hSibling, $sText, $TVNA_ADD, $iImage, $iSelImage)
EndFunc
Func _GUICtrlTreeView_AddChild($hWnd, $hParent, $sText, $iImage = -1, $iSelImage = -1)
Return __GUICtrlTreeView_AddItem($hWnd, $hParent, $sText, $TVNA_ADDCHILD, $iImage, $iSelImage)
EndFunc
Func __GUICtrlTreeView_AddItem($hWnd, $hRelative, $sText, $iMethod, $iImage = -1, $iSelImage = -1, $iParam = 0)
Local $iAddMode
Switch $iMethod
Case $TVNA_ADD, $TVNA_ADDCHILD
$iAddMode = $TVTA_ADD
Case $TVNA_ADDFIRST, $TVNA_ADDCHILDFIRST
$iAddMode = $TVTA_ADDFIRST
Case Else
$iAddMode = $TVTA_INSERT
EndSwitch
Local $hItem, $hItemID = 0
If $hRelative <> 0x00000000 Then
Switch $iMethod
Case $TVNA_ADD, $TVNA_ADDFIRST
$hItem = _GUICtrlTreeView_GetParentHandle($hWnd, $hRelative)
Case $TVNA_ADDCHILD, $TVNA_ADDCHILDFIRST
$hItem = $hRelative
Case Else
$hItem = _GUICtrlTreeView_GetParentHandle($hWnd, $hRelative)
$hItemID = _GUICtrlTreeView_GetPrevSibling($hWnd, $hRelative)
If $hItemID = 0x00000000 Then $iAddMode = $TVTA_ADDFIRST
EndSwitch
EndIf
Local $tBuffer, $iMsg
If _GUICtrlTreeView_GetUnicodeFormat($hWnd) Then
$tBuffer = $__g_tTVBuffer
$iMsg = $TVM_INSERTITEMW
Else
$tBuffer = $__g_tTVBufferANSI
$iMsg = $TVM_INSERTITEMA
EndIf
Local $tInsert = DllStructCreate($tagTVINSERTSTRUCT)
Switch $iAddMode
Case $TVTA_ADDFIRST
DllStructSetData($tInsert, "InsertAfter", $TVI_FIRST)
Case $TVTA_ADD
DllStructSetData($tInsert, "InsertAfter", $TVI_LAST)
Case $TVTA_INSERT
DllStructSetData($tInsert, "InsertAfter", $hItemID)
EndSwitch
Local $iMask = BitOR($TVIF_TEXT, $TVIF_PARAM)
If $iImage >= 0 Then $iMask = BitOR($iMask, $TVIF_IMAGE)
If $iSelImage >= 0 Then $iMask = BitOR($iMask, $TVIF_SELECTEDIMAGE)
DllStructSetData($tBuffer, "Text", $sText)
DllStructSetData($tInsert, "Parent", $hItem)
DllStructSetData($tInsert, "Mask", $iMask)
DllStructSetData($tInsert, "Image", $iImage)
DllStructSetData($tInsert, "SelectedImage", $iSelImage)
DllStructSetData($tInsert, "Param", $iParam)
Local $hResult = Ptr(__GUICtrl_SendMsg($hWnd, $iMsg, 0, $tInsert, $tBuffer, False, 7))
Return $hResult
EndFunc
Func _GUICtrlTreeView_BeginUpdate($hWnd)
If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)
Return _SendMessage($hWnd, $__TREEVIEWCONSTANT_WM_SETREDRAW, False) = 0
EndFunc
Func _GUICtrlTreeView_DeleteAll($hWnd)
Local $iCount = 0
If IsHWnd($hWnd) Then
_SendMessage($hWnd, $TVM_DELETEITEM, 0, $TVI_ROOT)
$iCount = _GUICtrlTreeView_GetCount($hWnd)
If $iCount Then Return GUICtrlSendMsg($hWnd, $TVM_DELETEITEM, 0, $TVI_ROOT) <> 0
Return True
Else
GUICtrlSendMsg($hWnd, $TVM_DELETEITEM, 0, $TVI_ROOT)
$iCount = _GUICtrlTreeView_GetCount($hWnd)
If $iCount Then Return _SendMessage($hWnd, $TVM_DELETEITEM, 0, $TVI_ROOT) <> 0
Return True
EndIf
EndFunc
Func _GUICtrlTreeView_EndUpdate($hWnd)
If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)
Return _SendMessage($hWnd, $__TREEVIEWCONSTANT_WM_SETREDRAW, True) = 0
EndFunc
Func _GUICtrlTreeView_Expand($hWnd, $hItem = Null, $bExpand = True)
If $hItem = Null Then
$hItem = $TVI_ROOT
Else
If Not IsHWnd($hItem) Then
Local $hItem_tmp = GUICtrlGetHandle($hItem)
If $hItem_tmp Then $hItem = $hItem_tmp
EndIf
EndIf
If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)
If $bExpand Then
__GUICtrlTreeView_ExpandItem($hWnd, $TVE_EXPAND, $hItem)
Else
__GUICtrlTreeView_ExpandItem($hWnd, $TVE_COLLAPSE, $hItem)
EndIf
EndFunc
Func __GUICtrlTreeView_ExpandItem($hWnd, $iExpand, $hItem)
If Not IsHWnd($hWnd) Then
If $hItem = 0x00000000 Then
$hItem = $TVI_ROOT
Else
$hItem = GUICtrlGetHandle($hItem)
If $hItem = 0 Then Return
EndIf
$hWnd = GUICtrlGetHandle($hWnd)
EndIf
_SendMessage($hWnd, $TVM_EXPAND, $iExpand, $hItem, 0, "wparam", "handle")
If $iExpand = $TVE_EXPAND And $hItem > 0 Then _SendMessage($hWnd, $TVM_ENSUREVISIBLE, 0, $hItem, 0, "wparam", "handle")
$hItem = _SendMessage($hWnd, $TVM_GETNEXTITEM, $TVGN_CHILD, $hItem, 0, "wparam", "handle", "handle")
Local $hChild
While $hItem <> 0x00000000
$hChild = _SendMessage($hWnd, $TVM_GETNEXTITEM, $TVGN_CHILD, $hItem, 0, "wparam", "handle", "handle")
If $hChild <> 0x00000000 Then __GUICtrlTreeView_ExpandItem($hWnd, $iExpand, $hItem)
$hItem = _SendMessage($hWnd, $TVM_GETNEXTITEM, $TVGN_NEXT, $hItem, 0, "wparam", "handle", "handle")
WEnd
EndFunc
Func _GUICtrlTreeView_GetCount($hWnd)
If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)
Return _SendMessage($hWnd, $TVM_GETCOUNT)
EndFunc
Func _GUICtrlTreeView_GetImageIndex($hWnd, $hItem)
If Not IsHWnd($hItem) Then $hItem = _GUICtrlTreeView_GetItemHandle($hWnd, $hItem)
Local $tItem = $__g_tTVItemEx
DllStructSetData($tItem, "Mask", $TVIF_IMAGE)
DllStructSetData($tItem, "hItem", $hItem)
__GUICtrlTreeView_GetItem($hWnd, $tItem)
Return DllStructGetData($tItem, "Image")
EndFunc
Func __GUICtrlTreeView_GetItem($hWnd, ByRef $tItem)
Local $iMsg
If _GUICtrlTreeView_GetUnicodeFormat($hWnd) Then
$iMsg = $TVM_GETITEMW
Else
$iMsg = $TVM_GETITEMA
EndIf
Local $iRet = __GUICtrl_SendMsg($hWnd, $iMsg, 0, $tItem, 0, True)
Return $iRet <> 0
EndFunc
Func _GUICtrlTreeView_GetItemHandle($hWnd, $hItem = Null)
If IsHWnd($hWnd) Then
If $hItem = Null Then $hItem = _SendMessage($hWnd, $TVM_GETNEXTITEM, $TVGN_ROOT, 0, 0, "wparam", "lparam", "handle")
Else
If $hItem = Null Then
$hItem = Ptr(GUICtrlSendMsg($hWnd, $TVM_GETNEXTITEM, $TVGN_ROOT, 0))
Else
Local $hTempItem = GUICtrlGetHandle($hItem)
If $hTempItem And Not IsPtr($hItem) Then
$hItem = $hTempItem
Else
SetExtended(1)
EndIf
EndIf
EndIf
Return $hItem
EndFunc
Func _GUICtrlTreeView_GetParentHandle($hWnd, $hItem = Null)
If $hItem = Null Then
If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)
$hItem = _SendMessage($hWnd, $TVM_GETNEXTITEM, $TVGN_CARET, 0, 0, "wparam", "handle", "handle")
If $hItem = 0x00000000 Then Return 0
Else
If Not IsHWnd($hItem) Then $hItem = _GUICtrlTreeView_GetItemHandle($hWnd, $hItem)
If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)
EndIf
Local $hParent = _SendMessage($hWnd, $TVM_GETNEXTITEM, $TVGN_PARENT, $hItem, 0, "wparam", "handle", "handle")
Return $hParent
EndFunc
Func _GUICtrlTreeView_GetPrevSibling($hWnd, $hItem)
If Not IsHWnd($hItem) Then $hItem = _GUICtrlTreeView_GetItemHandle($hWnd, $hItem)
If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)
Return _SendMessage($hWnd, $TVM_GETNEXTITEM, $TVGN_PREVIOUS, $hItem, 0, "wparam", "handle", "handle")
EndFunc
Func _GUICtrlTreeView_GetSelectedImageIndex($hWnd, $hItem)
If Not IsHWnd($hItem) Then $hItem = _GUICtrlTreeView_GetItemHandle($hWnd, $hItem)
Local $tItem = $__g_tTVItemEx
DllStructSetData($tItem, "Mask", $TVIF_SELECTEDIMAGE)
DllStructSetData($tItem, "hItem", $hItem)
__GUICtrlTreeView_GetItem($hWnd, $tItem)
Return DllStructGetData($tItem, "SelectedImage")
EndFunc
Func _GUICtrlTreeView_GetSelection($hWnd)
If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)
Return _SendMessage($hWnd, $TVM_GETNEXTITEM, $TVGN_CARET, 0, 0, "wparam", "handle", "handle")
EndFunc
Func _GUICtrlTreeView_GetStateImageIndex($hWnd, $hItem)
If Not IsHWnd($hItem) Then $hItem = _GUICtrlTreeView_GetItemHandle($hWnd, $hItem)
Local $tItem = $__g_tTVItemEx
DllStructSetData($tItem, "Mask", $TVIF_STATE)
DllStructSetData($tItem, "hItem", $hItem)
__GUICtrlTreeView_GetItem($hWnd, $tItem)
Return BitShift(BitAND(DllStructGetData($tItem, "State"), $TVIS_STATEIMAGEMASK), 12)
EndFunc
Func _GUICtrlTreeView_GetText($hWnd, $hItem = Null)
If Not IsHWnd($hItem) Then $hItem = _GUICtrlTreeView_GetItemHandle($hWnd, $hItem)
Local $tItem = $__g_tTVItemEx
Local $tText, $iMsg
Local $bUnicode = _GUICtrlTreeView_GetUnicodeFormat($hWnd)
If $bUnicode Then
$tText = $__g_tTVBuffer
$iMsg = $TVM_GETITEMW
Else
$tText = $__g_tTVBufferANSI
$iMsg = $TVM_GETITEMA
EndIf
DllStructSetData($tText, 1, "")
DllStructSetData($tItem, "Mask", $TVIF_TEXT)
DllStructSetData($tItem, "hItem", $hItem)
__GUICtrl_SendMsg($hWnd, $iMsg, 0, $tItem, $tText, False, 5, True)
Return DllStructGetData($tText, 1)
EndFunc
Func _GUICtrlTreeView_GetUnicodeFormat($hWnd)
If Not IsDllStruct($__g_tTVBuffer) Then
$__g_tTVBuffer = DllStructCreate("wchar Text[4096]")
$__g_tTVBufferANSI = DllStructCreate("char Text[4096]", DllStructGetPtr($__g_tTVBuffer))
EndIf
If IsHWnd($hWnd) Then
Return _SendMessage($hWnd, $TVM_GETUNICODEFORMAT) <> 0
Else
Return GUICtrlSendMsg($hWnd, $TVM_GETUNICODEFORMAT, 0, 0) <> 0
EndIf
EndFunc
Func _GUICtrlTreeView_HitTestEx($hWnd, $iX, $iY)
Local $tHitTest = DllStructCreate($tagTVHITTESTINFO)
DllStructSetData($tHitTest, "X", $iX)
DllStructSetData($tHitTest, "Y", $iY)
__GUICtrl_SendMsg($hWnd, $TVM_HITTEST, 0, $tHitTest, 0, True)
Return $tHitTest
EndFunc
Func _GUICtrlTreeView_SelectItem($hWnd, $hItem, $iFlag = 0)
If Not IsHWnd($hItem) And $hItem <> 0 Then $hItem = _GUICtrlTreeView_GetItemHandle($hWnd, $hItem)
If $iFlag = 0 Then $iFlag = $TVGN_CARET
If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)
Return _SendMessage($hWnd, $TVM_SELECTITEM, $iFlag, $hItem, 0, "wparam", "handle") <> 0
EndFunc
Func _GUICtrlTreeView_SetIcon($hWnd, $hItem = Null, $sIconFile = "", $iIconID = 0, $iImageMode = 6)
If Not IsHWnd($hItem) Then $hItem = _GUICtrlTreeView_GetItemHandle($hWnd, $hItem)
If @error Or $sIconFile = "" Then Return SetError(@error + 10, 0, False)
Local $tTVITEM = $__g_tTVItemEx
Local $tIcon = DllStructCreate("handle")
Local $aCount = DllCall("shell32.dll", "uint", "ExtractIconExW", "wstr", $sIconFile, "int", $iIconID, "handle", 0, "struct*", $tIcon, "uint", 1)
If @error Then Return SetError(@error + 20, @extended, False)
If $aCount[0] = 0 Then Return False
If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)
Local $hImageList = _SendMessage($hWnd, $TVM_GETIMAGELIST, 0, 0, 0, "wparam", "lparam", "handle")
If $hImageList = 0x00000000 Then
$hImageList = DllCall("comctl32.dll", "handle", "ImageList_Create", "int", 16, "int", 16, "uint", 0x0021, "int", 0, "int", 1)
If @error Then Return SetError(@error + 30, @extended, False)
$hImageList = $hImageList[0]
If $hImageList = 0 Then Return SetError(2, 0, False)
_SendMessage($hWnd, $TVM_SETIMAGELIST, 0, $hImageList, 0, "wparam", "handle")
EndIf
Local $hIcon = DllStructGetData($tIcon, 1)
Local $vIcon = DllCall("comctl32.dll", "int", "ImageList_AddIcon", "handle", $hImageList, "handle", $hIcon)
$vIcon = $vIcon[0]
If @error Then
Local $iError = @error + 40, $iExtended = @extended
DllCall("user32.dll", "int", "DestroyIcon", "handle", $hIcon)
Return SetError($iError, $iExtended, False)
EndIf
DllCall("user32.dll", "int", "DestroyIcon", "handle", $hIcon)
Local $iMask = BitOR($TVIF_IMAGE, $TVIF_SELECTEDIMAGE)
If BitAND($iImageMode, 2) Then
DllStructSetData($tTVITEM, "Image", $vIcon)
If Not BitAND($iImageMode, 4) Then $iMask = $TVIF_IMAGE
EndIf
If BitAND($iImageMode, 4) Then
DllStructSetData($tTVITEM, "SelectedImage", $vIcon)
If Not BitAND($iImageMode, 2) Then
$iMask = $TVIF_SELECTEDIMAGE
Else
$iMask = BitOR($TVIF_IMAGE, $TVIF_SELECTEDIMAGE)
EndIf
EndIf
DllStructSetData($tTVITEM, "Mask", $iMask)
DllStructSetData($tTVITEM, "hItem", $hItem)
Return __GUICtrlTreeView_SetItem($hWnd, $tTVITEM)
EndFunc
Func _GUICtrlTreeView_SetImageIndex($hWnd, $hItem, $iIndex)
If Not IsHWnd($hItem) Then $hItem = _GUICtrlTreeView_GetItemHandle($hWnd, $hItem)
Local $tItem = $__g_tTVItemEx
DllStructSetData($tItem, "Mask", BitOR($TVIF_HANDLE, $TVIF_IMAGE))
DllStructSetData($tItem, "hItem", $hItem)
DllStructSetData($tItem, "Image", $iIndex)
Return __GUICtrlTreeView_SetItem($hWnd, $tItem)
EndFunc
Func __GUICtrlTreeView_SetItem($hWnd, ByRef $tItem)
Local $iMsg
If _GUICtrlTreeView_GetUnicodeFormat($hWnd) Then
$iMsg = $TVM_SETITEMW
Else
$iMsg = $TVM_SETITEMA
EndIf
Local $iRet = __GUICtrl_SendMsg($hWnd, $iMsg, 0, $tItem)
Return $iRet <> 0
EndFunc
Func _GUICtrlTreeView_SetSelectedImageIndex($hWnd, $hItem, $iIndex)
If Not IsHWnd($hItem) Then $hItem = _GUICtrlTreeView_GetItemHandle($hWnd, $hItem)
Local $tItem = $__g_tTVItemEx
DllStructSetData($tItem, "Mask", BitOR($TVIF_HANDLE, $TVIF_SELECTEDIMAGE))
DllStructSetData($tItem, "hItem", $hItem)
DllStructSetData($tItem, "SelectedImage", $iIndex)
Return __GUICtrlTreeView_SetItem($hWnd, $tItem)
EndFunc
Func _GUICtrlTreeView_SetStateImageIndex($hWnd, $hItem, $iIndex)
If Not IsHWnd($hItem) Then $hItem = _GUICtrlTreeView_GetItemHandle($hWnd, $hItem)
If $iIndex < 0 Then
Return SetError(1, 0, False)
EndIf
Local $tItem = $__g_tTVItemEx
DllStructSetData($tItem, "Mask", $TVIF_STATE)
DllStructSetData($tItem, "hItem", $hItem)
DllStructSetData($tItem, "State", BitShift($iIndex, -12))
DllStructSetData($tItem, "StateMask", $TVIS_STATEIMAGEMASK)
Return __GUICtrlTreeView_SetItem($hWnd, $tItem)
EndFunc
Func _GUICtrlTreeView_SetText($hWnd, $hItem = Null, $sText = "")
If Not IsHWnd($hItem) Then $hItem = _GUICtrlTreeView_GetItemHandle($hWnd, $hItem)
If @error Or $sText = "" Then Return SetError(@error + 10, 0, False)
Local $tItem = $__g_tTVItemEx
Local $tBuffer, $iMsg
If _GUICtrlTreeView_GetUnicodeFormat($hWnd) Then
$tBuffer = $__g_tTVBuffer
$iMsg = $TVM_SETITEMW
Else
$tBuffer = $__g_tTVBufferANSI
$iMsg = $TVM_SETITEMA
EndIf
DllStructSetData($tBuffer, "Text", $sText)
DllStructSetData($tItem, "Mask", BitOR($TVIF_HANDLE, $TVIF_TEXT))
DllStructSetData($tItem, "hItem", $hItem)
Local $bResult = __GUICtrl_SendMsg($hWnd, $iMsg, 0, $tItem, $tBuffer, False, 5)
Return $bResult <> 0
EndFunc
Func _Min($iNum1, $iNum2)
If Not IsNumber($iNum1) Then Return SetError(1, 0, 0)
If Not IsNumber($iNum2) Then Return SetError(2, 0, 0)
Return($iNum1 > $iNum2) ? $iNum2 : $iNum1
EndFunc
Func _Singleton($sOccurrenceName, $iFlag = 0)
Local Const $ERROR_ALREADY_EXISTS = 183
Local Const $SECURITY_DESCRIPTOR_REVISION = 1
Local $tSecurityAttributes = 0
If BitAND($iFlag, 2) Then
Local $tSecurityDescriptor = DllStructCreate("byte;byte;word;ptr[4]")
Local $aCall = DllCall("advapi32.dll", "bool", "InitializeSecurityDescriptor", "struct*", $tSecurityDescriptor, "dword", $SECURITY_DESCRIPTOR_REVISION)
If @error Then Return SetError(@error, @extended, 0)
If $aCall[0] Then
$aCall = DllCall("advapi32.dll", "bool", "SetSecurityDescriptorDacl", "struct*", $tSecurityDescriptor, "bool", 1, "ptr", 0, "bool", 0)
If @error Then Return SetError(@error, @extended, 0)
If $aCall[0] Then
$tSecurityAttributes = DllStructCreate($tagSECURITY_ATTRIBUTES)
DllStructSetData($tSecurityAttributes, 1, DllStructGetSize($tSecurityAttributes))
DllStructSetData($tSecurityAttributes, 2, DllStructGetPtr($tSecurityDescriptor))
DllStructSetData($tSecurityAttributes, 3, 0)
EndIf
EndIf
EndIf
Local $aHandle = DllCall("kernel32.dll", "handle", "CreateMutexW", "struct*", $tSecurityAttributes, "bool", 1, "wstr", $sOccurrenceName)
If @error Then Return SetError(@error, @extended, 0)
Local $aLastError = DllCall("kernel32.dll", "dword", "GetLastError")
If @error Then Return SetError(@error, @extended, 0)
If $aLastError[0] = $ERROR_ALREADY_EXISTS Then
If BitAND($iFlag, 1) Then
DllCall("kernel32.dll", "bool", "CloseHandle", "handle", $aHandle[0])
If @error Then Return SetError(@error, @extended, 0)
Return SetError($aLastError[0], $aLastError[0], 0)
Else
Exit -1
EndIf
EndIf
Return $aHandle[0]
EndFunc
Func _IsPressed($sHexKey, $vDLL = "user32.dll")
Local $aCall = DllCall($vDLL, "short", "GetAsyncKeyState", "int", "0x" & $sHexKey)
If @error Then Return SetError(@error, @extended, False)
Return BitAND($aCall[0], 0x8000) <> 0
EndFunc
Global Const $SS_BLACKFRAME = 0x7
Global Const $SS_CENTERIMAGE = 0x0200
Global Const $STM_SETIMAGE = 0x0172
Global Const $TCS_BUTTONS = 0x00000100
Global Const $TCS_FLATBUTTONS = 0x00000008
Global Const $TCS_FOCUSNEVER = 0x00008000
Global $__g_aTimers_aTimerIDs[1][3]
Func _Timer_KillAllTimers($hWnd)
Local $iNumTimers = $__g_aTimers_aTimerIDs[0][0]
If $iNumTimers = 0 Then Return False
Local $aCall, $hCallBack = 0
For $x = $iNumTimers To 1 Step -1
If IsHWnd($hWnd) Then
$aCall = DllCall("user32.dll", "bool", "KillTimer", "hwnd", $hWnd, "uint_ptr", $__g_aTimers_aTimerIDs[$x][1])
Else
$aCall = DllCall("user32.dll", "bool", "KillTimer", "hwnd", $hWnd, "uint_ptr", $__g_aTimers_aTimerIDs[$x][0])
EndIf
If @error Or Not $aCall[0] Then Return SetError(@error + 10, @extended, False)
$hCallBack = $__g_aTimers_aTimerIDs[$x][2]
If $hCallBack <> 0 Then DllCallbackFree($hCallBack)
$__g_aTimers_aTimerIDs[0][0] -= 1
Next
ReDim $__g_aTimers_aTimerIDs[1][3]
Return True
EndFunc
Func _Timer_SetTimer($hWnd, $iElapse = 250, $sTimerFunc = "", $iTimerID = -1)
#Au3Stripper_Ignore_Funcs=$sTimerFunc
Local $aCall[1] = [0], $pTimerFunc = 0, $hCallBack = 0, $iIndex = $__g_aTimers_aTimerIDs[0][0] + 1
If $iTimerID = -1 Then
ReDim $__g_aTimers_aTimerIDs[$iIndex + 1][3]
$__g_aTimers_aTimerIDs[0][0] = $iIndex
$iTimerID = $iIndex + 1000
For $x = 1 To $iIndex
If $__g_aTimers_aTimerIDs[$x][0] = $iTimerID Then
$iTimerID = $iTimerID + 1
$x = 0
EndIf
Next
If $sTimerFunc <> "" Then
$hCallBack = DllCallbackRegister($sTimerFunc, "none", "hwnd;uint;uint_ptr;dword")
If $hCallBack = 0 Then Return SetError(-1, -1, 0)
$pTimerFunc = DllCallbackGetPtr($hCallBack)
If $pTimerFunc = 0 Then Return SetError(-1, -2, 0)
EndIf
$aCall = DllCall("user32.dll", "uint_ptr", "SetTimer", "hwnd", $hWnd, "uint_ptr", $iTimerID, "uint", $iElapse, "ptr", $pTimerFunc)
If @error Or Not $aCall[0] Then Return SetError(@error + 10, @extended, 0)
$__g_aTimers_aTimerIDs[$iIndex][0] = $aCall[0]
$__g_aTimers_aTimerIDs[$iIndex][1] = $iTimerID
$__g_aTimers_aTimerIDs[$iIndex][2] = $hCallBack
Else
For $x = 1 To $iIndex - 1
If $__g_aTimers_aTimerIDs[$x][0] = $iTimerID Then
If IsHWnd($hWnd) Then $iTimerID = $__g_aTimers_aTimerIDs[$x][1]
$hCallBack = $__g_aTimers_aTimerIDs[$x][2]
If $hCallBack <> 0 Then
$pTimerFunc = DllCallbackGetPtr($hCallBack)
If $pTimerFunc = 0 Then Return SetError(-1, -12, 0)
EndIf
$aCall = DllCall("user32.dll", "uint_ptr", "SetTimer", "hwnd", $hWnd, "uint_ptr", $iTimerID, "uint", $iElapse, "ptr", $pTimerFunc)
If @error Or Not $aCall[0] Then Return SetError(@error + 20, @extended, 0)
ExitLoop
EndIf
Next
EndIf
Return $aCall[0]
EndFunc
Global Const $WS_MAXIMIZEBOX = 0x00010000
Global Const $WS_MINIMIZEBOX = 0x00020000
Global Const $WS_TABSTOP = 0x00010000
Global Const $WS_SIZEBOX = 0x00040000
Global Const $WS_SYSMENU = 0x00080000
Global Const $WS_VSCROLL = 0x00200000
Global Const $WS_CAPTION = 0x00C00000
Global Const $WS_POPUP = 0x80000000
Global Const $WS_EX_ACCEPTFILES = 0x00000010
Global Const $WS_EX_CLIENTEDGE = 0x00000200
Global Const $WM_SIZE = 0x0005
Global Const $WM_GETMINMAXINFO = 0x0024
Global Const $WM_NOTIFY = 0x004E
Global Const $WM_CONTEXTMENU = 0x007B
Global Const $WM_COMMAND = 0x0111
Global Const $WM_ENTERSIZEMOVE = 0x0231
Global Const $WM_EXITSIZEMOVE = 0x0232
Global Const $WM_DROPFILES = 0x0233
Global Const $NM_FIRST = 0
Global Const $NM_CLICK = $NM_FIRST - 2
Global Const $NM_DBLCLK = $NM_FIRST - 3
Global Const $NM_RETURN = $NM_FIRST - 4
Global Const $NM_RCLICK = $NM_FIRST - 5
Global Const $GUI_SS_DEFAULT_GUI = BitOR($WS_MINIMIZEBOX, $WS_CAPTION, $WS_POPUP, $WS_SYSMENU)
Global Const $SHCNE_ASSOCCHANGED = 0x8000000
Global Const $SHCNF_FLUSH = 0x00001000
Func _WinAPI_ShellChangeNotify($iEvent, $iFlags, $iItem1 = 0, $iItem2 = 0)
Local $sTypeOfItem1 = 'dword_ptr', $sTypeOfItem2 = 'dword_ptr'
If IsString($iItem1) Then
$sTypeOfItem1 = 'wstr'
EndIf
If IsString($iItem2) Then
$sTypeOfItem2 = 'wstr'
EndIf
DllCall('shell32.dll', 'none', 'SHChangeNotify', 'long', $iEvent, 'uint', $iFlags, $sTypeOfItem1, $iItem1, $sTypeOfItem2, $iItem2)
If @error Then Return SetError(@error, @extended, 0)
Return 1
EndFunc
Global Const $JSMN_UNESCAPED_UNICODE = 1
Global Const $JSMN_UNESCAPED_SLASHES = 2
Global Const $JSMN_PRETTY_PRINT = 128
Global Const $JSMN_STRICT_PRINT = 256
Global Const $JSMN_UNQUOTED_STRING = 512
Global $JSMN_ERROR_NOMEM = -1
Global $_Jsmn_CodeBuffer, $_Jsmn_CodeBufferPtr
Global $_Jsmn_InitPtr, $_Jsmn_ParsePtr, $_Jsmn_StringEncodePtr, $_Jsmn_StringDecodePtr
Global $_Jsmn_EmptyArray, $_Jsmn_TokenSize = DllStructGetSize(DllStructCreate("int type;int start;int end;int size;int parent"))
Func _Jsmn_Shutdown()
$_Jsmn_CodeBuffer = 0
_MemVirtualFree($_Jsmn_CodeBufferPtr, 0, $MEM_RELEASE)
EndFunc
Func _Jsmn_Startup()
If Not IsDllStruct($_Jsmn_CodeBuffer) Then
Local $Code
If @AutoItX64 Then
$Code = '0xFF01E940030000FF02EB0EFF03E9CE050000FF04E9A0030000564589C9534883EC08E9C90200006683F82C0F84BD02000077376683F80D0F84B1020000771283E8096683F8010F873F020000E99D0200006683F8200F84930200006683F8220F8526020000E9030100006683F85D0F849F00000077166683F83A0F846E0200006683F85B0F8501020000EB126683F87B740C6683F87D0F85EF010000EB7C8B59044C63D34D39CA0F83950200004D6BD214FFC38959044F8D141041C74208FFFFFFFF41C74204FFFFFFFF41C7420C0000000041C74210FFFFFFFF448B59084183FBFF74104963F345895A10486BF61441FF44300C6683F87B0F95C0FFCB0FB6C0FFC04189028B0141894204895908E9DB010000BB02000000EB05BB010000008B410485C00F8E0C020000489848FFC8486BC014498D0400837804FF7420837808FF751A39180F85EB01000041FFC2448950088B4010894108E9910100008B401083F8FF0F84850100004898EBC2418D42018901E99E0000006683F82275478B59044863C34C39C80F83B2010000486BC01441FFC2FFC3895904498D04004489500444895808C7400C00000000448B5108C700030000004183FAFF448950107571E9290100006683F85C754941FFC34489194589DB66428B045A6683F86E743577226683F862742D77126683F82F74256683F85C741F6683F822EB046683F866757EEB116683F872740B727483E8746683F801776BFF01448B194489D8668B04426685C00F854FFFFFFF448911E9F00000004D63D24D6BD21443FF44100CE9AC0000006683F820745077126683F80972266683F80A76426683F80DEB186683F83A743677066683F82CEB0A6683F85D74286683F87D742283E8206683F85E7608448911E9AF000000FFC389198B1989D8668B04426685C075AA448B59044963C34C39C80F8397000000486BC01441FFC344895904448B19498D0400448958084489500441FFCBC7400C000000008B5908C700000000008958108B410844891983F8FF740B4898486BC01441FF44000CFF01448B114489D0668B04426685C00F8524FDFFFF8B5104FFCA4863C2486BC014498D440004EB188338FF740D837804FF7507B8FDFFFFFFEB13FFCA4883E81485D279E431C0EB05B8FEFFFFFF5A5B5EC344891183C8FFEBF44883EC08C70100000000C7410400000000C74108FFFFFFFF59C38D41D04883EC086683F80977080FB7C98D41D0EB238D41BF6683F80577080FB7C98D41C9EB128D519F83C8FF6683FA0577060FB7C98D41A94158C34883EC0883F9098D4130760E8D5157B83000000083F9100F42C24159C341544531D24531C955575653E9E90100004489D34C39C30F8300020000488D3C5A41FFC141FFC26683F85C6689070F85C60100004489CB668B04596685C00F84C60100006683F86E0F84A101000077376683F862745877236683F82F0F84920100006683F85C0F84880100006683F8220F8584010000E9790100006683F8660F8575010000EB316683F87474176683F875742F6683F8720F855D010000B00DE950010000B809000000E946010000B808000000E93C010000B80C000000E932010000488D6C5902668B45006685C00F84260100008D58D00FB7F06683FB09770583EE30EB1E8D58BF6683FB05770583EE37EB1083E8616683F8050F87FA00000083EE5785F60F88EF000000668B45026685C00F84E2000000448D58D00FB7D8664183FB09770583EB30EB20448D58BF664183FB05770583EB37EB1083E8616683F8050F87B200000083EB5785DB0F88A7000000668B45046685C00F849A000000448D60D0440FB7D8664183FC0977064183EB30EB1E448D60BF664183FC0577064183EB37EB0D83E8616683F805776B4183EB574585DB7862668B45066685C07459448D60D00FB7E8664183FC0977058D45D0EB1C448D60BF664183FC0577058D45C9EB0C83E8616683F805772D8D45A985C07826C1E6044183C10501F3C1E304418D1C1BC1E3048D0403668907EB0BB80A00000066890741FFC14489C8668B04416685C00F8507FEFFFF4589D24D39C2730B6642C70452000031C0EB0383C8FF5B5E5F5D415CC341574489C84531D283E0104531DB415641554589CD4183E50141544589CC4183E402554489CD83E50857564489CE83E604534883EC18894424044489C84183E14083E02044894C240C89442408E9AB0100004C39C30F83C7010000488D3C5A41FFC26683F81F66890777466683F80E0F83BD0000006683F809747877166683F8010F82B20000006683F8070F86A1000000EB696683F80B0F849500000072426683F80C74606683F80D0F858A000000EB396683F82F745777146683F82674666683F82774596683F822756EEB4B6683F83E74566683F85C74746683F83C755AEB4831DBB86E000000EB6C31DBB872000000EB6331DBB874000000EB5A31DBB862000000EB5131DBB866000000EB484585E4743AE9E50000008B5C2408EB38837C240400EB0685EDEB0285F67524E9CB000000837C240C00EB0D663DFF000F86BA0000004585ED7409E9B000000031DBEB05BB0100000085DB66C7075C000F848B000000458D4A044D39C10F83B200000089C74489D3458D720166' & _
'C1EF0C66C7045A7500448D7F578D5F306683FF09410F47DF6642891C720FB6DC458D720283E30F448D7B578D7B3083FB09410F47FF6642893C7289C7458D720366C1EF0483E70F8D5F30448D7F5783FF09410F47DF83E00F6642891C728D78578D583083F8090F47DF4183C2056642891C4AEB0F4489D34C39C3732C6689045A41FFC24489D841FFC34489D3668B04416685C00F853FFEFFFF4C39C3730A66C7045A000031C0EB0383C8FF4883C4185B5E5F5D415C415D415E415FC3'
Else
$Code = '0xFF01E913030000FF02EB46FF03E924050000FF04E9770300005589E556538B3031DB39CE73256BDE144689308D1C1AC74308FFFFFFFFC74304FFFFFFFFC7430C00000000C74310FFFFFFFF89D85B5E5DC35589E557565383EC088B5D088B7D108D43048945ECE95D02000066837DF22C0F8450020000773E66837DF20D0F84430200007716668B45F283E8096683F8010F87E3010000E92B02000066837DF2200F842002000066837DF2220F85C8010000E9C200000066837DF25D746D771866837DF23A0F84FC01000066837DF25B0F85A4010000EB1466837DF27B740D66837DF27D0F8590010000EB468B4D1489FA8B45ECE821FFFFFF85C00F84020200008B530883FAFF740A6BCA14895010FF440F0C31D266837DF27B0F95C24289108B138950048B430448EB39BA02000000EB05BA010000008B430485C00F8EC6010000486BC0148D0407837804FF741D837808FF751739100F85AB010000468970088B4010894308E95B0100008B401083F8FF75CFE94E0100008D46018B4D0C8903E98B0000006683F822753B8B4D1489FA8B45ECE881FEFFFF85C00F84F80000008B1346C70003000000897004C7400C000000008950088B530883FAFF8950107565E9000100006683F85C754242668B045189136683F86E743577226683F862742D77126683F82F74256683F85C741F6683F822EB046683F8667574EB116683F872740B726A83E8746683F8017761FF038B13668B04516685C00F8566FFFFFF8933E9E80000006BD214FF44170CE9940000006683F820744F77126683F80972266683F80A76416683F80DEB186683F83A743577066683F82CEB0A6683F85D74276683F87D742183E8206683F85E76078933E9910000004289138B138B4D0C668B04516685C075AB8B4D1489FA8B45ECE885FDFFFF85C075048933EB668B138B4B08C700000000008970048950084A83F9FFC7400C00000000894810891374076BC914FF440F0CFF038B338B450C668B04706685C0668945F20F858DFDFFFF8B53044A6BC2148D440704EB0F8338FF7406837804FF74184A83E81485D279ED31C0EB1183C8FFEB0CB8FEFFFFFFEB05B8FDFFFFFF5A595B5E5F5DC35589E58B4508C70000000000C7400400000000C74008FFFFFFFF5DC35589E58B55088D42D06683F80977080FB7D28D42D0EB238D42BF6683F80577080FB7D28D42C9EB128D4A9F83C8FF6683F90577060FB7D28D42A95DC35589E58B550883FA098D4230760E8D4A57B83000000083FA0F0F46C15DC35589E5575631F65331DB83EC148B7D0C897DF0E95E0100003B75100F837A0100008B55F04366890472466683F85C0F85420100008B5508668B045A6685C00F84420100006683F86E0F841301000077376683F862745677236683F82F0F840B0100006683F85C0F84010100006683F8220F8500010000E9F20000006683F8660F85F1000000EB2F6683F87474156683F875742D6683F8720F85D9000000E9C6000000B809000000E9C1000000B808000000E9B7000000B80C000000E9AD0000008B45088D7C5802668B076685C00F84A30000000FB7C0890424E8C8FEFFFF85C08945EC0F888D000000668B47026685C00F84800000000FB7C0890424E8A5FEFFFF85C08945E8786E668B47046685C074650FB7C0890424E88AFEFFFF85C089C27854668B47066685C0744B0FB7C08904248955E4E86DFEFFFF8B55E485C078368B4DEC83C305C1E104034DE8C1E1048D0C0A8B55F0C1E10401C166894C72FEEB15B80A000000EB05B80D0000008B55F04366894472FE8B5508668B045A6685C00F8592FEFFFF83C8FF8B7DF03B7510730D66C70477000031C0EB0383C8FF83C4145B5E5F5DC35589E5575631F65383EC248B55148B45088B7D0C8945F089D083E0018945E889D083E0028945E489D083E0048945EC89D083E0088945E089D083E0108945DCE9B40100003B75100F83CC0100008D0C77466683FB1F668919774E6683FB0E0F83DB0000006683FB090F848100000077166683FB010F82D40000006683FB070F86BB000000EB726683FB0B0F84AF0000000F82D30000006683FB0C74656683FB0D0F85A8000000EB3B6683FB2F745C77186683FB26746E6683FB27745D6683FB220F8588000000EB4A6683FB3E74616683FB5C74086683FB3C7574EB5331C0E98D00000031C0BB72000000E98100000031C0BB74000000EB7831C0BB62000000EB6F31C0BB66000000EB6631C0837DE400EB3589D083E020EB57B801000000837DDC00EB14B801000000837DE000EB09837DEC00B8010000007536E9B5000000B801000000F6C2407427E9A6000000837DE8000F859C0000006681FBFF00B801000000770CE98B00000031C0BB6E00000085C066C7015C0074718D4E043B4D100F839400000089D866C1E80C83E00F66C7047775008904248955D4894DD8E89AFCFFFF66894477020FB6C783E00F890424E887FCFFFF668944770489D883E30F66C1E80483E00F890424E86EFCFFFF668944770683C605891C24E85EFCFFFF8B4DD88B55D46689044FEB0A3B7510732A66891C77468345F0028B45F0668B186685DB0F853DFEFFFF83C8FF3B7510730D66C70477000031C0EB0383C8FF83C4245B5E5F5DC3'
EndIf
Local $Offset_Init =(StringInStr($Code, "FF01") + 1) / 2
Local $Offset_Parse =(StringInStr($Code, "FF02") + 1) / 2
Local $Offset_Encode =(StringInStr($Code, "FF03") + 1) / 2
Local $Offset_Decode =(StringInStr($Code, "FF04") + 1) / 2
Local $Opcode = Binary($Code)
$_Jsmn_CodeBufferPtr = _MemVirtualAlloc(0, BinaryLen($Opcode), $MEM_COMMIT, $PAGE_EXECUTE_READWRITE)
$_Jsmn_CodeBuffer = DllStructCreate("byte[" & BinaryLen($Opcode) & "]", $_Jsmn_CodeBufferPtr)
DllStructSetData($_Jsmn_CodeBuffer, 1, $Opcode)
$_Jsmn_InitPtr = $_Jsmn_CodeBufferPtr + $Offset_Init
$_Jsmn_ParsePtr = $_Jsmn_CodeBufferPtr + $Offset_Parse
$_Jsmn_StringEncodePtr = $_Jsmn_CodeBufferPtr + $Offset_Encode
$_Jsmn_StringDecodePtr = $_Jsmn_CodeBufferPtr + $Offset_Decode
Local $Object[]
$_Jsmn_EmptyArray = MapKeys($Object)
OnAutoItExitRegister("_Jsmn_Shutdown")
EndIf
EndFunc
Func _Jsmn_Token(ByRef $Json, $Ptr, ByRef $Next)
If $Next = -1 Then Return Null
Local $Token = DllStructCreate("int;int;int;int", $Ptr +($Next * $_Jsmn_TokenSize))
Local $Type = DllStructGetData($Token, 1)
Local $Start = DllStructGetData($Token, 2)
Local $End = DllStructGetData($Token, 3)
Local $Size = DllStructGetData($Token, 4)
$Next += 1
If $Type = 0 And $Start = 0 And $End = 0 And $Size = 0 Then
$Next = -1
Return Null
EndIf
Switch $Type
Case 0
Local $Primitive = StringMid($Json, $Start + 1, $End - $Start)
Switch $Primitive
Case "true"
Return True
Case "false"
Return False
Case "null"
Return Null
Case Else
If StringRegExp($Primitive, "^[+\-0-9]") Then
Return Number($Primitive)
Else
Return Jsmn_StringDecode($Primitive)
EndIf
EndSwitch
Case 1
Local $Object[]
For $i = 0 To $Size - 1 Step 2
Local $Key = _Jsmn_Token($Json, $Ptr, $Next)
Local $Value = _Jsmn_Token($Json, $Ptr, $Next)
If Not IsString($Key) Then $Key = Jsmn_Encode($Key)
$Object[$Key] = $Value
Next
Return $Object
Case 2
If $Size = 0 Then Return $_Jsmn_EmptyArray
Local $Array[$Size]
For $i = 0 To $Size - 1
$Array[$i] = _Jsmn_Token($Json, $Ptr, $Next)
Next
Return $Array
Case 3
Return Jsmn_StringDecode(StringMid($Json, $Start + 1, $End - $Start))
EndSwitch
EndFunc
Func Jsmn_StringEncode($String, $Option = 0)
If Not IsDllStruct($_Jsmn_CodeBuffer) Then _Jsmn_Startup()
Local $Length = StringLen($String) * 6 + 1
Local $Buffer = DllStructCreate("wchar[" & $Length & "]")
Local $Ret = DllCallAddress("int:cdecl", $_Jsmn_StringEncodePtr, "wstr", $String, "ptr", DllStructGetPtr($Buffer), "uint", $Length, "int", $Option)
Return SetError($Ret[0], 0, DllStructGetData($Buffer, 1))
EndFunc
Func Jsmn_StringDecode($String)
If Not IsDllStruct($_Jsmn_CodeBuffer) Then _Jsmn_Startup()
Local $Length = StringLen($String) + 1
Local $Buffer = DllStructCreate("wchar[" & $Length & "]")
Local $Ret = DllCallAddress("int:cdecl", $_Jsmn_StringDecodePtr, "wstr", $String, "ptr", DllStructGetPtr($Buffer), "uint", $Length)
Return SetError($Ret[0], 0, DllStructGetData($Buffer, 1))
EndFunc
Func Jsmn_Encode_Compact($Data, $Option = 0)
Local $Json
Select
Case IsString($Data)
Return '"' & Jsmn_StringEncode($Data, $Option) & '"'
Case IsNumber($Data)
Return $Data
Case IsArray($Data) And UBound($Data, 0) = 1
$Json = "["
For $i = 0 To UBound($Data) - 1
$Json &= Jsmn_Encode_Compact($Data[$i], $Option) & ","
Next
If StringRight($Json, 1) = "," Then $Json = StringTrimRight($Json, 1)
Return $Json & "]"
Case IsMap($Data)
$Json = "{"
Local $Keys = MapKeys($Data)
For $i = 0 To UBound($Keys) - 1
$Json &= '"' & Jsmn_StringEncode($Keys[$i], $Option) & '":' & Jsmn_Encode_Compact($Data[$Keys[$i]], $Option) & ","
Next
If StringRight($Json, 1) = "," Then $Json = StringTrimRight($Json, 1)
Return $Json & "}"
Case IsBool($Data)
Return StringLower($Data)
Case IsPtr($Data)
Return Number($Data)
Case IsBinary($Data)
Return '"' & Jsmn_StringEncode(BinaryToString($Data, 4), $Option) & '"'
Case Else
Return "null"
EndSelect
EndFunc
Func Jsmn_Encode_Pretty($Data, $Option, $Indent, $ArraySep, $ObjectSep, $ColonSep, $ArrayCRLF = Default, $ObjectCRLF = Default, $NextIdent = "")
Local $ThisIdent = $NextIdent, $Json = ""
Local $Match, $Length
Select
Case IsString($Data)
Local $String = Jsmn_StringEncode($Data, $Option)
If BitAND($Option, $JSMN_UNQUOTED_STRING) And Not BitAND($Option, $JSMN_STRICT_PRINT) And Not StringRegExp($String, "[\s,:]") And Not StringRegExp($String, "^[+\-0-9]") Then
Return $String
Else
Return '"' & $String & '"'
EndIf
Case IsArray($Data) And UBound($Data, 0) = 1
If UBound($Data) = 0 Then Return "[]"
If IsKeyword($ArrayCRLF) Then
$ArrayCRLF = ""
$Match = StringRegExp($ArraySep, "[\r\n]+$", 3)
If IsArray($Match) Then $ArrayCRLF = $Match[0]
EndIf
If $ArrayCRLF Then $NextIdent &= $Indent
$Length = UBound($Data) - 1
For $i = 0 To $Length
If $ArrayCRLF Then $Json &= $NextIdent
$Json &= Jsmn_Encode_Pretty($Data[$i], $Option, $Indent, $ArraySep, $ObjectSep, $ColonSep, $ArrayCRLF, $ObjectCRLF, $NextIdent)
If $i < $Length Then $Json &= $ArraySep
Next
If $ArrayCRLF Then Return "[" & $ArrayCRLF & $Json & $ArrayCRLF & $ThisIdent & "]"
Return "[" & $Json & "]"
Case IsMap($Data)
If UBound($Data) = 0 Then Return "{}"
If IsKeyword($ObjectCRLF) Then
$ObjectCRLF = ""
$Match = StringRegExp($ObjectSep, "[\r\n]+$", 3)
If IsArray($Match) Then $ObjectCRLF = $Match[0]
EndIf
If $ObjectCRLF Then $NextIdent &= $Indent
Local $Keys = MapKeys($Data)
$Length = UBound($Keys) - 1
For $i = 0 To $Length
If $ObjectCRLF Then $Json &= $NextIdent
$Json &= Jsmn_Encode_Pretty(String($Keys[$i]), $Option, $Indent, $ArraySep, $ObjectSep, $ColonSep) & $ColonSep & Jsmn_Encode_Pretty($Data[$Keys[$i]], $Option, $Indent, $ArraySep, $ObjectSep, $ColonSep, $ArrayCRLF, $ObjectCRLF, $NextIdent)
If $i < $Length Then $Json &= $ObjectSep
Next
If $ObjectCRLF Then Return "{" & $ObjectCRLF & $Json & $ObjectCRLF & $ThisIdent & "}"
Return "{" & $Json & "}"
Case Else
Return Jsmn_Encode_Compact($Data, $Option)
EndSelect
EndFunc
Func Jsmn_Encode($Data, $Option = 0, $Indent = Default, $ArraySep = Default, $ObjectSep = Default, $ColonSep = Default)
If BitAND($Option, $JSMN_PRETTY_PRINT) Then
Local $Strict = BitAND($Option, $JSMN_STRICT_PRINT)
If IsKeyword($Indent) Then
$Indent = @Tab
Else
$Indent = Jsmn_StringDecode($Indent)
If StringRegExp($Indent, "[^\t ]") Then $Indent = @Tab
EndIf
If IsKeyword($ArraySep) Then
$ArraySep = "," & @CRLF
Else
$ArraySep = Jsmn_StringDecode($ArraySep)
If $ArraySep = "" Or StringRegExp($ArraySep, "[^\s,]|,.*,") Or($Strict And Not StringRegExp($ArraySep, ",")) Then $ArraySep = "," & @CRLF
EndIf
If IsKeyword($ObjectSep) Then
$ObjectSep = "," & @CRLF
Else
$ObjectSep = Jsmn_StringDecode($ObjectSep)
If $ObjectSep = "" Or StringRegExp($ObjectSep, "[^\s,]|,.*,") Or($Strict And Not StringRegExp($ObjectSep, ",")) Then $ObjectSep = "," & @CRLF
EndIf
If IsKeyword($ColonSep) Then
$ColonSep = ": "
Else
$ColonSep = Jsmn_StringDecode($ColonSep)
If $ColonSep = "" Or StringRegExp($ColonSep, "[^\s,:]|[,:].*[,:]") Or($Strict And(StringRegExp($ColonSep, ",") Or Not StringRegExp($ColonSep, ":"))) Then $ColonSep = ": "
EndIf
Return Jsmn_Encode_Pretty($Data, $Option, $Indent, $ArraySep, $ObjectSep, $ColonSep)
ElseIf BitAND($Option, $JSMN_UNQUOTED_STRING) Then
Return Jsmn_Encode_Pretty($Data, $Option, "", ",", ",", ":")
Else
Return Jsmn_Encode_Compact($Data, $Option)
EndIf
EndFunc
Func Jsmn_Decode($Json, $InitTokenCount = 1000)
If Not IsDllStruct($_Jsmn_CodeBuffer) Then _Jsmn_Startup()
If $Json = "" Then $Json = '""'
Local $TokenList, $Ret
Local $Parser = DllStructCreate("uint pos;int toknext;int toksuper")
Do
DllCallAddress("none:cdecl", $_Jsmn_InitPtr, "ptr", DllStructGetPtr($Parser))
$TokenList = DllStructCreate("byte[" & $_Jsmn_TokenSize * $InitTokenCount & "]")
$Ret = DllCallAddress("int:cdecl", $_Jsmn_ParsePtr, "ptr", DllStructGetPtr($Parser), "wstr", $Json, "ptr", DllStructGetPtr($TokenList), "uint", $InitTokenCount)
$InitTokenCount *= 2
Until $Ret[0] <> $JSMN_ERROR_NOMEM
Local $Next = 0
Return SetError($Ret[0], 0, _Jsmn_Token($Json, DllStructGetPtr($TokenList), $Next))
EndFunc
Global $tagLITEM = "uint Mask;int Link;uint State;uint StateMask;wchar ID[48];wchar Url[2073]"
Global $tagNMLINK = @AutoItX64 ?($tagNMHDR & ";byte Aligment[4];" & $tagLITEM) :($tagNMHDR & ";" & $tagLITEM)
Global Const $__SYSLINKCONSTANT_ClassName = "SysLink"
Global Const $__SYSLINKCONSTANT_DEFAULT_GUI_FONT = 17
Global Const $__SYSLINKCONSTANT_WM_SETFONT = 0x0030
Func _GUICtrlSysLink_Create($hWnd, $sText, $iX, $iY, $iWidth, $iHeight, $iStyle = -1, $iExStyle = -1)
If Not IsHWnd($hWnd) Then
Return SetError(1, 0, 0)
EndIf
If $iStyle = -1 Then
$iStyle = BitOR($__UDFGUICONSTANT_WS_VISIBLE, $__UDFGUICONSTANT_WS_CHILD)
Else
$iStyle = BitOR($__UDFGUICONSTANT_WS_VISIBLE, $__UDFGUICONSTANT_WS_CHILD, $iStyle)
EndIf
If $iExStyle = -1 Then
$iExStyle = 0
EndIf
Local $nCtrlID = __UDF_GetNextGlobalID($hWnd)
If @error Then
Return SetError(@error, @extended, 0)
EndIf
Local $hSysLink = _WinAPI_CreateWindowEx($iExStyle, $__SYSLINKCONSTANT_ClassName, $sText, $iStyle, $iX, $iY, $iWidth, $iHeight, $hWnd, $nCtrlID)
_SendMessage($hSysLink, $__SYSLINKCONSTANT_WM_SETFONT, _WinAPI_GetStockObject($__SYSLINKCONSTANT_DEFAULT_GUI_FONT), True)
Return $hSysLink
EndFunc
Func _GUICtrlSysLink_SetText($hWnd, $sText)
If _WinAPI_IsClassName($hWnd, $__SYSLINKCONSTANT_ClassName) Then
Return _WinAPI_SetWindowText($hWnd, $sText)
EndIf
EndFunc
Global $_ZLIB_CodeBuffer, $_ZLIB_CodeBufferMemory, $_ZLIB_CodeBufferPtr
Global $_ZLIB_Alloc_Callback, $_ZLIB_Free_Callback
Global $_ZLIB_DeflateInit, $_ZLIB_DeflateInit2, $_ZLIB_Deflate, $_ZLIB_DeflateEnd, $_ZLIB_DeflateBound
Global $_ZLIB_InflateInit, $_ZLIB_InflateInit2, $_ZLIB_Inflate, $_ZLIB_InflateEnd
Global $_ZLIB_ZError
Global Const $_ZLIB_tagZStream = "ptr next_in;uint avail_in;uint total_in;ptr next_out;uint avail_out;uint total_out;ptr msg;ptr state;ptr zalloc;ptr zfree;ptr opaque;int data_type;uint adler;uint reserved"
Global Const $_ZLIB_USER32DLL = DllOpen("user32.dll")
Global Const $Z_NO_FLUSH = 0
Global Const $Z_NEED_DICT = 2
Global Const $Z_DATA_ERROR = -3
Global Const $Z_MAX_WBITS = 15
Func _ZLIB_Alloc($Opaque, $Items, $Size)
#forceref $Opaque
Return _MemGlobalAlloc($Items * $Size, $GPTR)
EndFunc
Func _ZLIB_Free($Opaque, $Addr)
#forceref $Opaque
_MemGlobalFree($Addr)
EndFunc
Func _ZLIB_Exit()
$_ZLIB_CodeBuffer = 0
_MemVirtualFree($_ZLIB_CodeBufferMemory, 0, $MEM_RELEASE)
DllCallbackFree($_ZLIB_Alloc_Callback)
DllCallbackFree($_ZLIB_Free_Callback)
EndFunc
Func _ZLIB_Startup()
If Not IsDllStruct($_ZLIB_CodeBuffer) Then
Local $Code
If @AutoItX64 Then
$Code = '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'
$Code &= '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'
$Code &= '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'
$Code &= 'jgCnFmaGwnHaPhws3m/ASbnTlPCBAQQJlea4sXv0DaM7Hi6AG0g+0kMtWQBu+8P22+mmkQBnUR+psMx6zgAMdJRhuWbxBi4F3gBAdwcwlgDuDmEsmQlRuvZtAMQZcGr0j+ljAKU1nmSVow7bAIgyedy4pODVB+kel9LZ0Am2TCsAfrF8vee4LQcOkL8dkUC3EGRqsAAg8vO5cUiEvgBB3hra1H1t3R3k6/TJtVGAloXHE2wAmFZka6jA/WIA+XqKZcnsFAEAXE9jBmzZ+g93PQCNCA31O24gyABMaRBe1WBB5AOiZ3FyPAO40UsEANRH0g2F/aUKHLVrNcCo+kKymGwA27vJ1qy8+UA9MtiB40XfXHXc+A3PAKvRPVkm2TCsUFHGOjvI1wCAv9BhFiG0APS1VrPEI8+6AJWZuL2lDygC7J4AXwWICMYM2bIAsQvpJC9vfIcAWGhMEcFhHasAtmYtPXbcQZAAAdtxBpjSILwP79UQKkOxhYnotrUfF5+/5ADVuNQzeAdYyeNwmBMAlgmojuEOmBgAf2oNuwhtPS0AkWRsl+ZjXAFxax5R9BzAYWKFZTDYdvLgTvYGAJXtGwGle4IIAPTB9Q/EV2WwANnGErfpUIu+ALjq/LmIfGLdXB1GA9otSYzT2PP71AVMZU2yYYVVAyvOo7yDdPi7MOIASt+lQT3YldcApNHEbdPW9PsAQ2npajRu2fwArWeIRtpguNAARAQtczMDHeUAqgpMX90NfMkBUAVxPCcCQfy+C3EQ+gwDIIZXaLUlsG+Fs5DeANQJzmHkn17eAPkOKdnJmLDQ5iIAx9eotFmzPRd2LgANgbe9XDvAugBsre24gyCavxyztgOT4gcVsdKw6tVHOXedAHevBNsmFXPcABaD42MLEpRkLDuE7QdqPnowWqjkDgHPC5MJ/50KwK4nA30HnrHwD/BEhwgAo9IeAfJoaQYAwv73YlddgGUAZ8sZbDZxbmsABuf+1Bt2idMAK+AQ2npaZ90ASsz5ud9vjr537zoXt49DYLBH1dYQo+ih0ViTCADYwsRP3/JS9rtcZ/UdvFdAP7UG3UiyADZL2A0r2q8KPRtMAgNK9kEEwcjfyO/DO6hnB1Uxbo6RRmm+cPBhsJ8AvGaDGiVv0qAAUmjiNswMd5UAuwtHAyICFrkAVQUmL8W6O74Asr0LKCu0WpIAXLNqBMLX/6cAtdDPMSzZnosAW96uHZtkwrAA7GPyJnVqo5wOAm2TCqAJBqnrDgE2P3IHZ4UFwFcTAJW/SoLiuHoUAHuxK64Mths4AZLSjpvl1b4getwA77cL298hhtMc0tTxgOJCaN2z+AAf2oNugb4WzQD2uSZbb7B34R0Yt0dmegBa5v8PanAAZgY7yhEBC1wfj2WewPhirmlha+7TABZsz0WgCuJ4ANcN0u5OBINUADkDs8KnZyZhANBgFvdJaUdNAD5ud9uu0WpKANnWWtxA3wtmADfYO/CpvK5TAN67nsVHss9/BzC1/+m9EPIcyroHwopTs5PwJLSjpvbQBzYFzdcG0FTeVykSI9lnANpmei7EYQBKuF1oGwIqbwArlLQLvjfDDACOoVoF3xstAi7vjQBHGaAxQTI2AmKCKy1Tw2DXxQQAfXf0RVZap4YAT0GWx8jZiggB0cK7Sfrv6OTj9PrLDqy1Twxgrn5NnoMALY6HmBzPSsIAElFT2SMQePQAcNNh70GSLq4A11U3teYUHJjr5AWDD4SWghsnWZsAqRiwLTv62wE2y5rmd13E/2ziHADUQT/fzVoOngCVhCSijJ8V4wCnskYgvql3YQ7x6OGmYPPQ58PeA4Mk2sWyZQBcrqpERp/rbwBrzCh2cP1pOXkxAK4gKlrvCwcJACwSHDht30Y2H/PGXUCy7XBUcfRYa4UfuyrA96IxwraJAByRdZAHoDQXAJ+8+w6EjbolAKneeTyy7zhzd/ML/2roSICqxRt9WA/eKjzw4E8F6WJ+O0TCgC2H21QcxpQAFYoBjQ67QKYBI+iDvzjZwsygxT8NIYD0TAqWp48TdY0c'
$Code &= 'zlzMAAlF1zFIbhL6YosJ4lMAe7tdVKMAoGwViI0/1pEAlg6X3teYUMcAzKkR7OH60vXmywCTcmLXXGt55gAdQFS13llPhACfFg4SWA8VIwMZJDhw2j24QZtlCf1rp3x4AQBXywklTtA4ZAABka6jGIqf4gAzp8whKrz9YACtJOGvtD/Q7iSfEnEAhgmybMlIPySrAFMV6vt+RikA4mV3aC8/efYANiRItx0JG3QBBBIqNUtTvGFF/I2zAHll3nBgfu8xDufm8/4g/cK/1dAAkXzMy6A9g4oeNvqawAe7sbxUeACop2U5O4OYS3MiAKkKCbX6yRCuAMuIX+9dT0b0AGwObdk/zXTC7owA81oSQ+pBIwIcwWxwz9h3IICXNtdHB44t5galALXFvBtxhABxQYoaaFq7Ww5Dd+iY52zZEBUtTx4EDDZ+XyfBXpw+wBzdOLmYABKggzFTi64OYpCSteDR3fTFFjrE77lXzOoAlPbZltWuBwC86bccjaicMRLea4XwAcqQLQDt03BIrPhdGx9v4UbDLmbeNrl/xSHJKwH/Y03zZWDXsurlABupwqQwhJFnACmfoCbkxa64PP3egPnW88w6z+j0ewGAqWu8mbJa55ifCT4Aq4Q4fywcJLAANQcV8R4qRjLuMQB3c0hw4bRRax/Q9XrAgzZjXbJ3AMv6107S4eYPS/nDAeDcwCmvlhI7SrYBIwudoHDI+LtBPYkDg11GGjhsA3YVP8QoDoiFZ08AmEJ+VKkDVXkD+sBMYsuBiDjFHwCYI/Resw6nnQOqFZbc5VSAG/xPDjFa12Igmc55U9g+SeGAF1D6flZ71wktlWLMjvfAjYoTNJYcu1IfwOiRBqDZ0ABefvPsR2XCrT9sSIBudVOgLzoSADboIwkHqQgkAlRqET9lK2B3eeQAj7xIpaSRG2YDvYoqJ/LL6ODr0BSNocD1AWLZ5u8jFPzhvQANp9D8JoqDP+KRHrJ+cMAkuWnLFfgAQuZGO1v9d3oS3GVrAKl+WvTuUwEJN/dIOHa43K6xAKESn/CKP8wzC5Mk/XKQAAHCAGo3A4TUbgJGLL5ZVwCo3AbLwusABI18sgVPFoUADhNRuA/RO489DZeA1gxV7+EJGgD5ZAjYk1MKnnMtuM4ARz0cJqNwHeR5yQ4fonceL2BAKRsvC6wAGu1hmxir38IAGWm19RI18sgAE/eY/xGxJqYAEHNMkRU8WhTi/gEwIxa4jnoXyORNcjgARuA5jyzXO8kAko46C/i5P0QH7jw+hoSur8DAUj0CUGUANl4XWDecfW8eNdrDwDQYqQExVwC/hDCV1bMy0w9r6jMR590kcuWQwNyPp0wn6wD+Ji1bySNiD01MIqDBeyDmmdwhJADzFSp4tCgrugPeHyn8YEbIPgpxci0AHPQss3bDLvUByJovN6KtcNiNwABxWOf3cx5ZrgBy3DOZd5MlHAF2UU8rdBfx/HXVAJtFfonceH9LALZPfQ0IFnzPAGIheYB0pHhCAB6TegSgynvG5v0FbLwusG3AP4dvOC763hQJkOkAboZsancA7FtoMVICafMAODVir38IY22YPQBhK6tmYOnBUQdlptfUZBO94+giA7oHZ+BpjUjwyyBJFSyhF7gFH05KxbOAjt5j/PIcAAnLTFq3kk2YB92lRsSaYEcG8K8ARUBO9kSCJMEdQc0y/YAPWHNCSeYqAEOLjB1U8WhQAFUzAmdXdbw+AFa31glT+MCMAFI6qrtQfBTiB1G+ftVaYDnoWyAAU99ZZu2GWKQAh7Fd65E0XCkA+wNeb0VaX60AL23hNRuA4PcAcbfisc/u43NMpVMDPLNc5/68gFa4ZzIA5HoNBe8mSjh57gAgD+yinlbtYAf0Yegv4ufpkIjT66sANorqaVy9/RMAuPD80dLH/pcAbJ7/VQap+hoBECz72Hob+fjEQgf4XK518wDpSPLCAIN/8IQ9JvFGAFcR9AlBlPXLACuj942V+vZPAP/N2XhdYNi6ADdX2vyJDts+AOM53nH1vN+zHZ+L3cAh0tw3S+UA12sM'
$Code &= '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'
$Code &= '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'
$Code &= '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'
$Code &= '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'
$Code &= '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'
$Code &= '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'
$Code &= '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'
$Code &= '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'
$Code &= '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'
$Code &= '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'
$Code &= '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'
$Code &= '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'
$Code &= '+iipPduEBK+JF4pC8Ulqtk7WaZ9PBTswNiZFQlFEzR2RN0AU9kAIWwLAz4lQID3HQvDhO6NR1BKZygl69JHLy/baE27V6JoWBHP8bTAKEwK4/99hC0LDgkN1BX0Bv+sUhLG0EonZ5Au5UgSWPynsGgb/o7IdBkU5l3KgEwtBRHrzAUUGmxwJI+SOcl6NtDAz7bXHhZDglrCKdZh5O39El3MQ7GXUa/E/H0isOCd0WVCwqHPHB2IfZYnRVKYF02dA1tIskIcHCHIni0/TTI2UgquQhL9HwZnC+CjyWJYuAZ9jwIlCOCcHc+JIjcZ8CGNUUMcBcI8S6PT+IWxGCJTkFhsL6OT+/F3LA4IMKWcuNk55CtZuFA6dCHwEdBH95nVfHIAW6Orj3o02VgjSIPy4SYWQJ6SESWk3XqULgzgNDianeEQOywZduhy5pVNqxV9lOa4IwcxiaAF37HZQXwmLSXpFilINjUIwoZAaRYWDev9Ltjp2nsqEr9utCUG915hy6BuCVn4mQS9sJEQF61g5I4tA8H7yb5BwSD9SNShF4HfTTuK9Gd/UxSwvJcUghY1F/OiYteopTT6F4/5MIeFI2p159YXo81YXz7ajS9VWDTLiI4lgX1gFdYf0OkkMOcNyQxnUQxsddzdPKfsFgetPG8FAAkqNhJ6VRjonRlhxqRcpCs4tEafY6cVuhIYyHWAFh+wFkCDp3qkcfYWTFVfc5OtBMtPlLOmu4ypSkLEWbjh+ULTLCSjpJiuAFkGG0KS1QhmCEMeAVTqsQhT+p3MhSUdFPq6AQ/kPdeX/7iROgFLwkYfIw4ooGHWAFoiS0yu0GoQMsFKEDlu4XYSlXRjtWUgJgenrqiVJECDCmIsEboIK+UpacAPg6SrMu7BkkDIk7P4xxglHkwLEIk6UBNxEcZUEDpYIvoghlxFRImMgtpggJZlELJKIEJqAHZuAdp6BfRGQoALuInSiBMdEdqMe4iBupETq9Yl5p4hZ72Fjb3LFZdR0IJ3O6eeUGmseqSrpJWk53EbcncdrXo9AO3rx08x+QiPyYgjhUgfPcJVhfSEHdVctHw1t0sc9KGfnWGTjb2aZYmzWnM2E4VBthnmsSqIbHNjueQ9tYm9stFe9G5jbfDSKZQ5RZyiQvK0QHXR5cJEWaocbYa45+mPypLCBk3QhmRgbdTluax1vd1QgI9P6CltnedqU0oxFp9RGdxLrt4xwsnplvFnGfm1wgKsl7hj1lLBo4XDAAA=='
Else
$Code = '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'
$Code &= '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'
$Code &= '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'
$Code &= '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'
$Code &= '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'
$Code &= '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'
$Code &= 'y2kA16t3DrK5wqEAXAF+xjmcqf4EgCQVmeW4/wALjhxRboZmABanPtpxwixvc94AlNO5SQkEgfADsbjmlaMN2Xsb5C4eAEPSPkj7blktAOnb9sNRZ5GmAMywqR90DM56AGa5YZTeBQbxSLiYSuH83N//4sNRVceAD1aJ1vfQhRz2dBvOwQOgFg+2ETESwoHivSd/B+gIM0SVAEFOdeUAU1eD/iAPgvHAd4n3we8FeTPuwu7qfBB8wwrrCIHjLSEzDIuUYATODjPunQgIIB98GGVUGCUZHCqFwQyDD1EEidAqthAUIIuExWGJ03FIM4RIO9OEQUQJWJUslTwVQQh463WPeRAPQ3KQPdF4vBSPWIPBZyD2+GfubfyguYCNfnH8HrBPD4UmFP4gKPoGBHJLifL+SAL2QZHz0sdgABCBVOdQvEO9IcPFvDyLfIUQvNDHAARKifh1ul9NW20TF5A7aSbqigFeXcMxwC7C7A5hjwHXcuYBg8IE0el18jCtiZiGl2FMfTACxgop97sgfw8MN+9V5ejOHKOAiQaDxgRLAnXtX15bXYMqgeyE0qtTiYgA3c6F23/NaPAy9eybNrktgMdFgJdIBYnI5Ex6hR9AAckf+MZ89I0qdFCjqBuZ6JIL/8oLG1Et+4N0Ez3ECL1VqVIhlXESLARgIKEFD4nxjZVIFUegmwrR+3QnJk2clHlHKqIMLIboUyAnFHWvlAozRQiXyLKfixwM303YUA4Q6FI8NRJdwhE1GaIjPHdNkCckdQYtIBChCRCoRAwgKvyOH/5T6fAQV/TPkbAS4fn5A4P7AXUzUKF7EPLRGIH58SdyBvDpoAgBz/H6mRDvCUCpweAQCl8JyFtOBlaLddZ09gIKjUYBXl+sEpQQJHM8WQx0C5YGMgHBLs9BfPVaUQe4cYAHIvfnYTYPNIDgOgQpigH4XlNYgfs1sBVKglLOeo4Dr6luXvfjAVYLiVUMgetAGbhbAcU9thYZpwpW70S+CAKORwMjBJEFyAbkB3IIOQkcCo5HCyMMkQ3IDu9wmghAUhBIsAIgd/+MzEThaXPSktzQPN7kMxLXpIaOWkU/RxaDhM2EiG0Qod+REYnYMOAEr8z2FIPrEM+idKqiuPoX3kSJm71JXixRjCTGJFwU1yuI5mr3QynWy7fpifO7OLqv4BTXjYQQb/At5UX8eSnk6RAmKdGajgH57NlMDqITQbL8ZcAnRyMUJFXxPXAvAcUaBS0fByoZ0RhNQZwEm8tJfOfexDN96Fj/DeRyFUA6dyP2+ikiCPlE7uGJ1hLCJLVKoBxoAQNTUVLohENYLTgZJbsECwFwSwqJunJQATkUi3QJib4KPEQJ/OL6AO9aWVvDN+ivM2K4VXcIfZXLCUCIQ0Q1MogBwrjWBQgpyosCDooEE7mYkx7IKQq8AGluY29tcGF4dAdibGUgdjNyc8/3bg+HdWYdFv9/BvvbhkRucx/PYx/8jnQgbbyzJnmDZHJiph96c+/n8m2bDWhOjAtoGeNuZIc/Prr575mGdLthoX6HYy4ykzWE7zksGwGKAQTZAh8jA+QEfAWPuEUMexA4ERIACAcJBgoFCwQEDAMNAsLRD7WWI37IbvIxXgZMBAeORwgjCZEKyAvkDHINOpcV6AH8haMVB/HiDKaMjAlETMyJLBKsJGxI7JEcIpxEXNyJPBK8JHxI/JECIoJEQsKJIhKiJGJI4pESIpJEUtKJMhKyJHJI8pEKIopESsqJKhKqJGpI6pEaIppEWtqJOhK6JHpI+pEGIoZERsaJJhKmJGZI5pEWIpZEVtaJNhK2JHZI9pEOIo5ETs6JLhKuJG5I7pEeIp5EXt6JPhK+JH5I/pEBIoFEQcGJIRKhJGFI4ZERIpFEUdGJMRKxJHFI8ZEJIolEScmJKRKpJGlI6ZEZIplEWdmJORK5JHlI+ZEFIoVERcWJJRKlJGVI5ZEVIpVEVdWJNRK1JHVI9ZENIo1ETc2JLRKtJG1I7ZEdIp1EXd2JPRK9JH1I/ZUTwnRnAQiTCLIRUy6RItPpEjMukSKz6RJz'
$Code &= 'LpEi8+kSCy6RIovpEksukSLL6RIrLpEiq+kSay6RIuvpEhsukSKb6RJbLpEi2+kSOy6RIrvpEnsukSL76RIHLpEih+kSRy6RIsfpEicukSKn6RJnLpEi5+kSFy6RIpfpElcukSLX6RI3LpEit+kSdy6RIvfpEg8ukSKP6RJPLpEiz+kSLy6RIq/pEm8ukSLv6RIfLpEin+kSXy6RIt/pEj8ukSK/6RJ/LpEi/+kViBFAyAkgkWAiEERQMIlwEggkSEgokWgiGERYOIl4EgQkREgkkWQiFERUNIl0EwMyhYMJQyTDSCORoyJjReNi3s4FCRCbzcbH+b6vbJcIDIkcEgIkEkgKkRoiBkQWDokeEgEkEUgJkRlAAhXICQ2RHSIDRBMLiRsSByQXUX+BAQIDBMf/FgYDRAcIjkcJIwrkC3wMj+QNfyMO/kcP/cOEsfnFE8UUkQMVIxaRF8gY+RkfIxr5Gx/IHP+RHf9JB6SCBQdE+aTlpbspY0UQMgERORIcE45HFMgV+RYfIxfkGH8jGfq/h+Qc82uJAeczEwTOyk5ywgp7phEOIhBkFAkYSByRICIoRDA4iUASUCRgSHCRgCKgRMDgnqNyNX+UBnfKDG9lGDJnMJlfYExXwKY9+VpBsFvo6mP2/IkDuXf1jw9DBEHYW8NT9eZRkpUrASkqs7OtHjgJD1AuQ0P7Id9RHIqpvyrTxx4KLsI39pYnV+3nFD4rJ4kTOFrDjTKClA+5gGVWMfZmAIkwg8AESXX1xC6ICSY5hxaIfAqRE+K4k/toHJL3jDHAEKxBFpAMqMiwZKBLXuggUYskkFC5klPgagj2nC2wXIB/jQw2iQFd/DnRD4+hgI99NYu0iGDbLzy8IA+3FOWACByfZjnacgEZdRiKlAZYtIFISh06DkF3AUFNEdxV/Mhjl7tCDEB1EyWKKJwCJnc6qC12LsEmCIm0kFQvN43RzgHJ0oiPggl+glCa/IymlpcbsGd9JgjPapReohP4nKUgotJ3gwcoi1EEU0cZZkmuPlXoMxEK3DIjVg7gAwhX2HkQMd+8FOSTO9FyPsHisQkOiDyygQxAGUQMSIZDTCFQkFTIWJqLGBLyM4NQmGhMKZMCFCiDSEE6OdiofbQEdfiB+T3QfQ+NTZKM60ksiuz0uhUGKcoB6vjs/k0o8JDNUfShBouF3wt6gEE5+X4GRonrooFXUDvAfw9Hi33kov+ESJOlEsI5+gHxidYp/qAqzkk0iQc8kwHxY6/PqohE3smc3NjAYBAsVJECAWfyLtdSkKwSDpFwAINF9AT/TezyjASF9g+Et5Dajbx4olShY0lmg/KoYKqiCAZ1CoPqAi1wOjZ09gz4RD4CTLqxn5QBIpQ8YBQPg+4CxJp/vpeVcdJ0Z0P47DP0Pwz06//rThOs8I13A8b87vukVvgHdeA7mtAZL0p8QeqNdI4IOdegGYnTKfvo3/khNp0sDKiyCPkBuKig/euoaBrQlrg34JxGvBQG7IPvAkrF+JxIX+ryEHyZPr/P/cB6RwIx0scbRfj/A/989kpzBwlyBIXAgkW5ipDWcANTuL0EiUSfBugnEIiQj8dpQymr2thuXdBr8A2XCiStGwdCOcp9BE+pdIew8oUKS++HEGLrL8OadBY7dcJJCIxFE7sQqLwaHxWD+ox/CR3AhGQHE8RQjiCJ1NZJRoEGcgPrFqjIHQZDcf31CpkHCkqXEfwK9HWA2NEcB8l40FVe1RTgCNjsaKci2IrlxM3ItwxsIQOEUP/WLEQFxiQGR2kgzRd96LskBR7e5JSoRn30ZNos5B4meBX84ExcJv4EGvCRQWH4MKOe2FNMvLBVfrghyeEWArpSICwp+oKYXTK0sKbvOYnyhNPii0iAAAmQuMJHD7aYhQeLgLGIHBE7/0BkIbkiSP0tpicxywFJsRBNh9LA6SjRwH7ujUw68MqSsDmgjz7rFFhGQl1otFdpeJahholMhQ8qhWf2KukRp5GzGMuTO3Vl7BKqMq+MGb9NqSACTVb4uU1ANGg4JFXUY2WyCorkXmiuioqA'
$Code &= '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'
$Code &= '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'
$Code &= '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'
$Code &= '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'
$Code &= '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'
$Code &= '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'
$Code &= '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'
$Code &= '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'
$Code &= '2GDtD4NrAc3wU7Ta70FMSCHY2ASBJ4nBCFL4EsnQH/F2P5MMCD4J01JtD1EMCjxVGwo/z3e0Dy8QCrZaIxkPOc6KJ1VNHk5h0lkgLMyNTnLZD1RpyI1moen2ImOG6TntixEYsXVhS41BTAJ9Ctw5xlnEkG2VVNyukCdtwk6hslako0Ygm+y3y7RuKbqOt2nAdYwZm+Sqv4/FK+l6nc3PEcuMxXVFhgOlZxEpqAOO0MhVIgfSn0sXuPjT5d1DlEIHRaPk5D8jB2R/CAthB7j5Fexnmh5XqeQzvfrBTtrwd2RjsvS1NrY4MbD5PoSNjWsBF3XsMwGFgv9Cj4M/HYSEAlDmFr9wkZJ1NjNUEQQPxOAGUBIRxQ7IzkkQZr8Ojmm8JR3EpPQTYHLHCS/zMMYB6Nxp2/AWw1sVcspEsWBuCFdRbEvZUGINyFggz2RgkgbZxaYyQIBSagLoj9uzE8swzdoNjmshYZZnget1siEYFHGsvg5yboHawEsCy2VAb4rog/5uZwwS+Gwd4PZQYxAi/FE8DgT7vskCdzzoIHWIUyoLUAzr4XwogtXqo/Lsn2haPwu+4ssB3Q+FrC9JY4d7SY/pnfZpbwkZBAHSN4lJvUx+EyA7exHDBb8ShMC6MdCo8EOMsEURHziBQSIh4YkMyAOR59xZSbQajbpLDfQisgHIlJTbUGR+o2botcAuCjnwdlaYxCtknbYSn0KMlSDF2Vi3yTGPCldN2JFdTGl/Wt7lPZWzgVXWhkasMXeq092LBMiYiUiPHZDPogGoDhi1mo1Q4E9ASoTIKRmEIEQEvYS7FY5sTmJtK4QZQNwSpUcLNA8tUv2GJ45kSFQVzVDmaTpAYZV3+xBPBOw7IndI0Wzc0JFF1exHQKKbM6N7NKG6yBasQhZ/SljiQ5TjyFBWKUCQcAnfAzzkR1jIUNSv3HFQHoRPA3uIUPxGAeUsrNxHCRRjAitpkUlF4CWxftVPCV4XHbQImwJ3kESmmlwYDMzwhVmKafYrz+66T0QEyFcpIzvjLNAbg79uwFsS5h8RFwnNw6uZuDBZDwYSPjQDNyhlscHrC7YbDh54MIKplxMas9w+TxX0LusOaLQ49UVIftzTYto3aTTUXUbcRfromunKFtSRPONX6wMMF4oMAS+IJQhADdha5HXslRhCQQG51kPpNt0oz4r1FkjvoogwRfAMJBKEIn8IcK+8kNBXAY3NlkcaOC/w9yRBFEEbHJz8koApUjQnVxhiz9UgyVFSdAf+nF6I4iQ7tN9tAQYghomF4PTYdV4jJMa4OCbhjklyP7bnaXhjhBBmGA47biZ0Dw9ijAcw61e86GQbMgglkUgKEJWHyeOOhG4CO18cdFdGyCMVBy2ZU4v62hsUhnHtuU+EOf8pZqXQGhtRGCDAlBK3FmliFFAQS14JF1v0+kgraKHEHFOg4gGJ6/dLE1D3Re0DviiEs1w/dfwJPxp9LihnnI87QcV0Iw8LXWPoautUfGsUyLAep/nb6JuQdQNF0CtGBFBSnl6QTfNr145q4SkfJ2B2dDG1BJ0tiCJTvWEVVqj4VC8p2gKH+IYC6w9dxKHJItl4QycGh8QtnwqwBkETdAxCtgh8oWEOdQdEDIzpBL9KFvUDDuFALzALWBGwZQYISoHigFE+AcoSVzwMe9DqVhEsdQQtBtK39BlOi1KUBaCx/qsilPueudQyYLUQbhikvooiEnQ9+ycedDa/jBUv/EC3JDEKvo6kIE5BVv0kQb//0Gstdj8S++8rmVRHVpVShW/EQ4tzVt9EuUaDfuK1QuKHaxGjPgpLCvir9iMldSdsQyLphRJNDFfuDBPeFztMRpl9yFn9UItDCRDoxekYpRJfJMcGpmqlIx6gsdN78L05Fsd2JQUoUAGpwBYhYaf6QfjdLEe7ef6h6DIseAf6UQGMSvxbYOIzBYl+LF9tIi/yVPIgMBn272oNDRPnbgX3x0GtU5L/Klt0780KrS54jhJ2QVO/ABsEczWKFGAwEAIZ/4E05wFRwz3ay8fmeQA5+3UDQesRhAfSdAQxyYMJ'
$Code &= 'urYpAynKidFAOxp4csaRfUDkCl1Jw2bIV0TKInvWN0e/CL3kaHWAYn88CFtzgi37/zoYQO4fViZ0T5IEPInBuXIGZzgpyMJfx9V98a8gTPgkCHLgA3c4ileft+ixiFQN/MHu7kFoiSIcQXPnjeFoIZDWYSrHaEWF6Cj/zGuLWEsKKjMbMOgWJQFDCHMpdgRIA/R40DuDPmhIuhBeX6fYDlMUVxMZBWOs5Y2h705OuDwnXpk/X3+dzH7ay1ZsIyECGoM4DVVAtXg8oeAJLGCQJV6KMslRXSLZU1ZCDuqcQt3dFtFlXorb84Je4UB5jSIVkJW9aXsLQRVOKHpwjlH/0Ia3CwzQdUg6Uy40Yb9wi+o7hPQk1Uu5cploIKVc/LZtWrFEqnUbZiYjVy3uy5uGoJmX8Y4iZijzpZxQ/KfoJIVeDYdDTI3ry9Faj6CNNvqTabxF3wDcLCnYLaAYwfgKAo2Ehgot2GuBglBwRoFU6Rj5gJSOhjNWUIxsKcQMMmSMYU5sUsUYkLhDNI6/6veJmxrwyv9B8zRgGHFaHOOyS+zK5hqdcxtEGpiHE78WuabbnXFI2U5ILUf9MAj5Jw91/vA/+r8S5nRkCQHImJH5GLXhb4hpwSsrHegPSQihEetiWrLh/0ziSFkAEBqkfJk7FgOsIgLIWln/4H+wll2LgLOMgFKNgcaICTuOEbkQZo8QEpAityBEkUShyIncEZSSscMJBZMCYSTZRMGUBMWXCMuI1pkILJoIipsR1xCmnCLKIImdICqeRDOCihyfRrmjNjLPRwllJHZLWFRx4WNvcsVl1uJaf7urnhpoa5Qe8v9kPoQcWliiq70/zu31qjstnb146eaIgkDchCNOUb4j2MhGkErPYjTrtA/ZcCphTvoOf64tPhtt5o4oe2fPWGTHb2YzYmytOdcI622hkHlZSkQlOeLceW0fYm9saVd6NKKPmLZ8indl71RnZCh5JAgddCR5cCBahpFhrs76Y3ypsCCTSHSjRhsOdW5rR293VSA0I+/Ci2dPPqncSEXK3nRudxK7jHtwJHplVFyMY8aSbXCUqy/uGPWUxGjrcMAA'
EndIf
Local $Opcode = String(_ZLIB_CodeDecompress($Code))
$_ZLIB_DeflateInit =(StringInStr($Opcode, "FF01") + 1) / 2
$_ZLIB_DeflateInit2 =(StringInStr($Opcode, "FF02") + 1) / 2
$_ZLIB_Deflate =(StringInStr($Opcode, "FF03") + 1) / 2
$_ZLIB_DeflateEnd =(StringInStr($Opcode, "FF04") + 1) / 2
$_ZLIB_DeflateBound =(StringInStr($Opcode, "FF05") + 1) / 2
$_ZLIB_InflateInit =(StringInStr($Opcode, "FF21") + 1) / 2
$_ZLIB_InflateInit2 =(StringInStr($Opcode, "FF22") + 1) / 2
$_ZLIB_Inflate =(StringInStr($Opcode, "FF23") + 1) / 2
$_ZLIB_InflateEnd =(StringInStr($Opcode, "FF24") + 1) / 2
$_ZLIB_ZError =(StringInStr($Opcode, "FF61") + 1) / 2
$Opcode = Binary($Opcode)
$_ZLIB_CodeBufferMemory = _MemVirtualAlloc(0, BinaryLen($Opcode), $MEM_COMMIT, $PAGE_EXECUTE_READWRITE)
$_ZLIB_CodeBuffer = DllStructCreate("byte[" & BinaryLen($Opcode) & "]", $_ZLIB_CodeBufferMemory)
DllStructSetData($_ZLIB_CodeBuffer, 1, $Opcode)
$_ZLIB_CodeBufferPtr = DllStructGetPtr($_ZLIB_CodeBuffer)
$_ZLIB_DeflateInit = $_ZLIB_CodeBufferPtr + $_ZLIB_DeflateInit
$_ZLIB_DeflateInit2 = $_ZLIB_CodeBufferPtr + $_ZLIB_DeflateInit2
$_ZLIB_Deflate = $_ZLIB_CodeBufferPtr + $_ZLIB_Deflate
$_ZLIB_DeflateEnd = $_ZLIB_CodeBufferPtr + $_ZLIB_DeflateEnd
$_ZLIB_DeflateBound = $_ZLIB_CodeBufferPtr + $_ZLIB_DeflateBound
$_ZLIB_InflateInit = $_ZLIB_CodeBufferPtr + $_ZLIB_InflateInit
$_ZLIB_InflateInit2 = $_ZLIB_CodeBufferPtr + $_ZLIB_InflateInit2
$_ZLIB_Inflate = $_ZLIB_CodeBufferPtr + $_ZLIB_Inflate
$_ZLIB_InflateEnd = $_ZLIB_CodeBufferPtr + $_ZLIB_InflateEnd
$_ZLIB_ZError = $_ZLIB_CodeBufferPtr + $_ZLIB_ZError
$_ZLIB_Alloc_Callback = DllCallbackRegister("_ZLIB_Alloc", "ptr:cdecl", "ptr;uint;uint")
$_ZLIB_Free_Callback = DllCallbackRegister("_ZLIB_Free", "none:cdecl", "ptr;ptr")
OnAutoItExitRegister("_ZLIB_Exit")
EndIf
EndFunc
Func _ZLIB_CodeDecompress($Code)
Local $Opcode
If @AutoItX64 Then
$Opcode = '0x89C04150535657524889CE4889D7FCB28031DBA4B302E87500000073F631C9E86C000000731D31C0E8630000007324B302FFC1B010E85600000010C073F77544AAEBD3E85600000029D97510E84B000000EB2CACD1E8745711C9EB1D91FFC8C1E008ACE8340000003D007D0000730A80FC05730783F87F7704FFC1FFC141904489C0B301564889FE4829C6F3A45EEB8600D275078A1648FFC610D2C331C9FFC1E8EBFFFFFF11C9E8E4FFFFFF72F2C35A4829D7975F5E5B4158C389D24883EC08C70100000000C64104004883C408C389F64156415541544D89CC555756534C89C34883EC20410FB64104418800418B3183FE010F84AB00000073434863D24D89C54889CE488D3C114839FE0F84A50100000FB62E4883C601E8C601000083ED2B4080FD5077E2480FBEED0FB6042884C00FBED078D3C1E20241885500EB7383FE020F841C01000031C083FE03740F4883C4205B5E5F5D415C415D415EC34863D24D89C54889CE488D3C114839FE0F84CA0000000FB62E4883C601E86401000083ED2B4080FD5077E2480FBEED0FB6042884C078D683E03F410845004983C501E964FFFFFF4863D24D89C54889CE488D3C114839FE0F84E00000000FB62E4883C601E81D01000083ED2B4080FD5077E2480FBEED0FB6042884C00FBED078D389D04D8D7501C1E20483E03041885501C1F804410845004839FE747B0FB62E4883C601E8DD00000083ED2B4080FD5077E6480FBEED0FB6042884C00FBED078D789D0C1E2064D8D6E0183E03C41885601C1F8024108064839FE0F8536FFFFFF41C7042403000000410FB6450041884424044489E84883C42029D85B5E5F5D415C415D415EC34863D24889CE4D89C6488D3C114839FE758541C7042402000000410FB60641884424044489F04883C42029D85B5E5F5D415C415D415EC341C7042401000000410FB6450041884424044489E829D8E998FEFFFF41C7042400000000410FB6450041884424044489E829D8E97CFEFFFF56574889CF4889D64C89C1FCF3A45F5EC3E8500000003EFFFFFF3F3435363738393A3B3C3DFFFFFFFEFFFFFF000102030405060708090A0B0C0D0E0F10111213141516171819FFFFFFFFFFFF1A1B1C1D1E1F202122232425262728292A2B2C2D2E2F3031323358C3'
Else
$Opcode = '0x89C0608B7424248B7C2428FCB28031DBA4B302E86D00000073F631C9E864000000731C31C0E85B0000007323B30241B010E84F00000010C073F7753FAAEBD4E84D00000029D97510E842000000EB28ACD1E8744D11C9EB1C9148C1E008ACE82C0000003D007D0000730A80FC05730683F87F770241419589E8B3015689FE29C6F3A45EEB8E00D275058A164610D2C331C941E8EEFFFFFF11C9E8E7FFFFFF72F2C32B7C2428897C241C61C389D28B442404C70000000000C6400400C2100089F65557565383EC1C8B6C243C8B5424388B5C24308B7424340FB6450488028B550083FA010F84A1000000733F8B5424388D34338954240C39F30F848B0100000FB63B83C301E8CD0100008D57D580FA5077E50FBED20FB6041084C00FBED078D78B44240CC1E2028810EB6B83FA020F841201000031C083FA03740A83C41C5B5E5F5DC210008B4C24388D3433894C240C39F30F84CD0000000FB63B83C301E8740100008D57D580FA5077E50FBED20FB6041084C078DA8B54240C83E03F080283C2018954240CE96CFFFFFF8B4424388D34338944240C39F30F84D00000000FB63B83C301E82E0100008D57D580FA5077E50FBED20FB6141084D20FBEC278D78B4C240C89C283E230C1FA04C1E004081189CF83C70188410139F374750FB60383C3018844240CE8EC0000000FB654240C83EA2B80FA5077E00FBED20FB6141084D20FBEC278D289C283E23CC1FA02C1E006081739F38D57018954240C8847010F8533FFFFFFC74500030000008B4C240C0FB60188450489C82B44243883C41C5B5E5F5DC210008D34338B7C243839F3758BC74500020000000FB60788450489F82B44243883C41C5B5E5F5DC210008B54240CC74500010000000FB60288450489D02B442438E9B1FEFFFFC7450000000000EB9956578B7C240C8B7424108B4C241485C9742FFC83F9087227F7C7010000007402A449F7C702000000740566A583E90289CAC1E902F3A589D183E103F3A4EB02F3A45F5EC3E8500000003EFFFFFF3F3435363738393A3B3C3DFFFFFFFEFFFFFF000102030405060708090A0B0C0D0E0F10111213141516171819FFFFFFFFFFFF1A1B1C1D1E1F202122232425262728292A2B2C2D2E2F3031323358C3'
EndIf
Local $AP_Decompress =(StringInStr($Opcode, "89C0") - 3) / 2
Local $B64D_DecodeData =(StringInStr($Opcode, "89F6") - 3) / 2
$Opcode = Binary($Opcode)
Local $CodeBufferMemory = _MemVirtualAlloc(0, BinaryLen($Opcode), $MEM_COMMIT, $PAGE_EXECUTE_READWRITE)
Local $CodeBuffer = DllStructCreate("byte[" & BinaryLen($Opcode) & "]", $CodeBufferMemory)
DllStructSetData($CodeBuffer, 1, $Opcode)
Local $CodeBufferPtr = DllStructGetPtr($CodeBuffer)
Local $B64D_State = DllStructCreate("byte[16]")
Local $Length = StringLen($Code)
Local $Output = DllStructCreate("byte[" & $Length & "]")
DllCall($_ZLIB_USER32DLL, "int", "CallWindowProc", "ptr", $CodeBufferPtr + $B64D_DecodeData, "str", $Code, "uint", $Length, "ptr", DllStructGetPtr($Output), "ptr", DllStructGetPtr($B64D_State))
Local $ResultLen = DllStructGetData(DllStructCreate("uint", DllStructGetPtr($Output)), 1)
Local $Result = DllStructCreate("byte[" &($ResultLen + 16) & "]")
Local $Ret = DllCall("user32.dll", "uint", "CallWindowProc", "ptr", $CodeBufferPtr + $AP_Decompress, "ptr", DllStructGetPtr($Output) + 4, "ptr", DllStructGetPtr($Result), "int", 0, "int", 0)
_MemVirtualFree($CodeBufferMemory, 0, $MEM_RELEASE)
Return BinaryMid(DllStructGetData($Result, 1), 1, $Ret[0])
EndFunc
Func _ZLIB_InflateInit2($Strm, $WindowBits = $Z_MAX_WBITS)
DllStructSetData($Strm, "zalloc", DllCallbackGetPtr($_ZLIB_Alloc_Callback))
DllStructSetData($Strm, "zfree", DllCallbackGetPtr($_ZLIB_Free_Callback))
Local $Ret = DllCall($_ZLIB_USER32DLL, "int", "CallWindowProc", "ptr", $_ZLIB_InflateInit2, "ptr", DllStructGetPtr($Strm), "int", $WindowBits, "int", 0, "int", 0)
Return $Ret[0]
EndFunc
Func _ZLIB_Inflate($Strm, $Flush = $Z_NO_FLUSH)
Local $Ret = DllCall($_ZLIB_USER32DLL, "int", "CallWindowProc", "ptr", $_ZLIB_Inflate, "ptr", DllStructGetPtr($Strm), "int", $Flush, "int", 0, "int", 0)
Return $Ret[0]
EndFunc
Func _ZLIB_InflateEnd($Strm)
Local $Ret = DllCall($_ZLIB_USER32DLL, "int", "CallWindowProc", "ptr", $_ZLIB_InflateEnd, "ptr", DllStructGetPtr($Strm), "int", 0, "int", 0, "int", 0)
Return $Ret[0]
EndFunc
Func _ZLIB_UncompressCore(ByRef $Data, $WindowBits = $Z_MAX_WBITS)
If Not IsDllStruct($_ZLIB_CodeBuffer) Then _ZLIB_Startup()
Local $Stream = DllStructCreate($_ZLIB_tagZStream)
_ZLIB_InflateInit2($Stream, $WindowBits)
Local $SourceLen = BinaryLen($Data)
Local $DestLen = $SourceLen * 2
Local $Source = DllStructCreate("byte[" & $SourceLen & "]")
Local $Dest = DllStructCreate("byte[" & $DestLen & "]")
Local $DestPtr = DllStructGetPtr($Dest)
DllStructSetData($Source, 1, $Data)
DllStructSetData($Stream, "next_in", DllStructGetPtr($Source))
DllStructSetData($Stream, "avail_in", $SourceLen)
Local $Ret = Binary("")
Do
DllStructSetData($Stream, "next_out", $DestPtr)
DllStructSetData($Stream, "avail_out", $DestLen)
Local $Error = _ZLIB_Inflate($Stream, $Z_NO_FLUSH)
If $Error = $Z_NEED_DICT Then $Error = $Z_DATA_ERROR
If $Error < 0 Then
_ZLIB_InflateEnd($Stream)
Return SetError($Error, 0, $Ret)
EndIf
Local $AvailOut = DllStructGetData($Stream, "avail_out")
Local $Got = $DestLen - $AvailOut
$Ret &= BinaryMid(DllStructGetData($Dest, 1), 1, $Got)
Until $AvailOut <> 0
_ZLIB_InflateEnd($Stream)
Return $Ret
EndFunc
Func _ZLIB_Uncompress($Data)
Local $Ret = _ZLIB_UncompressCore($Data, $Z_MAX_WBITS)
Return SetError(@Error, 0, $Ret)
EndFunc
Global Const $MM_VERSION_NUMBER = "0.93.8.0"
Global Const $MM_VERSION_SUBTYPE = "beta"
Global Const $MM_VERSION_NAME = "Dreaded Still"
Global Const $MM_VERSION = $MM_VERSION_SUBTYPE == "release" ? $MM_VERSION_NUMBER :($MM_VERSION_NUMBER & "." & $MM_VERSION_SUBTYPE)
Global Const $MM_TITLE = StringFormat("Era II Mod Manager [%s - %s]", $MM_VERSION, $MM_VERSION_NAME)
Global Const $MM_WINDOW_MIN_WIDTH = 800
Global Const $MM_WINDOW_MIN_HEIGHT = 494
Global Const $MM_DATA_DIRECTORY = @ScriptDir
Global Const $MM_SCN_DIRECTORY = $MM_DATA_DIRECTORY & "\Presets"
Global Const $MM_SETTINGS_PATH = $MM_DATA_DIRECTORY & "\settings.json"
Global Const $MM_WOG_OPTIONS_FILE = "WoGSetupMM.dat"
Global Enum $MM_VIEW_MODS, $MM_VIEW_PLUGINS, $MM_VIEW_INSTALL, $MM_VIEW_BIG_SCREEN, $MM_VIEW_SCN, $MM_VIEW_TOTAL
Global Enum $MM_SUBVIEW_DESC, $MM_SUBVIEW_INFO, $MM_SUBVIEW_SCREENS, $MM_SUBVIEW_BLANK, $MM_SUBVIEW_TOTAL
Global Enum $PLUGIN_GROUP_GLOBAL, $PLUGIN_GROUP_BEFORE, $PLUGIN_GROUP_AFTER
Global Enum $PLUGIN_FILENAME, $PLUGIN_PATH, $PLUGIN_GROUP, $PLUGIN_CAPTION, $PLUGIN_DESCRIPTION, $PLUGIN_STATE, $PLUGIN_DEFAULT_STATE, $PLUGIN_TOTAL
Global Enum $MOD_ID, $MOD_CAPTION, $MOD_IS_ENABLED, $MOD_IS_EXIST, $MOD_ITEM_ID, $MOD_PARENT_ID, $MOD_TOTAL
Global Enum $MM_LNG_FILE, $MM_LNG_CODE, $MM_LNG_NAME, $MM_LNG_MENU_ID, $MM_LNG_TOTAL
Global $MM_GAME_DIR = _PathFull($MM_DATA_DIRECTORY & "\..\..")
Global $MM_LIST_DIR_PATH = $MM_GAME_DIR & "\Mods"
Global $MM_LIST_FILE_PATH = $MM_LIST_DIR_PATH & "\list.txt"
Global $MM_GAME_EXE = "h3era.exe"
Global $MM_SETTINGS_LANGUAGE = "english.json"
Global $MM_LANGUAGE_CODE = "en_US"
Global $MM_WINDOW_WIDTH = $MM_WINDOW_MIN_WIDTH
Global $MM_WINDOW_HEIGHT = $MM_WINDOW_MIN_HEIGHT
Global $MM_WINDOW_MAXIMIZED = False
Global $MM_WINDOW_MIN_WIDTH_FULL
Global $MM_WINDOW_MIN_HEIGHT_FULL
Global $MM_WINDOW_CLIENT_WIDTH, $MM_WINDOW_CLIENT_HEIGHT
Global $MM_LNG_LIST[1][$MM_LNG_TOTAL]
Global $MM_VIEW_CURRENT, $MM_SUBVIEW_CURRENT, $MM_VIEW_PREV, $MM_SUBVIEW_PREV
Global $MM_LIST_CANT_WORK = False
Global $MM_PLUGINS_CONTENT[1][$PLUGIN_TOTAL]
Global $MM_PLUGINS_PART_PRESENT[3]
Global $MM_COMPATIBILITY_MESSAGE = ""
Global $MM_UI_MAIN
Func SFX_FileOpen(Const $sPath)
Local $aResult = DllCall("kernel32.dll", "ptr", "BeginUpdateResourceW", "wstr", $sPath, "int", 0)
If Not @error And IsArray($aResult) Then Return $aResult[0]
EndFunc
Func SFX_FileClose(Const $hFile)
Local $aResult = DllCall("kernel32.dll", "int", "EndUpdateResourceW", "ptr", $hFile, "int", 0)
If Not @error And IsArray($aResult) Then Return $aResult[0]
EndFunc
Func SFX_UpdateIcon(Const $hFile, Const $sIconPath)
Local $hIcon = _WinAPI_CreateFile($sIconPath, 2, 2)
If Not $hIcon Then Return SetError(1, 0, 1)
Local $tSize = FileGetSize($sIconPath), $iRead
Local $tI_Input_Header = DllStructCreate("word Res;word Type;word ImageCount;byte rest[" & $tSize - 6 & "]")
_WinAPI_ReadFile($hIcon, DllStructGetPtr($tI_Input_Header), $tSize, $iRead, 0)
If $hIcon Then _WinAPI_CloseHandle($hIcon)
Local $iIconType = DllStructGetData($tI_Input_Header, "Type")
Local $iIconCount = DllStructGetData($tI_Input_Header, "ImageCount")
Local $tB_IconGroupHeader = DllStructCreate("align 2;word res;word type;word ImageCount;byte rest[" & $iIconCount * 14 & "]")
Local $pB_IconGroupHeader = DllStructGetPtr($tB_IconGroupHeader)
DllStructSetData($tB_IconGroupHeader, "Res", 0)
DllStructSetData($tB_IconGroupHeader, "Type", $iIconType)
DllStructSetData($tB_IconGroupHeader, "ImageCount", $iIconCount)
For $x = 1 To $iIconCount
Local $pB_Input_IconHeader = DllStructGetPtr($tI_Input_Header, "rest") +($x - 1) * 16
Local $tB_Input_IconHeader = DllStructCreate("byte Width;byte Height;byte Colors;byte res;word Planes;word BitsPerPixel;dword ImageSize;dword ImageOffset", $pB_Input_IconHeader)
Local $IconWidth = DllStructGetData($tB_Input_IconHeader, "Width")
Local $IconHeight = DllStructGetData($tB_Input_IconHeader, "Height")
Local $IconColors = DllStructGetData($tB_Input_IconHeader, "Colors")
Local $IconPlanes = DllStructGetData($tB_Input_IconHeader, "Planes")
Local $IconBitsPerPixel = DllStructGetData($tB_Input_IconHeader, "BitsPerPixel")
Local $IconImageSize = DllStructGetData($tB_Input_IconHeader, "ImageSize")
Local $IconImageOffset = DllStructGetData($tB_Input_IconHeader, "ImageOffset")
$pB_IconGroupHeader = DllStructGetPtr($tB_IconGroupHeader, "rest") +($x - 1) * 14
Local $tB_GroupIcon = DllStructCreate("align 2;byte Width;byte Height;byte Colors;byte res;word Planes;word BitsPerPixel;dword ImageSize;word ResourceID", $pB_IconGroupHeader)
DllStructSetData($tB_GroupIcon, "Width", $IconWidth)
DllStructSetData($tB_GroupIcon, "Height", $IconHeight)
DllStructSetData($tB_GroupIcon, "Colors", $IconColors)
DllStructSetData($tB_GroupIcon, "Res", 0)
DllStructSetData($tB_GroupIcon, "Planes", $IconPlanes)
DllStructSetData($tB_GroupIcon, "BitsPerPixel", $IconBitsPerPixel)
DllStructSetData($tB_GroupIcon, "ImageSize", $IconImageSize)
DllStructSetData($tB_GroupIcon, "ResourceID", 1)
Local $pB_IconData = DllStructGetPtr($tI_Input_Header) + $IconImageOffset
DllCall("kernel32.dll", "int", "UpdateResourceW", "ptr", $hFile, "long", 3, "long", 1, "ushort", 1033, "ptr", $pB_IconData, "dword", $IconImageSize)
Next
$pB_IconGroupHeader = DllStructGetPtr($tB_IconGroupHeader)
DllCall("kernel32.dll", "int", "UpdateResourceW", "ptr", $hFile, "long", 14, "long", 1, "ushort", 1033, "ptr", $pB_IconGroupHeader, "dword", DllStructGetSize($tB_IconGroupHeader))
EndFunc
Func SFX_UpdateModDirName(Const $hFile, $sDirectoryName)
$sDirectoryName = '"' & $sDirectoryName & '"'
Local $sStruct = StringFormat("word;wchar[%i];word;word;word;word;word;word;word;word;word;word;word;word;word;word;word;", StringLen($sDirectoryName))
Local $oStruct = DllStructCreate($sStruct)
DllStructSetData($oStruct, 1, StringLen($sDirectoryName))
DllStructSetData($oStruct, 2, $sDirectoryName)
For $i = 3 To 3 + 14
DllStructSetData($oStruct, $i, 0)
Next
Local $tSize = DllStructGetSize($oStruct)
Local $pBuffer = DllStructGetPtr($oStruct)
DllCall("kernel32.dll", "int", "UpdateResourceW", "ptr", $hFile, "long", 6, "long", 251, "ushort", 1033, "ptr", $pBuffer, "dword", $tSize)
EndFunc
Func _StringRepeat($sString, $iRepeatCount)
$iRepeatCount = Int($iRepeatCount)
If $iRepeatCount = 0 Then Return ""
If StringLen($sString) < 1 Or $iRepeatCount < 0 Then Return SetError(1, 0, "")
Local $sResult = ""
While $iRepeatCount > 1
If BitAND($iRepeatCount, 1) Then $sResult &= $sString
$sString &= $sString
$iRepeatCount = BitShift($iRepeatCount, 1)
WEnd
Return $sString & $sResult
EndFunc
Global $__T_POINT = TimerInit()
Global $_TRACE[1][2]
Func _TracePrint(Const $sToPrint)
If IsDeclared("__DEBUG") Then ConsoleWrite(_StringRepeat(" ", $_TRACE[0][0]) & $sToPrint & @CRLF)
If IsDeclared("__DEBUG_TO_FILE") Then FileWriteLine(@ScriptDir & "\debug0.log", _StringRepeat(" ", $_TRACE[0][0]) & $sToPrint)
EndFunc
Func _Trace(Const $sToPrint = StringFormat("Called from %i line", @ScriptLineNumber), Const $sEmoji = "!!")
If Not IsDeclared("__DEBUG") And Not IsDeclared("__DEBUG_TO_FILE") Then Return
Local $iEndTime = Int(TimerDiff($__T_POINT))
$__T_POINT = TimerInit()
_TracePrint(StringFormat("%s (%s)\t%s msec later (%s memory)", $sToPrint, $sEmoji, $iEndTime, ProcessGetStats()[0]/1024))
Return $__T_POINT
EndFunc
Func _TraceStart(Const $sToPrint = StringFormat("Called from %i line", @ScriptLineNumber))
If Not IsDeclared("__DEBUG") And Not IsDeclared("__DEBUG_TO_FILE") Then Return
$_TRACE[0][0] += 1
If UBound($_TRACE) <= $_TRACE[0][0] Then ReDim $_TRACE[$_TRACE[0][0] * 2][2]
$_TRACE[$_TRACE[0][0]][0] = $sToPrint
$_TRACE[$_TRACE[0][0]][1] = _Trace($sToPrint, "->")
EndFunc
Func _TraceEnd()
If Not IsDeclared("__DEBUG") And Not IsDeclared("__DEBUG_TO_FILE") Then Return
If $_TRACE[0][0] = 0 Then Return
Local $iEndTime = Int(TimerDiff($_TRACE[$_TRACE[0][0]][1]))
_Trace($_TRACE[$_TRACE[0][0]][0], "<-")
_TracePrint(StringFormat("%s (%s)\t%s msec total (%s memory)", $_TRACE[$_TRACE[0][0]][0], "==", $iEndTime, ProcessGetStats()[0]/1024))
$_TRACE[0][0] -= 1
EndFunc
Global $__MM_UTILS_VIEWS[1]
Func Utils_LaunchInBrowser(Const $sLink)
Local Const $http = "http://"
Local Const $https = "https://"
If StringLeft($sLink, StringLen($http)) == $http Or StringLeft($sLink, StringLen($https)) == $https Then
ShellExecute($sLink)
Else
ShellExecute($http & $sLink)
EndIf
EndFunc
Func Utils_OpenFolder(Const $sFolder, Const $sFile)
ShellExecute("explorer.exe", "/select," & $sFile, $sFolder)
EndFunc
Func MapEmpty()
Local $mMap[]
Return $mMap
EndFunc
Func ArrayEmpty(Const $iDim = 1)
Switch $iDim
Case 1
Local $Array[1] = [0]
Case 2
Local $Array[1][1] = [[0]]
EndSwitch
Return $Array
EndFunc
Func ArraySimple(Const $iItem1, Const $iItem2 = Null, Const $iItem3 = Null)
Local $Array[1] = [$iItem1]
If $iItem2 <> Null Then _ArrayAdd($Array, $iItem2)
If $iItem3 <> Null Then _ArrayAdd($Array, $iItem3)
Return $Array
EndFunc
Func VersionCompare(Const $s1, Const $s2)
Local $aVersion1 = StringSplit($s1, ".", 2)
Local $aVersion2 = StringSplit($s2, ".", 2)
Local $iSize = UBound($aVersion1) > UBound($aVersion2) ? UBound($aVersion1) : UBound($aVersion2)
ReDim $aVersion1[$iSize]
ReDim $aVersion2[$iSize]
For $i = 0 To $iSize - 1
If Int($aVersion1[$i]) > Int($aVersion2[$i]) Then
Return $i+1
ElseIf Int($aVersion1[$i]) < Int($aVersion2[$i]) Then
Return -($i+1)
EndIf
Next
Return 0
EndFunc
Func VersionIncrement(Const $sVersion)
Local $aVersion = StringSplit($sVersion, ".", 2)
$aVersion[UBound($aVersion) - 1] += 1
Return _ArrayToString($aVersion, ".")
EndFunc
Func GUICtrlGetPos(Const $idControl)
Local $aAnswer, $mMap[]
If IsHWnd($idControl) Then
$aAnswer = ControlGetPos($idControl, '', 0)
Else
$aAnswer = ControlGetPos(GUICtrlGetHandle($idControl), '', 0)
EndIf
If IsArray($aAnswer) Then
$mMap.Left = $aAnswer[0]
$mMap.Top = $aAnswer[1]
$mMap.Width = $aAnswer[2]
$mMap.Height = $aAnswer[3]
Else
$mMap.Left = 0
$mMap.Top = 0
$mMap.Width = 0
$mMap.Height = 0
EndIf
$mMap.NextX = $mMap.Left + $mMap.Width
$mMap.NextY = $mMap.Top + $mMap.Height
Return $mMap
EndFunc
Func GUIRegisterMsgStateful(Const $iMessage, Const ByRef $sFuncName)
Local Static $mRegistered = MapEmpty()
If Not MapExists($mRegistered, $iMessage) And $sFuncName == "" Then Return
If Not MapExists($mRegistered, $iMessage) And $sFuncName <> "" Then $mRegistered[$iMessage] = ArrayEmpty()
Local $aList = $mRegistered[$iMessage]
GUIRegisterMsg($iMessage, $sFuncName)
If $sFuncName <> "" Then
$aList[0] += 1
If UBound($aList) <= $aList[0] Then ReDim $aList[$aList[0] + 1]
$aList[$aList[0]] = $sFuncName
Else
$aList[0] -= 1
If $aList[0] <> 0 Then GUIRegisterMsg($iMessage, $aList[$aList[0]])
EndIf
If $aList[0] <> 0 Then
$mRegistered[$iMessage] = $aList
Else
MapRemove($mRegistered, $iMessage)
EndIf
EndFunc
Func MM_GUICreate(Const $sTitle = "", Const $iWidth = Default, Const $iHeight = Default, Const $iLeft = Default, Const $iTop = Default, Const $iStyle = Default, Const $iExStyle = Default)
_ArrayAdd($__MM_UTILS_VIEWS, GUICreate($sTitle, $iWidth, $iHeight, $iLeft, $iTop, $iStyle, $iExStyle, $__MM_UTILS_VIEWS[0] > 0 ? $__MM_UTILS_VIEWS[$__MM_UTILS_VIEWS[0]] : 0))
$__MM_UTILS_VIEWS[0] += 1
Return MM_GetCurrentWindow()
EndFunc
Func MM_GetCurrentWindow()
Return $__MM_UTILS_VIEWS[$__MM_UTILS_VIEWS[0]]
EndFunc
Func MM_GUIDelete()
GUIDelete($__MM_UTILS_VIEWS[$__MM_UTILS_VIEWS[0]])
$__MM_UTILS_VIEWS[0] -= 1
ReDim $__MM_UTILS_VIEWS[$__MM_UTILS_VIEWS[0] + 1]
EndFunc
Func Utils_InnoLangToMM(Const $sInnoLng)
Return $sInnoLng & ".json"
EndFunc
Func Utils_FilterFileName($sFileName)
Return StringRegExpReplace($sFileName, "[\\\/:*?""<>|]", "_")
EndFunc
Global $MM_LNG_CACHE
Func Lng_Load()
Local $sText = FileRead(@ScriptDir & "\lng\" & $MM_SETTINGS_LANGUAGE)
If @error Then Return SetError(1, @extended, "Can't read .\lng\" & $MM_SETTINGS_LANGUAGE)
$MM_LNG_CACHE = Jsmn_Decode($sText)
__Lng_Validate()
$MM_LANGUAGE_CODE = IsMap($MM_LNG_CACHE) ?(IsMap($MM_LNG_CACHE["lang"]) ? $MM_LNG_CACHE["lang"]["code"] : "fail") : "fail"
Return SetError(0, 0, "")
EndFunc
Func __Lng_Validate()
If Not IsMap($MM_LNG_CACHE) Then $MM_LNG_CACHE = MapEmpty()
If Not MapExists($MM_LNG_CACHE, "lang") Or Not IsMap($MM_LNG_CACHE["lang"]) Then $MM_LNG_CACHE["lang"] = MapEmpty()
If Not MapExists($MM_LNG_CACHE["lang"], "code") Or Not IsString($MM_LNG_CACHE["lang"]["code"]) Then $MM_LNG_CACHE["lang"]["code"] = "en_US"
If Not MapExists($MM_LNG_CACHE["lang"], "name") Or Not IsString($MM_LNG_CACHE["lang"]["name"]) Then $MM_LNG_CACHE["lang"]["name"] = "English"
If Not MapExists($MM_LNG_CACHE["lang"], "author") Or Not IsString($MM_LNG_CACHE["lang"]["author"]) Then $MM_LNG_CACHE["lang"]["author"] = "Aliaksei SyDr Karalenka"
If Not MapExists($MM_LNG_CACHE["lang"], "language") Or Not IsString($MM_LNG_CACHE["lang"]["language"]) Then $MM_LNG_CACHE["lang"]["language"] = "Language"
If Not MapExists($MM_LNG_CACHE, "mod_list") Or Not IsMap($MM_LNG_CACHE["mod_list"]) Then $MM_LNG_CACHE["mod_list"] = MapEmpty()
If Not MapExists($MM_LNG_CACHE["mod_list"], "mod") Or Not IsString($MM_LNG_CACHE["mod_list"]["mod"]) Then $MM_LNG_CACHE["mod_list"]["mod"] = "Mod"
If Not MapExists($MM_LNG_CACHE["mod_list"], "caption") Or Not IsString($MM_LNG_CACHE["mod_list"]["caption"]) Then $MM_LNG_CACHE["mod_list"]["caption"] = "Mod list (%s)"
If Not MapExists($MM_LNG_CACHE["mod_list"], "no_game_dir") Or Not IsString($MM_LNG_CACHE["mod_list"]["no_game_dir"]) Then $MM_LNG_CACHE["mod_list"]["no_game_dir"] = "no game dir - select from ""Tools"""
If Not MapExists($MM_LNG_CACHE["mod_list"], "up") Or Not IsString($MM_LNG_CACHE["mod_list"]["up"]) Then $MM_LNG_CACHE["mod_list"]["up"] = "Move up"
If Not MapExists($MM_LNG_CACHE["mod_list"], "down") Or Not IsString($MM_LNG_CACHE["mod_list"]["down"]) Then $MM_LNG_CACHE["mod_list"]["down"] = "Move down"
If Not MapExists($MM_LNG_CACHE["mod_list"], "enable") Or Not IsString($MM_LNG_CACHE["mod_list"]["enable"]) Then $MM_LNG_CACHE["mod_list"]["enable"] = "Enable"
If Not MapExists($MM_LNG_CACHE["mod_list"], "disable") Or Not IsString($MM_LNG_CACHE["mod_list"]["disable"]) Then $MM_LNG_CACHE["mod_list"]["disable"] = "Disable"
If Not MapExists($MM_LNG_CACHE["mod_list"], "missing") Or Not IsString($MM_LNG_CACHE["mod_list"]["missing"]) Then $MM_LNG_CACHE["mod_list"]["missing"] = "%s (missing mod)"
If Not MapExists($MM_LNG_CACHE["mod_list"], "remove") Or Not IsString($MM_LNG_CACHE["mod_list"]["remove"]) Then $MM_LNG_CACHE["mod_list"]["remove"] = "Remove"
If Not MapExists($MM_LNG_CACHE["mod_list"], "group") Or Not IsMap($MM_LNG_CACHE["mod_list"]["group"]) Then $MM_LNG_CACHE["mod_list"]["group"] = MapEmpty()
If Not MapExists($MM_LNG_CACHE["mod_list"]["group"], "enabled") Or Not IsString($MM_LNG_CACHE["mod_list"]["group"]["enabled"]) Then $MM_LNG_CACHE["mod_list"]["group"]["enabled"] = "Enabled"
If Not MapExists($MM_LNG_CACHE["mod_list"]["group"], "enabled_with_priority") Or Not IsString($MM_LNG_CACHE["mod_list"]["group"]["enabled_with_priority"]) Then $MM_LNG_CACHE["mod_list"]["group"]["enabled_with_priority"] = "Enabled (%+i)"
If Not MapExists($MM_LNG_CACHE["mod_list"]["group"], "disabled") Or Not IsString($MM_LNG_CACHE["mod_list"]["group"]["disabled"]) Then $MM_LNG_CACHE["mod_list"]["group"]["disabled"] = "Without category"
If Not MapExists($MM_LNG_CACHE["mod_list"]["group"], "disabled_group") Or Not IsString($MM_LNG_CACHE["mod_list"]["group"]["disabled_group"]) Then $MM_LNG_CACHE["mod_list"]["group"]["disabled_group"] = "%s"
If Not MapExists($MM_LNG_CACHE["mod_list"], "list_inaccessible") Or Not IsString($MM_LNG_CACHE["mod_list"]["list_inaccessible"]) Then $MM_LNG_CACHE["mod_list"]["list_inaccessible"] = ""
If Not MapExists($MM_LNG_CACHE["mod_list"], "plugins") Or Not IsString($MM_LNG_CACHE["mod_list"]["plugins"]) Then $MM_LNG_CACHE["mod_list"]["plugins"] = "Plugins"
If Not MapExists($MM_LNG_CACHE["mod_list"], "homepage") Or Not IsString($MM_LNG_CACHE["mod_list"]["homepage"]) Then $MM_LNG_CACHE["mod_list"]["homepage"] = "Go to webpage"
If Not MapExists($MM_LNG_CACHE["mod_list"], "delete") Or Not IsString($MM_LNG_CACHE["mod_list"]["delete"]) Then $MM_LNG_CACHE["mod_list"]["delete"] = "Delete"
If Not MapExists($MM_LNG_CACHE["mod_list"], "delete_confirm") Or Not IsString($MM_LNG_CACHE["mod_list"]["delete_confirm"]) Then $MM_LNG_CACHE["mod_list"]["delete_confirm"] = "Do you really want to delete this mod? \n%s\n\n(The mod will be moved to recycle bin, if it's possible))"
If Not MapExists($MM_LNG_CACHE["mod_list"], "add_new") Or Not IsString($MM_LNG_CACHE["mod_list"]["add_new"]) Then $MM_LNG_CACHE["mod_list"]["add_new"] = "Add new mod(s)"
If Not MapExists($MM_LNG_CACHE["mod_list"], "compatibility") Or Not IsString($MM_LNG_CACHE["mod_list"]["compatibility"]) Then $MM_LNG_CACHE["mod_list"]["compatibility"] = "Compatibility"
If Not MapExists($MM_LNG_CACHE["mod_list"], "open_dir") Or Not IsString($MM_LNG_CACHE["mod_list"]["open_dir"]) Then $MM_LNG_CACHE["mod_list"]["open_dir"] = "Open mod directory"
If Not MapExists($MM_LNG_CACHE["mod_list"], "edit_mod") Or Not IsString($MM_LNG_CACHE["mod_list"]["edit_mod"]) Then $MM_LNG_CACHE["mod_list"]["edit_mod"] = "Edit mod data"
If Not MapExists($MM_LNG_CACHE["mod_list"], "pack_mod") Or Not IsString($MM_LNG_CACHE["mod_list"]["pack_mod"]) Then $MM_LNG_CACHE["mod_list"]["pack_mod"] = "Create self-extracting package"
If Not MapExists($MM_LNG_CACHE["mod_list"], "pack_mod_hint") Or Not IsString($MM_LNG_CACHE["mod_list"]["pack_mod_hint"]) Then $MM_LNG_CACHE["mod_list"]["pack_mod_hint"] = "Package will be created in background. You can continue to use MM or even close it. \n\nClose 7z console window to cancel package creation (you need then to delete created file). When 7z window disaapear - it safe to use created file."
If Not MapExists($MM_LNG_CACHE, "scenarios") Or Not IsMap($MM_LNG_CACHE["scenarios"]) Then $MM_LNG_CACHE["scenarios"] = MapEmpty()
If Not MapExists($MM_LNG_CACHE["scenarios"], "caption") Or Not IsString($MM_LNG_CACHE["scenarios"]["caption"]) Then $MM_LNG_CACHE["scenarios"]["caption"] = "Presets"
If Not MapExists($MM_LNG_CACHE["scenarios"], "manage") Or Not IsString($MM_LNG_CACHE["scenarios"]["manage"]) Then $MM_LNG_CACHE["scenarios"]["manage"] = "Manage"
If Not MapExists($MM_LNG_CACHE["scenarios"], "save") Or Not IsString($MM_LNG_CACHE["scenarios"]["save"]) Then $MM_LNG_CACHE["scenarios"]["save"] = "Save"
If Not MapExists($MM_LNG_CACHE["scenarios"], "save_menu") Or Not IsString($MM_LNG_CACHE["scenarios"]["save_menu"]) Then $MM_LNG_CACHE["scenarios"]["save_menu"] = "Save (%s)"
If Not MapExists($MM_LNG_CACHE["scenarios"], "load") Or Not IsString($MM_LNG_CACHE["scenarios"]["load"]) Then $MM_LNG_CACHE["scenarios"]["load"] = "Load"
If Not MapExists($MM_LNG_CACHE["scenarios"], "delete") Or Not IsString($MM_LNG_CACHE["scenarios"]["delete"]) Then $MM_LNG_CACHE["scenarios"]["delete"] = "Delete"
If Not MapExists($MM_LNG_CACHE["scenarios"], "special") Or Not IsString($MM_LNG_CACHE["scenarios"]["special"]) Then $MM_LNG_CACHE["scenarios"]["special"] = "Special"
If Not MapExists($MM_LNG_CACHE["scenarios"], "new") Or Not IsString($MM_LNG_CACHE["scenarios"]["new"]) Then $MM_LNG_CACHE["scenarios"]["new"] = "New"
If Not MapExists($MM_LNG_CACHE["scenarios"], "all") Or Not IsString($MM_LNG_CACHE["scenarios"]["all"]) Then $MM_LNG_CACHE["scenarios"]["all"] = "All"
If Not MapExists($MM_LNG_CACHE["scenarios"], "delete_confirm") Or Not IsString($MM_LNG_CACHE["scenarios"]["delete_confirm"]) Then $MM_LNG_CACHE["scenarios"]["delete_confirm"] = "Do you really want to delete this preset? \n%s\n\n(The preset file will be moved to recycle bin, if it's possible))"
If Not MapExists($MM_LNG_CACHE["scenarios"], "load_options") Or Not IsMap($MM_LNG_CACHE["scenarios"]["load_options"]) Then $MM_LNG_CACHE["scenarios"]["load_options"] = MapEmpty()
If Not MapExists($MM_LNG_CACHE["scenarios"]["load_options"], "caption") Or Not IsString($MM_LNG_CACHE["scenarios"]["load_options"]["caption"]) Then $MM_LNG_CACHE["scenarios"]["load_options"]["caption"] = "Select load options"
If Not MapExists($MM_LNG_CACHE["scenarios"]["load_options"], "exe") Or Not IsString($MM_LNG_CACHE["scenarios"]["load_options"]["exe"]) Then $MM_LNG_CACHE["scenarios"]["load_options"]["exe"] = "Set starting exe to ""%s"""
If Not MapExists($MM_LNG_CACHE["scenarios"]["load_options"], "wog_settings") Or Not IsString($MM_LNG_CACHE["scenarios"]["load_options"]["wog_settings"]) Then $MM_LNG_CACHE["scenarios"]["load_options"]["wog_settings"] = "Set WoG settings to stored in preset"
If Not MapExists($MM_LNG_CACHE["scenarios"]["load_options"], "not_again") Or Not IsString($MM_LNG_CACHE["scenarios"]["load_options"]["not_again"]) Then $MM_LNG_CACHE["scenarios"]["load_options"]["not_again"] = "Don't ask again (you can also hold Shift to show this window)"
If Not MapExists($MM_LNG_CACHE["scenarios"], "save_options") Or Not IsMap($MM_LNG_CACHE["scenarios"]["save_options"]) Then $MM_LNG_CACHE["scenarios"]["save_options"] = MapEmpty()
If Not MapExists($MM_LNG_CACHE["scenarios"]["save_options"], "caption") Or Not IsString($MM_LNG_CACHE["scenarios"]["save_options"]["caption"]) Then $MM_LNG_CACHE["scenarios"]["save_options"]["caption"] = "Select save options"
If Not MapExists($MM_LNG_CACHE["scenarios"]["save_options"], "exe") Or Not IsString($MM_LNG_CACHE["scenarios"]["save_options"]["exe"]) Then $MM_LNG_CACHE["scenarios"]["save_options"]["exe"] = "Save starting exe to preset"
If Not MapExists($MM_LNG_CACHE["scenarios"]["save_options"], "wog_settings") Or Not IsString($MM_LNG_CACHE["scenarios"]["save_options"]["wog_settings"]) Then $MM_LNG_CACHE["scenarios"]["save_options"]["wog_settings"] = "Save WoG settings to preset"
If Not MapExists($MM_LNG_CACHE["scenarios"]["save_options"], "select_file") Or Not IsString($MM_LNG_CACHE["scenarios"]["save_options"]["select_file"]) Then $MM_LNG_CACHE["scenarios"]["save_options"]["select_file"] = "Select file to save"
If Not MapExists($MM_LNG_CACHE["scenarios"]["save_options"], "select_filter") Or Not IsString($MM_LNG_CACHE["scenarios"]["save_options"]["select_filter"]) Then $MM_LNG_CACHE["scenarios"]["save_options"]["select_filter"] = "JSON files (*.json)"
If Not MapExists($MM_LNG_CACHE["scenarios"], "import") Or Not IsMap($MM_LNG_CACHE["scenarios"]["import"]) Then $MM_LNG_CACHE["scenarios"]["import"] = MapEmpty()
If Not MapExists($MM_LNG_CACHE["scenarios"]["import"], "caption") Or Not IsString($MM_LNG_CACHE["scenarios"]["import"]["caption"]) Then $MM_LNG_CACHE["scenarios"]["import"]["caption"] = "Import"
If Not MapExists($MM_LNG_CACHE["scenarios"]["import"], "only_load") Or Not IsString($MM_LNG_CACHE["scenarios"]["import"]["only_load"]) Then $MM_LNG_CACHE["scenarios"]["import"]["only_load"] = "Only load. Don't save"
If Not MapExists($MM_LNG_CACHE["scenarios"]["import"], "not_valid") Or Not IsString($MM_LNG_CACHE["scenarios"]["import"]["not_valid"]) Then $MM_LNG_CACHE["scenarios"]["import"]["not_valid"] = "Can't import this preset"
If Not MapExists($MM_LNG_CACHE["scenarios"]["import"], "replace") Or Not IsString($MM_LNG_CACHE["scenarios"]["import"]["replace"]) Then $MM_LNG_CACHE["scenarios"]["import"]["replace"] = "Preset with same name already exist. Replace?"
If Not MapExists($MM_LNG_CACHE["scenarios"], "export") Or Not IsMap($MM_LNG_CACHE["scenarios"]["export"]) Then $MM_LNG_CACHE["scenarios"]["export"] = MapEmpty()
If Not MapExists($MM_LNG_CACHE["scenarios"]["export"], "caption") Or Not IsString($MM_LNG_CACHE["scenarios"]["export"]["caption"]) Then $MM_LNG_CACHE["scenarios"]["export"]["caption"] = "Export"
If Not MapExists($MM_LNG_CACHE["scenarios"]["export"], "copy") Or Not IsString($MM_LNG_CACHE["scenarios"]["export"]["copy"]) Then $MM_LNG_CACHE["scenarios"]["export"]["copy"] = "Copy"
If Not MapExists($MM_LNG_CACHE["scenarios"]["export"], "name") Or Not IsString($MM_LNG_CACHE["scenarios"]["export"]["name"]) Then $MM_LNG_CACHE["scenarios"]["export"]["name"] = "Export name"
If Not MapExists($MM_LNG_CACHE, "game") Or Not IsMap($MM_LNG_CACHE["game"]) Then $MM_LNG_CACHE["game"] = MapEmpty()
If Not MapExists($MM_LNG_CACHE["game"], "caption") Or Not IsString($MM_LNG_CACHE["game"]["caption"]) Then $MM_LNG_CACHE["game"]["caption"] = "Game"
If Not MapExists($MM_LNG_CACHE["game"], "launch") Or Not IsString($MM_LNG_CACHE["game"]["launch"]) Then $MM_LNG_CACHE["game"]["launch"] = "Launch (%s)"
If Not MapExists($MM_LNG_CACHE["game"], "change") Or Not IsString($MM_LNG_CACHE["game"]["change"]) Then $MM_LNG_CACHE["game"]["change"] = "Change exe"
If Not MapExists($MM_LNG_CACHE["game"], "wog_options") Or Not IsString($MM_LNG_CACHE["game"]["wog_options"]) Then $MM_LNG_CACHE["game"]["wog_options"] = "Change WoG options"
If Not MapExists($MM_LNG_CACHE, "wog_options") Or Not IsMap($MM_LNG_CACHE["wog_options"]) Then $MM_LNG_CACHE["wog_options"] = MapEmpty()
If Not MapExists($MM_LNG_CACHE["wog_options"], "caption") Or Not IsString($MM_LNG_CACHE["wog_options"]["caption"]) Then $MM_LNG_CACHE["wog_options"]["caption"] = "WoG Options"
If Not MapExists($MM_LNG_CACHE["wog_options"], "loading") Or Not IsString($MM_LNG_CACHE["wog_options"]["loading"]) Then $MM_LNG_CACHE["wog_options"]["loading"] = "Please, wait..."
If Not MapExists($MM_LNG_CACHE["wog_options"], "loading_text") Or Not IsString($MM_LNG_CACHE["wog_options"]["loading_text"]) Then $MM_LNG_CACHE["wog_options"]["loading_text"] = "this will take only few seconds"
If Not MapExists($MM_LNG_CACHE["wog_options"], "bad_data") Or Not IsString($MM_LNG_CACHE["wog_options"]["bad_data"]) Then $MM_LNG_CACHE["wog_options"]["bad_data"] = "Can't load WoG options data. Check: \r\n\r\n1) Mod list (there should be mod with zsetup00.txt, usually WoG or WoG Revised) \r\n2) You have this mod installed"
If Not MapExists($MM_LNG_CACHE["wog_options"], "save") Or Not IsString($MM_LNG_CACHE["wog_options"]["save"]) Then $MM_LNG_CACHE["wog_options"]["save"] = "Save"
If Not MapExists($MM_LNG_CACHE["wog_options"], "select_filter") Or Not IsString($MM_LNG_CACHE["wog_options"]["select_filter"]) Then $MM_LNG_CACHE["wog_options"]["select_filter"] = "DAT files (*.dat)|WOG files (*.wog)|All files (*.*)"
If Not MapExists($MM_LNG_CACHE["wog_options"], "load") Or Not IsString($MM_LNG_CACHE["wog_options"]["load"]) Then $MM_LNG_CACHE["wog_options"]["load"] = "Load"
If Not MapExists($MM_LNG_CACHE["wog_options"], "default") Or Not IsString($MM_LNG_CACHE["wog_options"]["default"]) Then $MM_LNG_CACHE["wog_options"]["default"] = "Default"
If Not MapExists($MM_LNG_CACHE["wog_options"], "uncheck") Or Not IsString($MM_LNG_CACHE["wog_options"]["uncheck"]) Then $MM_LNG_CACHE["wog_options"]["uncheck"] = "Uncheck All"
If Not MapExists($MM_LNG_CACHE["wog_options"], "check") Or Not IsString($MM_LNG_CACHE["wog_options"]["check"]) Then $MM_LNG_CACHE["wog_options"]["check"] = "Check All"
If Not MapExists($MM_LNG_CACHE["wog_options"], "filter") Or Not IsString($MM_LNG_CACHE["wog_options"]["filter"]) Then $MM_LNG_CACHE["wog_options"]["filter"] = "Filter:"
If Not MapExists($MM_LNG_CACHE, "plugins_list") Or Not IsMap($MM_LNG_CACHE["plugins_list"]) Then $MM_LNG_CACHE["plugins_list"] = MapEmpty()
If Not MapExists($MM_LNG_CACHE["plugins_list"], "caption") Or Not IsString($MM_LNG_CACHE["plugins_list"]["caption"]) Then $MM_LNG_CACHE["plugins_list"]["caption"] = "Plugins (%s)"
If Not MapExists($MM_LNG_CACHE["plugins_list"], "global") Or Not IsString($MM_LNG_CACHE["plugins_list"]["global"]) Then $MM_LNG_CACHE["plugins_list"]["global"] = "Global"
If Not MapExists($MM_LNG_CACHE["plugins_list"], "before_wog") Or Not IsString($MM_LNG_CACHE["plugins_list"]["before_wog"]) Then $MM_LNG_CACHE["plugins_list"]["before_wog"] = "BeforeWoG"
If Not MapExists($MM_LNG_CACHE["plugins_list"], "after_wog") Or Not IsString($MM_LNG_CACHE["plugins_list"]["after_wog"]) Then $MM_LNG_CACHE["plugins_list"]["after_wog"] = "AfterWoG"
If Not MapExists($MM_LNG_CACHE["plugins_list"], "back") Or Not IsString($MM_LNG_CACHE["plugins_list"]["back"]) Then $MM_LNG_CACHE["plugins_list"]["back"] = "Back"
If Not MapExists($MM_LNG_CACHE["plugins_list"], "default") Or Not IsString($MM_LNG_CACHE["plugins_list"]["default"]) Then $MM_LNG_CACHE["plugins_list"]["default"] = "Default"
If Not MapExists($MM_LNG_CACHE, "info_group") Or Not IsMap($MM_LNG_CACHE["info_group"]) Then $MM_LNG_CACHE["info_group"] = MapEmpty()
If Not MapExists($MM_LNG_CACHE["info_group"], "desc") Or Not IsString($MM_LNG_CACHE["info_group"]["desc"]) Then $MM_LNG_CACHE["info_group"]["desc"] = "Descripton"
If Not MapExists($MM_LNG_CACHE["info_group"], "screens") Or Not IsMap($MM_LNG_CACHE["info_group"]["screens"]) Then $MM_LNG_CACHE["info_group"]["screens"] = MapEmpty()
If Not MapExists($MM_LNG_CACHE["info_group"]["screens"], "caption") Or Not IsString($MM_LNG_CACHE["info_group"]["screens"]["caption"]) Then $MM_LNG_CACHE["info_group"]["screens"]["caption"] = "Screenshots"
If Not MapExists($MM_LNG_CACHE["info_group"], "no_info") Or Not IsString($MM_LNG_CACHE["info_group"]["no_info"]) Then $MM_LNG_CACHE["info_group"]["no_info"] = "No description available"
If Not MapExists($MM_LNG_CACHE["info_group"], "info") Or Not IsMap($MM_LNG_CACHE["info_group"]["info"]) Then $MM_LNG_CACHE["info_group"]["info"] = MapEmpty()
If Not MapExists($MM_LNG_CACHE["info_group"]["info"], "caption") Or Not IsString($MM_LNG_CACHE["info_group"]["info"]["caption"]) Then $MM_LNG_CACHE["info_group"]["info"]["caption"] = "Information"
If Not MapExists($MM_LNG_CACHE["info_group"]["info"], "mod_caption") Or Not IsString($MM_LNG_CACHE["info_group"]["info"]["mod_caption"]) Then $MM_LNG_CACHE["info_group"]["info"]["mod_caption"] = "Mod %s (%s)"
If Not MapExists($MM_LNG_CACHE["info_group"]["info"], "mod_caption_s") Or Not IsString($MM_LNG_CACHE["info_group"]["info"]["mod_caption_s"]) Then $MM_LNG_CACHE["info_group"]["info"]["mod_caption_s"] = "Mod %s"
If Not MapExists($MM_LNG_CACHE["info_group"]["info"], "version") Or Not IsString($MM_LNG_CACHE["info_group"]["info"]["version"]) Then $MM_LNG_CACHE["info_group"]["info"]["version"] = "Version: %s"
If Not MapExists($MM_LNG_CACHE["info_group"]["info"], "author") Or Not IsString($MM_LNG_CACHE["info_group"]["info"]["author"]) Then $MM_LNG_CACHE["info_group"]["info"]["author"] = "Author(s): %s"
If Not MapExists($MM_LNG_CACHE["info_group"]["info"], "link") Or Not IsString($MM_LNG_CACHE["info_group"]["info"]["link"]) Then $MM_LNG_CACHE["info_group"]["info"]["link"] = "Visit mod <A HREF=""homepage"">homepage</A>"
If Not MapExists($MM_LNG_CACHE["info_group"]["info"], "category") Or Not IsString($MM_LNG_CACHE["info_group"]["info"]["category"]) Then $MM_LNG_CACHE["info_group"]["info"]["category"] = "Category: %s"
If Not MapExists($MM_LNG_CACHE, "compatibility") Or Not IsMap($MM_LNG_CACHE["compatibility"]) Then $MM_LNG_CACHE["compatibility"] = MapEmpty()
If Not MapExists($MM_LNG_CACHE["compatibility"], "part1") Or Not IsString($MM_LNG_CACHE["compatibility"]["part1"]) Then $MM_LNG_CACHE["compatibility"]["part1"] = "Mod %s is incompatible with following mods:"
If Not MapExists($MM_LNG_CACHE["compatibility"], "part2") Or Not IsString($MM_LNG_CACHE["compatibility"]["part2"]) Then $MM_LNG_CACHE["compatibility"]["part2"] = "Disable these mods to reduce amount of unexpected bugs :)"
If Not MapExists($MM_LNG_CACHE["compatibility"], "launch_anyway") Or Not IsString($MM_LNG_CACHE["compatibility"]["launch_anyway"]) Then $MM_LNG_CACHE["compatibility"]["launch_anyway"] = "Launch anyway?"
If Not MapExists($MM_LNG_CACHE, "add_new") Or Not IsMap($MM_LNG_CACHE["add_new"]) Then $MM_LNG_CACHE["add_new"] = MapEmpty()
If Not MapExists($MM_LNG_CACHE["add_new"], "caption") Or Not IsString($MM_LNG_CACHE["add_new"]["caption"]) Then $MM_LNG_CACHE["add_new"]["caption"] = "Mod install (%d from %d)"
If Not MapExists($MM_LNG_CACHE["add_new"], "filter") Or Not IsString($MM_LNG_CACHE["add_new"]["filter"]) Then $MM_LNG_CACHE["add_new"]["filter"] = "Era II Mods (*.exe; *.rar; *.zip; *.7z)|All (*.*)"
If Not MapExists($MM_LNG_CACHE["add_new"], "progress") Or Not IsMap($MM_LNG_CACHE["add_new"]["progress"]) Then $MM_LNG_CACHE["add_new"]["progress"] = MapEmpty()
If Not MapExists($MM_LNG_CACHE["add_new"]["progress"], "caption") Or Not IsString($MM_LNG_CACHE["add_new"]["progress"]["caption"]) Then $MM_LNG_CACHE["add_new"]["progress"]["caption"] = "Please wait... Unpacking files..."
If Not MapExists($MM_LNG_CACHE["add_new"]["progress"], "scanned") Or Not IsString($MM_LNG_CACHE["add_new"]["progress"]["scanned"]) Then $MM_LNG_CACHE["add_new"]["progress"]["scanned"] = ""
If Not MapExists($MM_LNG_CACHE["add_new"]["progress"], "found") Or Not IsString($MM_LNG_CACHE["add_new"]["progress"]["found"]) Then $MM_LNG_CACHE["add_new"]["progress"]["found"] = "Found %i"
If Not MapExists($MM_LNG_CACHE["add_new"]["progress"], "no_mods") Or Not IsString($MM_LNG_CACHE["add_new"]["progress"]["no_mods"]) Then $MM_LNG_CACHE["add_new"]["progress"]["no_mods"] = "There is no mod in the specified file. \n\nThe possible reasons are: \n1) You use an out-of-date program version. \n2) You're trying to add not supported mod file (probably not a mod at all)."
If Not MapExists($MM_LNG_CACHE["add_new"], "unpacking") Or Not IsString($MM_LNG_CACHE["add_new"]["unpacking"]) Then $MM_LNG_CACHE["add_new"]["unpacking"] = "Please wait... Unpacking files..."
If Not MapExists($MM_LNG_CACHE["add_new"], "install") Or Not IsString($MM_LNG_CACHE["add_new"]["install"]) Then $MM_LNG_CACHE["add_new"]["install"] = "Install"
If Not MapExists($MM_LNG_CACHE["add_new"], "reinstall") Or Not IsString($MM_LNG_CACHE["add_new"]["reinstall"]) Then $MM_LNG_CACHE["add_new"]["reinstall"] = "Reinstall"
If Not MapExists($MM_LNG_CACHE["add_new"], "installed") Or Not IsString($MM_LNG_CACHE["add_new"]["installed"]) Then $MM_LNG_CACHE["add_new"]["installed"] = "Please wait... Installing..."
If Not MapExists($MM_LNG_CACHE["add_new"], "dont_install") Or Not IsString($MM_LNG_CACHE["add_new"]["dont_install"]) Then $MM_LNG_CACHE["add_new"]["dont_install"] = "Don't install"
If Not MapExists($MM_LNG_CACHE["add_new"], "next_mod") Or Not IsString($MM_LNG_CACHE["add_new"]["next_mod"]) Then $MM_LNG_CACHE["add_new"]["next_mod"] = "Next mod"
If Not MapExists($MM_LNG_CACHE["add_new"], "close") Or Not IsString($MM_LNG_CACHE["add_new"]["close"]) Then $MM_LNG_CACHE["add_new"]["close"] = "Close"
If Not MapExists($MM_LNG_CACHE["add_new"], "exit") Or Not IsString($MM_LNG_CACHE["add_new"]["exit"]) Then $MM_LNG_CACHE["add_new"]["exit"] = "Exit"
If Not MapExists($MM_LNG_CACHE["add_new"], "version_installed") Or Not IsString($MM_LNG_CACHE["add_new"]["version_installed"]) Then $MM_LNG_CACHE["add_new"]["version_installed"] = "Mod is installed (version %s)"
If Not MapExists($MM_LNG_CACHE["add_new"], "install_package") Or Not IsString($MM_LNG_CACHE["add_new"]["install_package"]) Then $MM_LNG_CACHE["add_new"]["install_package"] = "Install package (version %s)"
If Not MapExists($MM_LNG_CACHE, "settings") Or Not IsMap($MM_LNG_CACHE["settings"]) Then $MM_LNG_CACHE["settings"] = MapEmpty()
If Not MapExists($MM_LNG_CACHE["settings"], "game_dir") Or Not IsMap($MM_LNG_CACHE["settings"]["game_dir"]) Then $MM_LNG_CACHE["settings"]["game_dir"] = MapEmpty()
If Not MapExists($MM_LNG_CACHE["settings"]["game_dir"], "change") Or Not IsString($MM_LNG_CACHE["settings"]["game_dir"]["change"]) Then $MM_LNG_CACHE["settings"]["game_dir"]["change"] = "Change game directory"
If Not MapExists($MM_LNG_CACHE["settings"]["game_dir"], "caption") Or Not IsString($MM_LNG_CACHE["settings"]["game_dir"]["caption"]) Then $MM_LNG_CACHE["settings"]["game_dir"]["caption"] = "Select game directory"
If Not MapExists($MM_LNG_CACHE["settings"]["game_dir"], "incorrect_dir") Or Not IsString($MM_LNG_CACHE["settings"]["game_dir"]["incorrect_dir"]) Then $MM_LNG_CACHE["settings"]["game_dir"]["incorrect_dir"] = "This directory doesn't look like Era II directory (no ""h3era.exe"" file here).\nDo you still want to use this dir?\n\nIn any case, you always can change dir later (menu ""Tools"" -> ""Change game directory"")"
If Not MapExists($MM_LNG_CACHE["settings"], "game_exe") Or Not IsMap($MM_LNG_CACHE["settings"]["game_exe"]) Then $MM_LNG_CACHE["settings"]["game_exe"] = MapEmpty()
If Not MapExists($MM_LNG_CACHE["settings"]["game_exe"], "show_all") Or Not IsString($MM_LNG_CACHE["settings"]["game_exe"]["show_all"]) Then $MM_LNG_CACHE["settings"]["game_exe"]["show_all"] = "Show all"
If Not MapExists($MM_LNG_CACHE["settings"], "menu") Or Not IsMap($MM_LNG_CACHE["settings"]["menu"]) Then $MM_LNG_CACHE["settings"]["menu"] = MapEmpty()
If Not MapExists($MM_LNG_CACHE["settings"]["menu"], "caption") Or Not IsString($MM_LNG_CACHE["settings"]["menu"]["caption"]) Then $MM_LNG_CACHE["settings"]["menu"]["caption"] = "Tools"
If Not MapExists($MM_LNG_CACHE["settings"]["menu"], "settings") Or Not IsString($MM_LNG_CACHE["settings"]["menu"]["settings"]) Then $MM_LNG_CACHE["settings"]["menu"]["settings"] = "Settings"
If Not MapExists($MM_LNG_CACHE["settings"], "auto_update") Or Not IsMap($MM_LNG_CACHE["settings"]["auto_update"]) Then $MM_LNG_CACHE["settings"]["auto_update"] = MapEmpty()
If Not MapExists($MM_LNG_CACHE["settings"]["auto_update"], "group") Or Not IsString($MM_LNG_CACHE["settings"]["auto_update"]["group"]) Then $MM_LNG_CACHE["settings"]["auto_update"]["group"] = "Program updates"
If Not MapExists($MM_LNG_CACHE["settings"]["auto_update"], "label") Or Not IsString($MM_LNG_CACHE["settings"]["auto_update"]["label"]) Then $MM_LNG_CACHE["settings"]["auto_update"]["label"] = "Update program:"
If Not MapExists($MM_LNG_CACHE["settings"]["auto_update"], "day") Or Not IsString($MM_LNG_CACHE["settings"]["auto_update"]["day"]) Then $MM_LNG_CACHE["settings"]["auto_update"]["day"] = "Every day"
If Not MapExists($MM_LNG_CACHE["settings"]["auto_update"], "week") Or Not IsString($MM_LNG_CACHE["settings"]["auto_update"]["week"]) Then $MM_LNG_CACHE["settings"]["auto_update"]["week"] = "Every week"
If Not MapExists($MM_LNG_CACHE["settings"]["auto_update"], "month") Or Not IsString($MM_LNG_CACHE["settings"]["auto_update"]["month"]) Then $MM_LNG_CACHE["settings"]["auto_update"]["month"] = "Every month"
If Not MapExists($MM_LNG_CACHE["settings"]["auto_update"], "never") Or Not IsString($MM_LNG_CACHE["settings"]["auto_update"]["never"]) Then $MM_LNG_CACHE["settings"]["auto_update"]["never"] = "Never"
If Not MapExists($MM_LNG_CACHE["settings"]["auto_update"], "auto") Or Not IsString($MM_LNG_CACHE["settings"]["auto_update"]["auto"]) Then $MM_LNG_CACHE["settings"]["auto_update"]["auto"] = "Install updates automatically"
If Not MapExists($MM_LNG_CACHE["settings"], "list_load_options") Or Not IsMap($MM_LNG_CACHE["settings"]["list_load_options"]) Then $MM_LNG_CACHE["settings"]["list_load_options"] = MapEmpty()
If Not MapExists($MM_LNG_CACHE["settings"]["list_load_options"], "group") Or Not IsString($MM_LNG_CACHE["settings"]["list_load_options"]["group"]) Then $MM_LNG_CACHE["settings"]["list_load_options"]["group"] = "Preset load options"
If Not MapExists($MM_LNG_CACHE["settings"]["list_load_options"], "exe") Or Not IsString($MM_LNG_CACHE["settings"]["list_load_options"]["exe"]) Then $MM_LNG_CACHE["settings"]["list_load_options"]["exe"] = "Set starting exe to selected in preset"
If Not MapExists($MM_LNG_CACHE["settings"]["list_load_options"], "wog_settings") Or Not IsString($MM_LNG_CACHE["settings"]["list_load_options"]["wog_settings"]) Then $MM_LNG_CACHE["settings"]["list_load_options"]["wog_settings"] = "Set wog settings to stored in preset"
If Not MapExists($MM_LNG_CACHE["settings"]["list_load_options"], "dont_ask") Or Not IsString($MM_LNG_CACHE["settings"]["list_load_options"]["dont_ask"]) Then $MM_LNG_CACHE["settings"]["list_load_options"]["dont_ask"] = "Don't ask. Use these settings"
If Not MapExists($MM_LNG_CACHE, "update") Or Not IsMap($MM_LNG_CACHE["update"]) Then $MM_LNG_CACHE["update"] = MapEmpty()
If Not MapExists($MM_LNG_CACHE["update"], "caption") Or Not IsString($MM_LNG_CACHE["update"]["caption"]) Then $MM_LNG_CACHE["update"]["caption"] = "Check for program updates"
If Not MapExists($MM_LNG_CACHE["update"], "current_version") Or Not IsString($MM_LNG_CACHE["update"]["current_version"]) Then $MM_LNG_CACHE["update"]["current_version"] = "Installed version: %s"
If Not MapExists($MM_LNG_CACHE["update"], "available_versions") Or Not IsString($MM_LNG_CACHE["update"]["available_versions"]) Then $MM_LNG_CACHE["update"]["available_versions"] = "Available to download:"
If Not MapExists($MM_LNG_CACHE["update"], "wait") Or Not IsString($MM_LNG_CACHE["update"]["wait"]) Then $MM_LNG_CACHE["update"]["wait"] = "wait..."
If Not MapExists($MM_LNG_CACHE["update"], "cancel") Or Not IsString($MM_LNG_CACHE["update"]["cancel"]) Then $MM_LNG_CACHE["update"]["cancel"] = "Cancel"
If Not MapExists($MM_LNG_CACHE["update"], "update_group") Or Not IsString($MM_LNG_CACHE["update"]["update_group"]) Then $MM_LNG_CACHE["update"]["update_group"] = "Selected update"
If Not MapExists($MM_LNG_CACHE["update"], "download_and_install") Or Not IsString($MM_LNG_CACHE["update"]["download_and_install"]) Then $MM_LNG_CACHE["update"]["download_and_install"] = "Download update and install automatically"
If Not MapExists($MM_LNG_CACHE["update"], "only_download") Or Not IsString($MM_LNG_CACHE["update"]["only_download"]) Then $MM_LNG_CACHE["update"]["only_download"] = "Only download"
If Not MapExists($MM_LNG_CACHE["update"], "change_dir") Or Not IsString($MM_LNG_CACHE["update"]["change_dir"]) Then $MM_LNG_CACHE["update"]["change_dir"] = "Change"
If Not MapExists($MM_LNG_CACHE["update"], "select_dir") Or Not IsString($MM_LNG_CACHE["update"]["select_dir"]) Then $MM_LNG_CACHE["update"]["select_dir"] = "Select directory"
If Not MapExists($MM_LNG_CACHE["update"], "start") Or Not IsString($MM_LNG_CACHE["update"]["start"]) Then $MM_LNG_CACHE["update"]["start"] = "Start"
If Not MapExists($MM_LNG_CACHE["update"], "close") Or Not IsString($MM_LNG_CACHE["update"]["close"]) Then $MM_LNG_CACHE["update"]["close"] = "Close"
If Not MapExists($MM_LNG_CACHE["update"], "cant_check") Or Not IsString($MM_LNG_CACHE["update"]["cant_check"]) Then $MM_LNG_CACHE["update"]["cant_check"] = "Can't check program update. Open link in browser?"
If Not MapExists($MM_LNG_CACHE["update"], "cant_download") Or Not IsString($MM_LNG_CACHE["update"]["cant_download"]) Then $MM_LNG_CACHE["update"]["cant_download"] = "Can't download program update. Open link in browser?"
If Not MapExists($MM_LNG_CACHE["update"], "info_invalid") Or Not IsString($MM_LNG_CACHE["update"]["info_invalid"]) Then $MM_LNG_CACHE["update"]["info_invalid"] = "invalid format..."
If Not MapExists($MM_LNG_CACHE["update"], "new_version_available") Or Not IsString($MM_LNG_CACHE["update"]["new_version_available"]) Then $MM_LNG_CACHE["update"]["new_version_available"] = "New program version available. Do you want to download it?"
If Not MapExists($MM_LNG_CACHE["update"], "progress") Or Not IsMap($MM_LNG_CACHE["update"]["progress"]) Then $MM_LNG_CACHE["update"]["progress"] = MapEmpty()
If Not MapExists($MM_LNG_CACHE["update"]["progress"], "caption") Or Not IsString($MM_LNG_CACHE["update"]["progress"]["caption"]) Then $MM_LNG_CACHE["update"]["progress"]["caption"] = "Installing update..."
If Not MapExists($MM_LNG_CACHE["update"]["progress"], "unpack") Or Not IsString($MM_LNG_CACHE["update"]["progress"]["unpack"]) Then $MM_LNG_CACHE["update"]["progress"]["unpack"] = "Unpacking files..."
If Not MapExists($MM_LNG_CACHE["update"]["progress"], "copy") Or Not IsString($MM_LNG_CACHE["update"]["progress"]["copy"]) Then $MM_LNG_CACHE["update"]["progress"]["copy"] = "Just a little bit more"
If Not MapExists($MM_LNG_CACHE, "mod_edit") Or Not IsMap($MM_LNG_CACHE["mod_edit"]) Then $MM_LNG_CACHE["mod_edit"] = MapEmpty()
If Not MapExists($MM_LNG_CACHE["mod_edit"], "caption") Or Not IsString($MM_LNG_CACHE["mod_edit"]["caption"]) Then $MM_LNG_CACHE["mod_edit"]["caption"] = "Mod edit"
If Not MapExists($MM_LNG_CACHE["mod_edit"], "save") Or Not IsString($MM_LNG_CACHE["mod_edit"]["save"]) Then $MM_LNG_CACHE["mod_edit"]["save"] = "Save"
If Not MapExists($MM_LNG_CACHE["mod_edit"], "cancel") Or Not IsString($MM_LNG_CACHE["mod_edit"]["cancel"]) Then $MM_LNG_CACHE["mod_edit"]["cancel"] = "Cancel"
If Not MapExists($MM_LNG_CACHE["mod_edit"], "group_caption") Or Not IsMap($MM_LNG_CACHE["mod_edit"]["group_caption"]) Then $MM_LNG_CACHE["mod_edit"]["group_caption"] = MapEmpty()
If Not MapExists($MM_LNG_CACHE["mod_edit"]["group_caption"], "caption") Or Not IsString($MM_LNG_CACHE["mod_edit"]["group_caption"]["caption"]) Then $MM_LNG_CACHE["mod_edit"]["group_caption"]["caption"] = "Caption and description"
If Not MapExists($MM_LNG_CACHE["mod_edit"]["group_caption"], "language") Or Not IsString($MM_LNG_CACHE["mod_edit"]["group_caption"]["language"]) Then $MM_LNG_CACHE["mod_edit"]["group_caption"]["language"] = "Language:"
If Not MapExists($MM_LNG_CACHE["mod_edit"]["group_caption"], "caption_label") Or Not IsString($MM_LNG_CACHE["mod_edit"]["group_caption"]["caption_label"]) Then $MM_LNG_CACHE["mod_edit"]["group_caption"]["caption_label"] = "Caption:"
If Not MapExists($MM_LNG_CACHE["mod_edit"]["group_caption"], "description_file") Or Not IsString($MM_LNG_CACHE["mod_edit"]["group_caption"]["description_file"]) Then $MM_LNG_CACHE["mod_edit"]["group_caption"]["description_file"] = "Description file:"
If Not MapExists($MM_LNG_CACHE["mod_edit"]["group_caption"], "description_short") Or Not IsString($MM_LNG_CACHE["mod_edit"]["group_caption"]["description_short"]) Then $MM_LNG_CACHE["mod_edit"]["group_caption"]["description_short"] = "Short description:"
If Not MapExists($MM_LNG_CACHE["mod_edit"]["group_caption"], "description_short_from_file") Or Not IsString($MM_LNG_CACHE["mod_edit"]["group_caption"]["description_short_from_file"]) Then $MM_LNG_CACHE["mod_edit"]["group_caption"]["description_short_from_file"] = "From file"
If Not MapExists($MM_LNG_CACHE["mod_edit"], "group_other") Or Not IsMap($MM_LNG_CACHE["mod_edit"]["group_other"]) Then $MM_LNG_CACHE["mod_edit"]["group_other"] = MapEmpty()
If Not MapExists($MM_LNG_CACHE["mod_edit"]["group_other"], "caption") Or Not IsString($MM_LNG_CACHE["mod_edit"]["group_other"]["caption"]) Then $MM_LNG_CACHE["mod_edit"]["group_other"]["caption"] = "Other"
If Not MapExists($MM_LNG_CACHE["mod_edit"]["group_other"], "mod_version") Or Not IsString($MM_LNG_CACHE["mod_edit"]["group_other"]["mod_version"]) Then $MM_LNG_CACHE["mod_edit"]["group_other"]["mod_version"] = "Mod version:"
If Not MapExists($MM_LNG_CACHE["mod_edit"]["group_other"], "author") Or Not IsString($MM_LNG_CACHE["mod_edit"]["group_other"]["author"]) Then $MM_LNG_CACHE["mod_edit"]["group_other"]["author"] = "Author:"
If Not MapExists($MM_LNG_CACHE["mod_edit"]["group_other"], "homepage") Or Not IsString($MM_LNG_CACHE["mod_edit"]["group_other"]["homepage"]) Then $MM_LNG_CACHE["mod_edit"]["group_other"]["homepage"] = "Homepage:"
If Not MapExists($MM_LNG_CACHE["mod_edit"]["group_other"], "icon") Or Not IsString($MM_LNG_CACHE["mod_edit"]["group_other"]["icon"]) Then $MM_LNG_CACHE["mod_edit"]["group_other"]["icon"] = "Icon:"
If Not MapExists($MM_LNG_CACHE["mod_edit"]["group_other"], "priority") Or Not IsString($MM_LNG_CACHE["mod_edit"]["group_other"]["priority"]) Then $MM_LNG_CACHE["mod_edit"]["group_other"]["priority"] = "Priority:"
If Not MapExists($MM_LNG_CACHE["mod_edit"]["group_other"], "category") Or Not IsString($MM_LNG_CACHE["mod_edit"]["group_other"]["category"]) Then $MM_LNG_CACHE["mod_edit"]["group_other"]["category"] = "Category:"
If Not MapExists($MM_LNG_CACHE["mod_edit"], "group_compatibility") Or Not IsMap($MM_LNG_CACHE["mod_edit"]["group_compatibility"]) Then $MM_LNG_CACHE["mod_edit"]["group_compatibility"] = MapEmpty()
If Not MapExists($MM_LNG_CACHE["mod_edit"]["group_compatibility"], "caption") Or Not IsString($MM_LNG_CACHE["mod_edit"]["group_compatibility"]["caption"]) Then $MM_LNG_CACHE["mod_edit"]["group_compatibility"]["caption"] = "Compatibility"
If Not MapExists($MM_LNG_CACHE["mod_edit"]["group_compatibility"], "class") Or Not IsString($MM_LNG_CACHE["mod_edit"]["group_compatibility"]["class"]) Then $MM_LNG_CACHE["mod_edit"]["group_compatibility"]["class"] = "Compatibility class:"
If Not MapExists($MM_LNG_CACHE["mod_edit"]["group_compatibility"], "all") Or Not IsString($MM_LNG_CACHE["mod_edit"]["group_compatibility"]["all"]) Then $MM_LNG_CACHE["mod_edit"]["group_compatibility"]["all"] = "compatible with all mods"
If Not MapExists($MM_LNG_CACHE["mod_edit"]["group_compatibility"], "default") Or Not IsString($MM_LNG_CACHE["mod_edit"]["group_compatibility"]["default"]) Then $MM_LNG_CACHE["mod_edit"]["group_compatibility"]["default"] = "incompatible with ""none"" mods"
If Not MapExists($MM_LNG_CACHE["mod_edit"]["group_compatibility"], "none") Or Not IsString($MM_LNG_CACHE["mod_edit"]["group_compatibility"]["none"]) Then $MM_LNG_CACHE["mod_edit"]["group_compatibility"]["none"] = "incompatible with ""none"" and ""default"" mods"
If Not MapExists($MM_LNG_CACHE["mod_edit"]["group_compatibility"], "exclusions") Or Not IsString($MM_LNG_CACHE["mod_edit"]["group_compatibility"]["exclusions"]) Then $MM_LNG_CACHE["mod_edit"]["group_compatibility"]["exclusions"] = "Exclusions:"
If Not MapExists($MM_LNG_CACHE["mod_edit"]["group_compatibility"], "mod") Or Not IsString($MM_LNG_CACHE["mod_edit"]["group_compatibility"]["mod"]) Then $MM_LNG_CACHE["mod_edit"]["group_compatibility"]["mod"] = "Mod caption/id"
If Not MapExists($MM_LNG_CACHE["mod_edit"]["group_compatibility"], "compatible") Or Not IsString($MM_LNG_CACHE["mod_edit"]["group_compatibility"]["compatible"]) Then $MM_LNG_CACHE["mod_edit"]["group_compatibility"]["compatible"] = "Compatible"
If Not MapExists($MM_LNG_CACHE["mod_edit"]["group_compatibility"], "yes") Or Not IsString($MM_LNG_CACHE["mod_edit"]["group_compatibility"]["yes"]) Then $MM_LNG_CACHE["mod_edit"]["group_compatibility"]["yes"] = "Yes"
If Not MapExists($MM_LNG_CACHE["mod_edit"]["group_compatibility"], "no") Or Not IsString($MM_LNG_CACHE["mod_edit"]["group_compatibility"]["no"]) Then $MM_LNG_CACHE["mod_edit"]["group_compatibility"]["no"] = "No"
If Not MapExists($MM_LNG_CACHE, "category") Or Not IsMap($MM_LNG_CACHE["category"]) Then $MM_LNG_CACHE["category"] = MapEmpty()
If Not MapExists($MM_LNG_CACHE["category"], "gameplay") Or Not IsString($MM_LNG_CACHE["category"]["gameplay"]) Then $MM_LNG_CACHE["category"]["gameplay"] = "Gameplay"
If Not MapExists($MM_LNG_CACHE["category"], "graphics") Or Not IsString($MM_LNG_CACHE["category"]["graphics"]) Then $MM_LNG_CACHE["category"]["graphics"] = "Graphics"
If Not MapExists($MM_LNG_CACHE["category"], "scenarios") Or Not IsString($MM_LNG_CACHE["category"]["scenarios"]) Then $MM_LNG_CACHE["category"]["scenarios"] = "Scenarios"
If Not MapExists($MM_LNG_CACHE["category"], "cheats") Or Not IsString($MM_LNG_CACHE["category"]["cheats"]) Then $MM_LNG_CACHE["category"]["cheats"] = "Cheats"
If Not MapExists($MM_LNG_CACHE["category"], "interface") Or Not IsString($MM_LNG_CACHE["category"]["interface"]) Then $MM_LNG_CACHE["category"]["interface"] = "Interface"
If Not MapExists($MM_LNG_CACHE["category"], "towns") Or Not IsString($MM_LNG_CACHE["category"]["towns"]) Then $MM_LNG_CACHE["category"]["towns"] = "Towns"
If Not MapExists($MM_LNG_CACHE["category"], "other") Or Not IsString($MM_LNG_CACHE["category"]["other"]) Then $MM_LNG_CACHE["category"]["other"] = "Other"
If Not MapExists($MM_LNG_CACHE["category"], "platforms") Or Not IsString($MM_LNG_CACHE["category"]["platforms"]) Then $MM_LNG_CACHE["category"]["platforms"] = "Platforms"
If Not MapExists($MM_LNG_CACHE["category"], "personal mods") Or Not IsString($MM_LNG_CACHE["category"]["personal mods"]) Then $MM_LNG_CACHE["category"]["personal mods"] = "My personal mods"
If Not MapExists($MM_LNG_CACHE["category"], "utilities") Or Not IsString($MM_LNG_CACHE["category"]["utilities"]) Then $MM_LNG_CACHE["category"]["utilities"] = "Utilities"
EndFunc
Func Lng_LoadList()
Local $asTemp = _FileListToArray(@ScriptDir & "\lng\", "*.json", 1)
Local $asReturn[UBound($asTemp, $UBOUND_ROWS)][$MM_LNG_TOTAL] = [[$asTemp[0]]]
Local $sText, $vDecoded
For $i = 1 To $asTemp[0]
$asReturn[$i][$MM_LNG_FILE] = $asTemp[$i]
$sText = FileRead(@ScriptDir & "\lng\" & $asTemp[$i])
If @error Then
$asReturn[$i][1] = "Can't read .\lng\" & $asTemp[$i]
Else
$vDecoded = Jsmn_Decode($sText)
$asReturn[$i][$MM_LNG_CODE] = "fail"
$asReturn[$i][$MM_LNG_MENU_ID] = 0
If @error Then
$asReturn[$i][$MM_LNG_NAME] = StringFormat("Error '%s' when parsing .\lng\%s", @error, $asTemp[$i])
Else
If Not IsMap($vDecoded) Then
$asReturn[$i][$MM_LNG_NAME] = StringFormat("Error '%s' when parsing .\lng\%s", '$vDecoded is not map', $asTemp[$i])
ElseIf Not IsMap($vDecoded["lang"]) Then
$asReturn[$i][$MM_LNG_NAME] = StringFormat("Error '%s' when parsing .\lng\%s", '$vDecoded["lang"] is not map', $asTemp[$i])
Else
$asReturn[$i][$MM_LNG_NAME] = $vDecoded["lang"]["name"]
$asReturn[$i][$MM_LNG_CODE] = $vDecoded["lang"]["code"]
EndIf
EndIf
EndIf
Next
$MM_LNG_LIST = $asReturn
EndFunc
Func Lng_GetCodeByName(Const $sName)
For $i = 1 To $MM_LNG_LIST[0][0]
If $MM_LNG_LIST[$i][$MM_LNG_NAME] = $sName Then Return $MM_LNG_LIST[$i][$MM_LNG_CODE]
Next
Return "en_US"
EndFunc
Func Lng_GetCategoryList()
Return MapKeys($MM_LNG_CACHE["category"])
EndFunc
Func Lng_Get(Const ByRef $sKeyName)
If Not IsMap($MM_LNG_CACHE) Then Lng_Load()
If Not IsMap($MM_LNG_CACHE) Then Return $sKeyName
Local $sReturn
Local $aPartsLower = StringSplit(StringLower($sKeyName), ".")
Local $aParts = StringSplit($sKeyName, ".")
If $aParts[0] > 0 And Not IsMap($MM_LNG_CACHE) Then Return $sKeyName
If $aParts[0] > 1 And Not IsMap($MM_LNG_CACHE[$aPartsLower[1]]) Then Return $sKeyName
If $aParts[0] > 2 And Not IsMap($MM_LNG_CACHE[$aPartsLower[1]][$aPartsLower[2]]) Then Return $sKeyName
If $aParts[0] > 3 And Not IsMap($MM_LNG_CACHE[$aPartsLower[1]][$aPartsLower[2]][$aPartsLower[3]]) Then Return $sKeyName
Switch $aParts[0]
Case 1
$sReturn = $MM_LNG_CACHE[$aPartsLower[1]]
Case 2
$sReturn = $MM_LNG_CACHE[$aPartsLower[1]][$aPartsLower[2]]
If IsKeyword($sReturn) And $aPartsLower[1] = "category" Then $sReturn = $aParts[2]
Case 3
$sReturn = $MM_LNG_CACHE[$aPartsLower[1]][$aPartsLower[2]][$aPartsLower[3]]
Case 4
$sReturn = $MM_LNG_CACHE[$aPartsLower[1]][$aPartsLower[2]][$aPartsLower[3]][$aPartsLower[4]]
EndSwitch
Return Not IsKeyword($sReturn) ? $sReturn : $sKeyName
EndFunc
Func Lng_GetCategory(Const $sKeyName)
Return Lng_Get("category." & $sKeyName)
EndFunc
Func Lng_GetF(Const ByRef $sKeyName, Const $vParam1, Const $vParam2 = Default)
If IsKeyword($vParam2) == $KEYWORD_DEFAULT Then
Return StringFormat(Lng_Get($sKeyName), $vParam1)
Else
Return StringFormat(Lng_Get($sKeyName), $vParam1, $vParam2)
EndIf
EndFunc
Global $MM_SETTINGS_CACHE, $MM_SETTINGS_INIT = False
Func Settings_Get(Const ByRef $sName)
If Not $MM_SETTINGS_INIT Then __Settings_Init()
Local $vReturn
Switch $sName
Case "language", "version"
$vReturn = $MM_SETTINGS_CACHE[StringLower($sName)]
Case "width", "height", "maximized"
$vReturn = $MM_SETTINGS_CACHE["window"][StringLower($sName)]
Case "path"
$vReturn = $MM_GAME_DIR
Case "exe"
$vReturn = $MM_SETTINGS_CACHE["game"]["exe"]
If Not $vReturn And FileExists(Settings_Get("path") & "\h3era.exe") Then $vReturn = "h3era.exe"
Case "game.blacklist"
$vReturn = $MM_SETTINGS_CACHE["game"]["blacklist"]
Case "available_path_list"
$vReturn = MapKeys($MM_SETTINGS_CACHE["game"]["items"])
Case "list_no_ask"
$vReturn = $MM_SETTINGS_CACHE["list"]["not_again"]
Case "list_exe"
$vReturn = $MM_SETTINGS_CACHE["list"]["exe"]
Case "list_wog_settings"
$vReturn = $MM_SETTINGS_CACHE["list"]["wog_settings"]
Case "list_only_load"
$vReturn = $MM_SETTINGS_CACHE["list"]["only_load"]
Case "current_preset"
$vReturn = $MM_SETTINGS_CACHE["game"]["preset"]
EndSwitch
Return $vReturn
EndFunc
Func Settings_Set(Const ByRef $sName, Const $vValue)
If Not $MM_SETTINGS_INIT Then __Settings_Init()
Switch $sName
Case "language"
$MM_SETTINGS_CACHE["language"] = $vValue
$MM_SETTINGS_LANGUAGE = $vValue
Case "version"
$MM_SETTINGS_CACHE[StringLower($sName)] = $vValue
Case "width", "height", "maximized"
$MM_SETTINGS_CACHE["window"][StringLower($sName)] = $vValue
Case "exe"
$MM_SETTINGS_CACHE["game"]["exe"] = $vValue
Case "list_no_ask"
$MM_SETTINGS_CACHE["list"]["not_again"] = $vValue
Case "list_exe"
$MM_SETTINGS_CACHE["list"]["exe"] = $vValue
Case "list_wog_settings"
$MM_SETTINGS_CACHE["list"]["wog_settings"] = $vValue
Case "list_only_load"
$MM_SETTINGS_CACHE["list"]["only_load"] = $vValue
Case "current_preset"
$MM_SETTINGS_CACHE["game"]["preset"] = $vValue
EndSwitch
__Settings_Save()
EndFunc
Func __Settings_Save()
If Not $MM_SETTINGS_INIT Then __Settings_Init()
FileDelete($MM_SETTINGS_PATH)
FileWrite($MM_SETTINGS_PATH, Jsmn_Encode($MM_SETTINGS_CACHE, $JSMN_PRETTY_PRINT + $JSMN_UNESCAPED_UNICODE))
EndFunc
Func __Settings_Validate()
Local $aItems, $i
If Not IsMap($MM_SETTINGS_CACHE) Then $MM_SETTINGS_CACHE = MapEmpty()
If Not MapExists($MM_SETTINGS_CACHE, "version") Or Not IsString($MM_SETTINGS_CACHE["version"]) Then $MM_SETTINGS_CACHE["version"] = $MM_VERSION_NUMBER
If Not MapExists($MM_SETTINGS_CACHE, "language") Or Not IsString($MM_SETTINGS_CACHE["language"]) Then $MM_SETTINGS_CACHE["language"] = "english.json"
If Not MapExists($MM_SETTINGS_CACHE, "window") Or Not IsMap($MM_SETTINGS_CACHE["window"]) Then $MM_SETTINGS_CACHE["window"] = MapEmpty()
If Not MapExists($MM_SETTINGS_CACHE["window"], "width") Or Not IsInt($MM_SETTINGS_CACHE["window"]["width"]) Or $MM_SETTINGS_CACHE["window"]["width"] < $MM_WINDOW_MIN_WIDTH Then $MM_SETTINGS_CACHE["window"]["width"] = $MM_WINDOW_MIN_WIDTH
If Not MapExists($MM_SETTINGS_CACHE["window"], "height") Or Not IsInt($MM_SETTINGS_CACHE["window"]["height"]) Or $MM_SETTINGS_CACHE["window"]["height"] < $MM_WINDOW_MIN_HEIGHT Then $MM_SETTINGS_CACHE["window"]["height"] = $MM_WINDOW_MIN_HEIGHT
If Not MapExists($MM_SETTINGS_CACHE["window"], "maximized") Or Not IsBool($MM_SETTINGS_CACHE["window"]["maximized"]) Then $MM_SETTINGS_CACHE["window"]["maximized"] = False
If Not MapExists($MM_SETTINGS_CACHE, "game") Or Not IsMap($MM_SETTINGS_CACHE["game"]) Then $MM_SETTINGS_CACHE["game"] = MapEmpty()
If Not MapExists($MM_SETTINGS_CACHE["game"], "exe") Or Not IsString($MM_SETTINGS_CACHE["game"]["exe"]) Then $MM_SETTINGS_CACHE["game"]["exe"] = ""
If Not MapExists($MM_SETTINGS_CACHE["game"], "blacklist") Or Not IsArray($MM_SETTINGS_CACHE["game"]["blacklist"]) Then
$aItems = StringSplit(".*?cmp.*?###.*?map.*?###.*?back.*?###.*?int.*?###.*?upd.*?###.*?unin.*?", "###", $STR_ENTIRESPLIT + $STR_NOCOUNT)
$MM_SETTINGS_CACHE["game"]["blacklist"] = $aItems
Else
$aItems = $MM_SETTINGS_CACHE["game"]["blacklist"]
EndIf
$i = 0
While $i < UBound($aItems) - 1
If Not IsString($aItems[$i]) Or $aItems[$i] = "" Then _ArrayDelete($aItems, $i)
$i += 1
WEnd
$MM_SETTINGS_CACHE["game"]["blacklist"] = $aItems
If Not MapExists($MM_SETTINGS_CACHE, "list") Or Not IsMap($MM_SETTINGS_CACHE["list"]) Then $MM_SETTINGS_CACHE["list"] = MapEmpty()
If Not MapExists($MM_SETTINGS_CACHE["list"], "not_again") Or Not IsBool($MM_SETTINGS_CACHE["list"]["not_again"]) Then $MM_SETTINGS_CACHE["list"]["not_again"] = False
If Not MapExists($MM_SETTINGS_CACHE["list"], "exe") Or Not IsBool($MM_SETTINGS_CACHE["list"]["exe"]) Then $MM_SETTINGS_CACHE["list"]["exe"] = False
If Not MapExists($MM_SETTINGS_CACHE["list"], "wog_settings") Or Not IsBool($MM_SETTINGS_CACHE["list"]["wog_settings"]) Then $MM_SETTINGS_CACHE["list"]["wog_settings"] = True
If Not MapExists($MM_SETTINGS_CACHE["list"], "only_load") Or Not IsBool($MM_SETTINGS_CACHE["list"]["only_load"]) Then $MM_SETTINGS_CACHE["list"]["only_load"] = False
If VersionCompare($MM_SETTINGS_CACHE["version"], "0.93.4.0") < 0 Then
If MapExists($MM_SETTINGS_CACHE, "preset") And IsMap($MM_SETTINGS_CACHE["preset"]) And MapExists($MM_SETTINGS_CACHE["preset"], "current") And IsString($MM_SETTINGS_CACHE["preset"]["current"]) Then $MM_SETTINGS_CACHE["game"]["preset"] = $MM_SETTINGS_CACHE["preset"]["current"]
MapRemove($MM_SETTINGS_CACHE, "preset")
EndIf
If Not MapExists($MM_SETTINGS_CACHE["game"], "preset") Or Not IsString($MM_SETTINGS_CACHE["game"]["preset"]) Then $MM_SETTINGS_CACHE["game"]["preset"] = ""
If VersionCompare($MM_SETTINGS_CACHE["version"], $MM_VERSION_NUMBER) < 0 Then $MM_SETTINGS_CACHE["version"] = $MM_VERSION_NUMBER
EndFunc
Func __Settings_Init()
$MM_SETTINGS_INIT = True
__Settings_Load()
EndFunc
Func __Settings_Load()
$MM_SETTINGS_CACHE = Jsmn_Decode(FileRead($MM_SETTINGS_PATH))
__Settings_Validate()
$MM_SETTINGS_LANGUAGE = $MM_SETTINGS_CACHE["language"]
$MM_GAME_EXE = Settings_Get("exe")
EndFunc
Global $MM_SELECTED_MOD = -1
Global $MM_LIST_MAP = MapEmpty()
Global $MM_LIST_FILE_CONTENT
Global $MM_LIST_CONTENT[1][$MOD_TOTAL]
Func Mod_ListLoad()
_TraceStart("ModList: Load")
Local $aModList_Dir, $aModList_File, $iFirstDisabled = -1
ReDim $MM_LIST_CONTENT[1][$MOD_TOTAL]
$MM_LIST_CONTENT[0][0] = 0
$MM_LIST_CONTENT[0][$MOD_IS_ENABLED] = "$MOD_IS_ENABLED"
$MM_LIST_CONTENT[0][$MOD_IS_EXIST] = "$MOD_IS_EXIST"
$MM_LIST_CONTENT[0][$MOD_CAPTION] = "$MOD_CAPTION"
$MM_LIST_CONTENT[0][$MOD_ITEM_ID] = "$MOD_ITEM_ID"
$MM_LIST_CONTENT[0][$MOD_PARENT_ID] = "$MOD_PARENT_ID"
$MM_LIST_FILE_CONTENT = FileRead($MM_LIST_FILE_PATH)
_FileReadToArray($MM_LIST_FILE_PATH, $aModList_File)
_ArrayReverse($aModList_File, 1)
If Not IsArray($aModList_File) Then Dim $aModList_File[1] = [0]
$aModList_Dir = _FileListToArray($MM_LIST_DIR_PATH, "*", $FLTA_FOLDERS)
If Not IsArray($aModList_Dir) Then Dim $aModList_Dir[1] = [0]
ReDim $MM_LIST_CONTENT[1 + $aModList_File[0] + $aModList_Dir[0]][$MOD_TOTAL]
For $i = 1 To $aModList_File[0]
_ArraySearch($MM_LIST_CONTENT, $aModList_File[$i], 1, Default, Default, Default, Default, 0)
If @error And StringInStr($aModList_File[$i], "_MM_") <> 1 Then
$MM_LIST_CONTENT[0][0] += 1
__Mod_LoadInfo($MM_LIST_CONTENT[0][0], $aModList_File[$i], True)
EndIf
Next
For $i = 1 To $aModList_Dir[0]
_ArraySearch($MM_LIST_CONTENT, $aModList_Dir[$i], 1, Default, Default, Default, Default, 0)
If @error And StringInStr($aModList_Dir[$i], "_MM_") <> 1 Then
$MM_LIST_CONTENT[0][0] += 1
__Mod_LoadInfo($MM_LIST_CONTENT[0][0], $aModList_Dir[$i], False)
If $iFirstDisabled < 1 Then $iFirstDisabled = $MM_LIST_CONTENT[0][0]
EndIf
Next
_Trace("ModList: Sort")
ReDim $MM_LIST_CONTENT[1 + $MM_LIST_CONTENT[0][0]][$MOD_TOTAL]
If $iFirstDisabled > 0 Then _ArraySort($MM_LIST_CONTENT, Default, $iFirstDisabled, Default, $MOD_CAPTION)
_TraceEnd()
EndFunc
Func Mod_CacheClear()
$MM_LIST_MAP = MapEmpty()
EndFunc
Func __Mod_LoadInfo(Const $iIndex, Const ByRef $sId, Const $bIsEnabled)
$MM_LIST_CONTENT[$iIndex][$MOD_ID] = $sId
$MM_LIST_CONTENT[$iIndex][$MOD_IS_ENABLED] = $bIsEnabled
$MM_LIST_CONTENT[$iIndex][$MOD_IS_EXIST] = FileExists($MM_LIST_DIR_PATH & "\" & $sId & "\") ? True : False
If $MM_LIST_CONTENT[$iIndex][$MOD_IS_EXIST] And Not MapExists($MM_LIST_MAP, $sID) Then
$MM_LIST_MAP[$sId] = Jsmn_Decode(FileRead($MM_LIST_DIR_PATH & "\" & $sId & "\mod.json"))
If Not IsMap($MM_LIST_MAP[$sId]) Then __Mod_LoadInfoFromINI($MM_LIST_MAP[$sId], $MM_LIST_DIR_PATH & "\" & $sId)
EndIf
If Not IsMap($MM_LIST_MAP[$sId]) Then $MM_LIST_MAP[$sId] = MapEmpty()
__Mod_Validate($MM_LIST_MAP[$sId])
$MM_LIST_CONTENT[$iIndex][$MOD_CAPTION] = Mod_Get("caption", $iIndex)
EndFunc
Func __Mod_Validate(ByRef $Map)
Local $aItems
If Not MapExists($Map, "platform") Or Not IsString($Map["platform"]) Then $Map["platform"] = "era"
If Not MapExists($Map, "info_version") Or Not IsString($Map["info_version"]) Then $Map["info_version"] = "1.0"
If Not MapExists($Map, "mod_version") Or Not IsString($Map["mod_version"]) Then $Map["mod_version"] = "0.0"
If Not MapExists($Map, "caption") Or Not IsMap($Map["caption"]) Then $Map["caption"] = MapEmpty()
If Not MapExists($Map, "description") Or Not IsMap($Map["description"]) Then $Map["description"] = MapEmpty()
If Not MapExists($Map["description"], "short") Or Not IsMap($Map["description"]["short"]) Then $Map["description"]["short"] = MapEmpty()
If Not MapExists($Map["description"], "full") Or Not IsMap($Map["description"]["full"]) Then $Map["description"]["full"] = MapEmpty()
For $i = 1 To $MM_LNG_LIST[0][0]
If Not MapExists($Map["caption"], $MM_LNG_LIST[$i][$MM_LNG_CODE]) Or Not IsString($Map["caption"][$MM_LNG_LIST[$i][$MM_LNG_CODE]]) Then $Map["caption"][$MM_LNG_LIST[$i][$MM_LNG_CODE]] = ""
If Not MapExists($Map["description"]["short"], $MM_LNG_LIST[$i][$MM_LNG_CODE]) Or Not IsString($Map["description"]["short"][$MM_LNG_LIST[$i][$MM_LNG_CODE]]) Then $Map["description"]["short"][$MM_LNG_LIST[$i][$MM_LNG_CODE]] = ""
If Not MapExists($Map["description"]["full"], $MM_LNG_LIST[$i][$MM_LNG_CODE]) Or Not IsString($Map["description"]["full"][$MM_LNG_LIST[$i][$MM_LNG_CODE]]) Then $Map["description"]["full"][$MM_LNG_LIST[$i][$MM_LNG_CODE]] = ""
Next
If Not MapExists($Map, "author") Or Not IsString($Map["author"]) Then $Map["author"] = ""
If Not MapExists($Map, "homepage") Or Not IsString($Map["homepage"]) Then $Map["homepage"] = ""
If Not MapExists($Map, "icon") Or Not IsMap($Map["icon"]) Then $Map["icon"] = MapEmpty()
If Not MapExists($Map["icon"], "file") Or Not IsString($Map["icon"]["file"]) Then $Map["icon"]["file"] = ""
If Not MapExists($Map["icon"], "index") Or $Map["icon"]["file"] = "" Then $Map["icon"]["index"] = 0
$Map["icon"]["index"] = Int($Map["icon"]["index"])
If Not MapExists($Map, "priority") Then $Map["priority"] = 0
$Map["priority"] = Int($Map["priority"])
If $Map["priority"] < -100 Then $Map["priority"] = -100
If $Map["priority"] > 100 Then $Map["priority"] = 100
If Not MapExists($Map, "compatibility") Or Not IsMap($Map["compatibility"]) Then $Map["compatibility"] = MapEmpty()
If Not MapExists($Map["compatibility"], "class") Or Not IsString($Map["compatibility"]["class"]) Then $Map["compatibility"]["class"] = "default"
$Map["compatibility"]["class"] = StringLower($Map["compatibility"]["class"])
If $Map["compatibility"]["class"] <> "default" And $Map["compatibility"]["class"] <> "all" And $Map["compatibility"]["class"] <> "none" Then $Map["compatibility"]["class"] = "default"
If Not MapExists($Map["compatibility"], "entries") Then $Map["compatibility"]["entries"] = MapEmpty()
$aItems = MapKeys($Map["compatibility"]["entries"])
For $i = 0 To UBound($aItems) - 1
If Not IsBool($Map["compatibility"]["entries"][$aItems[$i]]) Then $Map["compatibility"]["entries"][$aItems[$i]] = $Map["compatibility"]["entries"][$aItems[$i]] ? True : False
Next
If Not MapExists($Map, "plugins") Then $Map["plugins"] = MapEmpty()
$aItems = MapKeys($Map["plugins"])
For $i = 0 To UBound($aItems) - 1
If Not IsMap($Map["plugins"][$aItems[$i]]) Then $Map["plugins"][$aItems[$i]] = MapEmpty()
If Not MapExists($Map["plugins"][$aItems[$i]], "default") Or Not IsBool($Map["plugins"][$aItems[$i]]["default"]) Then $Map["plugins"][$aItems[$i]]["default"] = True
If Not MapExists($Map["plugins"][$aItems[$i]], "caption") Or Not IsMap($Map["plugins"][$aItems[$i]]["caption"]) Then $Map["plugins"][$aItems[$i]]["caption"] = MapEmpty()
If Not MapExists($Map["plugins"][$aItems[$i]], "description") Or Not IsMap($Map["plugins"][$aItems[$i]]["description"]) Then $Map["plugins"][$aItems[$i]]["description"] = MapEmpty()
For $j = 1 To $MM_LNG_LIST[0][0]
If Not MapExists($Map["plugins"][$aItems[$i]]["caption"], $MM_LNG_LIST[$j][$MM_LNG_CODE]) Or Not IsString($Map["plugins"][$aItems[$i]]["caption"][$MM_LNG_LIST[$j][$MM_LNG_CODE]]) Then $Map["plugins"][$aItems[$i]]["caption"][$MM_LNG_LIST[$j][$MM_LNG_CODE]] = ""
If Not MapExists($Map["plugins"][$aItems[$i]]["description"], $MM_LNG_LIST[$j][$MM_LNG_CODE]) Or Not IsString($Map["plugins"][$aItems[$i]]["description"][$MM_LNG_LIST[$j][$MM_LNG_CODE]]) Then $Map["plugins"][$aItems[$i]]["description"][$MM_LNG_LIST[$j][$MM_LNG_CODE]] = ""
Next
Next
If Not MapExists($Map, "category") Or Not IsString($Map["category"]) Then $Map["category"] = ""
EndFunc
Func __Mod_LoadInfoFromINI(ByRef $Map, Const $sDir)
If Not IsMap($Map) Then $Map = MapEmpty()
$Map["caption"] = MapEmpty()
$Map["description"] = MapEmpty()
$Map["description"]["full"] = MapEmpty()
For $i = 1 To $MM_LNG_LIST[0][0]
$Map["caption"][$MM_LNG_LIST[$i][$MM_LNG_CODE]] = IniRead($sDir & "\mod_info.ini", "info", "Caption." & $MM_LNG_LIST[$i][$MM_LNG_CODE], "")
$Map["description"]["full"][$MM_LNG_LIST[$i][$MM_LNG_CODE]] = IniRead($sDir & "\mod_info.ini", "info", "Description File." & $MM_LNG_LIST[$i][$MM_LNG_CODE], "")
Next
$Map["caption"]["en_US"] = IniRead($sDir & "\mod_info.ini", "info", "Caption", "")
$Map["description"]["full"]["en_US"] = IniRead($sDir & "\mod_info.ini", "info", "Description File", "")
$Map["author"] = IniRead($sDir & "\mod_info.ini", "info", "Author", "")
$Map["homepage"] = IniRead($sDir & "\mod_info.ini", "info", "Homepage", "")
$Map["icon"] = MapEmpty()
$Map["icon"]["file"] = IniRead($sDir & "\mod_info.ini", "info", "Icon File", "")
$Map["icon"]["index"] = IniRead($sDir & "\mod_info.ini", "info", "Icon Index", "")
$Map["mod_version"] = IniRead($sDir & "\mod_info.ini", "info", "Version", "0.0")
$Map["priority"] = IniRead($sDir & "\mod_info.ini", "info", "Priority", 0)
$Map["compatibility"] = MapEmpty()
$Map["compatibility"]["class"] = IniRead($sDir & "\mod_info.ini", "info", "Compatibility Class", "Default")
$Map["compatibility"]["entries"] = MapEmpty()
Local $aTemp = IniReadSection($sDir & "\mod_info.ini", "Compatibility")
If Not @error Then
For $i = 1 To $aTemp[0][0]
$Map["compatibility"]["entries"][$aTemp[$i][0]] = Int($aTemp[$i][1]) > 0 ? True : False
Next
EndIf
EndFunc
Func Mod_SetSelectedMod(Const $iMod)
$MM_SELECTED_MOD = $iMod
EndFunc
Func Mod_GetSelectedMod()
Return $MM_SELECTED_MOD
EndFunc
Func Mod_Get(Const $sPath, $iModIndex = -1)
Local $vReturn = ""
Local $aParts = StringSplit($sPath, "\")
If $iModIndex = -1 Then $iModIndex = Mod_GetSelectedMod()
Local $sModId = $MM_LIST_CONTENT[$iModIndex][$MOD_ID]
If $sPath = "id" Then
$vReturn = $sModId
ElseIf $sPath = "dir" Then
$vReturn = $MM_LIST_DIR_PATH & "\" & $MM_LIST_CONTENT[$iModIndex][$MOD_ID]
ElseIf $sPath = "dir\" Then
$vReturn = $MM_LIST_DIR_PATH & "\" & $MM_LIST_CONTENT[$iModIndex][$MOD_ID] & "\"
ElseIf $sPath = "info_file" Then
$vReturn = $MM_LIST_DIR_PATH & "\" & $MM_LIST_CONTENT[$iModIndex][$MOD_ID] & "\mod.json"
ElseIf $sPath = "icon_path" Then
Local $sIconPath = Mod_Get("icon\file", $iModIndex)
$vReturn = $sIconPath ?($MM_LIST_DIR_PATH & "\" & $sModId & "\" & $sIconPath) :(@ScriptDir & "\icons\folder-grey.ico")
ElseIf $sPath = "caption" Then
$vReturn = $MM_LIST_MAP[$sModId]["caption"][$MM_LANGUAGE_CODE]
If $vReturn = "" Then $vReturn = $MM_LIST_MAP[$sModId]["caption"]["en_US"]
If $vReturn = "" Then $vReturn = $MM_LIST_CONTENT[$iModIndex][$MOD_ID]
ElseIf $aParts[1] = "caption" And $aParts[2] = "formatted" Then
$vReturn = Mod_Get("caption", $iModIndex)
Local $sCategory = $MM_LIST_MAP[$sModId]["category"]
If $sCategory <> "" Then $vReturn = StringFormat("[%s] %s",($aParts[0] > 2 And $aParts[3] = "caps") ? StringUpper(Lng_GetCategory($sCategory)) : Lng_GetCategory($sCategory), $vReturn)
ElseIf $aParts[1] = "description" Then
$vReturn = $MM_LIST_MAP[$sModId]["description"][$aParts[2]][$MM_LANGUAGE_CODE]
If $vReturn = "" Then $vReturn = $MM_LIST_MAP[$sModId]["description"][$aParts[2]]["en_US"]
ElseIf $aParts[1] = "plugins" And Not MapExists($MM_LIST_MAP[$sModId]["plugins"], $aParts[2]) Then
Switch $aParts[3]
Case "caption"
$vReturn = $aParts[2]
Case "description"
$vReturn = Lng_Get("info_group.no_info")
Case "default"
$vReturn = False
Case "hidden"
$vReturn = False
EndSwitch
ElseIf $aParts[1] = "plugins" And $aParts[3] = "caption" Then
$vReturn = $MM_LIST_MAP[$sModId]["plugins"][$aParts[2]]["caption"][$MM_LANGUAGE_CODE]
If $vReturn = "" Then $vReturn = $MM_LIST_MAP[$sModId]["plugins"][$aParts[2]]["caption"]["en_US"]
If $vReturn = "" Then $vReturn = $aParts[2]
ElseIf $aParts[1] = "plugins" And $aParts[3] = "description" Then
$vReturn = $MM_LIST_MAP[$sModId]["plugins"][$aParts[2]]["description"][$MM_LANGUAGE_CODE]
If $vReturn = "" Then $vReturn = $MM_LIST_MAP[$sModId]["plugins"][$aParts[2]]["description"]["en_US"]
If $vReturn = "" Then $vReturn = Lng_Get("info_group.no_info")
Elseif $sPath = "compatibility\class" Then
$vReturn = $MM_LIST_MAP[$sModId]["compatibility"]["class"]
ElseIf $aParts[1] = "compatibility" And $aParts[2] = "entries" Then
$vReturn = MapExists($MM_LIST_MAP[$sModId]["compatibility"]["entries"], $aParts[3]) ?($MM_LIST_MAP[$sModId]["compatibility"]["entries"][$aParts[3]] ? 1 : -1) : 0
Else
Switch $aParts[0]
Case 1
$vReturn = $MM_LIST_MAP[$sModId][$aParts[1]]
Case 2
$vReturn = $MM_LIST_MAP[$sModId][$aParts[1]][$aParts[2]]
Case 3
$vReturn = $MM_LIST_MAP[$sModId][$aParts[1]][$aParts[2]][$aParts[3]]
EndSwitch
EndIf
Return $vReturn
EndFunc
Func Mod_Save(Const $iModIndex, Const $mModData)
Local $sSaveTo = Mod_Get("info_file", $iModIndex)
Local $sText = Jsmn_Encode($mModData, $JSMN_PRETTY_PRINT + $JSMN_UNESCAPED_UNICODE + $JSMN_UNESCAPED_SLASHES)
If Not @error Then
FileDelete($sSaveTo)
FileWrite($sSaveTo, $sText)
EndIf
EndFunc
Func Mod_CreatePackage(Const $iModIndex, Const $sSavePath)
Local $s7zTempDir = _TempFile()
DirCreate($s7zTempDir)
FileCopy(@ScriptDir & '\7z\7z.*', $s7zTempDir & '\7z\7z.*', $FC_OVERWRITE + $FC_CREATEPATH)
Local $hFile = SFX_FileOpen($s7zTempDir & '\7z\7z.sfx')
If Mod_Get("icon\file", $iModIndex) <> "" Then SFX_UpdateIcon($hFile, Mod_Get("dir\", $iModIndex) & Mod_Get("icon\file", $iModIndex))
SFX_UpdateModDirName($hFile, Mod_Get("id", $iModIndex))
SFX_FileClose($hFile)
Local $sCommand = StringFormat('%s a %s "Mods\%s" -sfx7z.sfx', '"' & $s7zTempDir & '\7z\7z.exe"', '"' & $sSavePath & '"', Mod_Get("id", $iModIndex))
Local $iPid = Run($sCommand, $MM_GAME_DIR, @SW_MINIMIZE)
_WinAPI_ShellChangeNotify($SHCNE_ASSOCCHANGED, $SHCNF_FLUSH)
Return $iPid
EndFunc
Func Mod_IsCompatible(Const $iModIndex1, Const $iModIndex2)
If Not $MM_LIST_CONTENT[$iModIndex1][$MOD_IS_ENABLED] Or Not $MM_LIST_CONTENT[$iModIndex2][$MOD_IS_ENABLED] Then
Return True
Else
Local $i1To2 = Mod_Get("compatibility\entries\" & $MM_LIST_CONTENT[$iModIndex2][$MOD_ID], $iModIndex1)
Local $i2To1 = Mod_Get("compatibility\entries\" & $MM_LIST_CONTENT[$iModIndex1][$MOD_ID], $iModIndex2)
If $i1To2 > 0 Then
Return True
ElseIf $i1To2 < 0 Then
Return False
ElseIf $i2To1 > 0 Then
Return True
ElseIf $i2To1 < 0 Then
Return False
Else
Local $sType1 = Mod_Get("compatibility\class", $iModIndex1)
Local $sType2 = Mod_Get("compatibility\class", $iModIndex2)
If($sType1 = "none" And($sType2 = "none" Or $sType2 = "default")) Or($sType2 = "none" And($sType1 = "none" Or $sType1 = "default")) Then
Return False
Else
Return True
EndIf
EndIf
EndIf
EndFunc
Func Mod_ListIsActual()
Local $bActual = True
Local $sListFile = $MM_LIST_FILE_CONTENT
Local $aModList = $MM_LIST_CONTENT
Mod_ListLoad()
If $aModList[0][0] <> $MM_LIST_CONTENT[0][0] Then
$bActual = False
Else
For $iCount = 1 To $aModList[0][0]
If $aModList[$iCount][$MOD_ID] <> $MM_LIST_CONTENT[$iCount][$MOD_ID] Then
$bActual = False
ExitLoop
EndIf
Next
EndIf
$MM_LIST_FILE_CONTENT = $sListFile
$MM_LIST_CONTENT = $aModList
Return $bActual
EndFunc
Func Mod_ReEnable($sModID)
Local $iModIndex = Mod_GetIndexByID($sModID)
If $iModIndex <> -1 Then
Mod_Disable($iModIndex)
Mod_ListLoad()
EndIf
$iModIndex = Mod_GetIndexByID($sModID)
If $iModIndex <> -1 Then
Mod_Enable($iModIndex)
Else
FileWriteLine($MM_LIST_FILE_PATH, $sModID)
EndIf
EndFunc
Func Mod_ListSave()
If Not FileDelete($MM_LIST_FILE_PATH) And FileExists($MM_LIST_FILE_PATH) Then
$MM_LIST_CANT_WORK = True
EndIf
Local $sWrite = ""
For $iCount = $MM_LIST_CONTENT[0][0] To 1 Step -1
If $MM_LIST_CONTENT[$iCount][$MOD_IS_ENABLED] Then
$sWrite &= $MM_LIST_CONTENT[$iCount][0] & @CRLF
EndIf
Next
If Not FileWrite($MM_LIST_FILE_PATH, $sWrite) Then
$MM_LIST_CANT_WORK = True
EndIf
EndFunc
Func Mod_ListGetAsArray()
Local $aReturn = ArrayEmpty()
For $iCount = 1 To $MM_LIST_CONTENT[0][0]
If $MM_LIST_CONTENT[$iCount][$MOD_IS_ENABLED] Then
$aReturn[UBound($aReturn) - 1] = $MM_LIST_CONTENT[$iCount][$MOD_ID]
ReDim $aReturn[UBound($aReturn) + 1]
EndIf
Next
If UBound($aReturn) > 1 Then ReDim $aReturn[UBound($aReturn) - 1]
Return $aReturn
EndFunc
Func Mod_ListLoadFromMemory(Const $aModList)
Mod_DisableAll()
Mod_ListLoad()
For $i = UBound($aModList) - 1 To 0 Step -1
If $aModList[$i] <> "" And MapExists($MM_LIST_MAP, $aModList[$i]) Then Mod_Enable(Mod_GetIndexByID($aModList[$i]), True, False)
Next
Mod_ListSave()
EndFunc
Func Mod_GetIndexByID($sModID)
For $iCount = 1 To $MM_LIST_CONTENT[0][0]
If $MM_LIST_CONTENT[$iCount][0] = $sModID Then Return $iCount
Next
Return -1
EndFunc
Func Mod_ListSwap($iModIndex1, $iModIndex2, $sUpdate = True)
Local $vTemp
For $jCount = 0 To $MOD_TOTAL - 1
If $jCount = $MOD_ITEM_ID Or $jCount = $MOD_PARENT_ID Then ContinueLoop
$vTemp = $MM_LIST_CONTENT[$iModIndex1][$jCount]
$MM_LIST_CONTENT[$iModIndex1][$jCount] = $MM_LIST_CONTENT[$iModIndex2][$jCount]
$MM_LIST_CONTENT[$iModIndex2][$jCount] = $vTemp
Next
If $sUpdate Then Mod_ListSave()
EndFunc
Func Mod_Disable($iModIndex, $sUpdate = True)
_Trace(StringFormat("Mod disable: %s", $MM_LIST_CONTENT[$iModIndex][$MOD_ID]))
If Not $MM_LIST_CONTENT[$iModIndex][$MOD_IS_ENABLED] Then Return
$MM_LIST_CONTENT[$iModIndex][$MOD_IS_ENABLED] = False
If $sUpdate Then Mod_ListSave()
EndFunc
Func Mod_DisableAll()
For $i = 1 To $MM_LIST_CONTENT[0][0]
Mod_Disable($i, False)
Next
Mod_ListSave()
EndFunc
Func Mod_Delete($iModIndex)
FileRecycle($MM_LIST_DIR_PATH & "\" & $MM_LIST_CONTENT[$iModIndex][0])
Mod_Disable($iModIndex)
EndFunc
Func Mod_Enable($iModIndex, $bIgnorePrioirity = False, $bUpdate = True)
_Trace(StringFormat("Mod enable: %s", $MM_LIST_CONTENT[$iModIndex][$MOD_ID]))
If $MM_LIST_CONTENT[$iModIndex][$MOD_IS_ENABLED] Then Return
$MM_LIST_CONTENT[$iModIndex][$MOD_IS_ENABLED] = True
For $iIndex = $iModIndex To 2 Step -1
If Not $bIgnorePrioirity And $MM_LIST_CONTENT[$iIndex - 1][$MOD_IS_ENABLED] And Mod_Get("priority", $iIndex - 1) > Mod_Get("priority", $iIndex) Then ExitLoop
Mod_ListSwap($iIndex, $iIndex - 1, False)
Next
If $bUpdate Then Mod_ListSave()
EndFunc
Func Mod_ModIsInstalled($sModName)
For $iCount = 1 To $MM_LIST_CONTENT[0][0]
If $MM_LIST_CONTENT[$iCount][$MOD_ID] = $sModName Then Return $iCount
Next
EndFunc
Func Mod_InfoLoad(Const $sModName, Const $sFile)
Local $sReturn = FileRead($MM_LIST_DIR_PATH & "\" & $sModName & "\" & $sFile)
If @error Or $sReturn = "" Then $sReturn = Lng_Get("info_group.no_info")
Return $sReturn
EndFunc
Func Mod_ScreenListLoad(Const $sModName)
Local $aReturn = _FileListToArray($MM_LIST_DIR_PATH & "\" & $sModName & "\Screens\", Default, $FLTA_FILES, True)
If @error Then Dim $aReturn[1]
Return $aReturn
EndFunc
Func Mod_GetVersion($sModName)
Return IniRead($MM_LIST_DIR_PATH & "\" & $sModName & "\mod_info.ini", "info", "Version", "0.0")
EndFunc
Func ModEdit_Editor(Const $iModIndex)
Local Const $iSelectedMod = Mod_GetSelectedMod()
Mod_SetSelectedMod($iModIndex)
Local Const $iOptionGUIOnEventMode = AutoItSetOption("GUIOnEventMode", 0)
GUISetState(@SW_DISABLE, MM_GetCurrentWindow())
Local Const $iItemSpacing = 4
Local Const $iLabelHeight = 17
Local Const $iInputHeight = 21
Local Const $iButtonHeight = 23
Local Const $iEditHeight = $iInputHeight * 4
Local $hGUI = MapEmpty()
$hGUI.Info = $MM_LIST_MAP[Mod_Get("id")]
$hGUI.LngCode = Lng_Get("lang.code")
Local $aSize, $vRes, $nMsg
$hGUI.Form = MM_GUICreate(Lng_Get("mod_edit.caption"), 500, 278 + 50 + 4 + $iEditHeight)
If Not @Compiled Then GUISetIcon(@ScriptDir & "\icons\preferences-system.ico")
$aSize = WinGetClientSize($hGUI.Form)
$hGUI.GroupCaption = GUICtrlCreateGroup(Lng_Get("mod_edit.group_caption.caption"), $iItemSpacing, $iItemSpacing, $aSize[0] - 2 * $iItemSpacing, 9 * $iItemSpacing + 25 + 2 * $iButtonHeight + 1 * $iLabelHeight + $iEditHeight)
$hGUI.LabelCaptionLanguage = GUICtrlCreateLabel(Lng_Get("mod_edit.group_caption.language"), 2 * $iItemSpacing, 5 * $iItemSpacing, Default, $iLabelHeight, $SS_CENTERIMAGE)
$hGUI.ComboCaptionLanguage = GUICtrlCreateCombo("", GUICtrlGetPos($hGUI.LabelCaptionLanguage).NextX, 5 * $iItemSpacing, $aSize[0] - GUICtrlGetPos($hGUI.LabelCaptionLanguage).NextX - 3 * $iItemSpacing, 25, BitOR($CBS_DROPDOWNLIST, $CBS_AUTOHSCROLL))
GUICtrlSetData($hGUI.ComboCaptionLanguage, _ArrayToString($MM_LNG_LIST, Default, 1, Default, "|", 2, 2))
GUICtrlSetData($hGUI.ComboCaptionLanguage, Lng_Get("lang.name"))
$hGUI.LabelCaptionCaption = GUICtrlCreateLabel(Lng_Get("mod_edit.group_caption.caption_label"), 2 * $iItemSpacing, GUICtrlGetPos($hGUI.ComboCaptionLanguage).NextY + $iItemSpacing, Default, $iLabelHeight, $SS_CENTERIMAGE)
$hGUI.InputCaptionCaption = GUICtrlCreateInput($hGUI.Info["caption"][$hGUI.LngCode], GUICtrlGetPos($hGUI.LabelCaptionCaption).NextX, GUICtrlGetPos($hGUI.LabelCaptionCaption).Top, $aSize[0] - GUICtrlGetPos($hGUI.LabelCaptionCaption).NextX - 3 * $iItemSpacing, $iInputHeight)
$hGUI.LabelDescFile = GUICtrlCreateLabel(Lng_Get("mod_edit.group_caption.description_file"), 2 * $iItemSpacing, GUICtrlGetPos($hGUI.InputCaptionCaption).NextY + $iItemSpacing, Default, $iLabelHeight, $SS_CENTERIMAGE)
$hGUI.InputDescFile = GUICtrlCreateInput($hGUI.Info["description"]["full"][$hGUI.LngCode], GUICtrlGetPos($hGUI.LabelDescFile).NextX, GUICtrlGetPos($hGUI.LabelDescFile).Top, $aSize[0] - GUICtrlGetPos($hGUI.LabelDescFile).NextX - 5 * $iItemSpacing - 2 * $iButtonHeight, $iInputHeight, $ES_READONLY)
$hGUI.ButtonCaptionFile = GUICtrlCreateButton("...", GUICtrlGetPos($hGUI.InputDescFile).NextX + $iItemSpacing, GUICtrlGetPos($hGUI.InputDescFile).Top - 1, $iButtonHeight, $iButtonHeight)
$hGUI.ButtonCaptionFileRemove = GUICtrlCreateButton("X", GUICtrlGetPos($hGUI.ButtonCaptionFile).NextX + $iItemSpacing, GUICtrlGetPos($hGUI.InputDescFile).Top - 1, $iButtonHeight, $iButtonHeight)
$hGUI.LabelDescShort = GUICtrlCreateLabel(Lng_Get("mod_edit.group_caption.description_short"), 2 * $iItemSpacing, GUICtrlGetPos($hGUI.ButtonCaptionFileRemove).NextY + $iItemSpacing, Default, $iLabelHeight, $SS_CENTERIMAGE)
$hGUI.ButtonDescFromFile = GUICtrlCreateButton(Lng_Get("mod_edit.group_caption.description_short_from_file"), $aSize[0] - 90 - 3 * $iItemSpacing, GUICtrlGetPos($hGUI.LabelDescShort).Top, 90, $iButtonHeight)
GUICtrlSetImage($hGUI.ButtonDescFromFile, @ScriptDir & "\icons\arrow-down-double.ico")
$hGUI.EditDescShort = GUICtrlCreateEdit($hGUI.Info["description"]["short"][$hGUI.LngCode], 2 * $iItemSpacing, GUICtrlGetPos($hGUI.LabelDescShort).NextY + 2 * $iItemSpacing, $aSize[0] - 5 * $iItemSpacing, $iEditHeight)
GUICtrlSetLimit($hGUI.EditDescShort, 500)
$hGUI.GroupOther = GUICtrlCreateGroup(Lng_Get("mod_edit.group_other.caption"), $iItemSpacing, GUICtrlGetPos($hGUI.GroupCaption).NextY, $aSize[0] - 2 * $iItemSpacing, 8 * $iItemSpacing + 3 * $iButtonHeight + $iInputHeight)
$hGUI.LabelModVersion = GUICtrlCreateLabel(Lng_Get("mod_edit.group_other.mod_version"), 2 * $iItemSpacing, GUICtrlGetPos($hGUI.GroupOther).Top + 4 * $iItemSpacing, Default, $iLabelHeight, $SS_CENTERIMAGE)
$hGUI.InputModVersion = GUICtrlCreateInput($hGUI.Info["mod_version"], GUICtrlGetPos($hGUI.LabelModVersion).NextX, GUICtrlGetPos($hGUI.LabelModVersion).Top,($aSize[0] / 2) - GUICtrlGetPos($hGUI.LabelModVersion).NextX - $iButtonHeight - 2 * $iItemSpacing, $iInputHeight)
$hGUI.ButtonModVersion = GUICtrlCreateButton("+", GUICtrlGetPos($hGUI.InputModVersion).NextX + $iItemSpacing, GUICtrlGetPos($hGUI.InputModVersion).Top - 1, $iButtonHeight, $iButtonHeight)
$hGUI.LabelAuthor = GUICtrlCreateLabel(Lng_Get("mod_edit.group_other.author"), GUICtrlGetPos($hGUI.ButtonModVersion).NextX + 2 * $iItemSpacing, GUICtrlGetPos($hGUI.LabelModVersion).Top, Default, $iLabelHeight, $SS_CENTERIMAGE)
$hGUI.InputAuthor = GUICtrlCreateInput($hGUI.Info["author"], GUICtrlGetPos($hGUI.LabelAuthor).NextX, GUICtrlGetPos($hGUI.LabelAuthor).Top, $aSize[0] - GUICtrlGetPos($hGUI.LabelAuthor).NextX - 3 * $iItemSpacing, $iInputHeight)
$hGUI.LabelPriority = GUICtrlCreateLabel(Lng_Get("mod_edit.group_other.priority"), 2 * $iItemSpacing, GUICtrlGetPos($hGUI.ButtonModVersion).NextY + $iItemSpacing, Default, $iLabelHeight, $SS_CENTERIMAGE)
$hGUI.InputPriority = GUICtrlCreateInput($hGUI.Info["priority"], GUICtrlGetPos($hGUI.LabelPriority).NextX, GUICtrlGetPos($hGUI.LabelPriority).Top,($aSize[0] / 2) - GUICtrlGetPos($hGUI.LabelPriority).NextX - $iItemSpacing, $iInputHeight, $ES_READONLY)
$hGUI.UpDownPriority = GUICtrlCreateUpdown($hGUI.InputPriority)
GUICtrlSetLimit($hGUI.UpDownPriority, 100, -100)
$hGUI.IconSelected = $hGUI.Info["icon"]["file"] <> ""
$hGUI.LabelIcon = GUICtrlCreateLabel(Lng_Get("mod_edit.group_other.icon"), GUICtrlGetPos($hGUI.UpDownPriority).NextX + 2 * $iItemSpacing, GUICtrlGetPos($hGUI.UpDownPriority).Top, Default, $iLabelHeight, $SS_CENTERIMAGE)
$hGUI.IconIcon = GUICtrlCreateIcon($MM_LIST_DIR_PATH & "\" & $MM_LIST_CONTENT[$iModIndex][0] & "\" & $hGUI.Info["icon"]["file"], -($hGUI.Info["icon"]["index"] + 1), GUICtrlGetPos($hGUI.LabelIcon).NextX, GUICtrlGetPos($hGUI.LabelIcon).Top+2, 16, 16)
If $hGUI.IconIcon = 0 Then
$hGUI.IconSelected = False
$hGUI.IconIcon = GUICtrlCreateIcon(@ScriptDir & "\icons\folder-grey.ico", 0, GUICtrlGetPos($hGUI.LabelIcon).NextX, GUICtrlGetPos($hGUI.LabelIcon).Top, 16, 16)
EndIf
GUICtrlSetCursor($hGUI.IconIcon, 0)
$hGUI.ButtonIcon = GUICtrlCreateButton("X", GUICtrlGetPos($hGUI.IconIcon).NextX + $iItemSpacing, GUICtrlGetPos($hGUI.InputPriority).Top - 1, $iButtonHeight, $iButtonHeight)
$hGUI.LabelHomepage = GUICtrlCreateLabel(Lng_Get("mod_edit.group_other.homepage"), 2 * $iItemSpacing, GUICtrlGetPos($hGUI.ButtonIcon).NextY + $iItemSpacing, Default, $iLabelHeight, $SS_CENTERIMAGE)
$hGUI.InputHomepage = GUICtrlCreateInput($hGUI.Info["homepage"], GUICtrlGetPos($hGUI.LabelHomepage).NextX, GUICtrlGetPos($hGUI.LabelHomepage).Top, $aSize[0] - GUICtrlGetPos($hGUI.LabelHomepage).NextX - 3 * $iItemSpacing, $iInputHeight)
$hGUI.LabelCategory = GUICtrlCreateLabel(Lng_Get("mod_edit.group_other.category"), 2 * $iItemSpacing, GUICtrlGetPos($hGUI.InputHomepage).NextY + $iItemSpacing, Default, $iLabelHeight, $SS_CENTERIMAGE)
$hGUI.ComboCategory = GUICtrlCreateCombo("", GUICtrlGetPos($hGUI.LabelCategory).NextX, GUICtrlGetPos($hGUI.LabelCategory).Top, $aSize[0] - GUICtrlGetPos($hGUI.LabelCategory).NextX - 3 * $iItemSpacing, 25, BitOR($CBS_DROPDOWN, $CBS_AUTOHSCROLL))
GUICtrlSetData($hGUI.ComboCategory, __ModEdit_PrepareCategoryList($hGUI.Info["category"]))
If Lng_Get("category." & $hGUI.Info["category"]) <> "" Then GUICtrlSetData($hGUI.ComboCategory, Lng_Get("category." & $hGUI.Info["category"]))
$hGUI.GroupCompatibility = GUICtrlCreateGroup(Lng_Get("mod_edit.group_compatibility.caption"), $iItemSpacing, GUICtrlGetPos($hGUI.GroupOther).NextY, $aSize[0] - 2 * $iItemSpacing, 5 * $iItemSpacing + 25)
$hGUI.LabelCompatibilityClass = GUICtrlCreateLabel(Lng_Get("mod_edit.group_compatibility.class"), 2 * $iItemSpacing, GUICtrlGetPos($hGUI.GroupCompatibility).Top + 4 * $iItemSpacing, Default, $iLabelHeight, $SS_CENTERIMAGE)
$hGUI.ComboCompatibilityClass = GUICtrlCreateCombo("", GUICtrlGetPos($hGUI.LabelCompatibilityClass).NextX, GUICtrlGetPos($hGUI.LabelCompatibilityClass).Top, $aSize[0] - GUICtrlGetPos($hGUI.LabelCompatibilityClass).NextX - 3 * $iItemSpacing, 25, BitOR($CBS_DROPDOWNLIST, $CBS_AUTOHSCROLL))
GUICtrlSetData($hGUI.ComboCompatibilityClass, __ModEdit_FormatCompatibilityClass("default") & "|" & __ModEdit_FormatCompatibilityClass("all") & "|" & __ModEdit_FormatCompatibilityClass("none"))
GUICtrlSetData($hGUI.ComboCompatibilityClass, __ModEdit_FormatCompatibilityClass($hGUI.Info["compatibility"]["class"]))
$hGUI.ButtonHelp = GUICtrlCreateButton("?", 2 * $iItemSpacing, GUICtrlGetPos($hGUI.GroupCompatibility).NextY + $iItemSpacing, $iButtonHeight, $iButtonHeight)
$hGUI.ButtonSave = GUICtrlCreateButton(Lng_Get("mod_edit.save"), $aSize[0] - $iItemSpacing - 90, GUICtrlGetPos($hGUI.GroupCompatibility).NextY + $iItemSpacing, 90, $iButtonHeight)
$hGUI.ButtonCancel = GUICtrlCreateButton(Lng_Get("mod_edit.cancel"), GUICtrlGetPos($hGUI.ButtonSave).Left - 90 - $iItemSpacing, GUICtrlGetPos($hGUI.ButtonSave).Top, 90, $iButtonHeight)
__ModEdit_SetControlAccessibility($hGUI)
GUISetState(@SW_SHOW)
Local $bOk = False, $bIsCancel = False
While Not $bOk And Not $bIsCancel
$nMsg = GUIGetMsg()
Switch $nMsg
Case $GUI_EVENT_CLOSE, $hGUI.ButtonCancel
$bIsCancel = True
Case $hGUI.ComboCaptionLanguage
$hGUI["Info"]["caption"][$hGUI.LngCode] = GUICtrlRead($hGUI.InputCaptionCaption)
$hGUI["Info"]["description"]["full"][$hGUI.LngCode] = GUICtrlRead($hGUI.InputDescFile)
$hGUI["Info"]["description"]["short"][$hGUI.LngCode] = GUICtrlRead($hGUI.EditDescShort)
$hGUI.LngCode = Lng_GetCodeByName(GUICtrlRead($hGUI.ComboCaptionLanguage))
GUICtrlSetData($hGUI.InputCaptionCaption, $hGUI.Info["caption"][$hGUI.LngCode])
GUICtrlSetData($hGUI.InputDescFile, $hGUI.Info["description"]["full"][$hGUI.LngCode])
GUICtrlSetData($hGUI.EditDescShort, $hGUI.Info["description"]["short"][$hGUI.LngCode])
__ModEdit_SetControlAccessibility($hGUI)
Case $hGUI.ButtonCaptionFile
$vRes = FileOpenDialog("", Mod_Get("dir\"), "(*.*)", $FD_PATHMUSTEXIST + $FD_FILEMUSTEXIST, GUICtrlRead($hGUI.InputDescFile), $hGUI.Form)
If Not @error And StringLeft($vRes, StringLen(Mod_Get("dir\"))) = Mod_Get("dir\") Then
GUICtrlSetData($hGUI.InputDescFile, StringTrimLeft($vRes, StringLen(Mod_Get("dir\"))))
__ModEdit_SetControlAccessibility($hGUI)
EndIf
Case $hGUI.ButtonDescFromFile
GUICtrlSetData($hGUI.EditDescShort, FileRead(Mod_Get("dir\") & GUICtrlRead($hGUI.InputDescFile), 500))
Case $hGUI.ButtonCaptionFileRemove
GUICtrlSetData($hGUI.InputDescFile, "")
__ModEdit_SetControlAccessibility($hGUI)
Case $hGUI.ButtonModVersion
GUICtrlSetData($hGUI.InputModVersion, VersionIncrement(GUICtrlRead($hGUI.InputModVersion)))
Case $hGUI.IconIcon
$vRes = DllCall("shell32.dll", "int", "PickIconDlg", "hwnd", 0, "wstr", Mod_Get("dir\") & $hGUI.Info["icon"]["file"], "int", 1000, "int*", $hGUI.Info["icon"]["index"])
If Not @error And $vRes[0] And StringLeft($vRes[2], StringLen(Mod_Get("dir\"))) = Mod_Get("dir\") Then
$hGUI["Info"]["icon"]["file"] = StringTrimLeft($vRes[2], StringLen(Mod_Get("dir\")))
$hGUI["Info"]["icon"]["index"] = Int($vRes[4])
__ModEdit_SetIcon($hGUI)
__ModEdit_SetControlAccessibility($hGUI)
EndIf
Case $hGUI.ButtonIcon
$hGUI["Info"]["icon"]["file"] = ""
$hGUI["Info"]["icon"]["index"] = 0
__ModEdit_SetIcon($hGUI)
__ModEdit_SetControlAccessibility($hGUI)
Case $hGUI.ButtonHelp
ShellExecute(@ScriptDir & "\doc\mod.txt")
Case $hGUI.ButtonSave
$bOk = True
EndSwitch
WEnd
$hGUI["Info"]["caption"][$hGUI.LngCode] = GUICtrlRead($hGUI.InputCaptionCaption)
$hGUI["Info"]["description"]["full"][$hGUI.LngCode] = GUICtrlRead($hGUI.InputDescFile)
$hGUI["Info"]["description"]["short"][$hGUI.LngCode] = GUICtrlRead($hGUI.EditDescShort)
$hGUI["Info"]["mod_version"] = GUICtrlRead($hGUI.InputModVersion)
$hGUI["Info"]["author"] = GUICtrlRead($hGUI.InputAuthor)
$hGUI["Info"]["homepage"] = GUICtrlRead($hGUI.InputHomepage)
$hGUI["Info"]["priority"] = Int(GUICtrlRead($hGUI.InputPriority))
$hGUI["Info"]["compatibility"]["class"] = __ModEdit_FormattedCompatibilityClassToPlain(GUICtrlRead($hGUI.ComboCompatibilityClass))
$hGUI["Info"]["category"] = __ModEdit_FormattedCategoryToPlain(GUICtrlRead($hGUI.ComboCategory))
AutoItSetOption("GUIOnEventMode", $iOptionGUIOnEventMode)
Mod_SetSelectedMod($iSelectedMod)
If $bOk Then Mod_Save($iModIndex, $hGUI.Info)
MM_GUIDelete()
GUISetState(@SW_ENABLE, MM_GetCurrentWindow())
GUISetState(@SW_RESTORE, MM_GetCurrentWindow())
Return $bOk
EndFunc
Func __ModEdit_PrepareCategoryList(Const $sForseThis)
Local $aKeys = Lng_GetCategoryList()
Local $sReturn, $bForsedIn = False
For $i = 0 To UBound($aKeys) - 1
$sReturn &= "|" & Lng_Get("category." & $aKeys[$i])
If $aKeys[$i] = StringLower($sForseThis) Then $bForsedIn = True
Next
If Not $bForsedIn And $sForseThis <> "" Then $sReturn &= "|" & $sForseThis
Return $sReturn
EndFunc
Func __ModEdit_FormattedCategoryToPlain(Const $sCategory)
Local $aKeys = Lng_GetCategoryList()
For $i = 0 To UBound($aKeys) - 1
If Lng_Get("category." & $aKeys[$i]) = $sCategory Then Return $aKeys[$i]
Next
Return $sCategory
EndFunc
Func __ModEdit_FormatCompatibilityClass(Const $sClass)
Return StringFormat("%s - %s", $sClass, Lng_Get(StringFormat("mod_edit.group_compatibility.%s", $sClass)))
EndFunc
Func __ModEdit_FormattedCompatibilityClassToPlain(Const $sPath)
If __ModEdit_FormatCompatibilityClass("all") = $sPath Then Return "all"
If __ModEdit_FormatCompatibilityClass("default") = $sPath Then Return "default"
If __ModEdit_FormatCompatibilityClass("none") = $sPath Then Return "none"
EndFunc
Func __ModEdit_SetControlAccessibility(ByRef $hGUI)
GUICtrlSetState($hGUI.ButtonCaptionFileRemove, GUICtrlRead($hGUI.InputDescFile) <> "" ? $GUI_ENABLE : $GUI_DISABLE)
GUICtrlSetState($hGUI.ButtonDescFromFile, GUICtrlRead($hGUI.InputDescFile) <> "" ? $GUI_ENABLE : $GUI_DISABLE)
GUICtrlSetState($hGUI.ButtonIcon, $hGUI.IconSelected ? $GUI_ENABLE : $GUI_DISABLE)
EndFunc
Func __ModEdit_SetIcon(ByRef $hGUI)
$hGUI.IconSelected = $hGUI.Info["icon"]["file"] <> ""
Local $bIsOk = GUICtrlSetImage($hGUI.IconIcon, Mod_Get("dir\") & $hGUI.Info["icon"]["file"], -($hGUI.Info["icon"]["index"] + 1))
If Not $bIsOk Then
$hGUI.IconSelected = False
GUICtrlSetImage($hGUI.IconIcon, @ScriptDir & "\icons\folder-grey.ico", 0)
EndIf
EndFunc
Func PackedMod_IsPackedMod($sFilePath)
Local $sModName = PackedMod_GetPackedName($sFilePath)
If $sModName <> "" Then
Return $sModName
Else
Return False
EndIf
EndFunc
Func PackedMod_GetPackedName($sFilePath)
If StringInStr(FileGetAttrib($sFilePath), "D") Then Return ""
Local $sStdOut, $aRegExp, $sModName = ""
Local $h7z = Run(@ScriptDir & '\7z\7z.exe l "' & $sFilePath & '"', @ScriptDir & "\7z\", @SW_HIDE, $STDERR_CHILD + $STDOUT_CHILD)
While True
$sStdOut = StdoutRead($h7z)
If @error Then ExitLoop
$aRegExp = StringRegExp($sStdOut, "Mods\\(.*?)\\", 1)
If IsArray($aRegExp) Then $sModName = $aRegExp[0]
WEnd
Return $sModName
EndFunc
Func PackedMod_LoadInfo($sFilePath, ByRef $sLocalName, ByRef $sLocalDesc, ByRef $sVersion, ByRef $sMinVersion, ByRef $sAuthor, ByRef $sWebSite)
Local $sModName = PackedMod_GetPackedName($sFilePath)
If $sModName = "" Then Return ""
Local $sTempDir = _TempFile()
DirCreate($sTempDir)
RunWait(@ScriptDir & '\7z\7z.exe e "' & $sFilePath & '" -o"' & $sTempDir & '\" "Mods\' & $sModName & '\mod_info.ini"', @ScriptDir & "\7z\", @SW_HIDE)
$sLocalName = IniRead($sTempDir & "\mod_info.ini", "info", "Caption." & Lng_Get("lang.code"), IniRead($sTempDir & "\mod_info.ini", "info", "Caption", ""))
Local $sDescriptonFile = IniRead($sTempDir & "\mod_info.ini", "info", "Description File." & Lng_Get("lang.code"), IniRead($sTempDir & "\mod_info.ini", "info", "Description File", "Readme.txt"))
If $sDescriptonFile Then
RunWait(@ScriptDir & '\7z\7z.exe e "' & $sFilePath & '" -o"' & $sTempDir & '\" "Mods\' & $sModName & '\' & $sDescriptonFile & '"', @ScriptDir & "\7z\", @SW_HIDE)
$sLocalDesc = FileRead($sTempDir & "\" & $sDescriptonFile)
EndIf
$sVersion = IniRead($sTempDir & "\mod_info.ini", "info", "Version", "0.0")
$sMinVersion = IniRead($sTempDir & "\mod_info.ini", "upgrade", "MinVersion", "0.0")
$sAuthor = IniRead($sTempDir & "\mod_info.ini", "info", "Author", "")
$sWebSite = IniRead($sTempDir & "\mod_info.ini", "info", "Homepage", "")
Return True
EndFunc
Func PackedMod_Deploy($sFilePath, $sAction)
Local $sTargetPath = $MM_LIST_DIR_PATH & "\.."
Local $sModName = PackedMod_GetPackedName($sFilePath)
If $sModName = "" Then Return SetError(1, 0, False)
Local $sOverwrite = ""
If $sAction = "Install" Then
DirRemove($sTargetPath & "\Mods\" & $sModName & "\", 1)
If @error Then Return SetError(2, 0, False)
Else
$sOverwrite = " -aoa"
EndIf
RunWait(@ScriptDir & '\7z\7z.exe x "' & $sFilePath & '"' & $sOverwrite & ' -o"' & $sTargetPath & '\', @ScriptDir & "\7z\", @SW_HIDE)
If $sAction = "Install" Then
Mod_ListLoad()
Mod_ReEnable($sModName)
EndIf
Return True
EndFunc
Func PackedMod_InstallGUI_Simple($aModList, $hFormParent = 0)
Local $hDesc
Local $hButtonInstall, $hButtonCancel, $hButtonClose
Local $hGUI, $msg
Local $bInstall, $bClose = False
Local $sAction
$hGUI = GUICreate(Lng_Get("add_new.caption"), 450, 370, Default, Default, Default, Default, $hFormParent)
GUISetState(@SW_SHOW)
$hDesc = GUICtrlCreateEdit("", 8, 8, 450 - 8, 300, $ES_READONLY)
$hButtonInstall = GUICtrlCreateButton(Lng_Get("add_new.install"), 8, 340, 136, 25)
$hButtonCancel = GUICtrlCreateButton(Lng_Get("add_new.next_mod"), 158, 340, 136, 25)
$hButtonClose = GUICtrlCreateButton(Lng_Get("add_new.close"), 308, 340, 136, 25)
If $hFormParent = 0 Then GUICtrlSetData($hButtonClose, Lng_Get("add_new.exit"))
For $iCount = 1 To $aModList[0][0]
WinSetTitle($hGUI, "", StringFormat(Lng_Get("add_new.caption"), $iCount, $aModList[0][0]))
Local $sDispName = $aModList[$iCount][1]
If $aModList[$iCount][2] <> "" And $aModList[$iCount][2] <> $aModList[$iCount][1] Then $sDispName = $aModList[$iCount][2] & " (" & $aModList[$iCount][1] & ")"
Local $sHelpMessage = ""
If Mod_ModIsInstalled($aModList[$iCount][1]) Then
$sHelpMessage &= StringFormat(Lng_Get("add_new.version_installed"), $aModList[$iCount][6]) & @CRLF
EndIf
$sAction = "Install"
$sHelpMessage &= StringFormat(Lng_Get("add_new.install"), $aModList[$iCount][4]) & @CRLF
If Mod_ModIsInstalled($aModList[$iCount][1]) Then
If $aModList[$iCount][6] >= $aModList[$iCount][4] Then
If $aModList[$iCount][6] = $aModList[$iCount][4] Then
GUICtrlSetData($hButtonInstall, Lng_Get("add_new.reinstall"))
GUICtrlSetState($hButtonInstall, $GUI_ENABLE)
GUICtrlSetData($hButtonCancel, Lng_Get("add_new.next_mod"))
Else
GUICtrlSetData($hButtonInstall, Lng_Get("add_new.install"))
GUICtrlSetState($hButtonInstall, $GUI_ENABLE)
GUICtrlSetData($hButtonCancel, Lng_Get("add_new.next_mod"))
EndIf
ElseIf $aModList[$iCount][6] < $aModList[$iCount][4] Then
GUICtrlSetData($hButtonInstall, Lng_Get("add_new.install"))
GUICtrlSetState($hButtonInstall, $GUI_ENABLE)
GUICtrlSetData($hButtonCancel, Lng_Get("add_new.dont_install"))
EndIf
Else
GUICtrlSetData($hButtonInstall, Lng_Get("add_new.install"))
GUICtrlSetState($hButtonInstall, $GUI_ENABLE)
GUICtrlSetData($hButtonCancel, Lng_Get("add_new.dont_install"))
EndIf
GUICtrlSetData($hDesc, $sDispName & @CRLF & $aModList[$iCount][3] & @CRLF & @CRLF & $sHelpMessage)
If $iCount = $aModList[0][0] Then
If $hFormParent = 0 Then
GUICtrlSetData($hButtonCancel, Lng_Get("add_new.close"))
Else
GUICtrlSetState($hButtonCancel, $GUI_DISABLE)
EndIf
EndIf
$bInstall = False
While Not $bInstall And Not $bClose
Sleep(10)
$msg = GUIGetMsg()
If $msg = 0 Then ContinueLoop
If $msg = $GUI_EVENT_CLOSE Then ExitLoop
If $msg = $hButtonCancel Then ExitLoop
If $msg = $hButtonClose Then $bClose = True
If $msg = $hButtonInstall Then $bInstall = True
WEnd
If $bInstall Then
SplashTextOn("", Lng_Get("add_new.installed"), 400, 200)
If $sAction = "Install" Then
Mod_Delete(Mod_ModIsInstalled($aModList[$iCount][1]))
PackedMod_Deploy($aModList[$iCount][0], "Install")
ElseIf $sAction = "Upgrade" Then
PackedMod_Deploy($aModList[$iCount][0], "Upgrade")
EndIf
SplashOff()
EndIf
If $bClose Then ExitLoop
Next
GUIDelete($hGUI)
Return Not $bClose
EndFunc
Func Plugins_ModHavePlugins(Const ByRef $sModID)
Local $iReturn
Local $aData1 = $MM_PLUGINS_CONTENT
Local $aData2 = $MM_PLUGINS_PART_PRESENT
Plugins_ListLoad($sModID)
$iReturn = $MM_PLUGINS_CONTENT[0][0]
$MM_PLUGINS_CONTENT = $aData1
$MM_PLUGINS_PART_PRESENT = $aData2
Return $iReturn
EndFunc
Func Plugins_ListLoad(Const ByRef $sModID)
Local $sPath = $MM_LIST_DIR_PATH & "\" & $sModID
Local $aPluginList[1][$PLUGIN_TOTAL]
Local $aGlobal = _FileListToArray($sPath & "\EraPlugins\", "*", 1)
Local $aBeforeWog = _FileListToArray($sPath & "\EraPlugins\BeforeWoG\", "*", 1)
Local $aAfterWog = _FileListToArray($sPath & "\EraPlugins\AfterWoG\", "*", 1)
Local $iTotalPlugins = 0
$MM_PLUGINS_PART_PRESENT[$PLUGIN_GROUP_GLOBAL] = False
$MM_PLUGINS_PART_PRESENT[$PLUGIN_GROUP_BEFORE] = False
$MM_PLUGINS_PART_PRESENT[$PLUGIN_GROUP_AFTER] = False
__Plugins_ListLoadFromFolder($aPluginList, $aGlobal, $sPath & "\EraPlugins", $PLUGIN_GROUP_GLOBAL, $iTotalPlugins)
__Plugins_ListLoadFromFolder($aPluginList, $aBeforeWog, $sPath & "\EraPlugins\BeforeWoG", $PLUGIN_GROUP_BEFORE, $iTotalPlugins)
__Plugins_ListLoadFromFolder($aPluginList, $aAfterWog, $sPath & "\EraPlugins\AfterWoG", $PLUGIN_GROUP_AFTER, $iTotalPlugins)
$aPluginList[0][0] = $iTotalPlugins
ReDim $aPluginList[$iTotalPlugins + 1][$PLUGIN_TOTAL]
$aPluginList[0][$PLUGIN_PATH] = "$PLUGIN_PATH"
$aPluginList[0][$PLUGIN_GROUP] = "$PLUGIN_GROUP"
$aPluginList[0][$PLUGIN_CAPTION] = "$PLUGIN_CAPTION"
$aPluginList[0][$PLUGIN_DESCRIPTION] = "$PLUGIN_DESCRIPTION"
$aPluginList[0][$PLUGIN_STATE] = "$PLUGIN_STATE"
$aPluginList[0][$PLUGIN_DEFAULT_STATE] = "$PLUGIN_DEFAULT_STATE"
$MM_PLUGINS_CONTENT = $aPluginList
EndFunc
Func __Plugins_ListLoadFromFolder(ByRef $aPluginList, Const ByRef $aFileList, Const $sPath, Const $iGroupId, ByRef $iPrevPos)
Local $bIsEnabled, $sFileName
If IsArray($aFileList) Then
ReDim $aPluginList[UBound($aPluginList, $UBOUND_ROWS) + $aFileList[0]][$PLUGIN_TOTAL]
For $iCount = 1 To $aFileList[0]
If FileGetSize($sPath & "\" & $aFileList[$iCount]) <> 0 Then
$MM_PLUGINS_PART_PRESENT[$iGroupId] = 1
$iPrevPos += 1
$bIsEnabled = StringRight($aFileList[$iCount], 4) <> ".off"
$sFileName =($bIsEnabled ? $aFileList[$iCount] : StringTrimRight($aFileList[$iCount], 4))
$aPluginList[$iPrevPos][$PLUGIN_FILENAME] = $sFileName
$aPluginList[$iPrevPos][$PLUGIN_PATH] = $sPath & "\" & $sFileName
$aPluginList[$iPrevPos][$PLUGIN_GROUP] = $iGroupId
$aPluginList[$iPrevPos][$PLUGIN_CAPTION] = Mod_Get("plugins\" & $sFileName & "\caption")
$aPluginList[$iPrevPos][$PLUGIN_DESCRIPTION] = Mod_Get("plugins\" & $sFileName & "\description")
$aPluginList[$iPrevPos][$PLUGIN_STATE] = $bIsEnabled
$aPluginList[$iPrevPos][$PLUGIN_DEFAULT_STATE] = Mod_Get("plugins\" & $sFileName & "\default")
EndIf
Next
EndIf
EndFunc
Func Plugins_ChangeState($iPluginIndex)
Local $sSourceFile = $MM_PLUGINS_CONTENT[$iPluginIndex][$PLUGIN_PATH] &($MM_PLUGINS_CONTENT[$iPluginIndex][$PLUGIN_STATE] ? "" : ".off")
Local $sTargetFile = $MM_PLUGINS_CONTENT[$iPluginIndex][$PLUGIN_PATH] &($MM_PLUGINS_CONTENT[$iPluginIndex][$PLUGIN_STATE] ? ".off" : "")
If FileMove($sSourceFile, $sTargetFile) Then
$MM_PLUGINS_CONTENT[$iPluginIndex][$PLUGIN_STATE] = Not $MM_PLUGINS_CONTENT[$iPluginIndex][$PLUGIN_STATE]
EndIf
EndFunc
Global $MM_SCN_LIST[1]
Func Scn_ListLoad()
Local $aScnList = _FileListToArray($MM_SCN_DIRECTORY, "*.json", $FLTA_FILES)
If @error Then
$aScnList = ArrayEmpty()
$aScnList[0] = 0
EndIf
For $i = 1 To $aScnList[0]
$aScnList[$i] = StringTrimRight($aScnList[$i], 5)
Next
$MM_SCN_LIST = $aScnList
EndFunc
Func Scn_Exist(Const $sName)
_ArraySearch($MM_SCN_LIST, $sName, 1)
Return Not @error
EndFunc
Func Scn_Delete(Const $iItemIndex)
If $iItemIndex < 1 Or $iItemIndex > $MM_SCN_LIST[0] Then Return
FileRecycle($MM_SCN_DIRECTORY & "\" & $MM_SCN_LIST[$iItemIndex] & ".json")
EndFunc
Func Scn_Apply(Const ByRef $mData)
Local $aData = $mData["list"]
Mod_ListLoadFromMemory($aData)
EndFunc
Func Scn_Load(Const $iItemIndex)
If $iItemIndex >= 1 And $iItemIndex <= $MM_SCN_LIST[0] Then
Return Scn_LoadData(FileRead($MM_SCN_DIRECTORY & "\" & $MM_SCN_LIST[$iItemIndex] & ".json"))
Else
Return Scn_LoadData("")
EndIf
EndFunc
Func Scn_LoadData(Const $sData)
Local $mScenario = Jsmn_Decode($sData)
__Scn_Validate($mScenario)
Return $mScenario
EndFunc
Func Scn_GetCurrentState(Const $mOptions)
Local $mData
__Scn_Validate($mData)
$mData["name"] = $mOptions["name"]
$mData["mm_version"] = $MM_VERSION_NUMBER
If $mOptions["exe"] Then $mData["exe"] = $MM_GAME_EXE
If $mOptions["wog_settings"] Then $mData["wog_settings"] = Scn_LoadWogSettings()
$mData["list"] = Mod_ListGetAsArray()
Return $mData
EndFunc
Func Scn_Save(Const $mOptions)
If Not $mOptions["name"] Then Return False
Const $sFileName = $MM_SCN_DIRECTORY & "\" & $mOptions["name"] & ".json"
Local $hFile = FileOpen($sFileName, $FO_OVERWRITE + $FO_CREATEPATH + $FO_UTF8)
FileWrite($hFile, Jsmn_Encode(Scn_GetCurrentState($mOptions), $JSMN_PRETTY_PRINT + $JSMN_UNESCAPED_UNICODE))
FileClose($hFile)
Return True
EndFunc
Func __Scn_Validate(ByRef $mData)
If Not IsMap($mData) Then $mData = MapEmpty()
If Not MapExists($mData, "version") Or Not IsString($mData["version"]) Then $mData["mm_version"] = $MM_VERSION_NUMBER
If Not MapExists($mData, "name") Or Not IsString($mData["name"]) Then $mData["name"] = ""
If Not MapExists($mData, "exe") Or Not IsString($mData["exe"]) Then $mData["exe"] = ""
If Not MapExists($mData, "wog_settings") Or Not IsString($mData["wog_settings"]) Then $mData["wog_settings"] = ""
If Not MapExists($mData, "list") Or Not IsArray($mData["list"]) Then $mData["list"] = ArrayEmpty()
Local $aItems = $mData["list"]
For $i = 0 To UBound($aItems) - 1
If Not IsString($aItems[$i]) Then $aItems[$i] = ""
Next
$mData["list"] = $aItems
EndFunc
Func Scn_SaveWogSettings(Const $vData, $sPath = "")
If Not $sPath Then
Local Const $sFilePath = ".\"
Local Const $aSection[3][2] = [[2, ""],["Options_File_Path", $sFilePath],["Options_File_Name", $MM_WOG_OPTIONS_FILE]]
IniWriteSection($MM_GAME_DIR & "\wog.ini", "WoGification", $aSection)
$sPath = $MM_GAME_DIR & "\" & $MM_WOG_OPTIONS_FILE
EndIf
Local Const $aData = IsArray($vData) ? $vData : Scn_StringToWS($vData)
Local $hFile = FileOpen($sPath, $FO_BINARY + $FO_OVERWRITE)
For $i = 0 To UBound($aData) - 1
FileWrite($hFile, $aData[$i])
Next
FileClose($hFile)
EndFunc
Func Scn_LoadWogSettings(Const $sFilePath = "")
Return Scn_WSToString(Scn_LoadWogSettingsAsArray($sFilePath))
EndFunc
Func Scn_LoadWogSettingsAsArray($sFilePath = "")
If Not $sFilePath Then $sFilePath = _PathFull(IniRead($MM_GAME_DIR & "\wog.ini", "WoGification", "Options_File_Path", ".\"), $MM_GAME_DIR) & IniRead($MM_GAME_DIR & "\wog.ini", "WoGification", "Options_File_Name", $MM_WOG_OPTIONS_FILE)
Return Scn_LoadWogSettingsFromFile($sFilePath)
EndFunc
Func Scn_LoadWogSettingsFromFile(Const $sFilePath)
Local Const $MAX = 1000
Local $aData[$MAX], $bData
Local $hFile = FileOpen($sFilePath, $FO_BINARY)
For $i = 0 To $MAX - 1
$bData = FileRead($hFile, 4)
If @error Then
$aData[$i] = 0
Else
$aData[$i] = Int($bData)
EndIf
Next
Return $aData
EndFunc
Func Scn_WSToString(Const ByRef $aData)
Local $sAnswer
Local $iCurrentItem = -1, $iCurrentCount = 0, $iItem
For $i = 0 To UBound($aData)
$iItem = $i <> UBound($aData) ? Int($aData[$i]) : -1
If $iItem = $iCurrentItem Then
$iCurrentCount += 1
Else
If $iCurrentItem <> -1 Then
If $iCurrentItem = 0 Then
$sAnswer &= $iCurrentCount
ElseIf $iCurrentItem = 1 And $iCurrentCount > 1 Then
$sAnswer &= ":" & $iCurrentCount
ElseIf $iCurrentItem > 1 Then
$sAnswer &= $iCurrentItem & ":" &($iCurrentCount > 1 ? $iCurrentCount : "")
EndIf
$sAnswer &= ";"
EndIf
$iCurrentItem = Int($iItem)
$iCurrentCount = 1
EndIf
Next
Return $sAnswer
EndFunc
Func Scn_StringToWS(Const ByRef $sData)
Local Const $MAX = 1000
Local $aReturn[$MAX], $iCurrent = 0, $aItem
Local $aTemp = StringSplit($sData, ";")
For $i = 1 To $aTemp[0] - 1
$aItem = StringSplit($aTemp[$i], ":")
If StringLen($aTemp[$i]) = 0 Then
$aReturn[$iCurrent] = 1
$iCurrent += 1
If $iCurrent >= $MAX Then ExitLoop
ElseIf $aItem[0] = 1 Then
For $j = 1 To Int($aItem[1])
$aReturn[$iCurrent] = 0
$iCurrent += 1
If $iCurrent >= $MAX Then ExitLoop
Next
ElseIf $aItem[0] = 2 And StringLen($aItem[1]) = 0 Then
For $j = 1 To Int($aItem[2])
$aReturn[$iCurrent] = 1
$iCurrent += 1
If $iCurrent >= $MAX Then ExitLoop
Next
ElseIf $aItem[0] = 2 And StringLen($aItem[2]) = 0 Then
$aReturn[$iCurrent] = Int($aItem[1])
$iCurrent += 1
If $iCurrent >= $MAX Then ExitLoop
ElseIf $aItem[0] = 2 Then
For $j = 1 To Int($aItem[2])
$aReturn[$iCurrent] = Int($aItem[1])
$iCurrent += 1
If $iCurrent >= $MAX Then ExitLoop
Next
Else
ExitLoop
EndIf
Next
For $i = 0 To $MAX - 1
If Not $aReturn[$i] Then $aReturn[$i] = 0
Next
Return $aReturn
EndFunc
Func StartUp_CheckRunningInstance()
Local $hSingleton = _Singleton("ERAIIMM {{C3125006-CAFE-4F97-B2A5-B287236A9DC6}", 1)
If $hSingleton = 0 Then
If WinActivate($MM_TITLE) Then Exit
EndIf
EndFunc
Func StartUp_WorkAsInstallmod()
Local $bUseWorkDir = FileExists(@ScriptDir & "\im_use_work_dir")
If $CMDLine[0] <> 1 Then
MsgBox($MB_SYSTEMMODAL, "", "Usage:" & @CRLF & "installmod.exe <Mod Directory>" & @CRLF &($bUseWorkDir ? "@WorkingDir will be used as root" : "@ScriptDir will be used as root"))
Exit
EndIf
$MM_LIST_DIR_PATH = $bUseWorkDir ?(@WorkingDir & "\Mods") :(@ScriptDir & "\..\Mods")
$MM_LIST_FILE_PATH = $MM_LIST_DIR_PATH & "\list.txt"
Mod_ListLoad()
Mod_ReEnable($CMDLine[1])
Exit
EndFunc
Global $__UI_EVENT = False, $__UI_LIST, $__UI_INPUT
Func UI_GameExeLaunch()
If $MM_COMPATIBILITY_MESSAGE <> "" Then
Local $iAnswer = MsgBox($MB_SYSTEMMODAL + $MB_YESNO, "", $MM_COMPATIBILITY_MESSAGE & @CRLF & Lng_Get("compatibility.launch_anyway"), Default, MM_GetCurrentWindow())
If $iAnswer <> $IDYES Then Return
EndIf
Run('"' & $MM_GAME_DIR & "\" & $MM_GAME_EXE & '"', $MM_GAME_DIR)
EndFunc
Func UI_Settings()
GUISetState(@SW_DISABLE, MM_GetCurrentWindow())
Local Const $iOptionGUIOnEventMode = AutoItSetOption("GUIOnEventMode", 0)
Local Const $iItemSpacing = 4
Local $bClose = False
Local $bSave = False
Local $hGUI = MM_GUICreate(Lng_Get("settings.menu.settings"), 370, 130)
Local $aSize = WinGetClientSize($hGUI)
If Not @Compiled Then GUISetIcon(@ScriptDir & "\icons\preferences-system.ico")
Local $hGroupListLoad = GUICtrlCreateGroup(Lng_Get("settings.list_load_options.group"), $iItemSpacing, $iItemSpacing + $iItemSpacing, $aSize[0] - 2 * $iItemSpacing, $aSize[1] - 3 * $iItemSpacing - 25)
Local $hCheckboxExe = GUICtrlCreateCheckbox(Lng_Get("settings.list_load_options.exe"), 2 * $iItemSpacing, GUICtrlGetPos($hGroupListLoad).Top + 5 * $iItemSpacing, Default, 17)
Local $hCheckboxSet = GUICtrlCreateCheckbox(Lng_Get("settings.list_load_options.wog_settings"), 2 * $iItemSpacing, GUICtrlGetPos($hCheckboxExe).NextY + $iItemSpacing, Default, 17)
Local $hCheckboxDontAsk = GUICtrlCreateCheckbox(Lng_Get("settings.list_load_options.dont_ask"), 2 * $iItemSpacing, GUICtrlGetPos($hCheckboxSet).NextY + $iItemSpacing, Default, 17)
GUICtrlSetState($hCheckboxExe, Settings_Get("list_exe") ? $GUI_CHECKED : $GUI_UNCHECKED)
GUICtrlSetState($hCheckboxSet, Settings_Get("list_wog_settings") ? $GUI_CHECKED : $GUI_UNCHECKED)
GUICtrlSetState($hCheckboxDontAsk, Settings_Get("list_no_ask") ? $GUI_CHECKED : $GUI_UNCHECKED)
Local $hOk = GUICtrlCreateButton("OK", $aSize[0] - $iItemSpacing - 75, $aSize[1] - $iItemSpacing - 25, 75, 25)
GUISetState(@SW_SHOW)
While Not $bClose And Not $bSave
Switch GUIGetMsg()
Case $GUI_EVENT_CLOSE
$bClose = True
Case $hOk
$bSave = True
EndSwitch
WEnd
If $bSave Then
Settings_Set("list_exe", GUICtrlRead($hCheckboxExe) = $GUI_CHECKED)
Settings_Set("list_wog_settings", GUICtrlRead($hCheckboxSet) = $GUI_CHECKED)
Settings_Set("list_no_ask", GUICtrlRead($hCheckboxDontAsk) = $GUI_CHECKED)
EndIf
MM_GUIDelete()
AutoItSetOption("GUIOnEventMode", $iOptionGUIOnEventMode)
GUISetState(@SW_ENABLE, MM_GetCurrentWindow())
GUISetState(@SW_RESTORE, MM_GetCurrentWindow())
EndFunc
Func UI_Import_Scn()
Local $mAnswer = MapEmpty()
$mAnswer["selected"] = False
$mAnswer["only_load"] = Settings_Get("list_only_load")
Local $bClose = False, $bSelected = False, $mParsed, $iUserChoice
GUISetState(@SW_DISABLE, MM_GetCurrentWindow())
Local Const $iOptionGUIOnEventMode = AutoItSetOption("GUIOnEventMode", 0)
Local Const $iItemSpacing = 4
Local $hGUI = MM_GUICreate(Lng_Get("scenarios.import.caption"), 460, 436)
Local $aSize = WinGetClientSize($hGUI)
If Not @Compiled Then GUISetIcon(@ScriptDir & "\icons\preferences-system.ico")
Local $hEdit = GUICtrlCreateEdit("", $iItemSpacing, $iItemSpacing, $aSize[0] - 2 * $iItemSpacing, 400, $ES_MULTILINE)
GUICtrlSetData($hEdit, ClipGet())
Local $hCheckOnlyLoad = GUICtrlCreateCheckbox(Lng_Get("scenarios.import.only_load"), $iItemSpacing, GUICtrlGetPos($hEdit).NextY + $iItemSpacing, Default, 17)
Local $hOk = GUICtrlCreateButton("OK", $aSize[0] - $iItemSpacing - 75, GUICtrlGetPos($hEdit).NextY + $iItemSpacing, 75, 25)
GUICtrlSetState($hCheckOnlyLoad, $mAnswer["only_load"] ? $GUI_CHECKED : $GUI_UNCHECKED)
GUISetState(@SW_SHOW)
While Not $bClose And Not $bSelected
Switch GUIGetMsg()
Case $GUI_EVENT_CLOSE
$bClose = True
Case $hOk
$mAnswer["only_load"] = GUICtrlRead($hCheckOnlyLoad) = $GUI_CHECKED
$mParsed = Scn_LoadData(GUICtrlRead($hEdit))
If Not $mAnswer["only_load"] And Not $mParsed["name"] Then
MsgBox($MB_OK + $MB_ICONINFORMATION + $MB_TASKMODAL, "", Lng_Get("scenarios.import.not_valid"))
ContinueLoop
ElseIf Not $mAnswer["only_load"] And Scn_Exist($mParsed["name"]) Then
$iUserChoice = MsgBox($MB_YESNO + $MB_ICONQUESTION + $MB_DEFBUTTON2 + $MB_TASKMODAL, "", Lng_Get("scenarios.import.replace"))
If $iUserChoice <> $IDYES Then ContinueLoop
EndIf
$mAnswer = UI_SelectScnLoadOptions($mParsed)
If $mAnswer["selected"] Then $bSelected = True
EndSwitch
WEnd
If $bSelected Then
$mAnswer["selected"] = True
$mAnswer["only_load"] = GUICtrlRead($hCheckOnlyLoad) = $GUI_CHECKED
$mAnswer["data"] = $mParsed
$mAnswer["name"] = $mAnswer["data"]["name"]
Settings_Set("list_only_load", $mAnswer["only_load"])
EndIf
MM_GUIDelete()
AutoItSetOption("GUIOnEventMode", $iOptionGUIOnEventMode)
GUISetState(@SW_ENABLE, MM_GetCurrentWindow())
GUISetState(@SW_RESTORE, MM_GetCurrentWindow())
Return $mAnswer
EndFunc
Func __UI_ScnSetCurrentData(ByRef $mMap)
$mMap["current_data"] = $mMap["export_data"]
$mMap["current_data"]["name"] = $mMap["name"]
$mMap["current_data"]["exe"] = $mMap["exe"] ? $mMap["export_data"]["exe"] : ""
$mMap["current_data"]["wog_settings"] = $mMap["wog_settings"] ? $mMap["export_data"]["wog_settings"] : ""
EndFunc
Func UI_ScnExport(Const $mData = "")
Local $mAnswer = MapEmpty()
If Not IsMap($mData) Then
$mAnswer["name"] = Lng_Get("scenarios.export.name")
$mAnswer["exe"] = True
$mAnswer["wog_settings"] = True
$mAnswer["export_data"] = Scn_GetCurrentState($mAnswer)
Else
$mAnswer["export_data"] = $mData
$mAnswer["name"] = $mData["name"]
EndIf
$mAnswer["exe"] = $mAnswer["export_data"]["exe"] And Settings_Get("list_exe")
$mAnswer["wog_settings"] = $mAnswer["export_data"]["wog_settings"] And Settings_Get("list_wog_settings")
__UI_ScnSetCurrentData($mAnswer)
Local $bClose = False
GUISetState(@SW_DISABLE, MM_GetCurrentWindow())
Local Const $iOptionGUIOnEventMode = AutoItSetOption("GUIOnEventMode", 0)
Local Const $iItemSpacing = 4
Local $hGUI = MM_GUICreate(Lng_Get("scenarios.export.caption"), 460, 486)
Local $aSize = WinGetClientSize($hGUI)
If Not @Compiled Then GUISetIcon(@ScriptDir & "\icons\preferences-system.ico")
GUIRegisterMsgStateful($WM_COMMAND, "__UI_WM_COMMAND")
Local $hEdit = GUICtrlCreateEdit("", $iItemSpacing, $iItemSpacing, $aSize[0] - 2 * $iItemSpacing, 400, BitOR($ES_MULTILINE, $ES_READONLY))
GUICtrlSetData($hEdit, Jsmn_Encode($mAnswer["current_data"], $JSMN_PRETTY_PRINT + $JSMN_UNESCAPED_UNICODE))
Local $hCheckExe = GUICtrlCreateCheckbox(Lng_Get("scenarios.save_options.exe"), $iItemSpacing, GUICtrlGetPos($hEdit).NextY + $iItemSpacing, Default, 17)
$__UI_INPUT = GUICtrlCreateInput($mAnswer["name"], $aSize[0] - $iItemSpacing - 150, GUICtrlGetPos($hEdit).NextY + $iItemSpacing, 150, 21)
Local $hCheckSet = GUICtrlCreateCheckbox(Lng_Get("scenarios.save_options.wog_settings"), $iItemSpacing, GUICtrlGetPos($hCheckExe).NextY + $iItemSpacing, Default, 17)
Local $hLine = GUICtrlCreateGraphic($iItemSpacing, GUICtrlGetPos($hCheckSet).NextY + $iItemSpacing, $aSize[0] - 2 * $iItemSpacing, 1)
GUICtrlSetGraphic($hLine, $GUI_GR_LINE, $aSize[0] - 2 * $iItemSpacing, 0)
Local $hCopy = GUICtrlCreateButton(Lng_Get("scenarios.export.copy"), $iItemSpacing, GUICtrlGetPos($hLine).NextY + $iItemSpacing, 100, 25)
Local $hOk = GUICtrlCreateButton("OK", $aSize[0] - $iItemSpacing - 75, GUICtrlGetPos($hLine).NextY + $iItemSpacing, 75, 25)
GUICtrlSetImage($hCopy, @ScriptDir & "\icons\edit-copy.ico")
GUICtrlSetState($hCheckExe, $mAnswer["export_data"]["exe"] And $mAnswer["exe"] ? $GUI_CHECKED : $GUI_UNCHECKED)
GUICtrlSetState($hCheckExe, $mAnswer["export_data"]["exe"] ? $GUI_ENABLE : $GUI_DISABLE)
GUICtrlSetState($hCheckSet, $mAnswer["export_data"]["wog_settings"] And $mAnswer["wog_settings"] ? $GUI_CHECKED : $GUI_UNCHECKED)
GUICtrlSetState($hCheckSet, $mAnswer["export_data"]["wog_settings"] ? $GUI_ENABLE : $GUI_DISABLE)
GUISetState(@SW_SHOW)
While Not $bClose
Switch GUIGetMsg()
Case $GUI_EVENT_CLOSE, $hOk
$bClose = True
Case $hCheckExe, $hCheckSet
$mAnswer["exe"] = GUICtrlRead($hCheckExe) = $GUI_CHECKED
$mAnswer["wog_settings"] = GUICtrlRead($hCheckSet) = $GUI_CHECKED
__UI_ScnSetCurrentData($mAnswer)
GUICtrlSetData($hEdit, Jsmn_Encode($mAnswer["current_data"], $JSMN_PRETTY_PRINT + $JSMN_UNESCAPED_UNICODE))
Case $hCopy
ClipPut(GUICtrlRead($hEdit))
EndSwitch
If $__UI_EVENT Then
$__UI_EVENT = False
$mAnswer["name"] = GUICtrlRead($__UI_INPUT)
__UI_ScnSetCurrentData($mAnswer)
GUICtrlSetData($hEdit, Jsmn_Encode($mAnswer["current_data"], $JSMN_PRETTY_PRINT + $JSMN_UNESCAPED_UNICODE))
EndIf
WEnd
GUIRegisterMsgStateful($WM_COMMAND, "")
MM_GUIDelete()
AutoItSetOption("GUIOnEventMode", $iOptionGUIOnEventMode)
GUISetState(@SW_ENABLE, $MM_UI_MAIN)
GUISetState(@SW_RESTORE, $MM_UI_MAIN)
EndFunc
Func UI_SelectScnLoadOptions(Const ByRef $mData)
Local $mAnswer = MapEmpty(), $bSkip = Settings_Get("list_no_ask")
$mAnswer["selected"] = False
$mAnswer["exe"] = $mData["exe"] And Settings_Get("list_exe")
$mAnswer["wog_settings"] = $mData["wog_settings"] And Settings_Get("list_wog_settings")
If($bSkip And Not _IsPressed("10")) Or(Not $mData["exe"] And Not $mData["wog_settings"]) Then
$mAnswer["selected"] = True
Return $mAnswer
EndIf
GUISetState(@SW_DISABLE, MM_GetCurrentWindow())
Local Const $iOptionGUIOnEventMode = AutoItSetOption("GUIOnEventMode", 0)
Local Const $iItemSpacing = 4
Local $bClose = False, $bSelected = False
Local $hGUI = MM_GUICreate(Lng_Get("scenarios.load_options.caption"), 420, 80)
Local $aSize = WinGetClientSize($hGUI)
If Not @Compiled Then GUISetIcon(@ScriptDir & "\icons\preferences-system.ico")
Local $hCheckExe = GUICtrlCreateCheckbox(Lng_GetF("scenarios.load_options.exe", $mData["exe"]), $iItemSpacing, $iItemSpacing, Default, 17)
Local $hCheckSet = GUICtrlCreateCheckbox(Lng_Get("scenarios.load_options.wog_settings"), $iItemSpacing, GUICtrlGetPos($hCheckExe).NextY + $iItemSpacing, Default, 17)
Local $hLine = GUICtrlCreateGraphic($iItemSpacing, GUICtrlGetPos($hCheckSet).NextY + $iItemSpacing, $aSize[0] - 2 * $iItemSpacing, 1)
GUICtrlSetGraphic($hLine, $GUI_GR_LINE, $aSize[0] - 2 * $iItemSpacing, 0)
Local $hCheckNotAgain = GUICtrlCreateCheckbox(Lng_Get("scenarios.load_options.not_again"), $iItemSpacing, GUICtrlGetPos($hLine).NextY + $iItemSpacing, Default, 17)
Local $hOk = GUICtrlCreateButton("OK", $aSize[0] - $iItemSpacing - 75, GUICtrlGetPos($hCheckNotAgain).Top, 75, 25)
GUICtrlSetState($hCheckExe, $mAnswer["exe"] ? $GUI_CHECKED : $GUI_UNCHECKED)
GUICtrlSetState($hCheckExe, $mData["exe"] ? $GUI_ENABLE : $GUI_DISABLE)
GUICtrlSetState($hCheckSet, $mAnswer["wog_settings"] ? $GUI_CHECKED : $GUI_UNCHECKED)
GUICtrlSetState($hCheckSet, $mData["wog_settings"] ? $GUI_ENABLE : $GUI_DISABLE)
GUICtrlSetState($hCheckNotAgain, $bSkip ? $GUI_CHECKED : $GUI_UNCHECKED)
GUISetState(@SW_SHOW)
While Not $bClose And Not $bSelected
Switch GUIGetMsg()
Case $GUI_EVENT_CLOSE
$bClose = True
Case $hOk
$bSelected = True
EndSwitch
WEnd
If $bSelected Then
$mAnswer["selected"] = True
If $mData["exe"] Then Settings_Set("list_exe", GUICtrlRead($hCheckExe) = $GUI_CHECKED)
If $mData["wog_settings"] Then Settings_Set("list_wog_settings", GUICtrlRead($hCheckSet) = $GUI_CHECKED)
Settings_Set("list_no_ask", GUICtrlRead($hCheckNotAgain) = $GUI_CHECKED)
$mAnswer["exe"] = $mData["exe"] And Settings_Get("list_exe")
$mAnswer["wog_settings"] = $mData["wog_settings"] And Settings_Get("list_wog_settings")
EndIf
MM_GUIDelete()
AutoItSetOption("GUIOnEventMode", $iOptionGUIOnEventMode)
GUISetState(@SW_ENABLE, MM_GetCurrentWindow())
GUISetState(@SW_RESTORE, MM_GetCurrentWindow())
Return $mAnswer
EndFunc
Func UI_SelectScnSaveOptions($sDefaultName)
Local $mAnswer = MapEmpty()
$mAnswer["selected"] = False
$mAnswer["name"] = ""
$mAnswer["exe"] = Settings_Get("list_exe")
$mAnswer["wog_settings"] = Settings_Get("list_wog_settings")
Local $bClose = False, $bSelected = False, $sPath
If $sDefaultName = "" Then
$sPath = __UI_SelectSavePath()
If Not @error Then
$sDefaultName = $sPath
Else
Return $mAnswer
EndIf
EndIf
GUISetState(@SW_DISABLE, MM_GetCurrentWindow())
Local Const $iOptionGUIOnEventMode = AutoItSetOption("GUIOnEventMode", 0)
Local Const $iItemSpacing = 4
Local $hGUI = MM_GUICreate(Lng_Get("scenarios.save_options.caption"), 420, 104)
Local $aSize = WinGetClientSize($hGUI)
If Not @Compiled Then GUISetIcon(@ScriptDir & "\icons\preferences-system.ico")
Local $hCombo = GUICtrlCreateCombo("", $iItemSpacing, $iItemSpacing, $aSize[0] - 3 * $iItemSpacing - 35, 25, BitOR($CBS_DROPDOWNLIST, $CBS_AUTOHSCROLL))
GUICtrlSetData($hCombo, _ArrayToString($MM_SCN_LIST, Default, 1))
If $sDefaultName <> "" Then GUICtrlSetData($hCombo, $sDefaultName, $sDefaultName)
Local $hDir = GUICtrlCreateButton("...", GUICtrlGetPos($hCombo).NextX + $iItemSpacing, $iItemSpacing - 2, 35, 25)
Local $hCheckExe = GUICtrlCreateCheckbox(Lng_Get("scenarios.save_options.exe"), $iItemSpacing, GUICtrlGetPos($hCombo).NextY + $iItemSpacing, Default, 17)
Local $hCheckSet = GUICtrlCreateCheckbox(Lng_Get("scenarios.save_options.wog_settings"), $iItemSpacing, GUICtrlGetPos($hCheckExe).NextY + $iItemSpacing, Default, 17)
Local $hLine = GUICtrlCreateGraphic($iItemSpacing, GUICtrlGetPos($hCheckSet).NextY + $iItemSpacing, $aSize[0] - 2 * $iItemSpacing, 1)
GUICtrlSetGraphic($hLine, $GUI_GR_LINE, $aSize[0] - 2 * $iItemSpacing, 0)
Local $hOk = GUICtrlCreateButton("OK", $aSize[0] - $iItemSpacing - 75, GUICtrlGetPos($hLine).NextY + $iItemSpacing, 75, 25)
GUICtrlSetState($hCheckExe, $mAnswer["exe"] ? $GUI_CHECKED : $GUI_UNCHECKED)
GUICtrlSetState($hCheckSet, $mAnswer["wog_settings"] ? $GUI_CHECKED : $GUI_UNCHECKED)
GUISetState(@SW_SHOW)
While Not $bClose And Not $bSelected
Switch GUIGetMsg()
Case $GUI_EVENT_CLOSE
$bClose = True
Case $hOk
$bSelected = True
Case $hDir
$sPath = __UI_SelectSavePath(GUICtrlRead($hCombo) & ".json")
If Not @error Then
GUICtrlSetData($hCombo, $sPath, $sPath)
EndIf
EndSwitch
WEnd
If $bSelected Then
$mAnswer["selected"] = True
$mAnswer["name"] = GUICtrlRead($hCombo)
$mAnswer["exe"] = GUICtrlRead($hCheckExe) = $GUI_CHECKED
$mAnswer["wog_settings"] = GUICtrlRead($hCheckSet) = $GUI_CHECKED
EndIf
MM_GUIDelete()
AutoItSetOption("GUIOnEventMode", $iOptionGUIOnEventMode)
GUISetState(@SW_ENABLE, MM_GetCurrentWindow())
GUISetState(@SW_RESTORE, MM_GetCurrentWindow())
Return $mAnswer
EndFunc
Func __UI_SelectSavePath(Const $sName = "")
Local $sDrive, $sDir, $sFileName, $sExtension
Local $sPath = FileSaveDialog(Lng_Get("scenarios.save_options.select_file"), $MM_SCN_DIRECTORY, Lng_Get("scenarios.save_options.select_filter"), Default, $sName, MM_GetCurrentWindow())
If @error Then Return SetError(@error, @extended, "")
_PathSplit($sPath, $sDrive, $sDir, $sFileName, $sExtension)
Return SetError(0, 0, $sFileName)
EndFunc
Func UI_SelectGameExe()
Local $aList = _FileListToArray($MM_GAME_DIR, "*.exe", $FLTA_FILES)
If Not IsArray($aList) Then Local $aList[1] = [0]
Local Const $iOptionGUIOnEventMode = AutoItSetOption("GUIOnEventMode", 0)
Local Const $aBlacklist = Settings_Get("game.blacklist")
GUISetState(@SW_DISABLE, MM_GetCurrentWindow())
Local Const $iItemSpacing = 4
Local $bClose = False
Local $bSelected = False
Local $sReturn = $MM_GAME_EXE
Local $bAllowName, $sSelected
Local $hGUI = MM_GUICreate("", 200, 324)
Local $aSize = WinGetClientSize($hGUI)
If Not @Compiled Then GUISetIcon(@ScriptDir & "\icons\preferences-system.ico")
GUIRegisterMsgStateful($WM_NOTIFY, "__UI_WM_NOTIFY")
$__UI_LIST = GUICtrlCreateTreeView($iItemSpacing, $iItemSpacing, $aSize[0] - 2 * $iItemSpacing, $aSize[1] - 3 * $iItemSpacing - 25, BitOR($TVS_FULLROWSELECT, $TVS_DISABLEDRAGDROP, $TVS_SHOWSELALWAYS), $WS_EX_CLIENTEDGE)
Local $hShowAll = GUICtrlCreateCheckbox(Lng_Get("settings.game_exe.show_all"), $iItemSpacing, GUICtrlGetPos($__UI_LIST).Height + $iItemSpacing, Default, 25)
Local $hOk = GUICtrlCreateButton("OK", $aSize[0] - $iItemSpacing - 75, GUICtrlGetPos($hShowAll).Top + $iItemSpacing, 75, 25)
Local $hListItems = $aList
For $i = 1 To $aList[0]
$bAllowName = True
For $j = 0 To UBound($aBlacklist) - 1
If StringRegExp($aList[$i], "(?i)" & $aBlacklist[$j]) Then $bAllowName = False
If Not $bAllowName Then ExitLoop
Next
If $bAllowName Or $aList[$i] = $MM_GAME_EXE Then
$hListItems[$i] = GUICtrlCreateTreeViewItem($aList[$i], $__UI_LIST)
If $aList[$i] = $MM_GAME_EXE Then GUICtrlSetState($hListItems[$i], $GUI_FOCUS)
If Not _GUICtrlTreeView_SetIcon($__UI_LIST, $hListItems[$i], $MM_GAME_DIR & "\" & $aList[$i], 0, 6) Then
_GUICtrlTreeView_SetIcon($__UI_LIST, $hListItems[$i], "shell32.dll", -3, 6)
EndIf
EndIf
Next
GUISetState(@SW_SHOW)
While Not $bClose And Not $bSelected
Switch GUIGetMsg()
Case $GUI_EVENT_CLOSE
$bClose = True
Case $hOk
$bSelected = True
Case $hShowAll
$sSelected = GUICtrlRead($__UI_LIST, 1)
GUICtrlSetState($hShowAll, $GUI_DISABLE)
_GUICtrlTreeView_BeginUpdate($__UI_LIST)
_GUICtrlTreeView_DeleteAll($__UI_LIST)
For $i = 1 To $aList[0]
$hListItems[$i] = GUICtrlCreateTreeViewItem($aList[$i], $__UI_LIST)
If $aList[$i] = $sSelected Then GUICtrlSetState($hListItems[$i], $GUI_FOCUS)
If Not _GUICtrlTreeView_SetIcon($__UI_LIST, $hListItems[$i], $MM_GAME_DIR & "\" & $aList[$i], 0, 6) Then
_GUICtrlTreeView_SetIcon($__UI_LIST, $hListItems[$i], "shell32.dll", -3, 6)
EndIf
Next
_GUICtrlTreeView_EndUpdate($__UI_LIST)
EndSwitch
If $__UI_EVENT Then
$bSelected = True
$__UI_EVENT = False
EndIf
WEnd
If $bSelected Then
$sSelected = GUICtrlRead($__UI_LIST, 1)
If $sSelected <> "" Then $sReturn = $sSelected
EndIf
GUIRegisterMsgStateful($WM_NOTIFY, "")
MM_GUIDelete()
AutoItSetOption("GUIOnEventMode", $iOptionGUIOnEventMode)
GUISetState(@SW_ENABLE, MM_GetCurrentWindow())
GUISetState(@SW_RESTORE, MM_GetCurrentWindow())
Return $sReturn
EndFunc
Func __UI_WM_NOTIFY($hwnd, $iMsg, $iwParam, $ilParam)
#forceref $hWnd, $iMsg, $iwParam, $ilParam
Local $hWndFrom, $iCode, $tNMHDR
$tNMHDR = DllStructCreate($tagNMHDR, $ilParam)
$hWndFrom = HWnd(DllStructGetData($tNMHDR, "hWndFrom"))
$iCode = DllStructGetData($tNMHDR, "Code")
Switch $hWndFrom
Case GUICtrlGetHandle($__UI_LIST)
Switch $iCode
Case $NM_DBLCLK
$__UI_EVENT = True
EndSwitch
EndSwitch
Return $GUI_RUNDEFMSG
EndFunc
Func __UI_WM_COMMAND($hWnd, $iMsg, $wParam, $lParam)
#forceref $hWnd, $iMsg
Local $hWndFrom, $iCode
$hWndFrom = $lParam
$iCode = _WinAPI_HiWord($wParam)
Switch $hWndFrom
Case GUICtrlGetHandle($__UI_INPUT)
Switch $iCode
Case $EN_CHANGE
$__UI_EVENT = True
EndSwitch
EndSwitch
Return $GUI_RUNDEFMSG
EndFunc
Global Const $WO_CAT = 8, $WO_GRP = 4, $WO_OPT = 20
Global $MM_WO_CAT[$WO_CAT]
Global $MM_WO_GROUPS[$WO_CAT][$WO_GRP]
Global $MM_WO_ITEMS[1]
Global $MM_WO_MAP[$WO_CAT][$WO_GRP][$WO_OPT + 1]
Global $MM_WO_UI_OPTIONS, $MM_WO_SHOW_POPUP, $MM_WO_FILTER_REQUESTED
Global $mPages = MapEmpty()
Global $mGroups = MapEmpty()
Global $mItems = MapEmpty()
Global $MM_WO_CURRENT_PAGE = -1, $MM_WO_PREV_PAGE = -1
Global $MM_WO_FILTER = "", $WO_UI, $__WO_INPUT
Func WO_ClearData()
For $p = 0 To $WO_CAT - 1
$MM_WO_CAT[$p] = Null
For $g = 0 To $WO_GRP - 1
$MM_WO_GROUPS[$p][$g] = Null
For $i = 1 To $MM_WO_MAP[$p][$g][0]
$MM_WO_MAP[$p][$g][$i] = Null
Next
$MM_WO_MAP[$p][$g][0] = 0
Next
Next
$MM_WO_ITEMS[0] = 0
ReDim $MM_WO_ITEMS[1]
$MM_WO_PREV_PAGE = -1
$MM_WO_PREV_PAGE = -1
$MM_WO_FILTER = ""
EndFunc
Func WO_ManageOptions(Const $aOptions)
_TraceStart("WO_Manage")
GUISetState(@SW_DISABLE, MM_GetCurrentWindow())
ProgressOn(Lng_Get("wog_options.caption"), Lng_Get("wog_options.loading"), Lng_Get("wog_options.loading_text"), Default, Default, $DLG_MOVEABLE + $DLG_NOTONTOP)
Local $mAnswer = MapEmpty()
$mAnswer["selected"] = False
Local Const $iOptionGUIOnEventMode = AutoItSetOption("GUIOnEventMode", 0)
$MM_WO_UI_OPTIONS = $aOptions
WO_LoadOverralInfo()
WO_LoadOptionsInfo()
_Trace("WO_DataLoaded")
If Not IsMap($MM_WO_CAT[0]) Then
ProgressOff()
MsgBox($MB_SYSTEMMODAL, "", Lng_Get("wog_options.bad_data"), MM_GetCurrentWindow())
WO_ClearData()
AutoItSetOption("GUIOnEventMode", $iOptionGUIOnEventMode)
GUISetState(@SW_ENABLE, MM_GetCurrentWindow())
GUISetState(@SW_RESTORE, MM_GetCurrentWindow())
Return $mAnswer
EndIf
Local Const $iWidth = 180, $iHeight = 50, $iBaseWidth = 350
Local Const $iButtonWidth = 90
Local Const $iItemSpacing = 4
Local Const $iGroupWidth = $iBaseWidth - 1.5 * $iItemSpacing
Local $bClose, $bSelected, $iMessage, $aCursoInfo
Local $hCloseButton, $hSaveButton, $hLoadButton, $hRestoreDefaultButton, $hUncheckAllButton, $hCheckAllButton
Local $hFilterLabel, $hFilterClearButton, $sPath
$WO_UI = MM_GUICreate(Lng_Get("wog_options.caption"), $iWidth + $iBaseWidth * 2, 500)
Local $aSize = WinGetClientSize($WO_UI)
If Not @Compiled Then GUISetIcon(@ScriptDir & "\icons\preferences-system.ico")
GUIRegisterMsgStateful($WM_COMMAND, "__WO_WM_COMMAND")
GUIRegisterMsgStateful($WM_CONTEXTMENU, "__WO_WM_CONTEXTMENU")
Local $iLeft, $iTop, $hItemFunc, $iIndex, $iIndex2, $sPopup
For $p = 0 To $WO_CAT - 1
$MM_WO_CAT[$p].Handle = GUICtrlCreateRadio($MM_WO_CAT[$p].Text, 0, $p * $iHeight, $iWidth, $iHeight, BitOR($BS_MULTILINE, $BS_PUSHLIKE))
GUICtrlSetTip($MM_WO_CAT[$p].Handle, $MM_WO_CAT[$p].Hint)
$mPages[$MM_WO_CAT[$p].Handle] = $p
Next
For $p = 0 To $WO_CAT - 1
For $g = 0 To $WO_GRP - 1
$iLeft = $iWidth + Floor(($g / 2) + 1) * $iItemSpacing + Floor(($g / 2)) * $iGroupWidth
$iTop =($g = 1 Or $g = 3) ? GUICtrlGetPos($MM_WO_GROUPS[$p][$g -(($p = 4 And $g = 3) ? 3 : 1)].Handle).NextY : 0
If $MM_WO_MAP[$p][$g][0] > 0 Then
$MM_WO_GROUPS[$p][$g].Handle = GUICtrlCreateGroup($MM_WO_GROUPS[$p][$g].Text, $iLeft, $iTop,($p = 4 And $g = 0) ?(2 * $iGroupWidth + $iItemSpacing) : $iGroupWidth, 19 * $MM_WO_MAP[$p][$g][0] + 5 * $iItemSpacing)
GUICtrlSetTip($MM_WO_GROUPS[$p][$g].Handle, $MM_WO_GROUPS[$p][$g].Hint)
$mGroups[$MM_WO_GROUPS[$p][$g].Handle] = ArraySimple($p, $g)
GUICtrlSetState(-1, $GUI_HIDE)
$MM_WO_GROUPS[$p][$g].Type = WO_IsCheckboxGroup($p, $g)
$hItemFunc = $MM_WO_GROUPS[$p][$g].Type ? GUICtrlCreateCheckbox : GUICtrlCreateRadio
For $i = 1 To $MM_WO_MAP[$p][$g][0]
$iIndex = $MM_WO_MAP[$p][$g][$i]
$iIndex2 = $MM_WO_MAP[$p][$g][$i-1]
$MM_WO_ITEMS[$iIndex].Handle = $hItemFunc($MM_WO_ITEMS[$iIndex].Text, $iLeft + $iItemSpacing, $i = 1 ? GUICtrlGetPos($MM_WO_GROUPS[$p][$g].Handle).Top + 3 * $iItemSpacing : GUICtrlGetPos($MM_WO_ITEMS[$iIndex2].Handle).NextY - 2,(($p = 4 And $g = 0) ? 2 : 1) * $iGroupWidth - 2 * $iItemSpacing)
GUICtrlSetTip($MM_WO_ITEMS[$iIndex].Handle, $MM_WO_ITEMS[$iIndex].Hint)
$mItems[$MM_WO_ITEMS[$iIndex].Handle] = ArraySimple($p, $g, $i)
GUICtrlSetState(-1, $GUI_HIDE)
Next
EndIf
Next
_Trace("WO_PageCreated")
ProgressSet($p/$WO_CAT*100)
Next
GUICtrlCreateLabel("", $iItemSpacing, $aSize[1] - 25 - 2 * $iItemSpacing, $aSize[0] - 2 * $iItemSpacing, 1, $SS_BLACKFRAME)
$hFilterLabel = GUICtrlCreateLabel(Lng_Get("wog_options.filter"), 2 * $iItemSpacing, $aSize[1] - 25 - $iItemSpacing, Default, Default, $SS_CENTERIMAGE)
$__WO_INPUT = GUICtrlCreateInput("", GUICtrlGetPos($hFilterLabel).NextX + $iItemSpacing, GUICtrlGetPos($hFilterLabel).Top + 2, 150)
$hFilterClearButton = GUICtrlCreateButton("", GUICtrlGetPos($__WO_INPUT).NextX + $iItemSpacing, GUICtrlGetPos($hFilterLabel).Top, 25, 25, $BS_ICON)
GUICtrlSetImage($hFilterClearButton, @ScriptDir & "\icons\edit-clear-locationbar-rtl.ico")
$hCheckAllButton = GUICtrlCreateButton(Lng_Get("wog_options.check"), $aSize[0] - 6 * $iButtonWidth - 7 * $iItemSpacing, $aSize[1] - 25 - $iItemSpacing, $iButtonWidth, 25)
$hUncheckAllButton = GUICtrlCreateButton(Lng_Get("wog_options.uncheck"), GUICtrlGetPos($hCheckAllButton).NextX + $iItemSpacing, GUICtrlGetPos($hCheckAllButton).Top, $iButtonWidth, 25)
$hRestoreDefaultButton = GUICtrlCreateButton(Lng_Get("wog_options.default"),GUICtrlGetPos($hUncheckAllButton).NextX + $iItemSpacing, GUICtrlGetPos($hUncheckAllButton).Top, $iButtonWidth, 25)
$hLoadButton = GUICtrlCreateButton(Lng_Get("wog_options.load"), GUICtrlGetPos($hRestoreDefaultButton).NextX + $iItemSpacing, GUICtrlGetPos($hRestoreDefaultButton).Top, $iButtonWidth, 25)
$hSaveButton = GUICtrlCreateButton(Lng_Get("wog_options.save"), GUICtrlGetPos($hLoadButton).NextX + $iItemSpacing, GUICtrlGetPos($hLoadButton).Top, $iButtonWidth, 25)
$hCloseButton = GUICtrlCreateButton("OK", GUICtrlGetPos($hSaveButton).NextX + $iItemSpacing, GUICtrlGetPos($hSaveButton).Top, $iButtonWidth, 25)
WO_SettingsToView($MM_WO_UI_OPTIONS)
WO_UpdateAccessibility()
WO_UpdateVisibility()
ProgressOff()
GUISetState(@SW_SHOW)
While Not $bClose And Not $bSelected
$iMessage = GUIGetMsg()
Select
Case $iMessage = $hFilterClearButton
GUICtrlSetData($__WO_INPUT, "")
Case $iMessage = $hSaveButton
$sPath = FileSaveDialog("", _PathFull(IniRead($MM_GAME_DIR & "\wog.ini", "WoGification", "Options_File_Path", ".\"), $MM_GAME_DIR), Lng_Get("wog_options.select_filter"), Default, IniRead($MM_GAME_DIR & "\wog.ini", "WoGification", "Options_File_Name", $MM_WOG_OPTIONS_FILE), MM_GetCurrentWindow())
If Not @error Then Scn_SaveWogSettings(WO_ViewToSettings($MM_WO_UI_OPTIONS), $sPath)
Case $iMessage = $hLoadButton
$sPath = FileOpenDialog("", _PathFull(IniRead($MM_GAME_DIR & "\wog.ini", "WoGification", "Options_File_Path", ".\"), $MM_GAME_DIR), Lng_Get("wog_options.select_filter"), $FD_FILEMUSTEXIST + $FD_PATHMUSTEXIST, IniRead($MM_GAME_DIR & "\wog.ini", "WoGification", "Options_File_Name", $MM_WOG_OPTIONS_FILE), MM_GetCurrentWindow())
If Not @error Then
WO_SettingsToView(Scn_LoadWogSettingsAsArray($sPath))
WO_UpdateAccessibility()
EndIf
Case $iMessage = $hRestoreDefaultButton
WO_SetState()
Case $iMessage = $hUncheckAllButton
WO_SetState(0)
Case $iMessage = $hCheckAllButton
WO_SetState(1)
Case $iMessage = $GUI_EVENT_CLOSE
$bClose = True
Case $iMessage = $hCloseButton
$bSelected = True
Case MapExists($mPages, $iMessage)
WO_OnPageChange($mPages[$iMessage])
Case MapExists($mItems, $iMessage)
WO_UpdateAccessibility($iMessage)
Case $MM_WO_SHOW_POPUP
$MM_WO_SHOW_POPUP = False
$aCursoInfo = GUIGetCursorInfo($WO_UI)
If Not @error And $aCursoInfo[4] <> 0 Then
$sPopup = WO_GetItemInfoByHandle($aCursoInfo[4])
If $sPopup Then MsgBox($MB_SYSTEMMODAL, "", $sPopup, Default, MM_GetCurrentWindow())
EndIf
Case $MM_WO_FILTER_REQUESTED
$MM_WO_FILTER_REQUESTED = False
$MM_WO_FILTER = GUICtrlRead($__WO_INPUT)
WO_UpdateVisibility()
EndSelect
WEnd
If $bSelected Then
$mAnswer["selected"] = True
$mAnswer["wog_options"] = WO_ViewToSettings($MM_WO_UI_OPTIONS)
EndIf
GUIRegisterMsgStateful($WM_COMMAND, "")
GUIRegisterMsgStateful($WM_CONTEXTMENU, "")
MM_GUIDelete()
WO_ClearData()
AutoItSetOption("GUIOnEventMode", $iOptionGUIOnEventMode)
GUISetState(@SW_ENABLE, MM_GetCurrentWindow())
GUISetState(@SW_RESTORE, MM_GetCurrentWindow())
_TraceEnd()
Return $mAnswer
EndFunc
Func WO_UpdateVisibility()
GUISetState(@SW_LOCK)
Local $iFirstAvailablePage = -1
Local $bPageAvailble
Local $bGroupVisible, $iIndex, $bItemVisible
For $p = 0 To $WO_CAT - 1
$bPageAvailble = False
For $g = 0 To $WO_GRP - 1
$bGroupVisible = False
If $MM_WO_MAP[$p][$g][0] > 0 Then
For $i = 1 To $MM_WO_MAP[$p][$g][0]
$iIndex = $MM_WO_MAP[$p][$g][$i]
$bItemVisible = $MM_WO_CURRENT_PAGE = $p And __WO_IsItemPassFilter($iIndex)
$bPageAvailble = $bPageAvailble Or __WO_IsItemPassFilter($iIndex)
GUICtrlSetState($MM_WO_ITEMS[$iIndex].Handle, $bItemVisible ? $GUI_SHOW : $GUI_HIDE)
If $bItemVisible Then $bGroupVisible = True
Next
EndIf
GUICtrlSetState($MM_WO_GROUPS[$p][$g].Handle, $bGroupVisible ? $GUI_SHOW : $GUI_HIDE)
Next
GUICtrlSetState($MM_WO_CAT[$p].Handle, $bPageAvailble ? $GUI_SHOW : $GUI_HIDE)
If $iFirstAvailablePage = -1 And $bPageAvailble Then $iFirstAvailablePage = $p
Next
GUISetState(@SW_UNLOCK)
If $iFirstAvailablePage <> - 1 And($MM_WO_CURRENT_PAGE = -1 Or($MM_WO_CURRENT_PAGE <> -1 And BitAnd(GUICtrlGetState($MM_WO_CAT[$MM_WO_CURRENT_PAGE].Handle), $GUI_HIDE))) Then
GUICtrlSetState($MM_WO_CAT[$iFirstAvailablePage].Handle, $GUI_CHECKED)
WO_OnPageChange($iFirstAvailablePage)
EndIf
EndFunc
Func __WO_IsItemPassFilter(Const $iIndex)
Return $MM_WO_FILTER = "" Or StringInStr($MM_WO_ITEMS[$iIndex].Text, $MM_WO_FILTER) Or StringInStr($MM_WO_ITEMS[$iIndex].Hint, $MM_WO_FILTER) Or StringInStr($MM_WO_ITEMS[$iIndex].PopUp, $MM_WO_FILTER)
EndFunc
Func WO_SetState(Const $iType = -1)
If $MM_WO_CURRENT_PAGE <> - 1 Then
Local $iIndex, $iState
For $g = 0 To $WO_GRP - 1
For $i = 1 To $MM_WO_MAP[$MM_WO_CURRENT_PAGE][$g][0]
$iIndex = $MM_WO_MAP[$MM_WO_CURRENT_PAGE][$g][$i]
$iState = $iType <> -1 ? $iType : $MM_WO_ITEMS[$iIndex].State
If BitAND(GUICtrlGetState($MM_WO_ITEMS[$iIndex].Handle), $GUI_SHOW) Then
If $MM_WO_GROUPS[$MM_WO_CURRENT_PAGE][$g].Type Then
GUICtrlSetState($MM_WO_ITEMS[$iIndex].Handle, $iState = 1 ? $GUI_CHECKED : $GUI_UNCHECKED)
ElseIf $iType = -1 Then
GUICtrlSetState($MM_WO_ITEMS[$iIndex].Handle, $iState ? $GUI_CHECKED : $GUI_UNCHECKED)
EndIf
EndIf
Next
Next
WO_UpdateAccessibility()
EndIf
EndFunc
Func WO_GetItemInfoByHandle(Const $hHandle)
Local $aCoords
If MapExists($mPages, $hHandle) Then
Return $MM_WO_CAT[$mPages[$hHandle]].PopUp
ElseIf MapExists($mGroups, $hHandle) Then
$aCoords = $mGroups[$hHandle]
Return $MM_WO_GROUPS[$aCoords[0]][$aCoords[1]].PopUp
ElseIf MapExists($mItems, $hHandle) Then
$aCoords = $mItems[$hHandle]
Return $MM_WO_ITEMS[$MM_WO_MAP[$aCoords[0]][$aCoords[1]][$aCoords[2]]].PopUp
Else
Return ""
EndIf
EndFunc
Func __WO_WM_CONTEXTMENU($hWnd, $iMsg, $wParam, $lParam)
#forceref $hWnd, $iMsg, $wParam, $lParam
$MM_WO_SHOW_POPUP = True
Return $GUI_RUNDEFMSG
EndFunc
Func __WO_WM_COMMAND($hWnd, $iMsg, $wParam, $lParam)
#forceref $hWnd, $iMsg
Local $hWndFrom, $iCode
$hWndFrom = $lParam
$iCode = _WinAPI_HiWord($wParam)
Switch $hWndFrom
Case GUICtrlGetHandle($__WO_INPUT)
Switch $iCode
Case $EN_CHANGE
_Timer_KillAllTimers($WO_UI)
_Timer_SetTimer($WO_UI, 250, "__WO_FilterData")
EndSwitch
EndSwitch
Return $GUI_RUNDEFMSG
EndFunc
Func __WO_FilterData($hWnd, $iMsg, $iIDTimer, $iTime)
#forceref $hWnd, $iMsg, $iIDTimer, $iTime
_Timer_KillAllTimers($WO_UI)
$MM_WO_FILTER_REQUESTED = True
EndFunc
Func WO_IsCheckboxGroup(Const $iPage, Const $iGroup)
Return Not(($iPage = 0 And($iGroup = 0 Or $iGroup = 3)) Or($iPage = 4 And $iGroup = 0))
EndFunc
Func WO_SettingsToView(Const ByRef $aOptions)
GUISetState(@SW_LOCK)
Local $iIndex, $iIndex2
For $p = 0 To $WO_CAT - 1
For $g = 0 To $WO_GRP - 1
For $i = 1 To $MM_WO_MAP[$p][$g][0]
$iIndex = $MM_WO_MAP[$p][$g][$i]
$iIndex2 = $MM_WO_ITEMS[$iIndex].ERM
If $MM_WO_GROUPS[$p][$g].Type Then
GUICtrlSetState($MM_WO_ITEMS[$iIndex].Handle,(($iIndex2 > 0 And $iIndex2 < 5) ?(Not $aOptions[$iIndex2]) : $aOptions[$iIndex2]) = 1 ? $GUI_CHECKED : $GUI_UNCHECKED)
Else
GUICtrlSetState($MM_WO_ITEMS[$iIndex].Handle,($aOptions[$iIndex2] = $i - 1) ? $GUI_CHECKED : $GUI_UNCHECKED)
EndIf
Next
Next
Next
GUISetState(@SW_UNLOCK)
EndFunc
Func WO_ViewToSettings($aResult)
ReDim $aResult[1000]
Local $iIndex, $iIndex2, $iState
For $p = 0 To $WO_CAT - 1
For $g = 0 To $WO_GRP - 1
For $i = 1 To $MM_WO_MAP[$p][$g][0]
$iIndex = $MM_WO_MAP[$p][$g][$i]
$iIndex2 = $MM_WO_ITEMS[$iIndex].ERM
$iState = BitAND(GUICtrlRead($MM_WO_ITEMS[$iIndex].Handle), $GUI_CHECKED) ? 1 : 0
If $MM_WO_GROUPS[$p][$g].Type Then
$aResult[$iIndex2] = Int(($iIndex2 > 0 And $iIndex2 < 5) ? Not $iState : $iState)
Else
If $iState = 1 Then $aResult[$iIndex2] = $i - 1
EndIf
Next
Next
Next
Return $aResult
EndFunc
Func WO_OnPageChange(Const $iIndex)
If $MM_WO_CURRENT_PAGE <> $iIndex Then
$MM_WO_CURRENT_PAGE = $iIndex
WO_UpdateVisibility()
EndIf
EndFunc
Func WO_CheckItemAvailability(Const $iPage, Const $iGroup, Const $iItem)
If $MM_WO_MAP[$iPage][$iGroup][$iItem] < 1 Then Return False
If Not IsMap($MM_WO_ITEMS[$MM_WO_MAP[$iPage][$iGroup][$iItem]]) Then Return False
Return True
EndFunc
Func WO_UpdateAccessibility(Const $hControl = 0)
If WO_CheckItemAvailability(0, 2, 3) And WO_CheckItemAvailability(0, 2, 4) Then
If $hControl = $MM_WO_ITEMS[$MM_WO_MAP[0][2][3]].Handle Or $hControl = 0 Then
GUICtrlSetState($MM_WO_ITEMS[$MM_WO_MAP[0][2][4]].Handle, BitAND(GUICtrlRead($MM_WO_ITEMS[$MM_WO_MAP[0][2][3]].Handle), $GUI_CHECKED) ? $GUI_ENABLE : BitOR($GUI_DISABLE, $GUI_UNCHECKED))
EndIf
EndIf
If WO_CheckItemAvailability(0, 2, 5) And WO_CheckItemAvailability(0, 2, 6) Then
If $hControl = $MM_WO_ITEMS[$MM_WO_MAP[0][2][5]].Handle Or $hControl = 0 Then
GUICtrlSetState($MM_WO_ITEMS[$MM_WO_MAP[0][2][6]].Handle, BitAND(GUICtrlRead($MM_WO_ITEMS[$MM_WO_MAP[0][2][5]].Handle), $GUI_CHECKED) ? $GUI_ENABLE : BitOR($GUI_DISABLE, $GUI_UNCHECKED))
EndIf
EndIf
If WO_CheckItemAvailability(0, 2, 11) And WO_CheckItemAvailability(0, 3, 1) Then
If $hControl = $MM_WO_ITEMS[$MM_WO_MAP[0][2][11]].Handle Or $hControl = 0 Then
GUICtrlSetState($MM_WO_ITEMS[$MM_WO_MAP[0][3][1]].Handle, BitAND(GUICtrlRead($MM_WO_ITEMS[$MM_WO_MAP[0][2][11]].Handle), $GUI_CHECKED) ? $GUI_ENABLE : $GUI_DISABLE)
For $i = 2 To $MM_WO_MAP[0][3][0]
GUICtrlSetState($MM_WO_ITEMS[$MM_WO_MAP[0][3][$i]].Handle, BitAND(GUICtrlRead($MM_WO_ITEMS[$MM_WO_MAP[0][2][11]].Handle), $GUI_CHECKED) ? $GUI_ENABLE : BitOR($GUI_DISABLE, $GUI_UNCHECKED))
Next
EndIf
Local $bIsSomethingChecked = False
For $i = 2 To $MM_WO_MAP[0][3][0]
$bIsSomethingChecked = $bIsSomethingChecked Or BitAND(GUICtrlRead($MM_WO_ITEMS[$MM_WO_MAP[0][3][$i]].Handle), $GUI_CHECKED)
Next
If Not $bIsSomethingChecked Then GUICtrlSetState($MM_WO_ITEMS[$MM_WO_MAP[0][3][1]].Handle, $GUI_CHECKED)
EndIf
If WO_CheckItemAvailability(1, 0, 1) And WO_CheckItemAvailability(1, 0, 2) Then
If $hControl = $MM_WO_ITEMS[$MM_WO_MAP[1][0][1]].Handle Or $hControl = 0 Then
GUICtrlSetState($MM_WO_ITEMS[$MM_WO_MAP[1][0][2]].Handle, BitAND(GUICtrlRead($MM_WO_ITEMS[$MM_WO_MAP[1][0][1]].Handle), $GUI_CHECKED) ? $GUI_ENABLE : BitOR($GUI_DISABLE, $GUI_UNCHECKED))
EndIf
EndIf
If WO_CheckItemAvailability(1, 1, 1) And WO_CheckItemAvailability(1, 1, 2) And WO_CheckItemAvailability(1, 1, 3) And WO_CheckItemAvailability(1, 1, 4) And WO_CheckItemAvailability(1, 1, 5) Then
If $hControl = $MM_WO_ITEMS[$MM_WO_MAP[1][1][1]].Handle Or $hControl = 0 Then
GUICtrlSetState($MM_WO_ITEMS[$MM_WO_MAP[1][1][2]].Handle, BitAND(GUICtrlRead($MM_WO_ITEMS[$MM_WO_MAP[1][1][1]].Handle), $GUI_CHECKED) ? $GUI_ENABLE : BitOR($GUI_DISABLE, $GUI_UNCHECKED))
GUICtrlSetState($MM_WO_ITEMS[$MM_WO_MAP[1][1][3]].Handle, BitAND(GUICtrlRead($MM_WO_ITEMS[$MM_WO_MAP[1][1][1]].Handle), $GUI_CHECKED) ? $GUI_ENABLE : BitOR($GUI_DISABLE, $GUI_UNCHECKED))
GUICtrlSetState($MM_WO_ITEMS[$MM_WO_MAP[1][1][4]].Handle, BitAND(GUICtrlRead($MM_WO_ITEMS[$MM_WO_MAP[1][1][1]].Handle), $GUI_CHECKED) ? $GUI_ENABLE : BitOR($GUI_DISABLE, $GUI_UNCHECKED))
GUICtrlSetState($MM_WO_ITEMS[$MM_WO_MAP[1][1][5]].Handle, BitAND(GUICtrlRead($MM_WO_ITEMS[$MM_WO_MAP[1][1][1]].Handle), $GUI_CHECKED) ? $GUI_ENABLE : BitOR($GUI_DISABLE, $GUI_UNCHECKED))
EndIf
If $hControl = $MM_WO_ITEMS[$MM_WO_MAP[1][1][3]].Handle Then GUICtrlSetState($MM_WO_ITEMS[$MM_WO_MAP[1][1][4]].Handle, $GUI_UNCHECKED)
If $hControl = $MM_WO_ITEMS[$MM_WO_MAP[1][1][4]].Handle Then GUICtrlSetState($MM_WO_ITEMS[$MM_WO_MAP[1][1][3]].Handle, $GUI_UNCHECKED)
If BitAND(GUICtrlRead($MM_WO_ITEMS[$MM_WO_MAP[1][1][3]].Handle), $GUI_CHECKED) Then GUICtrlSetState($MM_WO_ITEMS[$MM_WO_MAP[1][1][4]].Handle, $GUI_UNCHECKED)
EndIf
If WO_CheckItemAvailability(1, 1, 6) And WO_CheckItemAvailability(1, 1, 7) Then
If $hControl = $MM_WO_ITEMS[$MM_WO_MAP[1][1][6]].Handle Then GUICtrlSetState($MM_WO_ITEMS[$MM_WO_MAP[1][1][7]].Handle, GUICtrlRead($MM_WO_ITEMS[$MM_WO_MAP[1][1][6]].Handle))
If $hControl = $MM_WO_ITEMS[$MM_WO_MAP[1][1][7]].Handle Then GUICtrlSetState($MM_WO_ITEMS[$MM_WO_MAP[1][1][6]].Handle, GUICtrlRead($MM_WO_ITEMS[$MM_WO_MAP[1][1][7]].Handle))
If $hControl = 0 Then GUICtrlSetState($MM_WO_ITEMS[$MM_WO_MAP[1][1][7]].Handle, GUICtrlRead($MM_WO_ITEMS[$MM_WO_MAP[1][1][6]].Handle))
EndIf
If WO_CheckItemAvailability(2, 0, 7) And WO_CheckItemAvailability(2, 0, 8) And WO_CheckItemAvailability(2, 0, 9) Then
If $hControl = $MM_WO_ITEMS[$MM_WO_MAP[2][0][7]].Handle Then
GUICtrlSetState($MM_WO_ITEMS[$MM_WO_MAP[2][0][8]].Handle, $GUI_UNCHECKED)
GUICtrlSetState($MM_WO_ITEMS[$MM_WO_MAP[2][0][9]].Handle, $GUI_UNCHECKED)
EndIf
If $hControl = $MM_WO_ITEMS[$MM_WO_MAP[2][0][8]].Handle Then
GUICtrlSetState($MM_WO_ITEMS[$MM_WO_MAP[2][0][7]].Handle, $GUI_UNCHECKED)
GUICtrlSetState($MM_WO_ITEMS[$MM_WO_MAP[2][0][9]].Handle, $GUI_UNCHECKED)
EndIf
If $hControl = $MM_WO_ITEMS[$MM_WO_MAP[2][0][9]].Handle Then
GUICtrlSetState($MM_WO_ITEMS[$MM_WO_MAP[2][0][7]].Handle, $GUI_UNCHECKED)
GUICtrlSetState($MM_WO_ITEMS[$MM_WO_MAP[2][0][8]].Handle, $GUI_UNCHECKED)
EndIf
If BitAND(GUICtrlRead($MM_WO_ITEMS[$MM_WO_MAP[2][0][7]].Handle), $GUI_CHECKED) Then
GUICtrlSetState($MM_WO_ITEMS[$MM_WO_MAP[2][0][8]].Handle, $GUI_UNCHECKED)
GUICtrlSetState($MM_WO_ITEMS[$MM_WO_MAP[2][0][9]].Handle, $GUI_UNCHECKED)
ElseIf BitAND(GUICtrlRead($MM_WO_ITEMS[$MM_WO_MAP[2][0][7]].Handle), $GUI_CHECKED) Then
GUICtrlSetState($MM_WO_ITEMS[$MM_WO_MAP[2][0][9]].Handle, $GUI_UNCHECKED)
EndIf
EndIf
EndFunc
Func WO_LoadOverralInfo()
Local Const $sFileName = "zsetup00.txt"
Local $sData
Local $aFiles
For $i = 1 To $MM_LIST_CONTENT[0][0]
If Not $MM_LIST_CONTENT[$i][$MOD_IS_ENABLED] Then ContinueLoop
If FileExists(Mod_Get("dir\", $i) & "Data\" & $sFileName) Then
$sData = FileRead(Mod_Get("dir\", $i) & "Data\" & $sFileName)
Else
$aFiles = _FileListToArray(Mod_Get("dir\", $i) & "Data\", "*.pac", $FLTA_FILES, True)
If Not @error Then
For $j = 1 To $aFiles[0]
$sData = WO_GetFileData($aFiles[$j], $sFileName)
If $sData Then ExitLoop
Next
EndIf
EndIf
If $sData Then ExitLoop
Next
If $sData Then WO_ParseCategoriesData($sData)
EndFunc
Func WO_LoadOptionsInfo()
Local Const $sFileName = "zsetup01.txt"
Local $sData
Local $aFiles
For $i = 1 To $MM_LIST_CONTENT[0][0]
If Not $MM_LIST_CONTENT[$i][$MOD_IS_ENABLED] Then ContinueLoop
If FileExists(Mod_Get("dir\", $i) & "Data\" & $sFileName) Then
$sData = FileRead(Mod_Get("dir\", $i) & "Data\" & $sFileName)
Else
$aFiles = _FileListToArray(Mod_Get("dir\", $i) & "Data\", "*.pac", $FLTA_FILES, True)
If Not @error Then
For $j = 1 To $aFiles[0]
$sData = WO_GetFileData($aFiles[$j], $sFileName)
If $sData Then ExitLoop
Next
EndIf
EndIf
If $sData Then ExitLoop
Next
Local $mAlreadyLoaded = MapEmpty()
For $i = 1 To $MM_LIST_CONTENT[0][0]
If Not $MM_LIST_CONTENT[$i][$MOD_IS_ENABLED] Then ContinueLoop
$aFiles = _FileListToArray(Mod_Get("dir\", $i) & "Data\s\", "*.ers", $FLTA_FILES, False)
If Not @error Then
For $j = 1 To $aFiles[0]
If MapExists($mAlreadyLoaded, $aFiles[$j]) Then ContinueLoop
$mAlreadyLoaded[$aFiles[$j]] = True
$sData &= FileRead(Mod_Get("dir\", $i) & "Data\s\" & $aFiles[$j])
Next
EndIf
Next
If $sData Then WO_ParseItemsData($sData)
EndFunc
Func WO_ParseItemsData(Const ByRef $sData)
Local $aData = StringSplit($sData, @CRLF, $STR_ENTIRESPLIT)
Local $aToParse, $iPage, $iGroup, $iItem
$MM_WO_ITEMS[0] = $aData[0]
Local $iCount = 0
For $i = 1 To $aData[0]
$aToParse = StringSplit($aData[$i], @TAB, $STR_ENTIRESPLIT)
If $aToParse[0] < 11 Then ContinueLoop
if Not $aToParse[8] Then ContinueLoop
_ArrayAdd($MM_WO_ITEMS, MapEmpty())
$iCount += 1
$MM_WO_ITEMS[$iCount].Comment = $aToParse[1]
$MM_WO_ITEMS[$iCount].Script = Int($aToParse[2])
$MM_WO_ITEMS[$iCount].Page = Int($aToParse[3])
$MM_WO_ITEMS[$iCount].Group = Int($aToParse[4])
$MM_WO_ITEMS[$iCount].Item = Int($aToParse[5])
$MM_WO_ITEMS[$iCount].State = Int($aToParse[6])
$MM_WO_ITEMS[$iCount].MP = Int($aToParse[7])
$MM_WO_ITEMS[$iCount].ERM = Int($aToParse[8])
$MM_WO_ITEMS[$iCount].Text = $aToParse[9]
$MM_WO_ITEMS[$iCount].Hint = $aToParse[10]
$MM_WO_ITEMS[$iCount].PopUp = $aToParse[11]
$iPage = Int($aToParse[3])
$iGroup = Int($aToParse[4])
$iItem = Int($aToParse[5]) + 1
If $iItem <> 0 Then
$MM_WO_MAP[$iPage][$iGroup][$iItem] = $iCount
If $MM_WO_MAP[$iPage][$iGroup][0] < $iItem Then $MM_WO_MAP[$iPage][$iGroup][0] = $iItem
ElseIf $MM_WO_MAP[$iPage][$iGroup][0] < 20 Then
$MM_WO_MAP[$iPage][$iGroup][0] += 1
$MM_WO_MAP[$iPage][$iGroup][$MM_WO_MAP[$iPage][$iGroup][0]] = $iCount
EndIf
Next
EndFunc
Func WO_ParseCategoriesData(Const ByRef $sCategoriesData)
Local $aData = StringSplit($sCategoriesData, @CRLF, $STR_ENTIRESPLIT)
Local $aToParse, $sData, $iValue, $iPage, $iGroup
For $i = 1 To $aData[0]
$aToParse = StringSplit($aData[$i], @TAB, $STR_ENTIRESPLIT)
If $aToParse[0] <> 2 Then ContinueLoop
$iValue = Number($aToParse[1])
$sData = $aToParse[2]
Switch $iValue
Case 0, 1 To 4
Case 5 To 28
$iValue -= 5
$iPage = Floor($iValue / 3)
If Not IsMap($MM_WO_CAT[$iPage]) Then $MM_WO_CAT[$iPage] = MapEmpty()
Switch Mod($iValue, 3)
Case 0
$MM_WO_CAT[$iPage].Text = $sData
Case 1
$MM_WO_CAT[$iPage].Hint = $sData
Case 2
$MM_WO_CAT[$iPage].PopUp = $sData
EndSwitch
Case 29 To 124
$iValue -= 29
$iPage = Floor($iValue / 12)
$iGroup = Floor(Mod($iValue, 12) / 3)
If Not IsMap($MM_WO_GROUPS[$iPage][$iGroup]) Then $MM_WO_GROUPS[$iPage][$iGroup] = MapEmpty()
Switch Mod(Mod($iValue, 12), 3)
Case 0
$MM_WO_GROUPS[$iPage][$iGroup].Text = $sData
Case 1
$MM_WO_GROUPS[$iPage][$iGroup].Hint = $sData
Case 2
$MM_WO_GROUPS[$iPage][$iGroup].PopUp = $sData
EndSwitch
EndSwitch
Next
EndFunc
Func WO_GetFileData(Const $sLODPath, Const $sFileName)
Local $hFile = FileOpen($sLODPath, $FO_BINARY)
Local $sData, $iTotalFiles, $iOffset, $iSizeOrg, $iSizeCompressed
If BinaryToString(FileRead($hFile, 4)) = "LOD" Then
Int(FileRead($hFile, 4))
$iTotalFiles = Int(FileRead($hFile, 4))
For $i = 1 To $iTotalFiles
FileSetPos($hFile, 92 + 32 *($i - 1), $FILE_BEGIN)
Local $sName = FileRead($hFile, 16)
If Not StringInStr($sName, Binary($sFileName)) Then ContinueLoop
$iOffset = Int(FileRead($hFile, 4))
$iSizeOrg = Int(FileRead($hFile, 4))
Int(FileRead($hFile, 4))
$iSizeCompressed = Int(FileRead($hFile, 4))
FileSetPos($hFile, $iOffset, $FILE_BEGIN)
If $iSizeCompressed Then
$sData = BinaryToString(_ZLIB_Uncompress(FileRead($hFile, $iSizeCompressed)))
Else
$sData = BinaryToString(FileRead($hFile, $iSizeOrg))
EndIf
ExitLoop
Next
EndIf
FileClose($hFile)
Return $sData
EndFunc
Global $hGUI[]
Global $hDummyF5, $hDummyLinks, $hDummyCategories, $hDummyF9
Global Const $iItemSpacing = 4
Global $aModListGroups[1][3]
Global $aPlugins[1][2], $hPluginsParts[3]
Global $aScreens[1], $iScreenIndex, $iScreenWidth, $iScreenHeight, $sScreenPath
Global $sFollowMod = ""
Global $bEnableDisable, $bSelectionChanged
Global $bInTrack = False
Global $bPackModHint = True
If @Compiled And @ScriptName = "installmod.exe" Then
StartUp_WorkAsInstallmod()
EndIf
Lng_LoadList()
If $CMDLine[0] > 1 And $CMDLine[1] = '/setlang' Then
Settings_Set("language", Utils_InnoLangToMM($CMDLine[2]))
ElseIf $CMDLine[0] > 0 Then
If Not SD_CLI_Mod_Add() Then Exit
EndIf
StartUp_CheckRunningInstance()
If Not IsDeclared("__MM_NO_UI") Then
UI_InitMain()
MainLoop()
EndIf
Func UI_InitMain()
_TraceStart("UI_InitMain")
_GDIPlus_Startup()
SD_GUI_LoadSize()
UI_Main_Create()
TreeViewMain()
TreeViewTryFollow($MM_LIST_CONTENT[0][0] > 0 ? $MM_LIST_CONTENT[1][$MOD_ID] : "")
SD_SwitchView()
SD_SwitchSubView()
GUISetState(@SW_SHOW)
_TraceEnd()
EndFunc
Func MainLoop()
While True
Sleep(20)
UI_AutoUpdate()
UI_ModStateChange()
If $MM_LIST_CANT_WORK Then
$MM_LIST_CANT_WORK = False
If MsgBox($MB_SYSTEMMODAL + $MB_YESNO, "", Lng_GetF("mod_list.list_inaccessible", $MM_LIST_FILE_PATH)) = $IDYES Then
ShellExecute("explorer.exe", "/select," & $MM_LIST_FILE_PATH, $MM_LIST_DIR_PATH)
EndIf
EndIf
WEnd
EndFunc
Func UI_AutoUpdate()
Local Static $bGUINeedUpdate = False
If Not $bGUINeedUpdate And Not WinActive($MM_UI_MAIN) Then
$bGUINeedUpdate = True
EndIf
If $bGUINeedUpdate And WinActive($MM_UI_MAIN) Then
$bGUINeedUpdate = False
If Not Mod_ListIsActual() Then SD_GUI_Update()
EndIf
EndFunc
Func UI_ModStateChange()
If $bEnableDisable Then
$bEnableDisable = False
SD_GUI_List_ChangeState()
EndIf
If $bSelectionChanged Then
$bSelectionChanged = False
SD_GUI_List_SelectionChanged()
EndIf
EndFunc
Func SD_GUI_Language_Change()
Local $iIndex = -1
For $iCount = 1 To $MM_LNG_LIST[0][0]
If @GUI_CtrlId = $MM_LNG_LIST[$iCount][$MM_LNG_MENU_ID] Then
$iIndex = $iCount
ExitLoop
EndIf
Next
If $iIndex = -1 Then Return False
$MM_SETTINGS_LANGUAGE = $MM_LNG_LIST[$iIndex][$MM_LNG_FILE]
Local $sIsLoaded = Lng_Load()
If @error Then
MsgBox($MB_ICONINFORMATION + $MB_SYSTEMMODAL, "", $sIsLoaded, Default, $MM_UI_MAIN)
Else
Settings_Set("Language", $MM_SETTINGS_LANGUAGE)
EndIf
SD_GUI_SetLng()
SD_GUI_Update()
EndFunc
Func UI_Main_Create()
Local Const $iOptionGUICoordMode = AutoItSetOption("GUICoordMode", 0)
$MM_UI_MAIN = MM_GUICreate($MM_TITLE, $MM_WINDOW_MIN_WIDTH, $MM_WINDOW_MIN_HEIGHT, Default, Default, BitOR($GUI_SS_DEFAULT_GUI, $WS_SIZEBOX, $WS_MAXIMIZEBOX), $WS_EX_ACCEPTFILES)
$MM_WINDOW_MIN_WIDTH_FULL = WinGetPos($MM_UI_MAIN)[2]
$MM_WINDOW_MIN_HEIGHT_FULL = WinGetPos($MM_UI_MAIN)[3]
GUISetIcon(@ScriptDir & "\icons\preferences-system.ico")
UI_Main_MenuCreate()
$hGUI.ModList = MapEmpty()
$hGUI.ModList.Group = GUICtrlCreateGroup("-", 0, 0)
$hGUI.ModList.List = GUICtrlCreateTreeView(0, 0, Default, Default, BitOR($TVS_FULLROWSELECT, $TVS_DISABLEDRAGDROP, $TVS_SHOWSELALWAYS), $WS_EX_CLIENTEDGE)
$hGUI.ModList.Up = GUICtrlCreateButton("", 0, 0, 90, 25)
$hGUI.ModList.Down = GUICtrlCreateButton("", 0, 0, 90, 25)
$hGUI.ModList.ChangeState = GUICtrlCreateButton("", 0, 0, 90, 25)
$hGUI.MenuMod = MapEmpty()
$hGUI.MenuMod.Menu = GUICtrlCreateContextMenu($hGUI.ModList.List)
$hGUI.MenuMod.Plugins = GUICtrlCreateMenuItem("-", $hGUI.MenuMod.Menu)
$hGUI.MenuMod.OpenHomepage = GUICtrlCreateMenuItem("-", $hGUI.MenuMod.Menu)
GUICtrlCreateMenuItem("", $hGUI.MenuMod.Menu)
$hGUI.MenuMod.Delete = GUICtrlCreateMenuItem("-", $hGUI.MenuMod.Menu)
$hGUI.MenuMod.OpenFolder = GUICtrlCreateMenuItem("-", $hGUI.MenuMod.Menu)
$hGUI.MenuMod.EditMod = GUICtrlCreateMenuItem("-", $hGUI.MenuMod.Menu)
$hGUI.MenuMod.PackMod = GUICtrlCreateMenuItem("-", $hGUI.MenuMod.Menu)
$hGUI.PluginsList = MapEmpty()
$hGUI.PluginsList.Group = GUICtrlCreateGroup("-", 0, 0)
$hGUI.PluginsList.List = GUICtrlCreateTreeView(0, 0, Default, Default, BitOR($TVS_FULLROWSELECT, $TVS_DISABLEDRAGDROP, $TVS_SHOWSELALWAYS), $WS_EX_CLIENTEDGE)
$hGUI.ScnList = MapEmpty()
$hGUI.ScnList.Group = GUICtrlCreateGroup("-", 0, 0)
$hGUI.ScnList.List = GUICtrlCreateListView("1|Name", 2, 2, Default, Default, BitOR($LVS_NOCOLUMNHEADER, $LVS_SINGLESEL, $LVS_SHOWSELALWAYS), BitOR($LVS_EX_FULLROWSELECT, 0))
$hGUI.ScnList.Load = GUICtrlCreateButton("", 0, 0, 90, 25)
$hGUI.ScnList.Save = GUICtrlCreateButton("", 0, 0, 90, 25)
$hGUI.ScnList.Export = GUICtrlCreateButton("", 0, 0, 90, 25)
$hGUI.ScnList.Delete = GUICtrlCreateButton("", 0, 0, 90, 25)
GUICtrlSetState($hGUI.ScnList.Load, $GUI_DISABLE)
GUICtrlSetState($hGUI.ScnList.Save, $GUI_DISABLE)
GUICtrlSetState($hGUI.ScnList.Export, $GUI_DISABLE)
GUICtrlSetState($hGUI.ScnList.Delete, $GUI_DISABLE)
$hGUI.ScnList.ImageList = _GUIImageList_Create(16, 16, 4, 1)
_GUIImageList_AddIcon($hGUI.ScnList.ImageList, @ScriptDir & "\icons\go-next.ico")
_GUICtrlListView_SetImageList($hGUI.ScnList.List, $hGUI.ScnList.ImageList, 1)
$hGUI.Info = MapEmpty()
$hGUI.Info.TabControl = GUICtrlCreateTab(0, 0, Default, Default, BitOR($TCS_FLATBUTTONS, $TCS_BUTTONS, $TCS_FOCUSNEVER))
$hGUI.Info.TabDesc = GUICtrlCreateTabItem("-")
$hGUI.Info.TabInfo = GUICtrlCreateTabItem("-")
$hGUI.Info.TabScreens = GUICtrlCreateTabItem("-")
GUICtrlCreateTabItem("")
$hGUI.Info.Edit = GUICtrlCreateEdit("", 0, 0, 0, 0, BitOR($ES_READONLY, $WS_VSCROLL, $WS_TABSTOP))
$hGUI.Info.Desc = _GUICtrlSysLink_Create($MM_UI_MAIN, "-", 0, 0, 0, 0)
$hGUI.Screen = MapEmpty()
$hGUI.Screen.Control = GUICtrlCreatePic("", 0, 0)
GUICtrlSetCursor($hGUI.Screen.Control, 0)
$hGUI.Screen.Open = GUICtrlCreateButton("", 0, 0, 25, 25, $BS_ICON)
$hGUI.Screen.Back = GUICtrlCreateButton("", 0, 0, 25, 25, $BS_ICON)
$hGUI.Screen.Forward = GUICtrlCreateButton("", 0, 0, 25, 25, $BS_ICON)
GUICtrlSetImage($hGUI.Screen.Open, @ScriptDir & "\icons\folder-open.ico")
GUICtrlSetImage($hGUI.Screen.Back, @ScriptDir & "\icons\arrow-left.ico")
GUICtrlSetImage($hGUI.Screen.Forward, @ScriptDir & "\icons\arrow-right.ico")
SD_UI_ScnLoadItems()
$hGUI.Back = GUICtrlCreateButton("", 0, 0, 90, 25)
$hDummyF5 = GUICtrlCreateDummy()
$hDummyF9 = GUICtrlCreateDummy()
$hDummyLinks = GUICtrlCreateDummy()
$hDummyCategories = GUICtrlCreateDummy()
Local $AccelKeys[3][2] = [["{F5}", $hDummyF5], ["{F8}", $hDummyCategories], ["{F9}", $hDummyF9]]
GUISetAccelerators($AccelKeys)
SD_GUI_Mod_Controls_Disable()
SD_GUI_Events_Register()
SD_GUI_SetLng()
SD_GUI_MainWindowResize()
WinMove($MM_UI_MAIN, '',(@DesktopWidth - $MM_WINDOW_WIDTH) / 2,(@DesktopHeight - $MM_WINDOW_HEIGHT) / 2, $MM_WINDOW_WIDTH, $MM_WINDOW_HEIGHT)
If $MM_WINDOW_MAXIMIZED Then WinSetState($MM_UI_MAIN, '', @SW_MAXIMIZE)
AutoItSetOption("GUICoordMode", $iOptionGUICoordMode)
EndFunc
Func UI_Main_MenuCreate()
$hGUI.MenuScn = MapEmpty()
$hGUI.MenuScn.Menu = GUICtrlCreateMenu("-")
$hGUI.MenuScn.Manage = GUICtrlCreateMenuItem("-", $hGUI.MenuScn.Menu)
$hGUI.MenuScn.Save = GUICtrlCreateMenuItem("-", $hGUI.MenuScn.Menu)
GUICtrlCreateMenuItem("", $hGUI.MenuScn.Menu)
$hGUI.MenuScn.Import = GUICtrlCreateMenuItem("-", $hGUI.MenuScn.Manage)
$hGUI.MenuScn.Export = GUICtrlCreateMenuItem("-", $hGUI.MenuScn.Manage)
$hGUI.MenuGame = MapEmpty()
$hGUI.MenuGame.Menu = GUICtrlCreateMenu("-")
$hGUI.MenuGame.Launch = GUICtrlCreateMenuItem("-", $hGUI.MenuGame.Menu)
GUICtrlSetState($hGUI.MenuGame.Launch, $MM_GAME_EXE = "" ? $GUI_DISABLE : $GUI_ENABLE)
GUICtrlCreateMenuItem("", $hGUI.MenuGame.Menu)
$hGUI.MenuGame.Change = GUICtrlCreateMenuItem("-", $hGUI.MenuGame.Menu)
$hGUI.MenuGame.ChangeWO = GUICtrlCreateMenuItem("-", $hGUI.MenuGame.Menu)
$hGUI.MenuSettings = MapEmpty()
$hGUI.MenuSettings.Menu = GUICtrlCreateMenu("-")
$hGUI.MenuSettings.Add = GUICtrlCreateMenuItem("-", $hGUI.MenuSettings.Menu)
$hGUI.MenuSettings.Compatibility = GUICtrlCreateMenuItem("-", $hGUI.MenuSettings.Menu)
GUICtrlCreateMenuItem("", $hGUI.MenuSettings.Menu)
$hGUI.MenuSettings.Settings = GUICtrlCreateMenuItem("-", $hGUI.MenuSettings.Menu)
$hGUI.MenuLanguage = GUICtrlCreateMenu("-", $hGUI.MenuSettings.Menu)
For $iCount = 1 To $MM_LNG_LIST[0][0]
$MM_LNG_LIST[$iCount][$MM_LNG_MENU_ID] = GUICtrlCreateMenuItem($MM_LNG_LIST[$iCount][$MM_LNG_NAME], $hGUI.MenuLanguage, Default, 1)
If $MM_LNG_LIST[$iCount][$MM_LNG_FILE] = $MM_SETTINGS_LANGUAGE Then GUICtrlSetState($MM_LNG_LIST[$iCount][$MM_LNG_MENU_ID], $GUI_CHECKED)
Next
EndFunc
Func SD_GUI_UpdateScreen(Const $iIndex)
$iScreenWidth = 0
$iScreenHeight = 0
$iScreenIndex = $iIndex
$sScreenPath = $iIndex > 0 ? $aScreens[$iIndex] : ""
GUICtrlSetState($hGUI.Screen.Back, $iIndex <= 1 ? $GUI_DISABLE : $GUI_ENABLE)
GUICtrlSetState($hGUI.Screen.Forward, $iIndex >= $aScreens[0] ? $GUI_DISABLE : $GUI_ENABLE)
GUICtrlSetState($hGUI.Screen.Control, $iIndex = 0 ? $GUI_DISABLE : $GUI_ENABLE)
GUICtrlSetState($hGUI.Screen.Open, $iIndex = 0 ? $GUI_DISABLE : $GUI_ENABLE)
If $MM_SUBVIEW_CURRENT <> $MM_SUBVIEW_SCREENS Then Return
If $iIndex <> 0 Then
Local $hScreenImage = _GDIPlus_ImageLoadFromFile($sScreenPath)
Local $hScreenBitmap = _GDIPlus_BitmapCreateHBITMAPFromBitmap($hScreenImage)
$iScreenWidth = _GDIPlus_ImageGetWidth($hScreenImage)
$iScreenHeight = _GDIPlus_ImageGetHeight($hScreenImage)
_WinAPI_DeleteObject(GUICtrlSendMsg($hGUI.Screen.Control, $STM_SETIMAGE, $IMAGE_BITMAP, $hScreenBitmap))
_GDIPlus_ImageDispose($hScreenImage)
_WinAPI_DeleteObject($hScreenBitmap)
GUICtrlSetPos($hGUI.Screen.Control, 0, 0, 0, 0)
EndIf
SD_GUI_MainWindowResize(True)
EndFunc
Func SD_GUI_UpdateScreenByPath(Const $sPath)
For $i = 1 To $aScreens[0]
If $aScreens[$i] = $sPath Then Return SD_GUI_UpdateScreen($i)
Next
SD_GUI_UpdateScreen($aScreens[0] > 0 ? 1 : 0)
EndFunc
Func SD_GUI_OpenScreenFolder()
Utils_OpenFolder($MM_LIST_DIR_PATH & "\" & Mod_Get("id") & "\Screens\", $sScreenPath)
EndFunc
Func SD_GUI_NextScreen()
If $iScreenIndex < $aScreens[0] Then SD_GUI_UpdateScreen($iScreenIndex + 1)
EndFunc
Func SD_GUI_PrevScreen()
If $iScreenIndex > 0 Then SD_GUI_UpdateScreen($iScreenIndex - 1)
EndFunc
Func WM_SIZE()
If Not $hGUI.WindowResizeInProgress Or Not $hGUI.WindowResizeLags Then SD_GUI_MainWindowResize()
Return 0
EndFunc
Func WM_ENTERSIZEMOVE()
$hGUI.WindowResizeInProgress = True
EndFunc
Func WM_EXITSIZEMOVE()
SD_GUI_MainWindowResize()
$hGUI.WindowResizeInProgress = False
EndFunc
Func SD_GUI_BigScreen()
If $MM_VIEW_CURRENT <> $MM_VIEW_BIG_SCREEN Then
SD_SwitchView($MM_VIEW_BIG_SCREEN)
Else
SD_SwitchView($MM_VIEW_PREV)
EndIf
EndFunc
Func SD_GUI_MainWindowResize(Const $bForce = False)
Local $iTimer = TimerInit()
Local $aSize = WinGetClientSize($MM_UI_MAIN)
If Not $bForce And $aSize[0] == $MM_WINDOW_CLIENT_WIDTH And $aSize[1] == $MM_WINDOW_CLIENT_HEIGHT Then Return
$MM_WINDOW_CLIENT_WIDTH = $aSize[0]
$MM_WINDOW_CLIENT_HEIGHT = $aSize[1]
Local Const $iListLength = 400 +($MM_WINDOW_CLIENT_WIDTH - 800) / 4
Local Const $iButtonWidth = 90, $iButtonLeft = $iListLength - $iButtonWidth
If $MM_VIEW_CURRENT = $MM_VIEW_MODS Then
GUICtrlSetPos($hGUI.ModList.Group, $iItemSpacing, 0, $iListLength, $MM_WINDOW_CLIENT_HEIGHT - $iItemSpacing)
GUICtrlSetPos($hGUI.ModList.List, 2 * $iItemSpacing, 17, $iListLength - 3 * $iItemSpacing - $iButtonWidth, $MM_WINDOW_CLIENT_HEIGHT - 6 * $iItemSpacing)
GUICtrlSetPos($hGUI.ModList.Up, $iButtonLeft, 16, $iButtonWidth, 25)
GUICtrlSetPos($hGUI.ModList.Down, $iButtonLeft, 16 + 25 + $iItemSpacing, $iButtonWidth, 25)
GUICtrlSetPos($hGUI.ModList.ChangeState, $iButtonLeft, 16 + 50 + 2 * $iItemSpacing, $iButtonWidth, 25)
ElseIf $MM_VIEW_CURRENT = $MM_VIEW_PLUGINS Then
GUICtrlSetPos($hGUI.PluginsList.Group, $iItemSpacing, 0, $iListLength, $MM_WINDOW_CLIENT_HEIGHT - $iItemSpacing)
GUICtrlSetPos($hGUI.PluginsList.List, 2 * $iItemSpacing, 17, $iListLength - 3 * $iItemSpacing - $iButtonWidth, $MM_WINDOW_CLIENT_HEIGHT - 6 * $iItemSpacing)
ElseIf $MM_VIEW_CURRENT = $MM_VIEW_SCN Then
GUICtrlSetPos($hGUI.ScnList.Group, $iItemSpacing, 0, $iListLength, $MM_WINDOW_CLIENT_HEIGHT - $iItemSpacing)
GUICtrlSetPos($hGUI.ScnList.List, 2 * $iItemSpacing, 17, $iListLength - 3 * $iItemSpacing - $iButtonWidth, $MM_WINDOW_CLIENT_HEIGHT - 6 * $iItemSpacing)
_GUICtrlListView_SetColumnWidth($hGUI.ScnList.List, 1, $LVSCW_AUTOSIZE_USEHEADER)
GUICtrlSetPos($hGUI.ScnList.Load, $iButtonLeft, 16, $iButtonWidth, 25)
GUICtrlSetPos($hGUI.ScnList.Save, $iButtonLeft, 16 + 25 + $iItemSpacing, $iButtonWidth, 25)
GUICtrlSetPos($hGUI.ScnList.Export, $iButtonLeft, 16 + 50 + 2 * $iItemSpacing, $iButtonWidth, 25)
GUICtrlSetPos($hGUI.ScnList.Delete, $iButtonLeft, 16 + 75 + 3 * $iItemSpacing, $iButtonWidth, 25)
EndIf
If $MM_VIEW_CURRENT = $MM_VIEW_PLUGINS Or $MM_VIEW_CURRENT = $MM_VIEW_SCN Then
GUICtrlSetPos($hGUI.Back, $iButtonLeft, $MM_WINDOW_CLIENT_HEIGHT - $iItemSpacing * 2 - 25 + 2, $iButtonWidth, 25)
EndIf
GUICtrlSetPos($hGUI.Info.TabControl, $iListLength + $iItemSpacing, 2 * $iItemSpacing - 2, $MM_WINDOW_CLIENT_WIDTH - $iListLength - 3 * $iItemSpacing, 19)
If $MM_SUBVIEW_CURRENT = $MM_SUBVIEW_DESC Then
GUICtrlSetPos($hGUI.Info.Edit, $iListLength + $iItemSpacing + 2, 3 * $iItemSpacing + 17, $MM_WINDOW_CLIENT_WIDTH - $iListLength - 2 * $iItemSpacing - 2, $MM_WINDOW_CLIENT_HEIGHT -(4 * $iItemSpacing + 17))
ElseIf $MM_SUBVIEW_CURRENT = $MM_SUBVIEW_INFO Then
ControlMove($hGUI.Info.Desc, '', 0, $iListLength + 2 * $iItemSpacing + 2, 3 * $iItemSpacing + 17, $MM_WINDOW_CLIENT_WIDTH - $iListLength - 3 * $iItemSpacing - 2, $MM_WINDOW_CLIENT_HEIGHT -(4 * $iItemSpacing + 17))
ElseIf $MM_SUBVIEW_CURRENT = $MM_SUBVIEW_SCREENS Then
Local $iLeft =($MM_VIEW_CURRENT = $MM_VIEW_BIG_SCREEN) ? $iItemSpacing :($iListLength + $iItemSpacing + 2)
Local $iTop =($MM_VIEW_CURRENT = $MM_VIEW_BIG_SCREEN) ? $iItemSpacing :(3 * $iItemSpacing + 17)
GUICtrlSetPos($hGUI.Screen.Open, $iLeft, $iTop, 25, 25)
GUICtrlSetPos($hGUI.Screen.Back, $MM_WINDOW_CLIENT_WIDTH - 50 - 2 * $iItemSpacing, $iTop, 25, 25)
GUICtrlSetPos($hGUI.Screen.Forward, $MM_WINDOW_CLIENT_WIDTH - 25 - $iItemSpacing, $iTop, 25, 25)
Local Const $iMaxWidth =($MM_VIEW_CURRENT = $MM_VIEW_BIG_SCREEN) ? $MM_WINDOW_CLIENT_WIDTH :($MM_WINDOW_CLIENT_WIDTH - $iListLength - 2 * $iItemSpacing - 2)
Local Const $iMaxHeight =($MM_VIEW_CURRENT = $MM_VIEW_BIG_SCREEN) ?($MM_WINDOW_CLIENT_HEIGHT - 25 - $iItemSpacing) :($MM_WINDOW_CLIENT_HEIGHT -(5 * $iItemSpacing + 17 + 25))
Local $iWidth = _Min($iMaxWidth, $iScreenWidth)
Local $iHeight = _Min($iMaxHeight, $iScreenHeight)
Local $f, $fRatio
If $iScreenWidth > $iScreenHeight Then
$f = $iScreenWidth / $iWidth
Else
$f = $iScreenHeight / $iHeight
EndIf
$iWidth = Int($iScreenWidth / $f)
$iHeight = Int($iScreenHeight / $f)
If $iWidth > $iMaxWidth Then
$fRatio = $iMaxWidth / $iWidth
$iWidth = Int($iWidth * $fRatio)
$iHeight = Int($iHeight * $fRatio)
ElseIf $iHeight > $iMaxHeight Then
$fRatio = $iMaxHeight / $iHeight
$iWidth = Int($iWidth * $fRatio)
$iHeight = Int($iHeight * $fRatio)
EndIf
GUICtrlSetPos($hGUI.Screen.Control, $iLeft +($iMaxWidth - $iWidth) / 2, $iTop + 25 + $iItemSpacing, $iWidth, $iHeight)
EndIf
$hGUI.WindowResizeLags = TimerDiff($iTimer) > 50
EndFunc
Func SD_GUI_Events_Register()
GUISetOnEvent($GUI_EVENT_CLOSE, "SD_GUI_Close")
GUIRegisterMsgStateful($WM_GETMINMAXINFO, "WM_GETMINMAXINFO")
GUIRegisterMsgStateful($WM_DROPFILES, "SD_GUI_Mod_AddByDnD")
GUIRegisterMsgStateful($WM_NOTIFY, "WM_NOTIFY")
GUIRegisterMsgStateful($WM_SIZE, "WM_SIZE")
GUIRegisterMsgStateful($WM_ENTERSIZEMOVE, "WM_ENTERSIZEMOVE")
GUIRegisterMsgStateful($WM_EXITSIZEMOVE, "WM_EXITSIZEMOVE")
For $iCount = 1 To $MM_LNG_LIST[0][0]
GUICtrlSetOnEvent($MM_LNG_LIST[$iCount][$MM_LNG_MENU_ID], "SD_GUI_Language_Change")
Next
GUICtrlSetOnEvent($hGUI.ModList.Up, "SD_GUI_Mod_Move_Up")
GUICtrlSetOnEvent($hGUI.ModList.Down, "SD_GUI_Mod_Move_Down")
GUICtrlSetOnEvent($hGUI.ModList.ChangeState, "SD_GUI_Mod_EnableDisable")
GUICtrlSetOnEvent($hGUI.MenuScn.Manage, "SD_GUI_ScenarioManage")
GUICtrlSetOnEvent($hGUI.MenuScn.Save, "SD_UI_ScnSave")
GUICtrlSetOnEvent($hGUI.MenuScn.Import, "SD_UI_ScnImport")
GUICtrlSetOnEvent($hGUI.MenuScn.Export, "SD_UI_ScnExport")
GUICtrlSetOnEvent($hGUI.MenuSettings.Compatibility, "SD_GUI_Mod_Compatibility")
GUICtrlSetOnEvent($hGUI.MenuSettings.Settings, "SD_GUI_ChangeSettings")
GUICtrlSetOnEvent($hGUI.MenuMod.Plugins, "SD_GUI_Manage_Plugins")
GUICtrlSetOnEvent($hGUI.MenuMod.OpenHomepage, "SD_GUI_Mod_Website")
GUICtrlSetOnEvent($hGUI.MenuMod.Delete, "SD_GUI_Mod_Delete")
GUICtrlSetOnEvent($hGUI.MenuGame.Launch, "UI_GameExeLaunch")
GUICtrlSetOnEvent($hGUI.MenuGame.Change, "SD_GUI_GameExeChange")
GUICtrlSetOnEvent($hGUI.MenuGame.ChangeWO, "SD_GUI_GameWOChange")
GUICtrlSetOnEvent($hGUI.MenuSettings.Add, "SD_GUI_Mod_Add")
GUICtrlSetOnEvent($hGUI.MenuMod.OpenFolder, "SD_GUI_Mod_OpenFolder")
GUICtrlSetOnEvent($hGUI.MenuMod.EditMod, "SD_GUI_Mod_EditMod")
GUICtrlSetOnEvent($hGUI.MenuMod.PackMod, "SD_GUI_Mod_PackMod")
GUICtrlSetOnEvent($hGUI.Back, "SD_GUI_BackToMainView")
GUICtrlSetOnEvent($hGUI.ScnList.Delete, "SD_UI_ScnDelete")
GUICtrlSetOnEvent($hGUI.ScnList.Load, "SD_UI_ScnLoad")
GUICtrlSetOnEvent($hGUI.ScnList.Save, "SD_UI_ScnSave")
GUICtrlSetOnEvent($hGUI.ScnList.Export, "SD_UI_ScnExport")
GUICtrlSetOnEvent($hGUI.Info.TabControl, "SD_GUI_TabChanged")
GUICtrlSetOnEvent($hGUI.Screen.Open, "SD_GUI_OpenScreenFolder")
GUICtrlSetOnEvent($hGUI.Screen.Back, "SD_GUI_PrevScreen")
GUICtrlSetOnEvent($hGUI.Screen.Forward, "SD_GUI_NextScreen")
GUICtrlSetOnEvent($hGUI.Screen.Control, "SD_GUI_BigScreen")
GUICtrlSetOnEvent($hDummyF5, "SD_GUI_Update")
GUICtrlSetOnEvent($hDummyF9, "SD_GUI_ImportOldPresets")
GUICtrlSetOnEvent($hDummyLinks, "SD_GUI_Mod_Website")
GUICtrlSetOnEvent($hDummyCategories, "SD_GUI_ModCategoriesUpdate")
EndFunc
Func SD_UI_ScnLoadItems()
Scn_ListLoad()
_GUICtrlListView_BeginUpdate($hGUI.ScnList.List)
_GUICtrlListView_DeleteAllItems($hGUI.ScnList.List)
_GUICtrlListView_EnableGroupView($hGUI.ScnList.List, True)
_GUICtrlListView_InsertGroup($hGUI.ScnList.List, -1, 1, Lng_Get("scenarios.special"))
_GUICtrlListView_InsertGroup($hGUI.ScnList.List, -1, 3, Lng_Get("scenarios.all"))
Local $iIndex = _GUICtrlListView_AddItem($hGUI.ScnList.List, "")
_GUICtrlListView_SetItemImage($hGUI.ScnList.List, $iIndex, Settings_Get("current_preset") ? -1 : 0)
_GUICtrlListView_SetItemGroupID($hGUI.ScnList.List, $iIndex, 1)
_GUICtrlListView_AddSubItem($hGUI.ScnList.List, $iIndex, Lng_Get("scenarios.new"), 1)
For $i = 1 To $MM_SCN_LIST[0]
$iIndex = _GUICtrlListView_AddItem($hGUI.ScnList.List, "")
_GUICtrlListView_SetItemGroupID($hGUI.ScnList.List, $iIndex, 3)
_GUICtrlListView_SetItemImage($hGUI.ScnList.List, $iIndex,(Settings_Get("current_preset") = $MM_SCN_LIST[$i]) ? 0 : -1)
_GUICtrlListView_AddSubItem($hGUI.ScnList.List, $iIndex, $MM_SCN_LIST[$i], 1)
Next
_GUICtrlListView_EndUpdate($hGUI.ScnList.List)
EndFunc
Func SD_UI_ScnImport()
Local $mData = UI_Import_Scn()
If Not $mData["selected"] Then Return
Scn_Apply($mData["data"])
If $mData["wog_settings"] Then Scn_SaveWogSettings($mData["data"]["wog_settings"])
If $mData["exe"] Then SD_UI_ApplyExe($mData["data"]["exe"])
TreeViewMain()
$sFollowMod = $MM_LIST_CONTENT[0][0] > 0 ? $MM_LIST_CONTENT[1][$MOD_ID] : ""
TreeViewTryFollow($sFollowMod)
If Not $mData["only_load"] Then
Scn_Save($mData["data"])
Settings_Set("current_preset", $mData["data"]["name"])
GUICtrlSetData($hGUI.MenuScn.Save, Lng_GetF("scenarios.save_menu", Settings_Get("current_preset") ? Settings_Get("current_preset") : Lng_Get("scenarios.new")))
Else
Settings_Set("current_preset", "")
GUICtrlSetData($hGUI.MenuScn.Save, Lng_GetF("scenarios.save_menu", Settings_Get("current_preset") ? Settings_Get("current_preset") : Lng_Get("scenarios.new")))
EndIf
SD_UI_ScnLoadItems()
EndFunc
Func SD_UI_ScnExport()
Local $bSpecificScn = @GUI_CtrlId = $hGUI.ScnList.Export
If Not $bSpecificScn Then
UI_ScnExport()
Else
Local $iItemIndex = _GUICtrlListView_GetSelectedIndices($hGUI.ScnList.List)
If $iItemIndex < 0 Then Return
If $iItemIndex = 0 Then
UI_ScnExport()
Else
Local $mData = Scn_Load($iItemIndex)
UI_ScnExport($mData)
EndIf
EndIf
EndFunc
Func SD_UI_ScnDelete()
Local $iItemIndex = _GUICtrlListView_GetSelectedIndices($hGUI.ScnList.List)
If $iItemIndex < 0 Then Return
Local $iAnswer = MsgBox($MB_YESNO + $MB_ICONQUESTION + $MB_DEFBUTTON2 + $MB_TASKMODAL, "", StringFormat(Lng_Get("scenarios.delete_confirm"), $MM_SCN_LIST[$iItemIndex]), Default, $MM_UI_MAIN)
If $iAnswer = $IDNO Then Return
If $MM_SCN_LIST[$iItemIndex] = Settings_Get("current_preset") Then
Settings_Set("current_preset", "")
GUICtrlSetData($hGUI.MenuScn.Save, Lng_GetF("scenarios.save_menu", Settings_Get("current_preset") ? Settings_Get("current_preset") : Lng_Get("scenarios.new")))
EndIf
Scn_Delete($iItemIndex)
SD_UI_ScnLoadItems()
EndFunc
Func SD_UI_ScnSave()
Local $bFromMenu = @GUI_CtrlId = $hGUI.MenuScn.Save
Local $iItemIndex = _GUICtrlListView_GetSelectedIndices($hGUI.ScnList.List)
If $iItemIndex < 0 Then Return
Local $mOptions = UI_SelectScnSaveOptions($bFromMenu ? Settings_Get("current_preset") :($iItemIndex > 0 ? $MM_SCN_LIST[$iItemIndex] : ""))
If Not $mOptions["selected"] Then Return
If Scn_Save($mOptions) Then
Settings_Set("current_preset", $mOptions["name"])
GUICtrlSetData($hGUI.MenuScn.Save, Lng_GetF("scenarios.save_menu", Settings_Get("current_preset") ? Settings_Get("current_preset") : Lng_Get("scenarios.new")))
SD_UI_ScnLoadItems()
SD_GUI_BackToMainView()
EndIf
EndFunc
Func SD_UI_ScnLoad()
Local $iItemIndex = _GUICtrlListView_GetSelectedIndices($hGUI.ScnList.List)
If $iItemIndex < 0 Then Return
Local $mData = Scn_Load($iItemIndex)
Local $mOptions = UI_SelectScnLoadOptions($mData)
If Not $mOptions["selected"] Then Return
Scn_Apply($mData)
Settings_Set("current_preset", $mData["name"])
GUICtrlSetData($hGUI.MenuScn.Save, Lng_GetF("scenarios.save_menu", Settings_Get("current_preset") ? Settings_Get("current_preset") : Lng_Get("scenarios.new")))
SD_UI_ScnLoadItems()
If $mOptions["wog_settings"] Then Scn_SaveWogSettings($mData["wog_settings"])
If $mOptions["exe"] Then SD_UI_ApplyExe($mData["exe"])
TreeViewMain()
$sFollowMod = $MM_LIST_CONTENT[0][0] > 0 ? $MM_LIST_CONTENT[1][$MOD_ID] : ""
SD_GUI_BackToMainView()
EndFunc
Func SD_GUI_ChangeSettings()
UI_Settings()
EndFunc
Func SD_GUI_ModCategoriesUpdate()
Local $iAnswer = MsgBox(4096 + 4, "", "Do you want to process all mods?" & @CRLF & "(Yes - all mods, No - only enabled)", 0, $MM_UI_MAIN)
Local $sFolder = FileSelectFolder("", "", 1 + 2, "", $MM_UI_MAIN)
If @error Then Return
ProgressOn("Please wait...", "Mod packing", "", -1, -1, 2 + 16)
Local $iTotalMods = 0
For $i = 1 To $MM_LIST_CONTENT[0][0]
If $iAnswer = $IDYES Or $MM_LIST_CONTENT[$i][$MOD_IS_ENABLED] Then $iTotalMods += 1
Next
For $i = 1 To $MM_LIST_CONTENT[0][0]
If $iAnswer = $IDYES Or $MM_LIST_CONTENT[$i][$MOD_IS_ENABLED] Then
Local $iProcess = Mod_CreatePackage($i, $sFolder & "\" & Utils_FilterFileName(Mod_Get("caption\formatted", $i)) & ".exe")
ProcessWaitClose($iProcess)
EndIf
ProgressSet($i/$iTotalMods*100, StringFormat("%i from %i done", $i, $iTotalMods))
Next
ProgressOff()
EndFunc
Func SD_GUI_ImportOldPresets()
Local $sFolder = FileSelectFolder("", "", 1 + 2, "", $MM_UI_MAIN)
If @error Then Return
Local $aFiles = _FileListToArray($sFolder & "\Tools\Mod Manager\presets", "*.txt", $FLTA_FILES, True)
If @error Then Return
Local $sDrive = "", $sDir = "", $sFilename = "", $sExtension = ""
Local $aList, $sSettings, $sExe
Local $mMap
For $i = 1 To $aFiles[0]
_PathSplit($aFiles[$i], $sDrive, $sDir, $sFilename, $sExtension)
_FileReadToArray($aFiles[$i], $aList, $FRTA_NOCOUNT)
If @error Then $aList = ArrayEmpty()
$sExe = FileReadLine($sDrive & $sDir & $sFilename & $sExtension & ".e2p", 1)
$sSettings = FileReadLine($sDrive & $sDir & $sFilename & $sExtension & ".e2p", 2)
$sSettings = Scn_LoadWogSettingsFromFile($sFolder & "\" & $sSettings)
$mMap = MapEmpty()
$mMap["name"] = $sFilename
$mMap["exe"] = $sExe
$mMap["wog_settings"] = $sSettings
$mMap["list"] = $aList
Scn_Save($mMap)
Next
SD_GUI_Update()
EndFunc
Func SD_GUI_SetLng()
GUICtrlSetData($hGUI.MenuLanguage, Lng_Get("lang.language"))
GUICtrlSetData($hGUI.ModList.Group, Lng_GetF("mod_list.caption", $MM_GAME_DIR))
GUICtrlSetData($hGUI.ModList.Up, Lng_Get("mod_list.up"))
GUICtrlSetData($hGUI.ModList.Down, Lng_Get("mod_list.down"))
GUICtrlSetData($hGUI.ModList.ChangeState, Lng_Get("mod_list.enable"))
GUICtrlSetData($hGUI.MenuMod.Menu, Lng_Get("mod_list.mod"))
GUICtrlSetData($hGUI.MenuMod.Delete, Lng_Get("mod_list.delete"))
GUICtrlSetData($hGUI.MenuMod.Plugins, Lng_Get("mod_list.plugins"))
GUICtrlSetData($hGUI.MenuMod.OpenHomepage, Lng_Get("mod_list.homepage"))
GUICtrlSetData($hGUI.MenuMod.OpenFolder, Lng_Get("mod_list.open_dir"))
GUICtrlSetData($hGUI.MenuMod.EditMod, Lng_Get("mod_list.edit_mod"))
GUICtrlSetData($hGUI.MenuMod.PackMod, Lng_Get("mod_list.pack_mod"))
GUICtrlSetData($hGUI.MenuScn.Menu, Lng_Get("scenarios.caption"))
GUICtrlSetData($hGUI.MenuScn.Manage, Lng_Get("scenarios.manage"))
GUICtrlSetData($hGUI.MenuScn.Save, Lng_GetF("scenarios.save_menu", Settings_Get("current_preset") ? Settings_Get("current_preset") : Lng_Get("scenarios.new")))
GUICtrlSetData($hGUI.MenuScn.Import, Lng_Get("scenarios.import.caption"))
GUICtrlSetData($hGUI.MenuScn.Export, Lng_Get("scenarios.export.caption"))
GUICtrlSetData($hGUI.ScnList.Group, Lng_Get("scenarios.caption"))
GUICtrlSetData($hGUI.ScnList.Save, Lng_Get("scenarios.save"))
GUICtrlSetData($hGUI.ScnList.Export, Lng_Get("scenarios.export.caption"))
GUICtrlSetData($hGUI.ScnList.Load, Lng_Get("scenarios.load"))
GUICtrlSetData($hGUI.ScnList.Delete, Lng_Get("scenarios.delete"))
GUICtrlSetData($hGUI.MenuGame.Menu, Lng_Get("game.caption"))
GUICtrlSetData($hGUI.MenuGame.Launch, Lng_GetF("game.launch", $MM_GAME_EXE))
GUICtrlSetData($hGUI.MenuGame.Change, Lng_Get("game.change"))
GUICtrlSetData($hGUI.MenuGame.ChangeWO, Lng_Get("game.wog_options"))
GUICtrlSetData($hGUI.MenuSettings.Compatibility, Lng_Get("mod_list.compatibility"))
GUICtrlSetData($hGUI.MenuSettings.Add, Lng_Get("mod_list.add_new"))
GUICtrlSetData($hGUI.MenuSettings.Menu, Lng_Get("settings.menu.caption"))
GUICtrlSetData($hGUI.MenuSettings.Settings, Lng_Get("settings.menu.settings"))
GUICtrlSetData($hGUI.PluginsList.Group, Lng_GetF("plugins_list.caption", $MM_LIST_CONTENT[0][0] > 0 ? $MM_LIST_CONTENT[1][$MOD_ID] : ""))
GUICtrlSetData($hGUI.Back, Lng_Get("plugins_list.back"))
GUICtrlSetData($hGUI.Info.TabDesc, Lng_Get("info_group.desc"))
GUICtrlSetData($hGUI.Info.TabInfo, Lng_Get("info_group.info.caption"))
GUICtrlSetData($hGUI.Info.TabScreens, Lng_Get("info_group.screens.caption"))
_GUICtrlListView_SetGroupInfo($hGUI.ScnList.List, 1, Lng_Get("scenarios.special"))
_GUICtrlListView_SetGroupInfo($hGUI.ScnList.List, 3, Lng_Get("scenarios.all"))
_GUICtrlListView_SetItemText($hGUI.ScnList.List, 0, Lng_Get("scenarios.new"), 1)
_GUICtrlSysLink_SetText($hGUI.Info.Desc, SD_FormatDescription())
EndFunc
Func SD_GUI_Mod_Compatibility()
MsgBox(4096, "", $MM_COMPATIBILITY_MESSAGE, Default, MM_GetCurrentWindow())
EndFunc
Func SD_GUI_Mod_OpenFolder()
Local $iModIndex = TreeViewGetSelectedIndex()
If $iModIndex = -1 Then Return -1
Local $sPath = '"' & $MM_LIST_DIR_PATH & "\" & $MM_LIST_CONTENT[$iModIndex][$MOD_ID] & '"'
ShellExecute($sPath)
EndFunc
Func SD_GUI_Mod_EditMod()
Local $iModIndex = TreeViewGetSelectedIndex()
If $iModIndex = -1 Then Return -1
If ModEdit_Editor($iModIndex) Then SD_GUI_Update()
EndFunc
Func SD_GUI_Mod_PackMod()
Local $iModIndex = TreeViewGetSelectedIndex()
If $iModIndex = -1 Then Return -1
Local $sSavePath = FileSaveDialog("", "", "(*.*)", $FD_PATHMUSTEXIST + $FD_PROMPTOVERWRITE, Utils_FilterFileName(Mod_Get("caption\formatted")) & ".exe", $MM_UI_MAIN)
If Not @error Then
FileDelete($sSavePath)
Mod_CreatePackage($iModIndex, $sSavePath)
If $bPackModHint Then MsgBox($MB_ICONINFORMATION, "", Lng_Get("mod_list.pack_mod_hint"))
$bPackModHint = False
EndIf
EndFunc
Func SD_GUI_Manage_Plugins()
Local $iTreeViewIndex = TreeViewGetSelectedIndex()
Plugins_ListLoad($MM_LIST_CONTENT[$iTreeViewIndex][$MOD_ID])
GUICtrlSetData($hGUI.PluginsList.Group, Lng_GetF("plugins_list.caption", $MM_LIST_CONTENT[0][0] > 0 ? Mod_Get("caption", $iTreeViewIndex) : ""))
SD_GUI_PluginsDisplay()
SD_SwitchView($MM_VIEW_PLUGINS)
EndFunc
Func SD_GUI_BackToMainView()
SD_SwitchView($MM_VIEW_MODS)
If $MM_SUBVIEW_CURRENT = $MM_SUBVIEW_BLANK Then SD_SwitchSubView($MM_SUBVIEW_PREV)
EndFunc
Func SD_GUI_GameExeChange()
SD_UI_ApplyExe(UI_SelectGameExe())
EndFunc
Func SD_GUI_GameWOChange()
Local $aSettings = Scn_LoadWogSettingsAsArray()
Local $aAnswer = WO_ManageOptions($aSettings)
If $aAnswer["selected"] Then
Scn_SaveWogSettings($aAnswer["wog_options"])
EndIf
EndFunc
Func SD_UI_ApplyExe(Const $sNewExe)
If $MM_GAME_EXE <> $sNewExe Then
$MM_GAME_EXE = $sNewExe
GUICtrlSetData($hGUI.MenuGame.Launch, Lng_GetF("game.launch", $MM_GAME_EXE))
Settings_Set("exe", $MM_GAME_EXE)
GUICtrlSetState($hGUI.MenuGame.Launch, $MM_GAME_EXE = "" ? $GUI_DISABLE : $GUI_ENABLE)
EndIf
EndFunc
Func SD_GUI_Mod_AddByDnD($hwnd, $msg, $wParam, $lParam)
#forceref $hwnd, $Msg, $wParam, $lParam
Local $aRet = DllCall("shell32.dll", "int", "DragQueryFile", "int", $wParam, "int", -1, "ptr", Null, "int", 0)
If @error Then Return SetError(1, 0, 0)
Local $aDroppedFiles[$aRet[0] + 1], $i, $tBuffer = DllStructCreate("char[256]")
$aDroppedFiles[0] = $aRet[0]
For $i = 0 To $aRet[0] - 1
DllCall("shell32.dll", "int", "DragQueryFile", "int", $wParam, "int", $i, "ptr", DllStructGetPtr($tBuffer), "int", DllStructGetSize($tBuffer))
$aDroppedFiles[$i + 1] = DllStructGetData($tBuffer, 1)
Next
DllCall("shell32.dll", "none", "DragFinish", "int", $wParam)
$tBuffer = 0
GUISetState(@SW_DISABLE, $MM_UI_MAIN)
Local $aModList = Mod_ListCheck($aDroppedFiles)
GUISetState(@SW_ENABLE, $MM_UI_MAIN)
GUISetState(@SW_RESTORE, $MM_UI_MAIN)
If $aModList[0][0] = 0 Then
MsgBox($MB_SYSTEMMODAL, "", StringFormat(Lng_Get("add_new.progress.no_mods"), "0_O"), Default, $MM_UI_MAIN)
Return "GUI_RUNDEFMSG"
EndIf
GUISetState(@SW_DISABLE, $MM_UI_MAIN)
Local $iGUIOnEventModeState = AutoItSetOption("GUIOnEventMode", 0)
PackedMod_InstallGUI_Simple($aModList, $MM_UI_MAIN)
AutoItSetOption("GUIOnEventMode", $iGUIOnEventModeState)
GUISetState(@SW_ENABLE, $MM_UI_MAIN)
GUISetState(@SW_RESTORE, $MM_UI_MAIN)
TreeViewMain()
TreeViewTryFollow($sFollowMod)
Return $GUI_RUNDEFMSG
EndFunc
Func Mod_ListCheck($aFileList, $sDir = "")
Local $iTotalMods = 0
Local $aModList[$aFileList[0] + 1][9]
ProgressOn(Lng_Get("add_new.progress.caption"), "", "", Default, Default, $DLG_MOVEABLE)
For $iCount = 1 To $aFileList[0]
Local $sPackedPath = $sDir & $aFileList[$iCount]
ProgressSet(Round($iCount / $aFileList[0] * 100) - 1, StringFormat(Lng_Get("add_new.progress.scanned"), $iCount - 1, $aFileList[0]) & @LF & $aFileList[$iCount] & @LF & StringFormat(Lng_Get("add_new.progress.found"), $iTotalMods))
Local $sModName = PackedMod_IsPackedMod($sPackedPath)
If $sModName Then
$iTotalMods += 1
$aModList[$iTotalMods][0] = $sPackedPath
$aModList[$iTotalMods][1] = $sModName
PackedMod_LoadInfo($sPackedPath, $aModList[$iTotalMods][2], $aModList[$iTotalMods][3], $aModList[$iTotalMods][4], $aModList[$iTotalMods][5], $aModList[$iTotalMods][7], $aModList[$iTotalMods][8])
$aModList[$iTotalMods][6] = Mod_GetVersion($sModName)
EndIf
Next
ProgressOff()
$aModList[0][0] = $iTotalMods
Return $aModList
EndFunc
Func SD_GUI_Mod_Add()
Local $sFileList = FileOpenDialog("", "", Lng_Get("add_new.filter"), $FD_FILEMUSTEXIST + $FD_MULTISELECT, "", $MM_UI_MAIN)
If @error Then Return False
GUISetState(@SW_DISABLE, $MM_UI_MAIN)
Local $aFileList = StringSplit($sFileList, "|", $STR_NOCOUNT)
If UBound($aFileList, 1) = 1 Then
ReDim $aFileList[2]
Local $szDrive, $szDir, $szFName, $szExt
_PathSplit($aFileList[0], $szDrive, $szDir, $szFName, $szExt)
$aFileList[0] = $szDrive & $szDir
$aFileList[1] = $szFName & $szExt
EndIf
Local $sDirPath = $aFileList[0]
$aFileList[0] = UBound($aFileList, 1) - 1
Local $aModList = Mod_ListCheck($aFileList, $sDirPath & "\")
GUISetState(@SW_ENABLE, $MM_UI_MAIN)
GUISetState(@SW_RESTORE, $MM_UI_MAIN)
If $aModList[0][0] = 0 Then
MsgBox($MB_SYSTEMMODAL, "", StringFormat(Lng_Get("add_new.progress.no_mods"), "0_O"), Default, $MM_UI_MAIN)
Return False
EndIf
GUISetState(@SW_DISABLE, $MM_UI_MAIN)
Local $iGUIOnEventModeState = AutoItSetOption("GUIOnEventMode", 0)
PackedMod_InstallGUI_Simple($aModList, $MM_UI_MAIN)
AutoItSetOption("GUIOnEventMode", $iGUIOnEventModeState)
GUISetState(@SW_ENABLE, $MM_UI_MAIN)
GUISetState(@SW_RESTORE, $MM_UI_MAIN)
TreeViewMain()
TreeViewTryFollow($sFollowMod)
EndFunc
Func SD_CLI_Mod_Add()
Mod_ListLoad()
Mod_ListLoad()
Local $aModList = Mod_ListCheck($CMDLine)
If $aModList[0][0] = 0 Then
MsgBox($MB_SYSTEMMODAL, "", StringFormat(Lng_Get("add_new.no_mods"), "0_O"), Default)
Return False
EndIf
Local $iGUIOnEventModeState = AutoItSetOption("GUIOnEventMode", 0)
Local $bResult = PackedMod_InstallGUI_Simple($aModList)
AutoItSetOption("GUIOnEventMode", $iGUIOnEventModeState)
Return $bResult
EndFunc
Func SD_GUI_SaveSize()
Local $aPos = WinGetPos($MM_UI_MAIN)
$MM_WINDOW_WIDTH = $aPos[2]
$MM_WINDOW_HEIGHT = $aPos[3]
$MM_WINDOW_MAXIMIZED = BitAND(WinGetState($MM_UI_MAIN), 32) ? True : False
Settings_Set("maximized", $MM_WINDOW_MAXIMIZED)
If Not $MM_WINDOW_MAXIMIZED Then
Settings_Set("width", $MM_WINDOW_WIDTH)
Settings_Set("height", $MM_WINDOW_HEIGHT)
EndIf
EndFunc
Func SD_GUI_LoadSize()
$MM_WINDOW_WIDTH = Settings_Get("width")
$MM_WINDOW_HEIGHT = Settings_Get("height")
$MM_WINDOW_MAXIMIZED = Settings_Get("maximized")
EndFunc
Func SD_GUI_Close()
SD_GUI_SaveSize()
$aScreens = ArrayEmpty()
SD_GUI_UpdateScreen(0)
_GDIPlus_Shutdown()
MM_GUIDelete()
Exit
EndFunc
Func SD_GUI_Mod_Website()
Local $iTreeViewIndex = TreeViewGetSelectedIndex()
If $iTreeViewIndex = -1 Then Return -1
Utils_LaunchInBrowser(Mod_Get("homepage", $iTreeViewIndex))
EndFunc
Func SD_GUI_Mod_Move_Up()
Local $iTreeViewIndex = TreeViewGetSelectedIndex()
Local $iModIndex1 = $iTreeViewIndex, $iModIndex2
If $iModIndex1 < 2 Or $iModIndex1 > $MM_LIST_CONTENT[0][0] Then Return -1
$iModIndex2 = $iModIndex1 - 1
SD_GUI_Mod_Swap($iModIndex1, $iModIndex2)
EndFunc
Func SD_GUI_Mod_Move_Down()
Local $iTreeViewIndex = TreeViewGetSelectedIndex()
Local $iModIndex1 = $iTreeViewIndex, $iModIndex2
If $iModIndex1 < 1 Or $iModIndex1 > $MM_LIST_CONTENT[0][0] - 1 Then Return -1
$iModIndex2 = $iModIndex1 + 1
SD_GUI_Mod_Swap($iModIndex1, $iModIndex2)
EndFunc
Func SD_GUI_Mod_Swap($iModIndex1, $iModIndex2)
_TraceStart("UI: Swap")
Mod_ListSwap($iModIndex1, $iModIndex2)
TreeViewSwap($iModIndex1, $iModIndex2)
TreeViewTryFollow($sFollowMod)
_TraceEnd()
EndFunc
Func SD_GUI_Mod_Delete()
Local $iTreeViewIndex = TreeViewGetSelectedIndex()
Local $iModIndex = $iTreeViewIndex
Local $iAnswer = MsgBox($MB_YESNO + $MB_ICONQUESTION + $MB_DEFBUTTON2 + $MB_TASKMODAL, "", StringFormat(Lng_Get("mod_list.delete_confirm"), Mod_Get("caption", $iModIndex)), Default, $MM_UI_MAIN)
If $iAnswer = $IDNO Then Return
SD_GUI_UpdateScreen(0)
Mod_Delete($iModIndex)
TreeViewMain()
If $MM_LIST_CONTENT[0][0] < $iModIndex Then
$iModIndex = $MM_LIST_CONTENT[0][0]
EndIf
If $iModIndex > 0 Then
$sFollowMod = $MM_LIST_CONTENT[$iModIndex][$MOD_ID]
TreeViewTryFollow($sFollowMod)
EndIf
EndFunc
Func SD_GUI_Mod_EnableDisable()
Local $iModIndex = TreeViewGetSelectedIndex()
If $iModIndex < 1 Then Return
Local $bState = $MM_LIST_CONTENT[$iModIndex][$MOD_IS_ENABLED]
If Not $bState Then
Mod_Enable($iModIndex)
Else
Mod_Disable($iModIndex)
EndIf
TreeViewMain()
If Not $bState Then
TreeViewTryFollow($sFollowMod)
Else
If $iModIndex <> 1 Then $iModIndex -= 1
$sFollowMod = $MM_LIST_CONTENT[$iModIndex][$MOD_ID]
TreeViewTryFollow($sFollowMod)
EndIf
EndFunc
Func SD_GUI_ScenarioManage()
SD_SwitchView($MM_VIEW_SCN)
SD_SwitchSubView($MM_SUBVIEW_BLANK)
EndFunc
Func SD_GUI_Plugin_ChangeState()
Local $hSelected = _GUICtrlTreeView_GetSelection($hGUI.PluginsList.List)
For $i = 1 To $aPlugins[0][0]
If $hSelected <> $aPlugins[$i][0] Then ContinueLoop
Local $iPlugin = $aPlugins[$i][1]
If $iPlugin > 0 And $iPlugin <= $MM_PLUGINS_CONTENT[0][0] Then
Plugins_ChangeState($iPlugin)
_GUICtrlTreeView_SetIcon($hGUI.PluginsList.List, $aPlugins[$i][0], $MM_PLUGINS_CONTENT[$iPlugin][$PLUGIN_STATE] ?(@ScriptDir & "\icons\dialog-ok-apply.ico") :(@ScriptDir & "\icons\edit-delete.ico"), 0, 6)
EndIf
ExitLoop
Next
EndFunc
Func SD_GUI_List_ChangeState()
Switch $MM_VIEW_CURRENT
Case $MM_VIEW_MODS
SD_GUI_Mod_EnableDisable()
Case $MM_VIEW_PLUGINS
SD_GUI_Plugin_ChangeState()
EndSwitch
EndFunc
Func SD_GUI_Update()
Mod_CacheClear()
GUISwitch($MM_UI_MAIN)
TreeViewMain()
If $MM_VIEW_CURRENT = $MM_VIEW_MODS Then TreeViewTryFollow($sFollowMod)
SD_UI_ScnLoadItems()
EndFunc
Func TreeViewMain()
Mod_ListLoad()
TreeViewFill()
EndFunc
Func SD_GUI_PluginsDisplay()
_GUICtrlTreeView_BeginUpdate($hGUI.PluginsList.List)
_GUICtrlTreeView_DeleteAll($hGUI.PluginsList.List)
If $MM_PLUGINS_PART_PRESENT[$PLUGIN_GROUP_GLOBAL] Then
$hPluginsParts[$PLUGIN_GROUP_GLOBAL] = _GUICtrlTreeView_Add($hGUI.PluginsList.List, 0, Lng_Get("plugins_list.global"))
_GUICtrlTreeView_SetIcon($hGUI.PluginsList.List, $hPluginsParts[$PLUGIN_GROUP_GLOBAL], @ScriptDir & "\icons\folder-green.ico", 0, 6)
EndIf
If $MM_PLUGINS_PART_PRESENT[$PLUGIN_GROUP_BEFORE] Then
$hPluginsParts[$PLUGIN_GROUP_BEFORE] = _GUICtrlTreeView_Add($hGUI.PluginsList.List, 0, Lng_Get("plugins_list.before_wog"))
_GUICtrlTreeView_SetIcon($hGUI.PluginsList.List, $hPluginsParts[$PLUGIN_GROUP_BEFORE], @ScriptDir & "\icons\folder-green.ico", 0, 6)
EndIf
If $MM_PLUGINS_PART_PRESENT[$PLUGIN_GROUP_AFTER] Then
$hPluginsParts[$PLUGIN_GROUP_AFTER] = _GUICtrlTreeView_Add($hGUI.PluginsList.List, 0, Lng_Get("plugins_list.after_wog"))
_GUICtrlTreeView_SetIcon($hGUI.PluginsList.List, $hPluginsParts[$PLUGIN_GROUP_AFTER], @ScriptDir & "\icons\folder-green.ico", 0, 6)
EndIf
ReDim $aPlugins[$MM_PLUGINS_CONTENT[0][0] + 1][2]
$aPlugins[0][0] = $MM_PLUGINS_CONTENT[0][0]
Local $hItem
For $i = 1 To $MM_PLUGINS_CONTENT[0][0]
$hItem = _GUICtrlTreeView_AddChild($hGUI.PluginsList.List, $hPluginsParts[$MM_PLUGINS_CONTENT[$i][$PLUGIN_GROUP]], $MM_PLUGINS_CONTENT[$i][$PLUGIN_CAPTION])
_GUICtrlTreeView_SetIcon($hGUI.PluginsList.List, $hItem, $MM_PLUGINS_CONTENT[$i][$PLUGIN_STATE] ?(@ScriptDir & "\icons\dialog-ok-apply.ico") :(@ScriptDir & "\icons\edit-delete.ico"), 0, 6)
$aPlugins[$i][0] = $hItem
$aPlugins[$i][1] = $i
Next
If $MM_PLUGINS_PART_PRESENT[$PLUGIN_GROUP_GLOBAL] Then _GUICtrlTreeView_Expand($hGUI.PluginsList.List, $hPluginsParts[$PLUGIN_GROUP_GLOBAL], True)
If $MM_PLUGINS_PART_PRESENT[$PLUGIN_GROUP_BEFORE] Then _GUICtrlTreeView_Expand($hGUI.PluginsList.List, $hPluginsParts[$PLUGIN_GROUP_BEFORE], True)
If $MM_PLUGINS_PART_PRESENT[$PLUGIN_GROUP_AFTER] Then _GUICtrlTreeView_Expand($hGUI.PluginsList.List, $hPluginsParts[$PLUGIN_GROUP_AFTER], True)
_GUICtrlTreeView_EndUpdate($hGUI.PluginsList.List)
EndFunc
Func SD_GUI_Mod_Controls_Disable()
GUICtrlSetState($hGUI.ModList.Up, $GUI_DISABLE)
GUICtrlSetState($hGUI.ModList.Down, $GUI_DISABLE)
GUICtrlSetState($hGUI.ModList.ChangeState, $GUI_DISABLE)
GUICtrlSetState($hGUI.MenuMod.Delete, $GUI_DISABLE)
GUICtrlSetState($hGUI.MenuMod.Plugins, $GUI_DISABLE)
GUICtrlSetState($hGUI.MenuMod.OpenHomepage, $GUI_DISABLE)
GUICtrlSetState($hGUI.MenuMod.OpenFolder, $GUI_DISABLE)
GUICtrlSetState($hGUI.MenuMod.EditMod, $GUI_DISABLE)
GUICtrlSetState($hGUI.MenuMod.PackMod, $GUI_DISABLE)
GUICtrlSetState($hGUI.MenuMod.Menu, $GUI_DISABLE)
GUICtrlSetData($hGUI.Info.Edit, Lng_Get("info_group.no_info"))
_GUICtrlSysLink_SetText($hGUI.Info.Desc, "")
EndFunc
Func SD_GUI_List_SelectionChanged()
Switch $MM_VIEW_CURRENT
Case $MM_VIEW_MODS
SD_GUI_Mod_SelectionChanged()
Case $MM_VIEW_PLUGINS
SD_GUI_Plugin_SelectionChanged()
EndSwitch
EndFunc
Func SD_GUI_Mod_SelectionChanged()
_TraceStart("UI: Mod Selected")
Local $iSelected = TreeViewGetSelectedIndex()
If $iSelected = -1 Then
SD_GUI_Mod_Controls_Disable()
$aScreens[0] = 0
SD_GUI_UpdateScreen(0)
Else
Local $iModIndex = $iSelected
$MM_SELECTED_MOD = $iModIndex
Local $iModIndexPrev = $iSelected > 1 ? $iSelected - 1 : -1
Local $iModIndexNext = $iSelected < $MM_LIST_CONTENT[0][0] ? $iSelected + 1 : -1
$sFollowMod = $MM_LIST_CONTENT[$iModIndex][$MOD_ID]
GUICtrlSetData($hGUI.Info.Edit, Mod_InfoLoad($MM_LIST_CONTENT[$iModIndex][$MOD_ID], Mod_Get("description\full", $iModIndex)))
If $iModIndexPrev <> -1 And $MM_LIST_CONTENT[$iModIndex][$MOD_IS_ENABLED] And $MM_LIST_CONTENT[$iModIndexPrev][$MOD_IS_ENABLED] And(Mod_Get("priority", $iModIndex) = Mod_Get("priority", $iModIndexPrev)) Then
GUICtrlSetState($hGUI.ModList.Up, $GUI_ENABLE)
Else
GUICtrlSetState($hGUI.ModList.Up, $GUI_DISABLE)
EndIf
If $iModIndexNext <> -1 And $MM_LIST_CONTENT[$iModIndex][$MOD_IS_ENABLED] And $MM_LIST_CONTENT[$iModIndexNext][$MOD_IS_ENABLED] And(Mod_Get("priority", $iModIndex) = Mod_Get("priority", $iModIndexNext)) Then
GUICtrlSetState($hGUI.ModList.Down, $GUI_ENABLE)
Else
GUICtrlSetState($hGUI.ModList.Down, $GUI_DISABLE)
EndIf
GUICtrlSetState($hGUI.ModList.ChangeState, $GUI_ENABLE)
If Not $MM_LIST_CONTENT[$iModIndex][$MOD_IS_ENABLED] Then
GUICtrlSetData($hGUI.ModList.ChangeState, Lng_Get("mod_list.enable"))
ElseIf Not $MM_LIST_CONTENT[$iModIndex][$MOD_IS_EXIST] Then
GUICtrlSetData($hGUI.ModList.ChangeState, Lng_Get("mod_list.remove"))
Else
GUICtrlSetData($hGUI.ModList.ChangeState, Lng_Get("mod_list.disable"))
EndIf
If Plugins_ModHavePlugins($MM_LIST_CONTENT[$iModIndex][$MOD_ID]) Then
GUICtrlSetState($hGUI.MenuMod.Plugins, $GUI_ENABLE)
Else
GUICtrlSetState($hGUI.MenuMod.Plugins, $GUI_DISABLE)
EndIf
If Mod_Get("homepage", $iModIndex) Then
GUICtrlSetState($hGUI.MenuMod.OpenHomepage, $GUI_ENABLE)
Else
GUICtrlSetState($hGUI.MenuMod.OpenHomepage, $GUI_DISABLE)
EndIf
If Not $MM_LIST_CONTENT[$iModIndex][$MOD_IS_EXIST] Then
GUICtrlSetState($hGUI.MenuMod.Delete, $GUI_DISABLE)
GUICtrlSetState($hGUI.MenuMod.OpenFolder, $GUI_DISABLE)
GUICtrlSetState($hGUI.MenuMod.EditMod, $GUI_DISABLE)
GUICtrlSetState($hGUI.MenuMod.PackMod, $GUI_DISABLE)
GUICtrlSetState($hGUI.MenuMod.Menu, $GUI_DISABLE)
Else
GUICtrlSetState($hGUI.MenuMod.Delete, $GUI_ENABLE)
GUICtrlSetState($hGUI.MenuMod.OpenFolder, $GUI_ENABLE)
GUICtrlSetState($hGUI.MenuMod.EditMod, $GUI_ENABLE)
GUICtrlSetState($hGUI.MenuMod.PackMod, $GUI_ENABLE)
GUICtrlSetState($hGUI.MenuMod.Menu, $GUI_ENABLE)
EndIf
_GUICtrlSysLink_SetText($hGUI.Info.Desc, SD_FormatDescription())
$aScreens = Mod_ScreenListLoad($MM_LIST_CONTENT[$iModIndex][$MOD_ID])
SD_GUI_UpdateScreenByPath($sScreenPath)
EndIf
_TraceEnd()
EndFunc
Func SD_GUI_Plugin_SelectionChanged()
Local $hSelected = _GUICtrlTreeView_GetSelection($hGUI.PluginsList.List)
For $i = 1 To $aPlugins[0][0]
If $hSelected <> $aPlugins[$i][0] Then ContinueLoop
Local $iPlugin = $aPlugins[$i][1]
If $iPlugin > 0 And $iPlugin <= $MM_PLUGINS_CONTENT[0][0] Then
GUICtrlSetData($hGUI.Info.Edit, $MM_PLUGINS_CONTENT[$iPlugin][$PLUGIN_DESCRIPTION])
EndIf
Return
Next
GUICtrlSetData($hGUI.Info.Edit, Lng_Get("info_group.no_info"))
EndFunc
Func TreeViewFill()
_GUICtrlTreeView_BeginUpdate($hGUI.ModList.List)
_GUICtrlTreeView_DeleteAll($hGUI.ModList.List)
GUICtrlSetState($hGUI.MenuSettings.Compatibility, $GUI_DISABLE)
Local $iCurrentGroup = -1
$aModListGroups[0][0] = 0
Local $aGroupEnabledList[1], $aGroupDisabledList[1]
Local $bEnabled, $iPriority, $sCategory, $vGroup, $bFound, $sCaption
For $i = 1 To $MM_LIST_CONTENT[0][0]
$bEnabled = $MM_LIST_CONTENT[$i][$MOD_IS_ENABLED]
$iPriority = Mod_Get("priority", $i)
$sCategory = Mod_Get("category", $i)
$vGroup = $bEnabled ? $iPriority : $sCategory
$bFound = False
If $bEnabled Then
For $j = 1 To $aGroupEnabledList[0]
If $aGroupEnabledList[$j] = $vGroup Then
$bFound = True
ExitLoop
EndIf
Next
Else
For $j = 1 To $aGroupDisabledList[0]
If $aGroupDisabledList[$j] = $vGroup Then
$bFound = True
ExitLoop
EndIf
Next
EndIf
If Not $bFound Then
If $bEnabled Then
$aGroupEnabledList[0] += 1
ReDim $aGroupEnabledList[$aGroupEnabledList[0] + 1]
$aGroupEnabledList[$aGroupEnabledList[0]] = $vGroup
Else
$aGroupDisabledList[0] += 1
ReDim $aGroupDisabledList[$aGroupDisabledList[0] + 1]
$aGroupDisabledList[$aGroupDisabledList[0]] = $vGroup
EndIf
EndIf
Next
For $i = 1 To $aGroupEnabledList[0]
TreeViewAddGroup(True, $aGroupEnabledList[$i])
Next
Local $aCategories = MapKeys(Lng_Get("category"))
_ArraySort($aGroupDisabledList, Default, 1)
For $i = 0 To UBound($aCategories) - 1
_ArraySearch($aGroupDisabledList, $aCategories[$i], 1)
If Not @error Then TreeViewAddGroup(False, $aCategories[$i])
Next
Local $bAddEmpty = False
For $i = 1 To $aGroupDisabledList[0]
If $aGroupDisabledList[$i] = "" Then
$bAddEmpty = True
Else
_ArraySearch($aCategories, $aGroupDisabledList[$i])
If @error Then TreeViewAddGroup(False, $aGroupDisabledList[$i])
EndIf
Next
If $bAddEmpty Then TreeViewAddGroup(False, "")
For $iCount = 1 To $MM_LIST_CONTENT[0][0]
$bEnabled = $MM_LIST_CONTENT[$iCount][$MOD_IS_ENABLED]
$iPriority = Mod_Get("priority", $iCount)
$sCategory = Mod_Get("category", $iCount)
$sCaption = $bEnabled ? Mod_Get("caption\formatted\caps", $iCount) : Mod_Get("caption", $iCount)
$sCaption = $MM_LIST_CONTENT[$iCount][$MOD_IS_EXIST] ? $sCaption : Lng_GetF("mod_list.missing", $sCaption)
$iCurrentGroup = TreeViewFindCategory($bEnabled, $bEnabled ? $iPriority : $sCategory)
$MM_LIST_CONTENT[$iCount][$MOD_PARENT_ID] = $iCurrentGroup
$MM_LIST_CONTENT[$iCount][$MOD_ITEM_ID] = GUICtrlCreateTreeViewItem($sCaption, $aModListGroups[$MM_LIST_CONTENT[$iCount][$MOD_PARENT_ID]][0])
_GUICtrlTreeView_SetIcon($hGUI.ModList.List, $MM_LIST_CONTENT[$iCount][$MOD_ITEM_ID], Mod_Get("icon_path", $iCount), Mod_Get("icon\index", $iCount), 6)
Next
For $iCount = 1 To $aModListGroups[0][0]
GUICtrlSetState($aModListGroups[$iCount][0], $GUI_EXPAND)
Next
TreeViewColor()
_GUICtrlTreeView_EndUpdate($hGUI.ModList.List)
EndFunc
Func TreeViewAddGroup(Const $bEnabled, Const $vItem)
Local $sText = StringUpper($bEnabled ? Lng_Get("mod_list.group.enabled") : Lng_Get("mod_list.group.disabled"))
If $bEnabled And $vItem <> 0 Then $sText = StringFormat(Lng_Get("mod_list.group.enabled_with_priority"), $vItem)
If Not $bEnabled And $vItem <> "" Then $sText = Lng_GetF("mod_list.group.disabled_group", StringUpper(Lng_GetCategory($vItem)))
$aModListGroups[0][0] += 1
ReDim $aModListGroups[$aModListGroups[0][0] + 1][3]
$aModListGroups[$aModListGroups[0][0]][0] = GUICtrlCreateTreeViewItem($sText, $hGUI.ModList.List)
GUICtrlSetColor($aModListGroups[$aModListGroups[0][0]][0], 0x0000C0)
_GUICtrlTreeView_SetIcon($hGUI.ModList.List, $aModListGroups[$aModListGroups[0][0]][0], @ScriptDir & "\icons\" &($bEnabled ? "folder-green.ico" : "folder-red.ico"), 0, 6)
$aModListGroups[$aModListGroups[0][0]][1] = $bEnabled
$aModListGroups[$aModListGroups[0][0]][2] = $vItem
EndFunc
Func TreeViewFindCategory(Const $bEnabled, Const $vData)
For $i = 1 To $aModListGroups[0][0]
If $bEnabled = $aModListGroups[$i][1] And $aModListGroups[$i][2] = $vData Then Return $i
Next
Return -1
EndFunc
Func TreeViewColor()
$MM_COMPATIBILITY_MESSAGE = ""
Local $iMasterIndex = -1
For $iModIndex = 1 To $MM_LIST_CONTENT[0][0]
GUICtrlSetColor($MM_LIST_CONTENT[$iModIndex][$MOD_ITEM_ID], Default)
If Not $MM_LIST_CONTENT[$iModIndex][$MOD_IS_EXIST] Then GUICtrlSetColor($MM_LIST_CONTENT[$iModIndex][$MOD_ITEM_ID], 0xC00000)
If $iMasterIndex = -1 And $MM_LIST_CONTENT[$iModIndex][$MOD_IS_ENABLED] And $MM_LIST_CONTENT[$iModIndex][$MOD_IS_EXIST] Then
For $i = 1 To $MM_LIST_CONTENT[0][0]
If $iModIndex = $i Or Not $MM_LIST_CONTENT[$i][$MOD_IS_ENABLED] Or Not $MM_LIST_CONTENT[$i][$MOD_IS_EXIST] Then ContinueLoop
If Not Mod_IsCompatible($iModIndex, $i) Then
$iMasterIndex = $iModIndex
GUICtrlSetColor($MM_LIST_CONTENT[$iModIndex][$MOD_ITEM_ID], 0x00C000)
$MM_COMPATIBILITY_MESSAGE = StringFormat(Lng_Get("compatibility.part1"), Mod_Get("caption", $iModIndex)) & @CRLF
ExitLoop
EndIf
Next
ElseIf $iMasterIndex > 0 And $MM_LIST_CONTENT[$iModIndex][$MOD_IS_ENABLED] And $MM_LIST_CONTENT[$iModIndex][$MOD_IS_EXIST] Then
If Not Mod_IsCompatible($iMasterIndex, $iModIndex) Then
GUICtrlSetColor($MM_LIST_CONTENT[$iModIndex][$MOD_ITEM_ID], 0xCC0000)
$MM_COMPATIBILITY_MESSAGE &= Mod_Get("caption", $iModIndex) & @CRLF
EndIf
EndIf
Next
If $MM_COMPATIBILITY_MESSAGE <> "" Then
$MM_COMPATIBILITY_MESSAGE &= @CRLF & Lng_Get("compatibility.part2")
GUICtrlSetState($hGUI.MenuSettings.Compatibility, $GUI_ENABLE)
EndIf
EndFunc
Func TreeViewSwap($iIndex1, $iIndex2)
_GUICtrlTreeView_BeginUpdate($hGUI.ModList.List)
Local $vTemp
$vTemp = _GUICtrlTreeView_GetText($hGUI.ModList.List, $MM_LIST_CONTENT[$iIndex1][$MOD_ITEM_ID])
_GUICtrlTreeView_SetText($hGUI.ModList.List, $MM_LIST_CONTENT[$iIndex1][$MOD_ITEM_ID], _GUICtrlTreeView_GetText($hGUI.ModList.List, $MM_LIST_CONTENT[$iIndex2][$MOD_ITEM_ID]))
_GUICtrlTreeView_SetText($hGUI.ModList.List, $MM_LIST_CONTENT[$iIndex2][$MOD_ITEM_ID], $vTemp)
$vTemp = _GUICtrlTreeView_GetImageIndex($hGUI.ModList.List, $MM_LIST_CONTENT[$iIndex1][$MOD_ITEM_ID])
_GUICtrlTreeView_SetImageIndex($hGUI.ModList.List, $MM_LIST_CONTENT[$iIndex1][$MOD_ITEM_ID], _GUICtrlTreeView_GetImageIndex($hGUI.ModList.List, $MM_LIST_CONTENT[$iIndex2][$MOD_ITEM_ID]))
_GUICtrlTreeView_SetImageIndex($hGUI.ModList.List, $MM_LIST_CONTENT[$iIndex2][$MOD_ITEM_ID], $vTemp)
$vTemp = _GUICtrlTreeView_GetStateImageIndex($hGUI.ModList.List, $MM_LIST_CONTENT[$iIndex1][$MOD_ITEM_ID])
_GUICtrlTreeView_SetStateImageIndex($hGUI.ModList.List, $MM_LIST_CONTENT[$iIndex1][$MOD_ITEM_ID], _GUICtrlTreeView_GetStateImageIndex($hGUI.ModList.List, $MM_LIST_CONTENT[$iIndex2][$MOD_ITEM_ID]))
_GUICtrlTreeView_SetStateImageIndex($hGUI.ModList.List, $MM_LIST_CONTENT[$iIndex2][$MOD_ITEM_ID], $vTemp)
$vTemp = _GUICtrlTreeView_GetSelectedImageIndex($hGUI.ModList.List, $MM_LIST_CONTENT[$iIndex1][$MOD_ITEM_ID])
_GUICtrlTreeView_SetSelectedImageIndex($hGUI.ModList.List, $MM_LIST_CONTENT[$iIndex1][$MOD_ITEM_ID], _GUICtrlTreeView_GetSelectedImageIndex($hGUI.ModList.List, $MM_LIST_CONTENT[$iIndex2][$MOD_ITEM_ID]))
_GUICtrlTreeView_SetSelectedImageIndex($hGUI.ModList.List, $MM_LIST_CONTENT[$iIndex2][$MOD_ITEM_ID], $vTemp)
TreeViewColor()
_GUICtrlTreeView_EndUpdate($hGUI.ModList.List)
EndFunc
Func TreeViewGetSelectedIndex()
Local $hSelected = GUICtrlRead($hGUI.ModList.List)
For $iCount = 1 To $MM_LIST_CONTENT[0][0]
If $MM_LIST_CONTENT[$iCount][$MOD_ITEM_ID] = $hSelected Then Return $iCount
Next
Return -1
EndFunc
Func TreeViewTryFollow($sModName)
If $bInTrack Then Return
$bInTrack = True
Switch $MM_VIEW_CURRENT
Case $MM_VIEW_MODS
List_ModsTryFollow($sModName)
Case $MM_VIEW_PLUGINS
List_PluginsResetSelection()
EndSwitch
$bInTrack = False
EndFunc
Func List_ModsTryFollow($sModID)
Local $iModIndex = 0
For $iCount = 1 To $MM_LIST_CONTENT[0][0]
If $MM_LIST_CONTENT[$iCount][$MOD_ID] = $sModID Then
$iModIndex = $iCount
ExitLoop
EndIf
Next
If $iModIndex = 0 Then
GUICtrlSetState($hGUI.ModList.List, $GUI_FOCUS)
Return
EndIf
If $aModListGroups[0][0] > 0 Then GUICtrlSetState($aModListGroups[1][0], $GUI_FOCUS)
If $iModIndex <> -1 Then GUICtrlSetState($MM_LIST_CONTENT[$iModIndex][$MOD_ITEM_ID], $GUI_FOCUS)
EndFunc
Func List_PluginsResetSelection()
Local $iFirstGroup = -1
If $MM_PLUGINS_PART_PRESENT[$PLUGIN_GROUP_GLOBAL] Then
$iFirstGroup = $PLUGIN_GROUP_GLOBAL
ElseIf $MM_PLUGINS_PART_PRESENT[$PLUGIN_GROUP_BEFORE] Then
$iFirstGroup = $PLUGIN_GROUP_BEFORE
ElseIf $MM_PLUGINS_PART_PRESENT[$PLUGIN_GROUP_AFTER] Then
$iFirstGroup = $PLUGIN_GROUP_AFTER
EndIf
If $iFirstGroup <> -1 Then
_GUICtrlTreeView_SelectItem($hGUI.PluginsList.List, $hPluginsParts[$PLUGIN_GROUP_GLOBAL], $TVGN_FIRSTVISIBLE)
_GUICtrlTreeView_SelectItem($hGUI.PluginsList.List, $hPluginsParts[$PLUGIN_GROUP_GLOBAL], $TVGN_CARET)
EndIf
If $MM_PLUGINS_CONTENT[0][0] > 0 Then
_GUICtrlTreeView_SelectItem($hGUI.PluginsList.List, $aPlugins[1][0], $TVGN_CARET)
GUICtrlSetState($aPlugins[1][0], $GUI_FOCUS)
EndIf
EndFunc
Func WM_GETMINMAXINFO($hwnd, $msg, $iwParam, $ilParam)
#forceref $hwnd, $Msg, $iwParam, $ilParam
If $hwnd <> $MM_UI_MAIN Then Return $GUI_RUNDEFMSG
Local $tagMaxinfo = DllStructCreate("int;int;int;int;int;int;int;int;int;int", $ilParam)
DllStructSetData($tagMaxinfo, 7, $MM_WINDOW_MIN_WIDTH_FULL)
DllStructSetData($tagMaxinfo, 8, $MM_WINDOW_MIN_HEIGHT_FULL)
Return 0
EndFunc
Func WM_NOTIFY($hwnd, $iMsg, $iwParam, $ilParam)
#forceref $hWnd, $iMsg, $iwParam, $ilParam
Local $hWndFrom, $iCode, $tNMHDR
$tNMHDR = DllStructCreate($tagNMHDR, $ilParam)
$hWndFrom = HWnd(DllStructGetData($tNMHDR, "hWndFrom"))
$iCode = DllStructGetData($tNMHDR, "Code")
Switch $hWndFrom
Case GUICtrlGetHandle($hGUI.ModList.List), GUICtrlGetHandle($hGUI.PluginsList.List)
Switch $iCode
Case $NM_DBLCLK
$bEnableDisable = True
Case $TVN_SELCHANGEDA, $TVN_SELCHANGEDW
$bSelectionChanged = True
Case $NM_RCLICK
Local $tPoint = _WinAPI_GetMousePos(True, $hWndFrom), $tHitTest
$tHitTest = _GUICtrlTreeView_HitTestEx($hWndFrom, DllStructGetData($tPoint, 1), DllStructGetData($tPoint, 2))
If BitAND(DllStructGetData($tHitTest, "Flags"), BitOR($TVHT_ONITEM, $TVHT_ONITEMRIGHT)) Then
_GUICtrlTreeView_SelectItem($hWndFrom, DllStructGetData($tHitTest, 'Item'))
SD_GUI_List_SelectionChanged()
EndIf
EndSwitch
Case GUICtrlGetHandle($hGUI.ScnList.List)
Switch $iCode
Case $LVN_BEGINDRAG
Return 0
Case $LVN_ITEMCHANGED
If Not _GUICtrlListView_GetSelectedCount($hGUI.ScnList.List) Then
GUICtrlSetState($hGUI.ScnList.Load, $GUI_DISABLE)
GUICtrlSetState($hGUI.ScnList.Save, $GUI_DISABLE)
GUICtrlSetState($hGUI.ScnList.Export, $GUI_DISABLE)
GUICtrlSetState($hGUI.ScnList.Delete, $GUI_DISABLE)
Else
GUICtrlSetState($hGUI.ScnList.Save, $GUI_ENABLE)
GUICtrlSetState($hGUI.ScnList.Export, $GUI_ENABLE)
Local $aSelected = _GUICtrlListView_GetSelectedIndices($hGUI.ScnList.List, True)
GUICtrlSetState($hGUI.ScnList.Load,($aSelected[0] >= 1 And $aSelected[1] == 0) ? $GUI_DISABLE : $GUI_ENABLE)
GUICtrlSetState($hGUI.ScnList.Delete, $aSelected[0] >= 1 And $aSelected[1] == 0 ? $GUI_DISABLE : $GUI_ENABLE)
EndIf
EndSwitch
Case $hGUI.Info.Desc
Local $tNMLINK = DllStructCreate($tagNMLINK, $ilParam)
Local $ID = DllStructGetData($tNMLINK, "Code")
Switch $ID
Case $NM_CLICK, $NM_RETURN
GUICtrlSendToDummy($hDummyLinks, DllStructGetData($tNMLINK, "Link"))
EndSwitch
EndSwitch
Return $GUI_RUNDEFMSG
EndFunc
Func SD_GUI_TabChanged()
Switch GUICtrlRead($hGUI.Info.TabControl, 1)
Case $hGUI.Info.TabDesc
SD_SwitchSubView($MM_SUBVIEW_DESC)
Case $hGUI.Info.TabInfo
SD_SwitchSubView($MM_SUBVIEW_INFO)
Case $hGUI.Info.TabScreens
SD_SwitchSubView($MM_SUBVIEW_SCREENS)
EndSwitch
EndFunc
Func SD_SwitchView(Const $iNewView = $MM_VIEW_MODS)
GUICtrlSetData($hGUI.Info.Edit, "")
$MM_VIEW_PREV = $MM_VIEW_CURRENT
$MM_VIEW_CURRENT = $iNewView
SD_GUI_MainWindowResize(True)
GUICtrlSetState($hGUI.ModList.Group, $MM_VIEW_CURRENT = $MM_VIEW_MODS ? $GUI_SHOW : $GUI_HIDE)
GUICtrlSetState($hGUI.ModList.List, $MM_VIEW_CURRENT = $MM_VIEW_MODS ? $GUI_SHOW : $GUI_HIDE)
GUICtrlSetState($hGUI.ModList.Up, $MM_VIEW_CURRENT = $MM_VIEW_MODS ? $GUI_SHOW : $GUI_HIDE)
GUICtrlSetState($hGUI.ModList.Down, $MM_VIEW_CURRENT = $MM_VIEW_MODS ? $GUI_SHOW : $GUI_HIDE)
GUICtrlSetState($hGUI.ModList.ChangeState, $MM_VIEW_CURRENT = $MM_VIEW_MODS ? $GUI_SHOW : $GUI_HIDE)
GUICtrlSetState($hGUI.PluginsList.Group, $MM_VIEW_CURRENT = $MM_VIEW_PLUGINS ? $GUI_SHOW : $GUI_HIDE)
GUICtrlSetState($hGUI.PluginsList.List, $MM_VIEW_CURRENT = $MM_VIEW_PLUGINS ? $GUI_SHOW : $GUI_HIDE)
GUICtrlSetState($hGUI.MenuScn.Manage, $MM_VIEW_CURRENT = $MM_VIEW_SCN ? $GUI_DISABLE : $GUI_ENABLE)
GUICtrlSetState($hGUI.ScnList.Group, $MM_VIEW_CURRENT = $MM_VIEW_SCN ? $GUI_SHOW : $GUI_HIDE)
GUICtrlSetState($hGUI.ScnList.List, $MM_VIEW_CURRENT = $MM_VIEW_SCN ? $GUI_SHOW : $GUI_HIDE)
GUICtrlSetState($hGUI.ScnList.Load, $MM_VIEW_CURRENT = $MM_VIEW_SCN ? $GUI_SHOW : $GUI_HIDE)
GUICtrlSetState($hGUI.ScnList.Save, $MM_VIEW_CURRENT = $MM_VIEW_SCN ? $GUI_SHOW : $GUI_HIDE)
GUICtrlSetState($hGUI.ScnList.Export, $MM_VIEW_CURRENT = $MM_VIEW_SCN ? $GUI_SHOW : $GUI_HIDE)
GUICtrlSetState($hGUI.ScnList.Delete, $MM_VIEW_CURRENT = $MM_VIEW_SCN ? $GUI_SHOW : $GUI_HIDE)
GUICtrlSetState($hGUI.Back,($MM_VIEW_CURRENT = $MM_VIEW_PLUGINS Or $MM_VIEW_CURRENT = $MM_VIEW_SCN) ? $GUI_SHOW : $GUI_HIDE)
If $MM_VIEW_CURRENT = $MM_VIEW_MODS Then
TreeViewTryFollow($sFollowMod)
ElseIf $MM_VIEW_CURRENT = $MM_VIEW_PLUGINS Then
GUICtrlSetState($hGUI.MenuMod.Menu, $GUI_DISABLE)
TreeViewTryFollow("")
EndIf
GUICtrlSetState($hGUI.Info.TabControl, $MM_VIEW_CURRENT = $MM_VIEW_BIG_SCREEN Or $MM_VIEW_CURRENT = $MM_VIEW_SCN ? $GUI_HIDE : $GUI_SHOW)
EndFunc
Func SD_SwitchSubView(Const $iNewView = $MM_SUBVIEW_DESC)
$MM_SUBVIEW_PREV = $MM_SUBVIEW_CURRENT
$MM_SUBVIEW_CURRENT = $iNewView
SD_GUI_MainWindowResize(True)
GUICtrlSetState($hGUI.Info.Edit, $MM_SUBVIEW_CURRENT = $MM_SUBVIEW_DESC ? $GUI_SHOW : $GUI_HIDE)
If $MM_SUBVIEW_CURRENT = $MM_SUBVIEW_INFO Then
ControlShow($MM_UI_MAIN, '', $hGUI.Info.Desc)
Else
ControlHide($MM_UI_MAIN, '', $hGUI.Info.Desc)
EndIf
GUICtrlSetState($hGUI.Screen.Control, $MM_SUBVIEW_CURRENT = $MM_SUBVIEW_SCREENS ? $GUI_SHOW : $GUI_HIDE)
GUICtrlSetState($hGUI.Screen.Open, $MM_SUBVIEW_CURRENT = $MM_SUBVIEW_SCREENS ? $GUI_SHOW : $GUI_HIDE)
GUICtrlSetState($hGUI.Screen.Back, $MM_SUBVIEW_CURRENT = $MM_SUBVIEW_SCREENS ? $GUI_SHOW : $GUI_HIDE)
GUICtrlSetState($hGUI.Screen.Forward, $MM_SUBVIEW_CURRENT = $MM_SUBVIEW_SCREENS ? $GUI_SHOW : $GUI_HIDE)
If $MM_SUBVIEW_CURRENT = $MM_SUBVIEW_SCREENS Then SD_GUI_UpdateScreenByPath($sScreenPath)
EndFunc
Func SD_FormatDescription()
If $MM_SELECTED_MOD < 0 Then Return ""
Local $sText
If $MM_LIST_CONTENT[$MM_SELECTED_MOD][$MOD_ID] <> Mod_Get("caption") Then
$sText = Lng_GetF("info_group.info.mod_caption", Mod_Get("caption"), $MM_LIST_CONTENT[$MM_SELECTED_MOD][$MOD_ID])
Else
$sText = Lng_GetF("info_group.info.mod_caption_s", Mod_Get("caption"))
EndIf
If Mod_Get("category") <> "" Then $sText &= @CRLF & Lng_GetF("info_group.info.category", Lng_GetCategory(Mod_Get("category")))
If Mod_Get("mod_version") <> "0.0" Then $sText &= @CRLF & Lng_GetF("info_group.info.version", Mod_Get("mod_version"))
If Mod_Get("author") <> "" Then $sText &= @CRLF & Lng_GetF("info_group.info.author", Mod_Get("author"))
If Mod_Get("homepage") <> "" Then $sText &= @CRLF & Lng_GetF("info_group.info.link", Mod_Get("homepage"))
Return $sText
EndFunc
