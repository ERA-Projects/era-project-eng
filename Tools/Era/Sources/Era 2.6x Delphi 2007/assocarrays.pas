unit AssocArrays;
{
DESCRIPTION:  Associative array implementation
AUTHOR:       Alexander Shostak (aka Berserker aka EtherniDee aka BerSoft)
}

(*
The implementation uses binary tree and (in case of array with string keys) user provided hash function to store and retrieve data.
Tree is automatically rebalanced when critical search depth is met which is equal to 2X of balanced tree height.
Rebalancing is done by converting tree to linear node array and inserting nodes in empty tree.
*)

(***)  interface  (***)
uses SysUtils, Utils, Alg, Crypto;

const
  LEFT_CHILD  = FALSE;
  RIGHT_CHILD = TRUE;
  
  NO_KEY_PREPROCESS_FUNC  = nil;


type
  TChildNodeSide  = boolean;

  PAssocArrayItem = ^TAssocArrayItem;
  TAssocArrayItem = record
          Key:      string;
    {OUn} Value:    pointer;
    {On}  NextItem: PAssocArrayItem;
  end; // .record TAssocArrayItem

  PAssocArrayNode = ^TAssocArrayNode;
  TAssocArrayNode = record
        Hash:       integer;
    {O} Item:       PAssocArrayItem;
        ChildNodes: array [LEFT_CHILD..RIGHT_CHILD] of {On} PAssocArrayNode;
  end; // .record TAssocArrayNode

  THashFunc           = function (const Str: string): integer;
  TKeyPreprocessFunc  = function (const OrigKey: string): string;
  
  TNodeArray  = array of {O} PAssocArrayNode;
  
  TLinearNodeArray  = record
    NodeArray:  TNodeArray; // Nodes are sorted by hash
    NodeCount:  integer;
    ItemCount:  integer;
  end; // .record TLinearNodeArray
  
  TAssocArray = class (Utils.TCloneable)
    (***) protected (***)
      {On}  fRoot:              PAssocArrayNode;
            fHashFunc:          THashFunc;
      {n}   fKeyPreprocessFunc: TKeyPreprocessFunc;
            fOwnsItems:         boolean;
            fItemsAreObjects:   boolean;
            fItemGuardProc:     Utils.TItemGuardProc;
      {On}  fItemGuard:         Utils.TItemGuard;
            fItemCount:         integer;
            fNodeCount:         integer;
            fIterNodes:         array of {U} PAssocArrayNode;
      {U}   fIterCurrItem:      PAssocArrayItem;
            fIterNodeInd:       integer;
            fLocked:            boolean;

      
      function  CloneItem (Item: PAssocArrayItem): {O} PAssocArrayItem;
      function  CloneNode ({n} Node: PAssocArrayNode): {On} PAssocArrayNode;
      procedure FreeItemValue (Item: PAssocArrayItem);
      procedure FreeNode ({IN} var {n} Node: PAssocArrayNode);
      procedure RemoveNode ({n} ParentNode: PAssocArrayNode; ItemNode: PAssocArrayNode);
      procedure RemoveItem
      (
        {n} ParentNode: PAssocArrayNode;
            ItemNode:   PAssocArrayNode;
        {n} ParentItem: PAssocArrayItem;
            Item:       PAssocArrayItem
      );
      
      (*
        All nodes are placed in NodeArray and disconnected from each other.
        Original binary tree is emptied. Nodes are sorted by hash.
      *)
      procedure ConvertToLinearNodeArray (out Res: TLinearNodeArray);
      
      function  FindItem
      (
                    Hash:       integer;
              const Key:        string;
        out {ni}   ParentNode: PAssocArrayNode;
        out {ni}   ItemNode:   PAssocArrayNode;
        out {ni}   ParentItem: PAssocArrayItem;
        out {ni}   Item:       PAssocArrayItem
      ): boolean;

    (***) public (***)
      constructor Create
      (
                      HashFunc:           THashFunc;
                  {n} KeyPreprocessFunc:  TKeyPreprocessFunc;
                      OwnsItems:          boolean;
                      ItemsAreObjects:    boolean;
                      ItemGuardProc:      Utils.TItemGuardProc;
        {IN} var  {n} ItemGuard:          Utils.TItemGuard
      );
      destructor  Destroy; override;
      procedure Assign (Source: Utils.TCloneable); override;
      procedure Clear;
      function  GetPreprocessedKey (const Key: string): string;
      function  IsValidValue ({n} Value: pointer): boolean;
      function  CalcCritDepth: integer;
      procedure Rebuild;
      function  GetValue (Key: string): {n} pointer;
      function  GetExistingValue (Key: string; out {Un} Res: pointer): boolean;
      procedure SetValue (Key: string; {OUn} NewValue: pointer);
      function  DeleteItem (Key: string): boolean;
      
      (* Returns value with specified key and NILify it in the array *)
      function  TakeValue (Key: string; out {OUn} Value: pointer): boolean;
      
      (* Returns old value *)
      function  ReplaceValue
      (
                  Key:      string;
            {OUn} NewValue: pointer;
        out {OUn} OldValue: pointer
      ): boolean;
      
      procedure BeginIterate;
      function  IterateNext (out Key: string; out {Un} Value: pointer): boolean;
      procedure EndIterate;

      property  HashFunc:           THashFunc read fHashFunc;
      property  KeyPreprocessFunc:  TKeyPreprocessFunc read fKeyPreprocessFunc;
      property  OwnsItems:          boolean read fOwnsItems;
      property  ItemsAreObjects:    boolean read fItemsAreObjects;
      property  ItemCount:          integer read fItemCount;
      property  ItemGuardProc:      Utils.TItemGuardProc read fItemGuardProc;
      property  NodeCount:          integer read fNodeCount;
      property  Locked:             boolean read fLocked;
      property  Items[Key: string]: pointer read {n} GetValue write {OUn} SetValue; default;
  end; // .class TAssocArray

  PObjArrayNode = ^TObjArrayNode;
  TObjArrayNode = record
          Hash:       integer;  // Hash is encoded {U} Key: pointer
    {OUn} Value:      pointer;
          ChildNodes: array [LEFT_CHILD..RIGHT_CHILD] of {On} PObjArrayNode;
  end; // .record TObjArrayItem
  
  TObjNodeArray = array of {O} PObjArrayNode;
  
  TLinearObjNodeArray = record
    NodeArray:  TObjNodeArray;  // Nodes are sorted by hash
    NodeCount:  integer;
  end; // .record TLinearObjNodeArray
  
  TObjArray = class (Utils.TCloneable)
    (***) protected (***)
      {On}  fRoot:            PObjArrayNode;
            fOwnsItems:       boolean;
            fItemsAreObjects: boolean;
            fItemGuardProc:   Utils.TItemGuardProc;
      {On}  fItemGuard:       Utils.TItemGuard;
            fNodeCount:       integer;
            fIterNodes:       array of {U} PObjArrayNode;
            fIterNodeInd:     integer;
            fLocked:          boolean;
      
      function  HashToKey (Hash: integer): {n} pointer;
      function  KeyToHash (Key: {n} pointer): integer;
      procedure FreeNodeValue (Node: PObjArrayNode);
      procedure FreeNode ({IN} var {n} Node: PObjArrayNode);
      procedure RemoveNode ({n} ParentNode: PObjArrayNode; Node: PObjArrayNode);
      function  CloneNode (Node: PObjArrayNode): {O} PObjArrayNode;
      
      (*
        All nodes are placed in NodeArray and disconnected from each other.
        Original binary tree is emptied. Nodes are sorted by hash.
      *)
      procedure ConvertToLinearNodeArray (out Res: TLinearObjNodeArray);

      function  FindItem
      (
            {n}   Key:        pointer;
        out {ni}  ParentNode: PObjArrayNode;
        out {ni}  ItemNode:   PObjArrayNode
      ): boolean;

    (***) public (***)
      constructor Create
      (
                      OwnsItems:        boolean;
                      ItemsAreObjects:  boolean;
                      ItemGuardProc:    Utils.TItemGuardProc;
        {IN} var  {n} ItemGuard:        Utils.TItemGuard
      );
      destructor  Destroy; override;
      procedure Assign (Source: Utils.TCloneable); override;
      procedure Clear;
      function  IsValidValue ({n} Value: pointer): boolean;
      function  CalcCritDepth: integer;
      procedure Rebuild;
      function  GetValue ({n} Key: pointer): {n} pointer;
      function  GetExistingValue ({n} Key: pointer; out {Un} Res: pointer): boolean;
      procedure SetValue ({n} Key: pointer; {OUn} NewValue: pointer);
      function  DeleteItem ({n} Key: pointer): boolean;
      
      (* Returns value with specified key and NILify it in the array *)
      function  TakeValue ({n} Key: pointer; out {OUn} Value: pointer): boolean;
      
      {Returns old value}
      function  ReplaceValue
      (
            {n}   Key:      pointer;
            {OUn} NewValue: pointer;
        out {OUn} OldValue: pointer
      ): boolean;

      procedure BeginIterate;
      function  IterateNext (out {Un} Key: pointer; out {Un} Value: pointer): boolean;
      procedure EndIterate;

      property  OwnsItems:                boolean read fOwnsItems;
      property  ItemsAreObjects:          boolean read fItemsAreObjects;
      property  ItemCount:                integer read fNodeCount;
      property  ItemGuardProc:            Utils.TItemGuardProc read fItemGuardProc;
      property  NodeCount:                integer read fNodeCount;
      property  Locked:                   boolean read fLocked;
      property  Items[{n} Key: pointer]:  {OUn} pointer read GetValue write SetValue; default;
  end; // .class TObjArray

