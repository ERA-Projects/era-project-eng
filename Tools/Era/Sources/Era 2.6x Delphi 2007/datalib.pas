unit DataLib;
{
DESCRIPTION:  Convinient and widely used data structures
AUTHOR:       Alexander Shostak (aka Berserker aka EtherniDee aka BerSoft)
}

(***)  interface  (***)
uses
  SysUtils,
  Utils, Crypto, Lists, AssocArrays, StrLib, TypeWrappers;

const
  CASE_SENSITIVE   = FALSE; 
  CASE_INSENSITIVE = not CASE_SENSITIVE;


type
  TDict     = AssocArrays.TAssocArray {OF TObject};
  TObjDict  = AssocArrays.TObjArray {OF TObject};
  TList     = Lists.TList {OF TObject};
  TStrList  = Lists.TStringList {OF TObject};
  TString   = TypeWrappers.TString;

  (*  Combines access speed of TDist and order of TStrList  *)
  THashedList = class abstract
    protected
      function  GetItem (const Key: string): {Un} TObject; virtual; abstract;
      function  GetKey (Ind: integer): string; virtual; abstract;
      function  GetValue (Ind: integer): {Un} TObject; virtual; abstract;
      procedure SetValue (Ind: integer; {OUn} NewValue: TObject); virtual; abstract;
      function  GetCount: integer; virtual; abstract;
      
    public
      function  LinearFind (const Key: string; out Ind: integer): boolean; virtual; abstract;
      procedure InsertBefore
      (
              const Key:        string;
        {OUn}       Value:      TObject;
                    BeforeInd:  integer
      ); virtual; abstract;

      function  Take (Ind: integer): {OUn} TObject; virtual; abstract;
      procedure Delete (Ind: integer); virtual; abstract;
      procedure Clear; virtual; abstract;
      procedure  Add (const Key: string; {OUn} Value: TObject);

      property Count: integer read GetCount;
      
      property Items  [const Key: string]:  {n} TObject read GetItem; default;
      property Keys   [Ind: integer]:       string read GetKey;
      property Values [Ind: integer]:       {n} TObject read GetValue write SetValue;
  end; // .class THashedList
  
  IDictIterator = interface
    procedure BeginIterate ({U} Dict: TDict);
    function  IterNext: boolean;
    procedure EndIterate;
    function  GetIterKey: string;
    function  GetIterValue: {Un} TObject;
    
    property IterKey:   string read GetIterKey;
    property IterValue: {n} TObject read GetIterValue;
  end; // .interface IDictIterator
  
  IObjDictIterator = interface
    procedure BeginIterate (aDict: TObjDict);
    function  IterNext: boolean;
    procedure EndIterate;
    function  GetIterKey: {n} pointer;
    function  GetIterValue: {n} TObject;
    
    property IterKey:   pointer read GetIterKey;
    property IterValue: {n} TObject read GetIterValue;
  end; // .interface IObjDictIterator

  TSerializeProc   = procedure ({Un} Data: pointer; Writer: StrLib.IStrBuilder);
  TUnserializeFunc = function (ByteMapper: StrLib.IByteMapper): {UOn} pointer;


function  NewDict (OwnsItems, CaseInsensitive: boolean): {O} TDict;
function  NewObjDict (OwnsItems: boolean): {O} TObjDict;
function  NewList (OwnsItems: boolean): {O} TList;
function  NewStrList (OwnsItems: boolean; CaseInsensitive: boolean): {O} TStrList;
function  NewStrListFromStrArr (StrArr: Utils.TArrayOfStr;
                                OwnsItems: boolean; CaseInsensitive: boolean): {O} TStrList;
function  NewHashedList (OwnsItems, CaseInsensitive: boolean): {O} THashedList;
function  IterateDict ({U} Dict: TDict): IDictIterator;
function  IterateObjDict (aObjDict: TObjDict): IObjDictIterator;
procedure JoinLists (MainList, DependentList: TList);
function  DictToStrList ({n} Dict: TDict; CaseInsensitive: boolean): {O} TStrList {U};
function  GetObjDictKeys ({n} ObjDict: TObjDict): {O} TList {U};

