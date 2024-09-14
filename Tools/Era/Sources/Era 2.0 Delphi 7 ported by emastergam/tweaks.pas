UNIT Tweaks;
{
DESCRIPTION:  Game improvements
AUTHOR:       Alexander Shostak (aka Berserker aka EtherniDee aka BerSoft)
}

(***)  INTERFACE  (***)
USES
  SysUtils, Utils, StrLib, WinSock, Windows, Math,
  CFiles, Files, Ini,
  Core, GameExt, Heroes;

CONST
  // f (Value: PCHAR; MaxResLen: INTEGER; DefValue, Key, SectionName, FileName: PCHAR): INTEGER; CDECL;
  ZvsReadStrIni   = Ptr($773A46);
  // f (Res: PINTEGER; DefValue: INTEGER; Key, SectionName, FileName: PCHAR): INTEGER; CDECL;
  ZvsReadIntIni   = Ptr($7739D1);
  // f (Value: PCHAR; Key, SectionName, FileName: PCHAR): INTEGER; CDECL;
  ZvsWriteStrIni  = Ptr($773B34);
  // f (Value, Key, SectionName, FileName: PCHAR): INTEGER; CDECL;
  ZvsWriteIntIni  = Ptr($773ACB);


(***) IMPLEMENTATION (***)


VAR
  InetCriticalSection:  Windows.TRTLCriticalSection;
  IsDefaultInetMode:    BOOLEAN;


FUNCTION Hook_ReadIntIni
(
  Res:          PINTEGER;
  DefValue:     INTEGER;
  Key:          PCHAR;
  SectionName:  PCHAR;
  FileName:     PCHAR
): INTEGER; CDECL;

VAR
  Value:  STRING;
  
BEGIN
  RESULT  :=  0;
  
  IF
    (NOT Ini.ReadStrFromIni(Key, SectionName, FileName, Value)) OR
    NOT SysUtils.TryStrToInt(Value, Res^)
  THEN BEGIN
    Res^  :=  DefValue;
  END; // .IF
END; // .FUNCTION Hook_ReadIntIni

FUNCTION Hook_ReadStrIni
(
  Res:          PCHAR;
  MaxResLen:    INTEGER;
  DefValue:     PCHAR;
  Key:          PCHAR;
  SectionName:  PCHAR;
  FileName:     PCHAR
): INTEGER; CDECL;

VAR
  Value:  STRING;
  
BEGIN
  RESULT  :=  0;
  
  IF
    (NOT Ini.ReadStrFromIni(Key, SectionName, FileName, Value)) OR
    (LENGTH(Value) > MaxResLen)
  THEN BEGIN
    Value :=  DefValue;
  END; // .IF
  
  IF Value <> '' THEN BEGIN
    Utils.CopyMem(LENGTH(Value) + 1, POINTER(Value), Res);
  END // .IF
  ELSE BEGIN
    Res^  :=  #0;
  END; // .ELSE
END; // .FUNCTION Hook_ReadStrIni

FUNCTION Hook_WriteStrIni (Value, Key, SectionName, FileName: PCHAR): INTEGER; CDECL;
BEGIN
  RESULT  :=  0;
  Ini.WriteStrToIni(Key, Value, SectionName, FileName);
END; // .FUNCTION Hook_WriteStrIni

FUNCTION Hook_WriteIntIni (Value: INTEGER; Key, SectionName, FileName: PCHAR): INTEGER; CDECL;
BEGIN
  RESULT  :=  0;
  Ini.WriteStrToIni(Key, SysUtils.IntToStr(Value), SectionName, FileName);
END; // .FUNCTION Hook_ReadIntIni

FUNCTION Hook_ZvsGetWindowWidth (Context: Core.PHookHandlerArgs): LONGBOOL; STDCALL;
BEGIN
  Context.ECX :=  WndManagerPtr^.ScreenPcx16.Width;
  RESULT      :=  NOT Core.EXEC_DEF_CODE;
END; // .FUNCTION Hook_ZvsGetWindowWidth

FUNCTION Hook_ZvsGetWindowHeight (Context: Core.PHookHandlerArgs): LONGBOOL; STDCALL;
BEGIN
  Context.EDX :=  WndManagerPtr^.ScreenPcx16.Height;
  RESULT      :=  NOT Core.EXEC_DEF_CODE;
END; // .FUNCTION Hook_ZvsGetWindowHeight

