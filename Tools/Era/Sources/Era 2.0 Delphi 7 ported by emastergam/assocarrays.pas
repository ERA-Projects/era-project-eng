UNIT AssocArrays;
{
DESCRIPTION:  Associative array implementation
AUTHOR:       Alexander Shostak (aka Berserker aka EtherniDee aka BerSoft)
}

(*
The implementation uses binary tree and (in case of array with string keys) user provided hash function to store and retrieve data.
Tree is automatically rebalanced when critical search depth is met which is equal to 2X of balanced tree height.
Rebalancing is done by converting tree to linear node array and inserting nodes in empty tree.
*)

(***)  INTERFACE  (***)
USES SysUtils, Utils, Alg, Crypto;

CONST
  LEFT_CHILD  = FALSE;
  RIGHT_CHILD = TRUE;
  
  NO_KEY_PREPROCESS_FUNC  = NIL;


TYPE
  TChildNodeSide  = BOOLEAN;

  PAssocArrayItem = ^TAssocArrayItem;
  TAssocArrayItem = RECORD
              Key:      STRING;
    (* OUn *) Value:    POINTER;
    (* On *)  NextItem: PAssocArrayItem;
  END; // .RECORD TAssocArrayItem

  PAssocArrayNode = ^TAssocArrayNode;
  TAssocArrayNode = RECORD
            Hash:       INTEGER;
    (* O *) Item:       PAssocArrayItem;
            ChildNodes: ARRAY [LEFT_CHILD..RIGHT_CHILD] OF (* On *) PAssocArrayNode;
  END; // .RECORD TAssocArrayNode

  THashFunc           = FUNCTION (CONST Str: STRING): INTEGER;
  TKeyPreprocessFunc  = FUNCTION (CONST OrigKey: STRING): STRING;
  
  TNodeArray  = ARRAY OF (* O *) PAssocArrayNode;
  
  TLinearNodeArray  = RECORD
    NodeArray:  TNodeArray; // Nodes are sorted by hash
    NodeCount:  INTEGER;
    ItemCount:  INTEGER;
  END; // .RECORD TLinearNodeArray
  
  TAssocArray = CLASS (Utils.TCloneable)
    (***) PROTECTED (***)
      (* On *)  fRoot:              PAssocArrayNode;
                fHashFunc:          THashFunc;
      (* n *)   fKeyPreprocessFunc: TKeyPreprocessFunc;
                fOwnsItems:         BOOLEAN;
                fItemsAreObjects:   BOOLEAN;
                fItemGuardProc:     Utils.TItemGuardProc;
      (* On *)  fItemGuard:         Utils.TItemGuard;
                fItemCount:         INTEGER;
                fNodeCount:         INTEGER;
                fIterNodes:         ARRAY OF (* U *) PAssocArrayNode;
      (* U *)   fIterCurrItem:      PAssocArrayItem;
                fIterNodeInd:       INTEGER;
                fLocked:            BOOLEAN;

      
      FUNCTION  CloneItem (Item: PAssocArrayItem): (* O *) PAssocArrayItem;
      FUNCTION  CloneNode ((* n *) Node: PAssocArrayNode): (* On *) PAssocArrayNode;
      PROCEDURE FreeItemValue (Item: PAssocArrayItem);
      PROCEDURE FreeNode ((* n *) VAR {IN} Node: PAssocArrayNode);
      PROCEDURE RemoveNode ((* n *) ParentNode: PAssocArrayNode; ItemNode: PAssocArrayNode);
      PROCEDURE RemoveItem
      (
        (* n *) ParentNode: PAssocArrayNode;
                ItemNode:   PAssocArrayNode;
        (* n *) ParentItem: PAssocArrayItem;
                Item:       PAssocArrayItem
      );
      {All nodes are placed in NodeArray and disconnected from each other. Original binary tree is emptied. Nodes are sorted by hash.}
      PROCEDURE ConvertToLinearNodeArray (OUT Res: TLinearNodeArray);
      
      FUNCTION  FindItem
      (
                        Hash:       INTEGER;
                  CONST Key:        STRING;
        (* ni *)  OUT   ParentNode: PAssocArrayNode;
        (* ni *)  OUT   ItemNode:   PAssocArrayNode;
        (* ni *)  OUT   ParentItem: PAssocArrayItem;
        (* ni *)  OUT   Item:       PAssocArrayItem
      ): BOOLEAN;

    (***) PUBLIC (***)
      CONSTRUCTOR Create
      (
                          HashFunc:           THashFunc;
        (* n *)           KeyPreprocessFunc:  TKeyPreprocessFunc;
                          OwnsItems:          BOOLEAN;
                          ItemsAreObjects:    BOOLEAN;
                          ItemGuardProc:      Utils.TItemGuardProc;
        (* n *) VAR {IN}  ItemGuard:          Utils.TItemGuard
      );
      DESTRUCTOR  Destroy; OVERRIDE;
      PROCEDURE Assign (Source: Utils.TCloneable); OVERRIDE;
      PROCEDURE Clear;
      FUNCTION  GetPreprocessedKey (CONST Key: STRING): STRING;
      FUNCTION  IsValidValue ((* n *) Value: POINTER): BOOLEAN;
      FUNCTION  CalcCritDepth: INTEGER;
      PROCEDURE Rebuild;
      FUNCTION  GetValue (Key: STRING): (* n *) POINTER;
      FUNCTION  GetExistingValue (Key: STRING; (* Un *) OUT Res: POINTER): BOOLEAN;
      PROCEDURE SetValue (Key: STRING; (* OUn *) NewValue: POINTER);
      FUNCTION  DeleteItem (Key: STRING): BOOLEAN;
      {Returns value with specified key and NILify it in the array}
      FUNCTION  TakeValue (Key: STRING; (* OUn *) OUT Value: POINTER): BOOLEAN;
      {Returns old value}
      FUNCTION  ReplaceValue (Key: STRING; (* OUn *) NewValue: POINTER; (* OUn *) OUT OldValue: POINTER): BOOLEAN;
      PROCEDURE BeginIterate;
      FUNCTION  IterateNext (OUT Key: STRING; (* Un *) OUT Value: POINTER): BOOLEAN;
      PROCEDURE EndIterate;

      PROPERTY  HashFunc:           THashFunc READ fHashFunc;
      PROPERTY  KeyPreprocessFunc:  TKeyPreprocessFunc READ fKeyPreprocessFunc;
      PROPERTY  OwnsItems:          BOOLEAN READ fOwnsItems;
      PROPERTY  ItemsAreObjects:    BOOLEAN READ fItemsAreObjects;
      PROPERTY  ItemCount:          INTEGER READ fItemCount;
      PROPERTY  ItemGuardProc:      Utils.TItemGuardProc READ fItemGuardProc;
      PROPERTY  NodeCount:          INTEGER READ fNodeCount;
      PROPERTY  Locked:             BOOLEAN READ fLocked;
      PROPERTY  Items[Key: STRING]: POINTER READ (* n *) GetValue WRITE (* OUn *) SetValue; DEFAULT;
  END; // .CLASS TAssocArray

  PObjArrayNode = ^TObjArrayNode;
  TObjArrayNode = RECORD
              Hash:       INTEGER;  // Hash is encoded (* U *) Key: POINTER
    (* OUn *) Value:      POINTER;
              ChildNodes: ARRAY [LEFT_CHILD..RIGHT_CHILD] OF (* On *) PObjArrayNode;
  END; // .RECORD TObjArrayItem
  
  TObjNodeArray = ARRAY OF (* O *) PObjArrayNode;
  
  TLinearObjNodeArray = RECORD
    NodeArray:  TObjNodeArray;  // Nodes are sorted by hash
    NodeCount:  INTEGER;
  END; // .RECORD TLinearObjNodeArray
  
  TObjArray = CLASS (Utils.TCloneable)
    (***) PROTECTED (***)
      (* On *)  fRoot:            PObjArrayNode;
                fOwnsItems:       BOOLEAN;
                fItemsAreObjects: BOOLEAN;
                fItemGuardProc:   Utils.TItemGuardProc;
      (* On *)  fItemGuard:       Utils.TItemGuard;
                fNodeCount:       INTEGER;
                fIterNodes:       ARRAY OF (* U *) PObjArrayNode;
                fIterNodeInd:     INTEGER;
                fLocked:          BOOLEAN;
      
      FUNCTION  HashToKey (Hash: INTEGER): POINTER;
      FUNCTION  KeyToHash (Key: POINTER): INTEGER;
      PROCEDURE FreeNodeValue (Node: PObjArrayNode);
      PROCEDURE FreeNode ((* n *) VAR {IN} Node: PObjArrayNode);
      PROCEDURE RemoveNode ((* n *) ParentNode: PObjArrayNode; Node: PObjArrayNode);
      FUNCTION  CloneNode (Node: PObjArrayNode): (* O *) PObjArrayNode;
      {All nodes are placed in NodeArray and disconnected from each other. Original binary tree is emptied. Nodes are sorted by hash.}
      PROCEDURE ConvertToLinearNodeArray (OUT Res: TLinearObjNodeArray);

      FUNCTION  FindItem
      (
        (* n  *)      Key:        POINTER;
        (* ni *)  OUT ParentNode: PObjArrayNode;
        (* ni *)  OUT ItemNode:   PObjArrayNode
      ): BOOLEAN;

    (***) PUBLIC (***)
      CONSTRUCTOR Create
      (
                          OwnsItems:        BOOLEAN;
                          ItemsAreObjects:  BOOLEAN;
                          ItemGuardProc:    Utils.TItemGuardProc;
        (* n *) VAR {IN}  ItemGuard:        Utils.TItemGuard
      );
      DESTRUCTOR  Destroy; OVERRIDE;
      PROCEDURE Assign (Source: Utils.TCloneable); OVERRIDE;
      PROCEDURE Clear;
      FUNCTION  IsValidValue ((* n *) Value: POINTER): BOOLEAN;
      FUNCTION  CalcCritDepth: INTEGER;
      PROCEDURE Rebuild;
      FUNCTION  GetValue ((* n *) Key: POINTER): (* n *) POINTER;
      FUNCTION  GetExistingValue ((* n *) Key: POINTER; (* Un *) OUT Res: POINTER): BOOLEAN;
      PROCEDURE SetValue ((* n *) Key: POINTER; (* OUn *) NewValue: POINTER);
      FUNCTION  DeleteItem ((* n *) Key: POINTER): BOOLEAN;
      {Returns value with specified key and NILify it in the array}
      FUNCTION  TakeValue ((* n *) Key: POINTER; (* OUn *) OUT Value: POINTER): BOOLEAN;
      {Returns old value}
      FUNCTION  ReplaceValue ((* n *) Key: POINTER; (* OUn *) NewValue: POINTER; (* OUn *) OUT OldValue: POINTER): BOOLEAN;
      PROCEDURE BeginIterate;
      FUNCTION  IterateNext ((* Un *) OUT Key: POINTER; (* Un *) OUT Value: POINTER): BOOLEAN;
      PROCEDURE EndIterate;

      PROPERTY  OwnsItems:                    BOOLEAN READ fOwnsItems;
      PROPERTY  ItemsAreObjects:              BOOLEAN READ fItemsAreObjects;
      PROPERTY  ItemCount:                    INTEGER READ fNodeCount;
      PROPERTY  ItemGuardProc:                Utils.TItemGuardProc READ fItemGuardProc;
      PROPERTY  NodeCount:                    INTEGER READ fNodeCount;
      PROPERTY  Locked:                       BOOLEAN READ fLocked;
      PROPERTY  Items[(* n *) Key: POINTER]:  (* OUn *) POINTER READ GetValue WRITE SetValue; DEFAULT;
  END; // .CLASS TObjArray

