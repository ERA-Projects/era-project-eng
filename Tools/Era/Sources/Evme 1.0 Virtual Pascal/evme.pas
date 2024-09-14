Program ERM_VARS_MEMORY_EDITOR;
Uses Windows,SysUtils,VPUtils,Console,VPString,Menu;
{$H+}

TYPE
t_buffer=array[1..10000] of integer;
t_f=array[1..1000] of shortint;
t_1000=array[0..511] of byte;
t_z=array[1..1000] of t_1000;
t_w=array[0..255,1..200] of integer;

VAR
wndname:string;
st: SHORTSTRING;
f: TEXT;
hwnd:integer;
h3Main:integer;
h3ID:integer;
NewSize:TSmallRect;
key:char;
temp:array[0..6] of integer;
buffer:pointer;
hero:integer;

LABEL
1,2,3;


CONST
pv:^t_buffer=pointer($887668);
pf:^t_f=pointer($91F2E0);
pz:^t_z=pointer($9273E8);
pw:^t_w=pointer($A4AB10);


Procedure ShowHelp;
 begin
 Writeln('������ ������:');
 WriteC(14,'C ');Writeln('- ������ ���᮫�');
 WriteC(14,'G ');Writeln('- ������� ���祭�� ��६����� ���');
 WriteC(14,'S ');Writeln('- ��⠭����� ���祭�� ��६����� ���');
 WriteC(14,'F ');Writeln('- ��������� ��� ��६����� 㪠����� ���祭���');
 WriteC(14,'R ');Writeln('- �⥭�� ������ �� �����');
 WriteC(14,'W ');Writeln('- ������ ������ �� �����');
 WriteC(14,'I ');Writeln('- ��⠭���� ����� ��६����� ���祭�� ��㣮�');
 WriteC(14,'D ');Writeln('- ������ ���� ��६����� � 䠩�');
 WriteC(14,'L ');Writeln('- ����㧨�� ��६���� �� �����');
 WriteC(14,'A ');Writeln('- ������ ���� ERM ��६�����');
 WriteC(14,'M ');Writeln('- ����஢���� ����� ����� �� ����� ������ � �����');
 WriteC(14,'Q ');Writeln('- �롮� ����');
 WriteC(14,'H ');Writeln('- �������� ᢮��� ������');
 WriteC(14,'ESC ');Writeln('- ��室');
 Writeln;
 end;

