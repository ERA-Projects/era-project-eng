unit DlgMes;
{
DESCRIPTION:  Simple dialogs for messages and debugging
AUTHOR:       Alexander Shostak (aka Berserker aka EtherniDee aka BerSoft)
}

(***)  interface  (***)
uses Windows, SysUtils, Math, Utils, StrLib, Lang, DlgMesLng;

const
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


var
  hParentWindow:  integer = NO_WINDOW;
  DialogsTitle:   string;


procedure MsgEx (const Mes, Title: string; Icon: integer);
procedure MsgTitle (const Mes, Title: string);
procedure Msg (const Mes: string);
procedure MsgError(const Err: string);
procedure OK;
function  AskYesNo (const Question: string): boolean;
function  AskYesNoCancel (const Question: string): integer;
function  AskOkCancel (const Question: string): boolean;
function  VarToString (const VarRec: TVarRec): string;
function  ToString (const Vars: array of const): string;
function  PArrItemToString (var PArrItem: pointer; VarType: integer): string;
function  PVarToString (PVar: pointer; VarType: integer): string;
procedure VarDump (const Vars: array of const; const Title: string);
procedure ArrDump
(
  const Arr:        pointer;
        Count:      integer;
  const ElemsType:  integer;
  const Title:      string
);


(***)  implementation  (***)


var
{OU}  Lng:  DlgMesLng.PLangStringsArr;


procedure MsgEx (const Mes, Title: string; Icon: integer);
begin
  Windows.MessageBox(hParentWindow, pchar(Mes), pchar(Title), Icon);
end; // .procedure MsgEx

procedure MsgTitle (const Mes, Title: string);
begin
  MsgEx(Mes, Title, NO_ICON);
end; // .procedure MsgTitle

procedure Msg (const Mes: string);
begin
  MsgEx(Mes, DialogsTitle, NO_ICON);
end; // .procedure Msg

procedure MsgError(const Err: string);
begin
  MsgEx(Err, DialogsTitle, ICON_ERROR);
end; // .procedure MsgError

procedure OK;
begin
  Msg('OK');
end; // .procedure OK

function AskYesNo (const Question: string): boolean;
begin
  result  :=  NO;
  
  if
    Windows.MessageBox
    (
      hParentWindow,
      pchar(Question),
      pchar(Lng[STR_QUESTION]),
      Windows.MB_YESNO + ICON_QUESTION
    ) = Windows.ID_YES
  then begin
    result  :=  YES;
  end; // .if
end; // .function AskYesNo

function AskOkCancel (const Question: string): boolean;
begin
  result  :=  NO;
  
  if Windows.MessageBox
  (
    hParentWindow,
    pchar(Question),
    pchar(Lng[STR_QUESTION]),
    Windows.MB_OKCANCEL + ICON_QUESTION
  ) = Windows.ID_OK
  then begin
    result  :=  YES;
  end; // .if
end; // .function AskOkCancel

function AskYesNoCancel (const Question: string): integer;
begin
  result  :=  0;
  
  case
    Windows.MessageBox
    (
      hParentWindow,
      pchar(Question),
      pchar(Lng[STR_QUESTION]),
      Windows.MB_YESNOCANCEL + ICON_QUESTION
    )
  of 
    Windows.IDYES:      result  :=  ID_YES;
    Windows.IDNO:       result  :=  ID_NO;
    Windows.ID_CANCEL:  result  :=  ID_CANCEL;
  end; // .SWITCH
end; // .function AskYesNoCancel

function VarToString (const VarRec: TVarRec): string;
begin
  case VarRec.vType of
    vtBoolean:
      begin
        if VarRec.vBoolean then begin
          result  :=  'boolean: TRUE';
        end // .if
        else begin
          result  :=  'boolean: FALSE';
        end; // .else
      end; // .case vtBoolean
    vtInteger:    result  :=  'integer: ' + SysUtils.IntToStr(VarRec.vInteger);
    vtChar:       result  :=  'char: ' + VarRec.vChar;
    vtWideChar:   result  :=  'WIDECHAR: ' + VarRec.vWideChar;
    vtExtended:   result  :=  'REAL: ' + SysUtils.FloatToStr(VarRec.vExtended^);
    vtString:     result  :=  'string: ' + VarRec.vString^;
    vtPointer:    result  :=  'pointer: $' + SysUtils.Format('%x',[integer(VarRec.vPointer)]);
    vtPChar:      result  :=  'pchar: ' + VarRec.vPChar;
    vtPWideChar:  result  :=  'PWIDECHAR: ' + VarRec.vPWideChar;
    vtObject:     result  :=  'object: ' + VarRec.vObject.ClassName;
    vtClass:      result  :=  'class: ' + VarRec.vClass.ClassName;
    vtCurrency:   result  :=  'currency: ' + SysUtils.CurrToStr(VarRec.vCurrency^);
    vtAnsiString: result  :=  'ANSISTRING: ' + string(VarRec.vAnsiString);
    vtWideString: result  :=  'WIDESTRING: ' + WideString(VarRec.vWideString);
    vtVariant:    result  :=  'VARIANT: ' + string(VarRec.vVariant);
    vtInterface:  result  :=  'interface: $' + SysUtils.Format('%x',[integer(VarRec.vInterface)]);
    vtInt64:      result  :=  'INT64: ' + SysUtils.IntToStr(VarRec.vInt64^);
  else
    result  :=  'UNKNOWN:';
  end; // .SWITCH VarRec.vType
