unit Rainbow;
{
DESCRIPTION:  Adds multi-color support to all Heroes texts
AUTHOR:       Alexander Shostak (aka Berserker aka EtherniDee aka BerSoft)
}

(***)  interface  (***)
uses
  Math, SysUtils, Utils, Crypto, Lists, AssocArrays, TextScan,
  Core, GameExt;

const
  TEXTMODE_15BITS = $3E0;
  TEXTMODE_16BITS = $7E0;

  DEF_COLOR = -1;
  
  TextColorMode: PWORD = Ptr($694DB0);


type
  TColor32To16Func  = function (Color32: integer): integer;

  TTextBlock = record
    BlockLen: integer;
    Color16: integer;
  end; // .record TTextBlock
  
  
var
  (* Chinese loader support: {~color}...{~} => {...} *)
  ChineseLoaderOpt: boolean;
  ChineseHandler:   pointer;


procedure NameColor (Color32: integer; const Name: string); stdcall;

(* Chinese only: temporal *)
function ChineseGetCharColor: integer; stdcall;
procedure ChineseGotoNextChar; stdcall;


(***) implementation (***)


exports
  ChineseGetCharColor,
  ChineseGotoNextChar;


var
{O} NamedColors:  {U} AssocArrays.TAssocArray {OF Color16: INTEGER};
{O} ColorStack:   {U} Lists.TList {OF Color16: INTEGER};
{O} TextScanner:  TextScan.TTextScanner;
    Color32To16:  TColor32To16Func;
    
    TextBlocks:   array [0..16 * 1024 - 1] of TTextBlock;
    TextBlockInd: integer;
    TextBuffer:   array [0..1024 * 1024 - 1] of char;
    CurrBlockPos: integer;


function Color32To15Func (Color32: integer): integer;
begin
  result  :=
    ((Color32 and $0000F8) shr 3) or
    ((Color32 and $00F800) shr 6) or
    ((Color32 and $F80000) shr 9);
end; // .function Color32To15Func

function Color32To16Func (Color32: integer): integer;
begin
  result  :=
    ((Color32 and $0000F8) shr 3) or
    ((Color32 and $00FC00) shr 5) or
    ((Color32 and $F80000) shr 8);
end; // .function Color32To16

procedure NameStdColors;
begin
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
  NamedColors['r']                    :=  Ptr(Color32To16($F2223E));
  NamedColors['g']                    :=  Ptr(Color32To16($FFFE794));
  NamedColors['b']                    :=  NamedColors['Blue'];
  NamedColors['y']                    :=  NamedColors['Yellow'];
  NamedColors['w']                    :=  NamedColors['White'];
  NamedColors['o']                    :=  NamedColors['Orange'];
  NamedColors['p']                    :=  NamedColors['Purple'];
  NamedColors['a']                    :=  NamedColors['Aqua'];
end; // .procedure NameStdColors

procedure NameColor (Color32: integer; const Name: string);
begin
  NamedColors[Name] :=  Ptr(Color32To16(Color32));
end; // .procedure NameColor

function IsChineseLoaderPresent (out ChineseHandler: pointer): boolean;
begin
  result  :=  PBYTE($4B5202)^ = $E9;
  
  if result then begin
    ChineseHandler  :=  Ptr(PINTEGER($4B5203)^ + integer($4B5207));
  end; // .if
end; // .function IsChineseLoaderPresent

function Hook_BeginParseText (Context: Core.PHookContext): LONGBOOL; stdcall;
const
  ERR_COLOR       = $000000;
  LINE_END_MARKER = #10;

