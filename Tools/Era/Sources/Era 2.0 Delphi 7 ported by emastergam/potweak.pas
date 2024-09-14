UNIT PoTweak;
{
DESCRIPTION:  Fixing Erm PO command to support maps of any size
AUTHOR:       Alexander Shostak (aka Berserker aka EtherniDee aka BerSoft)
}

(***)  INTERFACE  (***)
USES Core, GameExt, Heroes, Stores;

CONST
  FILE_SECTION_NAME = 'EraPO';


TYPE
  PSquare = ^TSquare;
  TSquare = INTEGER;

  PSquare2  = ^TSquare2;
  TSquare2  = PACKED ARRAY [0..15] OF BYTE;


CONST
  ErmSquare:  ^PSquare  = Ptr($27C9678);
  ErmSquare2: ^PSquare2 = Ptr($9A48A0);


VAR
  Squares:  ARRAY OF BYTE;
  Squares2: ARRAY OF BYTE;
  
  MapSize:        INTEGER;
  BasicPoSize:    INTEGER;
  SquaresSize:    INTEGER;
  Squares2Size:   INTEGER;
  SecondDimSize:  INTEGER;
  SecondDimSize2: INTEGER;


(***) IMPLEMENTATION (***)


PROCEDURE PatchSquaresRefs;
BEGIN
  MapSize       :=  Heroes.GetMapSize;
  BasicPoSize   :=  MapSize * MapSize * 2;
  SquaresSize   :=  BasicPoSize * SIZEOF(TSquare);
  Squares2Size  :=  BasicPoSize * SIZEOF(TSquare2);
  
  IF SquaresSize > LENGTH(Squares) THEN BEGIN
    SetLength(Squares, SquaresSize);
  END; // .IF
  IF Squares2Size > LENGTH(Squares2) THEN BEGIN
    SetLength(Squares2, Squares2Size);
  END; // .IF
  
  SecondDimSize   :=  MapSize * 2 * SIZEOF(TSquare);
  SecondDimSize2  :=  MapSize * 2 * SIZEOF(TSquare2);
  
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
END; // .PROCEDURE PatchSquaresRefs

PROCEDURE OnSavegameWrite (Event: GameExt.PEvent); STDCALL;
BEGIN
  Stores.WriteSavegameSection(SquaresSize, @Squares[0], FILE_SECTION_NAME);
  Stores.WriteSavegameSection(Squares2Size, @Squares2[0], FILE_SECTION_NAME);
END; // .PROCEDURE OnSavegameWrite

PROCEDURE OnSavegameRead (Event: GameExt.PEvent); STDCALL;
BEGIN
  Stores.ReadSavegameSection(SquaresSize, @Squares[0], FILE_SECTION_NAME);
  Stores.ReadSavegameSection(Squares2Size, @Squares2[0], FILE_SECTION_NAME);
END; // .PROCEDURE OnSavegameRead

FUNCTION Hook_ResetErm (Context: Core.PHookHandlerArgs): LONGBOOL; STDCALL;
BEGIN
  PatchSquaresRefs;
  RESULT  :=  Core.EXEC_DEF_CODE;
END; // .FUNCTION Hook_ResetErm

PROCEDURE OnAfterWoG (Event: GameExt.PEvent); STDCALL;
BEGIN
  // Disable Squares Save/Load
  PINTEGER($751189)^  :=  INTEGER($909023EB);
  PBYTE($75118D)^     :=  BYTE($90);
  PINTEGER($75196F)^  :=  INTEGER($909023EB);
  PBYTE($751973)^     :=  BYTE($90);
  
  // Disable Squares2 Save/Load
  PINTEGER($75157C)^  :=  INTEGER($909020EB);
  PBYTE($751580)^     :=  BYTE($90);
  PINTEGER($75246C)^  :=  INTEGER($909023EB);
  PBYTE($752470)^     :=  BYTE($90);
END; // .PROCEDURE OnAfterWoG

BEGIN
  GameExt.RegisterHandler(OnAfterWoG, 'OnAfterWoG');
  GameExt.RegisterHandler(OnSavegameWrite, 'OnSavegameWrite');
  GameExt.RegisterHandler(OnSavegameRead, 'OnSavegameRead');
  Core.Hook(@Hook_ResetErm, Core.HOOKTYPE_BRIDGE, 5, Ptr($7525A4));
END.
