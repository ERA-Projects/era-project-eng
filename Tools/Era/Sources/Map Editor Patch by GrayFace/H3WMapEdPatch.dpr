library H3WMapEdPatch;

{ $DEFINE Test}

uses
  SysUtils, Windows, RSQ, RSStrUtils, RSSysUtils, Messages, IniFiles, Types,
  Consts, ShellAPI, CommCtrl, Forms, Dialogs, Menus, Classes, Graphics,
  Controls, RSUtils, RSLang, Math, RSDebug, RSLod, CommDlg, RSCodeHook, Clipbrd,
  Common in 'Common.pas',
  NoThemes in 'NoThemes.pas',
  Utils in 'Utils.pas',
  Unit1 in 'Unit1.pas' {Form1},
  Unit2 in 'Unit2.pas' {Form2},
  Unit4 in 'Unit4.pas' {Form4},
  Unit5 in 'Unit5.pas' {Form5};

// (themes are too slow)(to enable themes we should also handle WM_THEMECHANGED)


{
!!! localization (see Black Phantom)
Сделать так, чтобы в русской версии информация о том, что объект не найдет
 выводилась на русском. Тоже самое касается фразы "Patch Version"

[+] Basic support for object packages.
[+] In case of missing DEF files a list of them is displayed.
[-] Map Editor doesn't consume 100% processor time anymore.
[-] Advanced Properties bug in objects placement. Now internal Map Editor routines are used.
[*] CRTRAIT0.TXT -> ZCRTRAITS.TXT
[*] crbanks.txt -> ZCRBANK.txt
[*] Disabled commanders in garrisons

Object Palettes, Отдельные объекты ZOebjts.txt:
- разбить объекты на мелкие категории
- сгруппировать в большие
- мелкие использовать, как основу для добавления новых объектов

Это, я ещё хотел предложить в новой версии сделать так, чтобы поиском можно было находить существ и артефакты WoG'А - сейчас можно только стандартных
Любые хинты: 48CCF5, 48090E  (Ещё, если можно сделать описание для объекта тип 53, подти 8 - шахта мифрила)
Добавление объекта по имени типа/подтипа?
Предупреждение в install.txt, что затрет ZEOBJTS.txt
Глюк с Undo при Expand Roads!! (и Single Squares)
Выделение фигурными скобками в Edit'ах, Ctrl+A в Edit'ах, возможно фичи RSMemo
Nearest Same(Equal?, similar?) Object
Объектные события ?
Tool Button ?
Transparent Background и Center в RSLodEdit ?
Напоминание про Ctrl+drag ?
Позиционные события ?
Поиск объектов ?
Я вот хотел спросить, можно ли в новой версии MapEdPatch сделать возможность поиска по WoG-монстрам и существам на карте - сейчас только по стандартным RoE,AB,SoD
 }

// 32322a

// Новая карта - диалог 159
//{$R *.res}
{$R H3WMapEdPatch.res}

// 167 - Rumors            610CDC  (414000 + 1fccdc) : 50810044 -> 50A11044
// 261 - Event Object      6156DC  (414000 + 2016dc) : 50811044 -> 50A11044
// 262 - Timed Event       6158BC  (2018bc)          : 50811044 -> 50A11044
// 161 - Map Description   610890  (1fc890)          : 50811044 -> 50A11044
// 202 - Seer              612280  (1fe280)          : 50811044 -> 50A11044
// 334 - Quest Guard       618EA4  (204ea4)          : 50811044 -> 50A11044
// 337 - ?
// 355 - ?

// 133 - Terrain
// 147 - Roads
// 150 - Rivers
// 156 - Eraser
// 347 - Obstacle Tool

{ TODO : 32800($8020) - ресурсы }

type
  TObjType = record
    Name:string;
    Typ:int;
  end;

  TMenuProc = procedure(Wnd:TRSWnd; Id:word; Param:Pointer);

  TMenuIt = record
    Name:string;
    ShortCut:Word;
    Hint:string;
    Command:string;
    Params:string;
    Dir:string;
    Proc:TMenuProc;
    ProcParam:pointer;
  end;

  PStr=^string;

const
  MStdCount=150;

var
  MaxMon: int;
  MonstersTables: array[0..2] of array of PChar; // Name, Plural, Features

const AStdCount=146; AStdAddCount=144; AListStdPtr=$59A2E0;

const DStdCount=80; DListStdPtr=$5851C0;

const BStdCount=7; BListStdPtr=$5A31F4;

var BankCount:integer=BStdCount;


var ObjTypeList:array of TObjType; // For random maps

const EWndNamePtr=PPChar($5A1E54);
var ELastH:integer;
    EWndName:string; ESizable:boolean;

const VerPtr:^PPtr=ptr($5A1200);

type
  TSpecWndProc = function(obj:Ptr; Wnd:TRSWnd; Msg:uint; wParam:int;
                                              lParam:int):LResult; stdcall;

var MenuTools:array of TMenuIt; MenuAdded:boolean;
    Menu:hmenu; MenuAccel:HACCEL;

type
  TCreateMainWndProc = procedure(Handle:TRSWnd); stdcall;
  TGlobalWndProc = function(obj:ptr; Handle:TRSWnd; Msg:DWord;
    wParam, lParam:int; Proc:TSpecWndProc; var Result:int):Bool; stdcall;

  TModule = record
    CreateMainWnd:TCreateMainWndProc;
    GlobalWndProc:TGlobalWndProc;
  end;

var Modules:array of TModule;

var ObjectSize:int=66;

var ToolbarAdded:boolean;

var MaxOnStart:boolean; Maximized:boolean;
    BackupMaps: Boolean;

var PlaceAnywhere:boolean;

type
  TTestBlock = record
    Start: int;
    Size: int;
    Ret: int;
  end;
  PTestBlock = ^TTestBlock;

var
  TestBlocks: array of TTestBlock;
  TestBitBlt: array of ptr;

procedure PatchPlaceAnywhere; forward;

var
  WasSaveAs: Boolean;
  MapVersionResult: int;


procedure ApplicationOnException(n1, n2:ptr; e: Exception);
var h:hwnd;
begin
  h:=GetForegroundWindow;
  OnException(true);
  SetForegroundWindow(h);
end;

procedure LoadOptions;
begin
  with TIniFile.Create(PatchPath+'Options.ini') do
    try
      MaxMon:= ReadInteger('General','Number of Monsters',MStdCount)-1;
      ArtCount:= ReadInteger('General','Number of Artifacts',AStdCount);
      DwellCount:= ReadInteger('General','Number of Dwellings',DStdCount);
      ELastH:= ReadInteger('Windows','Events Height',0);
      ESizable:= ReadBool('Windows','Events Resize',true);
      BackupMaps:= ReadBool('General', 'Backup Maps', false);
      ObjectSize:= ReadInteger('General','Object Size',ObjectSize);
      if DWord(ObjectSize)>127 then
        ObjectSize:=127
      else
        if ObjectSize=0 then ObjectSize:=66;
      MaxOnStart:= ReadBool('Windows','Maximize On Start',false);
      Form2.CanTrack:= ReadBool('Scripts', 'Autorefresh', true);
      Form2.RelativePath:= ReadBool('Scripts', 'Relative Path', true);
      PlaceAnywhere:= ReadBool('General', 'Place Objects Anywhere', false);
      if PlaceAnywhere then
        PatchPlaceAnywhere;
      Form4.RoadsAnywhere:= ReadBool('General', 'Roads And Rivers Anywhere', false);
      Form4.ButtonSingleSquares.Down:= ReadBool('General', 'Allow Single Squares', false);
      if Form4.ButtonSingleSquares.Down then
        Form4.ButtonSingleSquaresClick(nil);
    finally
      Free;
    end;
end;

procedure SaveOptions;
begin
  with TIniFile.Create(PatchPath+'Options.ini') do
    try
      if ELastH<>0 then WriteInteger('Windows','Events Height',ELastH);
      WriteBool('Windows','Maximize On Start',MaxOnStart);
      WriteBool('Scripts', 'Autorefresh', Form2.CanTrack);
      WriteBool('Scripts', 'Relative Path', Form2.RelativePath);
      WriteBool('General', 'Place Objects Anywhere', PlaceAnywhere);
      WriteBool('General', 'Roads And Rivers Anywhere', Form4.RoadsAnywhere);
      WriteBool('General', 'Allow Single Squares', Form4.ButtonSingleSquares.Down);
      WriteBool('General', 'Backup Maps', BackupMaps);
    finally
      Free;
    end;
end;