(* Returns flipped associativa array with values as keys and keys as values (wrapped in TString) *)
function  FlipDict (Dict: TDict): {O} TObjDict {O} {OF TString};

function  SerializeDict (Dict: TDict; ItemSerializer: TSerializeProc = nil): string;
function  UnserializeDict (const Data: string; OwnsItems: boolean; CaseInsensitive: boolean; ItemUnserializer: TUnserializeFunc = nil): {O} TDict {UOn};
function  SerializeObjDict (Dict: TObjDict; KeySerializer: TSerializeProc = nil; ValueSerializer: TSerializeProc = nil): string;
function  UnserializeObjDict (const Data: string; OwnsItems: boolean; KeyUnserializer: TUnserializeFunc = nil; ValueUnserializer: TUnserializeFunc = nil): {O} TObjDict {UOn};


(***) implementation (***)


type
  TStdHashedList = class (THashedList)
    protected
      {O} fItemList:  {OU} TStrList;
      {O} fItems:     {U}  TDict;

      function  GetItem (const Key: string): {Un} TObject; override;
      function  GetKey (Ind: integer): string; override;
      function  GetValue (Ind: integer): {Un} TObject; override;
      procedure SetValue (Ind: integer; {OUn} NewValue: TObject); override;
      function  GetCount: integer; override;

    public
      constructor Create (OwnsItems, CaseInsensitive: boolean);
      destructor  Destroy; override;

      function  LinearFind (const Key: string; out Ind: integer): boolean; override;
      procedure InsertBefore
      (
              const Key:        string;
        {OUn}       Value:      TObject;
                    BeforeInd:  integer
      ); override;

      function  Take (Ind: integer): {OUn} TObject; override;
      procedure Delete (Ind: integer); override;
      procedure Clear; override;
  end; // .class TStdHashedList
  
  TDictIterator = class (TInterfacedObject, IDictIterator)
    protected
      {U}   fDict:      TDict;
      {Un}  fIterValue: TObject;
            fIterKey:   string;
            fIterating: boolean;
            
    public
      procedure BeginIterate ({U} Dict: TDict);
      function  IterNext: boolean;
      procedure EndIterate;
      function  GetIterKey: string;
      function  GetIterValue: {Un} TObject;
  end; // .class TDictIterator
  
  TObjDictIterator = class (TInterfacedObject, IObjDictIterator)
    protected
      {U}   fObjDict:   TObjDict;
      {Un}  fIterValue: TObject;
      {Un}  fIterKey:   pointer;
            fIterating: boolean;
            
    public
      procedure BeginIterate ({U} aObjDict: TObjDict);
      function  IterNext: boolean;
      procedure EndIterate;
      function  GetIterKey: {n} pointer;
      function  GetIterValue: {n} TObject;
  end; // .class TObjDictIterator


function NewDict (OwnsItems, CaseInsensitive: boolean): {O} TDict;
var
  KeyPreprocessFunc:  AssocArrays.TKeyPreprocessFunc;

begin
  if CaseInsensitive then begin
    KeyPreprocessFunc :=  SysUtils.AnsiLowerCase;
  end // .if
  else begin
    KeyPreprocessFunc :=  nil;
  end; // .else

  result  :=  AssocArrays.NewAssocArr
  (
    Crypto.AnsiCRC32,
    KeyPreprocessFunc,
    OwnsItems,
    Utils.ITEMS_ARE_OBJECTS and OwnsItems,
    Utils.NO_TYPEGUARD,
    Utils.ALLOW_NIL
  );
end; // .function NewDict

function NewObjDict (OwnsItems: boolean): {O} TObjDict;
begin
  result  :=  AssocArrays.NewObjArr
  (
    OwnsItems,
    Utils.ITEMS_ARE_OBJECTS and OwnsItems,
    Utils.NO_TYPEGUARD,
    Utils.ALLOW_NIL
  );
end; // .function NewObjDict

function NewList (OwnsItems: boolean): {O} TList;
begin
  result  :=  Lists.NewList
  (
    OwnsItems,
    Utils.ITEMS_ARE_OBJECTS and OwnsItems,
    Utils.NO_TYPEGUARD,
    Utils.ALLOW_NIL
  );
end; // .function NewList

