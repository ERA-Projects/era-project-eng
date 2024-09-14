unit Utils;
{
DESCRIPTION:  Addition to System unit
AUTHOR:       Alexander Shostak (aka Berserker aka EtherniDee aka BerSoft)
}

(***)  interface  (***)
uses Math;

const
  (* Global extra debugging marker *)
  DEBUG = TRUE;

  (* Relations between containers and their items *)
  OWNS_ITEMS        = TRUE;
  ITEMS_ARE_OBJECTS = TRUE;
  
  (* Items guards *)
  ALLOW_NIL     = TRUE;
  NO_TYPEGUARD  = nil;


type
  char = System.AnsiChar;
  int  = integer;

  (* Item pointers *)
  pobject   = ^TObject;
  pclass    = ^TClass;
  PCharByte = ^char;
  plongbool = ^LONGBOOL;
  
  (* array pointers *)
  TEndlessByteArr       = array [0..MAXLONGINT div sizeof(byte) - 1] of byte;
  PEndlessByteArr       = ^TEndlessByteArr;
  TEndlessIntArr        = array [0..MAXLONGINT div sizeof(integer) - 1] of integer;
  PEndlessIntArr        = ^TEndlessIntArr;
  TEndlessBoolArr       = array [0..MAXLONGINT div sizeof(boolean) - 1] of boolean;
  PEndlessBoolArr       = ^TEndlessBoolArr;
  TEndlessCharArr       = array [0..MAXLONGINT div sizeof(char) - 1] of char;
  PEndlessCharArr       = ^TEndlessCharArr;
  TEndlessWideCharArr   = array [0..MAXLONGINT div sizeof(WideChar) - 1] of WideChar;
  PEndlessWideCharArr   = ^TEndlessWideCharArr;
  TEndlessSingleArr     = array [0..MAXLONGINT div sizeof(single) - 1] of single;
  PEndlessSingleArr     = ^TEndlessSingleArr;
  TEndlessExtArr        = array [0..MAXLONGINT div sizeof(extended) - 1] of extended;
  PEndlessExtArr        = ^TEndlessExtArr;
  TEndlessShortStrArr   = array [0..MAXLONGINT div sizeof(ShortString) - 1] of ShortString;
  PEndlessShortStrArr   = ^TEndlessShortStrArr;
  TEndlessPtrArr        = array [0..MAXLONGINT div sizeof(pointer) - 1] of pointer;
  PEndlessPtrArr        = ^TEndlessPtrArr;
  TEndlessPCharArr      = array [0..MAXLONGINT div sizeof(pchar) - 1] of pchar;
  PEndlessPCharArr      = ^TEndlessPCharArr;
  TEndlessPWideCharArr  = array [0..MAXLONGINT div sizeof(PWideChar) - 1] of PWideChar;
  PEndlessPWideCharArr  = ^TEndlessPWideCharArr;
  TEndlessObjArr        = array [0..MAXLONGINT div sizeof(TObject) - 1] of TObject;
  PEndlessObjArr        = ^TEndlessObjArr;
  TEndlessCurrArr       = array [0..MAXLONGINT div sizeof(currency) - 1] of currency;
  PEndlessCurrArr       = ^TEndlessCurrArr;
  TEndlessAnsiStrArr    = array [0..MAXLONGINT div sizeof(AnsiString) - 1] of AnsiString;
  PEndlessAnsiStrArr    = ^TEndlessAnsiStrArr;

  TArrayOfByte = array of byte;
  TArrayOfInt  = array of integer;
  TArrayOfStr  = array of string;
  
  TCharSet  = set of char;
  
  TEmptyRec = packed record end;
  
  TProcedure    = procedure;
  TObjProcedure = procedure of object;
  
  TCloneable  = class
    procedure Assign (Source: TCloneable); virtual;
    function  Clone: TCloneable;
  end; // .class TCloneable
  
  (* Containers items guards *)
  TItemGuard      = TCloneable;
  TItemGuardProc  = function ({n} Item: pointer; ItemIsObject: boolean; {n} Guard: TCloneable): boolean;
  
  TDefItemGuard = class (TCloneable)
    ItemType: TClass;
    AllowNIL: boolean;
    
    procedure Assign (Source: TCloneable); override;
  end; // .class TDefItemGuard
  
  TEventHandler = procedure ({n} Mes: TObject) of object;


(* Low level functions *)
function  PtrOfs ({n} BasePtr: pointer; Offset: integer): pointer; inline;
function  IsValidBuf ({n} Buf: pointer; BufSize: integer): boolean;
procedure CopyMem (Count: integer; {n} Source, Destination: pointer);
procedure Exchange (var A, B: integer);
procedure SetPcharValue (What: pchar; const Value: string; BufSize: integer);

(* Extra system functions *)
function  Even (Num: integer): boolean;

(* Item guards *)
function  NoItemGuardProc ({n} Item: pointer; ItemIsObject: boolean; {n} Guard: TCloneable): boolean;
function  DefItemGuardProc ({n} Item: pointer; ItemIsObject: boolean; {n} Guard: TCloneable): boolean;