var
{U} Buf:          pchar;
    Txt:          string;
    TxtLen:       integer;
    StartPos:     integer;
    c:            char;
    
    BlockLen: integer;
    IsBlockEnd:   boolean;
    NumSpaceChars:  integer;
    
    ColorName:    string;
    Color16:      integer;
    
  procedure ConvertTextToChinese;
  var
    i:  integer;
  
  begin
    i :=  1;

    while i <= TxtLen do begin
      while (i <= TxtLen) and (Txt[i] <> '{') do begin
        Buf^  :=  Txt[i];
        Inc(Buf);
        Inc(i);
      end; // .while
      
      if i <= TxtLen then begin
        Inc(i);
        
        if (i <= TxtLen) and (Txt[i] = '~') then begin
          Inc(i);
          
          if (i <= TxtLen) and (Txt[i] = '}') then begin
            Buf^  :=  '}';
            Inc(Buf);
            Inc(i);
          end // .if
          else begin
            Buf^  :=  '{';
            Inc(Buf);
            
            while (i <= TxtLen) and (Txt[i] <> '}') do begin
              Inc(i);
            end; // .while
            
            Inc(i);
          end; // .else
        end // .if
        else begin
          Buf^  :=  '{';
          Inc(Buf);
        end; // .else
      end; // .if
    end; // .while
    
    Buf^  :=  #0;
    Inc(Buf);
  end; // .procedure ConvertTextToChinese
    
begin
  Buf :=  @TextBuffer[0];
  // * * * * * //
  TxtLen  :=  Context.ECX;
  SetLength(Txt, TxtLen);
  Utils.CopyMem(TxtLen, pchar(Context.EDX), pointer(Txt));
  
  TextBlockInd            := 0;
  TextBlocks[0].BlockLen  := TxtLen;
  TextBlocks[0].Color16   := DEF_COLOR;
  
  if Math.InRange(TxtLen, 1, sizeof(TextBuffer) - 1) then begin
    ColorStack.Clear;
    TextScanner.Connect(Txt, LINE_END_MARKER);
    
    while not TextScanner.EndOfText do begin
      StartPos      :=  TextScanner.Pos;
      NumSpaceChars :=  0;
      IsBlockEnd    :=  false;
      
      while not IsBlockEnd and TextScanner.GetCurrChar(c) do begin
        if c = '{' then begin
          IsBlockEnd  :=  TextScanner.GetCharAtRelPos(+1, c) and (c = '~');
        end // .if
        else if ORD(c) <= 32 then begin
          Inc(NumSpaceChars);
        end // .ELSEIF
        else if ChineseLoaderOpt and (ORD(c) > 160) then begin
          Inc(NumSpaceChars);
          TextScanner.GotoNextChar;
        end; // .ELSEIF
        
        if not IsBlockEnd then begin
          TextScanner.GotoNextChar;
        end; // .if
      end; // .while
      
      BlockLen := TextScanner.Pos - StartPos;
      Utils.CopyMem(BlockLen, pointer(@Txt[StartPos]), Buf);
      Buf := Utils.PtrOfs(Buf, BlockLen);
      TextBlocks[TextBlockInd].BlockLen := BlockLen - NumSpaceChars;
      
      if
        not TextScanner.EndOfText   and
        TextScanner.GotoRelPos(+2)  and
        TextScanner.ReadTokenTillDelim(['}'], ColorName)
      then begin
        Inc(TextBlockInd);
        TextBlocks[TextBlockInd].BlockLen := 0;
        
        if ColorName = '' then begin
          case ColorStack.Count of
            0:  TextBlocks[TextBlockInd].Color16  :=  DEF_COLOR;
            1:  begin
                  ColorStack.Pop;
                  TextBlocks[TextBlockInd].Color16  :=  DEF_COLOR;
                end;
          else
            ColorStack.Pop;
            TextBlocks[TextBlockInd].Color16  :=  integer(ColorStack.Top);
          end; // .switch
        end // .if
        else begin
          Color16 :=  0;
          
          if NamedColors.GetExistingValue(ColorName, pointer(Color16)) then begin
            TextBlocks[TextBlockInd].Color16  :=  Color16;
          end // .if
          else if SysUtils.TryStrToInt('$' + ColorName, Color16) then begin
            Color16                           :=  Color32To16(Color16);
            TextBlocks[TextBlockInd].Color16  :=  Color16;
          end // .ELSEIF
          else begin
            TextBlocks[TextBlockInd].Color16  :=  ERR_COLOR;
          end; // .else
          
          ColorStack.Add(Ptr(Color16));
        end; // .else
        
        TextScanner.GotoNextChar;
      end; // .if
    end; // .while
  end; // .if
  
  CurrBlockPos                  :=  -1;
  TextBlockInd                  :=  0;
  Context.ECX                   :=  integer(Buf) - integer(@TextBuffer[0]);
  TextBuffer[Context.ECX]       :=  #0;
  Context.EDX                   :=  integer(@TextBuffer[0]);
  PINTEGER(Context.EBP - $14)^  :=  Context.ECX;
  PINTEGER(Context.EBP + $8)^   :=  Context.EDX;
  
  if ChineseLoaderOpt then begin
    //ConvertTextToChinese;
    PINTEGER(Context.EBP - $14)^  :=  integer(Buf) - integer(@TextBuffer[0]);
    PINTEGER(Context.EBP + $8)^   :=  integer(@TextBuffer[0]);
    Context.ECX                   :=  Context.EBX;
    Context.RetAddr               :=  ChineseHandler;
  end // .if
  else begin
    // Overwritten Code
    if (PINTEGER(Context.EBP + $24)^ and 4) = 0 then begin
      Context.RetAddr :=  Ptr($4B52B2);
    end // .if
    else begin
      Context.RetAddr :=  Ptr($4B525B);
    end; // .else
  end; // .else
  
  result  :=  not Core.EXEC_DEF_CODE;
