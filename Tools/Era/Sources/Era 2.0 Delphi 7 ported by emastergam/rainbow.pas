UNIT Rainbow;
{
DESCRIPTION:  Adds multi-color support to all Heroes texts
AUTHOR:       Alexander Shostak (aka Berserker aka EtherniDee aka BerSoft)
}

(***)  INTERFACE  (***)
USES
  Math, SysUtils, Utils, Crypto, Lists, AssocArrays, TextScan,
  Core, GameExt;

CONST
  TEXTMODE_15BITS = $3E0;
  TEXTMODE_16BITS = $7E0;

  DEF_COLOR = -1;
  
  TextColorMode:  PWORD = Ptr($694DB0);


TYPE
  TColor32To16Func  = FUNCTION (Color32: INTEGER): INTEGER;

  TTextBlock  = RECORD
    RealBlockLen: INTEGER;
    BlockLen:     INTEGER;
    Color16:      INTEGER;
  END; // .RECORD TTextBlock


PROCEDURE NameColor (Color32: INTEGER; CONST Name: STRING); STDCALL;


(***) IMPLEMENTATION (***)


VAR
{O} NamedColors:  {U} AssocArrays.TAssocArray {OF Color16: INTEGER};
{O} ColorStack:   {U} Lists.TList {OF Color16: INTEGER};
{O} TextScanner:  TextScan.TTextScanner;
    Color32To16:  TColor32To16Func;
    
    TextBlocks:   ARRAY [0..16 * 1024 - 1] OF TTextBlock;
    TextBlockInd: INTEGER;
    TextBuffer:   ARRAY [0..1024 * 1024 - 1] OF CHAR;
    CurrBlockPos: INTEGER;
    
    SeekBlockInd: INTEGER;
    SeekBlockPos: INTEGER;
    SeekPos:      INTEGER;


FUNCTION Color32To15Func (Color32: INTEGER): INTEGER;
BEGIN
  RESULT  :=
    ((Color32 AND $0000F8) SHR 3) OR
    ((Color32 AND $00F800) SHR 6) OR
    ((Color32 AND $F80000) SHR 9);
END; // .FUNCTION Color32To15Func

FUNCTION Color32To16Func (Color32: INTEGER): INTEGER;
BEGIN
  RESULT  :=
    ((Color32 AND $0000F8) SHR 3) OR
    ((Color32 AND $00FC00) SHR 5) OR
    ((Color32 AND $F80000) SHR 8);
END; // .FUNCTION Color32To16

