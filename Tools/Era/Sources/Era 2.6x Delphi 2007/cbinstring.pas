unit CBinString;
{
DESCRIPTION:  Working with binary strings
AUTHOR:       Alexander Shostak (aka Berserker aka EtherniDee aka BerSoft)
}

(***)  interface  (***)
uses SysUtils, Utils, StrLib, CLang;

(*
Binary string is an atom in language system. It is either unicode or ansi string.
*)

type
  PBinStringHeader = ^TBinStringHeader;
  TBinStringHeader = record
    StrSize:  integer;
  end; // .record TBinStringHeader
  
  PBinString = ^TBinString;
  TBinString = packed record (* FORMAT *)
    Header:   TBinStringHeader;
    (*
    Chars:    array Header.StrSize of byte;
    *)
    Chars:    Utils.TEmptyRec;
  end; // .record TBinString

  TBinStringReader = class
    (***) protected (***)
                fConnected:             boolean;
      (* Un *)  fBinString:             PBinString;
                fStructMemoryBlockSize: integer;
                fUnicode:               boolean;
      
      function  GetStrSize: integer;
      function  GetStructSize: integer;
    
    (***) public (***)
      procedure Connect (BinString: PBinString; StructMemoryBlockSize: integer; Unicode: boolean);
      procedure Disconnect;
      function  Validate (out Error: string): boolean;
      function  GetAnsiString:  AnsiString;
      function  GetWideString:  WideString;

      constructor Create;
      
      property  Connected:              boolean read fConnected;
      property  BinString:              PBinString read fBinString;
      property  StructMemoryBlockSize:  integer read fStructMemoryBlockSize;
      property  Unicode:                boolean read fUnicode;
      property  StrSize:                integer read GetStrSize;
      property  StructSize:             integer read GetStructSize;
  end; // .class TBinStringReader


(***)  implementation  (***)
  
  
constructor TBinStringReader.Create;
begin
  Self.fConnected :=  FALSE;
end; // .constructor TBinStringReader.Create

procedure TBinStringReader.Connect (BinString: PBinString; StructMemoryBlockSize: integer; Unicode: boolean);
begin
  {!} Assert((BinString <> nil) or (StructMemoryBlockSize = 0));
  {!} Assert(StructMemoryBlockSize >= 0);
  Self.fConnected             :=  TRUE;
  Self.fBinString             :=  BinString;
  Self.fStructMemoryBlockSize :=  StructMemoryBlockSize;
  Self.fUnicode               :=  Unicode;
end; // .procedure TBinStringReader.Connect

procedure TBinStringReader.Disconnect;
begin
  Self.fConnected :=  FALSE;
end; // .procedure TBinStringReader.Disconnect

function TBinStringReader.Validate (out Error: string): boolean;
  function ValidateMinStructSize: boolean;
  begin
    result  :=  Self.StructMemoryBlockSize >= sizeof(TBinString);
    if not result then begin
      Error :=  'The size of structure is too small: ' + SysUtils.IntToStr(Self.StructMemoryBlockSize) + '/' + SysUtils.IntToStr(sizeof(TBinString));
    end; // .if
  end; // .function ValidateMinStructSize

  function ValidateStrSizeField: boolean;
  var
    StrSize:  integer;

  begin
    StrSize :=  Self.StrSize;
    result  :=  (StrSize >= 0) and ((sizeof(TBinString) + StrSize) <= Self.StructMemoryBlockSize);
    if not result then begin
      Error :=  'Invalid StrSize field: ' + SysUtils.IntToStr(StrSize);
    end; // .if
  end; // .function ValidateStrSizeField

begin
  {!} Assert(Self.Connected);
  {!} Assert(Error = '');
  result  :=
    ValidateMinStructSize and
    ValidateStrSizeField;
end; // .function TBinStringReader.Validate

function TBinStringReader.GetStrSize: integer;
begin
  {!} Assert(Self.Connected);
  result  :=  Self.BinString.Header.StrSize;
end; // .function TBinStringReader.GetStrSize

function TBinStringReader.GetStructSize: integer;
begin
  {!} Assert(Self.Connected);
  result  :=  sizeof(TBinString) + Self.StrSize;
end; // .function TBinStringReader.GetStructSize

function TBinStringReader.GetAnsiString: AnsiString;
begin
  {!} Assert(Self.Connected);
  {!} Assert(not Self.Unicode);
  result  :=  StrLib.BytesToAnsiString(@Self.fBinString.Chars, Self.StrSize);
end; // .function TBinStringReader.GetAnsiString

function TBinStringReader.GetWideString: WideString;
begin
  {!} Assert(Self.Connected);
  {!} Assert(Self.Unicode);
  result  :=  StrLib.BytesToWideString(@Self.fBinString.Chars, Self.StrSize);
end; // .function TBinStringReader.GetWideString
  
end.
