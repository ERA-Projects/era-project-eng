UNIT Binman;
{
DESCRIPTION:  Binary patch manager
AUTHOR:       Alexander Shostak (aka Berserker aka EtherniDee aka BerSoft)
}

(***)  INTERFACE  (***)
USES
  SysUtils, Utils, StrLib, Lists, TypeWrappers, Files, TextScan, CFiles,
  Math;

CONST
  NUMBYTES_CMD_TRUNC  = 0;  // 0 bytes patch size means truncate at address


TYPE
  (* IMPORT *)
  TString = TypeWrappers.TString;

  TBytes  = ARRAY OF BYTE;

  PBinFile  = ^TBinFile;
  TBinFile  = PACKED RECORD (* FORMAT *)
    NumPatches: INTEGER;
    (*
    Patches:    ARRAY NumPatches OF TFileBinPatch;
    *)
    Patches:    Utils.TEmptyRec;
  END; // .RECORD TBinFile

  PBinFilePatch = ^TBinFilePatch;
  TBinFilePatch = PACKED RECORD (* FORMAT *)
    Addr:     CARDINAL;
    NumBytes: INTEGER;
    (*
    Bytes:    ARRAY NumBytes OF BYTE;
    *)
    Bytes:    Utils.TEmptyRec;
  END; // .RECORD TBinFilePatch

  TBinBlock = CLASS (Utils.TCloneable)
    Addr:     CARDINAL;
    InitialN: INTEGER;
    Bytes:    TBytes;
    
    PROCEDURE Assign (Source: Utils.TCloneable); OVERRIDE;
  END; // .CLASS TBinBlock

  TAddrConvertorFunc  = FUNCTION (OrigAddr: INTEGER): INTEGER;

  TBinPatch = CLASS
    (***) PROTECTED (***)
      {O} fBlocks:    {O} Lists.TList {OF PBinBlock};
      {O} fTags:      {O} Lists.TStringList {OF TString};
          fSorted:    BOOLEAN;
          fOptimized: BOOLEAN;

    (***) PUBLIC (***)
      CONSTRUCTOR Create;
      DESTRUCTOR  Destroy; OVERRIDE;
      PROCEDURE LoadCompiledPatch (CONST Contents: STRING);
      FUNCTION  LoadSourcePatch (CONST Contents: STRING; OUT Error: STRING): BOOLEAN;
      {ToleranceDist - if the distance between two closest patches is less or equal
      to this value, the whole range of bytes will be treated as changed part.
      Example: abxc => 12x3. [12]x[3] => [12x3]}
      PROCEDURE LoadDifference (CONST OrigStr, NewStr: STRING; ToleranceDist: INTEGER);
      PROCEDURE AddFromPatch(Patch: TBinPatch);
      FUNCTION  HasAddrBelow (UpperAddrLimit: CARDINAL): BOOLEAN;
      FUNCTION  MakeSourcePatch: STRING;
      FUNCTION  MakeCompiledPatch: STRING;
      FUNCTION  ApplyToStr (CONST OrigStr: STRING): STRING;
      PROCEDURE ConvertAddresses (AddrConvertorFunc: TAddrConvertorFunc);
      PROCEDURE Sort;
      PROCEDURE Optimize;
      PROCEDURE Clear;

      PROPERTY  Tags: Lists.TStringList READ fTags;
  END; // .CLASS TBinPatch


CONST
  DEF_TOLERANCE_DIST  = SIZEOF(TBinFilePatch) - 1;


(***) IMPLEMENTATION (***)


FUNCTION HexStrToBytes (CONST HexStr: STRING): TBytes;
VAR
  i:  INTEGER;
  
BEGIN
  {!} ASSERT(NOT ODD(LENGTH(HexStr)));
  SetLength(RESULT, LENGTH(HexStr) DIV 2);
  i :=  0;
  WHILE i < LENGTH(RESULT) DO BEGIN
    RESULT[i] :=
      (StrLib.HexCharToByte(HexStr[i * 2 + 1]) SHL 4) OR StrLib.HexCharToByte(HexStr[i * 2 + 2]);
    INC(i);
  END; // .WHILE
