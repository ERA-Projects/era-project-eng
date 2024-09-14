unit Lodman;

(***)  interface  (***)

uses
  SysUtils, Math,
  Utils, Core, Lists, AssocArrays, DataLib, Files, Json, DlgMes,
  MapExt, MapObjMan, Editor;

const
  MAX_NUM_LODS   = 100;
  NUM_OBLIG_LODS = 8;

  GLOBAL_REDIRECTIONS_CONFIG_DIR         = 'Data\Redirections';
  GLOBAL_MISSING_REDIRECTIONS_CONFIG_DIR = GLOBAL_REDIRECTIONS_CONFIG_DIR + '\Missing';
  REDIRECT_ONLY_MISSING                  = true;
  REDIRECT_MISSING_AND_EXISTING          = NOT REDIRECT_ONLY_MISSING;

  MUSIC_DIR = 'Mp3';

type
  PLod  = ^TLod;
  TLod  = packed record
    Dummy:  array [0..399] of byte;
  end;
  
  PLodTable = ^TLodTable;
  TLodTable = array [0..99] of TLod;
  
  TGameVersion  = 0..3;
  TLodType      = (LOD_SPRITE = 1, LOD_BITMAP = 2, LOD_WAV = 3);
  
  PIndexes  = ^TIndexes;
  TIndexes  = array [0..MAX_NUM_LODS - 1] of integer;
  
  TLodIndexes = packed record
    NumLods:  integer;
    Indexes:  ^TIndexes;
  end;
  
  TLodTypes = packed record
    Table:    array [LOD_SPRITE..LOD_WAV, TGameVersion] of TLodIndexes;
    Indexes:  array [LOD_SPRITE..LOD_WAV, TGameVersion] of TIndexes;
  end;

var
{O} LodList:         Lists.TStringList;
{O} GlobalLodRedirs: {O} AssocArrays.TAssocArray {OF TString};
    NumLods:         integer;
    LodTable:        TLodTable;
    LodTypes:        TLodTypes;

implementation

procedure RegisterDefaultLodTypes;
begin
  (* LOD_SPRITE *)
  LodTypes.Table[LOD_SPRITE, 0].NumLods :=  2;
  LodTypes.Table[LOD_SPRITE, 0].Indexes :=  @LodTypes.Indexes[LOD_SPRITE, 0];
  LodTypes.Table[LOD_SPRITE, 1].NumLods :=  2;
  LodTypes.Table[LOD_SPRITE, 1].Indexes :=  @LodTypes.Indexes[LOD_SPRITE, 1];
  LodTypes.Table[LOD_SPRITE, 2].NumLods :=  2;
  LodTypes.Table[LOD_SPRITE, 2].Indexes :=  @LodTypes.Indexes[LOD_SPRITE, 2];
  LodTypes.Table[LOD_SPRITE, 3].NumLods :=  3;
  LodTypes.Table[LOD_SPRITE, 3].Indexes :=  @LodTypes.Indexes[LOD_SPRITE, 3];
  
  (* LOD_BITMAP *)
  LodTypes.Table[LOD_BITMAP, 0].NumLods :=  3;
  LodTypes.Table[LOD_BITMAP, 0].Indexes :=  @LodTypes.Indexes[LOD_BITMAP, 0];
  LodTypes.Table[LOD_BITMAP, 1].NumLods :=  3;
  LodTypes.Table[LOD_BITMAP, 1].Indexes :=  @LodTypes.Indexes[LOD_BITMAP, 1];
  LodTypes.Table[LOD_BITMAP, 2].NumLods :=  1;
  LodTypes.Table[LOD_BITMAP, 2].Indexes :=  @LodTypes.Indexes[LOD_BITMAP, 2];
  LodTypes.Table[LOD_BITMAP, 3].NumLods :=  1;
  LodTypes.Table[LOD_BITMAP, 3].Indexes :=  @LodTypes.Indexes[LOD_BITMAP, 3];
  
  (* LOD_WAV *)
  LodTypes.Table[LOD_WAV, 0].NumLods :=  2;
  LodTypes.Table[LOD_WAV, 0].Indexes :=  @LodTypes.Indexes[LOD_WAV, 0];
  LodTypes.Table[LOD_WAV, 1].NumLods :=  2;
  LodTypes.Table[LOD_WAV, 1].Indexes :=  @LodTypes.Indexes[LOD_WAV, 1];
  LodTypes.Table[LOD_WAV, 2].NumLods :=  2;
  LodTypes.Table[LOD_WAV, 2].Indexes :=  @LodTypes.Indexes[LOD_WAV, 2];
  LodTypes.Table[LOD_WAV, 3].NumLods :=  2;
  LodTypes.Table[LOD_WAV, 3].Indexes :=  @LodTypes.Indexes[LOD_WAV, 3];
  
  (* LOD_SPRITE *)
  LodTypes.Indexes[LOD_SPRITE, 0][0]  :=  5;
  LodTypes.Indexes[LOD_SPRITE, 0][1]  :=  1;
  
  LodTypes.Indexes[LOD_SPRITE, 1][0]  :=  4;
  LodTypes.Indexes[LOD_SPRITE, 1][1]  :=  0;
  
  LodTypes.Indexes[LOD_SPRITE, 2][0]  :=  1;
  LodTypes.Indexes[LOD_SPRITE, 2][1]  :=  0;
  
  LodTypes.Indexes[LOD_SPRITE, 3][0]  :=  7;
  LodTypes.Indexes[LOD_SPRITE, 3][1]  :=  3;
  LodTypes.Indexes[LOD_SPRITE, 3][2]  :=  1;
  
  (* LOD_BITMAP *)
  LodTypes.Indexes[LOD_BITMAP, 0][0]  :=  6;
  LodTypes.Indexes[LOD_BITMAP, 0][1]  :=  2;
  LodTypes.Indexes[LOD_BITMAP, 0][2]  :=  0;
  
  LodTypes.Indexes[LOD_BITMAP, 1][0]  :=  2;
  LodTypes.Indexes[LOD_BITMAP, 1][1]  :=  1;
  LodTypes.Indexes[LOD_BITMAP, 1][2]  :=  0;
  
  LodTypes.Indexes[LOD_BITMAP, 2][0]  :=  1;
  
  LodTypes.Indexes[LOD_BITMAP, 3][0]  :=  0;
  
  (* LOD_WAV *)
  LodTypes.Indexes[LOD_WAV, 0][0]  :=  1;
  LodTypes.Indexes[LOD_WAV, 0][1]  :=  0;
  
  LodTypes.Indexes[LOD_WAV, 1][0]  :=  1;
  LodTypes.Indexes[LOD_WAV, 1][1]  :=  3;
  
  LodTypes.Indexes[LOD_WAV, 2][0]  :=  0;
  LodTypes.Indexes[LOD_WAV, 2][1]  :=  2;
  
  LodTypes.Indexes[LOD_WAV, 3][0]  :=  1;
  LodTypes.Indexes[LOD_WAV, 3][1]  :=  0;