FUNCTION  NewAssocArr
(
          HashFunc:           THashFunc;
  (* n *) KeyPreprocessFunc:  TKeyPreprocessFunc;
          OwnsItems:          BOOLEAN;
          ItemsAreObjects:    BOOLEAN;
          ItemType:           TClass;
          AllowNIL:           BOOLEAN
): TAssocArray;
FUNCTION  NewSimpleAssocArr (HashFunc: THashFunc; (* n *) KeyPreprocessFunc: TKeyPreprocessFunc): TAssocArray;
FUNCTION  NewStrictAssocArr ({n} TypeGuard: TClass): TAssocArray;
FUNCTION  NewObjArr (OwnsItems: BOOLEAN; ItemsAreObjects: BOOLEAN; ItemType: TClass; AllowNIL: BOOLEAN): TObjArray;
FUNCTION  NewSimpleObjArr: TObjArray;
FUNCTION  NewStrictObjArr ({n} TypeGuard: TClass): TObjArray;


(***)  IMPLEMENTATION  (***)


CONSTRUCTOR TAssocArray.Create
(
                    HashFunc:           THashFunc;
  (* n *)           KeyPreprocessFunc:  TKeyPreprocessFunc;
                    OwnsItems:          BOOLEAN;
                    ItemsAreObjects:    BOOLEAN;
                    ItemGuardProc:      Utils.TItemGuardProc;
  (* n *) VAR {IN}  ItemGuard:          Utils.TItemGuard
);
BEGIN
  {!} ASSERT(@HashFunc <> NIL);
  {!} ASSERT(@ItemGuardProc <> NIL);
  Self.fHashFunc          :=  HashFunc;
  Self.fKeyPreprocessFunc :=  KeyPreprocessFunc;
  Self.fOwnsItems         :=  OwnsItems;
  Self.fItemsAreObjects   :=  ItemsAreObjects;
  Self.fItemGuardProc     :=  ItemGuardProc;
  Self.fItemGuard         :=  ItemGuard;
  Self.fItemCount         :=  0;
  Self.fNodeCount         :=  0;
  ItemGuard               :=  NIL;
END; // .CONSTRUCTOR TAssocArray.Create

DESTRUCTOR TAssocArray.Destroy;
BEGIN
  Self.Clear;
  SysUtils.FreeAndNil(Self.fItemGuard);
END; // .DESTRUCTOR TAssocArray.Destroy

FUNCTION TAssocArray.CloneItem (Item: PAssocArrayItem): (* O *) PAssocArrayItem;
BEGIN
  {!} ASSERT(Item <> NIL);
  {!} ASSERT(Self.IsValidValue(Item.Value));
  NEW(RESULT);
  RESULT.Key  :=  Item.Key;
  IF Item.NextItem <> NIL THEN BEGIN
    RESULT.NextItem :=  Self.CloneItem(Item.NextItem);
  END // .IF
  ELSE BEGIN
    RESULT.NextItem :=  NIL;
  END; // .ELSE
  IF (Item.Value = NIL) OR (NOT Self.OwnsItems) THEN BEGIN
    RESULT.Value  :=  Item.Value;
  END // .IF
  ELSE BEGIN
    {!} ASSERT(Self.ItemsAreObjects);
    {!} ASSERT(TObject(Item.Value) IS Utils.TCloneable);
    RESULT.Value  :=  Utils.TCloneable(Item.Value).Clone;
  END; // .ELSE
END; // .FUNCTION TAssocArray.CloneItem

FUNCTION TAssocArray.CloneNode ((* n *) Node: PAssocArrayNode): (* On *) PAssocArrayNode;
BEGIN
  IF Node = NIL THEN BEGIN
    RESULT  :=  NIL;
  END // .IF
  ELSE BEGIN
    NEW(RESULT);
    RESULT.Hash                     :=  Node.Hash;
    RESULT.Item                     :=  Self.CloneItem(Node.Item);
    RESULT.ChildNodes[LEFT_CHILD]   :=  Self.CloneNode(Node.ChildNodes[LEFT_CHILD]);
    RESULT.ChildNodes[RIGHT_CHILD]  :=  Self.CloneNode(Node.ChildNodes[RIGHT_CHILD]);
  END; // .ELSE
END; // .FUNCTION TAssocArray.CloneNode

PROCEDURE TAssocArray.Assign (Source: Utils.TCloneable);
VAR
(* U *) SrcArr: TAssocArray;
  
BEGIN
  {!} ASSERT(NOT Self.Locked);
  {!} ASSERT(Source <> NIL);
  SrcArr  :=  Source AS TAssocArray;
  // * * * * * //
  IF Self <> Source THEN BEGIN
    Self.Clear;
    Self.fHashFunc          :=  SrcArr.HashFunc;
    Self.fKeyPreprocessFunc :=  SrcArr.KeyPreprocessFunc;
    Self.fOwnsItems         :=  SrcArr.OwnsItems;
    Self.fItemsAreObjects   :=  SrcArr.ItemsAreObjects;
    Self.fItemGuardProc     :=  SrcArr.ItemGuardProc;
    Self.fItemGuard         :=  SrcArr.fItemGuard.Clone;
    Self.fItemCount         :=  SrcArr.ItemCount;
    Self.fNodeCount         :=  SrcArr.NodeCount;
    Self.fRoot              :=  Self.CloneNode(SrcArr.fRoot);
  END; // .IF
END; // .PROCEDURE TAssocArray.Assign

PROCEDURE TAssocArray.FreeItemValue (Item: PAssocArrayItem);
BEGIN
  {!} ASSERT(Item <> NIL);
  IF Self.OwnsItems THEN BEGIN
    IF Self.ItemsAreObjects THEN BEGIN
      TObject(Item.Value).Free;
    END // .IF
    ELSE BEGIN
      FreeMem(Item.Value);
    END; // .ELSE
  END; // .IF
  Item.Value  :=  NIL;