function NewStrList (OwnsItems: boolean; CaseInsensitive: boolean): {O} TStrList;
begin
  result := Lists.NewStrList
  (
    OwnsItems,
    Utils.ITEMS_ARE_OBJECTS and OwnsItems,
    Utils.NO_TYPEGUARD,
    Utils.ALLOW_NIL
  );
  
  result.CaseInsensitive := CaseInsensitive;
end; // .function NewStrList

function NewStrListFromStrArr (StrArr: Utils.TArrayOfStr;
                               OwnsItems: boolean; CaseInsensitive: boolean): {O} TStrList;
var
  i: integer;

begin
  result := NewStrList(OwnsItems, CaseInsensitive);

  for i := 0 to High(StrArr) do begin
    result.Add(StrArr[i]);
  end; // .for
end; // .function NewStrListFromStrArr

function NewHashedList (OwnsItems, CaseInsensitive: boolean): {O} THashedList;
begin
  result  :=  TStdHashedList.Create(OwnsItems, CaseInsensitive);
end; // .function NewHashedList

procedure THashedList.Add (const Key: string; {OUn} Value: TObject);
begin
  Self.InsertBefore(Key, Value, Self.Count);
end; // .procedure THashedList.Add

constructor TStdHashedList.Create (OwnsItems, CaseInsensitive: boolean);
begin
  Self.fItemList  :=  NewStrList(OwnsItems, CaseInsensitive);
  Self.fItems     :=  NewDict(not Utils.OWNS_ITEMS, CaseInsensitive);
end; // .constructor TStdHashedList.Create

destructor TStdHashedList.Destroy;
begin
  SysUtils.FreeAndNil(Self.fItems);
  SysUtils.FreeAndNil(Self.fItemList);
end; // .destructor TStdHashedList.Destroy

function TStdHashedList.GetItem (const Key: string): {Un} TObject;
begin
  result  :=  Self.fItems[Key];
end; // .function TStdHashedList.GetItem

function TStdHashedList.GetKey (Ind: integer): string;
begin
  result  :=  Self.fItemList.Keys[Ind];
end; // .function TStdHashedList.GetKey

function TStdHashedList.GetValue (Ind: integer): {Un} TObject;
begin
  result  :=  Self.fItemList.Values[Ind];
end; // .function TStdHashedList.GetValue

procedure TStdHashedList.SetValue (Ind: integer; {OUn} NewValue: TObject);
begin
  Self.fItemList.Values[Ind]        :=  NewValue;
  Self.fItems[Self.fItemList[Ind]]  :=  NewValue;
end; // .procedure TStdHashedList.SetValue

function TStdHashedList.GetCount: integer;
begin
  result  :=  Self.fItemList.Count;
end; // .function TStdHashedList.GetCount

function TStdHashedList.LinearFind (const Key: string; out Ind: integer): boolean;
begin
  result  :=  Self.fItemList.Find(Key, Ind);
end; // .function TStdHashedList.LinearFind 

procedure TStdHashedList.InsertBefore
(
        const Key:        string;
  {OUn}       Value:      TObject;
              BeforeInd:  integer
);

var
{U} OldValue: TObject;

begin
  OldValue  :=  nil;
  // * * * * * //
  {!} Assert(not Self.fItems.GetExistingValue(Key, pointer(OldValue)));
  Self.fItemList.InsertObj(Key, Value, BeforeInd);
  Self.fItems[Key]  :=  Value;
end; // .procedure TStdHashedList.InsertBefore

procedure TStdHashedList.Delete (Ind: integer);  
begin
  Self.fItems.DeleteItem(Self.fItemList[Ind]);
  Self.fItemList.Delete(Ind);
end; // .procedure TStdHashedList.Delete

function TStdHashedList.Take (Ind: integer): {OUn} TObject;
begin
  result  :=  nil;
  Self.fItems.TakeValue(Self.fItemList[Ind], pointer(result));
  Self.fItemList.TakeValue(Ind);
end; // .function TStdHashedList.Take

procedure TStdHashedList.Clear;
begin
  Self.fItemList.Clear;
  Self.fItems.Clear;
end; // .procedure TStdHashedList.Clear