function  NewAssocArr
(
      HashFunc:           THashFunc;
  {n} KeyPreprocessFunc:  TKeyPreprocessFunc;
      OwnsItems:          boolean;
      ItemsAreObjects:    boolean;
      ItemType:           TClass;
      AllowNIL:           boolean
): TAssocArray;

function  NewSimpleAssocArr
(
      HashFunc:           THashFunc;
  {n} KeyPreprocessFunc:  TKeyPreprocessFunc
): TAssocArray;

function  NewStrictAssocArr ({n} TypeGuard: TClass; OwnsItems: boolean = TRUE): TAssocArray;
function  NewObjArr
(
  OwnsItems:        boolean;
  ItemsAreObjects:  boolean;
  ItemType:         TClass;
  AllowNIL:         boolean
): TObjArray;

function  NewSimpleObjArr: TObjArray;
function  NewStrictObjArr ({n} TypeGuard: TClass): TObjArray;


(***)  implementation  (***)


constructor TAssocArray.Create
(
                HashFunc:           THashFunc;
            {n} KeyPreprocessFunc:  TKeyPreprocessFunc;
                OwnsItems:          boolean;
                ItemsAreObjects:    boolean;
                ItemGuardProc:      Utils.TItemGuardProc;
  {IN} var  {n} ItemGuard:          Utils.TItemGuard
);
begin
  {!} Assert(@HashFunc      <> nil);
  {!} Assert(@ItemGuardProc <> nil);
  Self.fHashFunc          :=  HashFunc;
  Self.fKeyPreprocessFunc :=  KeyPreprocessFunc;
  Self.fOwnsItems         :=  OwnsItems;
  Self.fItemsAreObjects   :=  ItemsAreObjects;
  Self.fItemGuardProc     :=  ItemGuardProc;
  Self.fItemGuard         :=  ItemGuard;
  Self.fItemCount         :=  0;
  Self.fNodeCount         :=  0;
  ItemGuard               :=  nil;
end; // .constructor TAssocArray.Create

destructor TAssocArray.Destroy;
begin
  Self.Clear;
  SysUtils.FreeAndNil(Self.fItemGuard);
end; // .destructor TAssocArray.Destroy

function TAssocArray.CloneItem (Item: PAssocArrayItem): {O} PAssocArrayItem;
begin
  {!} Assert(Item <> nil);
  {!} Assert(Self.IsValidValue(Item.Value));
  New(result);
  result.Key  :=  Item.Key;
  
  if Item.NextItem <> nil then begin
    result.NextItem :=  Self.CloneItem(Item.NextItem);
  end // .if
  else begin
    result.NextItem :=  nil;
  end; // .else
  
  if (Item.Value = nil) or (not Self.OwnsItems) then begin
    result.Value  :=  Item.Value;
  end // .if
  else begin
    {!} Assert(Self.ItemsAreObjects);
    {!} Assert(TObject(Item.Value) IS Utils.TCloneable);
    result.Value  :=  Utils.TCloneable(Item.Value).Clone;
  end; // .else
end; // .function TAssocArray.CloneItem

function TAssocArray.CloneNode ({n} Node: PAssocArrayNode): {On} PAssocArrayNode;
begin
  if Node = nil then begin
    result  :=  nil;
  end // .if
  else begin
    New(result);
    result.Hash                     :=  Node.Hash;
    result.Item                     :=  Self.CloneItem(Node.Item);
    result.ChildNodes[LEFT_CHILD]   :=  Self.CloneNode(Node.ChildNodes[LEFT_CHILD]);
    result.ChildNodes[RIGHT_CHILD]  :=  Self.CloneNode(Node.ChildNodes[RIGHT_CHILD]);
  end; // .else
end; // .function TAssocArray.CloneNode

procedure TAssocArray.Assign (Source: Utils.TCloneable);
var
{U} SrcArr: TAssocArray;
  
begin
  {!} Assert(not Self.Locked);
  {!} Assert(Source <> nil);
  SrcArr  :=  Source AS TAssocArray;
  // * * * * * //
  if Self <> Source then begin
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
  end; // .if
end; // .procedure TAssocArray.Assign

procedure TAssocArray.FreeItemValue (Item: PAssocArrayItem);
begin
  {!} Assert(Item <> nil);
  if Self.OwnsItems then begin
    if Self.ItemsAreObjects then begin
      TObject(Item.Value).Free;
    end // .if
    else begin
      FreeMem(Item.Value);
    end; // .else
  end; // .if
  
  Item.Value  :=  nil;
end; // .procedure TAssocArray.FreeItemValue

procedure TAssocArray.RemoveNode ({n} ParentNode: PAssocArrayNode; ItemNode: PAssocArrayNode);
var
{U} RightClosestNodeParent: PAssocArrayNode;
{U} RightClosestNode:       PAssocArrayNode;
    ItemNodeIsRoot:         boolean;
    ItemNodeSide:           TChildNodeSide;
  