PROCEDURE NameStdColors;
BEGIN
  NamedColors['AliceBlue']            :=  Ptr(Color32To16($F0F8FF));
  NamedColors['AntiqueWhite']         :=  Ptr(Color32To16($FAEBD7));
  NamedColors['Aqua']                 :=  Ptr(Color32To16($00FFFF));
  NamedColors['Aquamarine']           :=  Ptr(Color32To16($7FFFD4));
  NamedColors['Azure']                :=  Ptr(Color32To16($F0FFFF));
  NamedColors['Beige']                :=  Ptr(Color32To16($F5F5DC));
  NamedColors['Bisque']               :=  Ptr(Color32To16($FFE4C4));
  NamedColors['Black']                :=  Ptr(Color32To16($000000));
  NamedColors['BlanchedAlmond']       :=  Ptr(Color32To16($FFEBCD));
  NamedColors['Blue']                 :=  Ptr(Color32To16($0000FF));
  NamedColors['BlueViolet']           :=  Ptr(Color32To16($8A2BE2));
  NamedColors['Brown']                :=  Ptr(Color32To16($A52A2A));
  NamedColors['BurlyWood']            :=  Ptr(Color32To16($DEB887));
  NamedColors['CadetBlue']            :=  Ptr(Color32To16($5F9EA0));
  NamedColors['Chartreuse']           :=  Ptr(Color32To16($7FFF00));
  NamedColors['Chocolate']            :=  Ptr(Color32To16($D2691E));
  NamedColors['Coral']                :=  Ptr(Color32To16($FF7F50));
  NamedColors['CornflowerBlue']       :=  Ptr(Color32To16($6495ED));
  NamedColors['Cornsilk']             :=  Ptr(Color32To16($FFF8DC));
  NamedColors['Crimson']              :=  Ptr(Color32To16($DC143C));
  NamedColors['Cyan']                 :=  Ptr(Color32To16($00FFFF));
  NamedColors['DarkBlue']             :=  Ptr(Color32To16($00008B));
  NamedColors['DarkCyan']             :=  Ptr(Color32To16($008B8B));
  NamedColors['DarkGoldenRod']        :=  Ptr(Color32To16($B8860B));
  NamedColors['DarkGray']             :=  Ptr(Color32To16($A9A9A9));
  NamedColors['DarkGrey']             :=  Ptr(Color32To16($A9A9A9));
  NamedColors['DarkGreen']            :=  Ptr(Color32To16($006400));
  NamedColors['DarkKhaki']            :=  Ptr(Color32To16($BDB76B));
  NamedColors['DarkMagenta']          :=  Ptr(Color32To16($8B008B));
  NamedColors['DarkOliveGreen']       :=  Ptr(Color32To16($556B2F));
  NamedColors['Darkorange']           :=  Ptr(Color32To16($FF8C00));
  NamedColors['DarkOrchid']           :=  Ptr(Color32To16($9932CC));
  NamedColors['DarkRed']              :=  Ptr(Color32To16($8B0000));
  NamedColors['DarkSalmon']           :=  Ptr(Color32To16($E9967A));
  NamedColors['DarkSeaGreen']         :=  Ptr(Color32To16($8FBC8F));
  NamedColors['DarkSlateBlue']        :=  Ptr(Color32To16($483D8B));
  NamedColors['DarkSlateGray']        :=  Ptr(Color32To16($2F4F4F));
  NamedColors['DarkSlateGrey']        :=  Ptr(Color32To16($2F4F4F));
  NamedColors['DarkTurquoise']        :=  Ptr(Color32To16($00CED1));
  NamedColors['DarkViolet']           :=  Ptr(Color32To16($9400D3));
  NamedColors['DeepPink']             :=  Ptr(Color32To16($FF1493));
  NamedColors['DeepSkyBlue']          :=  Ptr(Color32To16($00BFFF));
  NamedColors['DimGray']              :=  Ptr(Color32To16($696969));
  NamedColors['DimGrey']              :=  Ptr(Color32To16($696969));
  NamedColors['DodgerBlue']           :=  Ptr(Color32To16($1E90FF));
  NamedColors['FireBrick']            :=  Ptr(Color32To16($B22222));
  NamedColors['FloralWhite']          :=  Ptr(Color32To16($FFFAF0));
  NamedColors['ForestGreen']          :=  Ptr(Color32To16($228B22));
  NamedColors['Fuchsia']              :=  Ptr(Color32To16($FF00FF));
  NamedColors['Gainsboro']            :=  Ptr(Color32To16($DCDCDC));
  NamedColors['GhostWhite']           :=  Ptr(Color32To16($F8F8FF));
  NamedColors['Gold']                 :=  Ptr(Color32To16($FFD700));
  NamedColors['GoldenRod']            :=  Ptr(Color32To16($DAA520));
  NamedColors['Gray']                 :=  Ptr(Color32To16($808080));
  NamedColors['Grey']                 :=  Ptr(Color32To16($808080));
  NamedColors['Green']                :=  Ptr(Color32To16($008000));
  NamedColors['GreenYellow']          :=  Ptr(Color32To16($ADFF2F));
  NamedColors['HoneyDew']             :=  Ptr(Color32To16($F0FFF0));
  NamedColors['HotPink']              :=  Ptr(Color32To16($FF69B4));
  NamedColors['IndianRed']            :=  Ptr(Color32To16($CD5C5C));
  NamedColors['Indigo']               :=  Ptr(Color32To16($4B0082));
  NamedColors['Ivory']                :=  Ptr(Color32To16($FFFFF0));
  NamedColors['Khaki']                :=  Ptr(Color32To16($F0E68C));
  NamedColors['Lavender']             :=  Ptr(Color32To16($E6E6FA));
  NamedColors['LavenderBlush']        :=  Ptr(Color32To16($FFF0F5));
  NamedColors['LawnGreen']            :=  Ptr(Color32To16($7CFC00));
  NamedColors['LemonChiffon']         :=  Ptr(Color32To16($FFFACD));
  NamedColors['LightBlue']            :=  Ptr(Color32To16($ADD8E6));
  NamedColors['LightCoral']           :=  Ptr(Color32To16($F08080));
  NamedColors['LightCyan']            :=  Ptr(Color32To16($E0FFFF));
  NamedColors['LightGoldenRodYellow'] :=  Ptr(Color32To16($FAFAD2));
  NamedColors['LightGray']            :=  Ptr(Color32To16($D3D3D3));
  NamedColors['LightGrey']            :=  Ptr(Color32To16($D3D3D3));
  NamedColors['LightGreen']           :=  Ptr(Color32To16($90EE90));
  NamedColors['LightPink']            :=  Ptr(Color32To16($FFB6C1));
  NamedColors['LightSalmon']          :=  Ptr(Color32To16($FFA07A));
  NamedColors['LightSeaGreen']        :=  Ptr(Color32To16($20B2AA));
  NamedColors['LightSkyBlue']         :=  Ptr(Color32To16($87CEFA));
  NamedColors['LightSlateGray']       :=  Ptr(Color32To16($778899));
  NamedColors['LightSlateGrey']       :=  Ptr(Color32To16($778899));
  NamedColors['LightSteelBlue']       :=  Ptr(Color32To16($B0C4DE));
  NamedColors['LightYellow']          :=  Ptr(Color32To16($FFFFE0));
  NamedColors['Lime']                 :=  Ptr(Color32To16($00FF00));
  NamedColors['LimeGreen']            :=  Ptr(Color32To16($32CD32));
  NamedColors['Linen']                :=  Ptr(Color32To16($FAF0E6));
  NamedColors['Magenta']              :=  Ptr(Color32To16($FF00FF));
  NamedColors['Maroon']               :=  Ptr(Color32To16($800000));
  NamedColors['MediumAquaMarine']     :=  Ptr(Color32To16($66CDAA));
  NamedColors['MediumBlue']           :=  Ptr(Color32To16($0000CD));
  NamedColors['MediumOrchid']         :=  Ptr(Color32To16($BA55D3));
  NamedColors['MediumPurple']         :=  Ptr(Color32To16($9370D8));
  NamedColors['MediumSeaGreen']       :=  Ptr(Color32To16($3CB371));
  NamedColors['MediumSlateBlue']      :=  Ptr(Color32To16($7B68EE));
  NamedColors['MediumSpringGreen']    :=  Ptr(Color32To16($00FA9A));
  NamedColors['MediumTurquoise']      :=  Ptr(Color32To16($48D1CC));
  NamedColors['MediumVioletRed']      :=  Ptr(Color32To16($C71585));
  NamedColors['MidnightBlue']         :=  Ptr(Color32To16($191970));
  NamedColors['MintCream']            :=  Ptr(Color32To16($F5FFFA));
  NamedColors['MistyRose']            :=  Ptr(Color32To16($FFE4E1));
  NamedColors['Moccasin']             :=  Ptr(Color32To16($FFE4B5));
  NamedColors['NavajoWhite']          :=  Ptr(Color32To16($FFDEAD));
  NamedColors['Navy']                 :=  Ptr(Color32To16($000080));
  NamedColors['OldLace']              :=  Ptr(Color32To16($FDF5E6));
  NamedColors['Olive']                :=  Ptr(Color32To16($808000));
  NamedColors['OliveDrab']            :=  Ptr(Color32To16($6B8E23));
  NamedColors['Orange']               :=  Ptr(Color32To16($FFA500));
  NamedColors['OrangeRed']            :=  Ptr(Color32To16($FF4500));
  NamedColors['Orchid']               :=  Ptr(Color32To16($DA70D6));
  NamedColors['PaleGoldenRod']        :=  Ptr(Color32To16($EEE8AA));
  NamedColors['PaleGreen']            :=  Ptr(Color32To16($98FB98));
  NamedColors['PaleTurquoise']        :=  Ptr(Color32To16($AFEEEE));
  NamedColors['PaleVioletRed']        :=  Ptr(Color32To16($D87093));
  NamedColors['PapayaWhip']           :=  Ptr(Color32To16($FFEFD5));
  NamedColors['PeachPuff']            :=  Ptr(Color32To16($FFDAB9));
  NamedColors['Peru']                 :=  Ptr(Color32To16($CD853F));
  NamedColors['Pink']                 :=  Ptr(Color32To16($FFC0CB));
  NamedColors['Plum']                 :=  Ptr(Color32To16($DDA0DD));
  NamedColors['PowderBlue']           :=  Ptr(Color32To16($B0E0E6));
  NamedColors['Purple']               :=  Ptr(Color32To16($800080));
  NamedColors['Red']                  :=  Ptr(Color32To16($FF0000));
  NamedColors['RosyBrown']            :=  Ptr(Color32To16($BC8F8F));
  NamedColors['RoyalBlue']            :=  Ptr(Color32To16($4169E1));
  NamedColors['SaddleBrown']          :=  Ptr(Color32To16($8B4513));
  NamedColors['Salmon']               :=  Ptr(Color32To16($FA8072));
  NamedColors['SandyBrown']           :=  Ptr(Color32To16($F4A460));
  NamedColors['SeaGreen']             :=  Ptr(Color32To16($2E8B57));
  NamedColors['SeaShell']             :=  Ptr(Color32To16($FFF5EE));
  NamedColors['Sienna']               :=  Ptr(Color32To16($A0522D));
  NamedColors['Silver']               :=  Ptr(Color32To16($C0C0C0));
  NamedColors['SkyBlue']              :=  Ptr(Color32To16($87CEEB));
  NamedColors['SlateBlue']            :=  Ptr(Color32To16($6A5ACD));
  NamedColors['SlateGray']            :=  Ptr(Color32To16($708090));
  NamedColors['SlateGrey']            :=  Ptr(Color32To16($708090));
  NamedColors['Snow']                 :=  Ptr(Color32To16($FFFAFA));
  NamedColors['SpringGreen']          :=  Ptr(Color32To16($00FF7F));
  NamedColors['SteelBlue']            :=  Ptr(Color32To16($4682B4));
  NamedColors['Tan']                  :=  Ptr(Color32To16($D2B48C));
  NamedColors['Teal']                 :=  Ptr(Color32To16($008080));
  NamedColors['Thistle']              :=  Ptr(Color32To16($D8BFD8));
  NamedColors['Tomato']               :=  Ptr(Color32To16($FF6347));
  NamedColors['Turquoise']            :=  Ptr(Color32To16($40E0D0));
  NamedColors['Violet']               :=  Ptr(Color32To16($EE82EE));
  NamedColors['Wheat']                :=  Ptr(Color32To16($F5DEB3));
  NamedColors['White']                :=  Ptr(Color32To16($FFFFFF));
  NamedColors['WhiteSmoke']           :=  Ptr(Color32To16($F5F5F5));
  NamedColors['Yellow']               :=  Ptr(Color32To16($FFFF00));
  NamedColors['YellowGreen']          :=  Ptr(Color32To16($9ACD32));
  NamedColors['r']                    :=  NamedColors['Red'];
  NamedColors['g']                    :=  NamedColors['Green'];
  NamedColors['b']                    :=  NamedColors['Blue'];
  NamedColors['y']                    :=  NamedColors['Yellow'];
  NamedColors['w']                    :=  NamedColors['White'];
  NamedColors['o']                    :=  NamedColors['Orange'];
  NamedColors['p']                    :=  NamedColors['Purple'];
  NamedColors['a']                    :=  NamedColors['Aqua'];