procedure TDictIterator.BeginIterate ({U} Dict: TDict);
begin
  {!} Assert(Dict <> nil);
  {!} Assert(not Dict.Locked);
  Self.fDict      :=  Dict;
  Self.fIterating :=  TRUE;
  Dict.BeginIterate;
end; // .procedure TDictIterator.BeginIterate

function TDictIterator.IterNext: boolean;
begin
  {!} Assert(Self.fIterating);
  Self.fIterValue :=  nil;
  result          :=  Self.fDict.IterateNext(Self.fIterKey, pointer(Self.fIterValue));
  
  if not result then begin
    Self.EndIterate;
  end; // .if
end; // .function TDictIterator.IterNext

procedure TDictIterator.EndIterate;
begin
  if Self.fIterating then begin
    Self.fDict.EndIterate;
    Self.fDict      :=  nil;
    Self.fIterating :=  FALSE;
  end; // .if
end; // .procedure TDictIterator.EndIterate

function TDictIterator.GetIterKey: string;
begin
  {!} Assert(Self.fIterating);
  result  :=  Self.fIterKey;
end; // .function TDictIterator.GetIterKey

function TDictIterator.GetIterValue: {Un} TObject;
begin
  {!} Assert(Self.fIterating);
  result  :=  Self.fIterValue;
end; // .function TDictIterator.GetIterValue

function IterateDict ({U} Dict: TDict): IDictIterator;
var
{O} DictIterator: TDictIterator;

begin
  {!} Assert(Dict <> nil);
  DictIterator  :=  TDictIterator.Create;
  // * * * * * //
  DictIterator.BeginIterate(Dict);
  result  :=  DictIterator; DictIterator  :=  nil;
end; // .function IterateDict

procedure TObjDictIterator.BeginIterate (aObjDict: TObjDict);
begin
  {!} Assert(aObjDict <> nil);
  {!} Assert(not aObjDict.Locked);
  Self.fObjDict   := aObjDict;
  Self.fIterating := TRUE;
  aObjDict.BeginIterate;
end; // .procedure TObjDictIterator.BeginIterate

function TObjDictIterator.IterNext: boolean;
begin
  {!} Assert(Self.fIterating);
  Self.fIterKey   := nil;
  Self.fIterValue := nil;
  result          := Self.fObjDict.IterateNext(Self.fIterKey, pointer(Self.fIterValue));
  
  if not result then begin
    Self.EndIterate;
  end; // .if
end; // .function TObjDictIterator.IterNext

procedure TObjDictIterator.EndIterate;
begin
  if Self.fIterating then begin
    Self.fObjDict.EndIterate;
    Self.fObjDict   := nil;
    Self.fIterating := FALSE;
  end; // .if
end; // .procedure TObjDictIterator.EndIterate

function TObjDictIterator.GetIterKey: {n} pointer;
begin
  {!} Assert(Self.fIterating);
  result := Self.fIterKey;
end; // .function TObjDictIterator.GetIterKey

function TObjDictIterator.GetIterValue: {n} TObject;
begin
  {!} Assert(Self.fIterating);
  result := Self.fIterValue;
end; // .function TObjDictIterator.GetIterValue

function IterateObjDict (aObjDict: TObjDict): IObjDictIterator;
var
{O} ObjDictIterator: TObjDictIterator;

begin
  {!} Assert(aObjDict <> nil);
  ObjDictIterator := TObjDictIterator.Create;
  // * * * * * //
  ObjDictIterator.BeginIterate(aObjDict);
  result := ObjDictIterator; ObjDictIterator := nil;
end; // .function IterateObjDict

procedure JoinLists (MainList, DependentList: TList);
var
  i: integer;
   
begin
  {!} Assert(MainList <> nil);
  {!} Assert(DependentList <> nil);
  for i := 0 to DependentList.Count - 1 do begin
    MainList.Add(DependentList[i]);
  end; // .for
end; // .procedure JoinLists

function DictToStrList ({n} Dict: TDict; CaseInsensitive: boolean): {O} TStrList {U};
begin
  result := NewStrList(not Utils.OWNS_ITEMS, CaseInsensitive);

  with IterateDict(Dict) do begin
    while IterNext do begin
      result.AddObj(IterKey, IterValue);
    end;
  end; // .with
end; // .function DictToStrList

