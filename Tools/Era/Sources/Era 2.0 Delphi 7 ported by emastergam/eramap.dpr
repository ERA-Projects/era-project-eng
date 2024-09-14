LIBRARY EraMap;
{
DESCRIPTION:  HMM 3.5 WogEra
AUTHOR:       Alexander Shostak (aka Berserker aka EtherniDee aka BerSoft)
}

USES
  VFS, MapSettings, MapExt;
  
CONST
  INIT_HANDLER_ADDR_HOLDER  = $5AA9B8;

BEGIN
  PINTEGER(INIT_HANDLER_ADDR_HOLDER)^ :=  INTEGER(@MapExt.AsmInit);
END.
