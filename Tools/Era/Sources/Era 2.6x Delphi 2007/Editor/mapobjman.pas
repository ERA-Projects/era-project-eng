unit MapObjMan;

(***)  interface  (***)

uses
  SysUtils, Utils, StrLib,
  Lists, Core, Files, DlgMes;

const
  ZEOBJTS_DIR = 'Data\Objects';

type
  TObjItem = class
    Pos:   integer;
    Value: string;
  end;

var
  {O} ZEObjList: Lists.TStringList;


function  LoadZeobjt (var FileInfo: SysUtils.TSearchRec): boolean;
function  LoadObjList (const FileName, RawFileData: string; out ObjList: Lists.TStringList): boolean;
function  ObjListToStr (var {in} ObjList: Lists.TStringList): string;


(***)  implementation  (***)


const
  LINE_END = #13#10;


function LoadObjList (const FileName, RawFileData: string; out ObjList: Lists.TStringList): boolean;
var
{U} ObjItem:      TObjItem;
    StrItems:     StrLib.TArrayOfStr;
    StrItem:      StrLib.TArrayOfStr;
    NumStrItems:  integer;
    i:            integer;

begin
  {!} Assert(ObjList = nil);
  ObjItem :=  nil;
  // * * * * * //
  StrItems    := StrLib.Explode(RawFileData, LINE_END);
  NumStrItems := Length(StrItems) - 2;
  result      := (NumStrItems > 0) and (StrItems[Length(StrItems) - 1] = '');
  
  if result then begin
    ObjList := Lists.NewStrictStrList(TObjItem);
    i       := 1;
    
    while result and (i <= NumStrItems) do begin
      StrItem := StrLib.ExplodeEx(StrItems[i], ' ', not StrLib.INCLUDE_DELIM,
                                  StrLib.LIMIT_TOKENS, 2);
      result  := (Length(StrItem) = 2) and (Length(StrLib.Explode(StrItems[i], ' ')) >= 9);
      
      if result then begin
        ObjItem       := TObjItem.Create;
        ObjItem.Pos   := i - 1;
        ObjItem.Value := StrItem[1];
        ObjList.AddObj(SysUtils.AnsiLowerCase(StrItem[0]), ObjItem);
      end else begin
        Core.NotifyError(Format('LoadObjList: Error in file "%s".'#13#10'Line should have at least 9 elements: "%s"', [FileName, StrItems[i]]));
      end;

      Inc(i);
    end; // .while
    
    (* FIXME: The order of objects is lost, because binary search is necessary for further work *)
    ObjList.Sorted := true;
  end else begin
    Core.NotifyError('LoadObjList: File "' + FileName + '" has zero items or does not have terminating end of line');
  end; // .else
  
  if not result then begin
    SysUtils.FreeAndNil(ObjList);
  end; // .if
end; // .function LoadObjList

function ObjListToStr (var {in} ObjList: Lists.TStringList): string;
var
{U} ObjItem:  TObjItem;
    NumItems: integer;
    i:        integer;

begin
  {!} Assert(ObjList <> nil);
  ObjItem := nil;
  // * * * * * //
  with StrLib.MakeStr do begin
    NumItems       := ObjList.Count;
    ObjList.Sorted := false;
    Append(IntToStr(NumItems));
    Append(LINE_END);
    i := 0;
    
    while i < NumItems do begin
      ObjItem := ObjList.Values[i];
      
      if ObjItem.Pos <> i then begin
        ObjList.Exchange(i, ObjItem.Pos);
      end else begin
        Inc(i);
      end;
    end; // .while

    for i := 0 to NumItems - 1 do begin
      ObjItem := ObjList.Values[i];
      Append(ObjList.Keys[i]);
      Append(' ');
      Append(ObjItem.Value);
      Append(LINE_END);
    end; // .for

    result := BuildStr();
  end; // .with
  // * * * * * //
  SysUtils.FreeAndNil(ObjList);
end; // .function ObjListToStr

function MergeObjLists (ParentObjList: Lists.TStringList; ChildObjList: Lists.TStringList; SafeMode: boolean): boolean;
const
  CATEGORY_ID = 6;

var
{U} ObjItem:          TObjItem;
    OldAssertHandler: TAssertErrorProc;
    ExplodedSrc:      StrLib.TArrayOfStr;
    ExplodedDst:      StrLib.TArrayOfStr;
    ItemInd:          integer;
    ContinueLoop:     boolean;
    i:                integer;
  
begin
  {!} Assert(ParentObjList <> nil);
  {!} Assert(ChildObjList <> nil);
  ParentObjList.Sorted   := true;
  ChildObjList.Sorted    := true;
  OldAssertHandler       := System.AssertErrorProc;
  System.AssertErrorProc := nil;
  
  try
    ChildObjList.ForbidDuplicates := true;
    result                        := true;
  except
    result := false;
  end;
  
  System.AssertErrorProc := OldAssertHandler;
  
  if result then begin
    i := 0;

    while result and (i < ChildObjList.Count) do begin
      ObjItem := ChildObjList.Values[i];
      
      if ParentObjList.Find(ChildObjList.Keys[i], ItemInd) then begin
        if not SafeMode then begin
          ContinueLoop := true;
          
          while result and ContinueLoop do begin
            ExplodedDst              := StrLib.Explode(TObjItem(ParentObjList.Values[ItemInd]).Value, ' ');
            ExplodedSrc              := StrLib.Explode(ObjItem.Value, ' ');
            ExplodedSrc[CATEGORY_ID] := ExplodedDst[CATEGORY_ID];
            TObjItem(ParentObjList.Values[ItemInd]).Value := StrLib.Join(ExplodedSrc, ' ');
            Dec(ItemInd);
            ContinueLoop := (ItemInd >= 0) and (ParentObjList.Keys[ItemInd] = ChildObjList.Keys[i]);
          end; // .while
        end; // .if
      end // .if
      else begin
        ObjItem.Pos := ParentObjList.Count;
        ParentObjList.AddObj(ChildObjList.Keys[i], ObjItem); ChildObjList.TakeValue(i);
      end; // .else
      
      Inc(i);
    end; // .while
  end; // .if
end; // .function MergeObjLists

function LoadZeobjt (var FileInfo: SysUtils.TSearchRec): boolean;
var
{O} ChildObjList: Lists.TStringList;
    FileName:     string;
    FileContents: string;
   
begin
  ChildObjList  :=  nil;
  // * * * * * //
  FileName := FileInfo.Name;
  
  if
    (FileInfo.Size > 0) and
    Files.ReadFileContents(ZEOBJTS_DIR + '\' + FileName, FileContents)
  then begin
    if
      not LoadObjList(FileName, FileContents, ChildObjList) or
      not MergeObjLists(ZEObjList, ChildObjList, false)
    then begin     
      DlgMes.MsgError
      (
        'Editor objects file contains duplicates or has invalid format: "'
        + ZEOBJTS_DIR + '\' + FileName + '"'
      );
    end; // .if
    
    SysUtils.FreeAndNil(ChildObjList);
  end; // .if
  
  result  :=  true;
end; // .function LoadZeobjt

begin
  ZEObjList := Lists.NewStrictStrList(TObjItem);
end.