PROCEDURE MarkFreshestSavegame;
VAR
{O} Locator:          Files.TFileLocator;
{O} FileInfo:         Files.TFileItemInfo;
    FileName:         STRING;
    FreshestTime:     INT64;
    FreshestFileName: STRING;
  
BEGIN
  Locator   :=  Files.TFileLocator.Create;
  FileInfo  :=  NIL;
  // * * * * * //
  FreshestFileName  :=  #0;
  FreshestTime      :=  0;
  
  Locator.DirPath   :=  'Games';
  Locator.InitSearch('*.*');
  
  WHILE Locator.NotEnd DO BEGIN
    FileName  :=  Locator.GetNextItem(CFiles.TItemInfo(FileInfo));
    
    IF
      ((FileInfo.Data.dwFileAttributes AND Windows.FILE_ATTRIBUTE_DIRECTORY) = 0) AND
      (INT64(FileInfo.Data.ftLastWriteTime) > FreshestTime)
    THEN BEGIN
      FreshestFileName  :=  FileName;
      FreshestTime      :=  INT64(FileInfo.Data.ftLastWriteTime);
    END; // .IF
    SysUtils.FreeAndNil(FileInfo);
  END; // .WHILE
  
  Locator.FinitSearch;
  
  Utils.CopyMem(LENGTH(FreshestFileName) + 1, POINTER(FreshestFileName), Heroes.MarkedSavegame);
  // * * * * * //
  SysUtils.FreeAndNil(Locator);
END; // .PROCEDURE MarkFreshestSavegame

FUNCTION Hook_SetHotseatHeroName (Context: Core.PHookHandlerArgs): LONGBOOL; STDCALL;
VAR
  PlayerName:     STRING;
  NewPlayerName:  STRING;
  EcxReg:         INTEGER;

BEGIN
  PlayerName    :=  PCHAR(Context.EAX);
  NewPlayerName :=  PlayerName + ' 1';
  EcxReg        :=  Context.ECX;
  
  ASM
    MOV ECX, EcxReg
    PUSH NewPlayerName
    MOV EDX, [ECX]
    CALL [EDX + $34]
  END; // .ASM
  
  NewPlayerName :=  PlayerName + ' 2';
  EcxReg        :=  Context.EBX;
  
  ASM
    MOV ECX, EcxReg
    MOV ECX, [ECX + $54]
    PUSH NewPlayerName
    MOV EDX, [ECX]
    CALL [EDX + $34]
  END; // .ASM
  
  RESULT  :=  NOT Core.EXEC_DEF_CODE;
END; // .FUNCTION Hook_SetHotseatHeroName

FUNCTION Hook_PeekMessageA (Context: Core.PHookHandlerArgs): LONGBOOL; STDCALL;
BEGIN
  Windows.WaitForSingleObject(Heroes.hHeroes3Event^, 1);
  RESULT  :=  Core.EXEC_DEF_CODE;
END; // .FUNCTION Hook_PeekMessageA

FUNCTION New_Zvslib_GetPrivateProfileStringA
(
  Section:  PCHAR;
  Key:      PCHAR;
  DefValue: PCHAR;
  Buf:      PCHAR;
  BufSize:  INTEGER;
  FileName: PCHAR
): INTEGER; STDCALL;
  
VAR
  Res:  STRING;

BEGIN
  Res :=  '';

  IF NOT Ini.ReadStrFromIni(Key, Section, FileName, Res) THEN BEGIN
    Res :=  DefValue;
  END; // .IF
  
  IF BufSize <= LENGTH(Res) THEN BEGIN
    SetLength(Res, BufSize - 1);
  END; // .IF
  
  Utils.CopyMem(LENGTH(Res) + 1, PCHAR(Res), Buf);
  
  RESULT :=  LENGTH(Res) + 1;
END; // .FUNCTION New_Zvslib_GetPrivateProfileStringA

