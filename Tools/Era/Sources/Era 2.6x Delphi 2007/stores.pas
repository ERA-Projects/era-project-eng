unit Stores;
{
DESCRIPTION:  Provides ability to store safely data in savegames
AUTHOR:       Alexander Shostak (aka Berserker aka EtherniDee aka BerSoft)
}

(***)  interface  (***)
uses
  SysUtils, Math, Utils, Crypto, Files, AssocArrays, DataLib, StrLib, DlgMes,
  Core, GameExt, Heroes, Erm;

const
  DUMP_SAVEGAME_SECTIONS_DIR = GameExt.DEBUG_DIR + '\Savegame Sections';

type
  (* IMPORT *)
  TAssocArray = AssocArrays.TAssocArray;

  // Cached I/O for sections
  IRider = interface
    procedure Write (Size: integer; {n} Addr: PBYTE);
    procedure WriteInt (Value: integer);
    procedure WriteStr (const Str: string);
    function  Read (Size: integer; {n} Addr: PBYTE): integer;
    function  ReadInt: integer;
    function  ReadStr: string;
    procedure Flush;
  end; // .interface IRider


const
  ZvsErmTriggerBeforeSave:  Utils.TProcedure  = Ptr($750093);


procedure WriteSavegameSection (DataSize: integer; {n} Data: pointer; const SectionName: string);
function  ReadSavegameSection  (DataSize: integer; {n} Dest: pointer; const SectionName: string)
                               :integer;
function  NewRider (const SectionName: string): IRider;


var
  DumpSavegameSectionsOpt: boolean;


(***) implementation (***)


type
  TStoredData = class
    Data:       string;
    ReadingPos: integer;
  end; // .class TStoredData
  
  TRider = class (TInterfacedObject, IRider)
   public 
    constructor Create (const aSectionName: string);
    destructor  Destroy; override;

    procedure Write (Size: integer; {n} Addr: PBYTE);
    procedure WriteInt (Value: integer);
    procedure WriteStr (const Str: string);
    function  Read (Size: integer; {n} Addr: PBYTE): integer;
    // if nothing to read, returns 0
    function  ReadInt: integer;
    // if nothing to read, return ''
    function  ReadStr: string;
    procedure Flush;
    
   private
    fSectionName:   string;
    fReadingBuf:    array [0..8149] of byte;
    fWritingBuf:    array [0..8149] of byte;
    fReadingBufPos: integer; // Starts from zero
    fWritingBufPos: integer; // Starts from zero
    fNumBytesRead:  integer;
  end; // .class TRider


var
{O} WritingStorage: {O} TAssocArray {OF Data: StrLib.TStrBuilder};
{O} ReadingStorage: {O} TAssocArray {OF StoredData: TStoredData};
    ZeroBuf:        string;


procedure WriteSavegameSection (DataSize: integer; {n} Data: pointer; const SectionName: string);
var
{U} Section: StrLib.TStrBuilder;
  
