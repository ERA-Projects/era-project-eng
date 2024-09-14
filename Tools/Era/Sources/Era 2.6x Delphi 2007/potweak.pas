unit PoTweak;
{
DESCRIPTION:  Fixing Erm PO command to support maps of any size
AUTHOR:       Alexander Shostak (aka Berserker aka EtherniDee aka BerSoft)
}

(***)  interface  (***)
uses Core, GameExt, Heroes, Stores;

const
  FILE_SECTION_NAME = 'Era.PO';
  MAX_MAP_SIZE      = 256;

type
  PSquare = ^TSquare;
  TSquare = integer;

  PSquare2  = ^TSquare2;
  TSquare2  = packed array [0..15] of byte;

const
  ErmSquare:  ^PSquare  = Ptr($27C9678);
  ErmSquare2: ^PSquare2 = Ptr($9A48A0);

var
  Squares:  array [0..MAX_MAP_SIZE * MAX_MAP_SIZE * 2 - 1] of TSquare;
  Squares2: array [0..MAX_MAP_SIZE * MAX_MAP_SIZE * 2 - 1] of TSquare2;

implementation

var
  SquaresSize:  integer;
  Squares2Size: integer;

procedure PatchSquaresRefs;
var
  MapSize:        integer;
  BasicPoSize:    integer;
  SecondDimSize:  integer;
  SecondDimSize2: integer;

begin
  MapSize         :=  Heroes.GetMapSize;
  BasicPoSize     :=  MapSize * MapSize * 2;
  SquaresSize     :=  BasicPoSize * sizeof(TSquare);
  Squares2Size    :=  BasicPoSize * sizeof(TSquare2);
  SecondDimSize   :=  MapSize * 2 * sizeof(TSquare);
  SecondDimSize2  :=  MapSize * 2 * sizeof(TSquare2);
  
  // Patch Squares
  PPOINTER($73644C)^  :=  @Squares[0];
  PPOINTER($73BB32)^  :=  @Squares[0];
  PPOINTER($73BE35)^  :=  @Squares[0];
  PPOINTER($75118F)^  :=  @Squares[0];
  PPOINTER($751975)^  :=  @Squares[0];
  PPOINTER($752B68)^  :=  @Squares[0];
  PPOINTER($752B87)^  :=  @Squares[0];
  PPOINTER($752BA0)^  :=  @Squares[0];
  PPOINTER($752BBF)^  :=  @Squares[0];
  PPOINTER($752BD8)^  :=  @Squares[0];
  PPOINTER($752BF6)^  :=  @Squares[0];
  PPOINTER($752C0F)^  :=  @Squares[0];
  PPOINTER($752C2E)^  :=  @Squares[0];
  PPOINTER($752C47)^  :=  @Squares[0];
  PPOINTER($752C66)^  :=  @Squares[0];
  
  // Patch Squares2
  PPOINTER($73BB51)^  :=  @Squares2[0];
  PPOINTER($751582)^  :=  @Squares2[0];
  PPOINTER($752472)^  :=  @Squares2[0];
  PPOINTER($752FA4)^  :=  @Squares2[0];
  
  // Patch calculating Squares addresses
  PINTEGER($736442)^  :=  SecondDimSize;
  PINTEGER($73BB28)^  :=  SecondDimSize;
  PINTEGER($73BE2B)^  :=  SecondDimSize;
  PINTEGER($752B5E)^  :=  SecondDimSize;
  PINTEGER($752B7D)^  :=  SecondDimSize;
  PINTEGER($752B96)^  :=  SecondDimSize;
  PINTEGER($752BB5)^  :=  SecondDimSize;
  PINTEGER($752BCE)^  :=  SecondDimSize;
  PINTEGER($752BEC)^  :=  SecondDimSize;
  PINTEGER($752C05)^  :=  SecondDimSize;
  PINTEGER($752C24)^  :=  SecondDimSize;
  PINTEGER($752C3D)^  :=  SecondDimSize;
  PINTEGER($752C5C)^  :=  SecondDimSize;
  
  // Patch calculating Squares2 addresses
  PINTEGER($73BB44)^  :=  SecondDimSize2;
  PINTEGER($752FBD)^  :=  Squares2Size;
  
  // Fix cycles
  PINTEGER($752B14)^  :=  MapSize;
  PINTEGER($752B33)^  :=  MapSize;
end; // .procedure PatchSquaresRefs

function Hook_BeforeResetErmFunc (Context: Core.PHookContext): LONGBOOL; stdcall;
begin
  GameExt.FireEvent('$OnBeforeResetErmFunc', nil, 0);
  result := Core.EXEC_DEF_CODE;
end; // .function Hook_BeforeResetErmFunc

procedure OnSavegameWrite (Event: GameExt.PEvent); stdcall;
begin
  Stores.WriteSavegameSection(SquaresSize, @Squares[0], FILE_SECTION_NAME);
  Stores.WriteSavegameSection(Squares2Size, @Squares2[0], FILE_SECTION_NAME);
end; // .procedure OnSavegameWrite

procedure OnSavegameRead (Event: GameExt.PEvent); stdcall;
begin
  PatchSquaresRefs;
  Stores.ReadSavegameSection(SquaresSize, @Squares[0], FILE_SECTION_NAME);
  Stores.ReadSavegameSection(Squares2Size, @Squares2[0], FILE_SECTION_NAME);
end; // .procedure OnSavegameRead

procedure OnBeforeResetErmFunc (Event: GameExt.PEvent); stdcall;
begin
  PatchSquaresRefs;
end; // .procedure OnBeforeResetErmFunc

procedure OnAfterWoG (Event: GameExt.PEvent); stdcall;
begin
  // Disable Squares Save/Load
  PINTEGER($751189)^  :=  integer($909023EB);
  PBYTE($75118D)^     :=  byte($90);
  PINTEGER($75196F)^  :=  integer($909023EB);
  PBYTE($751973)^     :=  byte($90);
  
  // Disable Squares2 Save/Load
  PINTEGER($75157C)^  :=  integer($909020EB);
  PBYTE($751580)^     :=  byte($90);
  PINTEGER($75246C)^  :=  integer($909023EB);
  PBYTE($752470)^     :=  byte($90);

  // $OnBeforeResetErmFunc event for patching PO code before being inited by ERM
  Core.ApiHook(@Hook_BeforeResetErmFunc, Core.HOOKTYPE_BRIDGE, Ptr($75259E));
end; // .procedure OnAfterWoG

begin
  GameExt.RegisterHandler(OnAfterWoG, 'OnAfterWoG');
  GameExt.RegisterHandler(OnSavegameWrite, 'OnSavegameWrite');
  GameExt.RegisterHandler(OnSavegameRead, 'OnSavegameRead');
  GameExt.RegisterHandler(OnBeforeResetErmFunc, '$OnBeforeResetErmFunc');
end.
