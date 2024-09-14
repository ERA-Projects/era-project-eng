UNIT Lists;
{
DESCRIPTION:  Implementation of data structure "List" in several variants.
AUTHOR:       Alexander Shostak (aka Berserker aka EtherniDee aka BerSoft)
}

(***)  INTERFACE  (***)
USES Windows, SysUtils, Math, Classes, Utils, Alg, StrLib;

TYPE
  TList = CLASS (Utils.TCloneable)
    (***) PROTECTED (***)
{#}      FIRST_ALLOC_COUNT   :Integer;
{#}      DEFAULT_GROWTH_RATE :Integer;
      (* O  *)  fData:            (* OUn *) Utils.PEndlessPtrArr;
                fCapacity:        INTEGER;
                fCount:           INTEGER;
                fGrowthRate:      INTEGER;  // In percents, ex: 120 = 1.2 growth koefficient
                fOwnsItems:       BOOLEAN;
                fItemsAreObjects: BOOLEAN;
                fItemGuardProc:   Utils.TItemGuardProc;
      (* On *)  fItemGuard:       Utils.TItemGuard;   

      PROCEDURE FreeItem (Ind: INTEGER);
      PROCEDURE Put (Ind: INTEGER; (* OUn *) Item: POINTER);
      FUNCTION  Get (Ind: INTEGER): (* n *) POINTER;
      FUNCTION  AddEmpty: INTEGER;
    
    (***) PUBLIC (***)
      CONSTRUCTOR Create (OwnsItems: BOOLEAN; ItemsAreObjects: BOOLEAN; ItemGuardProc: Utils.TItemGuardProc; (* n *) VAR (* IN *) ItemGuard: Utils.TItemGuard);
      DESTRUCTOR  Destroy; OVERRIDE;
      PROCEDURE Assign (Source: Utils.TCloneable); OVERRIDE;
      PROCEDURE Clear;
      FUNCTION  IsValidItem ((* n *) Item: POINTER): BOOLEAN;
      PROCEDURE SetGrowthRate (NewGrowthRate: INTEGER);
      PROCEDURE SetCapacity (NewCapacity: INTEGER);
      PROCEDURE SetCount (NewCount: INTEGER);
      FUNCTION  Add ((* OUn *) Item: POINTER): INTEGER;
      FUNCTION  Top: (* n *) POINTER;
      FUNCTION  Pop: (* OUn *) POINTER;
      PROCEDURE Delete (Ind: INTEGER);
      PROCEDURE Insert ((* OUn *) Item: POINTER; Ind: INTEGER);
      PROCEDURE Exchange (SrcInd, DstInd: INTEGER);
      PROCEDURE Move (SrcInd, DstInd: INTEGER);
      PROCEDURE Shift (StartInd, Count, ShiftBy: INTEGER);
      {Returns item with specified index and NILify it in the list}
      FUNCTION  Take (Ind: INTEGER): (* OUn *) POINTER;
      {Returns old item}
      FUNCTION  Replace (Ind: INTEGER; (* OUn *) NewValue: POINTER): (* OUn *) POINTER;
      PROCEDURE Pack;
      FUNCTION  Find ((* n *) Item: POINTER; OUT Ind: INTEGER): BOOLEAN;
      {Binary search assuming list is sorted}
      FUNCTION  QuickFind ((* n *) Item: POINTER; OUT Ind: INTEGER): BOOLEAN;
      PROCEDURE Sort;
      PROCEDURE CustomSort (Compare: Alg.TCompareFunc);
      
      PROPERTY  Capacity:             INTEGER READ fCapacity;
      PROPERTY  Count:                INTEGER READ fCount;
      PROPERTY  GrowthRate:           INTEGER READ fGrowthRate;
      PROPERTY  OwnsItems:            BOOLEAN READ fOwnsItems;
      PROPERTY  ItemsAreObjects:      BOOLEAN READ fItemsAreObjects;
      PROPERTY  ItemGuardProc:        Utils.TItemGuardProc READ fItemGuardProc;
      PROPERTY  Items[Ind: INTEGER]:  (* n *) POINTER READ Get WRITE Put; DEFAULT;
  END; // .CLASS TList
  
  TStringList = CLASS;

  TStringListCompareFunc  = FUNCTION (List: TStringList; CONST Str1, Str2: STRING): INTEGER;
  
  TStringList = CLASS (Utils.TCloneable)
    (***) PROTECTED (***)
{#}      FIRST_ALLOC_COUNT   :Integer;
{#}      DEFAULT_GROWTH_RATE :Integer;
                fKeys:              Utils.TArrayOfString;
      (* O  *)  fValues:            (* OUn *) Utils.PEndlessPtrArr;
                fCapacity:          INTEGER;
                fCount:             INTEGER;
                fGrowthRate:        INTEGER;  // In percents, ex: 120 = 1.2 grow koefficient
                fOwnsItems:         BOOLEAN;
                fItemsAreObjects:   BOOLEAN;
                fItemGuardProc:     Utils.TItemGuardProc;
      (* On *)  fItemGuard:         Utils.TItemGuard;
                fCaseInsensitive:   BOOLEAN;
                fForbidDuplicates:  BOOLEAN;
                fSorted:            BOOLEAN;

      PROCEDURE FreeValue (Ind: INTEGER);
      FUNCTION  ValidateKey (CONST Key: STRING): BOOLEAN;
      PROCEDURE PutKey (Ind: INTEGER; CONST Key: STRING);
      FUNCTION  GetKey (Ind: INTEGER): STRING;
      PROCEDURE PutValue (Ind: INTEGER; (* OUn *) Item: POINTER);
      FUNCTION  GetValue (Ind: INTEGER): (* n *) POINTER;
      FUNCTION  AddEmpty: INTEGER;
      FUNCTION  CompareStrings (CONST Str1, Str2: STRING): INTEGER;
      PROCEDURE QuickSort (MinInd, MaxInd: INTEGER; Compare: TStringListCompareFunc);
      FUNCTION  QuickFind (CONST Key: STRING; (* i *) OUT Ind: INTEGER): BOOLEAN;
      PROCEDURE SetSorted (IsSorted: BOOLEAN);
      PROCEDURE EnsureNoDuplicates;
      PROCEDURE SetCaseInsensitive (NewCaseInsensitive: BOOLEAN);
      PROCEDURE SetForbidDuplicates (NewForbidDuplicates: BOOLEAN);
      FUNCTION  GetItem (CONST Key: STRING): (* n *) POINTER;
      PROCEDURE PutItem (CONST Key: STRING; (* OUn *) Value: POINTER);
    
    (***) PUBLIC (***)
      CONSTRUCTOR Create (OwnsItems: BOOLEAN; ItemsAreObjects: BOOLEAN; ItemGuardProc: Utils.TItemGuardProc; (* n *) VAR {IN} ItemGuard: Utils.TItemGuard);
      DESTRUCTOR  Destroy; OVERRIDE;
      PROCEDURE Assign (Source: Utils.TCloneable); OVERRIDE;
      PROCEDURE Clear;
      FUNCTION  IsValidItem ((* n *) Item: POINTER): BOOLEAN;
      PROCEDURE SetGrowthRate (NewGrowthRate: INTEGER);
      PROCEDURE SetCapacity (NewCapacity: INTEGER);
      PROCEDURE SetCount (NewCount: INTEGER);
      FUNCTION  AddObj (CONST Key: STRING; (* OUn *) Value: POINTER): INTEGER;
      FUNCTION  Add (CONST Key: STRING): INTEGER;
      FUNCTION  Top: STRING;
      FUNCTION  Pop ((* OUn *) OUT Item: POINTER): STRING;
      PROCEDURE Delete (Ind: INTEGER);
      PROCEDURE InsertObj (CONST Key: STRING; Value: (* OUn *) POINTER; Ind: INTEGER);
      PROCEDURE Insert (CONST Key: STRING; Ind: INTEGER);
      PROCEDURE Exchange (SrcInd, DstInd: INTEGER);
      PROCEDURE Move (SrcInd, DstInd: INTEGER);
      PROCEDURE Shift (StartInd, Count, ShiftBy: INTEGER);
      {Returns value with specified index and NILify it in the list}
      FUNCTION  TakeValue (Ind: INTEGER): (* OUn *) POINTER;
      {Returns old value}
      FUNCTION  ReplaceValue (Ind: INTEGER; (* OUn *) NewValue: POINTER): (* OUn *) POINTER;
      PROCEDURE Pack;
      {If not success then returns index, where new item should be insert to keep list sorted}
      FUNCTION  Find (CONST Key: STRING; (* i *) OUT Ind: INTEGER): BOOLEAN;
      PROCEDURE Sort;
      PROCEDURE LoadFromText (CONST Text, EndOfLineMarker: STRING);
      FUNCTION  ToText (CONST EndOfLineMarker: STRING): STRING;
      
      PROPERTY  Capacity:                 INTEGER READ fCapacity;
      PROPERTY  Count:                    INTEGER READ fCount;
      PROPERTY  GrowthRate:               INTEGER READ fGrowthRate { = DEFAULT_GROWTH_RATE};
      PROPERTY  OwnsItems:                BOOLEAN READ fOwnsItems;
      PROPERTY  ItemsAreObjects:          BOOLEAN READ fItemsAreObjects;
      PROPERTY  ItemGuardProc:            Utils.TItemGuardProc READ fItemGuardProc;
      PROPERTY  Keys[Ind: INTEGER]:       STRING READ GetKey WRITE PutKey; DEFAULT;
      PROPERTY  Values[Ind: INTEGER]:     (* n *) POINTER READ GetValue WRITE PutValue;
      PROPERTY  CaseInsensitive:          BOOLEAN READ fCaseInsensitive WRITE SetCaseInsensitive;
      PROPERTY  ForbidDuplicates:         BOOLEAN READ fForbidDuplicates WRITE SetForbidDuplicates;
      PROPERTY  Sorted:                   BOOLEAN READ fSorted WRITE SetSorted;
      PROPERTY  Items[CONST Key: STRING]: (* n *) POINTER READ GetItem WRITE PutItem;
  END; // .CLASS TStringList


FUNCTION  NewStrList (OwnsItems: BOOLEAN; ItemsAreObjects: BOOLEAN; ItemType: TClass; AllowNIL: BOOLEAN): TStringList;
FUNCTION  NewStrictList ({n} TypeGuard: TClass): TList;
FUNCTION  NewSimpleList: TList;
FUNCTION  NewList (OwnsItems: BOOLEAN; ItemsAreObjects: BOOLEAN; ItemType: TClass; AllowNIL: BOOLEAN): TList;
FUNCTION  NewStrictStrList ({n} TypeGuard: TClass): TStringList;
FUNCTION  NewSimpleStrList: TStringList;
  

(***) IMPLEMENTATION (***)


CONSTRUCTOR TList.Create (OwnsItems: BOOLEAN; ItemsAreObjects: BOOLEAN; ItemGuardProc: Utils.TItemGuardProc; (* n *) VAR (* IN *) ItemGuard: Utils.TItemGuard);
BEGIN
{#} FIRST_ALLOC_COUNT   := 16;
{#} DEFAULT_GROWTH_RATE := 200;
  {!} ASSERT(@ItemGuardProc <> NIL);
  Self.fGrowthRate      :=  Self.DEFAULT_GROWTH_RATE;
  Self.fOwnsItems       :=  OwnsItems;
  Self.fItemsAreObjects :=  ItemsAreObjects;
  Self.fItemGuardProc   :=  ItemGuardProc;
  Self.fItemGuard       :=  ItemGuard;
  ItemGuard             :=  NIL;
END; // .CONSTRUCTOR TList.Create

DESTRUCTOR TList.Destroy;
BEGIN
  Self.Clear;
  SysUtils.FreeAndNil(Self.fItemGuard);
END; // .DESTRUCTOR TList.Destroy

PROCEDURE TList.Assign (Source: Utils.TCloneable);
VAR
(* U *) SrcList:  TList;
        i:        INTEGER;
  
BEGIN
  {!} ASSERT(Source <> NIL);
  SrcList :=  Source AS TList;
  // * * * * * //
  IF Self <> Source THEN BEGIN
    Self.Clear;
    Self.fCapacity        :=  SrcList.Capacity;
    Self.fCount           :=  SrcList.Count;
    Self.fGrowthRate      :=  SrcList.GrowthRate;
    Self.fOwnsItems       :=  SrcList.OwnsItems;
    Self.fItemsAreObjects :=  SrcList.ItemsAreObjects;
    Self.fItemGuardProc   :=  SrcList.ItemGuardProc;
    Self.fItemGuard       :=  SrcList.fItemGuard.Clone;
    GetMem(Self.fData, Self.Capacity * SIZEOF(POINTER));
    FOR i:=0 TO SrcList.Count - 1 DO BEGIN
      IF (SrcList.fData[i] = NIL) OR (NOT Self.OwnsItems) THEN BEGIN
        Self.fData[i] :=  SrcList.fData[i];
      END // .IF
      ELSE BEGIN
        {!} ASSERT(Self.ItemsAreObjects);
        {!} ASSERT(TObject(SrcList.fData[i]) IS Utils.TCloneable);
        Self.fData[i] :=  Utils.TCloneable(SrcList.fData[i]).Clone;
      END; // .ELSE
    END; // .FOR
  END; // .IF
END; // .PROCEDURE TList.Assign

PROCEDURE TList.FreeItem (Ind: INTEGER);
BEGIN
  {!} ASSERT(Math.InRange(Ind, 0, Self.Count - 1));
  IF Self.OwnsItems THEN BEGIN
    IF Self.ItemsAreObjects THEN BEGIN
      SysUtils.FreeAndNil(TObject(Self.fData[Ind]));
    END // .IF
    ELSE BEGIN
      FreeMem(Self.fData[Ind]); Self.fData[Ind] :=  NIL;
    END; // .ELSE
  END; // .IF
END; // .PROCEDURE TList.FreeItem

PROCEDURE TList.Clear;
VAR
  i:  INTEGER;
  
BEGIN
  IF Self.OwnsItems THEN BEGIN
    FOR i:=0 TO Self.Count - 1 DO BEGIN
      Self.FreeItem(i);
    END; // .FOR
  END; // .IF
  FreeMem(Self.fData); Self.fData :=  NIL;
  Self.fCapacity  :=  0;
  Self.fCount     :=  0;
END; // .PROCEDURE TList.Clear

FUNCTION TList.IsValidItem ((* n *) Item: POINTER): BOOLEAN;
BEGIN
  RESULT  :=  Self.ItemGuardProc(Item, Self.ItemsAreObjects, Self.fItemGuard);
END; // .FUNCTION TList.IsValidItem

PROCEDURE TList.Put (Ind: INTEGER; (* OUn *) Item: POINTER);
BEGIN
  {!} ASSERT(Math.InRange(Ind, 0, Self.Count - 1));
  {!} ASSERT(Self.IsValidItem(Item));
  Self.FreeItem(Ind);
  Self.fData[Ind] :=  Item;
END; // .PROCEDURE TList.Put

FUNCTION TList.Get (Ind: INTEGER): (* n *) POINTER;
BEGIN
  {!} ASSERT(Math.InRange(Ind, 0, Self.Count - 1));
  RESULT  :=  Self.fData[Ind];
END; // .FUNCTION TList.Get

PROCEDURE TList.SetGrowthRate (NewGrowthRate: INTEGER);
BEGIN
  {!} ASSERT(NewGrowthRate >= 100);
  Self.fGrowthRate  :=  NewGrowthRate;
END; // .PROCEDURE TList.SetGrowthRate

PROCEDURE TList.SetCapacity (NewCapacity: INTEGER);
VAR
  i:  INTEGER;
  
BEGIN
  {!} ASSERT(NewCapacity >= 0);
  IF NewCapacity < Self.Count THEN BEGIN
    FOR i:=NewCapacity TO Self.Count - 1 DO BEGIN
      Self.FreeItem(i);
    END; // .FOR
  END; // .IF
  Self.fCapacity  :=  NewCapacity;
  ReallocMem(Self.fData, Self.Capacity * SIZEOF(POINTER));
END; // .PROCEDURE TList.SetCapacity

PROCEDURE TList.SetCount (NewCount: INTEGER);
VAR
  i:  INTEGER;
  
BEGIN
  {!} ASSERT(NewCount >= 0);
  IF NewCount < Self.Count THEN BEGIN
    FOR i:=NewCount TO Self.Count - 1 DO BEGIN
      Self.FreeItem(i);
    END; // .FOR
  END // .IF
  ELSE IF NewCount > Self.Count THEN BEGIN
    IF NewCount > Self.Capacity THEN BEGIN
      Self.SetCapacity(NewCount);
    END; // .IF
    FOR i:=Self.Count TO NewCount - 1 DO BEGIN
      Self.fData[i] :=  NIL;
    END; // .FOR
  END; // .ELSEIF
  Self.fCount :=  NewCount;
END; // .PROCEDURE TList.SetCount

FUNCTION TList.AddEmpty: INTEGER;
BEGIN
  RESULT  :=  Self.Count;
  IF Self.Count = Self.Capacity THEN BEGIN
    IF Self.Capacity = 0 THEN BEGIN
      Self.fCapacity  :=  Self.FIRST_ALLOC_COUNT;
    END // .IF
    ELSE BEGIN
      Self.fCapacity  :=  Math.Max(Self.Capacity + 1, INT64(Self.Capacity) * Self.GrowthRate DIV 100);
    END; // .ELSE
    ReallocMem(Self.fData, Self.Capacity * SIZEOF(POINTER));
  END; // .IF
  Self.fData[Self.Count]  :=  NIL;
  INC(Self.fCount);
END; // .FUNCTION TList.AddEmpty

FUNCTION TList.Add ((* OUn *) Item: POINTER): INTEGER;
BEGIN
  {!} ASSERT(Self.IsValidItem(Item));
  RESULT              :=  Self.AddEmpty;
  Self.fData[RESULT]  :=  Item;
END; // .FUNCTION TList.Add

FUNCTION TList.Top: (* n *) POINTER;
BEGIN
  {!} ASSERT(Self.Count > 0);
  RESULT  :=  Self.fData[Self.Count - 1];
END; // .FUNCTION TList.Top

FUNCTION TList.Pop: (* OUn *) POINTER;
BEGIN
  RESULT  :=  Self.Top;
  DEC(Self.fCount);
END; // .FUNCTION TList.Pop

PROCEDURE TList.Delete (Ind: INTEGER);
BEGIN
  {!} ASSERT(Math.InRange(Ind, 0, Self.Count - 1));
  Self.FreeItem(Ind);
  DEC(Self.fCount);
  IF Ind < Self.Count THEN BEGIN
    Utils.CopyMem((Self.Count - Ind) * SIZEOF(POINTER), @Self.fData[Ind + 1], @Self.fData[Ind]);
  END; // .IF
END; // .PROCEDURE TList.Delete

PROCEDURE TList.Insert ((* OUn *) Item: POINTER; Ind: INTEGER);
BEGIN
  {!} ASSERT(Math.InRange(Ind, 0, Self.Count));
  IF Ind = Self.Count THEN BEGIN
    Self.Add(Item);
  END // .IF
  ELSE BEGIN
    {!} ASSERT(Self.IsValidItem(Item));
    Self.AddEmpty;
    Utils.CopyMem((Self.Count - Ind - 1) * SIZEOF(POINTER), @Self.fData[Ind], @Self.fData[Ind + 1]);
    Self.fData[Ind] :=  Item;
  END; // .ELSE
END; // .PROCEDURE TList.Insert

PROCEDURE TList.Exchange (SrcInd, DstInd: INTEGER);
BEGIN
  {!} ASSERT(Math.InRange(SrcInd, 0, Self.Count - 1));
  {!} ASSERT(Math.InRange(DstInd, 0, Self.Count - 1));
  Utils.Exchange(INTEGER(Self.fData[SrcInd]), INTEGER(Self.fData[DstInd]));
END; // .PROCEDURE TList.Exchange

PROCEDURE TList.Move (SrcInd, DstInd: INTEGER);
VAR
(* Un *)  SrcItem:  POINTER;
          Dist:     INTEGER;
  
BEGIN
  {!} ASSERT(Math.InRange(SrcInd, 0, Self.Count - 1));
  {!} ASSERT(Math.InRange(DstInd, 0, Self.Count - 1));
  IF SrcInd <> DstInd THEN BEGIN
    Dist  :=  ABS(SrcInd - DstInd);
    IF Dist = 1 THEN BEGIN
      Self.Exchange(SrcInd, DstInd);
    END // .IF
    ELSE BEGIN
      SrcItem :=  Self.fData[SrcInd];
      IF DstInd > SrcInd THEN BEGIN
        Utils.CopyMem(Dist * SIZEOF(POINTER), @Self.fData[SrcInd + 1],  @Self.fData[SrcInd]);
      END // .IF
      ELSE BEGIN
        Utils.CopyMem(Dist * SIZEOF(POINTER), @Self.fData[DstInd],      @Self.fData[DstInd + 1]);
      END; // .ELSE
      Self.fData[DstInd]  :=  SrcItem;
    END; // .ELSE
  END; // .IF
END; // .PROCEDURE TList.Move

PROCEDURE TList.Shift (StartInd, Count, ShiftBy: INTEGER);
VAR
  EndInd: INTEGER;
  Step:   INTEGER;
  i:      INTEGER;
  
BEGIN
  {!} ASSERT(Math.InRange(StartInd, 0, Self.Count - 1));
  {!} ASSERT(Count >= 0);
  Count :=  Math.EnsureRange(Count, 0, Self.Count - StartInd);
  IF (ShiftBy <> 0) AND (Count > 0) THEN BEGIN
    IF ShiftBy > 0 THEN BEGIN
      StartInd  :=  StartInd + Count - 1;
    END; // .IF
    EndInd  :=  StartInd + ShiftBy;
    Step    :=  -SIGN(ShiftBy);
    FOR i:=1 TO Count DO BEGIN
      IF Math.InRange(EndInd, 0, Self.Count - 1) THEN BEGIN
        Self.FreeItem(EndInd);
        Utils.Exchange(INTEGER(Self.fData[StartInd]), INTEGER(Self.fData[EndInd]));
        StartInd  :=  StartInd + Step;
        EndInd    :=  EndInd + Step;
      END; // .IF
    END; // .FOR
  END; // .IF
END; // .PROCEDURE TList.Shift

FUNCTION TList.Take (Ind: INTEGER): (* OUn *) POINTER;
BEGIN
  {!} ASSERT(Math.InRange(Ind, 0, Self.Count - 1));
  {!} ASSERT(Self.IsValidItem(NIL));
  RESULT          :=  Self.fData[Ind];
  Self.fData[Ind] :=  NIL;
END; // .FUNCTION TList.Take

FUNCTION TList.Replace (Ind: INTEGER; (* OUn *) NewValue: POINTER): (* OUn *) POINTER;
BEGIN
  {!} ASSERT(Math.InRange(Ind, 0, Self.Count - 1));
  {!} ASSERT(Self.IsValidItem(NewValue));
  RESULT          :=  Self.fData[Ind];
  Self.fData[Ind] :=  NewValue;
END; // .FUNCTION TList.Replace

PROCEDURE TList.Pack;
VAR
  EndInd: INTEGER;
  i:      INTEGER;
  
BEGIN
  i :=  0;
  WHILE (i < Self.Count) AND (Self.fData[i] <> NIL) DO BEGIN
    INC(i);
  END; // .WHILE
  IF i < Count THEN BEGIN
    EndInd    :=  i;
    FOR i:=i + 1 TO Self.Count - 1 DO BEGIN
      IF Self.fData[i] <> NIL THEN BEGIN
        Self.fData[EndInd]  :=  Self.fData[i];
        INC(EndInd);
      END; // .IF
    END; // .FOR
    Self.fCount :=  EndInd;
  END; // .IF
END; // .PROCEDURE TList.Pack

FUNCTION TList.Find ((* n *) Item: POINTER; OUT Ind: INTEGER): BOOLEAN;
BEGIN
  Ind :=  0;
  WHILE (Ind < Self.Count) AND (Self.fData[Ind] <> Item) DO BEGIN
    INC(Ind);
  END; // .WHILE
  RESULT  :=  Ind < Self.Count;
END; // .FUNCTION TList.Find

FUNCTION TList.QuickFind ((* n *) Item: POINTER; OUT Ind: INTEGER): BOOLEAN;
VAR
  LeftInd:    INTEGER;
  RightInd:   INTEGER;
  MiddleItem: INTEGER;

BEGIN
  RESULT    :=  FALSE;
  LeftInd   :=  0;
  RightInd  :=  Self.Count - 1;
  WHILE (NOT RESULT) AND (LeftInd <= RightInd) DO BEGIN
    Ind         :=  LeftInd + (RightInd - LeftInd) SHR 1;
    MiddleItem  :=  INTEGER(Self.fData[Ind]);
    IF INTEGER(Item) < MiddleItem THEN BEGIN
      RightInd  :=  Ind - 1;
    END // .IF
    ELSE IF INTEGER(Item) > MiddleItem THEN BEGIN
      LeftInd :=  Ind + 1;
    END // .ELSE
    ELSE BEGIN
      RESULT  :=  TRUE;
    END; // .ELSE
  END; // .WHILE
END; // .FUNCTION TList.QuickFind

PROCEDURE TList.Sort;
BEGIN
  Alg.QuickSort(@Self.fData[0], 0, Self.Count - 1);
END; // .PROCEDURE TList.Sort

PROCEDURE TList.CustomSort (Compare: Alg.TCompareFunc);
BEGIN
  Alg.CustomQuickSort(@Self.fData[0], 0, Self.Count - 1, Compare);
END; // .PROCEDURE TList.CustomSort

CONSTRUCTOR TStringList.Create (OwnsItems: BOOLEAN; ItemsAreObjects: BOOLEAN; ItemGuardProc: Utils.TItemGuardProc; (* n *) VAR {IN} ItemGuard: Utils.TItemGuard);
BEGIN
{#} FIRST_ALLOC_COUNT   := 16;
{#} DEFAULT_GROWTH_RATE := 200;
  {!} ASSERT(@ItemGuardProc <> NIL);
  Self.fGrowthRate      :=  Self.DEFAULT_GROWTH_RATE;
  Self.fOwnsItems       :=  OwnsItems;
  Self.fItemsAreObjects :=  ItemsAreObjects;
  Self.fItemGuardProc   :=  ItemGuardProc;
  Self.fItemGuard       :=  ItemGuard;
  ItemGuard             :=  NIL;
END; // .CONSTRUCTOR TStringList.Create

DESTRUCTOR TStringList.Destroy;
BEGIN
  Self.Clear;
  SysUtils.FreeAndNil(Self.fItemGuard);
END; // .DESTRUCTOR TStringList.Destroy

PROCEDURE TStringList.Assign (Source: Utils.TCloneable);
VAR
(* U *) SrcList:  TStringList;
        i:        INTEGER;
  
BEGIN
  {!} ASSERT(Source <> NIL);
  SrcList   :=  Source AS TStringList;
  // * * * * * //
  IF Self <> Source THEN BEGIN
    Self.Clear;
    Self.fKeys              :=  System.COPY(SrcList.fKeys);
    Self.fCapacity          :=  SrcList.Capacity;
    Self.fCount             :=  SrcList.Count;
    Self.fGrowthRate        :=  SrcList.GrowthRate;
    Self.fOwnsItems         :=  SrcList.OwnsItems;
    Self.fItemsAreObjects   :=  SrcList.ItemsAreObjects;
    Self.fItemGuardProc     :=  SrcList.ItemGuardProc;
    Self.fItemGuard         :=  SrcList.fItemGuard.Clone;
    Self.fCaseInsensitive   :=  SrcList.CaseInsensitive;
    Self.fForbidDuplicates  :=  SrcList.ForbidDuplicates;
    Self.fSorted            :=  SrcList.Sorted;
    GetMem(Self.fValues, Self.Count * SIZEOF(POINTER));
    FOR i:=0 TO SrcList.Count - 1 DO BEGIN
      IF (SrcList.fValues[i] = NIL) OR (NOT Self.OwnsItems) THEN BEGIN
        Self.fValues[i] :=  SrcList.fValues[i];
      END // .IF
      ELSE BEGIN
        {!} ASSERT(Self.ItemsAreObjects);
        {!} ASSERT(TObject(SrcList.fValues[i]) IS Utils.TCloneable);
        Self.fValues[i] :=  Utils.TCloneable(SrcList.fValues[i]).Clone;
      END; // .ELSE
    END; // .FOR
  END; // .IF
END; // .PROCEDURE TStringList.Assign

PROCEDURE TStringList.FreeValue (Ind: INTEGER);
BEGIN
  {!} ASSERT(Math.InRange(Ind, 0, Self.Count - 1));
  IF Self.OwnsItems THEN BEGIN
    IF Self.ItemsAreObjects THEN BEGIN
      SysUtils.FreeAndNil(TObject(Self.fValues[Ind]));
    END // .IF
    ELSE BEGIN
      FreeMem(Self.fValues[Ind]); Self.fValues[Ind] :=  NIL;
    END; // .ELSE
  END; // .IF
END; // .PROCEDURE TStringList.FreeValue

PROCEDURE TStringList.Clear;
VAR
  i:  INTEGER;
  
BEGIN
  IF Self.OwnsItems THEN BEGIN
    FOR i:=0 TO Self.Count - 1 DO BEGIN
      Self.FreeValue(i);
    END; // .FOR
  END; // .IF
  Self.fKeys  :=  NIL;
  FreeMem(Self.fValues); Self.fValues :=  NIL;
  Self.fCapacity  :=  0;
  Self.fCount     :=  0;
END; // .PROCEDURE TStringList.Clear

FUNCTION TStringList.IsValidItem ((* n *) Item: POINTER): BOOLEAN;
BEGIN
  RESULT  :=  Self.ItemGuardProc(Item, Self.ItemsAreObjects, Self.fItemGuard);
END; // .FUNCTION TStringList.IsValidItem

FUNCTION TStringList.ValidateKey (CONST Key: STRING): BOOLEAN;
VAR
  KeyInd: INTEGER;

BEGIN
  RESULT  :=  NOT Self.ForbidDuplicates;
  IF NOT RESULT THEN BEGIN
    RESULT  :=  NOT Self.Find(Key, KeyInd);
  END; // .IF
END; // .FUNCTION TStringList.ValidateKey

PROCEDURE TStringList.PutKey (Ind: INTEGER; CONST Key: STRING);
BEGIN
  {!} ASSERT(Math.InRange(Ind, 0, Self.Count - 1));
  {!} ASSERT(NOT Self.Sorted);
  IF Self.ForbidDuplicates THEN BEGIN
    {!} ASSERT((Self.CompareStrings(Self.fKeys[Ind], Key) = 0) OR Self.ValidateKey(Key));
  END; // .IF
  Self.fKeys[Ind] :=  Key;
END; // .PROCEDURE TStringList.PutKey

FUNCTION TStringList.GetKey (Ind: INTEGER): STRING;
BEGIN
  {!} ASSERT(Math.InRange(Ind, 0, Self.Count - 1));
  RESULT  :=  Self.fKeys[Ind];
END; // .FUNCTION TStringList.GetKey

PROCEDURE TStringList.PutValue (Ind: INTEGER; (* OUn *) Item: POINTER);
BEGIN
  {!} ASSERT(Math.InRange(Ind, 0, Self.Count - 1));
  IF Item <> Self.fValues[Ind] THEN BEGIN
    {!} ASSERT(Self.IsValidItem(Item));
    Self.FreeValue(Ind);
    Self.fValues[Ind] :=  Item;
  END; // .IF
END; // .PROCEDURE TStringList.PutValue

FUNCTION TStringList.GetValue (Ind: INTEGER): (* n *) POINTER;
BEGIN
  {!} ASSERT(Math.InRange(Ind, 0, Self.Count - 1));
  RESULT  :=  Self.fValues[Ind];
END; // .FUNCTION TStringList.GetValue

FUNCTION TStringList.AddEmpty: INTEGER;
BEGIN
  RESULT  :=  Self.Count;
  IF Self.Count = Self.Capacity THEN BEGIN
    IF Self.Capacity = 0 THEN BEGIN
      Self.fCapacity  :=  Self.FIRST_ALLOC_COUNT;
    END // .IF
    ELSE BEGIN
      Self.fCapacity  :=  Math.Max(Self.Capacity + 1, INT64(Self.Capacity) * Self.GrowthRate DIV 100);
    END; // .ELSE
    ReallocMem(Self.fValues, Self.Capacity * SIZEOF(POINTER));
    SetLength(Self.fKeys, Self.Capacity);
  END; // .IF
  Self.fKeys[Self.Count]    :=  '';
  Self.fValues[Self.Count]  :=  NIL;
  INC(Self.fCount);
END; // .FUNCTION TStringList.AddEmpty

PROCEDURE TStringList.SetGrowthRate (NewGrowthRate: INTEGER);
BEGIN
  {!} ASSERT(NewGrowthRate >= 100);
  Self.fGrowthRate  :=  NewGrowthRate;
END; // .PROCEDURE TStringList.SetGrowthRate

PROCEDURE TStringList.SetCapacity (NewCapacity: INTEGER);
VAR
  i:  INTEGER;
  
BEGIN
  {!} ASSERT(NewCapacity >= 0);
  IF NewCapacity < Self.Count THEN BEGIN
    FOR i:=NewCapacity TO Self.Count - 1 DO BEGIN
      Self.FreeValue(i);
    END; // .FOR
  END; // .IF
  Self.fCapacity  :=  NewCapacity;
  ReallocMem(Self.fValues, Self.Capacity * SIZEOF(POINTER));
  SetLength(Self.fKeys, Self.Capacity);
END; // .PROCEDURE TStringList.SetCapacity

PROCEDURE TStringList.SetCount (NewCount: INTEGER);
VAR
  i:  INTEGER;
  
BEGIN
  {!} ASSERT(NewCount >= 0);
  IF NewCount < Self.Count THEN BEGIN
    FOR i:=NewCount TO Self.Count - 1 DO BEGIN
      Self.FreeValue(i);
    END; // .FOR
  END // .IF
  ELSE IF NewCount > Self.Count THEN BEGIN
    IF NewCount > Self.Capacity THEN BEGIN
      Self.SetCapacity(NewCount);
    END; // .IF
    FOR i:=Self.Count TO NewCount - 1 DO BEGIN
      Self.fKeys[i]   :=  '';
      Self.fValues[i] :=  NIL;
    END; // .FOR
  END; // .ELSEIF
  Self.fCount :=  NewCount;
END; // .PROCEDURE TStringList.SetCount

FUNCTION TStringList.AddObj (CONST Key: STRING; (* OUn *) Value: POINTER): INTEGER;
VAR
  KeyInd:     INTEGER;
  KeyFound:   BOOLEAN;

BEGIN
  {!} ASSERT(Self.IsValidItem(Value));
  IF Self.ForbidDuplicates OR Self.Sorted THEN BEGIN
    KeyFound  :=  Self.Find(Key, KeyInd);
    IF Self.ForbidDuplicates THEN BEGIN
      {!} ASSERT(NOT KeyFound);
    END; // .IF
  END; // .IF
  RESULT                :=  Self.AddEmpty;
  Self.fKeys[RESULT]    :=  Key;
  Self.fValues[RESULT]  :=  Value;
  IF Self.Sorted THEN BEGIN
    Self.fSorted  :=  FALSE;
    Self.Move(RESULT, KeyInd);
    Self.fSorted  :=  TRUE;
  END; // .IF
END; // .FUNCTION TStringList.AddObj

FUNCTION TStringList.Add (CONST Key: STRING): INTEGER;
BEGIN
  RESULT  :=  Self.AddObj(Key, NIL);
END; // .FUNCTION TStringList.Add

FUNCTION TStringList.Top: STRING;
BEGIN
  {!} ASSERT(Self.Count > 0);
  RESULT  :=  Self.fKeys[Self.Count - 1];
END; // .FUNCTION TStringList.Top

FUNCTION TStringList.Pop ((* OUn *) OUT Item: POINTER): STRING;
BEGIN
  {!} ASSERT(Item = NIL);
  {!} ASSERT(Self.Count > 0);
  RESULT  :=  Self.fKeys[Self.Count - 1];
  Item    :=  Self.fValues[Self.Count - 1];
  DEC(Self.fCount);
END; // .FUNCTION TStringList.Pop

PROCEDURE TStringList.Delete (Ind: INTEGER);
BEGIN
  {!} ASSERT(Math.InRange(Ind, 0, Self.Count - 1));
  Self.FreeValue(Ind);
  Self.fKeys[Ind] :=  '';
  DEC(Self.fCount);
  IF Ind < Self.Count THEN BEGIN
    Utils.CopyMem((Self.Count - Ind) * SIZEOF(STRING),  @Self.fKeys[Ind + 1],   @Self.fKeys[Ind]);
    POINTER(Self.fKeys[Self.Count]) :=  NIL;
    Utils.CopyMem((Self.Count - Ind) * SIZEOF(POINTER), @Self.fValues[Ind + 1], @Self.fValues[Ind]);
  END; // .IF
END; // .PROCEDURE TStringList.Delete

PROCEDURE TStringList.InsertObj (CONST Key: STRING; Value: (* OUn *) POINTER; Ind: INTEGER);
VAR
  LastInd:  INTEGER;

BEGIN
  {!} ASSERT(Math.InRange(Ind, 0, Self.Count));
  IF Ind = Self.Count THEN BEGIN
    Self.AddObj(Key, Value);
  END // .IF
  ELSE BEGIN
    {!} ASSERT(NOT Self.Sorted);
    {!} ASSERT(Self.IsValidItem(Value));
    LastInd :=  Self.AddEmpty;
    Utils.CopyMem((LastInd - Ind) * SIZEOF(STRING),   @Self.fKeys[Ind],   @Self.fKeys[Ind + 1]);
    Utils.CopyMem((LastInd - Ind) * SIZEOF(POINTER),  @Self.fValues[Ind], @Self.fValues[Ind + 1]);
    POINTER(Self.fKeys[Ind])  :=  NIL;
    Self.fKeys[Ind]           :=  Key;
    Self.fValues[Ind]         :=  Value;
  END; // .ELSE
END; // .PROCEDURE TStringList.InsertObj

PROCEDURE TStringList.Insert ({!} CONST Key: STRING; {!} Ind: INTEGER);
BEGIN
  {!} Self.InsertObj(Key, NIL, Ind);
END; // .PROCEDURE TStringList.Insert

PROCEDURE TStringList.Exchange (SrcInd, DstInd: INTEGER);
BEGIN
  {!} ASSERT(Math.InRange(SrcInd, 0, Self.Count - 1));
  {!} ASSERT(Math.InRange(DstInd, 0, Self.Count - 1));
  IF SrcInd <> DstInd THEN BEGIN
    {!} ASSERT(NOT Self.Sorted);
    Utils.Exchange(INTEGER(Self.fKeys[SrcInd]),   INTEGER(Self.fKeys[DstInd]));
    Utils.Exchange(INTEGER(Self.fValues[SrcInd]), INTEGER(Self.fValues[DstInd]));
  END; // .IF
END; // .PROCEDURE TStringList.Exchange

PROCEDURE TStringList.Move (SrcInd, DstInd: INTEGER);
VAR
(* Un *)  SrcValue: POINTER;
          SrcKey:   POINTER;
          Dist:     INTEGER;
  
BEGIN
  {!} ASSERT(Math.InRange(SrcInd, 0, Self.Count - 1));
  {!} ASSERT(Math.InRange(DstInd, 0, Self.Count - 1));
  SrcValue  :=  NIL;
  SrcKey    :=  NIL;
  // * * * * * //
  IF SrcInd <> DstInd THEN BEGIN
    {!} ASSERT(NOT Self.Sorted);
    Dist  :=  SrcInd - DstInd;
    IF ABS(Dist) = 1 THEN BEGIN
      Self.Exchange(SrcInd, DstInd);
    END // .IF
    ELSE BEGIN
      SrcKey    :=  POINTER(Self.fKeys[SrcInd]);
      SrcValue  :=  Self.fValues[SrcInd];
      Utils.CopyMem(ABS(Dist) * SIZEOF(STRING),   @Self.fKeys[DstInd],    @Self.fKeys[DstInd + Math.Sign(Dist)]);
      Utils.CopyMem(ABS(Dist) * SIZEOF(POINTER),  @Self.fValues[DstInd],  @Self.fValues[DstInd + Math.Sign(Dist)]);
      POINTER(Self.fKeys[DstInd]) :=  SrcKey;
      Self.fValues[DstInd]        :=  SrcValue;
    END; // .ELSE
  END; // .IF
END; // .PROCEDURE TStringList.Move

PROCEDURE TStringList.Shift (StartInd, Count, ShiftBy: INTEGER);
VAR
  EndInd: INTEGER;
  Step:   INTEGER;
  i:      INTEGER;
  
BEGIN
  {!} ASSERT(Math.InRange(StartInd, 0, Self.Count - 1));
  {!} ASSERT(Count >= 0);
  Count :=  Math.EnsureRange(Count, 0, Self.Count - StartInd);
  IF (ShiftBy <> 0) AND (Count > 0) THEN BEGIN
    IF ShiftBy > 0 THEN BEGIN
      StartInd  :=  StartInd + Count - 1;
    END; // .IF
    EndInd  :=  StartInd + ShiftBy;
    Step    :=  -SIGN(ShiftBy);
    FOR i:=1 TO Count DO BEGIN
      IF Math.InRange(EndInd, 0, Self.Count - 1) THEN BEGIN
        Self.FreeValue(EndInd);
        Self.fKeys[EndInd]  :=  '';
        Utils.Exchange(INTEGER(Self.fKeys[StartInd]),   INTEGER(Self.fKeys[EndInd]));
        Utils.Exchange(INTEGER(Self.fValues[StartInd]), INTEGER(Self.fValues[EndInd]));
        StartInd  :=  StartInd + Step;
        EndInd    :=  EndInd + Step;
      END; // .IF
    END; // .FOR
  END; // .IF
END; // .PROCEDURE TStringList.Shift

FUNCTION TStringList.TakeValue (Ind: INTEGER): (* OUn *) POINTER;
BEGIN
  {!} ASSERT(Math.InRange(Ind, 0, Self.Count - 1));
  {!} ASSERT(Self.IsValidItem(NIL));
  RESULT            :=  Self.fValues[Ind];
  Self.fValues[Ind] :=  NIL;
END; // .FUNCTION TStringList.TakeValue

FUNCTION TStringList.ReplaceValue (Ind: INTEGER; (* OUn *) NewValue: POINTER): (* OUn *) POINTER;
BEGIN
  {!} ASSERT(Math.InRange(Ind, 0, Self.Count - 1));
  {!} ASSERT(Self.IsValidItem(NewValue));
  RESULT            :=  Self.fValues[Ind];
  Self.fValues[Ind] :=  NewValue;
END; // .FUNCTION TStringList.ReplaceValue

PROCEDURE TStringList.Pack;
VAR
  EndInd: INTEGER;
  i:      INTEGER;
  
BEGIN
  IF Self.Sorted THEN BEGIN
    i :=  0;
    WHILE (i < Self.Count) AND (Self.fKeys[i] = '') DO BEGIN
      INC(i);
    END; // .WHILE
    IF i > 0 THEN BEGIN
      Utils.CopyMem(i * SIZEOF(STRING), @Self.fKeys[i], @Self.fKeys[0]);
      System.FillChar(Self.fKeys[Count - i], i * SIZEOF(STRING), 0);
      Utils.CopyMem(i * SIZEOF(POINTER), @Self.fValues[i], @Self.fValues[0]);
      Self.fCount :=  Self.fCount - i;
    END; // .IF
  END // .IF
  ELSE BEGIN
    i :=  0;
    WHILE (i < Self.Count) AND (Self.fKeys[i] <> '') DO BEGIN
      INC(i);
    END; // .WHILE
    IF i < Count THEN BEGIN
      EndInd    :=  i;
      Self.FreeValue(i);
      FOR i:=i + 1 TO Self.Count - 1 DO BEGIN
        IF Self.fKeys[i] <> '' THEN BEGIN
          Utils.Exchange(INTEGER(Self.fKeys[EndInd]), INTEGER(Self.fKeys[i]));
          Self.fValues[EndInd]  :=  Self.fValues[i];
          INC(EndInd);
        END // .IF
        ELSE BEGIN
          Self.FreeValue(i);
        END; // .ELSE
      END; // .FOR
      Self.fCount :=  EndInd;
    END; // .IF
  END; // .ELSE
END; // .PROCEDURE TStringList.Pack

FUNCTION StringListCompareFunc (List: TStringList; CONST Str1, Str2: STRING): INTEGER;
BEGIN
  {!} ASSERT(List <> NIL);
  IF List.CaseInsensitive THEN BEGIN
    RESULT  :=  SysUtils.AnsiCompareText(Str1, Str2);
  END // .IF
  ELSE BEGIN
    RESULT  :=  SysUtils.AnsiCompareStr(Str1, Str2);
  END; // .ELSE
END; // .FUNCTION StringListCompareFunc

FUNCTION TStringList.CompareStrings (CONST Str1, Str2: STRING): INTEGER;
BEGIN
  RESULT  :=  StringListCompareFunc(Self, Str1, Str2);
END; // .FUNCTION TStringList.CompareStrings

FUNCTION TStringList.QuickFind (CONST Key: STRING; (* i *) OUT Ind: INTEGER): BOOLEAN;
VAR
  LeftInd:    INTEGER;
  RightInd:   INTEGER;
  CmpRes:     INTEGER;

BEGIN
  RESULT    :=  FALSE;
  LeftInd   :=  0;
  RightInd  :=  Self.Count - 1;
  WHILE (NOT RESULT) AND (LeftInd <= RightInd) DO BEGIN
    Ind     :=  LeftInd + (RightInd - LeftInd + 1) SHR 1;
    CmpRes  :=  Self.CompareStrings(Key, Self.fKeys[Ind]);
    IF CmpRes < 0 THEN BEGIN
      RightInd  :=  Ind - 1;
    END // .IF
    ELSE IF CmpRes > 0 THEN BEGIN
      LeftInd :=  Ind + 1;
    END // .ELSE
    ELSE BEGIN
      RESULT  :=  TRUE;
    END; // .ELSE
  END; // .WHILE
  IF NOT RESULT THEN BEGIN
    Ind :=  LeftInd;
  END; // .IF
END; // .FUNCTION TStringList.QuickFind

FUNCTION TStringList.Find (CONST Key: STRING; (* i *) OUT Ind: INTEGER): BOOLEAN;
BEGIN
  IF Self.Sorted THEN BEGIN
    RESULT  :=  Self.QuickFind(Key, Ind);
  END // .IF
  ELSE BEGIN
    Ind :=  0;
    WHILE (Ind < Self.Count) AND (Self.CompareStrings(Self.fKeys[Ind], Key) <> 0) DO BEGIN
      INC(Ind);
    END; // .WHILE
    RESULT  :=  Ind < Self.Count;
    IF NOT RESULT THEN BEGIN
      DEC(Ind);
    END; // .IF
  END; // .ELSE
END; // .FUNCTION TStringList.Find

PROCEDURE TStringList.QuickSort (MinInd, MaxInd: INTEGER; Compare: TStringListCompareFunc);
VAR
(* O *) CurrStackItem:  Alg.PStackItem;
        LeftInd:        INTEGER;
        RightInd:       INTEGER;
        MiddleItem:     STRING;

  PROCEDURE SaveBounds;
  VAR
  (* U *) PrevStackItem:  Alg.PStackItem;
    
  BEGIN
    PrevStackItem :=  CurrStackItem;
    NEW(CurrStackItem);
    CurrStackItem.PrevItem  :=  PrevStackItem;
    CurrStackItem.MinInd    :=  MinInd;
    CurrStackItem.MaxInd    :=  RightInd;
  END; // .PROCEDURE SaveBounds
  
  FUNCTION GetBounds: BOOLEAN;
  VAR
  (* U *) PrevStackItem:  Alg.PStackItem;
  
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
  IF Self.Count = 0 THEN BEGIN
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
      MiddleItem  :=  Self.fKeys[MinInd + (MaxInd - MinInd) SHR 1];
      WHILE LeftInd <= RightInd DO BEGIN
        WHILE Compare(Self, Self.fKeys[LeftInd], MiddleItem) < 0 DO BEGIN
          INC(LeftInd);
        END; // .WHILE
        WHILE Compare(Self, Self.fKeys[RightInd], MiddleItem) > 0 DO BEGIN
          DEC(RightInd);
        END; // .WHILE
        IF LeftInd <= RightInd THEN BEGIN
          Utils.Exchange(INTEGER(Self.fKeys[LeftInd]),    INTEGER(Self.fKeys[RightInd]));
          Utils.Exchange(INTEGER(Self.fValues[LeftInd]),  INTEGER(Self.fValues[RightInd]));
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
END; // .PROCEDURE TStringList.QuickSort

PROCEDURE TStringList.Sort;
BEGIN
  IF NOT Self.Sorted THEN BEGIN
    Self.fSorted  :=  TRUE;
    Self.QuickSort(0, Self.Count - 1, StringListCompareFunc);
  END; // .IF
END; // .PROCEDURE TStringList.Sort

PROCEDURE TStringList.SetSorted (IsSorted: BOOLEAN);
BEGIN
  IF IsSorted THEN BEGIN
    Self.Sort;
  END // .IF
  ELSE BEGIN
    Self.fSorted  :=  FALSE;
  END; // .ELSE
END; // .PROCEDURE TStringList.SetSorted

PROCEDURE TStringList.EnsureNoDuplicates;
VAR
  Etalon: STRING;
  i:      INTEGER;
  y:      INTEGER;
  
BEGIN
  IF Self.Sorted THEN BEGIN
    FOR i:=1 TO Self.Count - 1 DO BEGIN
      {!} ASSERT(Self.CompareStrings(Self.fKeys[i], Self.fKeys[i - 1]) <> 0);
    END; // .FOR
  END // .IF
  ELSE BEGIN
    FOR i:=0 TO Self.Count - 1 DO BEGIN
      Etalon  :=  Self.fKeys[i];
      FOR y:=i+1 TO Self.Count - 1 DO BEGIN
        {!} ASSERT(Self.CompareStrings(Etalon, Self.fKeys[y]) <> 0);
      END; // .FOR
    END; // .FOR
  END; // .ELSE
END; // .PROCEDURE TStringList.EnsureNoDuplicates

PROCEDURE TStringList.SetCaseInsensitive (NewCaseInsensitive: BOOLEAN);
BEGIN
  IF (NOT Self.CaseInsensitive) AND NewCaseInsensitive THEN BEGIN
    Self.fCaseInsensitive :=  NewCaseInsensitive;
    Self.EnsureNoDuplicates;
  END; // .IF
  Self.fCaseInsensitive :=  NewCaseInsensitive;
END; // .PROCEDURE TStringList.SetCaseInsensitive

PROCEDURE TStringList.SetForbidDuplicates (NewForbidDuplicates: BOOLEAN);
BEGIN
  IF NewForbidDuplicates <> Self.ForbidDuplicates THEN BEGIN
    IF NewForbidDuplicates THEN BEGIN
      Self.EnsureNoDuplicates;
    END; // .IF
    Self.fForbidDuplicates  :=  NewForbidDuplicates;
  END; // .IF
END; // .PROCEDURE TStringList.SetForbidDuplicates

PROCEDURE TStringList.LoadFromText (CONST Text, EndOfLineMarker: STRING);
BEGIN
  Self.Clear;
  Self.fKeys      :=  StrLib.Explode(Text, EndOfLineMarker);
  Self.fCapacity  :=  LENGTH(Self.fKeys);
  Self.fCount     :=  Self.Capacity;
  GetMem(Self.fValues, Self.Count * SIZEOF(POINTER));
  System.FillChar(Self.fValues[0], Self.Count * SIZEOF(POINTER), 0);
  IF Self.Sorted THEN BEGIN
    Self.fSorted  :=  FALSE;
    Self.Sort;
  END; // .IF
  IF Self.ForbidDuplicates THEN BEGIN
    Self.EnsureNoDuplicates;
  END; // .IF
END; // .PROCEDURE TStringList.LoadFromText

FUNCTION TStringList.ToText (CONST EndOfLineMarker: STRING): STRING;
VAR
  ClonedKeys: Utils.TArrayOfString;

BEGIN
  IF Self.Count = Self.Capacity THEN BEGIN
    RESULT  :=  StrLib.Join(Self.fKeys, EndOfLineMarker);
  END // .IF
  ELSE BEGIN
    ClonedKeys  :=  Self.fKeys;
    SetLength(ClonedKeys, Self.Count);
    RESULT  :=  StrLib.Join(ClonedKeys, EndOfLineMarker);;
  END; // .ELSE
END; // .FUNCTION TStringList.ToText

FUNCTION TStringList.GetItem (CONST Key: STRING): (* n *) POINTER;
VAR
  Ind:  INTEGER;

BEGIN
  IF Self.Find(Key, Ind) THEN BEGIN
    RESULT  :=  Self.fValues[Ind];
  END // .IF
  ELSE BEGIN
    RESULT  :=  NIL;
  END; // .ELSE
END; // .FUNCTION TStringList.GetItem

PROCEDURE TStringList.PutItem (CONST Key: STRING; (* OUn *) Value: POINTER);
VAR
  Ind:  INTEGER;

BEGIN
  IF Self.Find(Key, Ind) THEN BEGIN
    Self.PutValue(Ind, Value);
  END // .IF
  ELSE BEGIN
    Self.AddObj(Key, Value);
  END; // .ELSE
END; // .PROCEDURE TStringList.PutItem

FUNCTION NewList (OwnsItems: BOOLEAN; ItemsAreObjects: BOOLEAN; ItemType: TClass; AllowNIL: BOOLEAN): TList;
VAR
(* O *) ItemGuard:  Utils.TDefItemGuard;

BEGIN
  {!} ASSERT(ItemsAreObjects OR (ItemType = Utils.NO_TYPEGUARD));
  ItemGuard :=  Utils.TDefItemGuard.Create;
  // * * * * * //
  ItemGuard.ItemType  :=  ItemType;
  ItemGuard.AllowNIL  :=  AllowNIL;
  RESULT              :=  TList.Create(OwnsItems, ItemsAreObjects, @Utils.DefItemGuardProc, Utils.TItemGuard(ItemGuard));
END; // .FUNCTION NewList

FUNCTION NewStrictList ({n} TypeGuard: TClass): TList;
BEGIN
  RESULT  :=  NewList(Utils.OWNS_ITEMS, Utils.ITEMS_ARE_OBJECTS, TypeGuard, Utils.ALLOW_NIL);
END; // .FUNCTION NewStrictList

FUNCTION NewSimpleList: TList;
VAR
(* n *) ItemGuard:  Utils.TCloneable; 

BEGIN
  ItemGuard :=  NIL;
  // * * * * * //
  RESULT  :=  TList.Create(NOT Utils.OWNS_ITEMS, NOT Utils.ITEMS_ARE_OBJECTS, @Utils.NoItemGuardProc, ItemGuard);
END; // .FUNCTION NewSimpleList

FUNCTION NewStrList (OwnsItems: BOOLEAN; ItemsAreObjects: BOOLEAN; ItemType: TClass; AllowNIL: BOOLEAN): TStringList;
VAR
(* O *) ItemGuard:  Utils.TDefItemGuard;

BEGIN
  {!} ASSERT(ItemsAreObjects OR (ItemType = Utils.NO_TYPEGUARD));
  ItemGuard :=  Utils.TDefItemGuard.Create;
  // * * * * * //
  ItemGuard.ItemType  :=  ItemType;
  ItemGuard.AllowNIL  :=  AllowNIL;
  RESULT              :=  TStringList.Create(OwnsItems, ItemsAreObjects, @Utils.DefItemGuardProc, Utils.TItemGuard(ItemGuard));
END; // .FUNCTION NewStrList

FUNCTION NewStrictStrList ({n} TypeGuard: TClass): TStringList;
BEGIN
  RESULT  :=  NewStrList(Utils.OWNS_ITEMS, Utils.ITEMS_ARE_OBJECTS, TypeGuard, Utils.ALLOW_NIL);
END; // .FUNCTION NewStrictStrList

FUNCTION NewSimpleStrList: TStringList;
VAR
(* n *) ItemGuard:  Utils.TCloneable; 

BEGIN
  ItemGuard :=  NIL;
  // * * * * * //
  RESULT  :=  TStringList.Create(NOT Utils.OWNS_ITEMS, NOT Utils.ITEMS_ARE_OBJECTS, @Utils.NoItemGuardProc, ItemGuard);
END; // .FUNCTION NewSimpleStrList

END.