begin
  {!} Assert(ItemNode <> nil);
  RightClosestNodeParent  :=  nil;
  RightClosestNode        :=  nil;
  ItemNodeSide            :=  FALSE;
  // * * * * * //
  ItemNodeIsRoot  :=  ParentNode = nil;
  
  if Self.NodeCount = 1 then begin
    {!} Assert(ItemNodeIsRoot);
    {!} Assert(ItemNode = Self.fRoot);
    Dispose(Self.fRoot); Self.fRoot :=  nil;
  end // .if
  else begin
    if not ItemNodeIsRoot then begin
      ItemNodeSide  :=  ItemNode.Hash >= ParentNode.Hash;
    end; // .if
    
    (* N
      - -
    *)
    if
      (ItemNode.ChildNodes[LEFT_CHILD] = nil) and
      (ItemNode.ChildNodes[RIGHT_CHILD] = nil)
    then begin
      ParentNode.ChildNodes[ItemNodeSide] :=  nil;
      Dispose(ItemNode); ItemNode :=  nil;
    end // .if
    (* N
      - R
    *)
    else if ItemNode.ChildNodes[LEFT_CHILD] = nil then begin
      if ItemNodeIsRoot then begin
        Self.fRoot  :=  ItemNode.ChildNodes[RIGHT_CHILD];
      end // .if
      else begin
        ParentNode.ChildNodes[ItemNodeSide] :=  ItemNode.ChildNodes[RIGHT_CHILD];
      end; // .else
      
      Dispose(ItemNode); ItemNode :=  nil;
    end // .ELSEIF
    (* N
      L -
    *)
    else if ItemNode.ChildNodes[RIGHT_CHILD] = nil then begin
      if ItemNodeIsRoot then begin
        Self.fRoot  :=  ItemNode.ChildNodes[LEFT_CHILD];
      end // .if
      else begin
        ParentNode.ChildNodes[ItemNodeSide] :=  ItemNode.ChildNodes[LEFT_CHILD];
      end; // .else
      
      Dispose(ItemNode); ItemNode :=  nil;
    end // .ELSEIF
    (* N
      L R
    *)
    else begin
      RightClosestNodeParent  :=  ItemNode;
      RightClosestNode        :=  ItemNode.ChildNodes[RIGHT_CHILD];
      
      while RightClosestNode.ChildNodes[LEFT_CHILD] <> nil do begin
        RightClosestNodeParent  :=  RightClosestNode;
        RightClosestNode        :=  RightClosestNode.ChildNodes[LEFT_CHILD];
      end; // .while
      
      ItemNode.Item :=  RightClosestNode.Item; RightClosestNode.Item  :=  nil;
      ItemNode.Hash :=  RightClosestNode.Hash;
      Self.RemoveNode(RightClosestNodeParent, RightClosestNode);
    end; // .else
  end; // .else
end; // .procedure TAssocArray.RemoveNode

procedure TAssocArray.RemoveItem
(
  {n} ParentNode: PAssocArrayNode;
      ItemNode:   PAssocArrayNode;
  {n} ParentItem: PAssocArrayItem;
      Item:       PAssocArrayItem
);

begin
  {!} Assert(ItemNode <> nil);
  {!} Assert(Item <> nil);
  Self.FreeItemValue(Item);
  
  if (ItemNode.Item = Item) and (Item.NextItem = nil) then begin
    Self.RemoveNode(ParentNode, ItemNode);
    (* RemoveNode is recursive procedure not affecting the counter *)
    Dec(Self.fNodeCount);
  end // .if
  else begin
    if ItemNode.Item = Item then begin
      ItemNode.Item :=  Item.NextItem;
    end // .if
    else begin
      {!} Assert(ParentItem <> nil);
      ParentItem.NextItem :=  Item.NextItem;
    end; // .else
  end; // .else
  
  Dispose(Item); Item :=  nil;
  Dec(Self.fItemCount);
end; // .procedure TAssocArray.RemoveItem

procedure TAssocArray.FreeNode ({IN} var {n} Node: PAssocArrayNode);
var
{U} Item:     PAssocArrayItem;
{U} NextItem: PAssocArrayItem;

begin
  Item      :=  nil;
  NextItem  :=  nil;
  // * * * * * //
  if Node <> nil then begin
    Item  :=  Node.Item;
    
    while Item <> nil do begin
      NextItem  :=  Item.NextItem;
      Self.FreeItemValue(Item);
      Dispose(Item); Item :=  nil;
      Item  :=  NextItem;
    end; // .while
    
    Self.FreeNode(Node.ChildNodes[LEFT_CHILD]);
    Self.FreeNode(Node.ChildNodes[RIGHT_CHILD]);
    Dispose(Node); Node :=  nil;
  end; // .if
end; // .procedure TAssocArray.FreeNode

procedure TAssocArray.Clear;
begin
  {!} Assert(not Self.Locked);
  Self.FreeNode(Self.fRoot);
  Self.fItemCount :=  0;
  Self.fNodeCount :=  0;
end; // .procedure TAssocArray.Clear

function TAssocArray.GetPreprocessedKey (const Key: string): string;
begin
  if @Self.KeyPreprocessFunc = nil then begin
    result  :=  Key;
  end // .if
  else begin
    result  :=  Self.KeyPreprocessFunc(Key);
  end; // .else
end; // .function TAssocArray.GetPreprocessedKey

function TAssocArray.IsValidValue ({n} Value: pointer): boolean;
begin
  result  :=  Self.ItemGuardProc(Value, Self.ItemsAreObjects, Utils.TItemGuard(Self.fItemGuard));
end; // .function TAssocArray.IsValidValue 

function TAssocArray.CalcCritDepth: integer;
begin
  result  :=  Alg.IntLog2(Self.NodeCount + 1) shl 1;
end; // .function TAssocArray.CalcCritDepth

function AssocArrayCompareNodes (A, B: integer): integer;
begin
  if PAssocArrayNode(A).Hash > PAssocArrayNode(B).Hash then begin
    result  :=  +1;
  end // .if
  else if PAssocArrayNode(A).Hash < PAssocArrayNode(B).Hash then begin
    result  :=  -1;
  end // .ELSEIF
  else begin
    result  :=  0;
  end; // .else
end; // .function AssocArrayCompareNodes

procedure TAssocArray.ConvertToLinearNodeArray (out Res: TLinearNodeArray);
var
    LeftInd:              integer;
    RightInd:             integer;
    RightCheckInd:        integer;
    NumNotProcessedNodes: integer;
{U} CurrNode:             PAssocArrayNode;
    i:                    integer;
  
begin
  SetLength(Res.NodeArray, Self.NodeCount);
  Res.NodeCount :=  Self.NodeCount;
  Res.ItemCount :=  Self.ItemCount;
  
  if Self.NodeCount > 0 then begin
    CurrNode                :=  Self.fRoot;
    LeftInd                 :=  0;
    Res.NodeArray[LeftInd]  :=  CurrNode;
    RightInd                :=  Self.NodeCount;
    RightCheckInd           :=  RightInd - 1;
    NumNotProcessedNodes    :=  Self.NodeCount - 1;
    
    while NumNotProcessedNodes > 0 do begin
      if CurrNode.ChildNodes[RIGHT_CHILD] <> nil then begin
        Dec(RightInd);
        Res.NodeArray[RightInd] :=  CurrNode.ChildNodes[RIGHT_CHILD];
        Dec(NumNotProcessedNodes);
      end; // .if
      
      if CurrNode.ChildNodes[LEFT_CHILD] <> nil then begin
        CurrNode  :=  CurrNode.ChildNodes[LEFT_CHILD];
        Inc(LeftInd);
        Res.NodeArray[LeftInd]  :=  CurrNode;
        Dec(NumNotProcessedNodes);
      end // .if
      else begin
        CurrNode  :=  Res.NodeArray[RightCheckInd];
        Dec(RightCheckInd);
      end; // .else
    end; // .while
    
    for i:=0 to Self.NodeCount - 1 do begin
      Res.NodeArray[i].ChildNodes[LEFT_CHILD]   :=  nil;
      Res.NodeArray[i].ChildNodes[RIGHT_CHILD]  :=  nil;
    end; // .for
    
    Self.fRoot      :=  nil;
    Self.fNodeCount :=  0;
    Self.fItemCount :=  0;
    Alg.CustomQuickSort(pointer(Res.NodeArray), 0, Res.NodeCount - 1, AssocArrayCompareNodes);
  end; // .if