function  EqualMethods (A, B: TMethod): boolean;

// Casts Obj to Class and assigns Res to Obj. Frees object on fail and assings nil to Res.
procedure CastOrFree ({On} Obj: TObject; CastToType: TClass; out {O} Res);

(* Given method. Returns its object/class *)
function ObjFromMethod (Method: TObjProcedure): TObject; inline;
function ClassFromMethod (Method: TObjProcedure): TClass; inline;

(* Ternary operator *)
function IfThen (Condition: boolean; SuccessResult: string; FailureResult: string): string; inline; overload;
function IfThen (Condition: boolean; SuccessResult: integer; FailureResult: integer): integer; inline; overload;


(***)  implementation  (***)


function PtrOfs ({n} BasePtr: pointer; Offset: integer): pointer;
begin
  result := pointer(integer(BasePtr) + Offset);
end; // .function PtrOfs

function IsValidBuf ({n} Buf: pointer; BufSize: integer): boolean;
begin
  {Buf <> NIL and BufSize = 0 is OK. Buf = NIL and BufSize > 0 is BAD. !BufSize >= 0}
  result := (BufSize >= 0) and ((Buf <> nil) or (BufSize = 0));
end; // .function IsValidBuf

procedure CopyMem (Count: integer; {n} Source, Destination: pointer);
begin
  {!} Assert(Count >= 0);
  {!} Assert((Count = 0) or ((Source <> nil) and (Destination <> nil)));
  System.Move(Source^, Destination^, Count);
end; // .procedure CopyMem

procedure Exchange (var A, B: integer);
var
  C:  integer;

begin
  C :=  A;
  A :=  B;
  B :=  C;
end; // .procedure Exchange

procedure SetPcharValue (What: pchar; const Value: string; BufSize: integer);
var
  NumBytesToCopy: integer;
   
begin
  {!} Assert(What <> nil);
  {!} Assert(BufSize > 0);
  NumBytesToCopy := Math.Min(Length(Value), BufSize - 1);
  
  if NumBytesToCopy > 0 then begin
    CopyMem(Length(Value), pchar(Value), What);
  end; // .if
  
  PCharByte(PtrOfs(What, NumBytesToCopy))^ := #0;
end; // .procedure SetPcharValue

procedure TCloneable.Assign (Source: TCloneable);
begin
end; // .procedure TCloneable.Assign

function TCloneable.Clone: TCloneable;
begin
  result := TCloneable(Self.ClassType.Create);
  result.Assign(Self);
end; // .function TCloneable.CreateNew

procedure TDefItemGuard.Assign (Source: TCloneable);
var
(* U *) SrcItemGuard: TDefItemGuard;

begin
  {!} Assert(Source <> nil);
  SrcItemGuard := Source AS TDefItemGuard;
  // * * * * * //
  Self.ItemType := SrcItemGuard.ItemType;
  Self.AllowNIL := SrcItemGuard.AllowNIL;
end; // .procedure TDefItemGuard.Assign

function Even (Num: integer): boolean;
begin
  result := not ODD(Num);
end; // .function Even

function NoItemGuardProc ({n} Item: pointer; ItemIsObject: boolean; {n} Guard: TCloneable): boolean;
begin
  result := TRUE;
end; // .function NoItemGuardProc

function DefItemGuardProc ({n} Item: pointer; ItemIsObject: boolean; {n} Guard: TCloneable): boolean;
var
(* U *) MyGuard:  TDefItemGuard;
  
begin
  {!} Assert(Guard <> nil);
  MyGuard :=  Guard AS TDefItemGuard;
  // * * * * * //
  result := (Item <> nil) or (MyGuard.AllowNIL);
  if ItemIsObject and (Item <> nil) and (MyGuard.ItemType <> NO_TYPEGUARD) then begin
    result := result and (TObject(Item) IS MyGuard.ItemType);
  end; // .if
end; // .function DefItemGuardProc

function EqualMethods (A, B: TMethod): boolean;
begin
  result := (A.Code = B.Code) and (A.Data = B.Data);
end; // .function EqualMethods

procedure CastOrFree ({On} Obj: TObject; CastToType: TClass; out {O} Res);
begin
  if Obj is CastToType then begin
    TObject(Res) := Obj;
  end else begin
    Obj.Free;
    TObject(Res) := nil;
  end; // .else
end; // .procedure CastOrFree

function ObjFromMethod (Method: TObjProcedure): TObject; inline;
begin
  result := TObject(TMethod(Method).Data);
end;

function ClassFromMethod (Method: TObjProcedure): TClass; inline;
begin
  result := TClass(TMethod(Method).Data);
end;

function IfThen (Condition: boolean; SuccessResult: string; FailureResult: string): string; inline; overload; begin if Condition then result := SuccessResult else result := FailureResult; end;
function IfThen (Condition: boolean; SuccessResult: integer; FailureResult: integer): integer; inline; overload; begin if Condition then result := SuccessResult else result := FailureResult; end;

end.
