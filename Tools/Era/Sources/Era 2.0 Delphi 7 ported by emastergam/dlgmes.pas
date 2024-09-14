UNIT DlgMes;
{
DESCRIPTION:  Simple dialogs for messages and debugging
AUTHOR:       Alexander Shostak (aka Berserker aka EtherniDee aka BerSoft)
}

(***)  INTERFACE  (***)
USES Windows, SysUtils, Math, Utils, StrLib, Lang, DlgMesLng;

CONST
  NO_WINDOW = 0;

  (* Icons *)
  NO_ICON       = Windows.MB_OK;
  ICON_ERROR    = Windows.MB_ICONSTOP;
  ICON_QUESTION = Windows.MB_ICONQUESTION;
  
  (* Ask results *)
  YES = TRUE;
  NO  = FALSE;
  
  ID_YES    = 0;
  ID_NO     = 1;
  ID_CANCEL = 2;


VAR
  hParentWindow:  INTEGER = NO_WINDOW;
  DialogsTitle:   STRING;


PROCEDURE MsgEx (CONST Mes, Title: STRING; Icon: INTEGER);
PROCEDURE MsgTitle (CONST Mes, Title: STRING);
PROCEDURE Msg (CONST Mes: STRING);
PROCEDURE MsgError(CONST Err: STRING);
PROCEDURE OK;
FUNCTION  AskYesNo (CONST Question: STRING): BOOLEAN;
FUNCTION  AskYesNoCancel (CONST Question: STRING): INTEGER;
FUNCTION  AskOkCancel (CONST Question: STRING): BOOLEAN;
FUNCTION  VarToString (CONST VarRec: TVarRec): STRING;
FUNCTION  ToString (CONST Vars: ARRAY OF CONST): STRING;
FUNCTION  PArrItemToString (VAR PArrItem: POINTER; VarType: INTEGER): STRING;
FUNCTION  PVarToString (PVar: POINTER; VarType: INTEGER): STRING;
PROCEDURE VarDump (CONST Vars: ARRAY OF CONST; CONST Title: STRING);
PROCEDURE ArrDump (CONST Arr: POINTER; Count: INTEGER; CONST ElemsType: INTEGER; CONST Title: STRING);


(***)  IMPLEMENTATION  (***)


VAR
(* OU *)  Lng:  DlgMesLng.PLangStringsArr;


PROCEDURE MsgEx (CONST Mes, Title: STRING; Icon: INTEGER);
BEGIN
  Windows.MessageBox(hParentWindow, PCHAR(Mes), PCHAR(Title), Icon);
END; // .PROCEDURE MsgEx

PROCEDURE MsgTitle (CONST Mes, Title: STRING);
BEGIN
  MsgEx(Mes, Title, NO_ICON);
END; // .PROCEDURE MsgTitle

PROCEDURE Msg (CONST Mes: STRING);
BEGIN
  MsgEx(Mes, DialogsTitle, NO_ICON);
END; // .PROCEDURE Msg

PROCEDURE MsgError(CONST Err: STRING);
BEGIN
  MsgEx(Err, DialogsTitle, ICON_ERROR);
END; // .PROCEDURE MsgError

PROCEDURE OK;
BEGIN
  Msg('OK');
END; // .PROCEDURE OK

FUNCTION AskYesNo (CONST Question: STRING): BOOLEAN;
BEGIN
  RESULT  :=  NO;
  IF
    Windows.MessageBox(hParentWindow, PCHAR(Question), PCHAR(Lng[STR_QUESTION]), Windows.MB_YESNO + ICON_QUESTION) = Windows.ID_YES
  THEN BEGIN
    RESULT  :=  YES;
  END; // .IF
END; // .FUNCTION AskYesNo

FUNCTION AskOkCancel (CONST Question: STRING): BOOLEAN;
BEGIN
  RESULT  :=  NO;
  IF Windows.MessageBox (hParentWindow, PCHAR(Question), PCHAR(Lng[STR_QUESTION]), Windows.MB_OKCANCEL + ICON_QUESTION) = Windows.ID_OK
  THEN BEGIN
    RESULT  :=  YES;
  END; // .IF
END; // .FUNCTION AskOkCancel