Procedure CmdClear;
 begin
 ClrScr;
 WriteC(14,'��饭�!'+#13#10);
 end;

Procedure CmdGetVar;
var _i,_c,_ind:integer;_typ:char;_b:byte;
_str:string;

 begin
 WriteC(10,'������� ��� ��६�����  ');
 Readln(_str);
 _str:=Trim(_str);
 if _str='' then
  begin
  WriteC(12,'�� 㪠���� ��ࠬ���� �������!'+#13#10#13#10);
  Exit;
  end;
 _i:=Pos(#32,_str);
 if _i=0 then _c:=1
 else
 try
  _c:=StrToInt(RightStr(_str,length(_str)-_i));
  _str:=LeftStr(_str,_i-1);
 except
  WriteC(12,'����७ ��ன ��ࠬ��� �������!'+#13#10#13#10);
  Exit;
 end;
 _typ:=_str[1];
 if length(_str)=1 then
  begin
  WriteC(12,'�� 㪠��� ������ ��६�����!'+#13#10#13#10);
  Exit;
  end;
 try
 _str:=RightStr(_str,length(_str)-1);
 _ind:=StrToInt(_str);
 except
  WriteC(12,'����७ ���� ��ࠬ��� �������!'+#13#10#13#10);
  Exit;
 end;
 _typ:=UpCase(_typ);
 case _typ of
  'V':
   begin
   if not ((_ind>=1)and(_ind<=10000)) then
    begin
    WriteC(12,'������ ������ V-��६�����! ����᪠���� 1..10000'+#13#10#13#10);
    Exit;
    end;
   temp[0]:=Min(_ind+_c-1,10000);
   temp[1]:=(temp[0]-_ind+1)*4;
   GetMem(buffer,temp[1]);
   ReadProcessMemory(h3Main,@pv^[_ind],buffer,temp[1],temp[2]);
   for _i:=_ind to temp[0] do
    begin
    writeln('v',_i,' = ',pinteger((_i-_ind)*4+integer(buffer))^);
    end;
   Writeln;
   FreeMem(buffer,temp[1]);
   Exit;
   end;
  'F':
   begin
   if not ((_ind>=1)and(_ind<=10000)) then
    begin
    WriteC(12,'������ ������ 䫠��! ����᪠���� 1..1000'+#13#10#13#10);
    Exit;
    end;
   temp[0]:=Min(_ind+_c-1,1000);
   temp[1]:=temp[0]-_ind+1;
   GetMem(buffer,temp[1]);
   ReadProcessMemory(h3Main,@pf^[_ind],buffer,temp[1],temp[2]);
   for _i:=_ind to temp[0] do
    begin
    writeln('flag',_i,' = ',pbyte((_i-_ind)+integer(buffer))^);
    end;
   Writeln;
   FreeMem(buffer,temp[1]);
   Exit;
   end;
  'Z':
   begin
   if not ((_ind>=1)and(_ind<=1000)) then
    begin
    WriteC(12,'������ ������ Z-��६�����! ����᪠���� 1..1000'+#13#10#13#10);
    Exit;
    end;
   temp[0]:=Min(_ind+_c-1,1000);
   GetMem(Buffer,513);
   for _i:=_ind to temp[0] do
    begin
    ReadProcessMemory(h3Main,@pz^[_i],buffer,513,temp[2]);
    temp[3]:=StrLen(pchar(buffer));
    SetLength(_str,temp[3]);
    CopyMemory(@_str[1],buffer,temp[3]);
    AnsiToOEM(@_str[1],@_str[1]);
    writeln('z',_i,' = ',_str);
    end;
   Writeln;
   FreeMem(buffer,513);
   Exit;
   end;
  'W':
   begin
   if not ((_ind>=1)and(_ind<=200)) then
    begin
    WriteC(12,'������ ������ W-��६�����! ����᪠���� 1..200'+#13#10#13#10);
    Exit;
    end;
   temp[0]:=Min(_ind+_c-1,200);
   temp[1]:=(temp[0]-_ind+1)*4;
   GetMem(buffer,temp[1]);
   ReadProcessMemory(h3Main,@pw^[hero,_ind],buffer,temp[1],temp[2]);
   for _i:=_ind to temp[0] do
    begin
    writeln('[��� ',hero,']: w',_i,' = ',pinteger((_i-_ind)*4+integer(buffer))^);
    end;
   Writeln;
   FreeMem(buffer,temp[1]);
   Exit;
   end;
  else
   begin
   WriteC(12,'��������� ⨯ ��६�����! ����᪠���� V,F,W � Z'+#13#10#13#10);
   Exit;
   end;
 end;//of case
 end;

Procedure CmdSetVar;
var _i,_p,_ind:integer;_typ:char;
_str:string;

 begin
 WriteC(10,'��⠭����� ERM ��६�����  ');
 Readln(_str);
 _str:=Trim(_str);
 if _str='' then
  begin
  WriteC(12,'�� 㪠���� ��ࠬ���� �������!'+#13#10#13#10);
  Exit;
  end;
 _typ:=_str[1];
 if length(_str)=1 then
  begin
  WriteC(12,'�� 㪠��� ������ ��६�����!'+#13#10#13#10);
  Exit;
  end;
 _i:=Pos(#32,_str);
 if _i=0 then
  begin
  WriteC(12,'�� 㪠���� ����� ���祭�� ��६�����!'+#13#10#13#10);
  Exit;
  end;
 try
  _ind:=StrToInt(RightStr(LeftStr(_str,_i-1),_i-2));
  _str:=RightStr(_str,length(_str)-_i);
 except
  WriteC(12,'����७ ���� ��ࠬ��� �������!'+#13#10#13#10);
  Exit;
 end;
 _typ:=UpCase(_typ);
 case _typ of
  'V':
   begin
   if not ((_ind>=1)and(_ind<=10000)) then
    begin
    WriteC(12,'������ ������ V-��६�����! ����᪠���� 1..10000'+#13#10#13#10);
    Exit;
    end;
   while (length(_str)>0)and(_ind<=10000) do
    begin
    _p:=Pos(#32,_str);
    if _p=0 then _p:=length(_str)+1;
    try
    _i:=StrToInt(LeftStr(_str,_p-1));
    _str:=RightStr(_str,length(_str)-_p);
    except
    WriteC(12,'�����४⭮� ����� ���祭�� ��६�����!'+#13#10#13#10);
    Exit;
    end;
    writeln('v',_ind,' = ',_i);
    WriteProcessMemory(h3Main,@pv^[_ind],@_i,4,temp[2]);
    _ind:=_ind+1;
    end;
   Writeln;
   end;
  'F':
   begin
   if not ((_ind>=1)and(_ind<=1000)) then
    begin
    WriteC(12,'������ ������ 䫠��! ����᪠���� 1..1000'+#13#10#13#10);
    Exit;
    end;
   while (length(_str)>0)and(_ind<=1000) do
    begin
    _p:=Pos(#32,_str);
    if _p=0 then _p:=length(_str)+1;
    try
    _i:=StrToInt(LeftStr(_str,_p-1));
    _str:=RightStr(_str,length(_str)-_p);
    except
    WriteC(12,'�����४⭮� ����� ���祭�� ��६�����!'+#13#10#13#10);
    Exit;
    end;
    if (_i<0)or(_i>1) then
     begin
     WriteC(12,'�����४⭮� ����� ���祭�� 䫠��! ����᪠���� 0..1'+#13#10#13#10);
     Exit;
     end;
    writeln('flag',_ind,' = ',_i);
    WriteProcessMemory(h3Main,@pf^[_ind],@_i,1,temp[2]);
    _ind:=_ind+1;
    end;
   Writeln;
   end;
  'W':
   begin
   if not ((_ind>=1)and(_ind<=200)) then
    begin
    WriteC(12,'������ ������ W-��६�����! ����᪠���� 1..200'+#13#10#13#10);
    Exit;
    end;
   while (length(_str)>0)and(_ind<=200) do
    begin
    _p:=Pos(#32,_str);
    if _p=0 then _p:=length(_str)+1;
    try
    _i:=StrToInt(LeftStr(_str,_p-1));
    _str:=RightStr(_str,length(_str)-_p);
    except
    WriteC(12,'�����४⭮� ����� ���祭�� ��६�����!'+#13#10#13#10);
    Exit;
    end;
    writeln('[��� ',hero,']: w',_ind,' = ',_i);
    WriteProcessMemory(h3Main,@pw^[hero,_ind],@_i,4,temp[2]);
    _ind:=_ind+1;
    end;
   Writeln;
   end;
  'Z':
   begin
   if not ((_ind>=1)and(_ind<=1000)) then
    begin
    WriteC(12,'������ ������ Z-��६�����! ����᪠���� 1..1000'+#13#10#13#10);
    Exit;
    end;
   if length(_str)>512 then SetLength(_str,512);
   writeln('z',_ind,' = ',_str);
   if _str='#0' then _str:=#0;
   OEMToAnsi(@_str[1],@_str[1]);
   WriteProcessMemory(h3Main,@pz^[_ind],@_str[1],length(_str)+1,temp[2]);
   Writeln;
   end;
  else
   begin
   WriteC(12,'��������� ⨯ ��६�����! ����᪠���� V,F,W � Z'+#13#10#13#10);
   Exit;
   end;
 end;//of case
 end;

Procedure CmdChooseHero;
var _i:integer;_str:string;

 begin
 WriteC(10,'����� ����  ');
 Readln(_str);
 _str:=Trim(_str);
 if _str='' then
  begin
  WriteC(12,'�� 㪠���� ��ࠬ���� �������!'+#13#10#13#10);
  Exit;
  end;
 try
  _i:=StrToInt(_str);
 except
  WriteC(12,'������ ��ࠬ��� �������!'+#13#10#13#10);
  Exit;
 end;
 if not ((_i>=0)and(_i<=255)) then
  begin
  WriteC(12,'������ ����� ����! ����᪠���� 0..255'+#13#10#13#10);
  Exit;
  end;
 hero:=_i;
 Writeln('��ன ',_i);
 Writeln;
 end;

procedure _FillInt(var x;_c,_i:integer);
 begin
 asm
 mov ecx,_c
 mov edx,_i
 mov eax, x
 @@1:
 mov dword ptr [eax],edx
 add eax,4
 dec ecx
 jnz @@1
 end;
 end;

Procedure CmdFillVar;
var _i,_c,_f,_ind:integer;_typ:char;
_str:string;
 begin
 WriteC(10,'���������� ERM ��६�����  ');
 Readln(_str);
 _str:=Trim(_str);
 if _str='' then
  begin
  WriteC(12,'�� 㪠���� ��ࠬ���� �������!'+#13#10#13#10);
  Exit;
  end;
 _typ:=_str[1];
 if length(_str)=1 then
  begin
  WriteC(12,'�� 㪠��� ������ ��६�����!'+#13#10#13#10);
  Exit;
  end;
 _i:=Pos(#32,_str);
 if _i=0 then
  begin
  WriteC(12,'�� 㪠���� ���-�� ��६����� ��� ����������!'+#13#10#13#10);
  Exit;
  end;
 try
  _ind:=StrToInt(RightStr(LeftStr(_str,_i-1),_i-2));
  _str:=RightStr(_str,length(_str)-_i);
 except
  WriteC(12,'����७ ���� ��ࠬ��� �������!'+#13#10#13#10);
  Exit;
 end;
 _i:=Pos(#32,_str);
 if _i=0 then
  begin
  WriteC(12,'�� 㪠��� �������⥫�!'+#13#10#13#10);
  Exit;
  end;
 try
  _c:=StrToInt(LeftStr(_str,_i-1));
  _str:=RightStr(_str,length(_str)-_i);
 except
  WriteC(12,'����७ ��ன ��ࠬ��� �������!'+#13#10#13#10);
  Exit;
 end;
 _typ:=UpCase(_typ);
 case _typ of
  'V':
   begin
   if not ((_ind>=1)and(_ind<=10000)) then
    begin
    WriteC(12,'������ ������ V-��६�����! ����᪠���� 1..10000'+#13#10#13#10);
    Exit;
    end;
   try
    _f:=StrToInt(_str);
   except
    WriteC(12,'������ �������⥫�!'+#13#10#13#10);
    Exit;
   end;//of try
   temp[0]:=Min(_ind+_c-1,10000);
   temp[1]:=(temp[0]-_ind+1)*4;
   GetMem(buffer,temp[1]);
   _FillInt(buffer^,_c,_f);
   WriteProcessMemory(h3Main,@pv^[_ind],buffer,temp[1],temp[2]);
   FreeMem(buffer,temp[1]);
   Writeln('���������!'+#13#10);
   end;
  'W':
   begin
   if not ((_ind>=1)and(_ind<=200)) then
    begin
    WriteC(12,'������ ������ W-��६�����! ����᪠���� 1..200'+#13#10#13#10);
    Exit;
    end;
   try
    _f:=StrToInt(_str);
   except
    WriteC(12,'������ �������⥫�!'+#13#10#13#10);
    Exit;
   end;//of try
   temp[0]:=Min(_ind+_c-1,200);
   temp[1]:=(temp[0]-_ind+1)*4;
   GetMem(buffer,temp[1]);
   _FillInt(buffer^,_c,_f);
   WriteProcessMemory(h3Main,@pw^[hero,_ind],buffer,temp[1],temp[2]);
   FreeMem(buffer,temp[1]);
   Writeln('���������!'+#13#10);
   end;
  'F':
   begin
   if not ((_ind>=1)and(_ind<=1000)) then
    begin
    WriteC(12,'������ ������ 䫠��! ����᪠���� 1..1000'+#13#10#13#10);
    Exit;
    end;
   try
    _f:=StrToInt(_str);
   except
    WriteC(12,'������ �������⥫�!'+#13#10#13#10);
    Exit;
   end;//of try
   if (_f<0)or(_f>1) then
    begin
    WriteC(12,'�����४�� �������⥫�! ����᪠���� ���祭�� 0..1'+#13#10#13#10);
    Exit;
    end;
   temp[0]:=Min(_ind+_c-1,1000);
   temp[1]:=(temp[0]-_ind+1);
   GetMem(buffer,temp[1]);
   FillChar(buffer^,_c,_f);
   WriteProcessMemory(h3Main,@pf^[_ind],buffer,temp[1],temp[2]);
   FreeMem(buffer,temp[1]);
   Writeln('���������!'+#13#10);
   end;
  'Z':
   begin
   if not ((_ind>=1)and(_ind<=1000)) then
    begin
    WriteC(12,'������ ������ Z-��६�����! ����᪠���� 1..1000'+#13#10#13#10);
    Exit;
    end;
   if _str='#0' then _str:=#0;
   OEMToAnsi(@_str[1],@_str[1]);
   temp[0]:=Min(_ind+_c-1,1000);
   for _i:=_ind to temp[0] do
    WriteProcessMemory(h3Main,@pz^[_i],@_str[1],length(_str)+1,temp[2]);
   Writeln('���������!'+#13#10);
   end;
  else
   begin
   WriteC(12,'��������� ⨯ ��६�����! ����᪠���� V,F,W � Z'+#13#10#13#10);
   Exit;
   end;
 end;//of case
 end;

Procedure CmdVarToVar;
var _i,_c,_ind1,_ind2:integer;_typ1,_typ2:char;_p1,_p2:pointer;
_str:string;

 begin
 WriteC(10,'����� � ERM ��६���묨  ');
 _str:='';
 Readln(_str);
 _str:=Trim(_str);
 if _str='' then
  begin
  WriteC(12,'�� 㪠���� ��ࠬ���� �������!'+#13#10#13#10);
  Exit;
  end;
 _typ1:=_str[1];
 if length(_str)=1 then
  begin
  WriteC(12,'�� 㪠��� ������ ��ࢮ� ��६�����!'+#13#10#13#10);
  Exit;
  end;
 _i:=Pos(#32,_str);
 if _i=0 then
  begin
  WriteC(12,'�� 㪠���� ���� ��६�����!'+#13#10#13#10);
  Exit;
  end;
 try
  _ind1:=StrToInt(RightStr(LeftStr(_str,_i-1),_i-2));
  _str:=RightStr(_str,length(_str)-_i);
 except
  WriteC(12,'����७ ���� ��ࠬ��� �������!'+#13#10#13#10);
  Exit;
 end;
 _typ2:=_str[1];
 if length(_str)=1 then
  begin
  WriteC(12,'�� 㪠��� ������ ��ன ��६�����!'+#13#10#13#10);
  Exit;
  end;
 _i:=Pos(#32,_str);
 if _i=0 then _i:=length(_str)+1;
 try
  _ind2:=StrToInt(RightStr(LeftStr(_str,_i-1),_i-2));
  _str:=RightStr(_str,length(_str)-_i);
 except
  WriteC(12,'����७ ��ன ��ࠬ��� �������!'+#13#10#13#10);
  Exit;
 end;
 if length(_str)=0 then _c:=1 else
 try
  _c:=StrToInt(_str);
 except
  WriteC(12,'����७ ��⨩ ��ࠬ��� �������!'+#13#10#13#10);
  Exit;
 end;
 _typ1:=UpCase(_typ1);
 _typ2:=UpCase(_typ2);
 if not ((_typ1 in ['V','W','Z','F'])or(_typ2 in ['V','W','Z','F'])) then
  begin
  WriteC(12,'������ ⨯� ��६�����! ����᪠����  V,F,W � Z'+#13#10#13#10);
  Exit;
  end;
 if ((_typ1<>_typ2))and not((_typ1 in ['W','V'])and(_typ2 in ['W','V'])) then
  begin
  WriteC(12,'��ᮢ���⨬� ⨯� ��६�����!'+#13#10#13#10);
  Exit;
  end;
 case _typ1 of
  'V':
   begin
   if not ((_ind1>=1)and(_ind1<=10000)) then
    begin
    WriteC(12,'������ ������ V-��६�����! ����᪠���� 1..10000'+#13#10#13#10);
    Exit;
    end;
   temp[0]:=Min(_ind1+_c-1,10000);
   _p1:=@pv^[_ind1];
   end;
  'W':
   begin
   if not ((_ind1>=1)and(_ind1<=200)) then
    begin
    WriteC(12,'������ ������ W-��६�����! ����᪠���� 1..200'+#13#10#13#10);
    Exit;
    end;
   temp[0]:=Min(_ind1+_c-1,200);
   _p1:=@pw^[hero,_ind1];
   end;
  'F':
   begin
   if not ((_ind1>=1)and(_ind1<=1000)) then
    begin
    WriteC(12,'������ ������ 䫠��! ����᪠���� 1..1000'+#13#10#13#10);
    Exit;
    end;
   temp[0]:=Min(_ind1+_c-1,1000);
   _p1:=@pf^[_ind1];
   end;
  'Z':
   begin
   if not ((_ind1>=1)and(_ind1<=1000)) then
    begin
    WriteC(12,'������ ������ Z-��६�����! ����᪠���� 1..1000'+#13#10#13#10);
    Exit;
    end;
   temp[0]:=Min(_ind1+_c-1,1000);
   _p1:=@pz^[_ind1];
   end;
 end;//of case
 ///////////////////////////////////////////////
 case _typ2 of
  'V':
   begin
   if not ((_ind2>=1)and(_ind2<=10000)) then
    begin
    WriteC(12,'������ ������ V-��६�����! ����᪠���� 1..10000'+#13#10#13#10);
    Exit;
    end;
   temp[1]:=Min(_ind2+_c-1,10000);
   _p2:=@pv^[_ind2];
   end;
  'W':
   begin
   if not ((_ind2>=1)and(_ind2<=200)) then
    begin
    WriteC(12,'������ ������ W-��६�����! ����᪠���� 1..200'+#13#10#13#10);
    Exit;
    end;
   temp[1]:=Min(_ind2+_c-1,200);
   _p2:=@pw^[hero,_ind2];
   end;
  'F':
   begin
   if not ((_ind2>=1)and(_ind2<=1000)) then
    begin
    WriteC(12,'������ ������ 䫠��! ����᪠���� 1..1000'+#13#10#13#10);
    Exit;
    end;
   temp[1]:=Min(_ind2+_c-1,1000);
   _p2:=@pf^[_ind2];
   end;
  'Z':
   begin
   if not ((_ind2>=1)and(_ind2<=1000)) then
    begin
    WriteC(12,'������ ������ Z-��६�����! ����᪠���� 1..1000'+#13#10#13#10);
    Exit;
    end;
   temp[1]:=Min(_ind2+_c-1,1000);
   _p2:=@pz^[_ind2];
   end;
 end;//of case
 temp[2]:=Min(temp[0],temp[1]);
 //Z
 if _typ1='Z' then
  begin
  temp[3]:=512*temp[2];
  GetMem(buffer,temp[3]);
  ReadProcessMemory(h3Main,_p2,buffer,temp[3],temp[0]);
  WriteProcessMemory(h3Main,_p1,buffer,temp[3],temp[0]);
  Writeln('���祭�� �ᯥ譮 ��᢮���!'+#13#10);
  end
 //V,W or F
 else
  begin
  if _typ1='F' then temp[3]:=temp[2]
  else temp[3]:=temp[2]*4;
  GetMem(buffer,temp[3]);
  ReadProcessMemory(h3Main,_p2,buffer,temp[3],temp[0]);
  WriteProcessMemory(h3Main,_p1,buffer,temp[3],temp[0]);
  Writeln('���祭�� �ᯥ譮 ��᢮���!'+#13#10);
  end;
 end;

Procedure CmdDumpVar;
var _i,_c,_ind:integer;_typ:char;_hfile:integer;
_str:string;
 begin
 WriteC(10,'���� �����  ');Write('��� 䠩��: ');
 Readln(_str);
 _str:=Trim(_str);
 DeleteFile(_str);
 _hfile:=FileCreate(_str);
 if _hfile<0 then
  begin
  WriteC(12,'�� ���� ᮧ���� 㪠����� 䠩�!'+#13#10#13#10);
  Exit;
  end;
 Write('��ࠬ����: ');
 Readln(_str);
 _str:=Trim(_str);
 if _str='' then
  begin
  WriteC(12,'�� 㪠���� ��ࠬ���� �������!'+#13#10#13#10);
  CloseHandle(_hfile);
  Exit;
  end;
 _typ:=_str[1];
 if length(_str)=1 then
  begin
  WriteC(12,'�� 㪠��� ������ ��६�����!'+#13#10#13#10);
  CloseHandle(_hfile);
  Exit;
  end;
 _i:=Pos(#32,_str);
 if _i=0 then _i:=length(_str)+1;
 try
  _ind:=StrToInt(RightStr(LeftStr(_str,_i-1),_i-2));
  _str:=RightStr(_str,length(_str)-_i);
 except
  WriteC(12,'����७ ���� ��ࠬ��� �������!'+#13#10#13#10);
  CloseHandle(_hfile);
  Exit;
 end;
 if length(_str)=0 then _c:=1
 else
 try
  _c:=StrToInt(_str);
 except
  WriteC(12,'����७ ��ன ��ࠬ��� �������!'+#13#10#13#10);
  CloseHandle(_hfile);
  Exit;
 end;
 _typ:=UpCase(_typ);
 /////////////////////////////////////////////
 case _typ of
  'V':
   begin
   if not ((_ind>=1)and(_ind<=10000)) then
    begin
    WriteC(12,'������ ������ V-��६�����! ����᪠���� 1..10000'+#13#10#13#10);
    Exit;
    end;
   temp[0]:=Min(_ind+_c-1,10000);
   temp[1]:=(temp[0]-_ind+1)*4;
   GetMem(buffer,temp[1]);
   ReadProcessMemory(h3Main,@pv^[_ind],buffer,temp[1],temp[2]);
   FileWrite(_hfile,buffer^,temp[1]);
   Writeln('���� �ᯥ譮 ��襭'+#13#10);
   FreeMem(buffer,temp[1]);
   CloseHandle(_hfile);
   Exit;
   end;
  'F':
   begin
   if not ((_ind>=1)and(_ind<=10000)) then
    begin
    WriteC(12,'������ ������ 䫠��! ����᪠���� 1..1000'+#13#10#13#10);
    Exit;
    end;
   temp[0]:=Min(_ind+_c-1,1000);
   temp[1]:=temp[0]-_ind+1;
   GetMem(buffer,temp[1]);
   ReadProcessMemory(h3Main,@pf^[_ind],buffer,temp[1],temp[2]);
   FileWrite(_hfile,buffer^,temp[1]);
   Writeln('���� �ᯥ譮 ��襭'+#13#10);
   FreeMem(buffer,temp[1]);
   CloseHandle(_hfile);
   Exit;
   end;
  'Z':
   begin
   if not ((_ind>=1)and(_ind<=1000)) then
    begin
    WriteC(12,'������ ������ Z-��६�����! ����᪠���� 1..1000'+#13#10#13#10);
    Exit;
    end;
   temp[0]:=Min(_ind+_c-1,1000);
   temp[1]:=(temp[0]-_ind+1)*512;
   GetMem(buffer,temp[1]);
   ReadProcessMemory(h3Main,@pz^[_ind],buffer,temp[1],temp[2]);
   FileWrite(_hfile,buffer^,temp[1]);
   Writeln('���� �ᯥ譮 ��襭'+#13#10);
   FreeMem(buffer,temp[1]);
   CloseHandle(_hfile);
   Exit;
   end;
  'W':
   begin
   if not ((_ind>=1)and(_ind<=200)) then
    begin
    WriteC(12,'������ ������ W-��६�����! ����᪠���� 1..200'+#13#10#13#10);
    Exit;
    end;
   temp[0]:=Min(_ind+_c-1,200);
   temp[1]:=(temp[0]-_ind+1)*4;
   GetMem(buffer,temp[1]);
   ReadProcessMemory(h3Main,@pw^[hero,_ind],buffer,temp[1],temp[2]);
   FileWrite(_hfile,buffer^,temp[1]);
   Writeln('���� �ᯥ譮 ��襭'+#13#10);
   FreeMem(buffer,temp[1]);
   CloseHandle(_hfile);
   Exit;
   end;
  else
   begin
   WriteC(12,'��������� ⨯ ��६�����! ����᪠���� V,F,W � Z'+#13#10#13#10);
   CloseHandle(_hfile);
   Exit;
   end;
 end;//of case
 end;

Procedure CmdLoadVar;
var _i,_c,_ind:integer;_typ:char;_hfile:integer;
_str:string;
 begin
 WriteC(10,'����㧪� �����  ');Write('��� 䠩��: ');
 Readln(_str);
 _str:=Trim(_str);
 _hfile:=FileOpen(_str,fmOpenRead or fmShareDenyWrite);
 if _hfile<0 then
  begin
  WriteC(12,'�� ���� ������ 㪠����� 䠩�!'+#13#10#13#10);
  Exit;
  end;
 Write('��ࠬ����: ');
 Readln(_str);
 _str:=Trim(_str);
 if _str='' then
  begin
  WriteC(12,'�� 㪠���� ��ࠬ���� �������!'+#13#10#13#10);
  CloseHandle(_hfile);
  Exit;
  end;
 _typ:=_str[1];
 if length(_str)=1 then
  begin
  WriteC(12,'�� 㪠��� ������ ��६�����!'+#13#10#13#10);
  CloseHandle(_hfile);
  Exit;
  end;
 _i:=Pos(#32,_str);
 if _i=0 then _i:=length(_str)+1;
 try
  _ind:=StrToInt(RightStr(LeftStr(_str,_i-1),_i-2));
  _str:=RightStr(_str,length(_str)-_i);
 except
  WriteC(12,'����७ ���� ��ࠬ��� �������!'+#13#10#13#10);
  CloseHandle(_hfile);
  Exit;
 end;
 if length(_str)=0 then _c:=1
 else
 try
  _c:=StrToInt(_str);
 except
  WriteC(12,'����७ ��ன ��ࠬ��� �������!'+#13#10#13#10);
  CloseHandle(_hfile);
  Exit;
 end;
 _typ:=UpCase(_typ);
 /////////////////////////////////////////////
 _i:=GetFileSize(_hfile,nil);
 case _typ of
  'V':
   begin
   if not ((_ind>=1)and(_ind<=10000)) then
    begin
    WriteC(12,'������ ������ V-��६�����! ����᪠���� 1..10000'+#13#10#13#10);
    Exit;
    end;
   temp[0]:=Min(_ind+_c-1,10000);
   temp[1]:=(temp[0]-_ind+1)*4;
   temp[3]:=Min(temp[1],_i);
   GetMem(buffer,temp[3]);
   FileRead(_hfile,buffer^,temp[3]);
   WriteProcessMemory(h3Main,@pv^[_ind],buffer,temp[3],temp[2]);
   Writeln('���� �ᯥ譮 ����㦥�'+#13#10);
   FreeMem(buffer,temp[3]);
   CloseHandle(_hfile);
   Exit;
   end;
  'F':
   begin
   if not ((_ind>=1)and(_ind<=10000)) then
    begin
    WriteC(12,'������ ������ 䫠��! ����᪠���� 1..1000'+#13#10#13#10);
    Exit;
    end;
   temp[0]:=Min(_ind+_c-1,1000);
   temp[1]:=(temp[0]-_ind+1);
   temp[3]:=Min(temp[1],_i);
   GetMem(buffer,temp[3]);
   FileRead(_hfile,buffer^,temp[3]);
   WriteProcessMemory(h3Main,@pf^[_ind],buffer,temp[3],temp[2]);
   Writeln('���� �ᯥ譮 ����㦥�'+#13#10);
   FreeMem(buffer,temp[3]);
   CloseHandle(_hfile);
   Exit;
   end;
  'Z':
   begin
   if not ((_ind>=1)and(_ind<=1000)) then
    begin
    WriteC(12,'������ ������ Z-��६�����! ����᪠���� 1..1000'+#13#10#13#10);
    Exit;
    end;
   temp[0]:=Min(_ind+_c-1,10000);
   temp[1]:=(temp[0]-_ind+1)*512;
   temp[3]:=Min(temp[1],_i);
   GetMem(buffer,temp[3]);
   FileRead(_hfile,buffer^,temp[3]);
   WriteProcessMemory(h3Main,@pz^[_ind],buffer,temp[3],temp[2]);
   Writeln('���� �ᯥ譮 ����㦥�'+#13#10);
   FreeMem(buffer,temp[3]);
   CloseHandle(_hfile);
   Exit;
   end;
  'W':
   begin
   if not ((_ind>=1)and(_ind<=200)) then
    begin
    WriteC(12,'������ ������ W-��६�����! ����᪠���� 1..200'+#13#10#13#10);
    Exit;
    end;
   temp[0]:=Min(_ind+_c-1,200);
   temp[1]:=(temp[0]-_ind+1)*4;
   temp[3]:=Min(temp[1],_i);
   GetMem(buffer,temp[3]);
   FileRead(_hfile,buffer^,temp[3]);
   WriteProcessMemory(h3Main,@pw^[hero,_ind],buffer,temp[3],temp[2]);
   Writeln('���� �ᯥ譮 ����㦥�'+#13#10);
   FreeMem(buffer,temp[3]);
   CloseHandle(_hfile);
   Exit;
   end;
  else
   begin
   WriteC(12,'��������� ⨯ ��६�����! ����᪠���� V,F,W � Z'+#13#10#13#10);
   CloseHandle(_hfile);
   Exit;
   end;
 end;//of case
 end;

function _ScanZero(_p:pchar;_n:integer):integer;
var _r,_sp:pointer;
 begin
 _r:=nil;
 _sp:=_p;
 While TRUE do
  begin
  if _p^=#0 then begin _r:=_p; Break; end;
  _n:=_n-1;
  if _n=0 then Break;
  integer(_p):=integer(_p)+1;
  end;
 _ScanZero:=integer(_r)-integer(_sp);
 end;

Procedure CmdReadVar;
var _i,_c:integer;_typ:char;_p:pointer;_pnew:pointer;
_pi:^integer absolute _pnew;
_pw:^smallint absolute _pnew;
_pb:^shortint absolute _pnew;
_pz:pchar absolute _pnew;
_pc:pchar absolute _pnew;
_str:string;

 begin
 WriteC(10,'�⥭�� ��६����� �� �����  ');
 Readln(_str);
 _str:=Trim(_str);
 _i:=Pos(#32,_str);
 if _i=0 then
  begin
  WriteC(12,'�� 㪠��� ⨯ ��६�����!'+#13#10#13#10);
  Exit;
  end;
 try
  integer(_p):=StrToInt(LeftStr(_str,_i-1));
  _str:=RightStr(_str,length(_str)-_i);
 except
  WriteC(12,'����७ ���� ��ࠬ��� �������!'+#13#10#13#10);
  Exit;
 end;
 _typ:=_str[1];
 _typ:=UpCase(_typ);
 if not (_typ in ['I','W','B','Z','C']) then
  begin
  WriteC(12,'������ ⨯ ��६�����! ����᪠���� I,W,B,Z � C'+#13#10#13#10);
  Exit;
  end;
 _i:=Pos(#32,_str);
 if _i=0 then _c:=1 else
 try
  _c:=StrToInt(RightStr(_str,length(_str)-1));
 except
  WriteC(12,'����७ ��⨩ ��ࠬ��� �������!'+#13#10#13#10);
  Exit;
 end;
 if _c<=0 then
  begin
  WriteC(12,'���-�� ���뢠���� ��६����� ������ ���� ����� 0!'+#13#10#13#10);
  Exit;
  end;
 case _typ of
  'I':temp[0]:=4*_c;
  'W':temp[0]:=2*_c;
  'B':temp[0]:=_c;
  'Z':temp[0]:=512*_c;
  'C':temp[0]:=_c;
 end;//of case
 temp[2] :=1;//signed
 if _typ in ['W','B'] then
  begin
  write('��������(1) ��� ���(0): ');
  char(temp[3]):=ReadKey;
  if char(temp[3])='1' then writeln('��������')
  else begin temp[2]:=0; writeln('�����������'); end;
  end;
 GetMem(buffer,temp[0]);
 ReadProcessMemory(h3Main,_p,buffer,temp[0],temp[1]);
 if temp[1]=0 then
  begin
  WriteC(12,'�� 㤠���� ������ ��६����!'+#13#10#13#10);
  Exit;
  end;
 _pnew:=buffer;
 case _typ of
  'I':
   begin
   temp[3]:=Min(temp[1] div 4,_c);
   for _i:=0 to temp[3]-1 do
    begin
    temp[4]:=_i mod 4;
    if temp[4]=0 then WriteC(7,Format('%p',[_p])+'   ');
    if temp[2]=1 then write(_pi^,#32)
    else write(cardinal(_pi^),#32);
    integer(_p):=integer(_p)+4;
    integer(_pi):=integer(_pi)+4;
    if temp[4]=3 then Writeln;
    end;
   end;
  'W':
   begin
   temp[3]:=Min(temp[1] div 2,_c);
   for _i:=0 to temp[3]-1 do
    begin
    temp[4]:=_i mod 4;
    if temp[4]=0 then WriteC(7,Format('%p',[_p])+'   ');
    if temp[2]=1 then write(_pw^,#32)
    else write(smallword(_pw^),#32);
    integer(_p):=integer(_p)+2;
    integer(_pi):=integer(_pi)+2;
    if temp[4]=3 then Writeln;
    end;
   end;
  'B':
   begin
   temp[3]:=Min(temp[1],_c);
   for _i:=0 to temp[3]-1 do
    begin
    temp[4]:=_i mod 4;
    if temp[4]=0 then WriteC(7,Format('%p',[_p])+'   ');
    if temp[2]=1 then write(_pb^,#32)
    else write(byte(_pb^),#32);
    integer(_p):=integer(_p)+1;
    integer(_pb):=integer(_pb)+1;
    if temp[4]=3 then Writeln;
    end;
   end;
  'Z':
   begin
   temp[3]:=Min(temp[1],_c);
   for _i:=0 to temp[3]-1 do
    begin
    WriteC(7,Format('%p:',[_p])+#13#10);
    temp[4]:=integer(_ScanZero(_pz,temp[1]));
    if temp[4]=0 then begin writeln; Break; end;
    SetLength(_str,temp[4]);
    Move(_pz^,_str[1],temp[4]);
    AnsiToOEM(@_str[1],@_str[1]);
    Writeln(_str,#13#10);
    integer(_pz):=integer(_pz)+temp[4]+1;
    temp[1]:=temp[1]-temp[4]-1;
    integer(_p):=integer(_p)+temp[4]+1;
    if temp[1]=0 then Break;
    end;
   FreeMem(buffer,temp[0]);
   Exit;
   end;
  'C':
   begin
   temp[3]:=Min(temp[1],_c);
   WriteC(7,Format('%p:',[_p])+#13#10);
   for _i:=0 to temp[3]-1 do
    begin
    CharToOemBuff(_pc,_pc,1);
    write(_pc^);
    integer(_pc):=integer(_pc)+1;
    end;
   end;
 end;//of case
 FreeMem(buffer,temp[0]);
 Writeln(#13#10);
 end;

Procedure CmdGetVarAddress;
var _ind:integer;_typ:char;
_str:string;

 begin
 WriteC(10,'������� ���� ��� ��६�����  ');
 Readln(_str);
 _str:=Trim(_str);
 if length(_str)<2 then
  begin
  WriteC(12,'������ ��ࠬ��� �������!'+#13#10#13#10);
  Exit;
  end;
 try
  _ind:=StrToInt(RightStr(_str,length(_str)-1));
 except
  WriteC(12,'������ ��ࠬ��� �������!!'+#13#10#13#10);
  Exit;
 end;
 _typ:=UpCase(_str[1]);
 if not (_typ in ['V','W','Z','F']) then
  begin
  WriteC(12,'��������� ⨯ ��६�����! ����᪠���� V,F,W � Z'+#13#10#13#10);
  Exit;
  end;
 case _typ of
  'V':
   begin
   if not ((_ind>=1)and(_ind<=10000)) then
    begin
    WriteC(12,'������ ������ V-��६�����! ����᪠���� 1..10000'+#13#10#13#10);
    Exit;
    end;
   Write('����: ');
   WriteC(7,Format('%p (',[@pv^[_ind]])+IntToStr(integer(@pv^[_ind]))+')'#13#10#13#10);
   end;
  'F':
   begin
   if not ((_ind>=1)and(_ind<=10000)) then
    begin
    WriteC(12,'������ ������ 䫠��! ����᪠���� 1..1000'+#13#10#13#10);
    Exit;
    end;
   Write('����: ');
   WriteC(7,Format('%p (',[@pf^[_ind]])+IntToStr(integer(@pf^[_ind]))+')'#13#10#13#10);
   end;
  'Z':
   begin
   if not ((_ind>=1)and(_ind<=1000)) then
    begin
    WriteC(12,'������ ������ Z-��६�����! ����᪠���� 1..1000'+#13#10#13#10);
    Exit;
    end;
   Write('����: ');
   WriteC(7,Format('%p (',[@pz^[_ind]])+IntToStr(integer(@pz^[_ind]))+')'#13#10#13#10);
   end;
  'W':
   begin
   if not ((_ind>=1)and(_ind<=200)) then
    begin
    WriteC(12,'������ ������ W-��६�����! ����᪠���� 1..200'+#13#10#13#10);
    Exit;
    end;
   Write('����: ');
   WriteC(7,Format('%p (',[@pw^[hero,_ind]])+IntToStr(integer(@pw^[hero,_ind]))+')'#13#10#13#10);
   end;
 end;//of case
 end;

Procedure CmdMoveBlock;
var _i,_c,_a1,_a2:integer;_typ:char;
_str:string;

 begin
 WriteC(10,'����஢���� ����� �����  ');
 Readln(_str);
 _str:=Trim(_str);
 if length(_str)=0 then
  begin
  WriteC(12,'�� 㪠���� ��ࠬ���� �������!'+#13#10#13#10);
  Exit;
  end;
 _i:=Pos(#32,_str);
 if _i=0 then
  begin
  WriteC(12,'�� 㪠��� ��ன ��ࠬ��� �������!'+#13#10#13#10);
  Exit;
  end;
 try
  _a1:=StrToInt(LeftStr(_str,_i-1));
  _str:=RightStr(_str,length(_str)-_i);
 except
  WriteC(12,'����७ ���� ��ࠬ��� �������!'+#13#10#13#10);
  Exit;
 end;
 _i:=Pos(#32,_str);
 if _i=0 then
  begin
  WriteC(12,'�� 㪠��� ��⨩ ��ࠬ��� �������!'+#13#10#13#10);
  Exit;
  end;
 try
  _a2:=StrToInt(LeftStr(_str,_i-1));
  _str:=RightStr(_str,length(_str)-_i);
 except
  WriteC(12,'����७ ��ன ��ࠬ��� �������!'+#13#10#13#10);
  Exit;
 end;
 try
  _c:=StrToInt(RightStr(_str,length(_str)-_i));
 except
  WriteC(12,'����७ ��⨩ ��ࠬ��� �������!'+#13#10#13#10);
  Exit;
 end;
 if _c<=0 then
  begin
  WriteC(12,'���-�� ���� ������ ���� ����� ���!'+#13#10#13#10);
  Exit;
  end;
 GetMem(buffer,_c);
 ReadProcessMemory(h3Main,Pointer(_a1),buffer,_c,temp[0]);
 if temp[0]=0 then
  begin
  WriteC(12,'��㤠筠� ����⪠ �⥭�� �����!'+#13#10#13#10);
  Exit;
  end;
 WriteProcessMemory(h3Main,pointer(_a2),buffer,temp[0],temp[1]);
 Writeln('���� ࠧ��஬ ',Min(temp[0],temp[1]),' ���� 㤠筮 ᪮��஢��'+#13#10);
 FreeMem(buffer,_c);
 end;

Procedure CmdWriteVar;
var _i,_c:integer;_typ:char;_p:pointer;
_str:string;

 begin
 WriteC(10,'������ ��६����� �� �����  ');
 Readln(_str);
 _str:=Trim(_str);
 _i:=Pos(#32,_str);
 if _i=0 then
  begin
  WriteC(12,'�� 㪠��� ⨯ ��६�����!'+#13#10#13#10);
  Exit;
  end;
 try
  integer(_p):=StrToInt(LeftStr(_str,_i-1));
  _str:=RightStr(_str,length(_str)-_i);
 except
  WriteC(12,'����७ ���� ��ࠬ��� �������!'+#13#10#13#10);
  Exit;
 end;
 _typ:=_str[1];
 _typ:=UpCase(_typ);
 if not (_typ in ['I','W','B','Z','C']) then
  begin
  WriteC(12,'������ ⨯ ��६�����! ����᪠���� I,W,B,Z � C'+#13#10#13#10);
  Exit;
  end;
 _i:=Pos(#32,_str);
 if _i=0 then
  begin
  WriteC(12,'�� 㪠���� ����� ���祭��!'+#13#10#13#10);
  Exit;
  end;
 _str:=rightstr(_str,length(_str)-_i);
 temp[2] :=1;//signed
 if _typ in ['W','B'] then
  begin
  write('��������(1) ��� ���(0): ');
  char(temp[3]):=ReadKey;
  if char(temp[3])='1' then writeln('��������')
  else begin temp[2]:=0; writeln('�����������'); end;
  end;
 case _typ of
  'I':
   begin
   while (length(_str)>0) do
    begin
    _c:=Pos(#32,_str);
    if _c=0 then _c:=length(_str)+1;
    try
    _i:=StrToInt(LeftStr(_str,_c-1));
    _str:=RightStr(_str,length(_str)-_c);
    except
    WriteC(12,'�����४⭮� ����� ���祭�� ��६�����! ���祭��: '+LeftStr(_str,_c-1)+#13#10#13#10);
    Exit;
    end;
    WriteProcessMemory(h3Main,_p,@_i,4,temp[3]);
    if temp[3]<>4 then
     begin
     WriteC(12,'�訡�� ����� integer � ����� �� ����� '+Format('%p',[_p])+#13#10#13#10);
     Exit;
     end;
    integer(_p):=integer(_p)+4;
    end;
   Writeln('����� ����� 㤠筮 �������'+#13#10);
   end;
  'W':
   begin
   while (length(_str)>0) do
    begin
    _c:=Pos(#32,_str);
    if _c=0 then _c:=length(_str)+1;
    try
    _i:=StrToInt(LeftStr(_str,_c-1));
    _str:=RightStr(_str,length(_str)-_c);
    except
    WriteC(12,'�����४⭮� ����� ���祭�� ��६�����! ���祭��: '+LeftStr(_str,_c-1)+#13#10#13#10);
    Exit;
    end;
    if temp[2]=1 then smallint(_i):=_i;
    WriteProcessMemory(h3Main,_p,@_i,2,temp[3]);
    if temp[3]<>2 then
     begin
     WriteC(12,'�訡�� ����� word � ����� �� ����� '+Format('%p',[_p])+#13#10#13#10);
     Exit;
     end;
    integer(_p):=integer(_p)+2;
    end;
   Writeln('����� ����� 㤠筮 �������'+#13#10);
   end;
  'B':
   begin
   while (length(_str)>0) do
    begin
    _c:=Pos(#32,_str);
    if _c=0 then _c:=length(_str)+1;
    try
    _i:=StrToInt(LeftStr(_str,_c-1));
    _str:=RightStr(_str,length(_str)-_c);
    except
    WriteC(12,'�����४⭮� ����� ���祭�� ��६�����! ���祭��: '+LeftStr(_str,_c-1)+#13#10#13#10);
    Exit;
    end;
    if temp[2]=1 then shortint(_i):=_i;
    WriteProcessMemory(h3Main,_p,@_i,1,temp[3]);
    if temp[3]<>1 then
     begin
     WriteC(12,'�訡�� ����� byte � ����� �� ����� '+Format('%p',[_p])+#13#10#13#10);
     Exit;
     end;
    integer(_p):=integer(_p)+1;
    end;
   Writeln('����� ����� 㤠筮 �������'+#13#10);
   end;
  'Z':
   begin
   if _str='#0' then _str:=#0;
   OEMToAnsi(@_str[1],@_str[1]);
   WriteProcessMemory(h3Main,_p,@_str[1],length(_str)+1,temp[2]);
   Writeln('�ᯥ譮 ����ᠭ� ',temp[2],' ����'+#13#10);
   end;
  'C':
   begin
   OEMToAnsi(@_str[1],@_str[1]);
   WriteProcessMemory(h3Main,_p,@_str[1],length(_str),temp[2]);
   Writeln('�ᯥ譮 ����ᠭ� ',temp[2],' ����'+#13#10);
   end;
 end;//of case
 end;

Procedure DispatchKey;
 begin
 Case key of
  'C':CmdClear;
  'H':ShowHelp;
  'G':CmdGetVar;
  'S':CmdSetVar;
  'F':CmdFillVar;
  'I':CmdVarToVar;
  'R':CmdReadVar;
  'W':CmdWriteVar;
  'D':CmdDumpVar;
  'L':CmdLoadVar;
  'A':CmdGetVarAddress;
  'M':CmdMoveBlock;
  'Q':CmdChooseHero;
  #27:Halt;
 else
  begin
  WriteC(12,'�������⭠� �������!'+#13#10#13#10);
  Exit;
  end;
 end;//of case
 end;

Begin
InitConsole;
with NewSize do
 begin
 Left:=0;
 Top:=0;
 Right:=79;
 Bottom:=49;
 end;
SetConsoleWindowInfo(ConOut,TRUE,NewSize);
SetConsoleSize(80,1000);
WriteC(12,'ERM VARS MEMORY EDITOR v1.0 by Berserker'+#13#10);
WriteC(7,'------------------------------------------------------'+#13#10);
WriteC(14,'�롥�� ����:'+#13#10);
temp[0]:=ShowMenu(0,3,15,0,0,15,2,TRUE,1,['WoG 3.58f','Wog 3.59, TE, Phoenix']);
if temp[0]=255 then Exit;
ClrScr;
if temp[0]=0 then
 begin
 pv:=pointer($25543F8);
 pz:=pointer($265CC78);
 pf:=pointer($2585550);
 pw:=pointer($255E038);
 end;
//------------------------------------------------------------------
WriteC(12,'ERM VARS MEMORY EDITOR v1.0 by Berserker'+#13#10);
WriteC(7,'------------------------------------------------------'+#13#10);
Assign(f, 'Title.dat');
Reset(f);
Read(f,st);
Close(f);
wndname:=st;
Write('���� ����饭���� �ਫ������ HMM3.5 WoG...');
While TRUE do
 begin
 hwnd:=FindWindow(nil,'Heroes of Might and Magic III');
 if hwnd=0 then hwnd:=FindWindow(nil,@wndname[1]);
 if hwnd<>0 then Break;
 sleep(300);
 end;
 Write('   - ');
 WriteC(10,'OK'+#13#10);
GetWindowThreadProcessID(hwnd,@h3ID);
h3Main:=OpenProcess(PROCESS_ALL_ACCESS,FALSE,h3ID);
WriteC(11,'��⮢ � ࠡ��!'+#13#10#13#10);
ShowHelp;
While True do
 begin
 key:=ReadKey;
 if key=#0 then Continue;
 key:=UpCase(key);
 DispatchKey;
 end;
End.
