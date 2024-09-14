unit Trans;
{
DESCRIPTION:  Game localization support.
AUTHOR:       Alexander Shostak (aka Berserker aka EtherniDee aka BerSoft)
}

(***)  interface  (***)
uses
  Windows, SysUtils, Utils, DataLib, TypeWrappers,
  Files, StrLib, Json, Core, GameExt;


type
  TDict   = DataLib.TDict;
  TString = TypeWrappers.TString;


const
  LANG_DIR   = 'Lang';
  TEMPL_CHAR = '@';


var
  {O} LangMap: TDict {O} {OF TString};


function  tr (const Key: string; const Params: array of string): string;
procedure ClearLangData;
procedure LoadLangFiles;
procedure ReloadLangFiles;
procedure LoadLangFile (const FilePath: string);


(***) implementation (***)


function tr (const Key: string; const Params: array of string): string;
var
{Un} Translation: TString;

begin
  Translation := LangMap[Key];
  // * * * * * //
  if Translation <> nil then begin
    result := StrLib.BuildStr(Translation.Value, Params, TEMPL_CHAR);
  end else begin
    result := Key;
  end;
end; // .function tr

procedure ClearLangData;
begin
  LangMap.Clear();
end;

procedure LoadLangFiles;
begin
  with Files.Locate(LANG_DIR + '\*.json', Files.ONLY_FILES) do begin
    while FindNext do begin
      LoadLangFile(LANG_DIR + '\' + FoundName);
    end;
  end;
end;

procedure ReloadLangFiles;
begin
  ClearLangData;
  LoadLangFiles;
end;

procedure LoadLangFile (const FilePath: string);
var
{O} LangData:         TlkJsonObject;
    LangFileContents: string;
    Key:              string;
    i:                integer;

begin
  LangData := nil;
  // * * * * * //
  if Files.ReadFileContents(FilePath, LangFileContents) then begin
    Utils.CastOrFree(TlkJson.ParseText(LangFileContents), TlkJsonObject, LangData);
    
    if LangData <> nil then begin
      for i := 0 to LangData.Count - 1 do begin
        Key := LangData.NameOf[i];

        if LangMap[Key] = nil then begin
          LangMap[Key] := TString.Create(LangData.GetString(i));
        end;
      end;
    end else begin
      Core.NotifyError('Invalid language json file: "' + FilePath + '"');
    end; // .else
  end; // .if
  // * * * * * //
  FreeAndNil(LangData);
end; // .procedure LoadLangFile

procedure OnReloadLangData (Event: GameExt.PEvent); stdcall;
begin
  ReloadLangFiles;
end;


begin
  LangMap := DataLib.NewDict(Utils.OWNS_ITEMS, DataLib.CASE_SENSITIVE);
  GameExt.RegisterHandler(OnReloadLangData, 'OnAfterWoG');
  GameExt.RegisterHandler(OnReloadLangData, 'OnBeforeScriptsReload');
end.