END; // .FUNCTION HexStrToBytes

FUNCTION BytesToHexStr (Bytes: TBytes): STRING;
VAR
  i:  INTEGER;

BEGIN
  SetLength(RESULT, LENGTH(Bytes) * 2);
  i :=  0;
  WHILE i < LENGTH(Bytes) DO BEGIN
    RESULT[i * 2 + 1] :=  StrLib.ByteToHexChar(Bytes[i] SHR 4);
    RESULT[i * 2 + 2] :=  StrLib.ByteToHexChar(Bytes[i] AND $0F);
    INC(i);
  END; // .WHILE
END; // .FUNCTION BytesToHexStr

FUNCTION BinBlocksCompare (A, B: INTEGER): INTEGER;
VAR
{U} BlockA: TBinBlock;
{U} BlockB: TBinBlock;

BEGIN
  BlockA  :=  TBinBlock(A);
  BlockB  :=  TBinBlock(B);
  {!} ASSERT(BlockA <> NIL);
  {!} ASSERT(BlockB <> NIL);
  // * * * * * //
  
  IF
    (
      (BlockA.Addr <= BlockB.Addr)  AND
      (BlockA.Addr + CARDINAL(LENGTH(BlockA.Bytes)) >= BlockB.Addr)
    ) OR
    (
      (BlockB.Addr <= BlockA.Addr)  AND
      (BlockB.Addr + CARDINAL(LENGTH(BlockB.Bytes)) >= BlockA.Addr)
    )
  THEN BEGIN
    RESULT  :=  BlockA.InitialN - BlockB.InitialN;
  END // .IF
  ELSE BEGIN
    IF BlockA.Addr > BlockB.Addr THEN BEGIN
      RESULT  :=  1;
    END // .IF
    ELSE IF BlockA.Addr < BlockB.Addr THEN BEGIN
      RESULT  :=  -1;
    END // .ELSEIF
    ELSE BEGIN
      RESULT  :=  0;
    END; // .ELSE
  END; // .ELSE
END; // .FUNCTION BinBlocksCompare
  
PROCEDURE TBinBlock.Assign (Source: Utils.TCloneable);
VAR
{U} SrcBlock: TBinBlock;

BEGIN
  {!} ASSERT(Source <> NIL);
  SrcBlock  :=  Source AS TBinBlock;
  // * * * * * //
  Self.Addr     :=  SrcBlock.Addr;
  Self.InitialN :=  SrcBlock.InitialN;
  Self.Bytes    :=  SrcBlock.Bytes;
END; // .PROCEDURE TBinBlock.Assign

CONSTRUCTOR TBinPatch.Create;
BEGIN
  Self.fBlocks                :=  Lists.NewStrictList(TBinBlock);
  Self.fTags                  :=  Lists.NewStrictStrList(TString);
  Self.fTags.CaseInsensitive  :=  TRUE;
  Self.fTags.Sorted           :=  TRUE;
END; // .CONSTRUCTOR TBinPatch.Create

DESTRUCTOR TBinPatch.Destroy;
BEGIN
  SysUtils.FreeAndNil(Self.fBlocks);
  SysUtils.FreeAndNil(Self.fTags);
END; // .DESTRUCTOR TBinPatch.Destroy

PROCEDURE TBinPatch.Clear;
BEGIN
  Self.fBlocks.Clear;
  Self.fTags.Clear;
  Self.fSorted    :=  FALSE;
  self.fOptimized :=  FALSE;
END; // .PROCEDURE TBinPatch.Clear