end; // .procedure TAssocArray.ConvertToLinearNodeArray

procedure TAssocArray.Rebuild;
var
  LinearNodeArray:  TLinearNodeArray;
  NodeArray:        TNodeArray;
  
  procedure InsertNode (InsNode: PAssocArrayNode);
  var
  {U} ParentNode: PAssocArrayNode;
  {U} CurrNode:   PAssocArrayNode;
    
  begin
    {!} Assert(InsNode <> nil);
    ParentNode  :=  nil;
    CurrNode    :=  Self.fRoot;
    // * * * * * //
    while CurrNode <> nil do begin
      ParentNode  :=  CurrNode;
      CurrNode    :=  CurrNode.ChildNodes[InsNode.Hash >= CurrNode.Hash];
    end; // .while
    
    ParentNode.ChildNodes[InsNode.Hash >= ParentNode.Hash]  :=  InsNode;
  end; // .procedure InsertNode
  
  procedure InsertNodeRange (MinInd, MaxInd: integer);
  var
  {U} InsNode:    PAssocArrayNode;
      RangeLen:   integer;
      MiddleInd:  integer;

  begin
    RangeLen  :=  MaxInd - MinInd + 1;
    {!} Assert(RangeLen > 0);
    {!} Assert((MinInd >= 0) and (MaxInd < Length(NodeArray)));
    // * * * * * //
    MiddleInd :=  MinInd + (MaxInd - MinInd) shr 1;
    InsNode   :=  NodeArray[MiddleInd];
    
    if Self.fRoot = nil then begin
      Self.fRoot  :=  InsNode;
    end // .if
    else begin
      InsertNode(InsNode);
    end; // .else
    
    if RangeLen > 2 then begin
      InsertNodeRange(MinInd, MiddleInd - 1);
      InsertNodeRange(MiddleInd + 1, MaxInd);
    end // .if
    else if RangeLen = 2 then begin
      InsertNode(NodeArray[MiddleInd + 1]);
    end; // .ELSEIF
  end; // .procedure InsertNodeRange
  
begin
  {!} Assert(not Self.Locked);
  if Self.NodeCount > 2 then begin
    Self.ConvertToLinearNodeArray(LinearNodeArray);
    Self.fNodeCount :=  LinearNodeArray.NodeCount;
    Self.fItemCount :=  LinearNodeArray.ItemCount;
    NodeArray       :=  LinearNodeArray.NodeArray;
    InsertNodeRange(0, Self.NodeCount - 1);
  end; // .if
end; // .procedure TAssocArray.Rebuild

function TAssocArray.FindItem
(
              Hash:       integer;
        const Key:        string;
  out {ni}   ParentNode: PAssocArrayNode;
  out {ni}   ItemNode:   PAssocArrayNode;
  out {ni}   ParentItem: PAssocArrayItem;
  out {ni}   Item:       PAssocArrayItem
): boolean;

var
  SearchDepth:      integer;
  CritSearchDepth:  integer;
  
begin
  {!} Assert(ParentNode = nil);
  {!} Assert(ItemNode = nil);
  {!} Assert(ParentItem = nil);
  {!} Assert(Item = nil);
  result  :=  FALSE;
  
  if Self.NodeCount > 0 then begin
    CritSearchDepth :=  Self.CalcCritDepth;
    SearchDepth     :=  1;
    ItemNode        :=  Self.fRoot;
    
    while (ItemNode <> nil) and (ItemNode.Hash <> Hash) do begin
      Inc(SearchDepth);
      ParentNode  :=  ItemNode;
      ItemNode    :=  ItemNode.ChildNodes[Hash >= ItemNode.Hash];
    end; // .while
    
    if SearchDepth > CritSearchDepth then begin
      Self.Rebuild;
      ParentNode  :=  nil;
      ItemNode    :=  nil;
      ParentItem  :=  nil;
      Item        :=  nil;
      result      :=  Self.FindItem(Hash, Key, ParentNode, ItemNode, ParentItem, Item);
    end // .if
    else if ItemNode <> nil then begin
      Item  :=  ItemNode.Item;

      while (Item <> nil) and (Self.GetPreprocessedKey(Item.Key) <> Key) do begin
        ParentItem  :=  Item;
        Item        :=  Item.NextItem;
      end; // .while

      result  :=  Item <> nil;
    end; // .ELSEIF
  end; // .if
end; // .function TAssocArray.FindItem

function TAssocArray.GetValue (Key: string): {n} pointer;
var
{U} ItemNode:   PAssocArrayNode;
{U} ParentNode: PAssocArrayNode;
{U} Item:       PAssocArrayItem;
{U} ParentItem: PAssocArrayItem;
    Hash:       integer;
  
begin
  ItemNode    :=  nil;
  ParentNode  :=  nil;
  Item        :=  nil;
  ParentItem  :=  nil;
  // * * * * * //
  Key   :=  Self.GetPreprocessedKey(Key);
  Hash  :=  Self.HashFunc(Key);
  
  if Self.FindItem(Hash, Key, ParentNode, ItemNode, ParentItem, Item) then begin
    result  :=  Item.Value;
  end // .if
  else begin
    result  :=  nil;
  end; // .else
end; // .function TAssocArray.GetValue

function TAssocArray.GetExistingValue (Key: string; out {Un} Res: pointer): boolean;
var
{U} ItemNode:   PAssocArrayNode;
{U} ParentNode: PAssocArrayNode;
{U} Item:       PAssocArrayItem;
{U} ParentItem: PAssocArrayItem;
    Hash:       integer;
  
begin
  {!} Assert(Res = nil);
  ItemNode    :=  nil;
  ParentNode  :=  nil;
  Item        :=  nil;
  ParentItem  :=  nil;
  // * * * * * //
  Key     :=  Self.GetPreprocessedKey(Key);
  Hash    :=  Self.HashFunc(Key);
  result  :=  Self.FindItem(Hash, Key, ParentNode, ItemNode, ParentItem, Item);
  
  if result then begin
    Res :=  Item.Value;
  end; // .if
end; // .function TAssocArray.GetExistingValue

procedure TAssocArray.SetValue (Key: string; {OUn} NewValue: pointer);
var
{U} ItemNode:         PAssocArrayNode;
{U} ParentNode:       PAssocArrayNode;
{U} Item:             PAssocArrayItem;
{U} ParentItem:       PAssocArrayItem;
{O} NewItem:          PAssocArrayItem;
{O} NewNode:          PAssocArrayNode;
    PreprocessedKey:  string;
    Hash:             integer;
  