procedure LoadRunsFile(fileName:string);
var s, s1:string; h:DWord; i,j,k:int; ps1:TRSParsedString;
begin
  ps1:=nil;
  try
    s:=RSLoadTextFile(filename);
  except
    exit;
  end;

  ps1:=RSParseString(s, [#13#10]);
  j:=RSGetTokensCount(ps1,true);
  k:=length(Modules);
  for i:=0 to j-1 do
  begin
    try
      s1:=RSGetToken(ps1,i);
      if s1[1]=';' then continue;
      h:=LoadLibrary(ptr(s1));
      if h=0 then RaiseLastOSError;
      SetLength(Modules, k+1);
      with Modules[k] do
      begin
        CreateMainWnd:=GetProcAddress(h, 'MainWindowCreated');
        GlobalWndProc:=GetProcAddress(h, 'GlobalWndProc');
      end;
      inc(k);
    except
      on e:Exception do
      begin
        e.Message:=e.Message+#13#10+''''+RSGetToken(ps1,i)+'''';
        ShowException(e,nil);
      end;
    end;
  end;
end;

procedure LoadRuns;
begin
  LoadRunsFile(PatchPath+'RunDll.txt');
end;

procedure LoadRunOnce;
begin
  LoadRunsFile(PatchPath+'RunOnce.txt');
  DeleteFile(PChar(PatchPath+'RunOnce.txt'));
end;

procedure LoadBank;
var
  {U} Lod: RSLod.TRSLod;
  s:string; i,j,k:integer; ps1, ps2:TRSParsedString;

begin
  Lod :=  NIL;
  // * * * * * //
  ps1:=nil; ps2:=nil;

  if FileExists(AppPath + '\Data\ZCRBANK.TXT') then
    s:= RSLoadTextFile(AppPath + '\Data\ZCRBANK.TXT')
  else begin
    Lod :=  Unit1.Era.GetFileLod('zcrbank.txt');
    
    IF Lod = NIL THEN BEGIN
      EXIT;
    END; // .IF
    
    Lod.RawFiles.FindFile('ZCRBANK.TXT', i);
    s:= Lod.ExtractString(i);
  end;

  ps1:= RSParseString(s, [#13#10]);
  j:= RSGetTokensCount(ps1,true);
  k:= 11;
  i:= 46;
  while i<j do
  begin
    ps2:=RSParseToken(ps1,i,[#9]);
    if length(ps2)<29*2 then  break;
    //SetLength(BankList, k+1);
    PStr(@BankList[k])^:= RSGetToken(ps2,0);
    inc(k);
    inc(i, 4);
  end;
  //BankCount:= length(BankList);
end;

{
procedure LoadBank;
var s:string; i,j,k:integer; ps1, ps2:TRSParsedString;
begin
  ps1:=nil; ps2:=nil;
  SetLength(BankList, BStdCount);

  s:=RSLoadTextFile(PatchPath+'CrBanks.txt');

  ps1:=RSParseString(s, [#13#10]);
  j:=RSGetTokensCount(ps1,true);
  for i:=j-1 downto 1 do
  begin
    ps2:=RSParseToken(ps1,i,[#9]);
    if length(ps2)>=4 then
    begin
      k:=StrToInt(RSGetToken(ps2,0));
      if k>=length(BankList) then
        SetLength(BankList,k+1);
      PStr(@BankList[k])^:=RSGetToken(ps2,1);
    end;
  end;
  BankCount:=length(BankList);
end;
}

procedure PatchBank;
const
  p=PDWord($58DFE4);

  TablePtr:array[0..1] of DWord = ($48D497, $48D4D2);
  TableStdPtr:array[0..1] of DWord = ($5A31F4, $5A3210);

  PatchPtr1 = pointer($58DFFC);
  StdData1='crbanks.txt';
  NewData1='ZCRBANK.TXT';
var i:integer;
begin
  Assert(p^=BListStdPtr, SWrong);
  Assert(CompareMem(PatchPtr1, PChar(StdData1), length(StdData1)), SWrong);

  for i:=0 to high(TablePtr) do
    Assert(PDWord(TablePtr[i])^=TableStdPtr[i], SWrong);

  p^:=DWord(BankList);

  for i:=0 to high(TablePtr) do
    DoPatch4(ptr(TablePtr[i]), DWord(BankList)+TableStdPtr[i]-BListStdPtr);

  DoPatch(PatchPtr1, PChar(NewData1), length(NewData1));
end;

procedure DoLoadMenu(FileName:string);
var s,s1:string; i,j,k,m:integer; ps1, ps2:TRSParsedString;
begin
  ps1:=nil; ps2:=nil;
  k:=length(MenuTools);

  if not FileExists(PatchPath + FileName) then  exit;
  s:=RSLoadTextFile(PatchPath + FileName);

  ps1:=RSParseString(s, [#13#10]);
  j:=RSGetTokensCount(ps1,true);
  for i:=1 to j-1 do
  begin
    ps2:=RSParseToken(ps1,i,[#9]);
    if length(ps2)<8 then continue; // Comment line
    SetLength(MenuTools, k+1);
    with MenuTools[k] do
    begin
      if ps2[2]=ps2[3] then
        Name:=RSGetToken(ps2, 0)
      else
        Name:=RSGetTokens(ps2, 0, 2);
      s1:=RSGetToken(ps2, 1);
      if RSVal(s1, m) and (m=word(m)) then
        ShortCut:=m
      else
        ShortCut:=TextToShortCut(s1);
      Hint:=RSGetToken(ps2,2);
      Command:=RSGetToken(ps2,3);
      if length(ps2)>=10 then
        Params:=RSGetToken(ps2, 4);
      if (length(ps2)>=12) and (ps2[10]<>ps2[11]) then
        Dir:=RSGetToken(ps2,6)
      else
        if (Command<>'') and (Command[1]<>'-') then
        begin
          Dir:=ExtractFilePath(Command);
          Command:=ExtractFileName(Command);
        end;
      if Dir='' then
        Dir:=AppPath
      else
        Dir:=ExpandFileName(Dir);
    end;
    inc(k);
  end;
end;

procedure LoadMenu;
begin
  DoLoadMenu('WTMenu.txt');
  CopyFile(ptr(PatchPath + 'DefaultWTMenu.txt'),
           ptr(PatchPath + 'UserWTMenu.txt'), true);
  DoLoadMenu('UserWTMenu.txt');
end;

procedure MakeMonList;
const
  MListPtr=pointer($582298);
  MListStd=pointer($57DEA0);
var i:integer; p:PPointer;
begin
  p:=MListPtr;
  Assert(p^=MListStd, SWrong);
  SetLength(MonList,MaxMon+1);
  CopyMemory(pointer(MonList),p^,MStdCount*SizeOf(TMonRec));
  for i:=MStdCount to MaxMon do
  begin
    MonList[i].Town:=-1;
    MonList[i].Level:=7;
  end;
  p^:=pointer(MonList);

  for i:=0 to 2 do  SetLength(MonstersTables[i],MaxMon+1);
end;

procedure LoadMonsters;
var s:string; i,j:integer; ps1, ps2:TRSParsedString;
begin
  ps1:=nil; ps2:=nil;

  s:=RSLoadTextFile(PatchPath+'Monsters.txt');

  ps1:=RSParseString(s, [#13#10]);
  j:=RSGetTokensCount(ps1,true);
  for i:=1 to j-1 do
  begin
    ps2:=RSParseToken(ps1,i,[#9]);
    if length(ps2)>=6 then
      with MonList[StrToInt(RSGetToken(ps2,0))] do
      begin
        Town:=StrToInt(RSGetToken(ps2,1));
        Level:=StrToInt(RSGetToken(ps2,2));
      end;
  end;
end;

procedure PatchMonsters;
const
  CrTraitProgress:PByte=ptr($59BE7C);
  CrTraitStrPtr = ptr($582FFC);
  TablePtr = PDWord($40CAE0);
  TableStdPtr = $57DEA0;

  Places96:array[0..8] of DWord=($47E17C, $47E299, $47E38D,
    $47E3B6{, $48ED9D, $48EEC2}, $4976BB, $497759, $497F88, $49804F, $4B784E);
  Places95:array[0..3] of DWord=($40EF05, $47AA5F, $497567, $497D89);
{  Places1B:array[0..5] of DWord=($402D37, $40DE48, $41438C, $479802, $49F74E,
    $4A0C72);
}
  Place5=$40CA91;

  MTables:array[0..2] of DWord = ($40CB35, $40CB9A, $40CD2B);
  MTablesStd:array[0..2] of DWord = ($59B774, $59B9CC, $59BC24);

 // Release monsters hints
  PatchPtr1 = pointer($48CC81);
  StdData1:array[0..3] of byte=
    ($8B, $70, $14, // mov esi, [eax+14h]
     $90);          // nop
  NewData1:array[0..3] of byte=
    ($8B, $74, $06, $14); //mov esi, [eax+esi+14h]

 // Event, Pandora, Seer Task Add/Edit:Странная проверка, мешающая монстрам 8 ур
  PatchPtr2 = pointer($40E0E0);
  StdData2:array[0..1] of byte=($F7, $D8); // neg eax
  NewData2:array[0..1] of byte=($B0, $01); // mov esi, [eax+esi+14h]

 // Release monsters hints on map
  PatchPtr3 = pointer($488A9B);
  StdData3:array[0..2] of byte=($79, $14, $90);
  NewData3:array[0..2] of byte=($7C, $08, $14);

var i:integer;
begin
  Assert(TablePtr^=TableStdPtr, SWrong);
  //for i:=0 to high(places91) do
  //  Assert(PByte(places91[i])^=$91, SWrong);
  for i:=0 to high(places96) do
    Assert(pint(places96[i])^=$96, SWrong);
  for i:=0 to high(places95) do
    Assert(pint(places95[i])^=$95, SWrong);
{  for i:=0 to high(places1B) do
    Assert(PByte(places1B[i])^=$1B, SWrong);
}
  Assert(pint(place5)^=5, SWrong);
  for i:= 0 to high(MTables) do
    Assert(PDWord(MTables[i])^=MTablesStd[i], SWrong);

  Assert(CompareMem(PatchPtr1, @StdData1[0], SizeOf(StdData1)), SWrong);
  Assert(CompareMem(PatchPtr2, @StdData2[0], SizeOf(StdData2)), SWrong);
  Assert(CompareMem(PatchPtr3, @StdData3[0], SizeOf(StdData3)), SWrong);
{
  Assert(CompareMem(PatchPtr4, @StdData4[0], SizeOf(StdData4)), SWrong);
  Assert(CompareMem(PatchPtr5, @StdData5[0], SizeOf(StdData5)), SWrong);
  Assert(CompareMem(PatchPtr6, @StdData6[0], SizeOf(StdData6)), SWrong);
  Assert(CompareMem(PatchPtr7, @StdData7[0], SizeOf(StdData7)), SWrong);
  Assert(CompareMem(PatchPtr8, @StdData8[0], SizeOf(StdData8)), SWrong);
  Assert(CompareMem(PatchPtr9, @StdData9[0], SizeOf(StdData9)), SWrong);
}

  CrTraitProgress^:=$FF;
  DoPatch(CrTraitStrPtr, PChar('zcrtrait'), 8);

  DoPatch4(TablePtr, DWord(MonList));

  //for i:=0 to high(places91) do
  //  DoPatch1(PByte(places91[i]), MaxMon+1);

  for i:=0 to high(places96) do
    DoPatch4(ptr(places96[i]), MaxMon+1);

  for i:=0 to high(places95) do
    DoPatch4(ptr(places95[i]), MaxMon);

{  for i:=0 to high(places1B) do
    DoPatch1(ptr(places1B[i]), MaxMon+1+$1B-$91);
}

  DoPatch4(ptr(place5), MaxMon+1-MStdCount+5);

  for i:=0 to high(MTables) do
    DoPatch4(ptr(MTables[i]), DWord(@MonstersTables[i][0]));

  DoPatch(PatchPtr1,@NewData1[0],SizeOf(NewData1));
  DoPatch(PatchPtr2,@NewData2[0],SizeOf(NewData2));
  DoPatch(PatchPtr3,@NewData3[0],SizeOf(NewData3));
{
  DoPatch(PatchPtr4,@NewData4[0],SizeOf(NewData4));
  DoPatch(PatchPtr5,@NewData5[0],SizeOf(NewData5));
  DoPatch(PatchPtr6,@NewData6[0],SizeOf(NewData6));
  DoPatch(PatchPtr7,@NewData7[0],SizeOf(NewData7));
  DoPatch(PatchPtr8,@NewData8[0],SizeOf(NewData8));
  DoPatch(PatchPtr9,@NewData9[0],SizeOf(NewData9));
}
end;

{const
 // Seer's Task Edit monster
  MHookPtr1 = pointer($40FE3B);
  MHookPtr1Call:int = $40DC7C;
  MHookPtr1Ret = $40FE3F;
  MStdData1: array[0..3] of byte = ($3D, $DE, $FF, $FF);

 // Random Map
  MHookPtr2 = pointer($49A96E);
  MHookPtr2Ret = $49A974;
  MStdData2: array[0..5] of byte = ($55, $8B, $EC, $83, $EC, $14);
}

{
procedure MonstersHook2Proc(eax, edx, ecx:pptr);
var p:ptr;
begin
  inc(ecx, 2);
  CopyMemory(MonstersRndTable, ecx^, SizeOf(TMonsterRndTableItem)*MStdCount);
  ecx^:= MonstersRndTable;
end;

procedure MonstersHook2;
asm
   // StdData
  push ebp
  mov ebp, esp
  sub esp, 14h

  push ecx
  call MonstersHook2Proc
  pop ecx

  push MHookPtr2Ret
end;
{}

{
procedure MonstersHook2Proc(RndData:pptr);
begin
  inc(RndData, 3+2);
  if RndData^ <> ptr(MonstersRndTable) then
  begin
    CopyMemory(ptr(MonstersRndTable), RndData^, MStdCount*SizeOf(TMonsterRndTableItem));
    RndData^:= ptr(MonstersRndTable);
  end;
end;

procedure MonstersHook2;
asm
  push ecx
  mov eax, ebx
  call MonstersHook2Proc
  pop ecx

  push MHookPtr2Call
end;
}

procedure MonstersCountHook1;
asm
  cmp dword ptr [esi+68h], 2
  jl @std
  mov eax, MaxMon
  inc eax
  ret

@std:
  and eax, $1B
  add eax, $76
end;

procedure MonstersCountHook2;
asm
  mov edi, ebx
  cmp dword ptr [esi+118h], 2
  jl @std
  mov eax, MaxMon
  inc eax
  ret

@std:
  add eax, $76
end;

procedure MonstersCountHook3;
asm
  mov edi, ebp
  cmp dword ptr [esi+5Ch], 2
  jl @std
  mov eax, MaxMon
  inc eax
  ret

@std:
  add eax, $76
end;

procedure MonstersCountHook4;
asm
  cmp dword ptr [esi+60h], 2
  jl @std
  mov ebx, MaxMon
  inc ebx
  ret

@std:
  and ebx, $1B
  add ebx, $76
end;

procedure MonstersCountHook5;
asm
  cmp dword ptr [ecx+8], 2
  jl @std
  mov eax, MaxMon
  inc eax
  ret

@std:
  and eax, $1B
  add eax, $76
end;

procedure MonstersCountHook6;
asm
  cmp dword ptr [eax+8], 2
  jl @std
  mov ecx, MaxMon
  inc ecx
  ret

@std:
  and ecx, $1B
  add ecx, $76
end;

procedure HookMonsters;
const
  HooksList: array[1..10] of TRSHookInfo = (
    (p: $40E0F3; old: $40E130; new: $40E129; t: RShtJmp), // Seer's Task Bitset Set
    (p: $40E0C3; old: $CF8B; new: $C68B; t: RSht2), // Seer's Task Bitset Get: mov eax, esi
    (p: $40E0C5; old: $40E130; new: $40E0DA; t: RShtJmp), // Seer's Task Bitset Get
    (p: $402D35; newp: @MonstersCountHook1; t: RShtCall; size: 6), // Monsters count: and $1B
    (p: $40DE49; newp: @MonstersCountHook2; t: RShtCall), // Monsters count: and $1B
    (p: $41438D; newp: @MonstersCountHook3; t: RShtCall), // Monsters count: and $1B
    (p: $479800; newp: @MonstersCountHook4; t: RShtCall; size: 6), // Monsters count: and $1B
    (p: $49F74C; newp: @MonstersCountHook5; t: RShtCall; size: 6), // Monsters count: and $1B
    (p: $4A0C70; newp: @MonstersCountHook6; t: RShtCall; size: 6), // Monsters count: and $1B
    ()
  );

begin
  RSCheckHooks(HooksList);
  RSApplyHooks(HooksList);
//  Assert(CompareMem(pointer(MHookPtr1),@MStdData1[0],SizeOf(MStdData1)), SWrong);
//  Assert(CompareMem(pointer(MHookPtr2),@MStdData2[0],SizeOf(MStdData2)), SWrong);
//  Assert(CompareMem(pointer(MHookPtr3),@MStdData3[0],SizeOf(MStdData3)), SWrong);

//  CallHook(MHookPtr1, @MonstersHook1);
//  CallHook(MHookPtr2, @MonstersHook2);
//  DoHook(MHookPtr2, SizeOf(MStdData2), @MonstersHook2);
//  DoHook(MHookPtr3, SizeOf(MStdData3), @MonstersHook3);
end;

procedure MakeArtList;
const p=PDWord($57D7CC);
begin
  Assert(p^=AListStdPtr, SWrong);
  SetLength(ArtList,ArtCount);
  p^:=DWord(ArtList);
end;

procedure PatchArt;
const
  TablePtr: array[0..3] of DWord=($4036ED, $403896, $40385B, $403876);
  TableStdPtr: array[0..3] of DWord=($59A2E0, $59A2E0, $59A2FC, $59A2FD);

  Places90:array[0..13] of DWord = (
    $403B16, $404FC0, $404FE3, $40513B, $40515E,
    $40D587, $40D706, $40D72A, $413DE4, $46FFBC,
    $4793B5, $47AF8F, $48A11C, $4B804B // $4AEFB6 - Random maps
  );

  Places248:array[0..2] of DWord=( $40365F, $40369F, $403831);

{
 // Disable exception: Invalid bitset
  PatchPtr1 = pointer($403B59);
  StdData1:array[0..4] of byte=($B8, $40, $E2, $51, $00);
  NewData1:array[0..4] of byte=($C3, $90, $90, $90, $90); // ret; nop...
}

 // Release hint
  PatchPtr1 = pointer($48CC66);
  StdData1:array[0..2] of byte=($33, $F6, $90);
  NewData1:array[0..2] of byte=($8B, $76, $20);

 // Release hint on map
  PatchPtr2 = pointer($48E938);
  StdData2:array[0..2] of byte=($33, $C0, $90);
  NewData2:array[0..2] of byte=($8B, $40, $2C);

 // Don't display "-1" and "-2" in monster's reward
  PatchPtr3 = pointer($48A14D);
  StdData3:array[0..0] of byte=($0C);
  NewData3:array[0..0] of byte=($1C);

var i:integer;
begin
  for i:=0 to high(TablePtr) do
    Assert(PDWord(TablePtr[i])^=TableStdPtr[i], SWrong);

  for i:=0 to high(places90) do
    Assert(pint(places90[i])^=$90, SWrong);

  for i:=0 to high(places248) do
    Assert(pint(places248[i])^=$248, SWrong);

  Assert(CompareMem(PatchPtr1, @StdData1[0], SizeOf(StdData1)), SWrong);
  Assert(CompareMem(PatchPtr2, @StdData2[0], SizeOf(StdData2)), SWrong);
  Assert(CompareMem(PatchPtr3, @StdData3[0], SizeOf(StdData3)), SWrong);
{
  Assert(CompareMem(PatchPtr4, @StdData4[0], SizeOf(StdData4)), SWrong);
  Assert(CompareMem(PatchPtr5, @StdData5[0], SizeOf(StdData5)), SWrong);
  Assert(CompareMem(PatchPtr6, @StdData6[0], SizeOf(StdData6)), SWrong);
  Assert(CompareMem(PatchPtr7, @StdData7[0], SizeOf(StdData7)), SWrong);
  Assert(CompareMem(PatchPtr8, @StdData8[0], SizeOf(StdData8)), SWrong);
  Assert(CompareMem(PatchPtr9, @StdData9[0], SizeOf(StdData9)), SWrong);
}

  for i:=0 to high(TablePtr) do
    DoPatch4(ptr(TablePtr[i]), DWord(ArtList)+TableStdPtr[i]-AListStdPtr);

  for i:=0 to high(places90) do
    DoPatch4(ptr(places90[i]), ArtCount);

  for i:=0 to high(places248) do
    DoPatch4(ptr(places248[i]), (ArtCount+2)*4);

  DoPatch(PatchPtr1,@NewData1[0],SizeOf(NewData1));
  DoPatch(PatchPtr2,@NewData2[0],SizeOf(NewData2));
  DoPatch(PatchPtr3,@NewData3[0],SizeOf(NewData3));
{
  DoPatch(PatchPtr4,@NewData4[0],SizeOf(NewData4));
  DoPatch(PatchPtr5,@NewData5[0],SizeOf(NewData5));
  DoPatch(PatchPtr6,@NewData6[0],SizeOf(NewData6));
  DoPatch(PatchPtr7,@NewData7[0],SizeOf(NewData7));
  DoPatch(PatchPtr8,@NewData8[0],SizeOf(NewData8));
  DoPatch(PatchPtr9,@NewData9[0],SizeOf(NewData9));
}
end;

const
 // After loading artifacts
  AHookPtr1 = pointer($45C732);
  AHookPtr1Ret = $4B936C;
  AStdData1:array[0..3] of byte=($36, $CC, $05, $00);

procedure ArtHook1;
var a:TProcedure;
begin
  ArtList[141].CantAdd:=0; // Magic Wand
  ArtList[142].CantAdd:=0; // Gold Tower Arrow
  ArtList[143].CantAdd:=0; // Monster's Power

  ArtList[144].CantAdd:=1; // Highlighted Slot
  ArtList[145].CantAdd:=1; // Artifact Lock

  a:=pointer(AHookPtr1Ret);
  a;
//  TProcedure(AHookPtr1Ret);  Compiler crashes!
end;

procedure HookArt;
begin
  Assert(CompareMem(pointer(AHookPtr1),@AStdData1[0],SizeOf(AStdData1)), SWrong);

  CallHook(ptr(AHookPtr1), @ArtHook1);
end;

procedure MakeDwellList;
const p=PDWord($585450);
var i:integer;
begin
  Assert(p^=DListStdPtr, SWrong);
  SetLength(DwellList,DwellCount);
  for i:=0 to DwellCount-1 do
    DwellList[i].Unknown:=1;
  p^:=DWord(DwellList);
end;

procedure PatchDwell;
const
  TablePtr = $43DC7B;
  TableStdPtr = $5851C4;

  TableEndPtr = $43DCB1;
  TableEndStdPtr = $585444;

  Places140:array[0..0] of DWord=($43DC11);

 // Release hint
  PatchPtr1 = pointer($48CC51);
  StdData1:array[0..2] of byte=($70, $04, $90);
  NewData1:array[0..2] of byte=($74, $F0, $04);

 // Release hint on map
  PatchPtr2 = pointer($43DF4D);
  StdData2:array[0..1] of byte=($01, $90);
  NewData2:array[0..1] of byte=($04, $C1);

 // Unknown Slava's change
  PatchPtr3 = pointer($41D275);
  StdData3:array[0..2] of byte = ($52, $04, $90);
  NewData3:array[0..2] of byte = ($54, $CA, $04);

 // Unknown Slava's change
  PatchPtr4 = pointer($41D29B);
  StdData4:array[0..2] of byte = ($52, $04, $90);
  NewData4:array[0..2] of byte = ($54, $CA, $04);

 // ZCRGN0.txt -> ZCRGN1.txt
  PatchPtr5 = pointer($585471);
  StdData5:array[0..0] of byte = ($30);
  NewData5:array[0..0] of byte = ($31);

var i:integer;
begin
  Assert(PDWord(TablePtr)^=TableStdPtr, SWrong);

  Assert(PDWord(TableEndPtr)^=TableEndStdPtr, SWrong);

  for i:=0 to high(places140) do
    Assert(PDWord(places140[i])^=$140, SWrong);

  Assert(CompareMem(PatchPtr1, @StdData1[0], SizeOf(StdData1)), SWrong);
  Assert(CompareMem(PatchPtr2, @StdData2[0], SizeOf(StdData2)), SWrong);
  Assert(CompareMem(PatchPtr3, @StdData3[0], SizeOf(StdData3)), SWrong);
  Assert(CompareMem(PatchPtr4, @StdData4[0], SizeOf(StdData4)), SWrong);
  Assert(CompareMem(PatchPtr5, @StdData5[0], SizeOf(StdData5)), SWrong);
{
  Assert(CompareMem(PatchPtr6, @StdData6[0], SizeOf(StdData6)), SWrong);
  Assert(CompareMem(PatchPtr7, @StdData7[0], SizeOf(StdData7)), SWrong);
  Assert(CompareMem(PatchPtr8, @StdData8[0], SizeOf(StdData8)), SWrong);
  Assert(CompareMem(PatchPtr9, @StdData9[0], SizeOf(StdData9)), SWrong);
}

  DoPatch4(ptr(TablePtr), DWord(DwellList)+TableStdPtr-DListStdPtr);

  DoPatch4(ptr(TableEndPtr), DWord(DwellList) + TableEndStdPtr - DListStdPtr
                              + DWord(DwellCount-DStdCount)*8);

  for i:=0 to high(places140) do
    DoPatch4(ptr(places140[i]), DwellCount*4);

  DoPatch(PatchPtr1,@NewData1[0],SizeOf(NewData1));
  DoPatch(PatchPtr2,@NewData2[0],SizeOf(NewData2));
  DoPatch(PatchPtr3,@NewData3[0],SizeOf(NewData3));
  DoPatch(PatchPtr4,@NewData4[0],SizeOf(NewData4));
  DoPatch(PatchPtr5,@NewData5[0],SizeOf(NewData5));
{
  DoPatch(PatchPtr6,@NewData6[0],SizeOf(NewData6));
  DoPatch(PatchPtr7,@NewData7[0],SizeOf(NewData7));
  DoPatch(PatchPtr8,@NewData8[0],SizeOf(NewData8));
  DoPatch(PatchPtr9,@NewData9[0],SizeOf(NewData9));
}
end;

{------------------------------------------------------------------------------}
{ Additional Objects }

type
  TPaletteObj = record
    Str: string;
    Pos: int;
    Random: Boolean;
  end;

var
  ObjAddition: array of TPaletteObj;
  ObjRandomsCount: int;

const
  StdObjectsCount = 1559;

procedure LoadObjects;
const
  StdCount = StdObjectsCount;
var
  ObjList: array of TPaletteObj;
  ObjCounts: array[0..StdCount] of int;
  ps1, ps2: TRSParsedString;
  ss: string;
  i, j, n: int;
begin
  for i := 1 to StdCount do
    ObjCounts[i]:= 1;
  ObjCounts[0]:= 0;

  j:= StdCount;
  SetLength(ObjList, j);
  for i := 0 to StdCount - 1 do
    with ObjList[i] do
    begin
      Pos:= i + 1;
      Random:= true;
    end;

{}  with TRSFindFile.Create(PatchPath + 'Objects\*.txt') do
    try
      while FindAttributes(0, FILE_ATTRIBUTE_DIRECTORY) do
      begin
        ss:= RSLoadTextFile(FileName);
        ps1:= RSParseString(ss, [#13#10]);
        n:= RSGetTokensCount(ps1, true);
        Assert(n >= 2, 'Bad objects file: '#13#10 + FileName);
        Assert(RSGetToken(ps1, 0) = '1', 'Unsupported objects file version: '#13#10 + FileName);
        SetLength(ObjList, j + n - 2);
        for i := 2 to n - 1 do
        begin
          ps2:= RSParseToken(ps1, i, [#9]);
          n:= RSGetTokensCount(ps2, true);
          with ObjList[j] do
          begin
            Str:= RSGetToken(ps2, 0);
            if (n > 1) and RSVal(RSGetToken(ps2, 1), Pos) then
            begin
              dec(Pos, 2);
              Assert(Pos <= StdCount, 'Bad objects file: '#13#10 + FileName);
              if Pos < 0 then
                Pos:= 0;
            end else
              Pos:= StdCount;

            inc(ObjCounts[Pos]);

            if (n > 2) and (RSGetToken(ps2, 3) = '1') then
            begin
              Random:= true;
              inc(ObjRandomsCount);
            end;
          end;
          inc(j);
        end;
        FindNext;
      end;
    finally
      Free;
    end;
{}

  n:= 0;
  for i := 0 to StdCount do
  begin
    inc(n, ObjCounts[i]);
    ObjCounts[i]:= n;
  end;

  SetLength(ObjAddition, j);
  for i := j-1 downto 0 do
  begin
    j:= ObjList[i].Pos;
    n:= ObjCounts[j] - 1;
    ObjCounts[j]:= n;
    ObjAddition[n]:= ObjList[i];
    ObjList[i].Str:= '';
  end;
end;

var
  ObjAddIndex, ObjMaxPos: int;

function ObjectsCountProc(n: int; ret: int): int;
begin
  ObjMaxPos:= n;
  case ret of
    $492663: inc(n, length(ObjAddition) - StdObjectsCount);
    $49D78D: inc(n, ObjRandomsCount);
  end;
  ObjAddIndex:= -1;
  Result:= n;
end;

procedure ObjectsCountHook;
asm
  push [esp + 4]
  mov eax, $4E716C
  call eax
  pop ecx
  mov edx, [ebp + 4]
  call ObjectsCountProc
  ret
end;

function ObjectsTxtProc(var a: TPCharArray; ret: int): PChar;
var
  i, n: int; rand: Boolean;
begin
  Result:= nil;
  //exit;
  rand:= (ret = $49D78D);
  if not rand and (ret <> $492663) then  exit;

  n:= length(ObjAddition);
  i:= ObjAddIndex + 1;
  if rand then
    while (i < n) and not ObjAddition[i].Random do
      inc(i);

  ObjAddIndex:= i;

  if i >= n then
    Result:= a[i - n + StdObjectsCount + 1]
  else
    with ObjAddition[i] do
      if (Str = '') and (Pos <= ObjMaxPos) then
        Result:= a[Pos]
      else
        Result:= PChar(Str);
end;

procedure ObjectsTxtHook;
asm
  push ecx
  mov eax, [ebx + $20]
  mov edx, [ebp + 4]
  call ObjectsTxtProc
  pop ecx

  test eax, eax
  jz @docall
  mov [esp + 4], eax
@docall:
  push $490AAB
end;

{------------------------------------------------------------------------------}

procedure LoadRandom;
var s:string; i,j:integer; ps1, ps2:TRSParsedString;
begin
  ps1:=nil; ps2:=nil;

  s:=RSLoadTextFile(PatchPath+'Objects.txt');

  ps1:=RSParseString(s, [#13#10]);
  j:=RSGetTokensCount(ps1,true);
  for i:=1 to j-1 do
  begin
    ps2:=RSParseToken(ps1,i,[#9]);
    if RSGetTokensCount(ps2)>=2 then
    begin
      j:=length(ObjTypeList);
      SetLength(ObjTypeList,j+1);
      ObjTypeList[j].Name:=RSGetToken(ps2,0);
      ObjTypeList[j].Typ:=StrToInt(RSGetToken(ps2,1));
    end;
  end;
end;

{------------------------------------------------------------------------------}
{ HookRandom }

const
 // Load ZOBJTS.txt
  RHookPtr1 = pointer($492654);
  RHookPtr1Ret = $49265E;
  RStdData1:array[0..9] of byte=
    ($68, $6C, $E2, $58, $00, $B9, $B8, $33, $5A, $00);

 // Random map generation. Not used.
  RHookPtr2 = pointer($4ACF35);
  RHookPtr2Ret = $4ACF3B;
  RStdData2:array[0..5] of byte=
    ($55, $8B, $EC, $83, $EC, $10);

function ComparePChars(a,b:PChar):boolean;
begin
  Result:=true;
  if a=b then exit;
  if (a<>nil) and (b<>nil) then
    while a^=b^ do
    begin
      if a^=#0 then exit;
      inc(a);
      inc(b);
    end;
  Result:=false;
end;

procedure OnLoad; // After loading ZEObjts
begin
 // For Event
  SetString(EWndName,EWndNamePtr^,StrLen(EWndNamePtr^));

 // For version
  VerPtr^^:=@VerText[1];
  
  LoadBank;
end;

procedure RandomProc1(num:DWord);
begin
  OnLoad;
end;

procedure RandomHookAfter1;
asm
  mov eax, [esp-8]
  call RandomProc1
end;

procedure RandomHook1;
asm
  push offset RandomHookAfter1
  push $58E26C // StdData
  mov ecx, $5A33B8 // StdData

  push RHookPtr1Ret
end;

{
procedure RandomProc3(Count:int; var a: TPCharArray);
var
  props: TObjectProps;
  def: string;

  function CheckInObjList:Boolean;
  var j: int;
  begin
    Result:= true;
    for j:=0 to length(ObjTypeList)-1 do
      if (ObjTypeList[j].Name<>'') and (ObjTypeList[j].Name = def) and
         (ObjTypeList[j].Typ = props.Typ) then
        exit;
    Result:= false;
  end;

var
  p: PChar;
  i: int;
begin
  try
    SetLength(LastTypes, Count);
    for i := 1 to Count do
//    if a[i]^ <> ';' then
    begin
      p:= ReadBasicObjectProps(a[i], props, def);
      if (props.Typ = 54) and (props.SubTyp >= MStdCount) or CheckInObjList then
      begin
        LastTypes[i-1]:= props.Typ;
        while p^<>' ' do
        begin
          p^:= '0';
          inc(p);
        end;
      end;
    end;
  except
    RSShowException;
  end;

  ObjTypeList:= nil;
end;

procedure RandomHook3;
asm
  mov eax, $4E716C
  push [esp + 4]
  call eax
  push eax
  mov ecx, [ebx + $20]
  call RandomProc3
  pop eax
  ret 4
end;
}

function RandomProc3(var o:TObjectProps):Boolean;
var i:int;
begin
  Result:= false;
  if (o.Typ = 54) and (o.SubTyp >= MStdCount) then
    exit;
  for i:=0 to length(ObjTypeList)-1 do
    if (ObjTypeList[i].Typ = o.Typ) and (ObjTypeList[i].Name<>'') and
        ComparePChars(pointer(ObjTypeList[i].Name), PDefRec(ptr(DefList^ + o.Def*4)^).Str) then
      exit;
  Result:= true;
end;

procedure RandomHook3;
asm
  add eax, ebx
  call RandomProc3
  test eax, eax
  jz @exit // if it's zero, the jge in function will work trigger
  mov eax, $E8
@exit:
end;

procedure HookRandom;
begin
  Assert(CompareMem(pointer(RHookPtr1),@RStdData1[0],SizeOf(RStdData1)), SWrong);

  DoHook(RHookPtr1, SizeOf(RStdData1), @RandomHook1);
end;


{------------------------------------------------------------------------------}
{ HookWindowProc }


(*
Edit Timed Event:

#32770 - stretch
SysTabControl32 id=12320 - stretch

Button 1,2,9,(12321)


First #32770:

1268 - stretch

1643
1300-1307
1299
1298
1665
1327
1328
1666
1326

*)

const
   // Common WindowProc for all controls
  WHookPtr1 = pointer($501510);
  WHookPtr1Ret = $50127B;
  WStdData1: array[0..3] of byte=($67, $FD, $FF, $FF);

   // It disables my menu items
  WHookPtr2 = pointer($50489C);
  WHookPtr2Ret = $5048A2;
  WStdData2: array[0..5] of byte=($FF, $15, $38, $04, $53, $00);

   // Add my accelerators to the accelereators table
  WHookPtr3 = pointer($513775);
  WHookPtr3Ret = $51377B;
  WStdData3: array[0..5] of byte=($FF, $15, $84, $06, $53, $00);

   // Hook CreateWindowEx. Make Toolbars transparent
  WHookPtr4 = pointer($5304A8);

   // Hook SendMessage. (Not used)
  WHookPtr5 = pointer($53063C);

   // Hook TrackPopupMenu. Add "Advanced Properties" item.
  WHookPtr6 = pointer($530490);

   // Hook CreateDialogIndirectParam. (Not used)
  WHookPtr7 = pointer($5304F4);

   // Hook simple dialogs' creation. (Not used)
  WHookPtr8 = pointer($500BDA);
  WHookPtr8Ret = $50081C;
  WStdData8: array[0..3] of byte=($3E, $FC, $FF, $FF);

   // Hook other dialogs' creation. Detect "Edit Timed Event" dialog.
  WHookPtr9 = pointer($500814);
  WHookPtr9Ret = $50081C;
  WStdData9: array[0..3] of byte=($04, $00, $00, $00);

var EWnd:TRSWnd=nil; EDefW, EDefH:integer;
    EChild:TRSWnd; EGotWnds, EResize:boolean;
    EStrethWnd:array[0..3] of TRSWnd;
      // #32770, #32770(res), SysTabControl32, 1268(Edit)
    EMoveWnd:array[0..19] of TRSWnd;

//1327 1665

function EChildEnum(wnd:TRSWnd; void:int):Bool; stdcall;
const EMoveIds:array[0..19] of word=(1643,1300,1301,1302,1303,1304,1305,1306,
         1307,1299,1298,1665,1327,1328,1666,1326,1,2,9,12321);
var i,j:integer;
begin
  Result:=true;
  j:=Wnd.Id;
  if j=1268 then
  begin
    EStrethWnd[3]:=Wnd;
  end;
  for i:=0 to high(EMoveIds) do
    if EMoveIds[i]=j then
      EMoveWnd[i]:=Wnd;
end;

function EMainEnum(Wnd:TRSWnd; void:int):Bool; stdcall;
begin
  Result:=true;
  if (wnd.Id=12320) and (wnd.ClassName='SysTabControl32') then
    EStrethWnd[2]:=Wnd
  else
    EChildEnum(Wnd,0);
end;

procedure EResized(j:int);
var i:int; b:boolean;
begin
  b:=IsWindowVisible(hwnd(EChild));
  if b then ShowWindow(hwnd(EChild),SW_HIDE);
  if not EGotWnds then
  begin
    for i:=0 to high(EMoveWnd) do
      EMoveWnd[i]:=nil;
    for i:=2 to high(EStrethWnd) do
      EStrethWnd[i]:=nil;
    EnumChildWindows(hwnd(EWnd),@EMainEnum, 0);
    EnumChildWindows(hwnd(EChild),@EChildEnum, 0);
    EGotWnds:=true;

    Form2.Start(EStrethWnd[0], EStrethWnd[3]);
  end;

  for i:=0 to high(EMoveWnd) do
    if EMoveWnd[i]<>nil then
      with EMoveWnd[i].BoundsRect do
        EMoveWnd[i].BoundsRect:=Rect(Left,Top+j,Right,Bottom+j);
  for i:=0 to high(EStrethWnd) do
    if EStrethWnd[i]<>nil then
      with EStrethWnd[i].BoundsRect do
        EStrethWnd[i].BoundsRect:=Rect(Left,Top,Right,Bottom+j);
  if b then ShowWindow(hwnd(EChild),SW_SHOW);
end;

procedure EventWndProc(obj:Ptr; Wnd:TRSWnd; Msg:uint; wParam:int; lParam:int; var a:TSpecWndProc; var Result:LResult);
const WClass='#32770';
var j:int; r:PRect; r1:TRect;
begin
  try
    if EWnd<>nil then
      if Wnd=EWnd then
        case Msg of
          WM_COMMAND:
            case word(wparam) of
              1: Form2.CheckCreate;
              9: if Form2.ShowHelp then
                 begin
                   @a:=nil;
                   Result:=0;
                 end;
            end;
          //WM_NCDESTROY
          WM_DESTROY:
          begin
            EWnd:=nil;
            Form2.Stop;
          end;
          WM_NCLBUTTONDOWN:
            if ESizable and (wParam in [12..17]) then
              Wnd.Style:=Wnd.Style-WS_SYSMENU;
          WM_EXITSIZEMOVE:
            if ESizable then
            begin
              j:=Wnd.Style;
              if j and WS_SYSMENU =0 then
              begin
                Wnd.Style:=j+WS_SYSMENU;
                Wnd.BorderChanged;
              end;
            end;
          WM_SIZING:
          begin
            Result:=a(obj, Wnd, Msg, wParam, lParam);
            @a:=nil;
            r:=ptr(lParam);
            if wParam mod 3 = 1 then // Left
              r.Left:=r.Right-EDefW
            else
              r.Right:=r.Left+EDefW;
            if r.Bottom-r.Top<EDefH then
              if wParam div 3 = 1 then // Top
                r.Top:=r.Bottom-EDefH
              else
                r.Bottom:=r.Top+EDefH;
            with Wnd.AbsoluteRect do
              j:=r.Bottom-r.Top-ELastH;
            if j<>0 then EResized(j);
          end;
          WM_SHOWWINDOW:
          begin
            if EResize then
            begin
              EResize:=false;
              GetWindowRect(hwnd(Wnd),r1);
              SetWindowPos(hwnd(Wnd),0,r1.Left,r1.Top-(ELastH-EDefh) div 2,EDefW,ELastH,SWP_NOZORDER or SWP_NOACTIVATE);
              EResized(ELastH-EDefH);
            end;
//            EStrethWnd[3].Style:=EStrethWnd[3].Style+WS_VSCROLL;
            SetWindowPos(hwnd(EStrethWnd[3]),0,0,0,0,0,SWP_DRAWFRAME or SWP_FRAMECHANGED or SWP_NOZORDER or SWP_NOACTIVATE or SWP_NOMOVE or SWP_NOOWNERZORDER or SWP_NOSIZE or SWP_NOSENDCHANGING);
          end;

          WM_SIZE:
          begin
            with Wnd.AbsoluteRect do
              if EResize then
              begin
              end else
                ELastH:=Bottom-Top;
          end;
          WM_PARENTNOTIFY:
            if (loword(wParam)=WM_CREATE) and (HiWord(wParam)=0) and
               (TRSWnd(lParam).ClassName=WClass) then
            begin
              TRSWnd(lParam).Style:=TRSWnd(lParam).Style;
              if EChild=nil then
              begin
                EChild:=TRSWnd(lParam);
                EStrethWnd[0]:=EChild;
              end else
                EStrethWnd[1]:=TRSWnd(lParam);
            end;
        end
      else
    else
      if (Msg=WM_SIZE) and (Wnd.Text=EWndName) and (Wnd.ClassName=WClass) and
         (pint(obj)^=$5353A8) then
      begin
        // Towns' Timed Events' class = $5358D0
        EWnd:=Wnd;
        EChild:=nil;
        EGotWnds:=false;
        if ESizable then Wnd.Style:=Wnd.Style+WS_SIZEBOX;
        with Wnd.AbsoluteRect do
        begin
          EDefW:=Right-Left;
          EDefH:=Bottom-Top;
          //ELastH:=EDefH;
          if ELastH<EDefH then
          begin
            ELastH:=EDefH;
            EResize:=false;
          end else
            EResize:=true;
        end;
        EStrethWnd[0]:=nil;
        EStrethWnd[1]:=nil;
      end;

    if (Msg=WM_COMMAND) and (word(wParam)=CmdMapProps) then
      Form2.UpdateBindings;
  except
    OnException(false);
  end;
end;





procedure MenuProcEditObject(Wnd:hwnd);
begin
  Form1.Edit;
end;

procedure MenuProcSeparator;
begin
end;

procedure MenuProcBool(Wnd:hwnd; Id:word; var b:boolean);
var m:HMenu; i:DWord;
begin
  b:=not b;
  m:=GetMenu(Wnd);
  if b then i:=MF_CHECKED else i:=0;
  CheckMenuItem(m, Id, i);
end;

//var Izvrat:TProcedure = ptr($492654);

procedure MenuProcRun(Wnd:hwnd; Id:word; var It:TMenuIt);
var i:int;
begin
  with it do
    i:=ShellExecute(0, nil, ptr(Command), ptr(Params), ptr(Dir), SW_NORMAL);
  if i<=32 then
    RaiseLastOSError;
end;

procedure MenuProcAutoRefresh(Wnd:hwnd; Id:word);
var b:Boolean;
begin
  b:=Form2.CanTrack;
  MenuProcBool(Wnd, Id, b);
  Form2.CanTrack:=b;
end;

procedure MenuProcOpenScripts;
begin
  Form2.OpenAllScripts;
end;

procedure MenuProcUnbindAll;
begin
  Form2.UnbindAll;
end;

procedure MenuProcScriptsRelative(Wnd:hwnd; Id:word);
begin
  MenuProcBool(Wnd, Id, Form2.RelativePath);
  Form2.UpdateTracking;
end;

procedure MenuProcPlaceAnywhere(Wnd:hwnd; Id:word);
begin
  MenuProcBool(Wnd, Id, PlaceAnywhere);
  PatchPlaceAnywhere;
end;

{$IFDEF Test}

procedure MenuProcMemTest(Wnd:hwnd; Id:word);
var s,s1:string; i,j:int; p:int;
begin
  if not InputQuery('', '', s) then
  begin
    //msgh(EventsBlock);
    exit;
  end;
  if s[1]<>'$' then s:='$'+s;
  p:=StrToInt(s);
  s1:='';
  for i:=length(TestBlocks)-1 downto 0 do
  begin
    j:=TestBlocks[i].Start;
    if (j<=p) and (j+TestBlocks[i].Size>p) then
    begin
      s:='Test '+IntToHex(p,0)+' Alloc '+IntToHex(j, 0)+
                 ' Size '+IntToHex(TestBlocks[i].Size, 0)+
                 ' at '+IntToHex(TestBlocks[i].Ret, 0);
//      LogMessage(s);
      if s1='' then
        s1:=s;
    end;
  end;
  if s1='' then
    s1:='None'
  else
    Clipboard.AsText:=s1;
  msgz(s1);
end;

procedure MenuProcWndTest(Wnd:hwnd; Id:word);
var s:string; i:int; p:ptr;
begin
  if not InputQuery('', '', s) then
    exit;
  i:=StrToInt(s);
  p:=HwndToObj(i);
  msgh(p);
  Clipboard.AsText:=IntToHex(int(p), 0);
end;

function FindMemInfo(p:ptr):PTestBlock;
var i,j,k:int;
begin
  k:=int(p);
  for i:=length(TestBlocks)-1 downto 0 do
  begin
    j:=TestBlocks[i].Start;
    if (j<=k) and (j+TestBlocks[i].Size>k) then
//    if j=k then
    begin
      Result:=@TestBlocks[i];
      exit;
    end;
  end;
  Result:=nil;
end;

type
  TPtrArray = array of ptr;

var
  MemTraceBlocks: TPtrArray; MemTraceValues: array of int;
  TracesReport: string;

procedure CompareTraces(const Blocks: TPtrArray; Limit: int = 10; Start:string = #13#10);
var
  i,j:int; Mem:PTestBlock; MemSize:int; p:ptr;
  a: TPtrArray;
begin
  MemSize:=-1;
  for i:=0 to high(Blocks) do
  begin
    if int(Blocks[i])>high(word) then
      Mem:=FindMemInfo(Blocks[i])
    else
      Mem:=nil;

    if Mem <> nil then
    begin
      TracesReport:= TracesReport +
        Format('(Alloc %x Size %x at %x)  ', [Mem.Start, Mem.Size, Mem.Ret]);
      if MemSize=-1 then
        MemSize:=Mem.Size
      else
        if MemSize<>Mem.Size then
          MemSize:=0; // Check only mem blocks of constant size
    end else
    begin
      TracesReport:= TracesReport + Format('%x  ', [int(Blocks[i])]);
      MemSize:=0;
    end;
  end;

  if (MemSize<=0) or (Limit<=0) then  exit;

  Start:=Start+'  ';
  SetLength(a, length(Blocks));
  CopyMemory(ptr(a), ptr(Blocks), length(Blocks)*4);

 try

  if MemSize<=$1000 then
    for j:=0 to MemSize - 1 do
    begin

      for i:=0 to high(a) do
        a[i]:=pptr(PChar(Blocks[i])+j)^;

      i:=high(a);
      p:=a[i];
      dec(i);
      while (i>=0) and (a[i]=p) do  dec(i);
      if i<0 then continue; // Nothing changed

      i:=high(Blocks);
      while (i>=0) and (int(a[i])=MemTraceValues[i]) do  dec(i);
      if i<0 then
      begin
        TracesReport:=TracesReport + Start + IntToHex(j, 2) + '  ';
        for i:=0 to high(a) do
          TracesReport:= TracesReport + Format('%x  ', [int(a[i])]);
        TracesReport:= TracesReport + '(!!)';
      end else
        if j mod 4 = 0 then
        begin
          TracesReport:=TracesReport + Start + IntToHex(j, 2) + '  ';
          CompareTraces(a, Limit-1, Start);
        end;
    end
  else
   TracesReport:= TracesReport + '(Huge)';

 except
   TracesReport:= TracesReport + '(Deleted)';
 end;
end;

procedure MenuProcMemTraceTest(Wnd:hwnd; Id:word);
var s:string;
begin
  if not InputQuery('', '', s) then
    exit;

  SetLength(MemTraceBlocks, 1);
  MemTraceBlocks[0]:=MapProps.UndoBlock^;
  SetLength(MemTraceValues, 1);
  MemTraceValues[0]:=StrToInt(s);
end;

procedure MenuProcMemCompareTest(Wnd:hwnd; Id:word);
var s:string; i:int;
begin
  if not InputQuery('', '', s) then
    exit;

  i:=length(MemTraceBlocks);
  SetLength(MemTraceBlocks, i+1);
  MemTraceBlocks[i]:=MapProps.UndoBlock^;
  SetLength(MemTraceValues, i+1);
  MemTraceValues[i]:=StrToInt(s);

  TracesReport:=#13#10;
  CompareTraces(MemTraceBlocks);
  TracesReport:=TracesReport+#13#10;
  LogMessage(TracesReport);
end;

{
const InitEvents: procedure(New:ptr; Old:ptr) cdecl = ptr($4366BD);

procedure aaaa(Num:int);
var h:hwnd; i:int; tb:TTBBUTTON; bit:TTBADDBITMAP; b1, b2:TBitmap;
begin
  h:=FindWindowEx(hwnd(MainWindow), 0, 'AfxControlBar42s', 'Mode');
  h:=FindWindowEx(h, 0, 'ToolbarWindow32', 'Standard');

  i:=SendMessage(h, TB_ADDBITMAP, 1, int(@bit));
  if i=-1 then RaiseLastOSError;

  SendMessage(h, TB_GETBUTTON, Num, int(@tb));
  msgh(tb.dwData);
end;
}

procedure MenuProcMiscTest(Wnd:hwnd; Id:word);
var s:string; i,j:int; p, p1:pptr; ebl:PEventsBlock;
begin
  msghe(SizeOf(TObjectProps));
  //msghe(MapProps.UndoBlock);
  //msghe(MapProps.UndoList);

  exit;

  msghe(int(MainMap));
//  msghe(ToolbarPages.ObstacleBrush);
//  msghe(CurrentGroundBlock);
//  msgh(CurrentGroundBlock.ObjData.Positions);
  i:=MainMap.SelObj;
//  msghe(CurrentGroundBlock.ObjData.Positions[i].ZOrder);

//  s:=IntToHex(int(CurrentGroundBlock.ObjData.Positions[i].Obj.Obj), 0);

//  s:=IntToHex(int(CurrentGroundBlock.Data), 0);
//  s:=IntToHex(int(GetGroundPtr(CurrentGroundBlock, 0, 0)), 0);

//  s:= IntToStr(CurrentGroundBlock.ObjData.Positions[i].ZOrder);

{ ZLine map:
  s:='';
  for j:=0 to 5 do
  begin
    for i:=0 to 7 do
      with PGroundSquare(GetGroundPtr(CurrentGroundBlock, i, j))^ do
        if Objects<>nil then
          s:= s + IntToStr(pint(PChar(Objects.ListStart) + 4)^) + ' '
        else
          s:= s + '0 ';
    s:= s + #13#10;
  end;
{}

//  s:= IntToHex(int(MapProps.UndoBlock^.CountsBlock), 0);

//  MapProps.UndoBlock^.GroundBlock^[0]^.ObjData.Positions[i].Obj.Obj
//  Assert(FindMemInfo(MapProps.UndoBlock^.GroundBlock^[0]^.ObjData.Positions[i].Obj.Obj)<>nil);

//  s:=IntToHex(int(GroundBlock^[0]), 0)+'  '+IntToHex(int(GroundBlock^[1]), 0);

//  s:=IntToHex(int(MapProps.UndoBlock), 0) + ' ' + IntToHex(pint(EventsBlockBase+$48)^, 0);;
//  s:=IntToHex(int(GroundBlock^[0].Data), 0);

//  s:=IntToStr(MainMap.SelObj);

//  s:=IntToHex(int(MapProps.UndoBlock^), 0);

//  s:=IntToHex(int(MapProps.UndoBlock^.GroundBlock^[0]^.ObjData.Positions), 0);
//  s:=IntToHex(int(MapProps.UndoBlock^.GameData.EventsBlock.Unk1), 0);
//  s:=IntToHex(int(@ObjectPalette.PaletteInfos), 0);
//  s:=IntToHex(int(MapProps.UndoBlock^.GroundBlock^[0]^.ObjData.Positions[i].Obj.Obj), 0);
//  s:=IntToHex(pint(FindMemInfo(MapProps.UndoBlock^.GroundBlock^[0]^.ObjData.Positions[i].Obj.Obj).Start)^, 0);

//  s:=IntToHex(int(MapProps.UndoBlock^.GroundBlock^[0]^.ObjData.Positions[i].Obj.Obj.ClassPtr), 0);
//  s:=IntToHex(int(@MapProps.WasChanged), 0);

{
  // Class name
  p:=MapProps.UndoBlock^.GroundBlock^[0]^.ObjData.Positions[i].Obj.Obj.ClassPtr;
  dec(p);
  p:=p^;
  inc(p, 3);
  s:=PChar(p^)+8;
}

  msgze(s);
  exit;

{
  if not InputQuery('', '', s) then  exit;
  if s[1]<>'$' then s:='$'+s;
  p:= ptr(StrToInt(s));

  if not InputQuery('', '', s) then  exit;
  if s[1]<>'$' then s:='$'+s;
  p1:= ptr(StrToInt(s));

  if PChar(FindMemInfo(p)) < FindMemInfo(p1) then
    msgz('Первый раньше')
  else
    msgz('Второй раньше');
}

{
  p:=TestBitBlt[high(TestBitBlt)];
  msgh(p);
  Clipboard.AsText:=IntToHex(int(p), 0);
  exit;
}
//  p:=GroundBlock^[MainMap^.IsUnderground];
  {
  p:=GetGroundPtr(GroundBlock^[MainMap^.IsUnderground], 1, 1);
  msgh(p);
  Clipboard.AsText:=IntToHex(int(p), 0);
  exit;
  }
{
  pp:=EventsBlock;
  i:=__msize(pp);
  p1:=_malloc(i+$4c);
//  InitEvents(p1, pp);
  CopyMemory(p1, pp, i);
  CopyMemory(ptr(int(p1)+i), p1, $4c);
  EventsBlockPtr^:=p1;
  EventsBlockEndPtr^:=ptr(int(p1)+i+$4c);
  EventsBlockEndPtr1^:=ptr(int(p1)+i+$4c);
  exit;
}
{
  // Add event (dirty)
  ebl:=MapProps.UndoBlock^.GameData.EventsBlock;
  i:=int(ebl.EventsArrBufferEnd)-int(ebl.EventsArr);
  p:=_malloc(i+$4c);

  CopyMemory(p, ebl.EventsArr, i);
  ZeroMemory(ptr(int(p)+i), $4c);
  with PEventRec(int(p)+i)^ do
  begin
    NameUnk2:=$1F;
    MsgUnk2:=$1F;
  end;
  ebl.EventsArr:=ptr(p);
  ebl.EventsArrEnd:=ptr(int(p)+i+$4c);
  ebl.EventsArrBufferEnd:=ptr(int(p)+i+$4c);
  exit;
}

{
  if not InputQuery('', '', s) then
    exit;
  aaaa(StrToInt(s));
  exit;
}
  msghe(EventsBlockPtr);
end;

procedure MenuProcEfrit;
var
  j:int; p:PObjPos; s:string;
begin
  s:='';
  for j:=0 to 1 do
    if GroundBlock[j]<>nil then
      with GroundBlock^[j].ObjData^ do
      begin
        p:= ptr(Positions);
        inc(p);
        while PChar(p)<PositionsEnd do
        begin
          if p.Obj<>nil then
            with p.Obj.Obj.Data.Props do
              if Typ = 63 then
              begin
                s:=s+Format('%d %d %d SubType=%d'#13#10, [p.x, p.y, j, SubTyp]);
              end;
          inc(p);
        end;
      end;
  RSSaveTextFile(ChangeFileExt(MapProps.FileName, '_NewObj.txt'), s);
end;

{$ENDIF}

procedure DoAddMenu(m:hmenu);
label AfterCase;
const
  ToolsId=$100;
var i:integer; mi:TMenuItemInfo;
begin
  if m=0 then RaiseLastOSError;
  with mi do
  begin
    cbSize:=SizeOf(mi);
    fMask:=MIIM_ID or MIIM_TYPE or MIIM_SUBMENU;
    fType:=MFT_STRING;
    hSubMenu:=CreateMenu;
    wID:=ToolsId;
    dwTypeData:=ptr(SMenuWogTools);
  end;
  if not InsertMenuItem(m, 5, true, mi) then RaiseLastOSError;
  m:=mi.hSubMenu;
  if m=0 then RaiseLastOSError;
  Menu:=m;

  {$IFDEF Test}
  i:=length(MenuTools);
  SetLength(MenuTools, i+7);
  MenuTools[i].Command:='-';
  with MenuTools[i+1] do
  begin
    Name:='Mem Block Info';
    ptr(Params):=@MenuProcMemTest;
  end;
  with MenuTools[i+2] do
  begin
    Name:='Hwnd Info';
    ptr(Params):=@MenuProcWndTest;
  end;
  with MenuTools[i+3] do
  begin
    Name:='Mem Search';
    ptr(Params):=@MenuProcMemTraceTest;
  end;
  with MenuTools[i+4] do
  begin
    Name:='Mem Compare';
    ptr(Params):=@MenuProcMemCompareTest;
  end;
  with MenuTools[i+5] do
  begin
    Name:='Misc.';
    ptr(Params):=@MenuProcMiscTest;
  end;
  with MenuTools[i+6] do
  begin
    Name:='Efrit';
    ptr(Params):=@MenuProcEfrit;
  end;
  {$ENDIF}

  for i:=0 to high(MenuTools) do
    with mi, MenuTools[i] do
    begin
      fMask:=MIIM_ID or MIIM_TYPE or MIIM_STATE;
      wID:=ToolsId+1+i;
      fState:=0;
      dwTypeData:=ptr(Name);
      fType:=MFT_STRING;
// case
      if Command='-' then
      begin
        Proc:=@MenuProcSeparator;
        fType:=MFT_SEPARATOR;
        goto AfterCase;
      end;

      if Command='-AdvancedProps' then
      begin
        Proc:=@MenuProcEditObject;
        ProcParam:=nil;
        goto AfterCase;
      end;

      if Command='-MaxOnStart' then
      begin
        Proc:=@MenuProcBool;
        ProcParam:=@MaxOnStart;
        if MaxOnStart then
          fState:=MFS_CHECKED;
        goto AfterCase;
      end;

      if Command='-BackupMaps' then
      begin
        Proc:=@MenuProcBool;
        ProcParam:=@BackupMaps;
        if BackupMaps then
          fState:=MFS_CHECKED;
        goto AfterCase;
      end;

      if Command='-BindAutorefresh' then
      begin
        Proc:=@MenuProcAutoRefresh;
        if Form2.CanTrack then
          fState:=MFS_CHECKED;
        goto AfterCase;
      end;

      if Command='-OpenAllScripts' then
      begin
        Proc:=@MenuProcOpenScripts;
        goto AfterCase;
      end;

      if Command='-UnbindAll' then
      begin
        Proc:=@MenuProcUnbindAll;
        goto AfterCase;
      end;

      if Command='-BindRelativePath' then
      begin
        Proc:=@MenuProcScriptsRelative;
        if Form2.RelativePath then
          fState:=MFS_CHECKED;
        goto AfterCase;
      end;

      if Command='-ObjPlaceAnywhere' then
      begin
        Proc:=@MenuProcPlaceAnywhere;
        if PlaceAnywhere then
          fState:=MFS_CHECKED;
        goto AfterCase;
      end;

      {$IFDEF Test}
      if Command='' then
      begin
        Proc:=ptr(Params);
        ptr(Params):=nil;
        goto AfterCase;
      end;
      {$ENDIF}

      Proc:=@MenuProcRun;
      ProcParam:=@MenuTools[i];
AfterCase:
      if not InsertMenuItem(m, i+1, true, mi) then RaiseLastOSError;
    end;
end;

procedure MainWndProc(Obj:pptr; Wnd:TRSWnd; Msg:uint; wParam:int; lParam:int; var a:TSpecWndProc; var Result:LResult);
const
  MainWindowObj=PPtr($5A0D2C); // CWnd object
  StausBarClass='msctls_statusbar32';
  // FF   Advanced Props
  // 100  Menu
  MinId=$99;
  ToolsId=$100;
var w:hwnd; i:int; s:string;
begin
  try
    if (MinimapWindow=nil) and (Obj^=_TMiniMap) then
      with Form4 do
      begin
        MinimapWindow:= Wnd;
        ParentWindow:= GetParent(hwnd(Wnd));
        Top:= 0;
        Left:= 144;
        Show;
      end;

    if (Page6Window = nil) and (Obj^ = _TPage6) then
      Page6Window:= Wnd;

    if Obj^=_TToolbarPages then
      ToolbarPages:= ptr(Obj);

    if Obj^=_TObjectPalette then
      ObjectPalette:= ptr(Obj);

    if Obj^=_TMainMap then
      MainMap:= ptr(Obj);

    if Obj^=_TFullMap then
      FullMap:= ptr(Obj);

    if not MenuAdded then
    begin
      if Obj<>MainWindowObj^ then exit;
      MenuAdded:=true;
      MainWindow:=Wnd;
      DoAddMenu(GetMenu(hwnd(Wnd)));
      DrawMenuBar(hwnd(Wnd));
      for i:=0 to Length(Modules)-1 do
        with Modules[i] do
          try
            if @CreateMainWnd<>nil then
              CreateMainWnd(Wnd);
          except
            OnException(true);
          end;
    end else
    begin
      case Msg of
        WM_COMMAND:
          if (word(wParam)>=MinId) and
               (word(wParam)<=ToolsId+length(MenuTools)) then
          begin
            case word(wParam) of
              $99:
                MenuProcEditObject(hwnd(Wnd));
              else
                with MenuTools[word(wParam)-ToolsId-1] do
                  Proc(Wnd, word(wParam), ProcParam);
            end;
            Result:=0;
            @a:=nil;
          end else
            if word(wParam) = CmdHelp then
            begin
              s:=GetCurrentDir;
              SetCurrentDir(AppPath);
              Result:=a(Obj, Wnd, Msg, wParam, lParam);
              @a:=nil;
              SetCurrentDir(s);
            end else
            begin
              Result:=a(Obj, Wnd, Msg, wParam, lParam);
              @a:=nil;
              Form4.OnCommand(word(wParam));
            end;

        WM_MENUSELECT:
          if (word(wParam)>=MinId) and
             (word(wParam)<=ToolsId+length(MenuTools)) or (word(wParam)=5) then
          begin
            w:=FindWindowEx(hwnd(MainWindow), 0, StausBarClass, nil);
            if w<>0 then
              case word(wParam) of
                5:
                  TRSWnd(w).Text:='';
                $99: exit;
                  //TRSWnd(w).Text:=SHelpAdvProps;
                else
                  TRSWnd(w).Text:=MenuTools[word(wParam)-ToolsId-1].Hint;
              end;
            Result:=0;
            @a:=nil;
          end;
        WM_SHOWWINDOW:
          if (Wnd=MainWindow) and MaxOnStart and not Maximized then
          begin
            SendMessage(hwnd(Wnd), WM_SYSCOMMAND, SC_MAXIMIZE, 0);
            Maximized:=true;
          end;

        WM_MOUSEWHEEL:
        begin
          if ObjectPalette=nil then exit;
          w:=WindowFromPoint(Mouse.CursorPos);
          if (w=hwnd(ObjectPalette.Wnd)) and IsWindowEnabled(hwnd(MainWindow)) then
          begin
            @a:=nil;
            if wParam>0 then
              SendMessage(w, WM_VSCROLL, SB_LINEUP, 0)
            else
              SendMessage(w, WM_VSCROLL, SB_LINEDOWN, 0);
          end;
        end;
        WM_MBUTTONDOWN:
          if (ObjectPalette<>nil) and (Wnd=ObjectPalette.Wnd)
                                  and (@EnterReaderModeHelper<>nil) then
            EnterReaderModeHelper(hwnd(Wnd));

        WM_SIZE:
          if MinimapWindow<>nil then
            Form4.Left:=MinimapWindow.BoundsRect.Right;
      end;
    end;
  except
    OnException(true);
  end;
end;

var ToolbarWnd: hwnd;

procedure ToolbarWndProc(obj:Ptr; Wnd:TRSWnd; Msg:uint; wParam:int; lParam:int; var a:TSpecWndProc; var Result:LResult);
var h:hwnd; i:int; tb:TTBBUTTON; bit:TTBADDBITMAP; b1, b2:TBitmap;
begin
  if ToolbarAdded or (MainWindow=nil) then exit;
  ToolbarAdded:=true;
  h:=FindWindowEx(hwnd(MainWindow), 0, 'AfxControlBar42s', 'Mode');
  h:=FindWindowEx(h, 0, 'ToolbarWindow32', {'Mode'}'Standard');
  ToolbarWnd:=h;

//  WinLong(h, TBSTYLE_TRANSPARENT);

  b1:=TBitmap.Create;
  b1.LoadFromFile(AppPath+'Props.bmp');
  b1.PixelFormat:=pf32bit;
  b2:=TBitmap.Create;
  b2.Assign(b1);
  b2.Transparent:=true;
  b1.Canvas.Draw(0, 0, b2);
  with bit do
  begin
    hInst:=0;
    nID:=b1.Handle;
  end;

  i:=SendMessage(h, TB_ADDBITMAP, 1, int(@bit));
  if i=-1 then RaiseLastOSError;

//  i:=9;

  with tb do
  begin
    iBitmap:=i;
    idCommand:=$ff;
//    idCommand:=CmdProps;
    fsState:=TBSTATE_ENABLED;
    fsStyle:=TBSTYLE_BUTTON;
    iString:=5;
  end;
  SendMessage(h, TB_INSERTBUTTON, 13, int(@tb));
end;

{
procedure NTGWndProc(obj:pptr; Wnd:TRSWnd; Msg:uint; wParam:int; lParam:int; var a:TSpecWndProc; var Result:LResult);
begin
  if Obj^<>_TMapWnd then exit;
  case Msg of
    WM_LBUTTONDOWN:
    begin
      MapX:= loword(lParam) div 32 + GetScrollPos(hwnd(Wnd), SB_HORZ);
      MapY:= hiword(lParam) div 32 + GetScrollPos(hwnd(Wnd), SB_VERT);
      MapZ:= pbyte(int(Obj)+$50)^;
    end;
    WM_LBUTTONUP:
      if (GetKeyState(VK_MENU) and 128<>0) and FileExists(AppPath+'Maps\Agression.erm') then
      begin
        Form3:=TForm3.Create(Application);
        Form3.ParentWindow:=hwnd(MainWindow);
        Form3.ShowModal;
      end;
  end;
end;
}


procedure CopyMapWndProc(Obj:PMainMap; Wnd:TRSWnd; Msg:uint; wParam:int; lParam:int; var a:TSpecWndProc; var Result:LResult);
const
  MaxPos = 144*32;
  Zooms: array[0..2] of byte = (32, 16, 8);
var
  x, y:int;
begin
  if (Obj.ClassPtr<>_TMainMap) or (ToolbarPages.MainPage <> 6) or
                    (Form4.CopyMapMode in [cmmNone, cmmCopyRect]) then  exit;

  case Msg of
    WM_LBUTTONDOWN:
      a:= nil;
    WM_LBUTTONUP:
    begin
      a:= nil;
      Form4.TriggerCopyMap;
    end;
    WM_PAINT, WM_NCPAINT:
      if Form4.CopyStartX >= 0 then
      begin
        Result:= a(Obj, Wnd, Msg, wParam, lParam);
        a:= nil;
        with TCanvas.Create do
          try
            Handle:= GetDC(hwnd(MainMap.Wnd));
            Pen.Width:= 3 - MainMap.Zoom;
            Pen.Color:= clRed;
            y:= Zooms[MainMap.Zoom];
            x:= y*(Form4.CopyStartX - FullMap.ScrollBarX.Value);
            y:= y*(Form4.CopyStartY - FullMap.ScrollBarY.Value);
            if MainMap.Zoom <> 2 then
            begin
              inc(x);
              inc(y);
            end;
            MoveTo(MaxPos, y);
            LineTo(x, y);
            LineTo(x, MaxPos);
          finally
            ReleaseDC(hwnd(MainMap.Wnd), Handle);
            Free;
          end;
      end;
  end;
end;


function GetRoadConfig(v:int; InvertX:boolean):int;
const
  L = 8; U = 4; R = 2; D = 1;
var i:int;
begin
  i:= (v and MskRoadSubtype) shr ShRoadSubtype;
  case i of
    0..5:   i:=R+D;
    6..7:   i:=R+U+D;
    8..9:   i:=R+L+D;
    10..11: i:=U+D;
    12..13: i:=L+R;
    14:     i:=D;
    15:     i:=R;
    else {16}
            i:=L+R+U+D;
  end;
  if (v and MirRoadH <> 0) xor InvertX then
    i:= i and not (L+R) or (i and L) shr 2 or (i and R) shl 2;
  if v and MirRoadV <> 0 then
    i:= i and not (U+D) or (i and U) shr 2 or (i and D) shl 2;
  Result:=i;
  if v and MskRoadType = 0 then
    Result:=0;
end;

function ChangeRoad(x, y, z: int):Boolean;
const
  L = 8; U = 4; R = 2; D = 1;
  Segs: array[0..7] of byte = (15, 0, 12, 8, 0, 6, 8, 16);
  Rnd: array[0..7] of byte =  (1,  6,  2, 2, 6, 2, 2, 1);
  Mir: array[0..7] of byte =  (0,  0,  0, 0, 1, 0, 1, 0);

var i,j:int; v:pint;
begin
  Result:=false;
  v:= ptr(GetGroundPtr(GroundBlock^[z], x, y));
  i:=v^;
  if i and MskRoadType = 0 then
    exit;
  i:=GetRoadConfig(i, x>0);
  if i and L <> 0 then
    exit;
  j:=Mir[i]*MirRoadV;
  if x=0 then
    inc(j, MirRoadH);
  i:=Segs[i] + random(Rnd[i]);
  v^:= v^ and not MskRoadSubtype and not (MirRoadH or MirRoadV) or
       (i shl ShRoadSubtype) or j;
  Result:=true;     
end;

var
  LeftRoads: array[byte] of boolean;
  RightRoads: array[byte] of boolean;
  RoadLastX, RoadLastY: int;

procedure RoadWndProc(Obj:PMainMap; Wnd:TRSWnd; Msg:uint; wParam:int; lParam:int; var a:TSpecWndProc; var Result:LResult);
var x, y, Size:int; p:ptr; b:Boolean;
begin
  if (Obj.ClassPtr<>_TMainMap) or (ToolbarPages = nil) or
     (ToolbarPages.MainPage <> 3) or (ToolbarPages.RoadType = 0) then  exit;
  case Msg of
    WM_LBUTTONDOWN:
    begin
      p:=GroundBlock^[Obj.IsUnderground];
      Size:= MapSize;
      for y:=Size-1 downto 0 do
        LeftRoads[y]:= GetRoadConfig(GetGroundPtr(p, 0, y).Bits, false) and 8 <> 0;
      for y:=Size-1 downto 0 do
        RightRoads[y]:=GetRoadConfig(GetGroundPtr(p,Size-1,y).Bits, true) and 8 <>0;
      RoadLastX:=-1;  
    end;
    WM_MOUSEMOVE:
    begin
      if GetKeyState(VK_LBUTTON) >= 0 then  exit;
      Result:=a(Obj, Wnd, Msg, wParam, lParam);
      @a:=nil;
      x:= MainMap.SelX;
      y:= MainMap.SelY;
      Size:= MapSize;
      b:= (Form4<>nil) and Form4.ButtonExpandRoads.Down;
      if (x = RoadLastX) and (y = RoadLastY) then  exit;
      if (y>=0) and (y<Size) then
        if x=0 then
          LeftRoads[y]:= LeftRoads[y] or b
        else
          if x=Size-1 then
            RightRoads[y]:= RightRoads[y] or b;
      RoadLastX:=x;
      RoadLastY:=y;

      b:=false;
      for y:=0 to Size-1 do
        if LeftRoads[y] then
          b:= ChangeRoad(0, y, Obj.IsUnderground) or b;
      for y:=0 to Size-1 do
        if RightRoads[y] then
          b:= ChangeRoad(Size-1, y, Obj.IsUnderground) or b;
      if b then
        InvalidateMap;
    end;
  end;
end;


var
  OldMap: array[0..255, 0..255] of int;
  GroundStored: Boolean; MapLastBlock: ptr;
  LastScrollX, LastScrollY: int;

procedure GroundStore(Store:Boolean; Block:ptr = nil);
var
  x, y, Size:int; v:pint;
begin
  GroundStored:=Store;
  if Block = nil then
    Block:=GroundBlock^[MainMap.IsUnderground];
  Size:= MapSize;
  for y:=0 to Size-1 do
    for x:=0 to Size-1 do
    begin
      v:= ptr(GetGroundPtr(Block, x, y));
      if Store then
      begin
        OldMap[x,y]:=v^ and (MskGroundType or MskGroundSubtype);
        if v^ and MskGroundType >= 8 then
          v^:=v^ and not (MskGroundType or MskGroundSubtype) or
               21 shl ShGroundSubtype;
      end else
        v^:=v^ and not (MskGroundType or MskGroundSubtype) or OldMap[x,y];
  end;
end;

procedure RoadRiverWndProc(Obj:PMainMap; Wnd:TRSWnd; Msg:uint; wParam:int; lParam:int; var a:TSpecWndProc; var Result:LResult);
var x, y:int;
begin
  if (Obj.ClassPtr<>_TMainMap) or (ToolbarPages = nil) then  exit;
  if not Form4.RoadsAnywhere then  exit;

  case ToolbarPages.MainPage of
    2: if ToolbarPages.RiverType = 0 then  exit;
    3: if ToolbarPages.RoadType = 0 then  exit;
    else  exit;
  end;

  case Msg of
    WM_LBUTTONDOWN:
    begin
      MapLastBlock:=GroundBlock^[MainMap.IsUnderground];
      GroundStore(true, MapLastBlock);
      Result:=a(Obj, Wnd, Msg, wParam, lParam);
      @a:=nil;
    end;
    WM_LBUTTONUP:
    begin
      Result:=a(Obj, Wnd, Msg, wParam, lParam);
      @a:=nil;
      GroundStore(false, MapLastBlock);
      GroundStore(false);
      InvalidateMap;
      InvalidateMiniMap;
    end;
    WM_PAINT:
      if GroundStored then
      begin
        if GetKeyState(VK_LBUTTON) >= 0 then  exit;
        x:=FullMap.ScrollBarX.Value;
        y:=FullMap.ScrollBarY.Value;
        if (x<>LastScrollX) or (y<>LastScrollY) then
          InvalidateMap;
        LastScrollX:=x;
        LastScrollY:=y;
        GroundStore(false);
        Result:=a(Obj, Wnd, Msg, wParam, lParam);
        @a:=nil;
        GroundStore(true);
      end;
  end;
end;

procedure RoadRiverWndProc1(Obj:pptr; Wnd:TRSWnd; Msg:uint; wParam:int; lParam:int; var a:TSpecWndProc; var Result:LResult);
begin
  if (Obj^<>_TMiniMap) or (ToolbarPages = nil) or not Form4.RoadsAnywhere then
    exit;
  case ToolbarPages.MainPage of
    2: if ToolbarPages.RiverType = 0 then  exit;
    3: if ToolbarPages.RoadType = 0 then  exit;
    else  exit;
  end;

  case Msg of
    WM_PAINT:
      if GroundStored then
      begin
        if GetKeyState(VK_LBUTTON) >= 0 then  exit;
        //InvalidateMiniMap;
        GroundStore(false);
        Result:=a(Obj, Wnd, Msg, wParam, lParam);
        @a:=nil;
        GroundStore(true);
      end;
  end;
end;

procedure RoadRiverWndProc2(Obj:PMainMap; Wnd:TRSWnd; Msg:uint; wParam:int; lParam:int; var a:TSpecWndProc; var Result:LResult);
const
  Mask:int = MskRoadType or MskRoadSubtype or MskRiverType or MskRiverSubtype or
             MirRiverH or MirRiverV or MirRoadH or MirRoadV;
var x, y:int;
begin
  if (Obj.ClassPtr<>_TMainMap) or not Form4.RoadsAnywhere then  exit;
  if (ToolbarPages = nil) or (ToolbarPages.MainPage <> 1) then  exit;
  if ToolBarPages.GroundType < 8 then  exit;

  case Msg of
    WM_LBUTTONDOWN:
    begin
      MapStore(true, GroundBlock^[Obj.IsUnderground], SavedRoads, Mask);
      RoadLastX:=-1;
      if ToolBarPages.GroundBrush = 3 then  exit;

      Result:=a(Obj, Wnd, Msg, wParam, lParam);
      @a:=nil;

      MapStore(false, GroundBlock^[Obj.IsUnderground], SavedRoads, Mask);
    end;
    WM_MOUSEMOVE:
    begin
      if (GetKeyState(VK_LBUTTON) >= 0) or (ToolBarPages.GroundBrush = 3) then
        exit;

      Result:=a(Obj, Wnd, Msg, wParam, lParam);
      @a:=nil;

      x:= MainMap.SelX;
      y:= MainMap.SelY;
      if (x = RoadLastX) and (y = RoadLastY) then  exit;
      RoadLastX:=x;
      RoadLastY:=y;

      MapStore(false, GroundBlock^[Obj.IsUnderground], SavedRoads, Mask);
    end;
    WM_LBUTTONUP:
    begin
      Result:=a(Obj, Wnd, Msg, wParam, lParam);
      @a:=nil;

      MapStore(false, GroundBlock^[Obj.IsUnderground], SavedRoads, Mask);
    end;
  end;
end;

(*
function EditHookProc(Code, wParam:int; lParam:PMsg):int;
begin
  if Code < 0 then
  begin
    Result:= CallNextHookEx(EditHook, Code, wParam, int(lParam));
    exit;
  end;
  Result:=0;
  if (MenuEditHandle<>nil) and not EditMenuAdded then
  begin
    EditMenuAdded:=true;
    EditCode:=IntToStr(Code);
    {
    if IsBadReadPtr(lParam, SizeOf(TMsg)) then
      MenuHandle:='aaa';
    }
    {
    if IsMenu(lParam.hwnd) then
      MenuHandle:='YPA';
    }
    //MenuHandle:=IntToStr(GetMenu(lParam.hwnd));
  end else
    Result:= CallNextHookEx(EditHook, Code, wParam, int(lParam));
end;

procedure HookEdits;
begin
  if EditHook<>0 then  exit;
  EditHook:= SetWindowsHookEx(WH_MSGFILTER, @EditHookProc, 0, GetCurrentThreadId);
  Win32Check(EditHook<>0);
end;
*)
(*
var
  MenuEditHandle: TRSWnd;
  EditMenuAdded: Boolean;
  TrackPopupMenuExPtr: ptr;
  TrackPopupMenuExHooked: Boolean;
  TrackPopupMenuExData: array[0..5] of Byte;
  OldEditWndProc: ptr;
  EditHookReturnAddress: ptr;

function EditHookCmd(Cmd:int):int; stdcall;
begin
  if word(Cmd) = 100 then
  begin
    msgz('');
  end;
  Result:=Cmd;
end;

procedure UnhookEdits;
begin
  if not TrackPopupMenuExHooked then  exit;
  DoPatch(TrackPopupMenuExPtr, @TrackPopupMenuExData, 6);
  TrackPopupMenuExHooked:= false;
end;

procedure ExpandEditsMenu(Menu:HMENU; Wnd:HWnd);
var mi:TMenuItemInfo;
begin
  UnhookEdits;
  with mi do
  begin
    cbSize:=SizeOf(mi);
    fMask:=MIIM_ID or MIIM_TYPE;
    fType:=MFT_STRING;
    wID:=100;
    dwTypeData:=ptr(SEditHighlight);
  end;
  InsertMenuItem(Menu, 6, true, mi);
end;

procedure EditsHook1;
asm
  mov eax, [esp + 4]
  mov edx, [esp + 5*4]
  call ExpandEditsMenu
  mov eax, [esp + 8]
  or eax, TPM_RETURNCMD
  mov [esp + 8], eax
  pop EditHookReturnAddress
  call TrackPopupMenuExPtr
  call EditHookCmd
  push EditHookReturnAddress
end;

procedure HookEdits;
begin
  if TrackPopupMenuExPtr = nil then
    TrackPopupMenuExPtr:= GetProcAddress(GetModuleHandle('user32.dll'), 'TrackPopupMenuEx');
  CopyMemory(@TrackPopupMenuExData, TrackPopupMenuExPtr, 6);
  DoHook(TrackPopupMenuExPtr, 6, @EditsHook1);
  TrackPopupMenuExHooked:= true;
end;
*)

(*
procedure EditWndProc1(Obj:pptr; Wnd:TRSWnd; Msg:uint; wParam:int; lParam:int; var a:TSpecWndProc; var Result:LResult);
var i,j:int; p:TPoint;
begin
  if (Msg = WM_CHAR) and (wParam = ord(' ')) and
     (Wnd.ClassName = 'Edit') and (GetKeyState(VK_CONTROL) < 0) {and
     (SendMessage(hwnd(Wnd), EM_GETSEL, int(@i), int(@j)) <> -1) and (i<>j)} then
  begin
    @a:=nil;
    SendMessage(hwnd(Wnd), EM_GETSEL, int(@i), int(@j));
    if i=j then  exit;
{
    j:=SendMessage(hwnd(Wnd), EM_POSFROMCHAR, i, 0);
    if j=-1 then
      if i=0 then
        j:=0
      else
      begin
        j:=SendMessage(hwnd(Wnd), EM_POSFROMCHAR, i-1, 0);
      end;

    with p do
    begin
      X:=LoWord(j);
      Y:=HiWord(j);
      ClientToScreen(hwnd(Wnd), p);
      Form4.EditsPopupMenu1.Popup(X, Y);
    end;
}
    with Wnd.AbsoluteRect do
      Form4.EditsPopupMenu1.Popup(Left, Bottom);
  end;
end;

*)

procedure EditWndProc(Obj:pptr; Wnd:TRSWnd; Msg:uint; wParam:int; lParam:int; var a:TSpecWndProc; var Result:LResult);
begin
  if (Msg = WM_CHAR) and (wParam = 1{Ctrl+A}) and (Wnd.ClassName = 'Edit') then
  begin
    @a:=nil;
    PostMessage(hwnd(Wnd), EM_SETSEL, 0, -1);
    Result:=0;
  end;
end;


function EmptyProc(obj:Ptr; Wnd:TRSWnd; Msg:uint; wParam:int; lParam:int):LResult; stdcall;
begin
  Result:=0;
end;

function WindowHook1Proc(obj:Ptr; Wnd:TRSWnd; Msg:uint; wParam:int; lParam:int):LResult; stdcall;
var a:TSpecWndProc;
begin
  RSDebugHook; // Something spoils it...

//  if pptr(PPChar(obj)^ + $98)^ = nil then  exit;

  @a:=pointer(WHookPtr1Ret);
  Result:=0;

  EventWndProc(obj, Wnd, Msg, wParam, lParam, a, Result);
  if @a=nil then  a:=EmptyProc; //exit;
  MainWndProc(obj, Wnd, Msg, wParam, lParam, a, Result);
  if @a=nil then  a:=EmptyProc; //exit;
  CopyMapWndProc(obj, Wnd, Msg, wParam, lParam, a, Result);
  if @a=nil then  a:=EmptyProc; //exit;
  RoadWndProc(obj, Wnd, Msg, wParam, lParam, a, Result);
  if @a=nil then  a:=EmptyProc; //exit;
  RoadRiverWndProc(obj, Wnd, Msg, wParam, lParam, a, Result);
  if @a=nil then  a:=EmptyProc; //exit;
  RoadRiverWndProc1(obj, Wnd, Msg, wParam, lParam, a, Result);
  if @a=nil then  a:=EmptyProc; //exit;
  RoadRiverWndProc2(obj, Wnd, Msg, wParam, lParam, a, Result);
  if @a=nil then  a:=EmptyProc; //exit;
  EditWndProc(obj, Wnd, Msg, wParam, lParam, a, Result);
  {
  if @a=nil then  a:=EmptyProc; //exit;
  NTGWndProc(obj, Wnd, Msg, wParam, lParam, a, Result);
  }
  {
  if @a=nil then  a:=EmptyProc; //exit;
  ToolbarWndProc(obj, Wnd, Msg, wParam, lParam, a, Result);
  {}

  if @a=nil then exit;
  try
    Result:=a(obj, Wnd, Msg, wParam, lParam);
  except
    OnException(false);
  end;
end;

function WindowHook1(obj:Ptr; Wnd:TRSWnd; Msg:uint; wParam:int; lParam:int):LResult; stdcall;
var i:int;
begin
  try
    for i:=0 to Length(Modules)-1 do
      with Modules[i] do
        if (@GlobalWndProc<>nil) and
          Modules[i].GlobalWndProc(obj, Wnd, Msg, wParam, lParam,
                                   WindowHook1Proc, Result) then exit;
  except
    OnException(false);
  end;
  Result:=WindowHook1Proc(obj, Wnd, Msg, wParam, lParam);
end;

var EnableMenu:int;

function WindowHook2(AMenu:hmenu; P1, P2:uint):bool;
asm
  mov eax, Menu
  cmp eax, [esp]
  jz @Cancel
  mov eax, EnableMenu
  cmp eax, [esp]
  jnz @StdRet

@Cancel:
  mov eax, 1
  push WHookPtr2Ret
  ret 12

@StdRet:
  call EnableMenuItem
  push WHookPtr2Ret
end;

function MyLoadAccelerators(Inst:HInst; TableName:ptr):HAccel; stdcall;
const
  FirstId=$101;
var i,j:int; StdAccel:haccel; a:array of TAccel;
begin
  StdAccel:=LoadAccelerators(Inst, TableName);
  try
     // Redo
    SetLength(a, 1);
    a[0].key:=ord('Z');
    a[0].fVirt:=FVIRTKEY or FSHIFT or FCONTROL;
    a[0].cmd:=CmdRedo;
    j:=1;
     // WoG Tools
    for i:=0 to high(MenuTools) do
      with MenuTools[i] do
        if ShortCut<>0 then
        begin
          SetLength(a, j+1);
          a[j].key:=ShortCut and not (scShift or scCtrl or scAlt);
          a[j].fVirt:=FVIRTKEY;
          if ShortCut and scShift <>0 then a[j].fVirt:=a[j].fVirt or FSHIFT;
          if ShortCut and scCtrl <>0 then a[j].fVirt:=a[j].fVirt or FCONTROL;
          if ShortCut and scAlt <>0 then a[j].fVirt:=a[j].fVirt or FALT;
          a[j].cmd:=FirstId+i;
          inc(j);
        end;

    SetLength(a, j + CopyAcceleratorTable(StdAccel, nil^, 0));
    if CopyAcceleratorTable(StdAccel, a[j], length(a)-j)=0 then
      RaiseLastOSError;
    MenuAccel:=CreateAcceleratorTable(a[0], length(a));
    Result:=MenuAccel;
  except
    OnException(true);
    Result:=StdAccel;
  end;
end;

procedure WindowHook3;
asm
  push WHookPtr3Ret
  jmp MyLoadAccelerators
end;

{$IFDEF Themes}
function WindowHook4(dwExStyle: DWORD; lpClassName: PAnsiChar;
  lpWindowName: PAnsiChar; dwStyle: DWORD; X, Y, nWidth, nHeight: Integer;
  hWndParent: HWND; hMenu: HMENU; hInstance: HINST;
  lpParam: Pointer): HWND; stdcall;
begin
  Result := CreateWindowEx(dwExStyle, lpClassName, lpWindowName, dwStyle,
    X, Y, nWidth, nHeight, hWndParent, hMenu, hInstance, lpParam);
  if lpClassName='ToolbarWindow32' then
    WinLong(Result, TBSTYLE_TRANSPARENT);
end;
{$ENDIF}

function WindowHook5(Wnd: HWND; Msg: UINT; wParam: WPARAM;
  lParam: LPARAM): LRESULT; stdcall;
begin
  Result:=SendMessage(Wnd, Msg, wParam, lParam);
{
  if (Msg = CB_ADDSTRING) and (StrComp(PChar('-1'), PChar(lParam))=0) then
    zD;
}
end;

function WindowHook6(hMenu: HMENU; uFlags: UINT; x, y, nReserved: Integer;
  hWnd: HWND; prcRect: PRect): BOOL; stdcall;
var mi:TMenuItemInfo;
begin
  if MainMap.SelObj<>0 then
  begin
    FillChar(mi, SizeOf(mi), 0);
    with mi do
    begin
      cbSize:=SizeOf(mi);
      fMask:=MIIM_ID or MIIM_TYPE or MIIM_SUBMENU;
      fType:=MFT_STRING;
      wID:=$99;
      dwTypeData:=ptr(SMenuAdvProps);
    end;
    EnableMenu:=hMenu;
    if not InsertMenuItem(hMenu, 100, true, mi) then RaiseLastOSError;
  end;

  Result:=TrackPopupMenu(hMenu, uFlags, x, y, nReserved, hWnd, prcRect);
end;

function WindowHook7(hInst: HINST; const Template: TDlgTemplate;
  Parent: HWND; DialogFunc: TFNDlgProc; InitParam: LPARAM): HWND; stdcall;
begin
  Result:= CreateDialogIndirectParam(hInst, Template, Parent, DialogFunc,
    InitParam);
end;

function WindowProc8(eax:int; wnd:hwnd; Id:int):int;
const Child: array[0..1] of int = (1798, 1268);
{$IFDEF Themes}
var h:hwnd; r:TRect;
{$ENDIF}
begin
  Result:=eax;
{$IFDEF Themes}
  if Id<>202 then exit; // Seer's Hut
  if not ThemeServices.ThemesEnabled then exit;
  h:=GetDlgItem(wnd, 1841); // TabControl
  if h=0 then exit;
  GetClientRect(h, r);
  TabCtrl_AdjustRect(h, false, @r);
  CreateWindow('Static', '', SS_LEFT or WS_CHILD or WS_VISIBLE, r.Left, r.Top,
    r.Right-r.Left, r.Bottom-r.Top, h, 0, hInstance, nil);

  {
  for i:=0 to high(Child) do
  begin
    h1:=GetDlgItem(wnd, Child[i]);
    if h1=0 then continue;
    r:=TRSWnd(h1).AbsoluteRect;
    MapWindowPoints(0, h, r, 2);
    TRSWnd(h1).BoundsRect:=r;
    windows.SetParent(h1, h);
  end;
  }
{$ENDIF}
end;

procedure WindowHook8(a1, a2, a3:int); stdcall;
asm
  push ecx

  push a3
  push a2
  push a1
  mov edx, WHookPtr8Ret
  call edx

  pop ecx
  mov edx, [ecx+$1c] // Handle
  mov ecx, [ecx+$40] // Res Id (or 3C)
  call WindowProc8
end;

function WindowProc9(eax:int; wnd:hwnd; Id:int):int;
begin
  Result:=eax;
end;

procedure WindowHook9(a1, a2, a3:int); stdcall;
asm
  push ecx

  push a3
  push a2
  push a1
  mov edx, WHookPtr9Ret
  call edx

  pop ecx
  mov edx, [ecx+$1c] // Handle
  mov ecx, [ecx+$40] // Res Id (or 3C)
  call WindowProc9
end;

procedure HookWindowProc;
begin
  Assert(CompareMem(pointer(WHookPtr1),@WStdData1[0],SizeOf(WStdData1)),SWrong);
  Assert(CompareMem(pointer(WHookPtr2),@WStdData2[0],SizeOf(WStdData2)),SWrong);
  Assert(CompareMem(pointer(WHookPtr3),@WStdData3[0],SizeOf(WStdData3)),SWrong);
{$IFDEF Themes}
  Assert(CompareMem(pointer(WHookPtr8),@WStdData8[0],SizeOf(WStdData8)),SWrong);
{$ENDIF}
//  Assert(CompareMem(pointer(WHookPtr9),@WStdData9[0],SizeOf(WStdData9)),SWrong);

  CallHook(ptr(WHookPtr1), @WindowHook1);
  DoHook(WHookPtr2, SizeOf(WStdData2), @WindowHook2);
  DoHook(WHookPtr3, SizeOf(WStdData3), @WindowHook3);
//  DoPatch4(WHookPtr5, int(@WindowHook5));
  DoPatch4(WHookPtr6, int(@WindowHook6));
//  DoPatch4(WHookPtr7, int(@WindowHook7));
{$IFDEF Themes}
  DoPatch4(WHookPtr4, int(@WindowHook4));
  CallHook(WHookPtr8, @WindowHook8);
{$ENDIF}
//  CallHook(WHookPtr9, @WindowHook9);
end;

{------------------------------------------------------------------------------}
{ HookHelp }

function HelpProc1(t,st:int):int;
const
  CrBanks=$40000;
  Chests=$40100;
  Pyramid=$41000;
begin
  Result:= 0;
  case t of
    16:  if st>=11 then  Result:= CrBanks + st;
    63:  if st>0 then  Result:= Pyramid + st;
    101: if st>0 then  Result:= Chests + st;
  end;
end;

  // 46eea0 - Standing Monster
procedure HelpHook1;
const
  HHookPtr1Ret1 = $48B7C7;
  HHookPtr1Ret2 = $48B896;
asm
   //StdData
  shl ecx, 4
  mov ecx, [ecx+edx+8]

  push eax
  push ecx
  push edx
  mov edx, [eax+20h]
  mov eax, ecx
  call HelpProc1
  pop edx
  pop ecx
  test eax, eax
  jz @Default

  mov esi, eax
  pop eax
  push HHookPtr1Ret2
  ret

@Default:
  pop eax
  push HHookPtr1Ret1
end;

var
  ObjNames: array of string;

function HelpProc2(StdName:PChar; var Props:TObjectProps):PChar;
var i:int;
begin
  Result:= StdName;
  i:= Props.SubTyp;
  case Props.Typ of
    63: // Pyramid
    begin
      if i>=length(ObjNames) then  SetLength(ObjNames, i + 1);

      case i of
        0, 10..13:
          Result:= ptr(NewObjList[i]);
        else
        begin
          if ObjNames[i] = '' then
          begin
            if NewObjList[i] = '' then
              ObjNames[i]:= StdName
            else
              ObjNames[i]:= NewObjList[i];
              
            ObjNames[i]:= ObjNames[i] + ' (' + IntToStr(i) + ')';
          end;
          Result:= ptr(ObjNames[i]);
        end;
      end;
    end;

    101: // Chest
      if i<length(ChestsList) then
        Result:= ptr(ChestsList[i]);

  end;
end;

procedure HelpHook2;
const
  RetAddr = $48CCF4;
asm
   // Almost StadData
  mov eax, [eax+ecx+4]
  
  mov edx, esi
  call HelpProc2
  mov esi, eax
  push RetAddr
end;

procedure HelpHook3;
const
  RetAddr = $43CF6F;
asm
  lea edx, [eax + $C]

   // StdData
  mov eax, [eax + $28]
  mov esi, [ebp + 8]
  shl eax, 4
  push edi
  push 0

  mov eax, [eax+ecx+4]
  call HelpProc2
  mov edi, eax
  push RetAddr
end;

procedure HookHelp;
const
 // Choose Context Help topic
  HookPtr1 = pointer($48B7C0);
  StdData1: array[0..6] of byte = ($C1, $E1, $04, $8B, $4C, $11, $08);

 // Display hint for objects in object palette
  HookPtr2 = pointer($48CCAA);
  StdData2: array[0..5] of byte = ($8B, $74, $08, $04, $EB, $44);

 // Display hint for objects on map
  HookPtr3 = pointer($43CF5F);
  StdData3: array[0..5] of byte = ($8B, $40, $28, $8B, $75, $08);

begin
  Assert(CompareMem(pointer(HookPtr1),@StdData1[0],SizeOf(StdData1)), SWrong);
  Assert(CompareMem(pointer(HookPtr2),@StdData2[0],SizeOf(StdData2)), SWrong);
  Assert(CompareMem(pointer(HookPtr3),@StdData3[0],SizeOf(StdData3)), SWrong);

  DoHook(HookPtr1, SizeOf(StdData1), @HelpHook1);
  DoHook(HookPtr2, SizeOf(StdData2), @HelpHook2);
  DoHook(HookPtr3, SizeOf(StdData3), @HelpHook3);
end;

{------------------------------------------------------------------------------}
{ HookObjects }


{
function ObjectHook1(Param:int):int; stdcall;
  type
    TMyProc = function(Param:int):int; stdcall;
  const
    DestProc:TMyProc = ptr($42B259);

begin
  Result:=DestProc(Param);
  if ObjectEditing then
    Form1.Edit(PPObjectData(Result+4)^^);
end;
}

function ObjectHook2(d1, d2, d3:int; w:word):int; stdcall;
begin
  Result:=0;
  Form1.NoStdProps;
  if Form1.HandleAllocated then exit;
  MenuProcEditObject(MenuWindow);
end;

procedure ObjectHook3;
asm
  and ecx, edi
  push ecx
  mov ecx, eax
  push $4809CA
  cmp SavingAdvancedProps, 0
  mov eax, Form1
  jnz TForm1.StoreProps
  jmp [edx]
end;

procedure HookObjects;
const
   // Show object editor instead of "What's this" help.
   // Can be used for Objects Palette too.
  HookPtr1 = ptr($46EE95);
  StdData1:array[0..3] of byte = ($C0, $C3, $FB, $FF);

   // Show object editor for objects without properties
  HookPtr2 = ptr($53FB84);
  StdData2:array[0..3] of byte = ($14, $13, $48, $00);

   // Hook the Properties to change Advanced Properties the right way
  HookPtr3 = ptr($4809C3);
  StdData3:array[0..6] of byte = ($23, $CF, $51, $8B, $C8, $FF, $12);

begin
//  Assert(CompareMem(HookPtr1, @StdData1[0], SizeOf(StdData1)), SWrong);
  Assert(CompareMem(HookPtr2, @StdData2[0], SizeOf(StdData2)), SWrong);
  Assert(CompareMem(HookPtr3, @StdData3[0], SizeOf(StdData3)), SWrong);

//  CallHook(HookPtr1, @ObjectHook1);
  DoPatch4(HookPtr2, int(@ObjectHook2));
  DoHook(HookPtr3, SizeOf(StdData3), @ObjectHook3);
end;


{
const
 // Here the main window is created
  MWHookPtr1 = PDWord($45C879);
  MWHookPtr1Ret = $51A9F4;
  MWStdData1 = $000be177;

procedure OnMainWindowCreate(a,d,c:int);
begin

end;

procedure MainWindowHook;
asm
  call [MWHookPtr1Ret]
  push eax
  push ecx
  push edx
  call MainWindowProc
  pop edx
  pop ecx
  pop edx
end;

procedure HookMenu;
begin
  Assert(MWHookPtr1^=MWStdData1, SWrong);

  CallHook(ptr(MWHookPtr1), @OnMainWindowCreate);
end;
}

{
  // Don't work

procedure ObjectProc1(ObjectData:ptr);
begin
  msgh(int(ObjectData)+$7c);
end;

  // ObjectEdit:=true; SendMessage(WM_COPY);
  // CallHooks: 46DE45, 46DE6A
procedure ObjectHook1;
asm
  cmp ObjectEdit, 0
  jnz @mine
  push $46C128 // Go to standard reaction
  ret

@mine:
    // Get object properties ptr
  mov     al, [ecx+$50]
  xor     edx, edx
  cmp     al, 0
  setnz   dl
  mov     eax, [ecx+$48]
  mov     eax, [eax]
  mov     eax, [eax+$1C]
  lea     eax, [eax+edx*4]

  call    ObjectProc1
  mov eax, 1
end;

procedure HookObjects;
begin
  CallHook(ptr($46DE45), @ObjectHook1);
  CallHook(ptr($46DE6A), @ObjectHook1);
  //ObjectEdit:=true;
end;
}

{------------------------------------------------------------------------------}
{ HookOther }

var
  SavedPath: string;

function OtherHook1Proc(var OpenFile: TOpenFilename; Proc:ptr):Bool;
type
  TOpenFileNameProc = function(var OpenFile: TOpenFilename): Bool; stdcall;
begin
  if (MapProps.FileName<>nil) and (MapProps.FileName^<>#0) then
    SavedPath:= ExtractFilePath(MapProps.FileName)
  else
    if SavedPath = '' then
      SavedPath:= AppPath + 'Maps';

  OpenFile.lpstrInitialDir:= ptr(SavedPath);
  Result:= TOpenFileNameProc(Proc)(OpenFile);
  if Result then
    SavedPath:= ExtractFilePath(OpenFile.lpstrFile);
end;

function OtherHook1(var OpenFile: TOpenFilename): Bool; stdcall;
begin
  Result:= OtherHook1Proc(OpenFile, @GetOpenFileName);
end;

function OtherHook2(var OpenFile: TOpenFilename): Bool; stdcall;
begin
  if MapProps.UndoBlock^.GameVersion = 2 then
  begin
    OpenFile.lpstrFilter:= ptr(SSaveMapFilter);
    if (GameVersions[2] = $1C) and WasSaveAs then
      OpenFile.nFilterIndex:= 2;
      
    Result:= OtherHook1Proc(OpenFile, @GetSaveFileName);
    if Result then
    begin
      WasSaveAs:= true;
      if OpenFile.nFilterIndex = 2 then
        GameVersions[2]:= $1C
      else
        GameVersions[2]:= $33;
    end;
  end else
    Result:= OtherHook1Proc(OpenFile, @GetSaveFileName);
end;

procedure HookOther;
const
 // GetOpenFilename
  HookPtr1 = pointer($5306FC);

 // GetSaveFileName
  HookPtr2 = pointer($530704);
begin
  DoPatch4(HookPtr1, int(@OtherHook1));
  DoPatch4(HookPtr2, int(@OtherHook2));
end;

{------------------------------------------------------------------------------}
{ HookTest }

const
   // Memory allocation
  THookPtr1 = pointer($4E8159);
  THookPtr1Ret = $4E8160;
  TStdData1:array[0..3] of byte=(3, 0, 0, 0);

   // BitBlt call
  THookPtr2 = pptr($530070);

var
  TestRet:int;

procedure AddTestBlock(AStart, ASize, ARet:int);
var i:int;
begin
  i:=length(TestBlocks);
  SetLength(TestBlocks, i+1);
  with TestBlocks[i] do
  begin
    Start:=AStart;
    Size:=ASize;
    Ret:=ARet;
  end;
end;

function TestProc1(size, unk:int):int; cdecl;
type
  TProc = function(size, unk:int):int; cdecl;
const
  TestAddr = $13E8AA4;
  LogRet = $11;
begin
  Result:=TProc(THookPtr1Ret)(size, unk);
  AddTestBlock(Result, size, TestRet);

  if TestRet = LogRet then
    LogMessage('Thats it: '+IntToHex(LogRet - RSValidCallSite(ptr(LogRet)), 0));

{
  if (Result<=TestAddr) and (Result+size>TestAddr) then
    try
      raise Exception.Create('Test '+IntToHex(Result,0)
                            +' at '+IntToHex(TestRet,0));
    except
      MakeLog(1);
//      OnException(true);
    end;
{}
end;

procedure TestHook1;
asm
  mov eax, [esp+12]
  mov eax, [esp+12+4*4]
  mov TestRet, eax
  jmp TestProc1
end;

procedure TestProc2(Caller:ptr);
var i:int;
begin
  if Caller=ptr($48802A) then exit;
  if Caller=ptr($46B1AD) then exit;
  if Caller=ptr($46EB44) then exit;
  if Caller=ptr($48802A) then exit;
  i:=length(TestBitBlt);
  SetLength(TestBitBlt, i+1);
  TestBitBlt[i]:=Caller;
end;

var LastBitBlt:ptr;

procedure TestHook2;
asm
  mov eax, [esp]
  call TestProc2
  push LastBitBlt
end;

procedure HookTest;
begin
  Assert(CompareMem(ptr(THookPtr1), @TStdData1[0], SizeOf(TStdData1)), SWrong);

  CallHook(ptr(THookPtr1), @TestHook1);
{
  LastBitBlt:=THookPtr2^;
  THookPtr2^:=@TestHook2;
}  
end;

{------------------------------------------------------------------------------}
{ LoadNewObjects }

procedure LoadNewObjFile(const Name:string; var List:TMyStringArray);
var s, s1:string; i,j,k:integer; ps1, ps2:TRSParsedString;
begin
  ps1:=nil; ps2:=nil;

  s:=RSLoadTextFile(PatchPath + Name);

  ps1:=RSParseString(s, [#13#10]);
  k:=0;
  j:=RSGetTokensCount(ps1);
  for i:=0 to j-1 do
  begin
    ps2:= RSParseToken(ps1,i,[#9]);
    s1:= RSGetToken(ps2, 0);
    if (s1<>'') and (s1[1]=';') then   continue;
    SetLength(List, k+1);
    List[k]:= s1;
    inc(k);
  end;
end;

procedure LoadNewObjects;
begin
  LoadNewObjFile('NewObj.txt', NewObjList);
  LoadNewObjFile('Chests.txt', ChestsList);
end;

{------------------------------------------------------------------------------}
{ HookEvents }



(*  //Старый способ

var BadEventsCall:boolean;

procedure EventsHook1;
const RetAddr=$4E66C0;
asm
   // Вроде cdecl, но лучше перестраховаться
  cmp BadEventsCall, 0
  jnz @exit
  cmp ecx, [esp+4]
  jnz @exit
  mov EventsBlockSize, ecx
  mov ecx, [esp+8]
  mov EventsBlock, ecx
  mov ecx, [esp+4]
@exit:
  push RetAddr
end;

procedure EventsHook2;
const RetAddr=$42C4F6;
asm
  mov EventsBlock, 0
  push RetAddr
end;

var EventsHook3Ret:int = $478A2B;

procedure EventsHook3;
asm
  mov BadEventsCall, 1
  push [esp+4]
  call EventsHook3Ret
  mov BadEventsCall, 0
  ret 4
end;

procedure EventsHook4;
const RetAddr=$45F191;
asm
  mov EventsBlock, 0
  push RetAddr
end;

procedure HookEvents;
const
   // Get Events' block address. Not called on load map with 0 events or new.
  HookPtr1 = ptr($4366C3);
  StdData1 : array[0..3] of byte = ($F9, $FF, $0A, $00);

   // Load Map. Set events' block to 0.
  HookPtr2 = ptr($41F72A);
  StdData2 : array[0..3] of byte = ($C8, $CD, $00, $00);

   // On Add Event. 4366C3 is called, but we shouldn't react it.
  HookPtr3 = ptr($4783F0);
  StdData3 : array[0..3] of byte = ($37, $06, $00, $00);

   // New Map. Set events' block to 0.
  HookPtr4 = ptr($460AED);
  StdData4 : array[0..3] of byte = ($A0, $E6, $FF, $FF);
begin
  Assert(CompareMem(HookPtr1, @StdData1[0], SizeOf(StdData1)), SWrong);
  Assert(CompareMem(HookPtr2, @StdData2[0], SizeOf(StdData2)), SWrong);
  Assert(CompareMem(HookPtr3, @StdData3[0], SizeOf(StdData3)), SWrong);
  Assert(CompareMem(HookPtr4, @StdData4[0], SizeOf(StdData4)), SWrong);

  CallHook(HookPtr1, @EventsHook1);
  CallHook(HookPtr2, @EventsHook2);
  CallHook(HookPtr3, @EventsHook3);
  CallHook(HookPtr4, @EventsHook4);
end;

*)


procedure EventsHook1;
const RetAddr=$4E66C0;
asm
   // Вроде cdecl, но лучше перестраховаться
  cmp ecx, $1000
  ja @exit
  xchg ecx, [esp+8]
  mov EventsTemp, ecx
  xchg ecx, [esp+8]
@exit:
  push RetAddr
end;

{
procedure EventsHook2;
asm
  push [esp+4]
  call _GetMem
  pop ecx
  mov EventsBlockBase, eax
end;
}

function ReallocProc(NewPtr, OldPtr, size:int):int;
begin
  Result:=NewPtr;
  {
  if OldPtr=EventsBlockBase then
    EventsBlockBase:=NewPtr;
  }  
end;

procedure ReallocHook2;
asm
  pop edx
  pop ecx
  jmp ReallocProc
end;

const
  ReallocHook1Ret = $4E8C5D;

var
  ReallocHook2Ptr:ptr = @ReallocHook2;

procedure ReallocHook1;
asm
  push [esp+8]
  push [esp+8]
  push ReallocHook2Ptr

  // StdData
  push    ebp
  mov     ebp, esp
  push    ebx
  mov     ebx, [ebp+8]

  push ReallocHook1Ret
end;

procedure EventsHook4;
asm
  push [esp+4]
  call _GetMem
  pop ecx
  mov MapProps, eax
end;

procedure OnSaveMap;
begin
  ExceptionMapSaved:=true;
  Form2.UpdateBindings;
  Form2.StartTracking;
  if BackupMaps then
    RSMoveFile(string(MapProps.FileName), ChangeFileExt(MapProps.FileName, '.bak'), false);
end;

procedure EventsHook5;
const Ret=$5047CA;
asm
  call OnSaveMap
  push Ret
end;

procedure OnLoadMap;
begin
  if MapVersionResult <> 0 then
    GameVersions[2]:= MapVersionResult;
  WasSaveAs:= false;
  Form2.StopTracking;
end;

procedure EventsHook6;
const RetAddr=$42C4F6;
asm
  push eax
  push ecx
  push edx
  call OnLoadMap
  pop edx
  pop ecx
  pop eax
  push RetAddr
end;

procedure OnNewMap;
begin
  GameVersions[2]:= $33;
  WasSaveAs:= false;
  Form2.StopTracking;
end;

procedure EventsHook7;
const RetAddr=$45F191;
asm
  push eax
  push ecx
  push edx
  call OnNewMap
  pop edx
  pop ecx
  pop eax
  push RetAddr
end;

procedure HookEvents;
const
   // Get temp Events' block address. (while editing Events)
  HookPtr1 = ptr($4366C3);
  StdData1 : array[0..3] of byte = ($F9, $FF, $0A, $00);

   // Get EventsBlockBase. (Now I get everything via MapProps)
  HookPtr2 = ptr($46F42E);
  StdData2 : array[0..3] of byte = ($5C, $56, $09, $00);
{  HookPtr2 = ptr($45F062);
  StdData2 : array[0..3] of byte = ($28, $5A, $0A, $00); }

   // _realloc
  HookPtr3 = ptr($4E8C56);
  StdData3 : array[0..6] of byte = ($55, $8B, $EC, $53, $8B, $5D, $08);

   // Create MapProps
  HookPtr4 = ptr($45BE84);
  StdData4 : array[0..3] of byte = ($06, $8C, $0A, $00);

   // Save Map
  HookPtr5 = ptr($50A0EF);
  StdData5 : array[0..3] of byte = ($D7, $A6, $FF, $FF);

   // Load Map
  HookPtr6 = ptr($41F72A);
  StdData6 : array[0..3] of byte = ($C8, $CD, $00, $00);

   // New Map
  HookPtr7 = ptr($460AED);
  StdData7 : array[0..3] of byte = ($A0, $E6, $FF, $FF);
begin
  Assert(CompareMem(HookPtr1, @StdData1[0], SizeOf(StdData1)), SWrong);
  //Assert(CompareMem(HookPtr2, @StdData2[0], SizeOf(StdData2)), SWrong);
  //Assert(CompareMem(HookPtr3, @StdData3[0], SizeOf(StdData3)), SWrong);
  Assert(CompareMem(HookPtr4, @StdData4[0], SizeOf(StdData4)), SWrong);
  Assert(CompareMem(HookPtr5, @StdData5[0], SizeOf(StdData5)), SWrong);
  Assert(CompareMem(HookPtr6, @StdData6[0], SizeOf(StdData6)), SWrong);
  Assert(CompareMem(HookPtr7, @StdData7[0], SizeOf(StdData7)), SWrong);

  CallHook(HookPtr1, @EventsHook1);
  //CallHook(HookPtr2, @EventsHook2);
  //DoHook(HookPtr3, SizeOf(StdData3), @ReallocHook1);
  CallHook(HookPtr4, @EventsHook4);
  CallHook(HookPtr5, @EventsHook5);
  CallHook(HookPtr6, @EventsHook6);
  CallHook(HookPtr7, @EventsHook7);
end;

{------------------------------------------------------------------------------}
{ HookGround }


{
procedure GroundHook1;
asm
  push [esp+4]
  call _GetMem
  pop ecx
  mov GroundBlock, eax
end;
}

procedure GroundHook2;
asm
  cmp [esi+4], 0
  jz @spec
  jmp _rand
@spec:
  xor eax, eax
  add [esp], 7 // Change return address
end;

procedure HookGround;
const
   // Ground block address. (Now I get it via MapProps) 
  HookPtr1 = ptr($4374A5);
  StdData1 : array[0..3] of byte = ($E5, $D5, $0C, $00);

   // Avoid exception during smoothing
  HookPtr2 = ptr($4BAAE4);
  StdData2 : array[0..3] of byte = ($7E, $CD, $02, $00);

   // Avoid exception during smoothing
  HookPtr3 = ptr($4BAC4C);
  StdData3 : array[0..3] of byte = ($16, $CC, $02, $00);

   // Avoid possible exception during smoothing
  HookPtr4 = ptr($4BAAB1);
  StdData4 : array[0..3] of byte = ($B1, $CD, $02, $00);

begin
//  Assert(CompareMem(HookPtr1, @StdData1[0], 4), SWrong);
  Assert(CompareMem(HookPtr2, @StdData2[0], 4), SWrong);
  Assert(CompareMem(HookPtr3, @StdData3[0], 4), SWrong);
  Assert(CompareMem(HookPtr4, @StdData4[0], 4), SWrong);

//  CallHook(HookPtr1, @GroundHook1);
  CallHook(HookPtr2, @GroundHook2);
  CallHook(HookPtr3, @GroundHook2);
  CallHook(HookPtr4, @GroundHook2);
end;

{------------------------------------------------------------------------------}
{ PatchPlaceAnywhere }

procedure PatchPlaceAnywhere;
const
 // Move objects anywhare
  PatchPtr1 = ptr($42013D);
  StdData1:array[0..0] of byte = ($75);
  NewData1:array[0..0] of byte = ($EB);

 // Grab and Ctrl+move objects anywhere
  PatchPtr2 = ptr($426B4A);
  StdData2:array[0..0] of byte = ($75);
  NewData2:array[0..0] of byte = ($EB);

 // Move Grail anywhere
  PatchPtr3 = ptr($420113);
  StdData3:array[0..0] of byte = ($74);
  NewData3:array[0..0] of byte = ($EB);

 // Grab and Ctrl+move Grail anywhere
  PatchPtr4 = ptr($4270CF);
  StdData4:array[0..1] of byte = ($72, $42);
  NewData4:array[0..1] of byte = ($EB, $1D);

{
 // Grab and Ctrl+move Grail anywhere. Wrong way.
 // The count of Grails isn't controlled. 
  PatchPtr4 = ptr($43A1DA);
  StdData4:array[0..0] of byte = ($74);
  NewData4:array[0..0] of byte = ($EB);
}

begin
  BoolPatch(PatchPtr1, @StdData1[0], @NewData1[0], SizeOf(NewData1), PlaceAnywhere);
  BoolPatch(PatchPtr2, @StdData2[0], @NewData2[0], SizeOf(NewData2), PlaceAnywhere);
  BoolPatch(PatchPtr3, @StdData3[0], @NewData3[0], SizeOf(NewData3), PlaceAnywhere);
  BoolPatch(PatchPtr4, @StdData4[0], @NewData4[0], SizeOf(NewData4), PlaceAnywhere);
end;

{------------------------------------------------------------------------------}
{ PatchScrollBars }


{
function DoLoadRescourse(lpName, lpType: PChar):ptr; overload;
begin
  Result:=LockResource(LoadResource($400000,
                                    FindResource($400000, lpName, lpType)));
end;
}

function DoLoadRescourse(lpName, lpType:PChar):ptr; overload;
begin
  Result:=LockResource(LoadResource($400000,
                                    FindResource($400000, lpName, lpType)));
end;

function DoLoadRescourse(lpName:int; lpType: PChar):ptr; overload;
begin
  Result:=DoLoadRescourse(ptr(lpName), lpType);
end;

procedure PatchScrollBars;
{
 // ScrollBar and Enters in Rumors
  PatchPtr2 = PDword($610CDC); // 414000 + 1fccdc
  StdData2 = $50810044;
  NewData2 = $50A11044;

 // ScrollBar in Event Object
  PatchPtr3 = PDword($6156DC); // 414000 + 2016dc
  StdData3 = $50811044;
  NewData3 = $50A11044;

 // ScrollBar in Map Description
  PatchPtr4 = PDword($610890); // 414000 + 1fc890
  StdData4 = $50811044;
  NewData4 = $50A11044;

 // ScrollBar in Seer
  PatchPtr5 = PDword($612280); // 414000 + 1fe280
  StdData5 = $50811044;
  NewData5 = $50A11044;

 // ScrollBar in Quest Guard
  PatchPtr6 = PDword($618EA4); // 414000 + 204ea4
  StdData6 = $50811044;
  NewData6 = $50A11044;

 // ScrollBar in Edit Timed Event
  PatchPtr9 = PDword($6158BC); // 414000 + 2018bc
  StdData9 = $50811044;
  NewData9 = $50A11044;


// 167 - Rumors            610CDC  8C   (1fccdc) : 50810044 -> 50A11044
// 261 - Event Object      6156DC  54   (2016dc) : 50811044 -> 50A11044
// 262 - Timed Event       6158BC  8C   (2018bc) : 50811044 -> 50A11044
// 161 - Map Description   610890  2B8  (1fc890) : 50811044 -> 50A11044
// 202 - Seer              612280  2C0  (1fe280) : 50811044 -> 50A11044
// 334 - Quest Guard       618EA4  26C  (204ea4) : 50811044 -> 50A11044

}
const
  DlgIds: array[0..5] of int = (167, 261, 262, 161, 202, 334);
  Offsets: array[0..5] of int = ($8C, $54, $8C, $2B8, $2C0, $26C);
{
  DefPtrs: array[0..5] of int =
    ($610CDC, $6156DC, $6158BC, $610890, $612280, $618EA4);
}
  StdData: array[0..5] of int =
    ($50810044, $50811044, $50811044, $50811044, $50811044, $50811044);

var i:int; p:pint;
begin
  for i:=0 to 5 do
  begin
    p:=DoLoadRescourse(DlgIds[i], RT_DIALOG);
    inc(PByte(p), Offsets[i]);
    Assert(p^=StdData[i], SWrong);
    DoPatch4(p, $50A11044);
  end;
end;

{------------------------------------------------------------------------------}
{ PatchOther }

function GrailProc1(x,y:int):int;
var i:int;
begin
  i:=FullMap^.ScrollBarX.MaxValue - 9;
  Result:=BoolToInt[(x>=9) and (y>=9) and (x<i) and (y<i)];
end;

procedure GrailHook1;
const
  DefProc:ptr = ptr($42616A);
asm
  mov eax, [esp + 8]
  push 0
  push $5847F0
  push $57D8C8
  push 0
  push eax
  call ___RTDynamicCast
  add esp, $14
  test eax, eax
  jnz @IfGrail
@GoodRet:
  push DefProc
  ret

@IfGrail:
  mov eax, [esp + $C]
  mov edx, [esp + $10]
  call GrailProc1
  test eax, eax
  jnz @GoodRet
end;

procedure HookGrail;
const
 // Indicate wrong Grail placement with mouse cursor
  HookPtr1 = pointer($42A088);
  StdData1: array[0..3] of byte = ($DE, $C0, $FF, $FF);

begin
  Assert(CompareMem(HookPtr1, @StdData1[0], SizeOf(StdData1)), SWrong);
  CallHook(HookPtr1, @GrailHook1);
end;


procedure PatchOther;
const
 // Strict size of objects in clipboard
  CopyBuf:PDword = ptr($46C192);

 // May be a small bug of minimap
  PatchPtr1 = PDword($487A8B);
  StdData1 = $5A2F0C;
  NewData1 = $5A2F08;

 // Minimap Size
  PatchPtr7 = PDword($48776D);
  StdData7 = 144;

 // Object Size in list (54 - min)
  PatchPtr8 = PByte($48BAA0);
  StdData8 = 66;


{
 // No exceptions.
  PatchPtr10 = ptr($4E692B);
  StdData10:array[0..2] of byte = ($55, $8B, $EC);
  NewData10:array[0..2] of byte = ($C2, $10, $00);
{}
{
 // Remove limits for placing (except Towns)
  PatchPtr10 = ptr($426AFD);
  StdData10:array[0..0] of byte = ($72);
  NewData10:array[0..0] of byte = ($EB);
}
{
 // Remove limits for taking from palette
  PatchPtr10 = ptr($4212A7);
  StdData10:array[0..0] of byte = ($72);
  NewData10:array[0..0] of byte = ($EB);
{}
{
 // Objects anywhere
  PatchPtr10 = ptr($42616A);
  StdData10:array[0..3] of byte = ($55, $8B, $EC, $81);
  NewData10:array[0..3] of byte = ($31, $C0, $40, $C3);
{}
{
 // Test: No toolbutton select
  PatchPtr10 = ptr($482150);
  StdData10:array[0..2] of byte = ($55, $8B, $EC);
  NewData10:array[0..2] of byte = ($C2, $04, $00);
}
{
 // No disabled toolbar buttons HE TO
  PatchPtr10 = ptr($512BE6);
  StdData10:array[0..5] of byte = ($FF, $90, $A0, $00, $00, $00);
  NewData10:array[0..5] of byte = ($58, $58, $58, $31, $C0, $40);
}
begin
  Assert(CopyBuf^=$1000, SWrong);
//  Assert(PatchPtr1^=StdData1, SWrong);
  Assert(PatchPtr7^=StdData7, SWrong);
  Assert(PatchPtr8^=StdData8, SWrong);
//  Assert(CompareMem(PatchPtr10, @StdData10[0], SizeOf(StdData10)), SWrong);

{
  Assert(CompareMem(PatchPtr9, @StdData9[0], SizeOf(StdData9)), SWrong);
}

  DoPatch4(CopyBuf, 1);
//  DoPatch4(PatchPtr1, NewData1);
  {
  if MinimapSize<>StdData7 then
    DoPatch4(PatchPtr7, MinimapSize);
  }
  if ObjectSize<>StdData8 then
    DoPatch1(PatchPtr8, ObjectSize);
//  DoPatch(PatchPtr10, @NewData10[0], SizeOf(NewData10));
end;

{------------------------------------------------------------------------------}
{ HookNew }

var
  MissingSprites: string;
  MissingSpritesTick: DWORD;

function SpriteNotLoadedProc(name: PChar):PChar;
var
  p: TPoint;
begin
  p.X:= FullMap.ScrollBarX.Wnd.AbsoluteRect.Left + 5;
  p.Y:= FullMap.ScrollBarX.Wnd.AbsoluteRect.Bottom + 5;
  if (MissingSprites <> '') and (GetTickCount - MissingSpritesTick < 5000) then
  begin
    MissingSprites:= MissingSprites + #13#10 + name;
    RSShowHint(Format('Sprites not found:'#13#10'%s', [MissingSprites]), p, 5000);
  end else
  begin
    MessageBeep(MB_ICONERROR);
    MissingSprites:= name;
    RSShowHint(Format('Sprite not found:'#13#10'%s', [MissingSprites]), p, 5000);
  end;
  MissingSpritesTick:= GetTickCount;
  Result:= 'default.def';
end;

procedure SpriteNotLoadedHook;
asm
  mov eax, [esp+8]
  call SpriteNotLoadedProc
  mov ebx, eax
  push $4DCD66
  ret 12
end;

procedure CantPlaceObjectHook;
asm
  mov al, PastingMap
  test al, al
  jz @normal
  ret 12
@normal:
  push $502BD3
end;

procedure LoadMapVersionHookBefore;
asm
  xor eax, eax
  mov MapVersionResult, eax
  push $40737E
end;

procedure LoadMapVersionHook;
asm
  cmp ecx, $1C
  jz @ok
  cmp ecx, $33
  jz @ok
  // StdCode from SOD Map Editor
  push $10
  mov eax, $504A8E
  call eax
  mov esi, eax
  pop ecx
  mov [ebp - $1C], esi
  push $45FE4A
  ret
@ok:
  mov MapVersionResult, ecx
  dec ebx
  push $45FE88
end;

procedure NewUndoHook;
asm
  mov eax, SupressUndo
  test eax, eax
  jz @normal
  pop eax
  ret
@normal:
  mov eax, $526724
end;

procedure ValidationHook;
asm
  pop edi
  pop esi
  call ValidateMap
  test eax, eax
  jnz @addmine
  cmp dword ptr [ebx+10h], 0
  jnz @skip
  push $47D2B7
  ret

@addmine:
  push $47D2BC
  ret

@skip:
  push $47D2E1
end;

function EatProcessorProc(wnd: HWND; dt: int; var tick: DWORD): LongBool;
begin
  Result:= IsIconic(wnd) or (pint($5A33EC)^ = 0) and (pint($5A33F0)^ = 0);
  if Result then
    WaitMessage
  else
    if dt < 180 then
    begin
      MsgWaitForMultipleObjects(0, nil^, false, 180 - dt, QS_ALLINPUT);
      tick:= GetTickCount;
    end;
end;

procedure EatProcessorHook;
asm
  mov eax, [esp + 4]
  mov edx, edi
  sub edx, [esi + $C4]
  lea ecx, [esp + 4]
  mov [esp + 4], edi
  call EatProcessorProc
  mov edi, [esp + 4]
  ret 4
end;

{
procedure SafeLoad(a1,a2,a3,b1,b2,b3,b4:int);
const std: procedure(a1,a2,a3,b1,b2,b3,b4:int) = ptr($4224FE);
begin
  try
    std(a1,a2,a3,b1,b2,b3,b4);
  except
  end;
end;
}

var
  HooksList: array[0..11] of TRSHookInfo = (
    (p: $4DCD8E; newp: @SpriteNotLoadedHook; t: RShtJmp), // Show DEFAULT.def if a sprite doesn't exist
    (p: $480EA9; old: $502BD3; newp: @CantPlaceObjectHook; t: RShtCall), // For CopyMap
    (p: $45FE21; old: $40737E; newp: @LoadMapVersionHookBefore; t: RShtCall), // for WOG/SOD choice
    (p: $45FE3D; newp: @LoadMapVersionHook; t: RShtJmp), // for WOG/SOD choice and reporting wrong version
    (p: $45F580; newp: @NewUndoHook; t: RShtCall), // MapProps_NewUndo
    (p: $47D2AF; newp: @ValidationHook; t: RShtJmp), // extend validation
    (p: $49D7F4; newp: @RandomHook3; t: RShtCall), // exclude some objects from random maps generation
    //(p: $41F4B2; newp: @SafeLoad; t:RShtCall), // !!!
    (p: $490A11; old: $4E716C; newp: @ObjectsCountHook; t: RShtCall),
    (p: $490A48; old: $490AAB; newp: @ObjectsTxtHook; t: RShtCall),
    (p: $45CE6E; newp: @EatProcessorHook; t: RShtCall; size: 6), // Don't consume processor too much, especially when inactive
    (p: $45EED1; old: $5057ED; newp: @DeleteFile; t: RShtCall), // An error on exit
    ()
  );

procedure HookNew;
begin
  Assert(RSCheckHooks(HooksList), SWrong);
  RSApplyHooks(HooksList);
end;

{------------------------------------------------------------------------------}
{ PatchOther1 }

var Cmds:array of byte;

procedure PatchOther1;
const
 // More Object Palettes
  PatchPtr1 = PDword($4C15A7);
  StdData1 = $200;
  NewData1 = $200+20;

 // Menu/Toolbar Commands
  PatchPtr2 = PDword($53EABC);
  StdData2 = $53EAC0;

//var a:array of byte;
begin
  Assert(PatchPtr1^=StdData1, SWrong);
  Assert(PatchPtr2^=StdData2, SWrong);

  DoPatch4(PatchPtr1, NewData1);

  SetLength(Cmds, $53FAE0-$53EAB8);
  CopyMemory(ptr(Cmds), ptr($53EAB8), $53FAE0-$53EAB8);
  pptr(PatchPtr2)^:=@Cmds[8];
  pptr(@Cmds[4])^:=@Cmds[8];
  ZeroMemory(PatchPtr2, $53FAE0-$53EAC0);
  DoPatch4(ptr($480236), int(Cmds));

  {}
  // 53FAE0

//  SetLength(a, $53FAFC-$53EAC0);
//  DoPatch(ptr(Cmds), ptr(a), $53FAFC-$53EAC0 - 50);
end;

var oldDllProc:TDLLProc;
procedure MyDllProc(Reason: Integer);
begin
  try
    if Reason=DLL_PROCESS_DETACH then
    begin
      SaveOptions;
      DestroyAcceleratorTable(MenuAccel);
    end;
    if @oldDllProc<>nil then oldDllProc(Reason);
  except
    OnException(true);
  end;
end;

procedure ExportedProc;
begin

end;

CONST
  EMPTY_STR: STRING = #0;

PROCEDURE PrepareBank;
CONST
  NEW_BANK_COUNT  = 1000;
  
VAR
  i:  INTEGER;

BEGIN
  BankCount :=  NEW_BANK_COUNT;
  SetLength(BankList, 1000);
  
  FOR i := 0 TO NEW_BANK_COUNT - 1 DO BEGIN
    BankList[i] :=  PCHAR(EMPTY_STR);
  END; // .FOR
END; // .PROCEDURE PrepareBank

const
  MyOnException:TMethod = (Code:@ApplicationOnException);

exports
  ExportedProc;
begin
  try
    oldDllProc:=DllProc;
    DllProc:=MyDllProc;
    AssertErrorProc:=RSAssertErrorHandler;
    PatchPath:=AppPath + 'Data\MapEdPatch\';

    SetCurrentDirectory(PChar(AppPath));
    {$IFNDEF Themes}
    KillThemes;
    {$ENDIF}

    RSDebugUseDefaults;
    RSDebugHook;

    HintWindowClass:=TRSSimpleHintWindow;
    RSHintBorderColor:=0;
    RSHintHasShadow:=false;
    Application.OnException:=TExceptionEvent(MyOnException);
    Application.Initialize;
    Form1.Initialize;
    Form2.Initialize;
    Form4.Initialize;
    Form5.Initialize;
    pptr(@Application.MainForm)^:=nil;

//    RSSaveTextFile(PatchPath+'LanguageNew.txt', RSLanguage.MakeLanguage);
    try
      RSLanguage.LoadLanguage(RSLoadTextFile(PatchPath+'Language.txt'), false);
    except
    end;

    Form4.AfterLang;

    SSaveMapFilter:= RSStringReplace(SSaveMapFilter, '|', #0);

    LoadOptions;
    LoadMenu;

    MakeMonList;
    LoadMonsters;
    PatchMonsters;
    HookMonsters;

    MakeArtList;
    PatchArt;
    HookArt;

    MakeDwellList;
    PatchDwell;

    PrepareBank;
    PatchBank;
    {CUTTED LoadBank => OnLoad}

    LoadObjects;
    
    LoadRandom;
    HookRandom;

    HookWindowProc;

    HookHelp; // Also for objects' editing

    HookObjects;

    LoadNewObjects;

    HookEvents;

    HookGround;

    PatchScrollBars;

    HookGrail;
    HookOther;

    PatchOther;
//    PatchOther1;
    HookNew;

    {$IFDEF Test}
    HookTest;
    {$ENDIF}

    LoadRuns;
    LoadRunOnce;

  except
    OnException(true);
  end;
end.

