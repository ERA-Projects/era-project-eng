unit WndHooks;

interface

uses
  SysUtils, Windows, RSQ, RSStrUtils, RSSysUtils, Messages, IniFiles, Types,
  Consts, ShellAPI, CommCtrl, Forms, Dialogs, Menus, Classes, Graphics,
  Controls, RSUtils, RSLang, Math, RSDebug, Lod, CommDlg, RSCodeHook, Clipbrd,
  Common, Unit1, Unit2;

implementation

uses
  MainHooks;

type
  TSpecWndProc = function(obj:Ptr; Wnd:TRSWnd; Msg:uint; wParam:int;
                                              lParam:int):LResult; stdcall;

type
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

var
  MenuTools:array of TMenuIt; MenuAdded:boolean;
  Menu:hmenu; MenuAccel:HACCEL;

type
  TCreateMainWndProc = procedure(Handle:TRSWnd); stdcall;
  TGlobalWndProc = function(obj:ptr; Handle:TRSWnd; Msg:DWord;
    wParam, lParam:int; Proc:TSpecWndProc; var Result:int):Bool; stdcall;

  TModule = record
    CreateMainWnd:TCreateMainWndProc;
    GlobalWndProc:TGlobalWndProc;
  end;

var
  Modules:array of TModule;

var
  ToolbarAdded: Boolean;

const
  EWndNamePtr=PPChar($5A1E54);
var
  ELastH:integer;
  EWndName:string; ESizable:boolean;

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

type
  TCreatureRecord = packed record
    Def: array[0..11] of Char;
    Sound: array[0..7] of Char;
  end;
  TCreaturesArray = array[Byte] of TCreatureRecord;
  PCreaturesArray = ^TCreaturesArray;

var
  MonDataArray: TRSByteArray;
  MonData: PCreaturesArray absolute MonDataArray;

procedure MakeMonData;
begin
  SetLength(MonDataArray, (MaxMon + 1)*SizeOf(TCreatureRecord));
  

end;

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


end.