end; // .function VarToString

function ToString (const Vars: array of const): string;
var
  ResArr: Utils.TArrayOfStr;
  i:      integer;

begin
  SetLength(ResArr, Length(Vars));
  
  for i := 0 to High(Vars) do begin
    ResArr[i] :=  VarToString(Vars[i]);
  end; // .for
  
  result  :=  StrLib.Join(ResArr, #13#10);
end; // .function ToString

function PArrItemToString (var PArrItem: pointer; VarType: integer): string;
var
  VarRec: TVarRec;

begin
  {!} Assert(Math.InRange(VarType, 0, vtInt64));
  VarRec.vType  :=  VarType;
  
  case VarType of
    vtBoolean:    begin VarRec.vBoolean     :=  PBOOLEAN(PArrItem)^; Inc(PBOOLEAN(PArrItem)); end;
    vtInteger:    begin VarRec.vInteger     :=  PINTEGER(PArrItem)^; Inc(PINTEGER(PArrItem)); end;
    vtChar:       begin VarRec.vChar        :=  pchar(PArrItem)^; Inc(pchar(PArrItem)); end;
    vtWideChar:   begin VarRec.vWideChar    :=  PWideChar(PArrItem)^; Inc(PWideChar(PArrItem)); end;
    vtExtended:   begin VarRec.vExtended    :=  PArrItem; Inc(PEXTENDED(PArrItem)); end;
    vtString:     begin VarRec.vString      :=  PArrItem; Inc(PShortString(PArrItem)); end;
    vtPointer:    begin VarRec.vPointer     :=  PPOINTER(PArrItem)^; Inc(PPOINTER(PArrItem)); end;
    vtPChar:      begin VarRec.vPChar       :=  PPCHAR(PArrItem)^; Inc(PPCHAR(PArrItem)); end;
    vtPWideChar:
      begin
                        VarRec.vPWideChar   :=  PPWideChar(PArrItem)^; Inc(PPWideChar(PArrItem));
      end;
    vtObject:     begin VarRec.vObject      :=  pobject(PArrItem)^; Inc(pobject(PArrItem)); end;
    vtClass:      begin VarRec.vClass       :=  pclass(PArrItem)^; Inc(pclass(PArrItem)); end;
    vtCurrency:   begin VarRec.vCurrency    :=  PArrItem; Inc(PCURRENCY(PArrItem)); end;
    vtAnsiString: begin VarRec.vAnsiString  :=  PPOINTER(PArrItem)^; Inc(PPOINTER(PArrItem)); end;
    vtWideString: begin VarRec.vWideString  :=  PPOINTER(PArrItem)^; Inc(PPOINTER(PArrItem)); end;
    vtVariant:    begin VarRec.vVariant     :=  PArrItem; Inc(PVARIANT(PArrItem)); end;
    vtInterface:  begin VarRec.vInterface   :=  PPOINTER(PArrItem)^; Inc(PPOINTER(PArrItem)); end;
    vtInt64:      begin VarRec.vInt64       :=  PArrItem; Inc(PINT64(PArrItem)); end;
  end; // .case PArrItem.vType
  result  :=  VarToString(VarRec);
end; // .function PArrItemToString

function PVarToString (PVar: pointer; VarType: integer): string;
var
{U} Temp: pointer;

begin
  {!} Assert(Math.InRange(VarType, 0, vtInt64));
  Temp  :=  PVar;
  // * * * * * //
  result  :=  PArrItemToString(Temp, VarType);
end; // .function PVarToString

procedure VarDump (const Vars: array of const; const Title: string);
begin
  MsgTitle(ToString(Vars), Title);
end; // .procedure VarDump

procedure ArrDump
(
  const Arr:        pointer;
        Count:      integer;
  const ElemsType:  integer;
  const Title:      string
);

const
  NUM_ITEMS_PER_DISPLAY = 20;

var
{U} CurrItem:           pointer;
    CurrItemInd:        integer;
    StrArr:             Utils.TArrayOfStr; 
    DisplayN:           integer;
    NumItemsToDisplay:  integer;
    i:                  integer;
  
begin
  CurrItemInd :=  0;
  CurrItem    :=  Arr;
  
  for DisplayN := 1 to Math.Ceil(Count / NUM_ITEMS_PER_DISPLAY) do begin
    NumItemsToDisplay :=  Math.Min(Count - CurrItemInd, NUM_ITEMS_PER_DISPLAY);
    SetLength(StrArr, NumItemsToDisplay);
    
    for i := 0 to NumItemsToDisplay - 1 do begin
      StrArr[i] :=  '[' + SysUtils.IntToStr(i) + ']: ' + PArrItemToString(CurrItem, ElemsType);
    end; // .for
    
    MsgTitle(StrLib.Join(StrArr, #13#10), Title);
  end; // .for
end; // .procedure ArrDump

begin
  Lng :=  @DlgMesLng.Strs;
  Lang.RegisterClient
  (
    'DlgMes',
    Lang.ENG,
    Lang.IS_ANSI,
    ORD(High(DlgMesLng.TLangStrings)) + 1,
    @Lng,
    Lng
  );
end.
