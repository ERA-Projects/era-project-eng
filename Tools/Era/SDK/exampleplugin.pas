library ExamplePlugin;
(*
  Description: CTRL + LMB on map object to delete it
  Author:      Berserker aka EtherniDee.
*)

uses SysUtils, Era;

const
  ADV_MAP   = 37;
  CTRL_LMB  = 4;
  LMB_PUSH  = 12;

procedure OnAdventureMapLeftMouseClick (Event: PEvent); stdcall;
begin
  ExecErmCmd('CM:I?y1 F?y2 S?y3;');

  if (y[1] = ADV_MAP) AND (y[2] = CTRL_LMB) and (y[3] = LMB_PUSH) then begin
    ExecErmCmd('CM:R0 P?y1/?y2/?y3;');
    ExecErmCmd('UN:Ey1/y2/y3;');

    if f[1] THEN begin
      ExecErmCmd('UN:Oy1/y2/y3/1;');
      ExecErmCmd('IF:L^{~red}Object was deleted!{~}^;');
    end;
  end;
end;

begin
  RegisterHandler(OnAdventureMapLeftMouseClick, 'OnAdventureMapLeftMouseClick');
end.
