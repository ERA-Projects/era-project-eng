unit TextsExt;
{
DESCRIPTION:  Allows to extend heroes 3 *.txt files on the fly
AUTHOR:       Alexander Shostak (aka Berserker aka EtherniDee aka BerSoft)
}

(***)  interface  (***)
uses
  Utils, AssocArrays, TypeWrappers,
  Core, Heroes, GameExt;

type
  (* IMPORT *)
  TString = TypeWrappers.TString;


(***) implementation (***)


var
{O} AddTexts: {O} AssocArrays.TAssocArray {OF TString};
    TxtSize:  integer; {UNSAFE, used in gapped function}


procedure AddLinesToText (const FileName, Lines: string);
var
{U} AddText:  TString;
   
begin
  AddText :=  AddTexts[FileName];
  // * * * * * //
  if AddText = nil then begin
    AddText[FileName] :=  TString.Create(Lines);
  end // .if
  else begin
    AddText.Value :=  AddText.Value + Lines;
  end; // .else
end; // .procedure AddLinesToText

function ExtendText (const TextName: string; var TxtSize: integer): pointer;
var
{U} AddText:  TString;

begin
  AddText :=  AddTexts[FileName];
  result  :=  nil;
  // * * * * * //
  if AddText <> nil then begin
    TxtSize :=  TxtSize + Length(AddText.Value);
    result  :=  Heroes.MAlloc(TxtSize);
    Utils.CopyMem(Length(AddText.Value), pointer(AddText.Value), Utils.PtrOfs(result, TxtSize));
  end // .if
  else begin
    result  :=  Heroes.MAlloc(TxtSize);
  end; // .else
end; // .function ExtendText

function Hook_LoadTextFromFile_BeforeLoad (Context: Core.PHookContext): LONGBOOL; stdcall;
begin
  TxtSize         :=  Context.EDI;
  Context.EAX     :=  ExtendText(Ptr(Context.EBX), TxtSize);
  Context.RetAddr :=  Ptr($55C110);
  result          :=  not Core.EXEC_DEF_CODE;
end; // .function Hook_LoadTextFromFile_BeforeLoad

function Hook_LoadTextFromFile_AfterLoad (Context: Core.PHookContext): LONGBOOL; stdcall;
begin
  TxtSize         :=  Context.EDI;
  Context.EAX     :=  ExtendText(Ptr(Context.EBX), TxtSize);
  Context.RetAddr :=  Ptr($55C110);
  result          :=  not Core.EXEC_DEF_CODE;
end; // .function Hook_LoadTextFromFile_AfterLoad

procedure OnAfterWoG (Event: GameExt.PEvent);
begin
  Core.ApiHook(@Hook_LoadTextFromFile, Core.HOOKTYPE_BRIDGE, Ptr($55C106));
end; // .procedure OnAfterWoG

begin
  AddTexts  :=  AssocArrays.NewStrictAssocArr(TString);
  GameExt.RegisterHandler(OnAfterWoG, 'OnAfterWoG');
end.
