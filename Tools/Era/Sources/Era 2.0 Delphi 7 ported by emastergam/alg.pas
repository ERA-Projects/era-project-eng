UNIT Alg;
{
DESCRIPTION:  Additional math/algorithmic functions
AUTHOR:       Alexander Shostak (aka Berserker aka EtherniDee aka BerSoft)
}

(***)  INTERFACE  (***)
USES Utils;

TYPE
  {Structure used in sorting functions. Stack implementation}
  PStackItem  = ^TStackItem;
  TStackItem  = RECORD
    MinInd:   INTEGER;
    MaxInd:   INTEGER;
    PrevItem: PStackItem;
  END; // .RECORD TStackItem

  {A < B => Res < 0; A = B => Res = 0; A > B => Res > 0}
  TCompareFunc  = FUNCTION (A, B: INTEGER): INTEGER;


{Returns Ceil(Log2(N)), N > 0}
FUNCTION  IntLog2 (Num: INTEGER): INTEGER;
{Returns Int1 - Int2}
FUNCTION  IntCompare (Int1, Int2: INTEGER): INTEGER;
PROCEDURE QuickSort (Arr: Utils.PEndlessIntArr; MinInd, MaxInd: INTEGER);
PROCEDURE CustomQuickSort (Arr: Utils.PEndlessIntArr; MinInd, MaxInd: INTEGER; Compare: TCompareFunc);


(***)  IMPLEMENTATION  (***)


FUNCTION IntLog2 (Num: INTEGER): INTEGER;
VAR
  Test: INTEGER;
  
BEGIN
  {!} ASSERT(Num > 0);  // Num uses up to 31 bit
  RESULT  :=  30;
  Test    :=  1024 * 1024 * 1024;
  WHILE Test > Num DO BEGIN
    DEC(RESULT);
    Test  :=  Test SHR 1;
  END; // .WHILE
  IF Test < Num THEN BEGIN
    INC(RESULT);
  END; // .IF
END; // .FUNCTION IntLog2

FUNCTION IntCompare (Int1, Int2: INTEGER): INTEGER;
BEGIN
  RESULT  :=  Int1 - Int2;
END; // .FUNCTION IntCompare

PROCEDURE QuickSort ({!}Arr: Utils.PEndlessIntArr; {!} MinInd, MaxInd: INTEGER);
BEGIN
  CustomQuickSort({!}Arr, {!} MinInd, {!} MaxInd, IntCompare);
END; // .PROCEDURE QuickSort

PROCEDURE CustomQuickSort (Arr: Utils.PEndlessIntArr; MinInd, MaxInd: INTEGER; Compare: TCompareFunc);
VAR
(* O *) CurrStackItem:  PStackItem;
        LeftInd:        INTEGER;
        RightInd:       INTEGER;
        MiddleItem:     INTEGER;
        TransfValue:    INTEGER;

  PROCEDURE SaveBounds;
  VAR
  (* U *) PrevStackItem:  PStackItem;
    
  BEGIN
    PrevStackItem :=  CurrStackItem;
    NEW(CurrStackItem);
    CurrStackItem.PrevItem  :=  PrevStackItem;
    CurrStackItem.MinInd    :=  MinInd;
    CurrStackItem.MaxInd    :=  RightInd;
  END; // .PROCEDURE SaveBounds
  
  FUNCTION GetBounds: BOOLEAN;
  VAR
  (* U *) PrevStackItem:  PStackItem;
  
  BEGIN
    RESULT  :=  CurrStackItem <> NIL;
    IF RESULT THEN BEGIN
      MinInd        :=  CurrStackItem.MinInd;
      MaxInd        :=  CurrStackItem.MaxInd;
      PrevStackItem :=  CurrStackItem.PrevItem;
      DISPOSE(CurrStackItem);
      CurrStackItem :=  PrevStackItem;
    END; // .IF
  END; // .FUNCTION GetBounds
  
BEGIN
  {!} ASSERT(MinInd >= 0);
  IF Arr = NIL THEN BEGIN
    {!} ASSERT((MaxInd - MinInd) = -1);
  END // .IF
  ELSE BEGIN
    {!} ASSERT(MaxInd >= MinInd);
  END; // .ELSE
  {!} ASSERT(@Compare <> NIL);
  CurrStackItem :=  NIL;
  // * * * * * //
  RightInd  :=  MaxInd;
  SaveBounds;
  WHILE GetBounds DO BEGIN
    WHILE MinInd < MaxInd DO BEGIN
      LeftInd     :=  MinInd;
      RightInd    :=  MaxInd;
      MiddleItem  :=  Arr[MinInd + (MaxInd - MinInd) SHR 1];
      WHILE LeftInd <= RightInd DO BEGIN
        WHILE Compare(Arr[LeftInd], MiddleItem) < 0 DO BEGIN
          INC(LeftInd);
        END; // .WHILE
        WHILE Compare(Arr[RightInd], MiddleItem) > 0 DO BEGIN
          DEC(RightInd);
        END; // .WHILE
        IF LeftInd <= RightInd THEN BEGIN
          TransfValue   :=  Arr[LeftInd];
          Arr[LeftInd]  :=  Arr[RightInd];
          Arr[RightInd] :=  TransfValue;
          INC(LeftInd);
          DEC(RightInd);
        END; // .IF
      END; // .WHILE
      IF (RightInd - MinInd) > 0 THEN BEGIN
        SaveBounds;
      END; // .IF
      MinInd  :=  LeftInd;
    END; // .WHILE
  END; // .WHILE
END; // .PROCEDURE CustomQuickSort

END.
