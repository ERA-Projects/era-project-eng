library Era;
{
DESCRIPTION:  HMM 3.5 WogEra
AUTHOR:       Alexander Shostak (aka Berserker aka EtherniDee aka BerSoft)
}

uses
  VFS, GameExt, Erm, Tweaks,
  DebugMaps,
  Rainbow, Triggers, Stores, Lodman, Trans,
  AdvErm, ErmTracking, PoTweak, SndVid, EraButtons,
  EraSettings, Extern;

begin
  // set callback to GameExt unit
  Erm.v[1]  :=  integer(@GameExt.Init);
end.