end; // .function Hook_BeginParseText

function Hook_GetCharColor (Context: Core.PHookContext): LONGBOOL; stdcall;
begin
  result  :=  TextBlocks[TextBlockInd].Color16 = DEF_COLOR;
  
  if not result then begin
    Context.EAX :=  TextBlocks[TextBlockInd].Color16;
  end; // .if
end; // .function Hook_GetCharColor

function Hook_HandleTags (Context: Core.PHookContext): LONGBOOL; stdcall;
var
  c:  char;

begin
  c                           :=  PCharByte(Context.EDX)^;
  PCharByte(Context.EBP - 4)^ :=  c;
  Context.RetAddr             :=  Ptr($4B50BA);
  
  if ORD(c) > 32 then begin
    Inc(CurrBlockPos);
  end; // .if
  
  while CurrBlockPos = TextBlocks[TextBlockInd].BlockLen do begin
    CurrBlockPos  :=  0;
    Inc(TextBlockInd);
  end; // .while
  
  if (TextBlocks[TextBlockInd].Color16 = DEF_COLOR) and (c in ['{', '}']) then begin
    PBOOLEAN(Context.EBP + $24)^  :=  c = '{';
    Context.RetAddr               :=  Ptr($4B5190);
  end; // .if
  
  result  :=  not Core.EXEC_DEF_CODE;
end; // .function Hook_HandleTags

function ChineseGetCharColor: integer; stdcall;
begin
  result := TextBlocks[TextBlockInd].Color16;
end; // .function ChineseGetCharColor

procedure ChineseGotoNextChar; stdcall;
begin
  Inc(CurrBlockPos);
  
  while CurrBlockPos = TextBlocks[TextBlockInd].BlockLen do begin
    CurrBlockPos  :=  0;
    Inc(TextBlockInd);
  end; // .while
end; // .procedure ChineseGotoNextChar

function Hook_SetupColorMode (Context: Core.PHookContext): LONGBOOL; stdcall;
begin
  if TextColorMode^ = TEXTMODE_15BITS then begin
    Color32To16 :=  Color32To15Func;
    {!} Assert(false);// !FIXME
  end // .if
  else if TextColorMode^ = TEXTMODE_16BITS then begin
    Color32To16 :=  Color32To16Func;
  end // .ELSEIF
  else begin
    {!} Assert(false);
  end; // .else
  
  NameStdColors;
  GameExt.FireEvent('OnAfterCreateWindow', GameExt.NO_EVENT_DATA, 0);
  
  result  :=  Core.EXEC_DEF_CODE;