END; // .PROCEDURE NameStdColors

PROCEDURE NameColor (Color32: INTEGER; CONST Name: STRING);
BEGIN
  NamedColors[Name] :=  Ptr(Color32To16(Color32));
END; // .PROCEDURE NameColor

FUNCTION Hook_BeginParseText (Context: Core.PHookHandlerArgs): LONGBOOL; STDCALL;
CONST
  ERR_COLOR       = $000000;
  LINE_END_MARKER = #10;

VAR
{U} Buf:          POINTER;
    Txt:          STRING;
    TxtLen:       INTEGER;
    StartPos:     INTEGER;
    c:            CHAR;
    
    RealBlockLen: INTEGER;
    IsBlockEnd:   BOOLEAN;
    NumLineEnds:  INTEGER;
    
    ColorName:    STRING;
    Color16:      INTEGER;
    
BEGIN
  Buf :=  @TextBuffer[0];
  // * * * * * //
  TxtLen  :=  Context.ECX;
  SetLength(Txt, TxtLen);
  Utils.CopyMem(TxtLen, PCHAR(Context.EDX), POINTER(Txt));
  
  TextBlockInd                :=  0;
  TextBlocks[0].RealBlockLen  :=  TxtLen;
  TextBlocks[0].BlockLen      :=  TxtLen;
  TextBlocks[0].Color16       :=  DEF_COLOR;
  
  IF Math.InRange(TxtLen, 1, SIZEOF(TextBuffer) - 1) THEN BEGIN
    ColorStack.Clear;
    TextScanner.Connect(Txt, LINE_END_MARKER);
    
    SeekBlockInd  :=  0;
    SeekBlockPos  :=  0;
    SeekPos       :=  0;
    
    WHILE NOT TextScanner.EndOfText DO BEGIN
      StartPos    :=  TextScanner.Pos;
      NumLineEnds :=  0;
      IsBlockEnd  :=  FALSE;
      
      WHILE NOT IsBlockEnd AND TextScanner.GetCurrChar(c) DO BEGIN
        IF c = '{' THEN BEGIN
          IsBlockEnd  :=  TextScanner.GetCharAtRelPos(+1, c) AND (c = '~');
        END // .IF
        ELSE IF c = LINE_END_MARKER THEN BEGIN
          INC(NumLineEnds);
        END; // .ELSEIF
        
        IF NOT IsBlockEnd THEN BEGIN
          TextScanner.GotoNextChar;
        END; // .IF
      END; // .WHILE
      
      RealBlockLen  :=  TextScanner.Pos - StartPos;
      Utils.CopyMem(RealBlockLen, POINTER(@Txt[StartPos]), Buf);
      Buf                                   :=  Utils.PtrOfs(Buf, RealBlockLen);
      TextBlocks[TextBlockInd].RealBlockLen :=  RealBlockLen;
      TextBlocks[TextBlockInd].BlockLen     :=  RealBlockLen - NumLineEnds;
      
      IF
        NOT TextScanner.EndOfText   AND
        TextScanner.GotoRelPos(+2)  AND
        TextScanner.ReadTokenTillDelim(['}'], ColorName)
      THEN BEGIN
        INC(TextBlockInd);
        TextBlocks[TextBlockInd].RealBlockLen :=  0;
        TextBlocks[TextBlockInd].BlockLen     :=  0;
        
        IF ColorName = '' THEN BEGIN
          CASE ColorStack.Count OF
            0:  TextBlocks[TextBlockInd].Color16  :=  DEF_COLOR;
            1:  BEGIN
                  ColorStack.Pop;
                  TextBlocks[TextBlockInd].Color16  :=  DEF_COLOR;
                END;
          ELSE
            ColorStack.Pop;
            TextBlocks[TextBlockInd].Color16  :=  INTEGER(ColorStack.Top);
          END; // .SWITCH
        END // .IF
        ELSE BEGIN
          Color16 :=  0;
          
          IF NamedColors.GetExistingValue(ColorName, POINTER(Color16)) THEN BEGIN
            TextBlocks[TextBlockInd].Color16  :=  Color16;
          END // .IF
          ELSE IF SysUtils.TryStrToInt('$' + ColorName, Color16) THEN BEGIN
            Color16                           :=  Color32To16(Color16);
            TextBlocks[TextBlockInd].Color16  :=  Color16;
          END // .ELSEIF
          ELSE BEGIN
            TextBlocks[TextBlockInd].Color16  :=  ERR_COLOR;
          END; // .ELSE
          
          ColorStack.Add(Ptr(Color16));
        END; // .ELSE
        
        TextScanner.GotoNextChar;
      END; // .IF
    END; // .WHILE
  END; // .IF
  
  CurrBlockPos                  :=  -1;
  TextBlockInd                  :=  0;
  Context.ECX                   :=  INTEGER(Buf) - INTEGER(@TextBuffer[0]);
  TextBuffer[Context.ECX]       :=  #0;
  Context.EDX                   :=  INTEGER(@TextBuffer[0]);
  PINTEGER(Context.EBP - $14)^  :=  Context.ECX;
  PINTEGER(Context.EBP + $8)^   :=  Context.EDX;
  
  // Overwritten Code
  IF (PINTEGER(Context.EBP + $24)^ AND 4) = 0 THEN BEGIN
    Context.RetAddr :=  Ptr($4B52B2);
  END // .IF
  ELSE BEGIN
    Context.RetAddr :=  Ptr($4B525B);
  END; // .ELSE
  
  RESULT  :=  NOT Core.EXEC_DEF_CODE;