end; // .procedure RegisterDefaultLodTypes

procedure LoadLod (const LodName: string; Res: PLod);
begin
  {!} Assert(Res <> nil);
  asm
    MOV ECX, Res
    PUSH LodName
    MOV EAX, $4DAD60
    CALL EAX
  end; // .ASM
end; // .procedure LoadLod

procedure AddLodToList (LodInd: integer);
var
{U} Indexes:      PIndexes;
    LodType:      TLodType;
    GameVersion:  TGameVersion;
    i:            integer;
   
begin
  for LodType := LOD_SPRITE to LOD_WAV do begin
    for GameVersion := Low(TGameVersion) to High(TGameVersion) do begin
      Indexes := @LodTypes.Indexes[LodType, GameVersion];
      
      for i := LodTypes.Table[LodType, GameVersion].NumLods - 1 downto 0 do begin
        Indexes[i + 1] := Indexes[i];
      end; // .for
      
      Indexes[0] := LodInd;
      
      Inc(LodTypes.Table[LodType, GameVersion].NumLods);
    end; // .for
  end; // .for
end; // .procedure AddLodToList

procedure LoadLods;
const
  MIN_LOD_SIZE = 12;

var
  i: integer;

begin
  RegisterDefaultLodTypes;
  NumLods := NUM_OBLIG_LODS;
  
  with Files.Locate('Data\*.pac', Files.ONLY_FILES) do begin
    while FindNext do begin
      if FoundRec.Rec.Size > MIN_LOD_SIZE then begin
        LodList.Add(FoundName);
      end;
    end;
  end;
  
  for i := LodList.Count - 1 downto 0 do begin
    LoadLod(LodList[i], @LodTable[NumLods]);
    AddLodToList(NumLods);
    Inc(NumLods);
  end;
end; // .procedure LoadLods

{$W-}
procedure Hook_SetLodTypes; assembler;
asm
  CALL LoadLods
  // RET
end; // .procedure Hook_SetLodTypes
{$W+}