PROCEDURE ReadGameSettings;
  PROCEDURE ReadInt (CONST Key: STRING; Res: PINTEGER);
  VAR
    StrValue: STRING;
    Value:    INTEGER;
     
  BEGIN
    IF
      Ini.ReadStrFromIni
      (
        Key,
        Heroes.GAME_SETTINGS_SECTION,
        Heroes.GAME_SETTINGS_FILE,
        StrValue
      ) AND
      SysUtils.TryStrToInt(StrValue, Value)
    THEN BEGIN
      Res^  :=  Value;
    END; // .IF
  END; // .PROCEDURE ReadInt
  
  PROCEDURE ReadStr (CONST Key: STRING; Res: PCHAR);
  VAR
    StrValue: STRING;
     
  BEGIN
    IF
      Ini.ReadStrFromIni(Key, Heroes.GAME_SETTINGS_SECTION, Heroes.GAME_SETTINGS_FILE, StrValue)
    THEN BEGIN
      Utils.CopyMem(LENGTH(StrValue) + 1, PCHAR(StrValue), Res);
    END; // .IF
  END; // .PROCEDURE ReadStr
  
CONST
  UNIQUE_ID_LEN   = 3;
  UNIQUE_ID_MASK  = $FFF;
  
VAR
  RandomValue:  INTEGER;
  RandomStr:    STRING;
  i:            INTEGER;
   
BEGIN
  ASM
    MOV EAX, Heroes.LOAD_DEF_SETTINGS
    CALL EAX
  END; // .ASM

  ReadInt('Show Intro',             Heroes.SHOW_INTRO_OPT);
  ReadInt('Music Volume',           Heroes.MUSIC_VOLUME_OPT);
  ReadInt('Sound Volume',           Heroes.SOUND_VOLUME_OPT);
  ReadInt('Last Music Volume',      Heroes.LAST_MUSIC_VOLUME_OPT);
  ReadInt('Last Sound Volume',      Heroes.LAST_SOUND_VOLUME_OPT);
  ReadInt('Walk Speed',             Heroes.WALK_SPEED_OPT);
  ReadInt('Computer Walk Speed',    Heroes.COMP_WALK_SPEED_OPT);
  ReadInt('Show Route',             Heroes.SHOW_ROUTE_OPT);
  ReadInt('Move Reminder',          Heroes.MOVE_REMINDER_OPT);
  ReadInt('Quick Combat',           Heroes.QUICK_COMBAT_OPT);
  ReadInt('Video Subtitles',        Heroes.VIDEO_SUBTITLES_OPT);
  ReadInt('Town Outlines',          Heroes.TOWN_OUTLINES_OPT);
  ReadInt('Animate SpellBook',      Heroes.ANIMATE_SPELLBOOK_OPT);
  ReadInt('Window Scroll Speed',    Heroes.WINDOW_SCROLL_SPEED_OPT);
  ReadInt('Bink Video',             Heroes.BINK_VIDEO_OPT);
  ReadInt('Blackout Computer',      Heroes.BLACKOUT_COMPUTER_OPT);
  ReadInt('First Time',             Heroes.FIRST_TIME_OPT);
  ReadInt('Test Decomp',            Heroes.TEST_DECOMP_OPT);
  ReadInt('Test Read',              Heroes.TEST_READ_OPT);
  ReadInt('Test Blit',              Heroes.TEST_BLIT_OPT);
  ReadStr('Unique System ID',       Heroes.UNIQUE_SYSTEM_ID_OPT);
  
  IF Heroes.UNIQUE_SYSTEM_ID_OPT^ = #0 THEN BEGIN
    Randomize;
    RandomValue :=  (INTEGER(Windows.GetTickCount) + Random(MAXLONGINT)) AND UNIQUE_ID_MASK;
    SetLength(RandomStr, UNIQUE_ID_LEN);
    
    FOR i:=1 TO UNIQUE_ID_LEN DO BEGIN
      RandomStr[i]  :=  UPCASE(StrLib.ByteToHexChar(RandomValue AND $F));
      RandomValue   :=  RandomValue SHR 4;
    END; // .FOR
    
    Utils.CopyMem(LENGTH(RandomStr) + 1, POINTER(RandomStr), Heroes.UNIQUE_SYSTEM_ID_OPT);
    
    Ini.WriteStrToIni
    (
      'Unique System ID',
      RandomStr,
      Heroes.GAME_SETTINGS_SECTION,
      Heroes.GAME_SETTINGS_FILE
    );
    
    Ini.SaveIni(Heroes.GAME_SETTINGS_FILE);
  END; // .IF
  
  ReadStr('Network Default Name',   Heroes.NETWORK_DEF_NAME_OPT);
  ReadInt('Autosave',               Heroes.AUTOSAVE_OPT);
  ReadInt('Show Combat Grid',       Heroes.SHOW_COMBAT_GRID_OPT);
  ReadInt('Show Combat Mouse Hex',  Heroes.SHOW_COMBAT_MOUSE_HEX_OPT);
  ReadInt('Combat Shade Level',     Heroes.COMBAT_SHADE_LEVEL_OPT);
  ReadInt('Combat Army Info Level', Heroes.COMBAT_ARMY_INFO_LEVEL_OPT);
  ReadInt('Combat Auto Creatures',  Heroes.COMBAT_AUTO_CREATURES_OPT);
  ReadInt('Combat Auto Spells',     Heroes.COMBAT_AUTO_SPELLS_OPT);
  ReadInt('Combat Catapult',        Heroes.COMBAT_CATAPULT_OPT);
  ReadInt('Combat Ballista',        Heroes.COMBAT_BALLISTA_OPT);
  ReadInt('Combat First Aid Tent',  Heroes.COMBAT_FIRST_AID_TENT_OPT);
  ReadInt('Combat Speed',           Heroes.COMBAT_SPEED_OPT);
  ReadInt('Main Game Show Menu',    Heroes.MAIN_GAME_SHOW_MENU_OPT);
  ReadInt('Main Game X',            Heroes.MAIN_GAME_X_OPT);
  ReadInt('Main Game Y',            Heroes.MAIN_GAME_Y_OPT);
  ReadInt('Main Game Full Screen',  Heroes.MAIN_GAME_FULL_SCREEN_OPT);
  ReadStr('AppPath',                Heroes.APP_PATH_OPT);
  ReadStr('CDDrive',                Heroes.CD_DRIVE_OPT);
