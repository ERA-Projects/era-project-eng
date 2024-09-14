UNIT Stores;
{
DESCRIPTION:  Provides ability to store safely data in savegames
AUTHOR:       Alexander Shostak (aka Berserker aka EtherniDee aka BerSoft)
}

(***)  INTERFACE  (***)
USES
  SysUtils, Math, Utils, Crypto, AssocArrays, StrLib, DlgMes,
  Core, GameExt, Heroes, Erm;

TYPE
  (* IMPORT *)
  TAssocArray = AssocArrays.TAssocArray;

  TStoredData = CLASS
    Data:       STRING;
    ReadingPos: INTEGER;
  END; // .CLASS TStoredData


CONST
  ZvsErmTriggerBeforeSave:  Utils.TProcedure  = Ptr($750093);


PROCEDURE WriteSavegameSection
(
            DataSize:     INTEGER;
        {n} Data:         POINTER;
  CONST     SectionName:  STRING
);

FUNCTION  ReadSavegameSection
(
            DataSize:     INTEGER;
        {n} Dest:         POINTER;
  CONST     SectionName:  STRING
): INTEGER;


(***) IMPLEMENTATION (***)


VAR
{O} WritingStorage:   {O} TAssocArray {OF Data: StrLib.TStrBuilder};
{O} ReadingStorage:   {O} TAssocArray {OF StoredData: TStoredData};


PROCEDURE WriteSavegameSection (DataSize: INTEGER; {n} Data: POINTER; CONST SectionName: STRING);
VAR
{U} Section:  StrLib.TStrBuilder;
    DataStr:  STRING;
  
BEGIN
  {!} ASSERT(Utils.IsValidBuf(Data, DataSize));
  Section :=  NIL;
  // * * * * * //
  IF DataSize > 0 THEN BEGIN
    Section :=  WritingStorage[SectionName];
    
    IF Section = NIL THEN BEGIN
      Section                     :=  StrLib.TStrBuilder.Create;
      WritingStorage[SectionName] :=  Section;
    END; // .IF
    
    SetLength(DataStr, DataSize);
    Utils.CopyMem(DataSize, Data, POINTER(DataStr));
    Section.Append(DataStr);
  END; // .IF
END; // .PROCEDURE WriteSavegameSection

FUNCTION ReadSavegameSection
(
            DataSize:     INTEGER;
        {n} Dest:         POINTER;
  CONST     SectionName:  STRING
): INTEGER;

VAR
{U} Section:  TStoredData;
  
BEGIN
  {!} ASSERT(Utils.IsValidBuf(Dest, DataSize));
  Section :=  NIL;
  // * * * * * //
  RESULT  :=  0;
  
  IF DataSize > 0 THEN BEGIN
    Section :=  ReadingStorage[SectionName];
    
    IF Section <> NIL THEN BEGIN
      RESULT  :=  Math.Min(DataSize, LENGTH(Section.Data) - Section.ReadingPos);
      Utils.CopyMem(RESULT, POINTER(@Section.Data[Section.ReadingPos + 1]), Dest);
      Section.ReadingPos  :=  Section.ReadingPos + RESULT;
    END; // .IF
  END; // .IF
END; // .FUNCTION ReadSavegameSection

FUNCTION Hook_SaveGame (Context: Core.PHookHandlerArgs): LONGBOOL; STDCALL;
CONST
  PARAM_SAVEGAME_NAME = 0;

VAR
{U} OldSavegameName:  PCHAR;
{U} SavegameName:     PCHAR;
    SavegameNameLen:  INTEGER;
  
BEGIN
  OldSavegameName :=  PPOINTER(Context.EBP + 8)^;
  SavegameName    :=  NIL;
  // * * * * * //
  GameExt.EraSaveEventParams;
  
  GameExt.EraEventParams[PARAM_SAVEGAME_NAME] :=  INTEGER(OldSavegameName);
  ZvsErmTriggerBeforeSave;
  SavegameName    :=  Ptr(GameExt.EraEventParams[PARAM_SAVEGAME_NAME]);
  SavegameNameLen :=  SysUtils.StrLen(SavegameName);
  
  IF SavegameName <> OldSavegameName THEN BEGIN
    Utils.CopyMem(SavegameNameLen + 1, SavegameName, OldSavegameName);
    PINTEGER(Context.EBP + 12)^ :=  -1;
  END; // .IF
  
  GameExt.EraRestoreEventParams;
  
  RESULT  :=  Core.EXEC_DEF_CODE;
END; // .FUNCTION Hook_SaveGame

FUNCTION Hook_SaveGameWrite (Context: Core.PHookHandlerArgs): LONGBOOL; STDCALL;
VAR
{U} StrBuilder:     StrLib.TStrBuilder;
    NumSections:    INTEGER;
    SectionNameLen: INTEGER;
    SectionName:    STRING;
    DataLen:        INTEGER;
    BuiltData:      STRING;

