library EraMap;
{
DESCRIPTION:  WoG Editor, adapted to Era
AUTHOR:       Alexander Shostak (aka Berserker aka EtherniDee aka BerSoft)
}

uses
  VFS,
  BinPatching in '..\Era\BinPatching.pas',
  EraLog      in '..\Era\EraLog.pas',
  Json        in '..\Era\Json.pas',
  MapExt, Tweaks, MapObjMan, Lodman;
  
const
  INIT_HANDLER_ADDR_HOLDER = $5AA9B8;

begin
  pinteger(INIT_HANDLER_ADDR_HOLDER)^ := integer(@MapExt.AsmInit);
end.