END; // .PROCEDURE TAssocArray.FreeItemValue

PROCEDURE TAssocArray.RemoveNode ((* n *) ParentNode: PAssocArrayNode; ItemNode: PAssocArrayNode);
VAR
(* U *) RightClosestNodeParent: PAssocArrayNode;
(* U *) RightClosestNode:       PAssocArrayNode;
        ItemNodeIsRoot:         BOOLEAN;
        ItemNodeSide:           TChildNodeSide;
  
BEGIN
  {!} ASSERT(ItemNode <> NIL);
  RightClosestNodeParent  :=  NIL;
  RightClosestNode        :=  NIL;
  ItemNodeSide            :=  FALSE;
  // * * * * * //
  ItemNodeIsRoot  :=  ParentNode = NIL;
  IF Self.NodeCount = 1 THEN BEGIN
    DISPOSE(Self.fRoot); Self.fRoot :=  NIL;
  END // .IF
  ELSE BEGIN
    IF NOT ItemNodeIsRoot THEN BEGIN
      ItemNodeSide  :=  ItemNode.Hash >= ParentNode.Hash;
    END; // .IF
    IF (ItemNode.ChildNodes[LEFT_CHILD] = NIL) AND (ItemNode.ChildNodes[RIGHT_CHILD] = NIL) THEN BEGIN
      IF ItemNodeIsRoot THEN BEGIN
        Self.fRoot  :=  NIL;
      END // .IF
      ELSE BEGIN
        ParentNode.ChildNodes[ItemNodeSide] :=  NIL;
      END; // .ELSE
      DISPOSE(ItemNode); ItemNode :=  NIL;
    END // .IF
    ELSE IF ItemNode.ChildNodes[LEFT_CHILD] = NIL THEN BEGIN
      IF ItemNodeIsRoot THEN BEGIN
        Self.fRoot  :=  ItemNode.ChildNodes[RIGHT_CHILD];
      END // .IF
      ELSE BEGIN
        ParentNode.ChildNodes[ItemNodeSide] :=  ItemNode.ChildNodes[RIGHT_CHILD];
      END; // .ELSE
      DISPOSE(ItemNode); ItemNode :=  NIL;
    END // .ELSEIF
    ELSE IF ItemNode.ChildNodes[RIGHT_CHILD] = NIL THEN BEGIN
      IF ItemNodeIsRoot THEN BEGIN
        Self.fRoot  :=  ItemNode.ChildNodes[LEFT_CHILD];
      END // .IF
      ELSE BEGIN
        ParentNode.ChildNodes[ItemNodeSide] :=  ItemNode.ChildNodes[LEFT_CHILD];
      END; // .ELSE
      DISPOSE(ItemNode); ItemNode :=  NIL;
    END // .ELSEIF
    ELSE BEGIN
      RightClosestNodeParent  :=  ItemNode;
      RightClosestNode        :=  ItemNode.ChildNodes[RIGHT_CHILD];
      WHILE RightClosestNode.ChildNodes[LEFT_CHILD] <> NIL DO BEGIN
        RightClosestNodeParent  :=  RightClosestNode;
        RightClosestNode        :=  RightClosestNode.ChildNodes[LEFT_CHILD];
      END; // .WHILE
      ItemNode.Item :=  RightClosestNode.Item; RightClosestNode.Item  :=  NIL;
      ItemNode.Hash :=  RightClosestNode.Hash;
      Self.RemoveNode(RightClosestNodeParent, RightClosestNode);
    END; // .ELSE
  END; // .ELSE
END; // .PROCEDURE TAssocArray.RemoveNode

PROCEDURE TAssocArray.RemoveItem
(
  (* n *) ParentNode: PAssocArrayNode;
          ItemNode:   PAssocArrayNode;
  (* n *) ParentItem: PAssocArrayItem;
          Item:       PAssocArrayItem
);
BEGIN
  {!} ASSERT(ItemNode <> NIL);
  {!} ASSERT(Item <> NIL);
  Self.FreeItemValue(Item);
  IF (ItemNode.Item = Item) AND (Item.NextItem = NIL) THEN BEGIN
    Self.RemoveNode(ParentNode, ItemNode);
    DEC(Self.fNodeCount);
  END // .IF
  ELSE BEGIN
    IF ItemNode.Item = Item THEN BEGIN
      ItemNode.Item :=  Item.NextItem;
    END // .IF
    ELSE BEGIN
      ParentItem.NextItem :=  Item.NextItem;
    END; // .ELSE
  END; // .ELSE
  DISPOSE(Item); Item :=  NIL;
  DEC(Self.fItemCount);
END; // .PROCEDURE TAssocArray.RemoveItem

PROCEDURE TAssocArray.FreeNode ((* n *) VAR {IN} Node: PAssocArrayNode);
VAR
(* U *) Item:     PAssocArrayItem;
(* U *) NextItem: PAssocArrayItem;

BEGIN
  Item      :=  NIL;
  NextItem  :=  NIL;
  // * * * * * //
  IF Node <> NIL THEN BEGIN
    Item  :=  Node.Item;
    WHILE Item <> NIL DO BEGIN
      NextItem  :=  Item.NextItem;
      Self.FreeItemValue(Item);
      DISPOSE(Item); Item :=  NIL;
      Item  :=  NextItem;
    END; // .WHILE
    Self.FreeNode(Node.ChildNodes[LEFT_CHILD]);
    Self.FreeNode(Node.ChildNodes[RIGHT_CHILD]);
    DISPOSE(Node); Node :=  NIL;
  END; // .IF
END; // .PROCEDURE TAssocArray.FreeNode

PROCEDURE TAssocArray.Clear;
BEGIN
  {!} ASSERT(NOT Self.Locked);
  Self.FreeNode(Self.fRoot);
  Self.fItemCount :=  0;
  Self.fNodeCount :=  0;
END; // .PROCEDURE TAssocArray.Clear

FUNCTION TAssocArray.GetPreprocessedKey (CONST Key: STRING): STRING;
BEGIN
  IF @Self.KeyPreprocessFunc = NIL THEN BEGIN
    RESULT  :=  Key;
  END // .IF
  ELSE BEGIN
    RESULT  :=  Self.KeyPreprocessFunc(Key);
  END; // .ELSE
END; // .FUNCTION TAssocArray.GetPreprocessedKey

FUNCTION TAssocArray.IsValidValue ((* n *) Value: POINTER): BOOLEAN;
BEGIN
  RESULT  :=  Self.ItemGuardProc(Value, Self.ItemsAreObjects, Utils.TItemGuard(Self.fItemGuard));
END; // .FUNCTION TAssocArray.IsValidValue 

FUNCTION TAssocArray.CalcCritDepth: INTEGER;
BEGIN
  RESULT  :=  Alg.IntLog2(Self.NodeCount + 1) SHL 1;
END; // .FUNCTION TAssocArray.CalcCritDepth

FUNCTION AssocArrayCompareItems (A, B: INTEGER): INTEGER;
BEGIN
  IF PAssocArrayNode(A).Hash > PAssocArrayNode(B).Hash THEN BEGIN
    RESULT  :=  1;
  END // .IF
  ELSE IF PAssocArrayNode(A).Hash < PAssocArrayNode(B).Hash THEN BEGIN
    RESULT  :=  -1;
  END // .ELSEIF
  ELSE BEGIN
    RESULT  :=  0;
  END; // .ELSE
END; // .FUNCTION AssocArrayCompareItems

PROCEDURE TAssocArray.ConvertToLinearNodeArray (OUT Res: TLinearNodeArray);
VAR
        LeftInd:              INTEGER;
        RightInd:             INTEGER;
        RightCheckInd:        INTEGER;
        NumNotProcessedNodes: INTEGER;
(* U *) CurrNode:             PAssocArrayNode;
        i:                    INTEGER;
  