function GetObjDictKeys ({n} ObjDict: TObjDict): {O} TList {U};
begin
  result := NewList(not Utils.OWNS_ITEMS);

  with IterateObjDict(ObjDict) do begin
    while IterNext do begin
      result.Add(IterKey);
    end;
  end; // .with
end; // .function GetObjDictKeys

function FlipDict (Dict: TDict): {O} TObjDict {OF TString};
begin
  {!} Assert(Dict <> nil);
  result := NewObjDict(not Utils.OWNS_ITEMS);

  with IterateDict(Dict) do begin
    while IterNext do begin
      result[IterValue] := TString.Create(IterKey);
    end;
  end;
end;

function SerializeDict (Dict: TDict; ItemSerializer: TSerializeProc = nil): string;
var
  Writer: StrLib.IStrBuilder;

begin
  {!} Assert(Dict <> nil);
  Writer := StrLib.MakeStr;
  Writer.WriteInt(Dict.ItemCount);

  with IterateDict(Dict) do begin
    while IterNext do begin
      Writer.WriteInt(length(IterKey));
      Writer.Append(IterKey);

      if @ItemSerializer <> nil then begin
        ItemSerializer(IterValue, Writer);
      end else begin
        Writer.WriteInt(integer(IterValue));
      end;
    end;
  end; // .with

  result := Writer.BuildStr;
end; // .function SerializeDict

function UnserializeDict (const Data: string; OwnsItems: boolean; CaseInsensitive: boolean; ItemUnserializer: TUnserializeFunc = nil): {O} TDict {UOn};
var
  Reader:   StrLib.IByteMapper;
  NumItems: integer;
  Key:      string;
  i:        integer;

begin
  result   := NewDict(OwnsItems, CaseInsensitive);
  Reader   := MapBytes(StrLib.StrAsByteSource(Data));
  NumItems := Reader.ReadInt;
  {!} Assert(NumItems >= 0);

  for i := 0 to NumItems - 1 do begin
    Key := Reader.ReadStrWithLenField(sizeof(integer));

    if @ItemUnserializer <> nil then begin
      result[Key] := ItemUnserializer(Reader);
    end else begin
      result[Key] := Ptr(Reader.ReadInt());
    end;
  end; // .for
end; // .function UnserializeDict

function SerializeObjDict (Dict: TObjDict; KeySerializer: TSerializeProc = nil; ValueSerializer: TSerializeProc = nil): string;
var
  Writer: StrLib.IStrBuilder;

begin
  {!} Assert(Dict <> nil);
  Writer := StrLib.MakeStr;
  Writer.WriteInt(Dict.ItemCount);

  with IterateObjDict(Dict) do begin
    while IterNext do begin
      if @KeySerializer <> nil then begin
        KeySerializer(IterKey, Writer);
      end else begin
        Writer.WriteInt(integer(IterKey));
      end;

      if @ValueSerializer <> nil then begin
        ValueSerializer(IterValue, Writer);
      end else begin
        Writer.WriteInt(integer(IterValue));
      end;
    end;
  end; // .with

  result := Writer.BuildStr;
end; // .function SerializeDict

function UnserializeObjDict (const Data: string; OwnsItems: boolean; KeyUnserializer: TUnserializeFunc = nil; ValueUnserializer: TUnserializeFunc = nil): {O} TObjDict {UOn};
var
     Reader:   StrLib.IByteMapper;
     NumItems: integer;
{Un} Key:      pointer;
     i:        integer;

begin
  Key := nil;
  // * * * * * //
  result   := NewObjDict(OwnsItems);
  Reader   := MapBytes(StrLib.StrAsByteSource(Data));
  NumItems := Reader.ReadInt;
  {!} Assert(NumItems >= 0);

  for i := 0 to NumItems - 1 do begin
    if @KeyUnserializer <> nil then begin
      Key := KeyUnserializer(Reader);
    end else begin
      Key := Ptr(Reader.ReadInt());
    end;

    if @ValueUnserializer <> nil then begin
      result[Key] := ValueUnserializer(Reader);
    end else begin
      result[Key] := Ptr(Reader.ReadInt());
    end;
  end; // .for
end; // .function UnserializeDict

end.