procedure ExtendLods;
begin
  (* Fix lod constructors args *)
  Core.p.WriteDword(Ptr($4DACE6 + 15 * 0), integer(@LodTable[0]));
  Core.p.WriteDword(Ptr($4DACE6 + 15 * 1), integer(@LodTable[1]));
  Core.p.WriteDword(Ptr($4DACE6 + 15 * 2), integer(@LodTable[2]));
  Core.p.WriteDword(Ptr($4DACE6 + 15 * 3), integer(@LodTable[3]));
  Core.p.WriteDword(Ptr($4DACE6 + 15 * 4), integer(@LodTable[4]));
  Core.p.WriteDword(Ptr($4DACE6 + 15 * 5), integer(@LodTable[5]));
  Core.p.WriteDword(Ptr($4DACE6 + 15 * 6), integer(@LodTable[6]));
  Core.p.WriteDword(Ptr($4DACE6 + 15 * 7), integer(@LodTable[7]));
  
  (* Fix refs to LodTable[0] *)
  Core.p.WriteDword(Ptr($4DAD9D), integer(@LodTable[0]));
  Core.p.WriteDword(Ptr($4DB1A9), integer(@LodTable[0]));
  
  (* Fix refs to LodTable[0].F4 *)
  Core.p.WriteDword(Ptr($4DB1AF), integer(@LodTable[0]) + 4);
  Core.p.WriteDword(Ptr($4DB275), integer(@LodTable[0]) + 4);
  Core.p.WriteDword(Ptr($4DB298), integer(@LodTable[0]) + 4);
  Core.p.WriteDword(Ptr($4DB2F5), integer(@LodTable[0]) + 4);
  Core.p.WriteDword(Ptr($4DB318), integer(@LodTable[0]) + 4);
  Core.p.WriteDword(Ptr($4DC029), integer(@LodTable[0]) + 4);
  Core.p.WriteDword(Ptr($4DC087), integer(@LodTable[0]) + 4);
  
  (* Fix refs to LodTypes.Table *)
  Core.p.WriteDword(Ptr($4DB25D), integer(@LodTypes.Table));
  Core.p.WriteDword(Ptr($4DB264), integer(@LodTypes.Table));
  Core.p.WriteDword(Ptr($4DB2E4), integer(@LodTypes.Table));
  Core.p.WriteDword(Ptr($4DBF0F), integer(@LodTypes.Table));
  
  (* Fix refs to LodTypes.Table.f4 *)
  Core.p.WriteDword(Ptr($4DB256), integer(@LodTypes.Table) + 4);
  
  (* Fix refs to LodTypes.Table.f8 *)
  Core.p.WriteDword(Ptr($4DB2DD), integer(@LodTypes.Table) + 8);
  
  (* Fix refs to LodTypes.Table.f12 *)
  Core.p.WriteDword(Ptr($4DB2D6), integer(@LodTypes.Table) + 12);
  
  Core.Hook(@Hook_SetLodTypes, Core.HOOKTYPE_JUMP, 5, Ptr($4DAED0));
end; // .procedure ExtendLods

procedure LoadZeobjtsExtensions;
var
{O} ChildObjList: Lists.TStringList;
    FileName:     string;
    FileContents: string;

begin
  {!} Assert(MapObjMan.ZEObjList <> nil);
  Files.Scan(MapObjMan.ZEOBJTS_DIR + '\*.txt', Files.faNotDirectory, '.txt', MapObjMan.LoadZeobjt);
end; // .procedure LoadZeobjtsExtensions

function FileIsInLod (const FileName: string; RawLod: pointer): boolean; 
begin
  result  :=  false;
  
  if FileName <> '' then begin
    asm
      MOV ECX, RawLod
      ADD ECX, 4
      PUSH FileName
      MOV EAX, $4E48F0
      CALL EAX
      MOV result, AL
    end; // .asm
  end; // .if
end; // .function FileIsInLod  

function FindFileLod (const FileName: string; out LodPath: string): boolean;
const
  MAX_LOD_COUNT = 100;
  
type
  PLod  = ^TLod;
  TLod  = packed record
    Dummy:  array [0..399] of byte;
  end; // .record TLod

var
  Lod:  PLod;
  i:    integer;
  
begin
  Lod :=  Ptr(integer(PPOINTER($4DACE6)^) + sizeof(TLod) * (MAX_LOD_COUNT - 1));
  // * * * * * //
  result  :=  false;
  i       :=  MAX_LOD_COUNT - 1;
   
  while not result and (i >= 0) do begin
    if PPOINTER(Lod)^ <> nil then begin
      result := FileIsInLod(FileName, Lod);
    end; // .if
    
    if not result then begin
      Dec(Lod);
      Dec(i);
    end; // .if
  end; // .while

  if result then begin
    LodPath :=  pchar(integer(Lod) + 8);
  end; // .if