BEGIN
  SetLength(Res.NodeArray, Self.NodeCount);
  Res.NodeCount :=  Self.NodeCount;
  Res.ItemCount :=  Self.ItemCount;
  IF Self.NodeCount > 0 THEN BEGIN
    CurrNode                :=  Self.fRoot;
    LeftInd                 :=  0;
    Res.NodeArray[LeftInd]  :=  CurrNode;
    RightInd                :=  Self.NodeCount;
    RightCheckInd           :=  RightInd - 1;
    NumNotProcessedNodes    :=  Self.NodeCount - 1;
    WHILE NumNotProcessedNodes > 0 DO BEGIN
      IF CurrNode.ChildNodes[RIGHT_CHILD] <> NIL THEN BEGIN
        DEC(RightInd);
        Res.NodeArray[RightInd] :=  CurrNode.ChildNodes[RIGHT_CHILD];
        DEC(NumNotProcessedNodes);
      END; // .IF
      IF CurrNode.ChildNodes[LEFT_CHILD] <> NIL THEN BEGIN
        CurrNode  :=  CurrNode.ChildNodes[LEFT_CHILD];
        INC(LeftInd);
        Res.NodeArray[LeftInd]  :=  CurrNode;
        DEC(NumNotProcessedNodes);
      END // .IF
      ELSE BEGIN
        CurrNode  :=  Res.NodeArray[RightCheckInd];
        DEC(RightCheckInd);
      END; // .ELSE
    END; // .WHILE
    FOR i:=0 TO Self.NodeCount - 1 DO BEGIN
      Res.NodeArray[i].ChildNodes[LEFT_CHILD]   :=  NIL;
      Res.NodeArray[i].ChildNodes[RIGHT_CHILD]  :=  NIL;
    END; // .FOR
    Self.fRoot      :=  NIL;
    Self.fNodeCount :=  0;
    Self.fItemCount :=  0;
    Alg.CustomQuickSort(@Res.NodeArray[0], 0, Res.NodeCount - 1, AssocArrayCompareItems);
  END; // .IF
END; // .PROCEDURE TAssocArray.ConvertToLinearNodeArray

PROCEDURE TAssocArray.Rebuild;
VAR
  LinearNodeArray:  TLinearNodeArray;
  NodeArray:        TNodeArray;
  
  PROCEDURE InsertNode (InsNode: PAssocArrayNode);
  VAR
  (* U *) ParentNode: PAssocArrayNode;
  (* U *) CurrNode:   PAssocArrayNode;
    
  BEGIN
    {!} ASSERT(InsNode <> NIL);
    ParentNode  :=  NIL;
    CurrNode    :=  Self.fRoot;
    // * * * * * //
    WHILE CurrNode <> NIL DO BEGIN
      ParentNode  :=  CurrNode;
      CurrNode    :=  CurrNode.ChildNodes[InsNode.Hash >= CurrNode.Hash];
    END; // .WHILE
    ParentNode.ChildNodes[InsNode.Hash >= ParentNode.Hash]  :=  InsNode;
  END; // .PROCEDURE InsertNode
  
  PROCEDURE InsertNodeRange (MinInd, MaxInd: INTEGER);
  VAR
          RangeLen:   INTEGER;
          MiddleInd:  INTEGER;
  (* U *) InsNode:    PAssocArrayNode;
    
  BEGIN
    RangeLen  :=  MaxInd - MinInd + 1;
    {!} ASSERT(RangeLen > 0);
    {!} ASSERT((MinInd >= 0) AND (MaxInd < LENGTH(NodeArray)));
    // * * * * * //
    MiddleInd :=  (MaxInd - MinInd) SHR 1 + MinInd;
    InsNode   :=  NodeArray[MiddleInd];
    IF Self.fRoot = NIL THEN BEGIN
      Self.fRoot  :=  InsNode;
    END // .IF
    ELSE BEGIN
      InsertNode(InsNode);
    END; // .ELSE
    IF RangeLen > 2 THEN BEGIN
      InsertNodeRange(MinInd, MiddleInd - 1);
      InsertNodeRange(MiddleInd + 1, MaxInd);
    END // .IF
    ELSE IF RangeLen = 2 THEN BEGIN
      InsertNode(NodeArray[MiddleInd + 1]);
    END; // .ELSEIF
  END; // .PROCEDURE InsertNodeRange
  
BEGIN
  {!} ASSERT(NOT Self.Locked);
  IF Self.NodeCount > 2 THEN BEGIN
    Self.ConvertToLinearNodeArray(LinearNodeArray);
    Self.fNodeCount :=  LinearNodeArray.NodeCount;
    Self.fItemCount :=  LinearNodeArray.ItemCount;
    NodeArray       :=  LinearNodeArray.NodeArray;
    InsertNodeRange(0, Self.NodeCount - 1);
  END; // .IF
END; // .PROCEDURE TAssocArray.Rebuild

FUNCTION TAssocArray.FindItem
(
                  Hash:       INTEGER;
            CONST Key:        STRING;
  (* ni *)  OUT   ParentNode: PAssocArrayNode;
  (* ni *)  OUT   ItemNode:   PAssocArrayNode;
  (* ni *)  OUT   ParentItem: PAssocArrayItem;
  (* ni *)  OUT   Item:       PAssocArrayItem
): BOOLEAN;

VAR
  SearchDepth:      INTEGER;
  CritSearchDepth:  INTEGER;
  
BEGIN
  {!} ASSERT(ParentNode = NIL);
  {!} ASSERT(ItemNode = NIL);
  {!} ASSERT(ParentItem = NIL);
  {!} ASSERT(Item = NIL);
  RESULT  :=  FALSE;
  IF Self.NodeCount > 0 THEN BEGIN
    CritSearchDepth :=  Self.CalcCritDepth;
    SearchDepth     :=  1;
    ItemNode        :=  Self.fRoot;
    WHILE (ItemNode <> NIL) AND (ItemNode.Hash <> Hash) DO BEGIN
      INC(SearchDepth);
      ParentNode  :=  ItemNode;
      ItemNode    :=  ItemNode.ChildNodes[Hash >= ItemNode.Hash];
    END; // .WHILE
    IF SearchDepth > CritSearchDepth THEN BEGIN
      Self.Rebuild;
      ParentNode  :=  NIL;
      ItemNode    :=  NIL;
      ParentItem  :=  NIL;
      Item        :=  NIL;
      RESULT      :=  Self.FindItem(Hash, Key, ParentNode, ItemNode, ParentItem, Item);
    END // .IF
    ELSE IF ItemNode <> NIL THEN BEGIN
      Item  :=  ItemNode.Item;
      IF Item.NextItem <> NIL THEN BEGIN
        WHILE (Item <> NIL) AND (Self.GetPreprocessedKey(Item.Key) <> Key) DO BEGIN
          ParentItem  :=  Item;
          Item        :=  Item.NextItem;
        END; // .WHILE
      END; // .IF
      RESULT  :=  Item <> NIL;
    END; // .ELSEIF
  END; // .IF
END; // .FUNCTION TAssocArray.FindItem

FUNCTION TAssocArray.GetValue (Key: STRING): (* n *) POINTER;
VAR
(* U *) ItemNode:   PAssocArrayNode;
(* U *) ParentNode: PAssocArrayNode;
(* U *) Item:       PAssocArrayItem;
(* U *) ParentItem: PAssocArrayItem;
        Hash:       INTEGER;
  
BEGIN
  ItemNode    :=  NIL;
  ParentNode  :=  NIL;
  Item        :=  NIL;
  ParentItem  :=  NIL;
  // * * * * * //
  Key   :=  Self.GetPreprocessedKey(Key);
  Hash  :=  Self.HashFunc(Key);
  IF Self.FindItem(Hash, Key, ParentNode, ItemNode, ParentItem, Item) THEN BEGIN
    RESULT  :=  Item.Value;
  END // .IF
  ELSE BEGIN
    RESULT  :=  NIL;
  END; // .ELSE
END; // .FUNCTION TAssocArray.GetValue

FUNCTION TAssocArray.GetExistingValue (Key: STRING; (* Un *) OUT Res: POINTER): BOOLEAN;
VAR
(* U *) ItemNode:   PAssocArrayNode;
(* U *) ParentNode: PAssocArrayNode;
(* U *) Item:       PAssocArrayItem;
(* U *) ParentItem: PAssocArrayItem;
        Hash:       INTEGER;
  
BEGIN
  {!} ASSERT(Res = NIL);
  ItemNode    :=  NIL;
  ParentNode  :=  NIL;
  Item        :=  NIL;
  ParentItem  :=  NIL;
  // * * * * * //
  Key   :=  Self.GetPreprocessedKey(Key);
  Hash  :=  Self.HashFunc(Key);
  IF Self.FindItem(Hash, Key, ParentNode, ItemNode, ParentItem, Item) THEN BEGIN
    Res     :=  Item.Value;
    RESULT  :=  TRUE;
  END // .IF
  ELSE BEGIN
    RESULT  :=  FALSE;
  END; // .ELSE
END; // .FUNCTION TAssocArray.GetExistingValue

PROCEDURE TAssocArray.SetValue (Key: STRING; (* OUn *) NewValue: POINTER);
VAR
(* U *) ItemNode:         PAssocArrayNode;
(* U *) ParentNode:       PAssocArrayNode;
(* U *) Item:             PAssocArrayItem;
(* U *) ParentItem:       PAssocArrayItem;
(* O *) NewItem:          PAssocArrayItem;
(* O *) NewNode:          PAssocArrayNode;
        PreprocessedKey:  STRING;
        Hash:             INTEGER;
  