begin
  ItemNode    :=  nil;
  ParentNode  :=  nil;
  Item        :=  nil;
  ParentItem  :=  nil;
  NewItem     :=  nil;
  NewNode     :=  nil;
  // * * * * * //
  {!} Assert(Self.IsValidValue(NewValue));
  PreprocessedKey :=  Self.GetPreprocessedKey(Key);
  Hash            :=  Self.HashFunc(PreprocessedKey);
  
  if Self.FindItem(Hash, PreprocessedKey, ParentNode, ItemNode, ParentItem, Item) then begin
    if Item.Value <> NewValue then begin
      Self.FreeItemValue(Item);
      Item.Value  :=  NewValue;
    end; // .if
  end // .if
  else begin
    New(NewItem);
    NewItem.Key       :=  Key;
    NewItem.Value     :=  NewValue;
    NewItem.NextItem  :=  nil;
    Inc(Self.fItemCount);
    
    if ItemNode <> nil then begin
      ParentItem.NextItem :=  NewItem; NewItem  :=  nil;
    end // .if
    else begin
      New(NewNode);
      NewNode.Hash                    :=  Hash;
      NewNode.ChildNodes[LEFT_CHILD]  :=  nil;
      NewNode.ChildNodes[RIGHT_CHILD] :=  nil;
      NewNode.Item                    :=  NewItem; NewItem  :=  nil;
      Inc(Self.fNodeCount);
      
      if Self.NodeCount > 1 then begin
        ParentNode.ChildNodes[NewNode.Hash >= ParentNode.Hash]  :=  NewNode; NewNode  :=  nil;
      end // .if
      else begin
        Self.fRoot  :=  NewNode; NewNode  :=  nil;
      end; // .else
    end; // .else
  end; // .else   
end; // .procedure TAssocArray.SetValue

function TAssocArray.DeleteItem (Key: string): boolean;
var
{U} ParentNode: PAssocArrayNode;
{U} ItemNode:   PAssocArrayNode;
{U} ParentItem: PAssocArrayItem;
{U} Item:       PAssocArrayItem;
    Hash:       integer;
  
begin
  {!} Assert(not Self.Locked);
  ItemNode          :=  nil;
  ParentNode        :=  nil;
  Item              :=  nil;
  ParentItem        :=  nil;
  // * * * * * //
  Key     :=  Self.GetPreprocessedKey(Key);
  Hash    :=  Self.HashFunc(Key);
  result  :=  Self.FindItem(Hash, Key, ParentNode, ItemNode, ParentItem, Item);
  
  if result then begin
    Self.RemoveItem(ParentNode, ItemNode, ParentItem, Item);
  end; // .if
end; // .function TAssocArray.DeleteItem

function TAssocArray.TakeValue (Key: string; out {OUn} Value: pointer): boolean;
var
{U} ParentNode:       PAssocArrayNode;
{U} ItemNode:         PAssocArrayNode;
{U} ParentItem:       PAssocArrayItem;
{U} Item:             PAssocArrayItem;
    Hash:             integer;
  

begin
  {!} Assert(Value = nil);
  ItemNode          :=  nil;
  ParentNode        :=  nil;
  Item              :=  nil;
  ParentItem        :=  nil;
  // * * * * * //
  Key     :=  Self.GetPreprocessedKey(Key);
  Hash    :=  Self.HashFunc(Key);
  result  :=  Self.FindItem(Hash, Key, ParentNode, ItemNode, ParentItem, Item);
  
  if result then begin
    Value :=  Item.Value;
    {!} Assert(Self.IsValidValue(nil));
    Item.Value  :=  nil;
  end; // .if
end; // .function TAssocArray.TakeValue

function TAssocArray.ReplaceValue
(
            Key:      string;
      {OUn} NewValue: pointer;
  out {OUn} OldValue: pointer
): boolean;

var
{U} ParentNode:       PAssocArrayNode;
{U} ItemNode:         PAssocArrayNode;
{U} ParentItem:       PAssocArrayItem;
{U} Item:             PAssocArrayItem;
    Hash:             integer;

begin
  {!} Assert(OldValue = nil);
  {!} Assert(Self.IsValidValue(NewValue));
  ItemNode          :=  nil;
  ParentNode        :=  nil;
  Item              :=  nil;
  ParentItem        :=  nil;
  // * * * * * //
  Key     :=  Self.GetPreprocessedKey(Key);
  Hash    :=  Self.HashFunc(Key);
  result  :=  Self.FindItem(Hash, Key, ParentNode, ItemNode, ParentItem, Item);
  
  if result then begin
    OldValue    :=  Item.Value;
    Item.Value  :=  NewValue;
  end; // .if
end; // .function TAssocArray.ReplaceValue

procedure TAssocArray.EndIterate;
begin
  {!} Assert(Self.fLocked);
  Self.fLocked  :=  FALSE;
end; // .procedure TAssocArray.EndIterate

procedure TAssocArray.BeginIterate;
var
  OptimalNumIterNodes:  integer;
  
begin
  {!} Assert(not Self.fLocked);
  OptimalNumIterNodes :=  Self.CalcCritDepth + 1;
  
  if Length(Self.fIterNodes) < OptimalNumIterNodes then begin
    SetLength(Self.fIterNodes, OptimalNumIterNodes);
  end; // .if
  
  Self.fIterCurrItem  :=  nil;
  
  if Self.NodeCount > 0 then begin
    Self.fIterNodeInd   :=  0;
    Self.fIterNodes[0]  :=  Self.fRoot;
  end // .if
  else begin
    Self.fIterNodeInd :=  -1;
  end; // .else
  
  Self.fLocked  :=  TRUE;
end; // .procedure TAssocArray.BeginIterate

function TAssocArray.IterateNext (out Key: string; out {Un} Value: pointer): boolean;
var
{U} IterNode: PAssocArrayNode;  

begin
  {!} Assert(Self.Locked);
  {!} Assert(Value = nil);
  IterNode  :=  nil;
  // * * * * * //
  result  :=  (Self.fIterNodeInd >= 0) or (Self.fIterCurrItem <> nil);
  
  if result then begin
    if Self.fIterCurrItem = nil then begin
      IterNode            :=  Self.fIterNodes[Self.fIterNodeInd];
      Self.fIterCurrItem  :=  IterNode.Item;
      Dec(Self.fIterNodeInd);
      
      if IterNode.ChildNodes[LEFT_CHILD] <> nil then begin
        Inc(Self.fIterNodeInd);
        Self.fIterNodes[Self.fIterNodeInd]  :=  IterNode.ChildNodes[LEFT_CHILD];
      end; // .if
      if IterNode.ChildNodes[RIGHT_CHILD] <> nil then begin
        Inc(Self.fIterNodeInd);
        Self.fIterNodes[Self.fIterNodeInd]  :=  IterNode.ChildNodes[RIGHT_CHILD];
      end; // .if
    end; // .if
    
    Key                 :=  Self.fIterCurrItem.Key;
    Value               :=  Self.fIterCurrItem.Value;
    Self.fIterCurrItem  :=  Self.fIterCurrItem.NextItem;
  end; // .if
end; // .function TAssocArray.IterateNext

constructor TObjArray.Create
(

                OwnsItems:        boolean;
                ItemsAreObjects:  boolean;
                ItemGuardProc:    Utils.TItemGuardProc;
  {IN} var  {n} ItemGuard:        Utils.TItemGuard
);

begin
  {!} Assert(@ItemGuardProc <> nil);
  Self.fOwnsItems       :=  OwnsItems;
  Self.fItemsAreObjects :=  ItemsAreObjects;
  Self.fItemGuardProc   :=  ItemGuardProc;
  Self.fItemGuard       :=  ItemGuard;
  ItemGuard             :=  nil;
end; // .constructor TObjArray.Create

destructor TObjArray.Destroy;
begin
  Self.Clear;
  SysUtils.FreeAndNil(Self.fItemGuard);
end; // .destructor TObjArray.Destroy

function TObjArray.KeyToHash ({n} Key: pointer): integer;
begin
  result  :=  Crypto.Bb2011Encode(integer(Key));
end; // .function TObjArray.KeyToHash

function TObjArray.HashToKey (Hash: integer): {n} pointer;
begin
  result  :=  pointer(Crypto.Bb2011Decode(Hash));
end; // .function TObjArray.HashToKey