end; // .function FindFileLod


(* Loads global redirection rules from json configs *)
procedure LoadGlobalRedirectionConfig (const ConfigDir: string; RedirectOnlyMissing: boolean);
var
{U} Config:             TlkJsonObject;
    LodPath:            string;
    ResourceName:       string;
    WillBeRedirected:   boolean;
    ConfigFileContents: string;
    i:                  integer;

begin
  Config := nil;
  // * * * * * //
  with Files.Locate(ConfigDir + '\*.json', Files.ONLY_FILES) do begin
    while FindNext do begin
      if Files.ReadFileContents(ConfigDir + '\' + FoundName, ConfigFileContents) then begin
        Utils.CastOrFree(TlkJson.ParseText(ConfigFileContents), TlkJsonObject, Config);
        
        if Config <> nil then begin
          for i := 0 to Config.Count - 1 do begin
            ResourceName := Config.NameOf[i];

            if GlobalLodRedirs[ResourceName] = nil then begin
              WillBeRedirected := not RedirectOnlyMissing;

              if RedirectOnlyMissing then begin
                if AnsiLowerCase(ExtractFileExt(ResourceName)) = '.mp3' then begin
                  WillBeRedirected := not FileExists(MUSIC_DIR + '\' + ResourceName);
                end else begin
                  WillBeRedirected := not FindFileLod(ResourceName, LodPath);
                end; // .else
              end; // .if
              
              if WillBeRedirected then begin
                GlobalLodRedirs[ResourceName] := TString.Create(Config.getString(i));
              end; // .if
            end; // .if
          end; // .for
        end else begin
          Core.NotifyError('Json file has invalid format: "' + ConfigDir + '\' + FoundName + '"');
        end; // .else
      end; // .if
    end; // .while
  end; // .with
  // * * * * * //
  FreeAndNil(Config);
end; // .procedure LoadGlobalRedirectionConfig

function Hook_ReadTxt (Context: Core.PHookContext): LONGBOOL; stdcall;
const
  ZEOBJTS_NAME = 'zeobjts.txt';

var
  TextName:     string;
  TextContents: string;
  TextBuffer:   pointer;

begin
  (*
  All ESP offsets were increased by 4 to compensate call to bridge 
  *)
  TextName := SysUtils.AnsiLowerCase(PPCHAR(Context.ESP + $28)^);
  
  if TextName = ZEOBJTS_NAME then begin
    if ZEObjList <> nil then begin
      SysUtils.FreeAndNil(ZEObjList);
    end; // .if
    
    SetString(TextContents, PPCHAR(Context.ESP + $14)^, Context.EDI);
    
    if MapObjMan.LoadObjList('zeobjts.txt', TextContents, ZEObjList) then begin
      LoadZeobjtsExtensions;
      TextContents               := ObjListToStr(ZEObjList);
      Editor.MFree(PPCHAR(Context.ESP + $14)^);
      TextBuffer                 := Editor.MAlloc(Length(TextContents));
      PPCHAR(Context.ESP + $14)^ := TextBuffer;
      Context.EDI                := Length(TextContents);
      Context.ESI                := integer(TextBuffer);
      Utils.CopyMem(Length(TextContents), pointer(TextContents), TextBuffer);
    end // .if
    else begin
      DlgMes.MsgError('Invalid editor objects file: "' + ZEOBJTS_NAME + '"');
    end; // .else
  end; // .if
  
  result  :=  Core.EXEC_DEF_CODE;
end; // .function Hook_ReadTxt

function Hook_AfterLoadLods (Context: Core.PHookContext): longbool; stdcall;
begin
  LoadGlobalRedirectionConfig(GLOBAL_MISSING_REDIRECTIONS_CONFIG_DIR, REDIRECT_ONLY_MISSING);
  result := Core.EXEC_DEF_CODE;
end;

procedure OnInit (Event: MapExt.PEvent); stdcall;
begin
  ExtendLods;

  (* Add support for extended zeobjts.txt *)
  Core.ApiHook(@Hook_ReadTxt, Core.HOOKTYPE_BRIDGE, Ptr($4DC8D4));

  (* Add support for laod resources redirection mechanism *)
  Core.ApiHook(@Hook_AfterLoadLods, Core.HOOKTYPE_BRIDGE, Ptr($45BDBB));
end;

begin
  LodList         := Lists.NewSimpleStrList;
  GlobalLodRedirs := AssocArrays.NewStrictAssocArr(TString);
  MapExt.RegisterHandler(OnInit, 'OnInit');
end.