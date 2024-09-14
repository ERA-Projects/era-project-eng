unit FilesEx;
{
DESCRIPTION:  High-level finctions for working with files
AUTHOR:       Alexander Shostak (aka Berserker aka EtherniDee aka BerSoft)
}

(***)  interface  (***)
uses SysUtils, Utils, Files, DataLib, StrLib;

type
  (* IMPORT *)
  TStrList    = DataLib.TStrList;
  TDict       = DataLib.TDict;
  TSearchSubj = Files.TSearchSubj;

  (*
  Provides means for formatted output to external storage.
  It's recommended to internally use StrBuilder for file output.
  Default indentation must be '  ', line end marker - #13#10.
  *)
  IFormattedOutput = interface
    procedure SetIndentation (const Identation: string);
    procedure SetLineEndMarker (const aLineEndMarker: string);

    // Increase or decrease indentation
    procedure Indent;
    procedure Unindent;
    procedure SetIndentLevel (Level: integer);
    
    procedure Write (const Str: string);
    // Same as Write + Write([line end marker])
    procedure WriteIndentation;
    procedure RawLine (const Str: string);
    // Same as Write([indentation]) * [indent level] + RawLine(Str)
    procedure Line (const Str: string);
    // Same as Write([line end marker])
    procedure EmptyLine;

    property Indentation:   string write SetIndentation;
    property LineEndMarker: string write SetLineEndMarker;
  end; // .interface IFormattedOutput

  TFileFormattedOutput = class (TInterfacedObject, IFormattedOutput)
   protected
    {O} fOutputBuf:     StrLib.TStrBuilder;
        fFilePath:      string;
        fIndentation:   string;
        fIndentLevel:   integer;
        fLineEndMarker: string;

   public
    constructor Create (const aFilePath: string);
    destructor Destroy; override;

    procedure SetIndentation (const aIndentation: string);
    procedure SetLineEndMarker (const aLineEndMarker: string);
    procedure Indent;
    procedure Unindent;
    procedure SetIndentLevel (Level: integer);
    procedure WriteIndentation;
    procedure Write (const Str: string);
    procedure RawLine (const Str: string);
    procedure Line (const Str: string);
    procedure EmptyLine;
  end; // .class TFileFormattedOutput
  

// List does not own its objects. It simply contains case insensitive file names
function  GetFileList (const MaskedPath: string; SearchSubj: TSearchSubj): {O} TStrList;
procedure MergeFileLists (MainList, DependantList: TStrList);
function  WriteFormattedOutput (const FilePath: string): IFormattedOutput;


(***) implementation (***)


constructor TFileFormattedOutput.Create (const aFilePath: string);
begin
  fFilePath      := aFilePath;
  fOutputBuf     := StrLib.TStrBuilder.Create;
  fIndentation   := '  ';
  fIndentLevel   := 0;
  fLineEndMarker := #13#10;
end; // .constructor TFileFormattedOutput.Create

destructor TFileFormattedOutput.Destroy;
begin
  Files.WriteFileContents(fOutputBuf.BuildStr, fFilePath);
  FreeAndNil(fOutputBuf);
end; // .destructor TFileFormattedOutput.Destroy

procedure TFileFormattedOutput.SetIndentation (const aIndentation: string);
begin
  fIndentation := aIndentation;
end; // .procedure TFileFormattedOutput.SetIndentation

procedure TFileFormattedOutput.SetLineEndMarker (const aLineEndMarker: string);
begin
  fLineEndMarker := aLineEndMarker;
end; // .procedure TFileFormattedOutput.SetLineEndMarker

procedure TFileFormattedOutput.Indent;
begin
  Inc(fIndentLevel);
end; // .procedure TFileFormattedOutput.Indent

procedure TFileFormattedOutput.Unindent;
begin
  if fIndentLevel > 0 then begin
    Dec(fIndentLevel);
  end; // .if
end; // .procedure TFileFormattedOutput.Unindent

procedure TFileFormattedOutput.SetIndentLevel (Level: integer);
begin
  if Level <= 0 then begin
    fIndentLevel := 0;
  end else begin
    fIndentLevel := Level;
  end;
end;

procedure TFileFormattedOutput.WriteIndentation;
var
  i: integer;

begin
  for i := 1 to fIndentLevel do begin
    fOutputBuf.Append(fIndentation);
  end;
end;

procedure TFileFormattedOutput.Write (const Str: string);
begin
  fOutputBuf.Append(Str);
end; // .procedure TFileFormattedOutput.Write

procedure TFileFormattedOutput.RawLine (const Str: string);
begin
  fOutputBuf.Append(Str);
  fOutputBuf.Append(fLineEndMarker);
end; // .procedure TFileFormattedOutput.RawLine

procedure TFileFormattedOutput.Line (const Str: string);
var
  i: integer;

begin
  for i := 1 to fIndentLevel do begin
    fOutputBuf.Append(fIndentation);
  end;

  fOutputBuf.Append(Str);
  fOutputBuf.Append(fLineEndMarker);
end; // .procedure TFileFormattedOutput.Line

procedure TFileFormattedOutput.EmptyLine;
begin
  fOutputBuf.Append(fLineEndMarker);
end; // .procedure TFileFormattedOutput.EmptyLine

function GetFileList (const MaskedPath: string; SearchSubj: TSearchSubj): {O} TStrList;
begin
  result := DataLib.NewStrList(not Utils.OWNS_ITEMS, DataLib.CASE_INSENSITIVE);
  
  with Files.Locate(MaskedPath, SearchSubj) do begin
    while FindNext do begin
      result.Add(FoundName);
    end; // .while
  end; // .with 
end; // .procedure GetFileList

procedure MergeFileLists (MainList, DependantList: TStrList);
var
{O} NamesDict: TDict {OF FileName: STRING => Ptr(1)};
    i: integer;
   
begin
  {!} Assert(MainList <> nil);
  {!} Assert(DependantList <> nil);
  NamesDict := DataLib.NewDict(not Utils.OWNS_ITEMS, DataLib.CASE_INSENSITIVE);
  // * * * * * //
  for i := 0 to MainList.Count - 1 do begin
    NamesDict[MainList[i]] := Ptr(1);
  end; // .for
  
  for i := 0 to DependantList.Count - 1 do begin
    if NamesDict[DependantList[i]] = nil then begin
      NamesDict[DependantList[i]] := Ptr(1);
      MainList.Add(DependantList[i]);
    end; // .if
  end; // .for
  // * * * * * //
  SysUtils.FreeAndNil(NamesDict);
end; // .procedure MergeFileLists

function WriteFormattedOutput (const FilePath: string): IFormattedOutput;
var
{O} FormattedOutputObj: TFileFormattedOutput;

begin
  FormattedOutputObj := TFileFormattedOutput.Create(FilePath);
  // * * * * * //
  result := FormattedOutputObj; FormattedOutputObj := nil;
end; // .function WriteFormattedOutput

end.