BEGIN
  ItemNode    :=  NIL;
  ParentNode  :=  NIL;
  Item        :=  NIL;
  ParentItem  :=  NIL;
  NewItem     :=  NIL;
  NewNode     :=  NIL;
  // * * * * * //
  {!} ASSERT(Self.IsValidValue(NewValue));
  PreprocessedKey   :=  Self.GetPreprocessedKey(Key);
  Hash              :=  Self.HashFunc(PreprocessedKey);
  IF Self.FindItem(Hash, PreprocessedKey, ParentNode, ItemNode, ParentItem, Item) THEN BEGIN
    IF Item.Value <> NewValue THEN BEGIN
      Self.FreeItemValue(Item);
      Item.Value  :=  NewValue;
    END; // .IF
  END // .IF
  ELSE BEGIN
    NEW(NewItem);
    NewItem.Key       :=  Key;
    NewItem.Value     :=  NewValue;
    NewItem.NextItem  :=  NIL;
    INC(Self.fItemCount);
    IF ItemNode <> NIL THEN BEGIN
      ParentItem.NextItem :=  NewItem; NewItem  :=  NIL;
    END // .IF
    ELSE BEGIN
      NEW(NewNode);
      NewNode.Hash                    :=  Hash;
      NewNode.ChildNodes[LEFT_CHILD]  :=  NIL;
      NewNode.ChildNodes[RIGHT_CHILD] :=  NIL;
      NewNode.Item                    :=  NewItem; NewItem  :=  NIL;
      INC(Self.fNodeCount);
      IF Self.NodeCount > 1 THEN BEGIN
        ParentNode.ChildNodes[NewNode.Hash >= ParentNode.Hash]  :=  NewNode; NewNode  :=  NIL;
      END // .IF
      ELSE BEGIN
        Self.fRoot  :=  NewNode; NewNode  :=  NIL;
      END; // .ELSE
    END; // .ELSE
  END; // .ELSE   
END; // .PROCEDURE TAssocArray.SetValue

FUNCTION TAssocArray.DeleteItem (Key: STRING): BOOLEAN;
VAR
(* U *) ParentNode: PAssocArrayNode;
(* U *) ItemNode:   PAssocArrayNode;
(* U *) ParentItem: PAssocArrayItem;
(* U *) Item:       PAssocArrayItem;
        Hash:       INTEGER;
  
BEGIN
  {!} ASSERT(NOT Self.Locked);
  ItemNode          :=  NIL;
  ParentNode        :=  NIL;
  Item              :=  NIL;
  ParentItem        :=  NIL;
  // * * * * * //
  Key     :=  Self.GetPreprocessedKey(Key);
  Hash    :=  Self.HashFunc(Key);
  RESULT  :=  Self.FindItem(Hash, Key, ParentNode, ItemNode, ParentItem, Item);
  IF RESULT THEN BEGIN
    Self.RemoveItem(ParentNode, ItemNode, ParentItem, Item);
  END; // .IF
END; // .FUNCTION TAssocArray.DeleteItem

FUNCTION TAssocArray.TakeValue (Key: STRING; (* OUn *) OUT Value: POINTER): BOOLEAN;
VAR
(* U *) ParentNode:       PAssocArrayNode;
(* U *) ItemNode:         PAssocArrayNode;
(* U *) ParentItem:       PAssocArrayItem;
(* U *) Item:             PAssocArrayItem;
        Hash:             INTEGER;
  

BEGIN
  {!} ASSERT(Value = NIL);
  ItemNode          :=  NIL;
  ParentNode        :=  NIL;
  Item              :=  NIL;
  ParentItem        :=  NIL;
  // * * * * * //
  Key     :=  Self.GetPreprocessedKey(Key);
  Hash    :=  Self.HashFunc(Key);
  RESULT  :=  Self.FindItem(Hash, Key, ParentNode, ItemNode, ParentItem, Item);
  IF RESULT THEN BEGIN
    Value :=  Item.Value;
    {!} ASSERT(Self.IsValidValue(NIL));
    Item.Value  :=  NIL;
  END; // .IF
END; // .FUNCTION TAssocArray.TakeValue

FUNCTION TAssocArray.ReplaceValue (Key: STRING; (* OUn *) NewValue: POINTER; (* OUn *) OUT OldValue: POINTER): BOOLEAN;
VAR
(* U *) ParentNode:       PAssocArrayNode;
(* U *) ItemNode:         PAssocArrayNode;
(* U *) ParentItem:       PAssocArrayItem;
(* U *) Item:             PAssocArrayItem;
        Hash:             INTEGER;
  

BEGIN
  {!} ASSERT(OldValue = NIL);
  {!} ASSERT(Self.IsValidValue(NewValue));
  ItemNode          :=  NIL;
  ParentNode        :=  NIL;
  Item              :=  NIL;
  ParentItem        :=  NIL;
  // * * * * * //
  Key     :=  Self.GetPreprocessedKey(Key);
  Hash    :=  Self.HashFunc(Key);
  RESULT  :=  Self.FindItem(Hash, Key, ParentNode, ItemNode, ParentItem, Item);
  IF RESULT THEN BEGIN
    OldValue    :=  Item.Value;
    Item.Value  :=  NewValue;
  END; // .IF
END; // .FUNCTION TAssocArray.ReplaceValue

PROCEDURE TAssocArray.EndIterate;
BEGIN
  Self.fLocked  :=  FALSE;
END; // .PROCEDURE TAssocArray.EndIterate

PROCEDURE TAssocArray.BeginIterate;
VAR
  OptimalNumIterNodes:  INTEGER;
  
BEGIN
  OptimalNumIterNodes :=  Self.CalcCritDepth + 1;
  IF LENGTH(Self.fIterNodes) < OptimalNumIterNodes THEN BEGIN
    SetLength(Self.fIterNodes, OptimalNumIterNodes);
  END; // .IF
  Self.fIterCurrItem  :=  NIL;
  IF Self.NodeCount > 0 THEN BEGIN
    Self.fIterNodeInd   :=  0;
    Self.fIterNodes[0]  :=  Self.fRoot;
  END // .IF
  ELSE BEGIN
    Self.fIterNodeInd :=  -1;
  END; // .ELSE
  Self.fLocked  :=  TRUE;
END; // .PROCEDURE TAssocArray.BeginIterate

FUNCTION TAssocArray.IterateNext (OUT Key: STRING; (* Un *) OUT Value: POINTER): BOOLEAN;
VAR
(* U *) IterNode: PAssocArrayNode;  

BEGIN
  {!} ASSERT(Self.Locked);
  {!} ASSERT(Value = NIL);
  IterNode  :=  NIL;
  // * * * * * //
  RESULT  :=  (Self.fIterNodeInd >= 0) OR (Self.fIterCurrItem <> NIL);
  IF RESULT THEN BEGIN
    IF Self.fIterCurrItem = NIL THEN BEGIN
      IterNode            :=  Self.fIterNodes[Self.fIterNodeInd];
      Self.fIterCurrItem  :=  IterNode.Item;
      DEC(Self.fIterNodeInd);
      IF IterNode.ChildNodes[LEFT_CHILD] <> NIL THEN BEGIN
        INC(Self.fIterNodeInd);
        Self.fIterNodes[Self.fIterNodeInd]  :=  IterNode.ChildNodes[LEFT_CHILD];
      END; // .IF
      IF IterNode.ChildNodes[RIGHT_CHILD] <> NIL THEN BEGIN
        INC(Self.fIterNodeInd);
        Self.fIterNodes[Self.fIterNodeInd]  :=  IterNode.ChildNodes[RIGHT_CHILD];
      END; // .IF
    END; // .IF
    Key                 :=  Self.fIterCurrItem.Key;
    Value               :=  Self.fIterCurrItem.Value;
    Self.fIterCurrItem  :=  Self.fIterCurrItem.NextItem;
  END; // .IF
END; // .FUNCTION TAssocArray.IterateNext

CONSTRUCTOR TObjArray.Create
(

                    OwnsItems:        BOOLEAN;
                    ItemsAreObjects:  BOOLEAN;
                    ItemGuardProc:    Utils.TItemGuardProc;
  (* n *) VAR {IN}  ItemGuard:        Utils.TItemGuard
);

BEGIN
  {!} ASSERT(@ItemGuardProc <> NIL);
  Self.fOwnsItems       :=  OwnsItems;
  Self.fItemsAreObjects :=  ItemsAreObjects;
  Self.fItemGuardProc   :=  ItemGuardProc;
  Self.fItemGuard       :=  ItemGuard;
  ItemGuard             :=  NIL;
END; // .CONSTRUCTOR TObjArray.Create

