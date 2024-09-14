UNIT Lodman;
{
DESCRIPTION:  LOD archives manager
AUTHOR:       Alexander Shostak (aka Berserker aka EtherniDee aka BerSoft)
BASED ON:     "Lods" plugin by Sav, WoG Sources by ZVS
}

(***)  INTERFACE  (***)
USES
  SysUtils, Math, Utils, Files, Core, Lists,
  GameExt, Heroes;

CONST
  MAX_NUM_LODS  = 100;
  DEF_NUM_LODS  = 8;


TYPE
  TGameVersion  = Heroes.ROE..Heroes.SOD_AND_AB;
  TLodType      = (LOD_SPRITE = 1, LOD_BITMAP = 2, LOD_WAV = 3);
  
  PLodTable = ^TLodTable;
  TLodTable = ARRAY [0..MAX_NUM_LODS - 1] OF Heroes.TLod;

  TZvsAddLodToList  = FUNCTION (LodInd: INTEGER): INTEGER; CDECL;
  
  PIndexes  = ^TIndexes;
  TIndexes  = ARRAY [0..MAX_NUM_LODS - 1] OF INTEGER;
  
  PLodIndexes = ^TLodIndexes;
  TLodIndexes = PACKED RECORD
    NumLods:  INTEGER;
    Indexes:  PIndexes;
  END; // .RECORD TLodIndexes
  
  PLodTypes = ^TLodTypes;
  TLodTypes = PACKED RECORD
    Table:    ARRAY [TLodType, TGameVersion] OF TLodIndexes;
    Indexes:  ARRAY [TLodType, TGameVersion] OF TIndexes;
  END; // .RECORD TLodTypes


CONST
  ZvsAddLodToList:  TZvsAddLodToList  = Ptr($75605B);
  ZvsLodTable:      PLodTable         = Ptr($28077D0);
  ZvsLodTypes:      PLodTypes         = Ptr($79EFE0);


(***) IMPLEMENTATION (***)


VAR
{O} LodList:  Lists.TStringList;
    NumLods:  INTEGER = DEF_NUM_LODS;


PROCEDURE UnregisterLod (LodInd: INTEGER);
VAR
{U} Table:        PLodIndexes;
{U} Indexes:      PIndexes;
    LodType:      TLodType;
    GameVersion:  TGameVersion;
    LocalNumLods: INTEGER;
    
    LeftInd:      INTEGER;
    i:            INTEGER;
   
BEGIN
  {!} ASSERT(Math.InRange(LodInd, 0, NumLods - 1));
  Table   :=  NIL;
  Indexes :=  NIL;
  // * * * * * //
  FOR LodType := LOW(TLodType) TO HIGH(TLodType) DO BEGIN
    FOR GameVersion := LOW(TGameVersion) TO HIGH(TGameVersion) DO BEGIN
      Table         :=  @ZvsLodTypes.Table[LodType, GameVersion];
      Indexes       :=  Table.Indexes;
      LocalNumLods  :=  Table.NumLods;
      
      LeftInd :=  0;
      i       :=  0;
      
      WHILE i < LocalNumLods DO BEGIN
        IF Indexes[i] <> LodInd THEN BEGIN
          Indexes[LeftInd]  :=  Indexes[i];
          INC(LeftInd);
        END; // .IF
        
        INC(i);
      END; // .WHILE
      
      Table.NumLods :=  LeftInd;
    END; // .FOR
  END; // .FOR
  
  DEC(NumLods);
END; // .PROCEDURE UnregisterLod

PROCEDURE UnregisterDeadLods;
BEGIN
  IF NOT SysUtils.FileExists('Data\h3abp_sp.lod') THEN BEGIN
    UnregisterLod(7);
  END; // .IF
  
  IF NOT SysUtils.FileExists('Data\h3abp_bm.lod') THEN BEGIN
    UnregisterLod(6);
  END; // .IF
  
  IF NOT SysUtils.FileExists('Data\h3psprit.lod') THEN BEGIN
    UnregisterLod(5);
  END; // .IF
  
  IF NOT SysUtils.FileExists('Data\h3pbitma.lod') THEN BEGIN
    UnregisterLod(4);
  END; // .IF
  
  IF NOT SysUtils.FileExists('Data\h3ab_spr.lod') THEN BEGIN
    UnregisterLod(3);
  END; // .IF
  
  IF NOT SysUtils.FileExists('Data\h3ab_bmp.lod') THEN BEGIN
    UnregisterLod(2);
  END; // .IF
  
  IF NOT SysUtils.FileExists('Data\h3sprite.lod') THEN BEGIN
    UnregisterLod(1);
  END; // .IF
  
  IF NOT SysUtils.FileExists('Data\h3bitmap.lod') THEN BEGIN
    UnregisterLod(0);
  END; // .IF
END; // .PROCEDURE UnregisterDeadLods

FUNCTION Hook_LoadLods (Context: Core.PHookHandlerArgs): LONGBOOL; STDCALL;
VAR
{O} Locator:  Files.TFileLocator;
{O} FileInfo: Files.TFileItemInfo;
    FileName: STRING;
    i:        INTEGER;
  
BEGIN
  Locator   :=  Files.TFileLocator.Create;
  FileInfo  :=  NIL;
  // * * * * * //
  UnregisterDeadLods;
  
  Locator.DirPath :=  'Data';
  Locator.InitSearch('*.pac');
  
  WHILE Locator.NotEnd AND (NumLods <= HIGH(TLodTable)) DO BEGIN
    FileName  :=  SysUtils.AnsiLowerCase(Locator.GetNextItem(Files.TItemInfo(FileInfo)));
    
    IF (SysUtils.ExtractFileExt(FileName) = '.pac') AND NOT FileInfo.IsDir THEN BEGIN
      LodList.Add(FileName);
    END; // .IF
    
    SysUtils.FreeAndNil(FileInfo);
  END; // .WHILE
  
  Locator.FinitSearch;
  
  FOR i := LodList.Count - 1 DOWNTO 0 DO BEGIN
    Heroes.LoadLod(LodList[i], @ZvsLodTable[NumLods]);
    ZvsAddLodToList(NumLods);
    INC(NumLods);
  END; // .FOR
  
  RESULT  :=  Core.EXEC_DEF_CODE;
  // * * * * * //
  SysUtils.FreeAndNil(Locator);
END; // .FUNCTION Hook_LoadLods
  
PROCEDURE OnBeforeWoG (Event: PEvent); STDCALL;
BEGIN
  // Remove WoG h3custom and h3wog lods registration
  PWORD($7015E5)^ :=  $38EB;
  Core.Hook(@Hook_LoadLods, Core.HOOKTYPE_BRIDGE, 5, Ptr($559408));
END; // .PROCEDURE OnBeforeWoG

BEGIN
  LodList :=  Lists.NewSimpleStrList;

  GameExt.RegisterHandler(OnBeforeWoG, 'OnBeforeWoG');
END.