begin
  {!} Assert(Utils.IsValidBuf(Data, DataSize));
  Section := nil;
  // * * * * * //
  if DataSize > 0 then begin
    Section := WritingStorage[SectionName];
    
    if Section = nil then begin
      Section                     := StrLib.TStrBuilder.Create;
      WritingStorage[SectionName] := Section;
    end; // .if
    
    Section.AppendBuf(DataSize, Data);

    if DumpSavegameSectionsOpt then begin
      
      Files.AppendFileContents(StrLib.BufToStr(Data, DataSize),
                               DUMP_SAVEGAME_SECTIONS_DIR + '\' + SectionName + '.chunks.txt');
    end; // .if
  end; // .if
end; // .procedure WriteSavegameSection

function ReadSavegameSection (DataSize: integer; {n} Dest: pointer; const SectionName: string)
                              : integer; 
var
{U} Section: TStoredData;
  
begin
  {!} Assert(Utils.IsValidBuf(Dest, DataSize));
  Section := nil;
  // * * * * * //
  result := 0;
  
  if DataSize > 0 then begin
    Section := ReadingStorage[SectionName];
    
    if Section <> nil then begin
      result := Math.Min(DataSize, Length(Section.Data) - Section.ReadingPos);
      Utils.CopyMem(result, pointer(@Section.Data[1 + Section.ReadingPos]), Dest);
      Inc(Section.ReadingPos, result);
    end; // .if
  end; // .if
end; // .function ReadSavegameSection

constructor TRider.Create (const aSectionName: string);
begin
  fSectionName    := aSectionName;
  fReadingBufPos  := 0;
  fWritingBufPos  := 0;
  fNumBytesRead   := 0;
end; // .constructor TRider.Create

destructor TRider.Destroy;
begin
  Flush;
end; // .destructor TRider.Destroy

procedure TRider.Write (Size: integer; {n} Addr: PBYTE);
begin
  {!} Assert(Utils.IsValidBuf(Addr, Size));
  if Size > 0 then begin
    // if no more space in cache - flush the cache
    if sizeof(fWritingBuf) - fWritingBufPos < Size then begin
      Flush;
    end; // .if
    
    // if it's enough space in cache to hold passed data then write data to cache
    if sizeof(fWritingBuf) - fWritingBufPos > Size then begin
      Utils.CopyMem(Size, Addr, @fWritingBuf[fWritingBufPos]);
      Inc(fWritingBufPos, Size);
    end // .if
    // else cache is too small, write directly to section
    else begin
      WriteSavegameSection(Size, Addr, fSectionName);
    end; // .else
  end; // .if
end; // .procedure TRider.Write

procedure TRider.WriteInt (Value: integer);
begin
  Write(sizeof(Value), @Value);
end; // .procedure TRider.WriteInt

procedure TRider.WriteStr (const Str: string);
var
  StrLen: integer;

begin
  StrLen := Length(Str);
  WriteInt(StrLen);
  
  if StrLen > 0 then begin
    Write(StrLen, pointer(Str));
  end; // .if
end; // .procedure TRider.WriteStr

procedure TRider.Flush;
begin
  WriteSaveGameSection(fWritingBufPos, @fWritingBuf[0], fSectionName);
  fWritingBufPos := 0;
end; // .procedure TRider.Flush

function TRider.Read (Size: integer; {n} Addr: PBYTE): integer;
var
  NumBytesToCopy: integer;

begin
  {!} Assert(Utils.IsValidBuf(Addr, Size));
  result := 0;
  
  if Size > 0 then begin
    // if there is some data in cache
    if fNumBytesRead > 0 then begin
      result := Math.Min(Size, fNumBytesRead);
      Utils.CopyMem(result, @fReadingBuf[fReadingBufPos], Addr);
      Dec(Size,           result);
      Dec(fNumBytesRead,  result);
      Inc(Addr,           result);
      Inc(fReadingBufPos, result);
    end; // .if

    // if client expects more data to be read than it's in cache. Cache is empty
    if Size > 0 then begin
      // if requested data chunk is too big, no sense to cache it
      if Size >= sizeof(fReadingBuf) then begin
        Inc(result, ReadSavegameSection(Size, Addr, fSectionName));
      end // .if
      // try to fill cache with New data and pass its portion to the client
      else begin
        fNumBytesRead := ReadSavegameSection(sizeof(fReadingBuf), @fReadingBuf[0], fSectionName);
        
        if fNumBytesRead > 0 then begin
          NumBytesToCopy := Math.Min(Size, fNumBytesRead);
          Utils.CopyMem(NumBytesToCopy, @fReadingBuf[0], Addr);
          fReadingBufPos := NumBytesToCopy;
          Dec(fNumBytesRead, NumBytesToCopy);
          Inc(result, NumBytesToCopy);
        end; // .if
      end; // .else
    end; // .if
  end; // .if
end; // .procedure TRider.Read

function TRider.ReadInt: integer;
var
  NumBytesRead: integer;

begin
  result       := 0;
  NumBytesRead := Read(sizeof(result), @result);
  {!} Assert((NumBytesRead = sizeof(result)) or (NumBytesRead = 0));
end; // .function TRider.ReadInt

function TRider.ReadStr: string;
var
  StrLen:       integer;
  NumBytesRead: integer;

begin
  StrLen := ReadInt;
  {!} Assert(StrLen >= 0);
  SetLength(result, StrLen);
  
  if StrLen > 0 then begin
    NumBytesRead := Read(StrLen, pointer(result));
    {!} Assert(NumBytesRead = StrLen);
  end; // .if
end; // .function TRider.ReadStr

function NewRider (const SectionName: string): IRider;
begin
  result := TRider.Create(SectionName);
end; // .function NewRider

function Hook_SaveGame (Context: Core.PHookContext): LONGBOOL; stdcall;
const
  PARAM_SAVEGAME_NAME = 0;

var
{U} OldSavegameName:  pchar;
{U} SavegameName:     pchar;
    SavegameNameLen:  integer;
  
begin
  OldSavegameName := PPOINTER(Context.EBP + 8)^;
  SavegameName    := nil;
  // * * * * * //
  GameExt.EraSaveEventParams;
  
  GameExt.EraEventParams[PARAM_SAVEGAME_NAME] := integer(OldSavegameName);
  ZvsErmTriggerBeforeSave;
  SavegameName    := Ptr(GameExt.EraEventParams[PARAM_SAVEGAME_NAME]);
  SavegameNameLen := SysUtils.StrLen(SavegameName);
  
  if SavegameName <> OldSavegameName then begin
    Utils.CopyMem(SavegameNameLen + 1, SavegameName, OldSavegameName);
    PINTEGER(Context.EBP + 12)^ := -1;
  end; // .if
  
  GameExt.EraRestoreEventParams;
  
  result := Core.EXEC_DEF_CODE;
end; // .function Hook_SaveGame

function Hook_SaveGameWrite (Context: Core.PHookContext): LONGBOOL; stdcall;
var
{U} StrBuilder:     StrLib.TStrBuilder;
    NumSections:    integer;
    SectionNameLen: integer;
    DataLen:        integer;
    BuiltData:      string;
    TotalWritten:   integer; // Trying to fix game diff algorithm in online games
    PaddingSize:    integer;
    
  procedure GzipWrite (Count: integer; {n} Addr: pointer);
  begin
    Inc(TotalWritten, Count);
    Heroes.GzipWrite(Count, Addr);
  end; // .procedure GzipWrite

begin
  StrBuilder := nil;
  // * * * * * //
  if DumpSavegameSectionsOpt then begin
    Files.DeleteDir(DUMP_SAVEGAME_SECTIONS_DIR);
    SysUtils.CreateDir(DUMP_SAVEGAME_SECTIONS_DIR);
  end; // .if

  WritingStorage.Clear;
  Erm.FireErmEventEx(Erm.TRIGGER_SAVEGAME_WRITE, []);
  GameExt.FireEvent('$OnEraSaveScripts', GameExt.NO_EVENT_DATA, 0);
  
  TotalWritten := 0;
  NumSections  := WritingStorage.ItemCount;
  GzipWrite(sizeof(NumSections), @NumSections);

  with DataLib.IterateDict(WritingStorage) do begin
    while IterNext do begin
      SectionNameLen := Length(IterKey);
      GzipWrite(sizeof(SectionNameLen), @SectionNameLen);
      GzipWrite(SectionNameLen, pointer(IterKey));

      BuiltData := (IterValue AS StrLib.TStrBuilder).BuildStr;
      DataLen   := Length(BuiltData);
      GzipWrite(sizeof(DataLen), @DataLen);
      GzipWrite(Length(BuiltData), pointer(BuiltData));

      if DumpSavegameSectionsOpt then begin
        Files.WriteFileContents(BuiltData, DUMP_SAVEGAME_SECTIONS_DIR
                                           + '\' + IterKey + '.joined.txt');
      end; // .if
    end; // .while
  end; // .with 
  
  // Default code
  if PINTEGER(Context.EBP - 4)^ = 0 then begin
    Context.RetAddr := Ptr($704EF2);
  end // .if
  else begin
    Context.RetAddr := Ptr($704F10);
  end; // .else
  
  result := not Core.EXEC_DEF_CODE;
end; // .function Hook_SaveGameWrite

function Hook_SaveGameRead (Context: Core.PHookContext): LONGBOOL; stdcall;
var
{U} StoredData:     TStoredData;
    BytesRead:      integer;
    NumSections:    integer;
    SectionNameLen: integer;
    SectionName:    string;
    DataLen:        integer;
    SectionData:    string;
    i:              integer;
    
  procedure ForceGzipRead (Count: integer; {n} Addr: pointer);
  begin
    BytesRead := Heroes.GzipRead(Count, Addr);
    {!} Assert(BytesRead = Count);
  end; // .procedure ForceGzipRead

begin
  StoredData := nil;
  // * * * * * //
  ReadingStorage.Clear;
  NumSections := 0;
  BytesRead   := Heroes.GzipRead(sizeof(NumSections), @NumSections);
  {!} Assert((BytesRead = sizeof(NumSections)) or (BytesRead = 0), 'Failed to read NumSections:integer from saved game');
  
  for i:=1 to NumSections do begin
    ForceGzipRead(sizeof(SectionNameLen), @SectionNameLen);
    {!} Assert(SectionNameLen >= 0);
    SetLength(SectionName, SectionNameLen);
    ForceGzipRead(SectionNameLen, pointer(SectionName));

    ForceGzipRead(sizeof(DataLen), @DataLen);
    {!} Assert(DataLen >= 0);
    SetLength(SectionData, DataLen);
    ForceGzipRead(DataLen, pointer(SectionData));
    
    StoredData                  := TStoredData.Create;
    StoredData.Data             := SectionData; SectionData := '';
    StoredData.ReadingPos       := 0;
    ReadingStorage[SectionName] := StoredData;
  end; // .for
  
  GameExt.FireEvent('$OnEraLoadScripts', GameExt.NO_EVENT_DATA, 0);
  Erm.FireErmEventEx(Erm.TRIGGER_SAVEGAME_READ, []);
  
  // default code
  if PINTEGER(Context.EBP - $14)^ = 0 then begin
    Context.RetAddr := Ptr($7051BE);
  end // .if
  else begin
    Context.RetAddr := Ptr($7051DC);
  end; // .else
  
  result := not Core.EXEC_DEF_CODE;
end; // .function Hook_SaveGameRead

procedure OnAfterWoG (Event: GameExt.PEvent); stdcall;
begin
  Core.Hook(@Hook_SaveGame, Core.HOOKTYPE_BRIDGE, 5, Ptr($4BEB65));
  Core.Hook(@Hook_SaveGameWrite, Core.HOOKTYPE_BRIDGE, 6, Ptr($704EEC));
  Core.Hook(@Hook_SaveGameRead, Core.HOOKTYPE_BRIDGE, 6, Ptr($7051B8));
  
  (* Remove Erm trigger "BeforeSaveGame" call *)
  Core.p.WriteDataPatch(Ptr($7051F5), ['9090909090']);
end; // .procedure OnAfterWoG

begin
  WritingStorage := AssocArrays.NewStrictAssocArr(StrLib.TStrBuilder);
  ReadingStorage := AssocArrays.NewStrictAssocArr(TStoredData);
  GameExt.RegisterHandler(OnAfterWoG, 'OnAfterWoG');
end.