DESTRUCTOR TObjArray.Destroy;
BEGIN
  Self.Clear;
  SysUtils.FreeAndNil(Self.fItemGuard);
END; // .DESTRUCTOR TObjArray.Destroy

FUNCTION TObjArray.KeyToHash (Key: POINTER): INTEGER;
BEGIN
  RESULT  :=  Crypto.Bb2011Encode(INTEGER(Key));
END; // .FUNCTION TObjArray.KeyToHash

FUNCTION TObjArray.HashToKey (Hash: INTEGER): POINTER;
BEGIN
  RESULT  :=  POINTER(Crypto.Bb2011Decode(Hash));
END; // .FUNCTION TObjArray.HashToKey

FUNCTION TObjArray.IsValidValue ((* n *) Value: POINTER): BOOLEAN;
BEGIN
  RESULT  :=  Self.ItemGuardProc(Value, Self.ItemsAreObjects, Utils.TItemGuard(Self.fItemGuard));
END; // .FUNCTION TObjArray.IsValidValue 

FUNCTION TObjArray.CalcCritDepth: INTEGER;
BEGIN
  RESULT  :=  Alg.IntLog2(Self.NodeCount + 1) SHL 1;
END; // .FUNCTION TObjArray.CalcCritDepth

PROCEDURE TObjArray.FreeNodeValue (Node: PObjArrayNode);
BEGIN
  {!} ASSERT(Node <> NIL);
  IF Self.OwnsItems THEN BEGIN
    IF Self.ItemsAreObjects THEN BEGIN
      TObject(Node.Value).Free;
    END // .IF
    ELSE BEGIN
      FreeMem(Node.Value);
    END; // .ELSE
  END; // .IF
  Node.Value  :=  NIL;
END; // .PROCEDURE TObjArray.FreeNodeValue

PROCEDURE TObjArray.FreeNode ((* n *) VAR {IN} Node: PObjArrayNode);
BEGIN
  IF Node <> NIL THEN BEGIN
    Self.FreeNodeValue(Node);
    Self.FreeNode(Node.ChildNodes[LEFT_CHILD]);
    Self.FreeNode(Node.ChildNodes[RIGHT_CHILD]);
    DISPOSE(Node); Node :=  NIL;
  END; // .IF
END; // .PROCEDURE TObjArray.FreeNode

PROCEDURE TObjArray.RemoveNode ((* n *) ParentNode: PObjArrayNode; Node: PObjArrayNode);
VAR
(* U *) RightClosestNodeParent: PObjArrayNode;
(* U *) RightClosestNode:       PObjArrayNode;
        NodeIsRoot:             BOOLEAN;
        NodeSide:               TChildNodeSide;
  
BEGIN
  {!} ASSERT(Node <> NIL);
  RightClosestNodeParent  :=  NIL;
  RightClosestNode        :=  NIL;
  NodeSide                :=  FALSE;
  // * * * * * //
  NodeIsRoot  :=  ParentNode = NIL;
  IF Self.NodeCount = 1 THEN BEGIN
    DISPOSE(Self.fRoot); Self.fRoot :=  NIL;
  END // .IF
  ELSE BEGIN
    IF NOT NodeIsRoot THEN BEGIN
      NodeSide  :=  Node.Hash >= ParentNode.Hash;
    END; // .IF
    IF (Node.ChildNodes[LEFT_CHILD] = NIL) AND (Node.ChildNodes[RIGHT_CHILD] = NIL) THEN BEGIN
      IF NodeIsRoot THEN BEGIN
        Self.fRoot  :=  NIL;
      END // .IF
      ELSE BEGIN
        ParentNode.ChildNodes[NodeSide] :=  NIL;
      END; // .ELSE
      DISPOSE(Node); Node :=  NIL;
    END // .IF
    ELSE IF Node.ChildNodes[LEFT_CHILD] = NIL THEN BEGIN
      IF NodeIsRoot THEN BEGIN
        Self.fRoot  :=  Node.ChildNodes[RIGHT_CHILD];
      END // .IF
      ELSE BEGIN
        ParentNode.ChildNodes[NodeSide] :=  Node.ChildNodes[RIGHT_CHILD];
      END; // .ELSE
      DISPOSE(Node); Node :=  NIL;
    END // .ELSEIF
    ELSE IF Node.ChildNodes[RIGHT_CHILD] = NIL THEN BEGIN
      IF NodeIsRoot THEN BEGIN
        Self.fRoot  :=  Node.ChildNodes[LEFT_CHILD];
      END // .IF
      ELSE BEGIN
        ParentNode.ChildNodes[NodeSide] :=  Node.ChildNodes[LEFT_CHILD];
      END; // .ELSE
      DISPOSE(Node); Node :=  NIL;
    END // .ELSEIF
    ELSE BEGIN
      RightClosestNodeParent  :=  Node;
      RightClosestNode        :=  Node.ChildNodes[RIGHT_CHILD];
      WHILE RightClosestNode.ChildNodes[LEFT_CHILD] <> NIL DO BEGIN
        RightClosestNodeParent  :=  RightClosestNode;
        RightClosestNode        :=  RightClosestNode.ChildNodes[LEFT_CHILD];
      END; // .WHILE
      Node.Value  :=  RightClosestNode.Value; RightClosestNode.Value  :=  NIL;
      Node.Hash   :=  RightClosestNode.Hash;
      Self.RemoveNode(RightClosestNodeParent, RightClosestNode);
    END; // .ELSE
  END; // .ELSE
END; // .PROCEDURE TObjArray.RemoveNode

PROCEDURE TObjArray.Clear;
BEGIN
  {!} ASSERT(NOT Self.Locked);
  Self.FreeNode(Self.fRoot);
  Self.fNodeCount :=  0;
END; // .PROCEDURE TObjArray.Clear

FUNCTION TObjArray.CloneNode ((* n *) Node: PObjArrayNode): (* On *) PObjArrayNode;
BEGIN
  IF Node = NIL THEN BEGIN
    RESULT  :=  NIL;
  END // .IF
  ELSE BEGIN
    NEW(RESULT);
    RESULT.Hash :=  Node.Hash;
    {!} ASSERT(Self.IsValidValue(Node.Value));
    IF (Node.Value = NIL) OR (NOT Self.OwnsItems) THEN BEGIN
      RESULT.Value  :=  Node.Value;
    END // .IF
    ELSE BEGIN
      {!} ASSERT(Self.ItemsAreObjects);
      {!} ASSERT(TObject(Node.Value) IS Utils.TCloneable);
      RESULT.Value  :=  Utils.TCloneable(Node.Value).Clone;
    END; // .ELSE
    RESULT.ChildNodes[LEFT_CHILD]   :=  Self.CloneNode(Node.ChildNodes[LEFT_CHILD]);
    RESULT.ChildNodes[RIGHT_CHILD]  :=  Self.CloneNode(Node.ChildNodes[RIGHT_CHILD]);
  END; // .ELSE
END; // .FUNCTION TObjArray.CloneNode

PROCEDURE TObjArray.Assign (Source: Utils.TCloneable);
VAR
(* U *) SrcArr: TObjArray;
  
BEGIN
  {!} ASSERT(NOT Self.Locked);
  {!} ASSERT(Source <> NIL);
  SrcArr  :=  Source AS TObjArray;
  // * * * * * //
  IF Self <> Source THEN BEGIN
    Self.Clear;
    Self.fOwnsItems       :=  SrcArr.OwnsItems;
    Self.fItemsAreObjects :=  SrcArr.ItemsAreObjects;
    Self.fItemGuardProc   :=  SrcArr.ItemGuardProc;
    Self.fItemGuard       :=  SrcArr.fItemGuard.Clone;
    Self.fNodeCount       :=  SrcArr.NodeCount;
    Self.fRoot            :=  Self.CloneNode(SrcArr.fRoot);
  END; // .IF
END; // .PROCEDURE TObjArray.Assign

FUNCTION ObjArrayCompareItems (A, B: INTEGER): INTEGER;
BEGIN
  IF PObjArrayNode(A).Hash > PObjArrayNode(B).Hash THEN BEGIN
    RESULT  :=  1;
  END // .IF
  ELSE IF PObjArrayNode(A).Hash < PObjArrayNode(B).Hash THEN BEGIN
    RESULT  :=  -1;
  END // .ELSEIF
  ELSE BEGIN
    RESULT  :=  0;
  END; // .ELSE
END; // .FUNCTION ObjArrayCompareItems

PROCEDURE TObjArray.ConvertToLinearNodeArray (OUT Res: TLinearObjNodeArray);
VAR
        LeftInd:              INTEGER;
        RightInd:             INTEGER;
        RightCheckInd:        INTEGER;
        NumNotProcessedNodes: INTEGER;
(* U *) CurrNode:             PObjArrayNode;
        i:                    INTEGER;
  
