UNIT Utils;
{
DESCRIPTION:  Addition to System unit
AUTHOR:       Alexander Shostak (aka Berserker aka EtherniDee aka BerSoft)
}

(***)  INTERFACE  (***)

CONST
  (* Relations between containers and their items *)
  OWNS_ITEMS        = TRUE;
  ITEMS_ARE_OBJECTS = TRUE;
  
  (* Items guards *)
  ALLOW_NIL     = TRUE;
  NO_TYPEGUARD  = NIL;


TYPE
  (* Item pointers *)
  POBJECT   = ^TObject;
  PCLASS    = ^TClass;
  PCharByte = ^CHAR;
  PLONGBOOL = ^LONGBOOL;
  
  (* Array pointers *)
  TEndlessByteArr       = ARRAY [0..MAXLONGINT DIV SIZEOF(BYTE) - 1] OF BYTE;
  PEndlessByteArr       = ^TEndlessByteArr;
  TEndlessIntArr        = ARRAY [0..MAXLONGINT DIV SIZEOF(INTEGER) - 1] OF INTEGER;
  PEndlessIntArr        = ^TEndlessIntArr;
  TEndlessBoolArr       = ARRAY [0..MAXLONGINT DIV SIZEOF(BOOLEAN) - 1] OF BOOLEAN;
  PEndlessBoolArr       = ^TEndlessBoolArr;
  TEndlessCharArr       = ARRAY [0..MAXLONGINT DIV SIZEOF(CHAR) - 1] OF CHAR;
  PEndlessCharArr       = ^TEndlessCharArr;
  TEndlessWideCharArr   = ARRAY [0..MAXLONGINT DIV SIZEOF(WideChar) - 1] OF WideChar;
  PEndlessWideCharArr   = ^TEndlessWideCharArr;
  TEndlessExtArr        = ARRAY [0..MAXLONGINT DIV SIZEOF(EXTENDED) - 1] OF EXTENDED;
  PEndlessExtArr        = ^TEndlessExtArr;
  TEndlessShortStrArr   = ARRAY [0..MAXLONGINT DIV SIZEOF(ShortString) - 1] OF ShortString;
  PEndlessShortStrArr   = ^TEndlessShortStrArr;
  TEndlessPtrArr        = ARRAY [0..MAXLONGINT DIV SIZEOF(POINTER) - 1] OF POINTER;
  PEndlessPtrArr        = ^TEndlessPtrArr;
  TEndlessPCharArr      = ARRAY [0..MAXLONGINT DIV SIZEOF(PCHAR) - 1] OF PCHAR;
  PEndlessPCharArr      = ^TEndlessPCharArr;
  TEndlessPWideCharArr  = ARRAY [0..MAXLONGINT DIV SIZEOF(PWideChar) - 1] OF PWideChar;
  PEndlessPWideCharArr  = ^TEndlessPWideCharArr;
  TEndlessObjArr        = ARRAY [0..MAXLONGINT DIV SIZEOF(TObject) - 1] OF TObject;
  PEndlessObjArr        = ^TEndlessObjArr;
  TEndlessCurrArr       = ARRAY [0..MAXLONGINT DIV SIZEOF(CURRENCY) - 1] OF CURRENCY;
  PEndlessCurrArr       = ^TEndlessCurrArr;
  TEndlessAnsiStrArr    = ARRAY [0..MAXLONGINT DIV SIZEOF(AnsiString) - 1] OF AnsiString;
  PEndlessAnsiStrArr    = ^TEndlessAnsiStrArr;

  TArrayOfString  = ARRAY OF STRING;
  
  TCharSet  = SET OF CHAR;
  
  TEmptyRec = PACKED RECORD END;
  
  TProcedure  = PROCEDURE;
  
  TCloneable  = CLASS
    PROCEDURE Assign (Source: TCloneable); VIRTUAL;
    FUNCTION  Clone: TCloneable;
  END; // .CLASS TCloneable
  
  (* Containers items guards *)
  TItemGuard      = TCloneable;
  TItemGuardProc  = FUNCTION ((* n *) Item: POINTER; ItemIsObject: BOOLEAN; (* n *) Guard: TCloneable): BOOLEAN;
  
  TDefItemGuard = CLASS (TCloneable)
    ItemType: TClass;
    AllowNIL: BOOLEAN;
    
    PROCEDURE Assign (Source: TCloneable); OVERRIDE;
  END; // .CLASS TDefItemGuard
  
  TEventHandler = PROCEDURE (Mes: TObject) OF OBJECT;