FUNCTION AskYesNoCancel (CONST Question: STRING): INTEGER;
BEGIN
  RESULT  :=  0;
  CASE Windows.MessageBox (hParentWindow, PCHAR(Question), PCHAR(Lng[STR_QUESTION]), Windows.MB_YESNOCANCEL + ICON_QUESTION) OF 
    Windows.IDYES:      RESULT  :=  ID_YES;
    Windows.IDNO:       RESULT  :=  ID_NO;
    Windows.ID_CANCEL:  RESULT  :=  ID_CANCEL;
  END; // .SWITCH
END; // .FUNCTION AskYesNoCancel

FUNCTION VarToString (CONST VarRec: TVarRec): STRING;
BEGIN
  CASE VarRec.vType OF
    vtBoolean:
    BEGIN
      IF VarRec.vBoolean THEN BEGIN
        RESULT  :=  'BOOLEAN: TRUE';
      END // .IF
      ELSE BEGIN
        RESULT  :=  'BOOLEAN: FALSE';
      END; // .ELSE
    END; // .CASE vtBoolean
    vtInteger:    RESULT  :=  'INTEGER: ' + SysUtils.IntToStr(VarRec.vInteger);
    vtChar:       RESULT  :=  'CHAR: ' + VarRec.vChar;
    vtWideChar:   RESULT  :=  'WIDECHAR: ' + VarRec.vWideChar;
    vtExtended:   RESULT  :=  'REAL: ' + SysUtils.FloatToStr(VarRec.vExtended^);
    vtString:     RESULT  :=  'STRING: ' + VarRec.vString^;
    vtPointer:    RESULT  :=  'POINTER: $' + SysUtils.Format('%x',[INTEGER(VarRec.vPointer)]);
    vtPChar:      RESULT  :=  'PCHAR: ' + VarRec.vPChar;
    vtPWideChar:  RESULT  :=  'PWIDECHAR: ' + VarRec.vPWideChar;
    vtObject:     RESULT  :=  'OBJECT: ' + VarRec.vObject.ClassName;
    vtClass:      RESULT  :=  'CLASS: ' + VarRec.vClass.ClassName;
    vtCurrency:   RESULT  :=  'CURRENCY: ' + SysUtils.CurrToStr(VarRec.vCurrency^);
    vtAnsiString: RESULT  :=  'ANSISTRING: ' + STRING(VarRec.vAnsiString);
    vtWideString: RESULT  :=  'WIDESTRING: ' + WideString(VarRec.vWideString);
    vtVariant:    RESULT  :=  'VARIANT: ' + STRING(VarRec.vVariant);
    vtInterface:  RESULT  :=  'INTERFACE: $' + SysUtils.Format('%x',[INTEGER(VarRec.vInterface)]);
    vtInt64:      RESULT  :=  'INT64: ' + SysUtils.IntToStr(VarRec.vInt64^);
    ELSE
      RESULT  :=  'UNKNOWN:';
  END; // .CASE VarRec.vType
END; // .FUNCTION VarToString

FUNCTION ToString (CONST Vars: ARRAY OF CONST): STRING;
VAR
  ResArr: Utils.TArrayOfString;
  i:      INTEGER;