END; // .FUNCTION Hook_BeginParseText

FUNCTION Hook_GetCharColor (Context: Core.PHookHandlerArgs): LONGBOOL; STDCALL;
BEGIN
  RESULT  :=  TextBlocks[TextBlockInd].Color16 = DEF_COLOR;
  
  IF NOT RESULT THEN BEGIN
    Context.EAX :=  TextBlocks[TextBlockInd].Color16;
  END; // .IF
END; // .FUNCTION Hook_GetCharColor

FUNCTION Hook_HandleTags (Context: Core.PHookHandlerArgs): LONGBOOL; STDCALL;
VAR
  c:  CHAR;

BEGIN
  c                           :=  PCharByte(Context.EDX)^;
  PCharByte(Context.EBP - 4)^ :=  c;
  Context.RetAddr             :=  Ptr($4B50BA);
  INC(CurrBlockPos);
  
  WHILE CurrBlockPos = TextBlocks[TextBlockInd].BlockLen DO BEGIN
    CurrBlockPos  :=  0;
    INC(TextBlockInd);
  END; // .WHILE
  
  IF (TextBlocks[TextBlockInd].Color16 = DEF_COLOR) AND (c IN ['{', '}']) THEN BEGIN
    PBOOLEAN(Context.EBP + $24)^  :=  c = '{';
    Context.RetAddr               :=  Ptr($4B5190);
  END; // .IF
  
  RESULT  :=  NOT Core.EXEC_DEF_CODE;