end; // .function Hook_SetupColorMode

function Hook_DrawPic (Context: PHookContext): LONGBOOL; stdcall;
const
  Name: string = 'smalres.def';
  
var
  Def:  PBYTE;
  Pcx8: PBYTE;
  Pcx16:  PBYTE;
  x, y: integer;
  Width, Height:  integer;
  REbp:  integer;

begin
  REbp :=  Context.EBP;

  asm
    MOV ECX, Name
    MOV EAX, $55C9C0
    CALL EAX
    MOV Def, EAX
    
    MOV ECX, REbp
    MOV EAX, [ECX+12]
    MOV Pcx16, EAX
    MOV EAX, [ECX+16]
    MOV Width, EAX
    MOV EAX, [ECX+20]
    MOV Height, EAX
    MOV EAX, [ECX+24]
    MOV x, EAX
    MOV EAX, [ECX+28]
    MOV y, EAX
    
    PUSH 0
    MOV EDX, [$6992D0]
    MOV EDX, [EDX+$40]
    MOV EAX, [EDX+$2C]
    PUSH EAX // scan_line_size
    MOV EAX, [EDX+$28]
    PUSH EAX // height
    MOV EAX, [EDX+$24]
    PUSH EAX // width
    PUSH Height
    PUSH Width
    MOV EAX, [EDX+$30]
    PUSH EAX // buf
    PUSH 18
    PUSH 20
    PUSH 0
    PUSH 0
    PUSH 2
    MOV ECX, Def
    MOV EAX, $47B820
    CALL EAX
  end; // .asm
  
  Context.RetAddr :=  Ptr($4B4FA5);
  result  :=  not Core.EXEC_DEF_CODE;
end; // .function Hook_DrawPic

function Hook_RegisterDefFrame (Context: Core.PHookContext): LONGBOOL; stdcall;
begin
  if TextColorMode^ = TEXTMODE_15BITS then begin
    Color32To16 :=  Color32To15Func;
    {!} Assert(false);// !FIXME
  end // .if
  else if TextColorMode^ = TEXTMODE_16BITS then begin
    Color32To16 :=  Color32To16Func;
  end // .ELSEIF
  else begin
    {!} Assert(false);
  end; // .else
  
  NameStdColors;
  GameExt.FireEvent('OnAfterCreateWindow', GameExt.NO_EVENT_DATA, 0);
  
  result  :=  Core.EXEC_DEF_CODE;
end; // .function Hook_RegisterDefFrame

procedure OnAfterWoG (Event: GameExt.PEvent); stdcall;
begin
  ChineseLoaderOpt  :=  IsChineseLoaderPresent(ChineseHandler);
  
  if ChineseLoaderOpt then begin
    (* Remove Chinese loader hook *)
    PWORD($4B5202)^     :=  word($840F);  // JE
    PINTEGER($4B5204)^  :=  $02E7;        // 4B54EF
  end // .if
  else begin
    Core.Hook(@Hook_HandleTags, Core.HOOKTYPE_BRIDGE, 7, Ptr($4B509B));
    //Core.ApiHook(@Hook_DrawPic, Core.HOOKTYPE_BRIDGE, Ptr($4B4F03));
  end; // .else 

  Core.Hook(@Hook_GetCharColor, Core.HOOKTYPE_BRIDGE, 8, Ptr($4B4F74));
  Core.Hook(@Hook_BeginParseText, Core.HOOKTYPE_BRIDGE, 6, Ptr($4B5255));
  Core.Hook(@Hook_SetupColorMode, Core.HOOKTYPE_BRIDGE, 5, Ptr($4F8226));
end; // .procedure OnAfterWoG

begin
  NamedColors :=  AssocArrays.NewSimpleAssocArr(Crypto.AnsiCRC32, SysUtils.AnsiLowerCase);
  ColorStack  :=  Lists.NewSimpleList;
  TextScanner :=  TextScan.TTextScanner.Create;
  GameExt.RegisterHandler(OnAfterWoG, 'OnAfterWoG');
end.