BEGIN
  StrBuilder  :=  NIL;
  // * * * * * //
  WritingStorage.Clear;
  
  GameExt.EraSaveEventParams;
  Erm.FireErmEvent(Erm.TRIGGER_SAVEGAME_WRITE);
  GameExt.EraRestoreEventParams;
  
  NumSections :=  WritingStorage.ItemCount;
  Heroes.GzipWrite(@NumSections, SIZEOF(NumSections));
  
  WritingStorage.BeginIterate;
  
  WHILE WritingStorage.IterateNext(SectionName, POINTER(StrBuilder)) DO BEGIN
    SectionNameLen  :=  LENGTH(SectionName);
    Heroes.GzipWrite(@SectionNameLen, SIZEOF(SectionNameLen));
    Heroes.GzipWrite(POINTER(SectionName), SectionNameLen);
    
    BuiltData :=  StrBuilder.BuildStr;
    DataLen   :=  LENGTH(BuiltData);
    Heroes.GzipWrite(@DataLen, SIZEOF(DataLen));
    Heroes.GzipWrite(POINTER(BuiltData), LENGTH(BuiltData));
    
    StrBuilder  :=  NIL;
  END; // .WHILE
  
  WritingStorage.EndIterate;
  
  // Default code
  IF PINTEGER(Context.EBP - 4)^ = 0 THEN BEGIN
    Context.RetAddr :=  Ptr($704EF2);
  END // .IF
  ELSE BEGIN
    Context.RetAddr :=  Ptr($704F10);
  END; // .ELSE
  
  RESULT  :=  NOT Core.EXEC_DEF_CODE;
END; // .FUNCTION Hook_SaveGameWrite

FUNCTION Hook_SaveGameRead (Context: Core.PHookHandlerArgs): LONGBOOL; STDCALL;
VAR
{U} StoredData:     TStoredData;
    NumSections:    INTEGER;
    SectionNameLen: INTEGER;
    SectionName:    STRING;
    DataLen:        INTEGER;
    SectionData:    STRING;
    i:              INTEGER;

BEGIN
  StoredData  :=  NIL;
  // * * * * * //
  ReadingStorage.Clear;
  Heroes.GzipRead(@NumSections, SIZEOF(NumSections));
  
  FOR i:=1 TO NumSections DO BEGIN
    Heroes.GzipRead(@SectionNameLen, SIZEOF(SectionNameLen));
    SetLength(SectionName, SectionNameLen);
    Heroes.GzipRead(POINTER(SectionName), SectionNameLen);
    
    Heroes.GzipRead(@DataLen, SIZEOF(DataLen));
    SetLength(SectionData, DataLen);
    Heroes.GzipRead(POINTER(SectionData), DataLen);
    
    StoredData                  :=  TStoredData.Create;
    StoredData.Data             :=  SectionData; SectionData  :=  '';
    StoredData.ReadingPos       :=  0;
    ReadingStorage[SectionName] :=  StoredData;
  END; // .FOR
  
  GameExt.EraSaveEventParams;
  Erm.FireErmEvent(Erm.TRIGGER_SAVEGAME_READ);
  GameExt.EraRestoreEventParams;
  
  // Default code
  IF PINTEGER(Context.EBP - $14)^ = 0 THEN BEGIN
    Context.RetAddr :=  Ptr($7051BE);
  END // .IF
  ELSE BEGIN
    Context.RetAddr :=  Ptr($7051DC);
  END; // .ELSE
  
  RESULT  :=  NOT Core.EXEC_DEF_CODE;
END; // .FUNCTION Hook_SaveGameRead

PROCEDURE OnAfterWoG (Event: GameExt.PEvent); STDCALL;
BEGIN
  Core.Hook(@Hook_SaveGame, Core.HOOKTYPE_BRIDGE, 5, Ptr($4BEB65));
  Core.Hook(@Hook_SaveGameWrite, Core.HOOKTYPE_BRIDGE, 6, Ptr($704EEC));
  Core.Hook(@Hook_SaveGameRead, Core.HOOKTYPE_BRIDGE, 6, Ptr($7051B8));
  
  // Remove Erm Trigger "BeforeSaveGame" Call
  FillChar(POINTER($7051F5)^, 5, $90);
END; // .PROCEDURE OnAfterWoG

BEGIN
  WritingStorage  :=  AssocArrays.NewStrictAssocArr(StrLib.TStrBuilder);
  ReadingStorage  :=  AssocArrays.NewStrictAssocArr(TStoredData);
  GameExt.RegisterHandler(OnAfterWoG, 'OnAfterWoG');
END.