function TObjArray.IsValidValue ({n} Value: pointer): boolean;
begin
  result  :=  Self.ItemGuardProc(Value, Self.ItemsAreObjects, Utils.TItemGuard(Self.fItemGuard));
end; // .function TObjArray.IsValidValue 

function TObjArray.CalcCritDepth: integer;
begin
  result  :=  Alg.IntLog2(Self.NodeCount + 1) shl 1;
end; // .function TObjArray.CalcCritDepth

procedure TObjArray.FreeNodeValue (Node: PObjArrayNode);
begin
  {!} Assert(Node <> nil);
  if Self.OwnsItems then begin
    if Self.ItemsAreObjects then begin
      TObject(Node.Value).Free;
    end // .if
    else begin
      FreeMem(Node.Value);
    end; // .else
  end; // .if
  
  Node.Value  :=  nil;
end; // .procedure TObjArray.FreeNodeValue

procedure TObjArray.FreeNode ({IN} var {n} Node: PObjArrayNode);
begin
  if Node <> nil then begin
    Self.FreeNodeValue(Node);
    Self.FreeNode(Node.ChildNodes[LEFT_CHILD]);
    Self.FreeNode(Node.ChildNodes[RIGHT_CHILD]);
    Dispose(Node); Node :=  nil;
  end; // .if
end; // .procedure TObjArray.FreeNode

procedure TObjArray.RemoveNode ({n} ParentNode: PObjArrayNode; Node: PObjArrayNode);
var
{U} RightClosestNodeParent: PObjArrayNode;
{U} RightClosestNode:       PObjArrayNode;
    NodeIsRoot:             boolean;
    NodeSide:               TChildNodeSide;
  
begin
  {!} Assert(Node <> nil);
  RightClosestNodeParent  :=  nil;
  RightClosestNode        :=  nil;
  NodeSide                :=  FALSE;
  // * * * * * //
  NodeIsRoot  :=  ParentNode = nil;
  
  if Self.NodeCount = 1 then begin
    {!} Assert(NodeIsRoot);
    {!} Assert(Node = Self.fRoot);
    Dispose(Self.fRoot); Self.fRoot :=  nil;
  end // .if
  else begin
    if not NodeIsRoot then begin
      NodeSide  :=  Node.Hash >= ParentNode.Hash;
    end; // .if
    (* N
      - -
    *)
    if (Node.ChildNodes[LEFT_CHILD] = nil) and (Node.ChildNodes[RIGHT_CHILD] = nil) then begin
      ParentNode.ChildNodes[NodeSide] :=  nil;
      Dispose(Node); Node :=  nil;
    end // .if
    (* N
      - R
    *)
    else if Node.ChildNodes[LEFT_CHILD] = nil then begin
      if NodeIsRoot then begin
        Self.fRoot  :=  Node.ChildNodes[RIGHT_CHILD];
      end // .if
      else begin
        ParentNode.ChildNodes[NodeSide] :=  Node.ChildNodes[RIGHT_CHILD];
      end; // .else
      
      Dispose(Node); Node :=  nil;
    end // .ELSEIF
    (* N
      L -
    *)
    else if Node.ChildNodes[RIGHT_CHILD] = nil then begin
      if NodeIsRoot then begin
        Self.fRoot  :=  Node.ChildNodes[LEFT_CHILD];
      end // .if
      else begin
        ParentNode.ChildNodes[NodeSide] :=  Node.ChildNodes[LEFT_CHILD];
      end; // .else
      
      Dispose(Node); Node :=  nil;
    end // .ELSEIF
    (* N
      L R
    *)
    else begin
      RightClosestNodeParent  :=  Node;
      RightClosestNode        :=  Node.ChildNodes[RIGHT_CHILD];
      
      while RightClosestNode.ChildNodes[LEFT_CHILD] <> nil do begin
        RightClosestNodeParent  :=  RightClosestNode;
        RightClosestNode        :=  RightClosestNode.ChildNodes[LEFT_CHILD];
      end; // .while
      
      Node.Value  :=  RightClosestNode.Value; RightClosestNode.Value  :=  nil;
      Node.Hash   :=  RightClosestNode.Hash;
      Self.RemoveNode(RightClosestNodeParent, RightClosestNode);
    end; // .else
  end; // .else
end; // .procedure TObjArray.RemoveNode

procedure TObjArray.Clear;
begin
  {!} Assert(not Self.Locked);
  Self.FreeNode(Self.fRoot);
  Self.fNodeCount :=  0;
end; // .procedure TObjArray.Clear

function TObjArray.CloneNode ({n} Node: PObjArrayNode): {On} PObjArrayNode;
begin
  if Node = nil then begin
    result  :=  nil;
  end // .if
  else begin
    New(result);
    result.Hash :=  Node.Hash;
    {!} Assert(Self.IsValidValue(Node.Value));
    
    if (Node.Value = nil) or (not Self.OwnsItems) then begin
      result.Value  :=  Node.Value;
    end // .if
    else begin
      {!} Assert(Self.ItemsAreObjects);
      {!} Assert(TObject(Node.Value) IS Utils.TCloneable);
      result.Value  :=  Utils.TCloneable(Node.Value).Clone;
    end; // .else
    
    result.ChildNodes[LEFT_CHILD]   :=  Self.CloneNode(Node.ChildNodes[LEFT_CHILD]);
    result.ChildNodes[RIGHT_CHILD]  :=  Self.CloneNode(Node.ChildNodes[RIGHT_CHILD]);
  end; // .else
end; // .function TObjArray.CloneNode

procedure TObjArray.Assign (Source: Utils.TCloneable);
var
{U} SrcArr: TObjArray;
  
begin
  {!} Assert(not Self.Locked);
  {!} Assert(Source <> nil);
  SrcArr  :=  Source AS TObjArray;
  // * * * * * //
  if Self <> Source then begin
    Self.Clear;
    Self.fOwnsItems       :=  SrcArr.OwnsItems;
    Self.fItemsAreObjects :=  SrcArr.ItemsAreObjects;
    Self.fItemGuardProc   :=  SrcArr.ItemGuardProc;
    Self.fItemGuard       :=  SrcArr.fItemGuard.Clone;
    Self.fNodeCount       :=  SrcArr.NodeCount;
    Self.fRoot            :=  Self.CloneNode(SrcArr.fRoot);
  end; // .if
end; // .procedure TObjArray.Assign

function ObjArrayCompareNodes (A, B: integer): integer;
begin
  if PObjArrayNode(A).Hash > PObjArrayNode(B).Hash then begin
    result  :=  +1;
  end // .if
  else if PObjArrayNode(A).Hash < PObjArrayNode(B).Hash then begin
    result  :=  -1;
  end // .ELSEIF
  else begin
    result  :=  0;
  end; // .else
end; // .function ObjArrayCompareNodes

procedure TObjArray.ConvertToLinearNodeArray (out Res: TLinearObjNodeArray);
var
    LeftInd:              integer;
    RightInd:             integer;
    RightCheckInd:        integer;
    NumNotProcessedNodes: integer;
{U} CurrNode:             PObjArrayNode;
    i:                    integer;
  