(* Low level functions *)
FUNCTION  PtrOfs ((* n *) BasePtr: POINTER; Offset: INTEGER): POINTER;
FUNCTION  IsValidBuf ((* n *) Buf: POINTER; BufSize: INTEGER): BOOLEAN;
PROCEDURE CopyMem (Count: INTEGER; (* n *) Source, Destination: POINTER);
PROCEDURE Exchange (VAR A, B: INTEGER);

(* Extra system functions *)
FUNCTION  EVEN (Num: INTEGER): BOOLEAN;

(* Item guards *)
FUNCTION  NoItemGuardProc ((* n *) Item: POINTER; ItemIsObject: BOOLEAN; (* n *) Guard: TCloneable): BOOLEAN;
FUNCTION  DefItemGuardProc ((* n *) Item: POINTER; ItemIsObject: BOOLEAN; (* n *) Guard: TCloneable): BOOLEAN;


(***)  IMPLEMENTATION  (***)


FUNCTION PtrOfs ((* n *) BasePtr: POINTER; Offset: INTEGER): POINTER;
BEGIN
  RESULT  :=  POINTER(INTEGER(BasePtr) + Offset);
END; // .FUNCTION PtrOfs

FUNCTION IsValidBuf ((* n *) Buf: POINTER; BufSize: INTEGER): BOOLEAN;
BEGIN
  {Buf <> NIL and BufSize = 0 is OK. Buf = NIL and BufSize > 0 is BAD. !BufSize >= 0}
  RESULT  :=  (BufSize >= 0) AND ((Buf <> NIL) OR (BufSize = 0));
END; // .FUNCTION IsValidBuf

PROCEDURE CopyMem (Count: INTEGER; (* n *) Source, Destination: POINTER);
BEGIN
  {!} ASSERT(Count >= 0);
  {!} ASSERT((Count = 0) OR ((Source <> NIL) AND (Destination <> NIL)));
  System.MOVE(Source^, Destination^, Count);
END; // .PROCEDURE CopyMem

PROCEDURE Exchange (VAR A, B: INTEGER);
VAR
  C:  INTEGER;

BEGIN
  C :=  A;
  A :=  B;
  B :=  C;
END; // .PROCEDURE Exchange

PROCEDURE TCloneable.Assign (Source: TCloneable);
BEGIN
END; // .PROCEDURE TCloneable.Assign

FUNCTION TCloneable.Clone: TCloneable;
BEGIN
  RESULT  :=  TCloneable(Self.ClassType.Create);
  RESULT.Assign(Self);
END; // .FUNCTION TCloneable.CreateNew

PROCEDURE TDefItemGuard.Assign (Source: TCloneable);
VAR
(* U *) SrcItemGuard: TDefItemGuard;

BEGIN
  {!} ASSERT(Source <> NIL);
  SrcItemGuard  :=  Source AS TDefItemGuard;
  // * * * * * //
  Self.ItemType :=  SrcItemGuard.ItemType;
  Self.AllowNIL :=  SrcItemGuard.AllowNIL;
END; // .PROCEDURE TDefItemGuard.Assign

FUNCTION EVEN (Num: INTEGER): BOOLEAN;
BEGIN
  RESULT  :=  NOT ODD(Num);
END; // .FUNCTION EVEN

FUNCTION NoItemGuardProc ((* n *) Item: POINTER; ItemIsObject: BOOLEAN; (* n *) Guard: TCloneable): BOOLEAN;
BEGIN
  RESULT  :=  TRUE;
END; // .FUNCTION NoItemGuardProc

FUNCTION DefItemGuardProc ((* n *) Item: POINTER; ItemIsObject: BOOLEAN; (* n *) Guard: TCloneable): BOOLEAN;
VAR
(* U *) MyGuard:  TDefItemGuard;
  
BEGIN
  {!} ASSERT(Guard <> NIL);
  MyGuard :=  Guard AS TDefItemGuard;
  // * * * * * //
  RESULT  :=  (Item <> NIL) OR (MyGuard.AllowNIL);
  IF ItemIsObject AND (Item <> NIL) AND (MyGuard.ItemType <> NO_TYPEGUARD) THEN BEGIN
    RESULT  :=  RESULT AND (TObject(Item) IS MyGuard.ItemType);
  END; // .IF
END; // .FUNCTION DefItemGuardProc

END.
