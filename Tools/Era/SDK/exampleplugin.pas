LIBRARY ExamplePlugin;
{
DESCRIPTION:  CTRL + LMB on map object to delete it
AUTHOR:       Alexander Shostak (aka Berserker aka EtherniDee aka BerSoft)
}

USES SysUtils, Era;

CONST
  ADV_MAP   = 37;
  CTRL_LMB  = 4;
  LMB_PUSH  = 12;

PROCEDURE OnAdventureMapLeftMouseClick (Event: PEvent); STDCALL;
BEGIN
  ExecErmCmd('CM:I?y1 F?y2 S?y3;');
  IF (y^[1] = ADV_MAP) AND (y^[2] = CTRL_LMB) AND (y^[3] = LMB_PUSH) THEN BEGIN
    ExecErmCmd('CM:R0 P?y1/?y2/?y3;');
    ExecErmCmd('UN:Ey1/y2/y3;');
    IF f^[1] THEN BEGIN
      ExecErmCmd('UN:Oy1/y2/y3/1;');
      ExecErmCmd('IF:L^{~red}Object was deleted!{~}^;');
    END; // .IF
  END; // .IF
END; // .PROCEDURE OnAdventureMapLeftMouseClick

BEGIN
  RegisterHandler(OnAdventureMapLeftMouseClick, 'OnAdventureMapLeftMouseClick');
END.