begin
  SetLength(Res.NodeArray, Self.NodeCount);
  Res.NodeCount :=  Self.NodeCount;
  
  if Self.NodeCount > 0 then begin
    CurrNode                :=  Self.fRoot;
    LeftInd                 :=  0;
    Res.NodeArray[LeftInd]  :=  CurrNode;
    RightInd                :=  Self.NodeCount;
    RightCheckInd           :=  RightInd - 1;
    NumNotProcessedNodes    :=  Self.NodeCount - 1;
    
    while NumNotProcessedNodes > 0 do begin
      if CurrNode.ChildNodes[RIGHT_CHILD] <> nil then begin
        Dec(RightInd);
        Res.NodeArray[RightInd] :=  CurrNode.ChildNodes[RIGHT_CHILD];
        Dec(NumNotProcessedNodes);
      end; // .if
      
      if CurrNode.ChildNodes[LEFT_CHILD] <> nil then begin
        CurrNode  :=  CurrNode.ChildNodes[LEFT_CHILD];
        Inc(LeftInd);
        Res.NodeArray[LeftInd]  :=  CurrNode;
        Dec(NumNotProcessedNodes);
      end // .if
      else begin
        CurrNode  :=  Res.NodeArray[RightCheckInd];
        Dec(RightCheckInd);
      end; // .else
    end; // .while
    
    for i:=0 to Self.NodeCount - 1 do begin
      Res.NodeArray[i].ChildNodes[LEFT_CHILD]   :=  nil;
      Res.NodeArray[i].ChildNodes[RIGHT_CHILD]  :=  nil;
    end; // .for
    
    Self.fRoot      :=  nil;
    Self.fNodeCount :=  0;
    Alg.CustomQuickSort(pointer(Res.NodeArray), 0, Res.NodeCount - 1, ObjArrayCompareNodes);
  end; // .if
end; // .procedure TObjArray.ConvertToLinearNodeArray

procedure TObjArray.Rebuild;
var
  LinearNodeArray:  TLinearObjNodeArray;
  NodeArray:        TObjNodeArray;
  
  procedure InsertNode (InsNode: PObjArrayNode);
  var
  {U} ParentNode: PObjArrayNode;
  {U} CurrNode:   PObjArrayNode;
    
  begin
    {!} Assert(InsNode <> nil);
    ParentNode  :=  nil;
    CurrNode    :=  Self.fRoot;
    // * * * * * //
    while CurrNode <> nil do begin
      ParentNode  :=  CurrNode;
      CurrNode    :=  CurrNode.ChildNodes[InsNode.Hash >= CurrNode.Hash];
    end; // .while
    
    ParentNode.ChildNodes[InsNode.Hash >= ParentNode.Hash]  :=  InsNode;
  end; // .procedure InsertNode
  
  procedure InsertNodeRange (MinInd, MaxInd: integer);
  var
      RangeLen:   integer;
      MiddleInd:  integer;
  {U} InsNode:    PObjArrayNode;
    
  begin
    RangeLen  :=  MaxInd - MinInd + 1;
    {!} Assert(RangeLen > 0);
    {!} Assert((MinInd >= 0) and (MaxInd < Length(NodeArray)));
    // * * * * * //
    MiddleInd :=  MinInd + (MaxInd - MinInd) shr 1;
    InsNode   :=  NodeArray[MiddleInd];
    
    if Self.fRoot = nil then begin
      Self.fRoot  :=  InsNode;
    end // .if
    else begin
      InsertNode(InsNode);
    end; // .else
    
    if RangeLen > 2 then begin
      InsertNodeRange(MinInd, MiddleInd - 1);
      InsertNodeRange(MiddleInd + 1, MaxInd);
    end // .if
    else if RangeLen = 2 then begin
      InsertNode(NodeArray[MiddleInd + 1]);
    end; // .ELSEIF
  end; // .procedure InsertNodeRange
  
begin
  {!} Assert(not Self.Locked);
  if Self.NodeCount > 2 then begin
    Self.ConvertToLinearNodeArray(LinearNodeArray);
    Self.fNodeCount :=  LinearNodeArray.NodeCount;
    NodeArray       :=  LinearNodeArray.NodeArray;
    InsertNodeRange(0, Self.NodeCount - 1);
  end; // .if
end; // .procedure TObjArray.Rebuild

function TObjArray.FindItem
(
      {n}   Key:        pointer;
  out {ni}  ParentNode: PObjArrayNode;
  out {ni}  ItemNode:   PObjArrayNode
): boolean;

var
  Hash:             integer;
  SearchDepth:      integer;
  CritSearchDepth:  integer;
  
begin
  {!} Assert(ParentNode = nil);
  {!} Assert(ItemNode = nil);
  result  :=  FALSE;
  
  if Self.NodeCount > 0 then begin
    Hash            :=  Self.KeyToHash(Key);
    CritSearchDepth :=  Self.CalcCritDepth;
    SearchDepth     :=  1;
    ItemNode        :=  Self.fRoot;
    
    while (ItemNode <> nil) and (ItemNode.Hash <> Hash) do begin
      Inc(SearchDepth);
      ParentNode  :=  ItemNode;
      ItemNode    :=  ItemNode.ChildNodes[Hash >= ItemNode.Hash];
    end; // .while
    
    if SearchDepth > CritSearchDepth then begin
      Self.Rebuild;
      ParentNode  :=  nil;
      ItemNode    :=  nil;
      result      :=  Self.FindItem(Key, ParentNode, ItemNode);
    end; // .if
    
    result  :=  ItemNode <> nil;
  end; // .if
end; // .function TObjArray.FindItem

function TObjArray.GetValue ({n} Key: pointer): {n} pointer;
var
{U} ItemNode:   PObjArrayNode;
{U} ParentNode: PObjArrayNode;
  
begin
  ItemNode    :=  nil;
  ParentNode  :=  nil;
  // * * * * * //
  if Self.FindItem(Key, ParentNode, ItemNode) then begin
    result  :=  ItemNode.Value;
  end // .if
  else begin
    result  :=  nil;
  end; // .else
end; // .function TObjArray.GetValue

function TObjArray.GetExistingValue ({n} Key: pointer; out {Un} Res: pointer): boolean;
var
{U} ItemNode:   PObjArrayNode;
{U} ParentNode: PObjArrayNode;
  
begin
  {!} Assert(Res = nil);
  ItemNode    :=  nil;
  ParentNode  :=  nil;
  // * * * * * //
  result  :=  Self.FindItem(Key, ParentNode, ItemNode);
  
  if result then begin
    Res :=  ItemNode.Value;
  end; // .if
end; // .function TObjArray.GetExistingValue

procedure TObjArray.SetValue ({n} Key: pointer; {OUn} NewValue: pointer);
var
{U} ItemNode:   PObjArrayNode;
{U} ParentNode: PObjArrayNode;
{O} NewNode:    PObjArrayNode;
  
begin
  ItemNode    :=  nil;
  ParentNode  :=  nil;
  NewNode     :=  nil;
  // * * * * * //
  {!} Assert(Self.IsValidValue(NewValue));
  if Self.FindItem(Key, ParentNode, ItemNode) then begin
    if ItemNode.Value <> NewValue then begin
      Self.FreeNodeValue(ItemNode);
      ItemNode.Value  :=  NewValue;
    end; // .if
  end // .if
  else begin
    New(NewNode);
    NewNode.Hash  :=  Self.KeyToHash(Key);
    NewNode.Value :=  NewValue;
    NewNode.ChildNodes[LEFT_CHILD]  :=  nil;
    NewNode.ChildNodes[RIGHT_CHILD] :=  nil;
    Inc(Self.fNodeCount);
    
    if Self.NodeCount > 1 then begin
      ParentNode.ChildNodes[NewNode.Hash >= ParentNode.Hash]  :=  NewNode; NewNode  :=  nil;
    end // .if
    else begin
      Self.fRoot  :=  NewNode; NewNode  :=  nil;
    end; // .else
  end; // .else   
end; // .procedure TObjArray.SetValue

function TObjArray.DeleteItem ({n} Key: pointer): boolean;
var
{U} ParentNode: PObjArrayNode;
{U} ItemNode:   PObjArrayNode;
  