END; // .PROCEDURE ReadGameSettings

PROCEDURE WriteGameSettings;
  PROCEDURE WriteInt (CONST Key: STRING; Value: PINTEGER); 
  BEGIN
    Ini.WriteStrToIni
    (
      Key,
      SysUtils.IntToStr(Value^),
      Heroes.GAME_SETTINGS_SECTION,
      Heroes.GAME_SETTINGS_FILE
    );
  END; // .PROCEDURE WriteInt
  
  PROCEDURE WriteStr (CONST Key: STRING; Value: PCHAR);
  BEGIN
    Ini.WriteStrToIni
    (
      Key,
      Value,
      Heroes.GAME_SETTINGS_SECTION,
      Heroes.GAME_SETTINGS_FILE
    );
  END; // .PROCEDURE WriteStr
   
BEGIN
  WriteInt('Show Intro',             Heroes.SHOW_INTRO_OPT);
  WriteInt('Music Volume',           Heroes.MUSIC_VOLUME_OPT);
  WriteInt('Sound Volume',           Heroes.SOUND_VOLUME_OPT);
  WriteInt('Last Music Volume',      Heroes.LAST_MUSIC_VOLUME_OPT);
  WriteInt('Last Sound Volume',      Heroes.LAST_SOUND_VOLUME_OPT);
  WriteInt('Walk Speed',             Heroes.WALK_SPEED_OPT);
  WriteInt('Computer Walk Speed',    Heroes.COMP_WALK_SPEED_OPT);
  WriteInt('Show Route',             Heroes.SHOW_ROUTE_OPT);
  WriteInt('Move Reminder',          Heroes.MOVE_REMINDER_OPT);
  WriteInt('Quick Combat',           Heroes.QUICK_COMBAT_OPT);
  WriteInt('Video Subtitles',        Heroes.VIDEO_SUBTITLES_OPT);
  WriteInt('Town Outlines',          Heroes.TOWN_OUTLINES_OPT);
  WriteInt('Animate SpellBook',      Heroes.ANIMATE_SPELLBOOK_OPT);
  WriteInt('Window Scroll Speed',    Heroes.WINDOW_SCROLL_SPEED_OPT);
  WriteInt('Bink Video',             Heroes.BINK_VIDEO_OPT);
  WriteInt('Blackout Computer',      Heroes.BLACKOUT_COMPUTER_OPT);
  WriteInt('First Time',             Heroes.FIRST_TIME_OPT);
  WriteInt('Test Decomp',            Heroes.TEST_DECOMP_OPT);
  WriteInt('Test Write',             Heroes.TEST_READ_OPT);
  WriteInt('Test Blit',              Heroes.TEST_BLIT_OPT);
  WriteStr('Unique System ID',       Heroes.UNIQUE_SYSTEM_ID_OPT);
  WriteStr('Network Default Name',   Heroes.NETWORK_DEF_NAME_OPT);
  WriteInt('Autosave',               Heroes.AUTOSAVE_OPT);
  WriteInt('Show Combat Grid',       Heroes.SHOW_COMBAT_GRID_OPT);
  WriteInt('Show Combat Mouse Hex',  Heroes.SHOW_COMBAT_MOUSE_HEX_OPT);
  WriteInt('Combat Shade Level',     Heroes.COMBAT_SHADE_LEVEL_OPT);
  WriteInt('Combat Army Info Level', Heroes.COMBAT_ARMY_INFO_LEVEL_OPT);
  WriteInt('Combat Auto Creatures',  Heroes.COMBAT_AUTO_CREATURES_OPT);
  WriteInt('Combat Auto Spells',     Heroes.COMBAT_AUTO_SPELLS_OPT);
  WriteInt('Combat Catapult',        Heroes.COMBAT_CATAPULT_OPT);
  WriteInt('Combat Ballista',        Heroes.COMBAT_BALLISTA_OPT);
  WriteInt('Combat First Aid Tent',  Heroes.COMBAT_FIRST_AID_TENT_OPT);
  WriteInt('Combat Speed',           Heroes.COMBAT_SPEED_OPT);
  WriteInt('Main Game Show Menu',    Heroes.MAIN_GAME_SHOW_MENU_OPT);
  WriteInt('Main Game X',            Heroes.MAIN_GAME_X_OPT);
  WriteInt('Main Game Y',            Heroes.MAIN_GAME_Y_OPT);
  WriteInt('Main Game Full Screen',  Heroes.MAIN_GAME_FULL_SCREEN_OPT);
  WriteStr('AppPath',                Heroes.APP_PATH_OPT);
  WriteStr('CDDrive',                Heroes.CD_DRIVE_OPT);
  
  Ini.SaveIni(Heroes.GAME_SETTINGS_FILE);