END; // .FUNCTION Hook_HandleTags

FUNCTION Hook_ExcludeSpaceChar (Context: Core.PHookHandlerArgs): LONGBOOL; STDCALL;
VAR
  EndPos:           INTEGER;
  BlockFinishDist:  INTEGER;

BEGIN
  EndPos  :=  Context.ESI;
  
  WHILE SeekPos < EndPos DO BEGIN
    BlockFinishDist :=  TextBlocks[SeekBlockInd].RealBlockLen - SeekBlockPos;
    
    IF EndPos < (SeekPos + BlockFinishDist) THEN BEGIN
      SeekBlockPos  :=  SeekBlockPos + (EndPos - SeekPos);
      SeekPos       :=  EndPos;
    END // .IF
    ELSE BEGIN
      SeekPos       :=  SeekPos + BlockFinishDist;
      SeekBlockPos  :=  0;
      INC(SeekBlockInd);
    END; // .ELSE
  END; // .WHILE
  
  DEC(TextBlocks[SeekBlockInd].BlockLen);
  DEC(TextBlocks[SeekBlockInd].RealBlockLen);
  
  RESULT  :=  Core.EXEC_DEF_CODE;
END; // .FUNCTION Hook_ExcludeSpaceChar

FUNCTION Hook_SetupColorMode (Context: Core.PHookHandlerArgs): LONGBOOL; STDCALL;
BEGIN
  IF TextColorMode^ = TEXTMODE_15BITS THEN BEGIN
    Color32To16 :=  Color32To15Func;
  END // .IF
  ELSE IF TextColorMode^ = TEXTMODE_16BITS THEN BEGIN
    Color32To16 :=  Color32To16Func;
  END // .ELSEIF
  ELSE BEGIN
    {!} ASSERT(FALSE);
  END; // .ELSE
  
  NameStdColors;
  GameExt.FireEvent('OnAfterCreateWindow', GameExt.NO_EVENT_DATA, 0);
  
  RESULT  :=  Core.EXEC_DEF_CODE;
END; // .FUNCTION Hook_SetupColorMode

PROCEDURE OnAfterWoG (Event: GameExt.PEvent); STDCALL;
BEGIN
  Core.Hook(@Hook_BeginParseText, Core.HOOKTYPE_BRIDGE, 6, Ptr($4B5255));
  Core.Hook(@Hook_GetCharColor, Core.HOOKTYPE_BRIDGE, 8, Ptr($4B4F74));
  Core.Hook(@Hook_HandleTags, Core.HOOKTYPE_BRIDGE, 7, Ptr($4B509B));
  Core.Hook(@Hook_ExcludeSpaceChar, Core.HOOKTYPE_BRIDGE, 6, Ptr($4B5463));
  Core.Hook(@Hook_SetupColorMode, Core.HOOKTYPE_BRIDGE, 5, Ptr($4F8226));
END; // .PROCEDURE OnAfterWoG

BEGIN
  NamedColors :=  AssocArrays.NewSimpleAssocArr(Crypto.AnsiCRC32, SysUtils.AnsiLowerCase);
  ColorStack  :=  Lists.NewSimpleList;
  TextScanner :=  TextScan.TTextScanner.Create;
  GameExt.RegisterHandler(OnAfterWoG, 'OnAfterWoG');
END.