begin
  {!} Assert(not Self.Locked);
  ItemNode    :=  nil;
  ParentNode  :=  nil;
  // * * * * * //
  result  :=  Self.FindItem(Key, ParentNode, ItemNode);
  
  if result then begin
    Self.RemoveNode(ParentNode, ItemNode);
    Dec(Self.fNodeCount);
  end; // .if
end; // .function TObjArray.DeleteItem

function TObjArray.TakeValue ({n} Key: pointer; out {OUn} Value: pointer): boolean;
var
{U} ParentNode: PObjArrayNode;
{U} ItemNode:   PObjArrayNode;

begin
  {!} Assert(Value = nil);
  ItemNode    :=  nil;
  ParentNode  :=  nil;
  // * * * * * //
  result  :=  Self.FindItem(Key, ParentNode, ItemNode);
  
  if result then begin
    Value :=  ItemNode.Value;
    {!} Assert(Self.IsValidValue(nil));
    ItemNode.Value  :=  nil;
  end; // .if
end; // .function TObjArray.TakeValue

function TObjArray.ReplaceValue
(
      {n}   Key:      pointer;
      {OUn} NewValue: pointer;
  out {OUn} OldValue: pointer
): boolean;

var
{U} ParentNode: PObjArrayNode;
{U} ItemNode:   PObjArrayNode;

begin
  {!} Assert(OldValue = nil);
  {!} Assert(Self.IsValidValue(NewValue));
  ItemNode          :=  nil;
  ParentNode        :=  nil;
  // * * * * * //
  result  :=  Self.FindItem(Key, ParentNode, ItemNode);
  
  if result then begin
    OldValue        :=  ItemNode.Value;
    ItemNode.Value  :=  NewValue;
  end; // .if
end; // .function TObjArray.ReplaceValue

procedure TObjArray.EndIterate;
begin
  {!} Assert(Self.fLocked);
  Self.fLocked  :=  FALSE;
end; // .procedure TObjArray.EndIterate

procedure TObjArray.BeginIterate;
var
  OptimalNumIterNodes:  integer;
  
begin
  {!} Assert(not Self.fLocked);
  OptimalNumIterNodes :=  Self.CalcCritDepth + 1;
  
  if Length(Self.fIterNodes) < OptimalNumIterNodes then begin
    SetLength(Self.fIterNodes, OptimalNumIterNodes);
  end; // .if
  
  if Self.NodeCount > 0 then begin
    Self.fIterNodeInd   :=  0;
    Self.fIterNodes[0]  :=  Self.fRoot;
  end // .if
  else begin
    Self.fIterNodeInd :=  -1;
  end; // .else
  
  Self.fLocked  :=  TRUE;
end; // .procedure TObjArray.BeginIterate

function TObjArray.IterateNext (out {Un} Key: pointer; out {Un} Value: pointer): boolean;
var
{U} IterNode: PObjArrayNode;  

begin
  {!} Assert(Self.Locked);
  {!} Assert(Key = nil);
  {!} Assert(Value = nil);
  IterNode  :=  nil;
  // * * * * * //
  result  :=  Self.fIterNodeInd >= 0;
  
  if result then begin
    IterNode  :=  Self.fIterNodes[Self.fIterNodeInd];
    Dec(Self.fIterNodeInd);
    
    if IterNode.ChildNodes[LEFT_CHILD] <> nil then begin
      Inc(Self.fIterNodeInd);
      Self.fIterNodes[Self.fIterNodeInd]  :=  IterNode.ChildNodes[LEFT_CHILD];
    end; // .if
    
    if IterNode.ChildNodes[RIGHT_CHILD] <> nil then begin
      Inc(Self.fIterNodeInd);
      Self.fIterNodes[Self.fIterNodeInd]  :=  IterNode.ChildNodes[RIGHT_CHILD];
    end; // .if
    
    Key   :=  Self.HashToKey(IterNode.Hash);
    Value :=  IterNode.Value;
  end; // .if
end; // .function TObjArray.IterateNext

function NewAssocArr
(
      HashFunc:           THashFunc;
  {n} KeyPreprocessFunc:  TKeyPreprocessFunc;
      OwnsItems:          boolean;
      ItemsAreObjects:    boolean;
      ItemType:           TClass;
      AllowNIL:           boolean
): TAssocArray;

var
{O} ItemGuard:  Utils.TDefItemGuard;

begin
  {!} Assert(ItemsAreObjects or (ItemType = Utils.NO_TYPEGUARD));
  ItemGuard :=  Utils.TDefItemGuard.Create;
  // * * * * * //
  ItemGuard.ItemType  :=  ItemType;
  ItemGuard.AllowNIL  :=  AllowNIL;
  result              :=  TAssocArray.Create
  (
    HashFunc,
    KeyPreprocessFunc,
    OwnsItems,
    ItemsAreObjects,
    @Utils.DefItemGuardProc,
    Utils.TItemGuard(ItemGuard)
  );
end; // .function NewAssocArr

function NewSimpleAssocArr
(
      HashFunc:           THashFunc;
  {n} KeyPreprocessFunc:  TKeyPreprocessFunc
): TAssocArray;

var
{O} ItemGuard:  Utils.TCloneable;

begin
  ItemGuard :=  nil;
  // * * * * * //
  result  :=  TAssocArray.Create
  (
    HashFunc,
    KeyPreprocessFunc,
    not Utils.OWNS_ITEMS,
    not Utils.ITEMS_ARE_OBJECTS,
    @Utils.NoItemGuardProc,
    ItemGuard
  );
end; // .function NewSimpleAssocArr

function NewStrictAssocArr ({n} TypeGuard: TClass; OwnsItems: boolean = TRUE): TAssocArray;
begin
  result  :=  NewAssocArr
  (
    Crypto.AnsiCRC32,
    SysUtils.AnsiLowerCase,
    OwnsItems,
    Utils.ITEMS_ARE_OBJECTS,
    TypeGuard,
    Utils.ALLOW_NIL
  );
end; // .function NewStrictAssocArr

function NewObjArr
(
  OwnsItems:        boolean;
  ItemsAreObjects:  boolean;
  ItemType:         TClass;
  AllowNIL:         boolean
): TObjArray;

var
{O} ItemGuard:  Utils.TDefItemGuard;

begin
  {!} Assert(ItemsAreObjects or (ItemType = Utils.NO_TYPEGUARD));
  ItemGuard :=  Utils.TDefItemGuard.Create;
  // * * * * * //
  ItemGuard.ItemType  :=  ItemType;
  ItemGuard.AllowNIL  :=  AllowNIL;
  result              :=  TObjArray.Create
  (
    OwnsItems,
    ItemsAreObjects,
    @Utils.DefItemGuardProc,
    Utils.TItemGuard(ItemGuard)
  );
end; // .function NewObjArr

function NewSimpleObjArr: TObjArray;
var
{O} ItemGuard:  Utils.TCloneable;

begin
  ItemGuard :=  nil;
  // * * * * * //
  result  :=  TObjArray.Create
  (
    not Utils.OWNS_ITEMS,
    not Utils.ITEMS_ARE_OBJECTS,
    @Utils.NoItemGuardProc,
    ItemGuard
  );
end; // .function NewSimpleObjArr

function NewStrictObjArr ({n} TypeGuard: TClass): TObjArray;
begin
  result  :=  NewObjArr(Utils.OWNS_ITEMS, Utils.ITEMS_ARE_OBJECTS, TypeGuard, Utils.ALLOW_NIL);
end; // .function NewStrictObjArr

end.