END; // .PROCEDURE WriteGameSettings

FUNCTION Hook_GetHostByName (Context: Core.PHookHandlerArgs): LONGBOOL; STDCALL;
CONST
  NUM_ARGS  = 1;
  
  LOCAL_ADDR_0_MIN  = 10;
  LOCAL_ADDR_0_MAX  = 10 + (255 SHL 8) + (255 SHL 16) + (255 SHL 24);
  LOCAL_ADDR_1_MIN  = 172 + (16 SHL 8);
  LOCAL_ADDR_1_MAX  = 172 + (31 SHL 8) + (255 SHL 16) + (255 SHL 24);
  LOCAL_ADDR_2_MIN  = 192 + (168 SHL 8);
  LOCAL_ADDR_2_MAX  = 192 + (168 SHL 8) + (255 SHL 16) + (255 SHL 24);

TYPE
  PEndlessPIntArr = ^TEndlessPIntArr;
  TEndlessPIntArr = ARRAY [0..MAXLONGINT DIV 4 - 1] OF PINTEGER;
  
VAR
{U} HostEnt:  WinSock.PHostEnt;
{U} Addrs:    PEndlessPIntArr;
    i:        INTEGER;

  FUNCTION IsLocalAddr (Addr: INTEGER): BOOLEAN;
  TYPE
    TInt32 = PACKED ARRAY [0..3] OF BYTE;
  
  BEGIN
    RESULT  :=
      (TInt32(Addr)[0] = 10)  OR
      ((TInt32(Addr)[0] = 172) AND Math.InRange(TInt32(Addr)[1], 16, 31)) OR
      ((TInt32(Addr)[0] = 192) AND (TInt32(Addr)[1] = 168));
  END; // .FUNCTION IsLocalAddr
    
BEGIN
  {!} Windows.EnterCriticalSection(InetCriticalSection);
  
  RESULT :=  IsDefaultInetMode;
  
  IF NOT RESULT THEN BEGIN
    IsDefaultInetMode :=  TRUE;
    
    Context.EAX :=  Core.RecallAPI(Context, NUM_ARGS);
    HostEnt     :=  POINTER(Context.EAX);
    
    IF HostEnt.h_length = SIZEOF(INTEGER) THEN BEGIN
      Addrs :=  POINTER(HostEnt.h_addr_list);
      
      IF (Addrs[0] <> NIL) AND IsLocalAddr(Addrs[0]^) THEN BEGIN
        i :=  1;
        
        WHILE (Addrs[i] <> NIL) AND IsLocalAddr(Addrs[i]^) DO BEGIN
          INC(i);
        END; // .WHILE
        
        IF Addrs[i] <> NIL THEN BEGIN
          Utils.Exchange(Addrs[0]^, Addrs[i]^);
        END; // .IF
      END; // .IF
    END; // .IF
    
    Context.RetAddr :=  Core.Ret(NUM_ARGS);
    
    IsDefaultInetMode :=  FALSE;
  END; // .IF
  
  {!} Windows.LeaveCriticalSection(InetCriticalSection);
