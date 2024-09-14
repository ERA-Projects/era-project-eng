unit Editor;
{
DESCRIPTION:  Editor internal functions, variables, data structures and constants.
AUTHOR:       Alexander Shostak (aka Berserker aka EtherniDee aka BerSoft)
}

(***)  interface  (***)

uses
  SysUtils;

const
  (* Game versions *)
  AB_AND_SOD = 3;
    

type
  TMAlloc = function (Size: integer): pointer; cdecl;
  TMFree  = procedure (Addr: pointer); cdecl;

const
  MAlloc: TMAlloc = Ptr($504A8E);
  MFree:  TMFree  = Ptr($504AB7);

  GameVersion: PINTEGER = Ptr($596F58);

(***)  implementation   (***)



end.