BEGIN
  SetLength(Res.NodeArray, Self.NodeCount);
  Res.NodeCount :=  Self.NodeCount;
  IF Self.NodeCount > 0 THEN BEGIN
    CurrNode                :=  Self.fRoot;
    LeftInd                 :=  0;
    Res.NodeArray[LeftInd]  :=  CurrNode;
    RightInd                :=  Self.NodeCount;
    RightCheckInd           :=  RightInd - 1;
    NumNotProcessedNodes    :=  Self.NodeCount - 1;
    WHILE NumNotProcessedNodes > 0 DO BEGIN
      IF CurrNode.ChildNodes[RIGHT_CHILD] <> NIL THEN BEGIN
        DEC(RightInd);
        Res.NodeArray[RightInd] :=  CurrNode.ChildNodes[RIGHT_CHILD];
        DEC(NumNotProcessedNodes);
      END; // .IF
      IF CurrNode.ChildNodes[LEFT_CHILD] <> NIL THEN BEGIN
        CurrNode  :=  CurrNode.ChildNodes[LEFT_CHILD];
        INC(LeftInd);
        Res.NodeArray[LeftInd]  :=  CurrNode;
        DEC(NumNotProcessedNodes);
      END // .IF
      ELSE BEGIN
        CurrNode  :=  Res.NodeArray[RightCheckInd];
        DEC(RightCheckInd);
      END; // .ELSE
    END; // .WHILE
    FOR i:=0 TO Self.NodeCount - 1 DO BEGIN
      Res.NodeArray[i].ChildNodes[LEFT_CHILD]   :=  NIL;
      Res.NodeArray[i].ChildNodes[RIGHT_CHILD]  :=  NIL;
    END; // .FOR
    Self.fRoot      :=  NIL;
    Self.fNodeCount :=  0;
    Alg.CustomQuickSort(@Res.NodeArray[0], 0, Res.NodeCount - 1, ObjArrayCompareItems);
  END; // .IF
END; // .PROCEDURE TObjArray.ConvertToLinearNodeArray

PROCEDURE TObjArray.Rebuild;
VAR
  LinearNodeArray:  TLinearObjNodeArray;
  NodeArray:        TObjNodeArray;
  
  PROCEDURE InsertNode (InsNode: PObjArrayNode);
  VAR
  (* U *) ParentNode: PObjArrayNode;
  (* U *) CurrNode:   PObjArrayNode;
    
  BEGIN
    {!} ASSERT(InsNode <> NIL);
    ParentNode  :=  NIL;
    CurrNode    :=  Self.fRoot;
    // * * * * * //
    WHILE CurrNode <> NIL DO BEGIN
      ParentNode  :=  CurrNode;
      CurrNode    :=  CurrNode.ChildNodes[InsNode.Hash >= CurrNode.Hash];
    END; // .WHILE
    ParentNode.ChildNodes[InsNode.Hash >= ParentNode.Hash]  :=  InsNode;
  END; // .PROCEDURE InsertNode
  
  PROCEDURE InsertNodeRange (MinInd, MaxInd: INTEGER);
  VAR
          RangeLen:   INTEGER;
          MiddleInd:  INTEGER;
  (* U *) InsNode:    PObjArrayNode;
    
  BEGIN
    RangeLen  :=  MaxInd - MinInd + 1;
    {!} ASSERT(RangeLen > 0);
    {!} ASSERT((MinInd >= 0) AND (MaxInd < LENGTH(NodeArray)));
    // * * * * * //
    MiddleInd :=  (MaxInd - MinInd) SHR 1 + MinInd;
    InsNode   :=  NodeArray[MiddleInd];
    IF Self.fRoot = NIL THEN BEGIN
      Self.fRoot  :=  InsNode;
    END // .IF
    ELSE BEGIN
      InsertNode(InsNode);
    END; // .ELSE
    IF RangeLen > 2 THEN BEGIN
      InsertNodeRange(MinInd, MiddleInd - 1);
      InsertNodeRange(MiddleInd + 1, MaxInd);
    END // .IF
    ELSE IF RangeLen = 2 THEN BEGIN
      InsertNode(NodeArray[MiddleInd + 1]);
    END; // .ELSEIF
  END; // .PROCEDURE InsertNodeRange
  
BEGIN
  {!} ASSERT(NOT Self.Locked);
  IF Self.NodeCount > 2 THEN BEGIN
    Self.ConvertToLinearNodeArray(LinearNodeArray);
    Self.fNodeCount :=  LinearNodeArray.NodeCount;
    NodeArray       :=  LinearNodeArray.NodeArray;
    InsertNodeRange(0, Self.NodeCount - 1);
  END; // .IF
END; // .PROCEDURE TObjArray.Rebuild

FUNCTION TObjArray.FindItem
(
  (* n  *)      Key:        POINTER;
  (* ni *)  OUT ParentNode: PObjArrayNode;
  (* ni *)  OUT ItemNode:   PObjArrayNode
): BOOLEAN;

VAR
  Hash:             INTEGER;
  SearchDepth:      INTEGER;
  CritSearchDepth:  INTEGER;
  
BEGIN
  {!} ASSERT(ParentNode = NIL);
  {!} ASSERT(ItemNode = NIL);
  RESULT  :=  FALSE;
  IF Self.NodeCount > 0 THEN BEGIN
    Hash            :=  Self.KeyToHash(Key);
    CritSearchDepth :=  Self.CalcCritDepth;
    SearchDepth     :=  1;
    ItemNode        :=  Self.fRoot;
    WHILE (ItemNode <> NIL) AND (ItemNode.Hash <> Hash) DO BEGIN
      INC(SearchDepth);
      ParentNode  :=  ItemNode;
      ItemNode    :=  ItemNode.ChildNodes[Hash >= ItemNode.Hash];
    END; // .WHILE
    IF SearchDepth > CritSearchDepth THEN BEGIN
      Self.Rebuild;
      ParentNode  :=  NIL;
      ItemNode    :=  NIL;
      RESULT      :=  Self.FindItem(Key, ParentNode, ItemNode);
    END; // .IF
    RESULT  :=  ItemNode <> NIL;
  END; // .IF
END; // .FUNCTION TObjArray.FindItem

FUNCTION TObjArray.GetValue ((* n *) Key: POINTER): (* n *) POINTER;
VAR
(* U *) ItemNode:   PObjArrayNode;
(* U *) ParentNode: PObjArrayNode;
  
BEGIN
  ItemNode    :=  NIL;
  ParentNode  :=  NIL;
  // * * * * * //
  IF Self.FindItem(Key, ParentNode, ItemNode) THEN BEGIN
    RESULT  :=  ItemNode.Value;
  END // .IF
  ELSE BEGIN
    RESULT  :=  NIL;
  END; // .ELSE
END; // .FUNCTION TObjArray.GetValue

FUNCTION TObjArray.GetExistingValue ((* n *) Key: POINTER; (* Un *) OUT Res: POINTER): BOOLEAN;
VAR
(* U *) ItemNode:   PObjArrayNode;
(* U *) ParentNode: PObjArrayNode;
  
BEGIN
  {!} ASSERT(Res = NIL);
  ItemNode    :=  NIL;
  ParentNode  :=  NIL;
  // * * * * * //
  IF Self.FindItem(Key, ParentNode, ItemNode) THEN BEGIN
    Res     :=  ItemNode.Value;
    RESULT  :=  TRUE;
  END // .IF
  ELSE BEGIN
    RESULT  :=  FALSE;
  END; // .ELSE
END; // .FUNCTION TObjArray.GetExistingValue

PROCEDURE TObjArray.SetValue ((* n *) Key: POINTER; (* OUn *) NewValue: POINTER);
VAR
(* U *) ItemNode:   PObjArrayNode;
(* U *) ParentNode: PObjArrayNode;
(* O *) NewNode:    PObjArrayNode;
  
BEGIN
  ItemNode    :=  NIL;
  ParentNode  :=  NIL;
  NewNode     :=  NIL;
  // * * * * * //
  {!} ASSERT(Self.IsValidValue(NewValue));
  IF Self.FindItem(Key, ParentNode, ItemNode) THEN BEGIN
    IF ItemNode.Value <> NewValue THEN BEGIN
      Self.FreeNodeValue(ItemNode);
      ItemNode.Value  :=  NewValue;
    END; // .IF
  END // .IF
  ELSE BEGIN
    NEW(NewNode);
    NewNode.Hash  :=  Self.KeyToHash(Key);
    NewNode.Value :=  NewValue;
    NewNode.ChildNodes[LEFT_CHILD]  :=  NIL;
    NewNode.ChildNodes[RIGHT_CHILD] :=  NIL;
    INC(Self.fNodeCount);
    IF Self.NodeCount > 1 THEN BEGIN
      ParentNode.ChildNodes[NewNode.Hash >= ParentNode.Hash]  :=  NewNode; NewNode  :=  NIL;
    END // .IF
    ELSE BEGIN
      Self.fRoot  :=  NewNode; NewNode  :=  NIL;
    END; // .ELSE
  END; // .ELSE   