END; // .FUNCTION Hook_GetHostByName

PROCEDURE OnAfterWoG (Event: GameExt.PEvent); STDCALL;
CONST
  NOP7: STRING  = #$90#$90#$90#$90#$90#$90#$90;
  
VAR
  Zvslib1Handle:  INTEGER;
  Addr:           INTEGER;
  NewAddr:        POINTER;

BEGIN
  (* Ini handling *)
  Core.Hook(@Hook_ReadStrIni, Core.HOOKTYPE_JUMP, 5, ZvsReadStrIni);
  Core.Hook(@Hook_WriteStrIni, Core.HOOKTYPE_JUMP, 5, ZvsWriteStrIni);
  Core.Hook(@Hook_WriteIntIni, Core.HOOKTYPE_JUMP, 5, ZvsWriteIntIni);
  
  (* DL dialogs centering *)
  Core.Hook(@Hook_ZvsGetWindowWidth, Core.HOOKTYPE_BRIDGE, 5, Ptr($729C5A));
  Core.Hook(@Hook_ZvsGetWindowHeight, Core.HOOKTYPE_BRIDGE, 5, Ptr($729C6D));
  
  (* Mark the freshest savegame *)
  MarkFreshestSavegame;
  
  (* Fix multi-thread CPU problem *)
  Windows.SetProcessAffinityMask(Windows.GetCurrentProcess, 1);
  
  (* Fix HotSeat second hero name *)
  Core.Hook(@Hook_SetHotseatHeroName, Core.HOOKTYPE_BRIDGE, 6, Ptr($5125B0));
  Core.WriteAtCode(LENGTH(NOP7), POINTER(NOP7), Ptr($5125F9));
  
  (* Universal CPU patch *)
  Core.ApiHook
  (
    @Hook_PeekMessageA,
    Core.HOOKTYPE_BRIDGE,
    Windows.GetProcAddress(GetModuleHandle('user32.dll'), 'PeekMessageA')
  );
  
  (* Remove duplicate ResetErm call *)
  PINTEGER($7055BF)^ :=  INTEGER($90909090);
  PBYTE($7055C3)^    :=  $90;
  
  (* Optimize zvslib1.dll ini handling *)
  Zvslib1Handle   :=  Windows.GetModuleHandle('zvslib1.dll');
  Addr            :=  Zvslib1Handle + 1666469;
  Addr            :=  PINTEGER(Addr + PINTEGER(Addr)^ + 6)^;
  NewAddr         :=  @New_Zvslib_GetPrivateProfileStringA;
  Core.WriteAtCode(SIZEOF(NewAddr), @NewAddr, POINTER(Addr));
  
  (* Redirect reading/writing game settings to ini *)
  // No saving settings after reading them
  PBYTE($50B964)^     :=  $C3;
  PINTEGER($50B965)^  :=  INTEGER($90909090);
  
  PPOINTER($50B920)^  :=  Ptr(INTEGER(@ReadGameSettings) - $50B924);
  PPOINTER($50BA2F)^  :=  Ptr(INTEGER(@WriteGameSettings) - $50BA33);
  PPOINTER($50C371)^  :=  Ptr(INTEGER(@WriteGameSettings) - $50C375);
  
  (* Fix game version to enable map generator *)
  Heroes.GameVersion^ :=  Heroes.SOD_AND_AB;
  
  (* Fix gethostbyname function to return external IP address at first place *)
  Core.APIHook
  (
    @Hook_GetHostByName,
    Core.HOOKTYPE_BRIDGE,
    Windows.GetProcAddress(Windows.GetModuleHandle('ws2_32.dll'), 'gethostbyname')
  );
END; // .PROCEDURE OnAfterWoG

BEGIN
  Windows.InitializeCriticalSection(InetCriticalSection);
  IsDefaultInetMode :=  FALSE;
  
  GameExt.RegisterHandler(OnAfterWoG, 'OnAfterWoG');
END.
