unit Textman;
{
DESCRIPTION:  Text manager provides high-level functions-wrappers over AText
AUTHOR:       Alexander Shostak (aka Berserker aka EtherniDee aka BerSoft)
}

(***)  interface  (***)
uses Windows, SysUtils, Utils, Crypto, StrLib, CFiles, Files, ATexts;

const
  (* FindStr *)
  IGNORE_CASE = TRUE;


type
  TCharPreprocessFunc = function (c: char): char;


function  FindStr (Str: string; IgnoreCase: boolean; Text: ATexts.AText): boolean;
procedure ReplaceStr (Str: string; ReplWith: string; IgnoreCase: boolean; Text: ATexts.AText);
function  LoadFromFile (const FilePath: string; {n} Settings: Utils.TCloneable; Text: ATexts.AText): boolean;
function  SaveToFile (const FilePath: string; Text: ATexts.AText): boolean;


(***) implementation (***)


function FindStr (Str: string; IgnoreCase: boolean; Text: ATexts.AText): boolean;
var
  StrLen:     integer;
  StrHash:    integer;
  MatchHash:  integer;
  HashInd:    integer;
  StartPos:   integer;
  c:          char;
  i:          integer;
  
  function IsMatch: boolean;
  begin
    Text.GotoPos(StartPos);
    result  :=  TRUE;
    i       :=  1;
    while result and (i <= StrLen) do begin
      Text.GetCurrChar(c);
      if IgnoreCase then begin
        c :=  StrLib.CharToLower(c);
      end; // .if
      result  :=  c = Str[i];
      Text.GotoNextPos;
      Inc(i);
    end; // .while
  end; // .function IsMatch
  
begin
  {!} Assert(Text <> nil);
  StrLen  :=  Length(Str);
  result  :=  FALSE;
  if (Text.Len - Text.Pos + 1) >= StrLen then begin
    if IgnoreCase then begin
      Str :=  SysUtils.AnsiLowerCase(Str);
    end; // .if
    StartPos  :=  Text.Pos;
    StrHash   :=  0;
    HashInd   :=  0;
    for i:=1 to StrLen do begin
      c :=  Str[i];
      if IgnoreCase then begin
        c :=  StrLib.CharToLower(c);
      end; // .if
      Inc(Crypto.TInt32(StrHash)[HashInd], Crypto.ByteRedirTable[ORD(c)]);
      HashInd :=  (HashInd + 1) and 3;
    end; // .for
    MatchHash :=  0;
    HashInd   :=  0;
    for i:=1 to StrLen do begin
      Text.GetCurrChar(c);
      if IgnoreCase then begin
        c :=  StrLib.CharToLower(c);
      end; // .if
      Inc(Crypto.TInt32(MatchHash)[HashInd], Crypto.ByteRedirTable[ORD(c)]);
      HashInd :=  (HashInd + 1) and 3;
      Text.GotoNextPos;
    end; // .for
    result  :=  (MatchHash = StrHash) and IsMatch;
    HashInd :=  (StrLen - 1) and 3;
    while (not result) and (not Text.TextEnd) do begin
      Text.GotoPos(StartPos);
      Text.GetCurrChar(c);
      if IgnoreCase then begin
        c :=  StrLib.CharToLower(c);
      end; // .if
      Dec(Crypto.TInt32(MatchHash)[0], Crypto.ByteRedirTable[ORD(c)]);
      MatchHash :=  ((MatchHash and $FF) shl 24) or (MatchHash shr 8);
      Text.GotoPos(StartPos + StrLen);
      Text.GetCurrChar(c);
      if IgnoreCase then begin
        c :=  StrLib.CharToLower(c);
      end; // .if
      Inc(Crypto.TInt32(MatchHash)[HashInd], Crypto.ByteRedirTable[ORD(c)]);
      Inc(StartPos);
      result  :=  (MatchHash = StrHash) and IsMatch;
      Text.GotoNextPos;
    end; // .while
    if result then begin
      Text.GotoPos(StartPos);
    end; // .if
  end; // .if
end; // .function FindStr

procedure ReplaceStr (Str: string; ReplWith: string; IgnoreCase: boolean; Text: ATexts.AText);
begin
  {!} Assert(Text <> nil);
  while FindStr(Str, IgnoreCase, Text) do begin
    Text.Replace(Length(Str), ReplWith);
  end; // .while
end; // .procedure ReplaceStr

function LoadFromFile (const FilePath: string; {n} Settings: Utils.TCloneable; Text: ATexts.AText): boolean;
var
{O} DataFile:     Files.TFile;
    FileContents: string;

begin
  {!} Assert(Text <> nil);
  DataFile  :=  Files.TFile.Create;
  // * * * * * //
  result  :=  DataFile.Open(FilePath, CFiles.MODE_READ) and DataFile.ReadAllToStr(FileContents);
  if result then begin
    Text.Connect(FileContents, TObject(Settings));
  end; // .if
  SysUtils.FreeAndNil(DataFile);
end; // .function LoadFromFile

function SaveToFile (const FilePath: string; Text: ATexts.AText): boolean;
var
{O} DataFile: Files.TFile;
    SavedPos: integer;

begin
  {!} Assert(Text <> nil);
  DataFile  :=  Files.TFile.Create;
  // * * * * * //
  SavedPos  :=  Text.Pos;
  Text.GotoPos(1);
  Windows.DeleteFile(pchar(FilePath));
  result  :=  DataFile.CreateNew(FilePath) and DataFile.WriteStr(Text.GetStr(Text.Len));
  Text.GotoPos(SavedPos);
  SysUtils.FreeAndNil(DataFile);
end; // .function SaveToFile

end.