END; // .PROCEDURE TObjArray.SetValue

FUNCTION TObjArray.DeleteItem ((* n *) Key: POINTER): BOOLEAN;
VAR
(* U *) ParentNode: PObjArrayNode;
(* U *) ItemNode:   PObjArrayNode;
  
BEGIN
  {!} ASSERT(NOT Self.Locked);
  ItemNode    :=  NIL;
  ParentNode  :=  NIL;
  // * * * * * //
  RESULT  :=  Self.FindItem(Key, ParentNode, ItemNode);
  IF RESULT THEN BEGIN
    Self.RemoveNode(ParentNode, ItemNode);
    DEC(Self.fNodeCount);
  END; // .IF
END; // .FUNCTION TObjArray.DeleteItem

FUNCTION TObjArray.TakeValue ((* n *) Key: POINTER; (* OUn *) OUT Value: POINTER): BOOLEAN;
VAR
(* U *) ParentNode: PObjArrayNode;
(* U *) ItemNode:   PObjArrayNode;

BEGIN
  {!} ASSERT(Value = NIL);
  ItemNode    :=  NIL;
  ParentNode  :=  NIL;
  // * * * * * //
  RESULT  :=  Self.FindItem(Key, ParentNode, ItemNode);
  IF RESULT THEN BEGIN
    Value :=  ItemNode.Value;
    {!} ASSERT(Self.IsValidValue(NIL));
    ItemNode.Value  :=  NIL;
  END; // .IF
END; // .FUNCTION TObjArray.TakeValue

FUNCTION TObjArray.ReplaceValue ((* n *) Key: POINTER; (* OUn *) NewValue: POINTER; (* OUn *) OUT OldValue: POINTER): BOOLEAN;
VAR
(* U *) ParentNode: PObjArrayNode;
(* U *) ItemNode:   PObjArrayNode;

BEGIN
  {!} ASSERT(OldValue = NIL);
  {!} ASSERT(Self.IsValidValue(NewValue));
  ItemNode          :=  NIL;
  ParentNode        :=  NIL;
  // * * * * * //
  RESULT  :=  Self.FindItem(Key, ParentNode, ItemNode);
  IF RESULT THEN BEGIN
    OldValue        :=  ItemNode.Value;
    ItemNode.Value  :=  NewValue;
  END; // .IF
END; // .FUNCTION TObjArray.ReplaceValue

PROCEDURE TObjArray.EndIterate;
BEGIN
  Self.fLocked  :=  FALSE;
END; // .PROCEDURE TObjArray.EndIterate

PROCEDURE TObjArray.BeginIterate;
VAR
  OptimalNumIterNodes:  INTEGER;
  
BEGIN
  OptimalNumIterNodes :=  Self.CalcCritDepth + 1;
  IF LENGTH(Self.fIterNodes) < OptimalNumIterNodes THEN BEGIN
    SetLength(Self.fIterNodes, OptimalNumIterNodes);
  END; // .IF
  IF Self.NodeCount > 0 THEN BEGIN
    Self.fIterNodeInd   :=  0;
    Self.fIterNodes[0]  :=  Self.fRoot;
  END // .IF
  ELSE BEGIN
    Self.fIterNodeInd :=  -1;
  END; // .ELSE
  Self.fLocked  :=  TRUE;
END; // .PROCEDURE TObjArray.BeginIterate

FUNCTION TObjArray.IterateNext ((* Un *) OUT Key: POINTER; (* Un *) OUT Value: POINTER): BOOLEAN;
VAR
(* U *) IterNode: PObjArrayNode;  

BEGIN
  {!} ASSERT(Self.Locked);
  {!} ASSERT(Key = NIL);
  {!} ASSERT(Value = NIL);
  IterNode  :=  NIL;
  // * * * * * //
  RESULT  :=  Self.fIterNodeInd >= 0;
  IF RESULT THEN BEGIN
    IterNode  :=  Self.fIterNodes[Self.fIterNodeInd];
    DEC(Self.fIterNodeInd);
    IF IterNode.ChildNodes[LEFT_CHILD] <> NIL THEN BEGIN
      INC(Self.fIterNodeInd);
      Self.fIterNodes[Self.fIterNodeInd]  :=  IterNode.ChildNodes[LEFT_CHILD];
    END; // .IF
    IF IterNode.ChildNodes[RIGHT_CHILD] <> NIL THEN BEGIN
      INC(Self.fIterNodeInd);
      Self.fIterNodes[Self.fIterNodeInd]  :=  IterNode.ChildNodes[RIGHT_CHILD];
    END; // .IF
    Key   :=  Self.HashToKey(IterNode.Hash);
    Value :=  IterNode.Value;
  END; // .IF
END; // .FUNCTION TObjArray.IterateNext

FUNCTION NewAssocArr
(
          HashFunc:           THashFunc;
  (* n *) KeyPreprocessFunc:  TKeyPreprocessFunc;
          OwnsItems:          BOOLEAN;
          ItemsAreObjects:    BOOLEAN;
          ItemType:           TClass;
          AllowNIL:           BOOLEAN
): TAssocArray;

VAR
(* O *) ItemGuard:  Utils.TDefItemGuard;

BEGIN
  {!} ASSERT(ItemsAreObjects OR (ItemType = Utils.NO_TYPEGUARD));
  ItemGuard :=  Utils.TDefItemGuard.Create;
  // * * * * * //
  ItemGuard.ItemType  :=  ItemType;
  ItemGuard.AllowNIL  :=  AllowNIL;
  RESULT              :=  TAssocArray.Create
  (
    HashFunc, KeyPreprocessFunc, OwnsItems, ItemsAreObjects, @Utils.DefItemGuardProc, Utils.TItemGuard(ItemGuard)
  );
END; // .FUNCTION NewAssocArr

FUNCTION NewSimpleAssocArr (HashFunc: THashFunc; (* n *) KeyPreprocessFunc: TKeyPreprocessFunc): TAssocArray;
VAR
(* O *) ItemGuard:  Utils.TCloneable;

BEGIN
  ItemGuard :=  NIL;
  // * * * * * //
  RESULT  :=  TAssocArray.Create
  (
    HashFunc, KeyPreprocessFunc, NOT Utils.OWNS_ITEMS, NOT Utils.ITEMS_ARE_OBJECTS, @Utils.NoItemGuardProc, ItemGuard
  );
END; // .FUNCTION NewSimpleAssocArr

FUNCTION NewStrictAssocArr ({n} TypeGuard: TClass): TAssocArray;
BEGIN
  RESULT  :=  NewAssocArr
  (
    Crypto.AnsiCRC32,
    SysUtils.AnsiLowerCase,
    Utils.OWNS_ITEMS,
    Utils.ITEMS_ARE_OBJECTS,
    TypeGuard,
    Utils.ALLOW_NIL
  );
END; // .FUNCTION NewStrictAssocArr

FUNCTION NewObjArr (OwnsItems: BOOLEAN; ItemsAreObjects: BOOLEAN; ItemType: TClass; AllowNIL: BOOLEAN): TObjArray;

VAR
(* O *) ItemGuard:  Utils.TDefItemGuard;

BEGIN
  {!} ASSERT(ItemsAreObjects OR (ItemType = Utils.NO_TYPEGUARD));
  ItemGuard :=  Utils.TDefItemGuard.Create;
  // * * * * * //
  ItemGuard.ItemType  :=  ItemType;
  ItemGuard.AllowNIL  :=  AllowNIL;
  RESULT              :=  TObjArray.Create(OwnsItems, ItemsAreObjects, @Utils.DefItemGuardProc, Utils.TItemGuard(ItemGuard));
END; // .FUNCTION NewObjArr

FUNCTION NewSimpleObjArr: TObjArray;
VAR
(* O *) ItemGuard:  Utils.TCloneable;

BEGIN
  ItemGuard :=  NIL;
  // * * * * * //
  RESULT  :=  TObjArray.Create(NOT Utils.OWNS_ITEMS, NOT Utils.ITEMS_ARE_OBJECTS, @Utils.NoItemGuardProc, ItemGuard);
END; // .FUNCTION NewSimpleObjArr

FUNCTION NewStrictObjArr ({n} TypeGuard: TClass): TObjArray;
BEGIN
  RESULT  :=  NewObjArr(Utils.OWNS_ITEMS, Utils.ITEMS_ARE_OBJECTS, TypeGuard, Utils.ALLOW_NIL);
END; // .FUNCTION NewStrictObjArr

END.