FUNCTION TBinPatch.LoadSourcePatch (CONST Contents: STRING; OUT Error: STRING): BOOLEAN;
CONST
  COMMENT_MARKER          = ';';
  TAG_KEYVALUE_SEPARATOR  = '=';
  LINE_END_MARKER         = #10;
  BLANKS                  = [#0..#32];
  LINE_BLANKS             = BLANKS - [LINE_END_MARKER];
  LINE_DELIMS             = [LINE_END_MARKER] + [COMMENT_MARKER];
  HEX_NUM                 = ['0'..'9', 'A'..'F', 'a'..'f'];

VAR
{O} Scanner:  TTextScanner;
{U} Block:    TBinBlock;
    StartPos: INTEGER;
    TagName:  STRING;
    TagValue: STRING;
    AddrStr:  STRING;
    BytesStr: STRING;
    Addr:     INTEGER;
    c:        CHAR;
    
    PROCEDURE ErrorAtPos (CONST ErrStr: STRING; ErrPos: INTEGER);
    BEGIN
      Scanner.GotoPos(ErrPos);
      Error :=  StrLib.BuildStr
      (
        '~ErrorText~.'#13#10'Error on line ~Line~ in position ~Position~.',
        [
          'ErrorText',  ErrStr,
          'Line',       SysUtils.IntToStr(Scanner.LineN),
          'Position',   SysUtils.IntToStr(ErrPos - Scanner.LineStartPos)
        ],
        '~'
      );
    END; // .PROCEDURE ErrorAtPos

BEGIN
  {!} ASSERT(Error = '');
  Scanner :=  TTextScanner.Create;
  Block   :=  NIL;
  // * * * * * //
  Self.Clear;
  RESULT  :=  TRUE;
  Scanner.Connect(Contents, LINE_END_MARKER);
  WHILE RESULT AND Scanner.SkipCharset(BLANKS) AND Scanner.GetCurrChar(c) DO BEGIN
    IF c = COMMENT_MARKER THEN BEGIN
      IF Scanner.GotoNextChar THEN BEGIN
        Scanner.ReadTokenTillDelim([TAG_KEYVALUE_SEPARATOR] + [LINE_END_MARKER], TagName);
        TagName :=  SysUtils.Trim(TagName);
        IF
          Scanner.GetCurrChar(c)        AND
          (c = TAG_KEYVALUE_SEPARATOR)  AND
          Scanner.GotoNextChar
        THEN BEGIN
          Scanner.ReadTokenTillDelim([LINE_END_MARKER], TagValue);
          TagValue  :=  SysUtils.Trim(TagValue);
        END // .IF
        ELSE BEGIN
          TagValue  :=  '';
        END; // .ELSE
      END; // .IF
      Self.fTags.Items[TagName] :=  TString.Create(TagValue);
    END // .IF
    ELSE BEGIN
      StartPos  :=  Scanner.Pos;
      Scanner.ReadToken(HEX_NUM, AddrStr);
      RESULT  :=  SysUtils.TryStrToInt('$' + AddrStr, Addr);
      IF NOT RESULT THEN BEGIN
        ErrorAtPos('Invalid address: "' + AddrStr + '"', StartPos);
      END // .IF
      ELSE IF Scanner.GetCurrChar(c) THEN BEGIN
        RESULT  :=  c IN BLANKS;
        IF NOT RESULT THEN BEGIN
          ErrorAtPos('Invalid separator: "' + c + '"', Scanner.Pos);
        END // .IF
        ELSE BEGIN
          IF
            Scanner.SkipCharset(LINE_BLANKS)  AND
            Scanner.GetCurrChar(c)            AND
            NOT (c IN LINE_DELIMS)
          THEN BEGIN
            StartPos  :=  Scanner.Pos;
            Scanner.ReadToken(HEX_NUM, BytesStr);
            Scanner.SkipCharset(LINE_BLANKS);
            RESULT  :=  Scanner.EndOfText OR (Scanner.GetCurrChar(c) AND (c IN LINE_DELIMS));
            IF NOT RESULT THEN BEGIN
              ErrorAtPos('Invalid character: "' + c + '"', Scanner.Pos);
            END; // .IF
            IF RESULT THEN BEGIN
              RESULT  :=  NOT ODD(LENGTH(BytesStr));
              IF NOT RESULT THEN BEGIN
                ErrorAtPos('Character count in data must be even', StartPos);
              END; // .IF
            END; // .IF
            IF RESULT THEN BEGIN
              Block       :=  TBinBlock.Create;
              Block.Addr  :=  Addr;
              Block.Bytes :=  HexStrToBytes(BytesStr);
              Self.fBlocks.Add(Block);
            END; // .IF
          END // .IF
          ELSE BEGIN
            Block       :=  TBinBlock.Create;
            Block.Addr  :=  Addr;
            Self.fBlocks.Add(Block);
          END; // .ELSE
        END; // .ELSE
      END; // .ELSEIF
    END; // .ELSE
  END; // .WHILE
  // * * * * * //
  SysUtils.FreeAndNil(Scanner);
END; // .FUNCTION TBinPatch.LoadSourcePatch

PROCEDURE TBinPatch.LoadCompiledPatch (CONST Contents: STRING);
VAR
{U} CurrPatch:  PBinFilePatch;
{U} CurrBlock:  TBinBlock;
    NumPatches: INTEGER;
    i:          INTEGER;

BEGIN
  CurrPatch :=  NIL;
  CurrBlock :=  NIL;
  // * * * * * //
  Self.Clear;
  IF LENGTH(Contents) >= SIZEOF(INTEGER) THEN BEGIN
    NumPatches  :=  PBinFile(Contents).NumPatches;
    CurrPatch   :=  @PBinFile(Contents).Patches;
    FOR i:=1 TO NumPatches DO BEGIN
      CurrBlock       :=  TBinBlock.Create;
      CurrBlock.Addr  :=  CurrPatch.Addr;
      IF CurrPatch.NumBytes > 0 THEN BEGIN
        SetLength(CurrBlock.Bytes, CurrPatch.NumBytes);
        Utils.CopyMem(CurrPatch.NumBytes, @CurrPatch.Bytes, @CurrBlock.Bytes[0]);
      END; // .IF
      Self.fBlocks.Add(CurrBlock);
      CurrPatch :=  Utils.PtrOfs(CurrPatch, SIZEOF(TBinFilePatch) + CurrPatch.NumBytes);
    END; // .FOR
  END; // .IF
END; // .PROCEDURE TBinPatch.LoadCompiledPatch

PROCEDURE TBinPatch.LoadDifference (CONST OrigStr, NewStr: STRING; ToleranceDist: INTEGER);
VAR
{U} CurrBlock:              TBinBlock;
    CommonLen:              INTEGER;
    StartDiffPos:           INTEGER;
    ToleranceZoneStartInd:  INTEGER;
    NumBytes:               INTEGER;
    i:                      INTEGER;
  
BEGIN
  {!} ASSERT(ToleranceDist >= 0);
  CurrBlock :=  NIL;
  // * * * * * //
  Self.Clear;
  CommonLen :=  Math.Min(LENGTH(OrigStr), LENGTH(NewStr));
  i         :=  1;
  WHILE i <= CommonLen DO BEGIN
    WHILE (i <= CommonLen) AND (OrigStr[i] = NewStr[i]) DO BEGIN
      INC(i);
    END; // .WHILE
    StartDiffPos          :=  i;
    ToleranceZoneStartInd :=  i;
    WHILE
      (i <= CommonLen)  AND
      ((OrigStr[i] <> NewStr[i]) OR ((i - ToleranceZoneStartInd) <= ToleranceDist))
    DO BEGIN
      IF OrigStr[i] <> NewStr[i] THEN BEGIN
        ToleranceZoneStartInd :=  i;
      END; // .IF
      INC(i);
    END; // .WHILE
    IF StartDiffPos <= CommonLen THEN BEGIN
      NumBytes        :=  ToleranceZoneStartInd - StartDiffPos + 1;
      CurrBlock       :=  TBinBlock.Create;
      CurrBlock.Addr  :=  StartDiffPos - 1;
      SetLength(CurrBlock.Bytes, NumBytes);
      Utils.CopyMem(NumBytes, POINTER(@NewStr[StartDiffPos]), @CurrBlock.Bytes[0]);
      Self.fBlocks.Add(CurrBlock);
    END; // .IF
  END; // .WHILE
  IF LENGTH(OrigStr) > CommonLen THEN BEGIN
    CurrBlock       :=  TBinBlock.Create;
    CurrBlock.Addr  :=  CommonLen;
    Self.fBlocks.Add(CurrBlock);
  END // .IF
  ELSE IF LENGTH(NewStr) > CommonLen THEN BEGIN
    CurrBlock       :=  TBinBlock.Create;
    CurrBlock.Addr  :=  CommonLen;
    SetLength(CurrBlock.Bytes, LENGTH(NewStr) - CommonLen);
    Utils.CopyMem(LENGTH(CurrBlock.Bytes), POINTER(@NewStr[CommonLen + 1]), @CurrBlock.Bytes[0]);
    Self.fBlocks.Add(CurrBlock);
  END; // .ELSEIF
  Self.fSorted    :=  TRUE;
  Self.fOptimized :=  TRUE;
END; // .PROCEDURE TBinPatch.LoadDifference

PROCEDURE TBinPatch.AddFromPatch(Patch: TBinPatch);
VAR
  i:  INTEGER;
  
BEGIN
  {!} ASSERT(Patch <> NIL);
  FOR i:=0 TO Patch.fBlocks.Count - 1 DO BEGIN
    Self.fBlocks.Add(TBinBlock(Patch.fBlocks[i]).Clone);
  END; // .FOR
  FOR i:=0 TO Patch.fTags.Count - 1 DO BEGIN
    Self.fTags.Items[Patch.fTags[i]]  :=  TString(Patch.fTags.Values[i]).Clone;
  END; // .FOR
  Self.fSorted    :=  FALSE;
  Self.fOptimized :=  FALSE;
END; // .PROCEDURE TBinPatch.AddFromPatch(Patch: TBinPatch)

FUNCTION TBinPatch.HasAddrBelow (UpperAddrLimit: CARDINAL): BOOLEAN;
BEGIN
  Self.Sort;
  RESULT  :=  (Self.fBlocks.Count > 0) AND (TBinBlock(Self.fBlocks[0]).Addr < UpperAddrLimit);
END; // .FUNCTION TBinPatch.HasAddrBelow

FUNCTION TBinPatch.MakeSourcePatch: STRING;
VAR
{O} Res:            StrLib.TStrBuilder;
{U} CurrBlock:      TBinBlock;
    MaxTagNameLen:  INTEGER;
    PostfixLen:     INTEGER;
    i:              INTEGER;
  
  FUNCTION GetMaxTagNameLen: INTEGER;
  VAR
    i:  INTEGER;
  
  BEGIN
    RESULT  :=  0;
    FOR i:=0 TO Self.fTags.Count - 1 DO BEGIN
      IF (LENGTH(Self.fTags[i]) > RESULT) AND (TString(Self.fTags.Values[i]).Value <> '') THEN BEGIN
        RESULT  :=  LENGTH(Self.fTags[i]);
      END; // .IF
    END; // .FOR
  END; // .FUNCTION GetMaxTagLen

BEGIN
  Res       :=  StrLib.TStrBuilder.Create;
  CurrBlock :=  NIL;
  // * * * * * //
  MaxTagNameLen :=  GetMaxTagNameLen;
  FOR i:=0 TO Self.fTags.Count - 1 DO BEGIN
    Res.Append('; ');
    Res.Append(Self.fTags[i]);
    IF TString(Self.fTags.Values[i]).Value <> '' THEN BEGIN
      PostfixLen  :=  MaxTagNameLen - LENGTH(Self.fTags[i]) + 1;
      Res.Append(StringOfChar(' ', PostfixLen));
      Res.Append('= ');
      Res.Append(TString(Self.fTags.Values[i]).Value);
    END; // .IF
    Res.Append(#13#10);
  END; // .FOR
  FOR i:=0 TO Self.fBlocks.Count - 1 DO BEGIN
    CurrBlock :=  Self.fBlocks[i];
    Res.Append(SysUtils.Format('%.8x', [CurrBlock.Addr]));
    Res.Append(' ');
    Res.Append(BytesToHexStr(CurrBlock.Bytes));
    Res.Append(#13#10);
  END; // .FOR
  RESULT  :=  Res.BuildStr;
  // * * * * * //
  SysUtils.FreeAndNil(Res);
END; // .FUNCTION TBinPatch.MakeSourcePatch

FUNCTION TBinPatch.MakeCompiledPatch: STRING;
VAR
{O} Res:        StrLib.TStrBuilder;
{U} CurrBlock:  TBinBlock;
    NumPatches: INTEGER;
    NumBytes:   INTEGER;
    i:          INTEGER;

BEGIN
  Res       :=  StrLib.TStrBuilder.Create;
  CurrBlock :=  NIL;
  // * * * * * //
  NumPatches  :=  Self.fBlocks.Count;
  Res.AppendBuf(SIZEOF(NumPatches), @NumPatches);
  FOR i:=0 TO Self.fBlocks.Count - 1 DO BEGIN
    CurrBlock :=  Self.fBlocks[i];
    Res.AppendBuf(SIZEOF(CurrBlock.Addr), @CurrBlock.Addr);
    NumBytes  :=  LENGTH(CurrBlock.Bytes);
    Res.AppendBuf(SIZEOF(NumBytes), @NumBytes);
    IF NumBytes > 0 THEN BEGIN
      Res.AppendBuf(NumBytes, @CurrBlock.Bytes[0]);
    END; // .IF
  END; // .FOR
  RESULT  :=  Res.BuildStr;
  // * * * * * //
  SysUtils.FreeAndNil(Res);
END; // .FUNCTION TBinPatch.MakeCompiledPatch

FUNCTION TBinPatch.ApplyToStr (CONST OrigStr: STRING): STRING;
VAR
{U} CurrBlock:      TBinBlock;
{U} Buf:            POINTER;
    ClonedPartSize: INTEGER;
    MinResLen:      INTEGER;
    i:              INTEGER;

BEGIN
  CurrBlock :=  NIL;
  Buf       :=  NIL;
  // * * * * * //
  RESULT  :=  OrigStr;
  IF Self.fBlocks.Count > 0 THEN BEGIN
    Self.Sort;
    i :=  0;
    WHILE (i < Self.fBlocks.Count) AND (TBinBlock(Self.fBlocks[i]).Bytes <> NIL) DO BEGIN
      INC(i);
    END; // .WHILE
    IF i < Self.fBlocks.Count THEN BEGIN
      ClonedPartSize  :=  TBinBlock(Self.fBlocks[i]).Addr;
    END // .IF
    ELSE BEGIN
      ClonedPartSize  :=  LENGTH(OrigStr);
    END; // .ELSE
    MinResLen :=
      TBinBlock(Self.fBlocks[Self.fBlocks.Count - 1]).Addr  +
      CARDINAL(LENGTH(TBinBlock(Self.fBlocks[Self.fBlocks.Count - 1]).Bytes));
    SetLength(RESULT, Math.Max(ClonedPartSize, MinResLen));
    IF RESULT <> '' THEN BEGIN
      Buf :=  POINTER(RESULT);
      IF ClonedPartSize < LENGTH(RESULT) THEN BEGIN
        FillChar(RESULT[ClonedPartSize + 1], LENGTH(RESULT) - ClonedPartSize, 0);
      END; // .IF
      FOR i:=0 TO Self.fBlocks.Count - 1 DO BEGIN
        CurrBlock :=  Self.fBlocks[i];
        IF CurrBlock.Bytes <> NIL THEN BEGIN
          Utils.CopyMem
          (
            LENGTH(CurrBlock.Bytes),
            @CurrBlock.Bytes[0],
            Utils.PtrOfs(Buf, CurrBlock.Addr)
          );
        END; // .IF
      END; // .FOR    
    END; // .IF
  END; // .IF
END; // .FUNCTION TBinPatch.ApplyToStr

PROCEDURE TBinPatch.ConvertAddresses (AddrConvertorFunc: TAddrConvertorFunc);
VAR
  i:  INTEGER;
  
BEGIN
  {!} ASSERT(@AddrConvertorFunc <> NIL);
  Self.fSorted  :=  FALSE;
  FOR i:=0 TO Self.fBlocks.Count - 1 DO BEGIN
    TBinBlock(Self.fBlocks[i]).Addr :=  AddrConvertorFunc(TBinBlock(Self.fBlocks[i]).Addr);
  END; // .FOR
END; // .PROCEDURE TBinPatch.ConvertAddresses

PROCEDURE TBinPatch.Sort;
VAR
  i:  INTEGER;

BEGIN
  IF NOT Self.fSorted THEN BEGIN
    FOR i := 0 TO Self.fBlocks.Count - 1 DO BEGIN
      TBinBlock(Self.fBlocks[i]).InitialN :=  i;
    END; // .FOR
  
    Self.fBlocks.CustomSort(BinBlocksCompare);
    Self.fSorted  :=  TRUE;
  END; // .IF
END; // .PROCEDURE TBinPatch.Sort

PROCEDURE TBinPatch.Optimize;
VAR
{O} Mem:                  Files.TFixedBuf;
{U} CurrBlock:            TBinBlock;
    StartBlockInd:        INTEGER;
    EndBlockInd:          INTEGER;
    BaseAddr:             INTEGER;
    PrevEndAddr:          INTEGER;
    EndAddr:              INTEGER;
    BlocksChainLen:       INTEGER;
    BlocksChainByteSize:  INTEGER;
    JoinedBytes:          TBytes;
    i:                    INTEGER;
    y:                    INTEGER;
  
BEGIN
  Mem       :=  Files.TFixedBuf.Create;
  CurrBlock :=  NIL;
  // * * * * * //
  IF NOT Self.fOptimized THEN BEGIN
    Self.Sort;
    i :=  0;
    WHILE i < Self.fBlocks.Count DO BEGIN
      WHILE (i < Self.fBlocks.Count) AND (TBinBlock(Self.fBlocks[i]).Bytes = NIL) DO BEGIN
        INC(i);
      END; // .WHILE
      IF i < Self.fBlocks.Count THEN BEGIN
        StartBlockInd :=  i;
        BaseAddr      :=  MAXLONGINT;
        EndAddr       :=  0;
        
        REPEAT
          CurrBlock   :=  Self.fBlocks[i];
          BaseAddr    :=  Math.Min(BaseAddr, CurrBlock.Addr);
          PrevEndAddr :=  CurrBlock.Addr + LENGTH(CurrBlock.Bytes);
          EndAddr     :=  Math.Max(EndAddr, PrevEndAddr);
          INC(i);
        UNTIL (i = Self.fBlocks.Count) OR (TBinBlock(Self.fBlocks[i]).Addr > EndAddr);
        
        BlocksChainLen  :=  i - StartBlockInd;
        EndBlockInd     :=  i - 1;
        
        IF BlocksChainLen > 1 THEN BEGIN
          BlocksChainByteSize :=  EndAddr - BaseAddr;
          SetLength(JoinedBytes, BlocksChainByteSize);
          Mem.Open(@JoinedBytes[0], BlocksChainByteSize, CFiles.MODE_WRITE);
          
          FOR y := StartBlockInd TO EndBlockInd DO BEGIN
            CurrBlock :=  Self.fBlocks[y];
            {!} ASSERT(Mem.Seek(CurrBlock.Addr - BaseAddr));
            {!} ASSERT(Mem.Write(LENGTH(CurrBlock.Bytes), @CurrBlock.Bytes[0]));
            Self.fBlocks[y] :=  NIL;
          END; // .FOR
          
          CurrBlock                   :=  TBinBlock.Create;
          Self.fBlocks[StartBlockInd] :=  CurrBlock;
          CurrBlock.Addr              :=  BaseAddr;
          CurrBlock.Bytes             :=  JoinedBytes;
        END; // .IF
      END; // .IF
    END; // .WHILE
    Self.fBlocks.Pack;
    Self.fOptimized :=  TRUE;
  END; // .IF
  // * * * * * //
  SysUtils.FreeAndNil(Mem);
END; // .PROCEDURE TBinPatch.Optimize

END.
