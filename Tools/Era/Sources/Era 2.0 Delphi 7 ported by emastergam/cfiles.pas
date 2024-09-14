UNIT CFiles;
{
DESCRIPTION:  Abstract interface of virtual device with sequential access
AUTHOR:       Alexander Shostak (aka Berserker aka EtherniDee aka BerSoft)
}

(***)  INTERFACE  (***)
USES Math, Utils;

CONST
  MODE_OFF        = 0;
  MODE_READ       = 1;
  MODE_WRITE      = 2;
  MODE_READWRITE  = 3;

TYPE
  TDeviceMode = MODE_OFF..MODE_READWRITE;

  (*
  Note about detecting Input/Output (IO) errors.
  If an error occurs during any operation functions will return FALSE. But FALSE is also returned if end of file (EOF) is reached.
  The solution is to check EOF flag after FALSE result.
  If EOF is true, then nothing more can be read/written, otherwise IO error occured.
  
  Example:
  WHILE File.ReadByte(Arr[File.Pos]) DO BEGIN END;
  IF NOT File.EOF THEN BEGIN /* ERROR! */ END;
  *)
{#}  TAbstractFile = CLASS // ABSTRACT
    (***) PROTECTED (***)
{#}     MIN_BUF_SIZE  :Integer;
{#}     MAX_BUF_SIZE  :Integer;
        fMode:          TDeviceMode;
        fHasKnownSize:  BOOLEAN;
        fSizeIsConst:   BOOLEAN;
        fSize:          INTEGER;
        fPos:           INTEGER;
        fEOF:           BOOLEAN;
  
    (***) PUBLIC (***)
      (* Core *)
      constructor Create;
      {Reads 1..Count bytes}
      FUNCTION  ReadUpTo (Count: INTEGER; (* n *) Buf: POINTER; OUT BytesRead: INTEGER): BOOLEAN; VIRTUAL; ABSTRACT;
      {Writes 1..Count bytes}
      FUNCTION  WriteUpTo (Count: INTEGER; (* n *) Buf: POINTER; OUT ByteWritten: INTEGER): BOOLEAN; VIRTUAL; ABSTRACT;
      FUNCTION  Seek (NewPos: INTEGER): BOOLEAN; VIRTUAL; ABSTRACT;
    
      (* Reading *)
      FUNCTION  Read (Count: INTEGER; (* n *) Buf: POINTER): BOOLEAN;
      FUNCTION  ReadByte (OUT Res: BYTE): BOOLEAN;
      FUNCTION  ReadInt (OUT Res: INTEGER): BOOLEAN;
      FUNCTION  ReadStr (Count: INTEGER; OUT Res: STRING): BOOLEAN;
      FUNCTION  ReadAllToBuf (OUT Buf: POINTER; OUT Size: INTEGER): BOOLEAN;
      FUNCTION  ReadAllToStr (OUT Str: STRING): BOOLEAN;

      (* Writing *)
      FUNCTION  Write (Count: INTEGER; (* n *) Buf: POINTER): BOOLEAN;
      FUNCTION  WriteByte (Data: BYTE): BOOLEAN;
      FUNCTION  WriteWord (Data: WORD): BOOLEAN;
      FUNCTION  WriteInt (Data: INTEGER): BOOLEAN;
      FUNCTION  WriteStr (Data: STRING): BOOLEAN;
      FUNCTION  WriteFrom (Count: INTEGER; Source: TAbstractFile): BOOLEAN;
      FUNCTION  WriteAllFrom (Source: TAbstractFile): BOOLEAN;

      PROPERTY  Mode:         TDeviceMode READ fMode;
      PROPERTY  HasKnownSize: BOOLEAN READ fHasKnownSize;
      PROPERTY  SizeIsConst:  BOOLEAN READ fSizeIsConst;
      PROPERTY  Size:         INTEGER READ fSize;
      PROPERTY  Pos:          INTEGER READ fPos;
      PROPERTY  EOF:          BOOLEAN READ fEOF;
  END; // .CLASS TAbstractFile
  
  TItemInfo = CLASS
    IsDir:        BOOLEAN;
    HasKnownSize: BOOLEAN;
    FileSize:     INTEGER;
  END; // .CLASS TItemInfo
  
  TAbstractLocator  = CLASS
    (***) PROTECTED (***)
      fNotEnd:      BOOLEAN;
      fSearchMask:  STRING;
      
    (***) PUBLIC (***)
      DESTRUCTOR  Destroy; OVERRIDE;
      PROCEDURE FinitSearch; VIRTUAL; ABSTRACT;
      PROCEDURE InitSearch (CONST Mask: STRING); VIRTUAL; ABSTRACT;
      FUNCTION  GetNextItem (OUT ItemInfo: TItemInfo): STRING; VIRTUAL; ABSTRACT;
      FUNCTION  GetItemInfo (CONST ItemName: STRING; OUT ItemInfo: TItemInfo): BOOLEAN; VIRTUAL; ABSTRACT;
      
      PROPERTY  NotEnd:     BOOLEAN READ fNotEnd;
      PROPERTY  SearchMask: STRING READ fSearchMask;
  END; // .CLASS TAbstractLocator


(***) IMPLEMENTATION (***)


FUNCTION TAbstractFile.Read (Count: INTEGER; (* n *) {!} Buf: POINTER): BOOLEAN;
VAR
  TotalBytesRead: INTEGER;
  BytesRead:      INTEGER;

BEGIN
  {!} ASSERT(Count >= 0);
  TotalBytesRead  :=  0;
  WHILE (TotalBytesRead < Count) AND Self.ReadUpTo(Count - TotalBytesRead, Utils.PtrOfs(Buf, TotalBytesRead), BytesRead) DO BEGIN
    TotalBytesRead  :=  TotalBytesRead + BytesRead;
  END; // .WHILE
  RESULT  :=  TotalBytesRead = Count;
END; // .FUNCTION TAbstractFile.Read

FUNCTION TAbstractFile.ReadByte (OUT Res: BYTE): BOOLEAN;
VAR
  BytesRead:  INTEGER;

BEGIN
  RESULT  :=  Self.ReadUpTo(1, @Res, BytesRead);
END; // .FUNCTION TAbstractFile.ReadByte

FUNCTION TAbstractFile.ReadInt (OUT Res: INTEGER): BOOLEAN;
BEGIN
  RESULT  :=  Self.Read(SIZEOF(Res), @Res);
END; // .FUNCTION TAbstractFile.ReadInt

FUNCTION TAbstractFile.ReadStr (Count: INTEGER; OUT Res: STRING): BOOLEAN;
BEGIN
  SetLength(Res, Count);
  RESULT  :=  Self.Read(Count, POINTER(Res));
  IF NOT RESULT THEN BEGIN
    Res :=  '';
  END; // .IF
END; // .FUNCTION TAbstractFile.ReadStr

FUNCTION TAbstractFile.ReadAllToBuf (OUT Buf: POINTER; OUT Size: INTEGER): BOOLEAN;
VAR
  TotalBytesRead: INTEGER;
  BytesRead:      INTEGER;
  BufSize:        INTEGER;

BEGIN
  {!} ASSERT(Buf = NIL);
  IF Self.HasKnownSize THEN BEGIN
    Size  :=  Self.Size;
    GetMem(Buf, Size);
    RESULT  :=  Self.Read(Size, Buf);
  END // .IF
  ELSE BEGIN
    BufSize :=  Self.MIN_BUF_SIZE;
    GetMem(Buf, BufSize);
    TotalBytesRead  :=  0;
    WHILE Self.ReadUpTo(BufSize - TotalBytesRead, Utils.PtrOfs(Buf, TotalBytesRead), BytesRead) AND (NOT Self.EOF) DO BEGIN
      TotalBytesRead  :=  TotalBytesRead + BytesRead;
      IF TotalBytesRead = BufSize THEN BEGIN
        BufSize :=  BufSize * 2;
        ReallocMem(Buf, BufSize);
      END; // .IF
    END; // .WHILE
    RESULT  :=  Self.EOF;
    IF RESULT AND (BufSize > TotalBytesRead) THEN BEGIN
      ReallocMem(Buf, TotalBytesRead);
    END; // .IF
  END; // .ELSE
  // * * * * * //
  IF NOT RESULT THEN BEGIN
    FreeMem(Buf); Buf :=  NIL;
  END; // .IF
END; // .FUNCTION TAbstractFile.ReadAllToBuf

FUNCTION TAbstractFile.ReadAllToStr (OUT Str: STRING): BOOLEAN;
VAR
  TotalBytesRead: INTEGER;
  BytesRead:      INTEGER;
  StrLen:         INTEGER;

BEGIN
  IF Self.HasKnownSize THEN BEGIN
    RESULT  :=  Self.ReadStr(Self.Size, Str);
  END // .IF
  ELSE BEGIN
    StrLen  :=  Self.MIN_BUF_SIZE;
    SetLength(Str, StrLen);
    TotalBytesRead  :=  0;
    WHILE Self.ReadUpTo(StrLen - TotalBytesRead, @Str[TotalBytesRead + 1], BytesRead) AND (NOT Self.EOF) DO BEGIN
      TotalBytesRead  :=  TotalBytesRead + BytesRead;
      IF TotalBytesRead = StrLen THEN BEGIN
        StrLen  :=  StrLen * 2;
        SetLength(Str, StrLen);
      END; // .IF
    END; // .WHILE
    RESULT  :=  Self.EOF;
    IF RESULT AND (StrLen > TotalBytesRead) THEN BEGIN
      SetLength(Str, TotalBytesRead);
    END; // .IF
  END; // .ELSE
  // * * * * * //
  IF NOT RESULT THEN BEGIN
    Str :=  '';
  END; // .IF
END; // .FUNCTION TAbstractFile.ReadAllToStr

FUNCTION TAbstractFile.Write (Count: INTEGER; (* n *) {!} Buf: POINTER): BOOLEAN;
VAR
  TotalBytesWritten:  INTEGER;
  BytesWritten:       INTEGER;

BEGIN
  {!} ASSERT(Count >= 0);
  TotalBytesWritten :=  0;
  WHILE
    (TotalBytesWritten < Count) AND Self.WriteUpTo(Count - TotalBytesWritten, Utils.PtrOfs(Buf, TotalBytesWritten), BytesWritten)
  DO BEGIN
    TotalBytesWritten :=  TotalBytesWritten + BytesWritten;
  END; // .WHILE
  RESULT  :=  TotalBytesWritten = Count;
END; // .FUNCTION TAbstractFile.Write

FUNCTION TAbstractFile.WriteByte (Data: BYTE): BOOLEAN;
VAR
  BytesWritten: INTEGER;

BEGIN
  RESULT  :=  Self.WriteUpTo(SIZEOF(Data), @Data, BytesWritten);
END; // .FUNCTION TAbstractFile.WriteByte

FUNCTION TAbstractFile.WriteWord (Data: WORD): BOOLEAN;
VAR
  BytesWritten: INTEGER;

BEGIN
  RESULT  :=  Self.WriteUpTo(SIZEOF(Data), @Data, BytesWritten);
END; // .FUNCTION TAbstractFile.WriteByte

FUNCTION TAbstractFile.WriteInt (Data: INTEGER): BOOLEAN;
BEGIN
  RESULT  :=  Self.Write(SIZEOF(Data), @Data);
END; // .FUNCTION TAbstractFile.WriteInt

FUNCTION TAbstractFile.WriteStr (Data: STRING): BOOLEAN;
BEGIN
  RESULT  :=  Self.Write(LENGTH(Data), POINTER(Data));
END; // .FUNCTION TAbstractFile.WriteStr

FUNCTION TAbstractFile.WriteFrom (Count: INTEGER; Source: TAbstractFile): BOOLEAN;
VAR
  StrBuf:           STRING;
  NumWriteOpers:    INTEGER;
  NumBytesToWrite:  INTEGER;
  i:                INTEGER;

BEGIN
  {!} ASSERT(Count >= 0);
  {!} ASSERT(Source <> NIL);
  RESULT  :=  FALSE;
  SetLength(StrBuf, Math.Min(Count, Self.MAX_BUF_SIZE));
  IF Count <= MAX_BUF_SIZE THEN BEGIN
    RESULT  :=  Source.Read(Count, POINTER(StrBuf)) AND Self.Write(Count, POINTER(StrBuf));
  END // .IF
  ELSE BEGIN
    NumWriteOpers   :=  Math.Ceil(Count / MAX_BUF_SIZE);
    NumBytesToWrite :=  MAX_BUF_SIZE;
    i               :=  1;
    WHILE (i <= NumWriteOpers) AND RESULT DO BEGIN
      IF i = NumWriteOpers THEN BEGIN
        NumBytesToWrite :=  Count MOD MAX_BUF_SIZE;
      END; // .IF
      RESULT  :=  Source.Read(NumBytesToWrite, POINTER(StrBuf)) AND Self.Write(NumBytesToWrite, POINTER(StrBuf));
      INC(i);
    END; // .WHILE
  END; // .ELSE
END; // .FUNCTION TAbstractFile.WriteFrom

FUNCTION TAbstractFile.WriteAllFrom (Source: TAbstractFile): BOOLEAN;
VAR
  StrBuf:     STRING;
  BytesRead:  INTEGER;

BEGIN
  {!} ASSERT(Source <> NIL);
  RESULT  :=  TRUE;
  IF Source.HasKnownSize THEN BEGIN
    RESULT  :=  Self.WriteFrom(Source.Size, Source);
  END // .IF
  ELSE BEGIN
    SetLength(StrBuf, Self.MAX_BUF_SIZE);
    WHILE RESULT AND Source.ReadUpTo(Self.MAX_BUF_SIZE, POINTER(StrBuf), BytesRead) DO BEGIN
      RESULT  :=  Self.Write(BytesRead, POINTER(StrBuf));
    END; // .WHILE
    RESULT  :=  RESULT AND Source.EOF;
  END; // .ELSE
END; // .FUNCTION TAbstractFile.WriteAllFrom

DESTRUCTOR TAbstractLocator.Destroy;
BEGIN
  Self.FinitSearch;
END; // .DESTRUCTOR TAbstractLocator.Destroy

{#}constructor TAbstractFile.Create;
{#}begin
{#}    inherited;
{#}    MIN_BUF_SIZE  := 64 * 1024;
{#}    MAX_BUF_SIZE  := 1024 * 1024;
{#}end;

END.