BEGIN
  SetLength(ResArr, High(Vars) + 1);
  FOR i:=0 TO High(Vars) DO BEGIN
    ResArr[i] :=  VarToString(Vars[i]);
  END; // .FOR
  RESULT  :=  StrLib.Join(ResArr, #13#10);
END; // .FUNCTION ToString

FUNCTION PArrItemToString (VAR PArrItem: POINTER; VarType: INTEGER): STRING;
VAR
  VarRec: TVarRec;

BEGIN
  {!} ASSERT(Math.InRange(VarType, 0, vtInt64));
  VarRec.vType  :=  VarType;
  CASE VarType OF
    vtBoolean:    BEGIN VarRec.vBoolean     :=  PBOOLEAN(PArrItem)^; INC(PBOOLEAN(PArrItem)); END;
    vtInteger:    BEGIN VarRec.vInteger     :=  PINTEGER(PArrItem)^; INC(PINTEGER(PArrItem)); END;
    vtChar:       BEGIN VarRec.vChar        :=  PCHAR(PArrItem)^; INC(PCHAR(PArrItem)); END;
    vtWideChar:   BEGIN VarRec.vWideChar    :=  PWideChar(PArrItem)^; INC(PWideChar(PArrItem)); END;
    vtExtended:   BEGIN VarRec.vExtended    :=  PArrItem; INC(PEXTENDED(PArrItem)); END;
    vtString:     BEGIN VarRec.vString      :=  PArrItem; INC(PShortString(PArrItem)); END;
    vtPointer:    BEGIN VarRec.vPointer     :=  PPOINTER(PArrItem)^; INC(PPOINTER(PArrItem)); END;
    vtPChar:      BEGIN VarRec.vPChar       :=  PPCHAR(PArrItem)^; INC(PPCHAR(PArrItem)); END;
    vtPWideChar:  BEGIN VarRec.vPWideChar   :=  PPWideChar(PArrItem)^; INC(PPWideChar(PArrItem)); END;
    vtObject:     BEGIN VarRec.vObject      :=  PObject(PArrItem)^; INC(PObject(PArrItem)); END;
    vtClass:      BEGIN VarRec.vClass       :=  PClass(PArrItem)^; INC(PClass(PArrItem)); END;
    vtCurrency:   BEGIN VarRec.vCurrency    :=  PArrItem; INC(PCURRENCY(PArrItem)); END;
    vtAnsiString: BEGIN VarRec.vAnsiString  :=  PPOINTER(PArrItem)^; INC(PPOINTER(PArrItem)); END;
    vtWideString: BEGIN VarRec.vWideString  :=  PPOINTER(PArrItem)^; INC(PPOINTER(PArrItem)); END;
    vtVariant:    BEGIN VarRec.vVariant     :=  PArrItem; INC(PVARIANT(PArrItem)); END;
    vtInterface:  BEGIN VarRec.vInterface   :=  PPOINTER(PArrItem)^; INC(PPOINTER(PArrItem)); END;
    vtInt64:      BEGIN VarRec.vInt64       :=  PArrItem; INC(PINT64(PArrItem)); END;
  END; // .CASE PArrItem.vType
  RESULT  :=  VarToString(VarRec);
END; // .FUNCTION PArrItemToString

FUNCTION PVarToString (PVar: POINTER; VarType: INTEGER): STRING;
VAR
(* U *) Temp: POINTER;

BEGIN
  {!} ASSERT(Math.InRange(VarType, 0, vtInt64));
  Temp  :=  NIL;
  // * * * * * //
  Temp    :=  PVar;
  RESULT  :=  PArrItemToString(Temp, VarType);
END; // .FUNCTION PVarToString

PROCEDURE VarDump (CONST Vars: ARRAY OF CONST; CONST Title: STRING);
BEGIN
  MsgTitle(ToString(Vars), Title);
END; // .PROCEDURE VarDump

PROCEDURE ArrDump (CONST Arr: POINTER; Count: INTEGER; CONST ElemsType: INTEGER; CONST Title: STRING);
CONST
  NUM_ITEMS_PER_DISPLAY = 20;

VAR
(* U *) CurrItem:           POINTER;
        CurrItemInd:        INTEGER;
        StrArr:             Utils.TArrayOfString; 
        DisplayN:           INTEGER;
        NumItemsToDisplay:  INTEGER;
        i:                  INTEGER;
  
BEGIN
  CurrItemInd :=  0;
  CurrItem    :=  Arr;
  FOR DisplayN:=1 TO Math.Ceil(Count / NUM_ITEMS_PER_DISPLAY) DO BEGIN
    NumItemsToDisplay :=  Math.Min(Count - CurrItemInd, NUM_ITEMS_PER_DISPLAY);
    SetLength(StrArr, NumItemsToDisplay);
    FOR i:=0 TO NumItemsToDisplay - 1 DO BEGIN
      StrArr[i] :=  '[' + SysUtils.IntToStr(i) + ']: ' + PArrItemToString(CurrItem, ElemsType);
    END; // .FOR
    MsgTitle(StrLib.Join(StrArr, #13#10), Title);
  END; // .FOR
END; // .PROCEDURE ArrDump

BEGIN
  Lng :=  @DlgMesLng.Strs;
  Lang.RegisterClient('DlgMes', Lang.ENG, Lang.IS_ANSI, ORD(HIGH(DlgMesLng.TLangStrings)) + 1, @Lng, Lng);
END.
