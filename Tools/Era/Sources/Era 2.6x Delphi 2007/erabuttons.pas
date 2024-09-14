unit EraButtons;
{
DESCRIPTION:  Adds custom buttons support using modified Buttons plugin by MoP 
AUTHOR:       Alexander Shostak (aka Berserker aka EtherniDee aka BerSoft)
}

(***)  interface  (***)
uses
  Windows, SysUtils, Crypto, StrLib, Files, AssocArrays, DlgMes,
  Core, GameExt;

const
  BUTTONS_PATH  = 'Data\Buttons';
  
  NUM_BUTTON_COLUMNS  = 10;
  
  (* Columns *)
  COL_TYPE      = 0;
  COL_NAME      = 1;
  COL_DEF       = 2;
  COL_X         = 3;
  COL_Y         = 4;
  COL_WIDTH     = 5;
  COL_HEIGHT    = 6;
  COL_LONGHINT  = 7;
  COL_SHORTHINT = 8;
  COL_HOTKEY    = 9;
  
  (* Button screen *)
  TYPENAME_ADVMAP = 'advmap';
  TYPENAME_TOWN   = 'town';
  TYPENAME_HERO   = 'hero';
  TYPENAME_HEROES = 'heroes';
  TYPENAME_BATTLE = 'battle';
  TYPENAME_DUMMY  = 'dummy';  // Button is not shown
  
  TYPE_ADVMAP = '0';
  TYPE_TOWN   = '1';
  TYPE_HERO   = '2';
  TYPE_HEROES = '3';
  TYPE_BATTLE = '4';
  TYPE_DUMMY  = '9';
  

function  GetButtonID (const ButtonName: string): integer; stdcall;
  
  
(***) implementation (***)


const
  BUTTONS_DLL_NAME  = 'buttons.dll';


type
  TButtonsTable = array of StrLib.TArrayOfStr;
  
  
var
{O} ButtonNames:  AssocArrays.TAssocArray {OF INTEGER};

  hButtons: integer;
  
  ExtButtonsTable:  PPOINTER;
  ExtNumButtons:    PINTEGER;
  
  ButtonsTable: TButtonsTable;
  ButtonID:     integer = 400;
  NumButtons:   integer;


procedure LoadButtons;
var
{O} Locator:      Files.TFileLocator;
{O} ItemInfo:     Files.TFileItemInfo;
    FileName:     string;
    FileContents: string;
    Lines:        StrLib.TArrayOfStr;
    Line:         StrLib.TArrayOfStr;
    NumLines:     integer;
    ButtonName:   string;
    i:            integer;
    y:            integer;
   
begin
  Locator   :=  Files.TFileLocator.Create;
  ItemInfo  :=  nil;
  // * * * * * //
  Locator.DirPath :=  BUTTONS_PATH;
  Locator.InitSearch('*.btn');
  
  while Locator.NotEnd do begin
    FileName  :=  SysUtils.AnsiLowerCase(Locator.GetNextItem(Files.TItemInfo(ItemInfo)));
    
    if
      not ItemInfo.IsDir                            and
      (SysUtils.ExtractFileExt(FileName) = '.btn')  and
      ItemInfo.HasKnownSize                         and
      (ItemInfo.FileSize > 0)
    then begin
      {!} Assert(Files.ReadFileContents(BUTTONS_PATH + '\' + FileName, FileContents));
      Lines     :=  StrLib.Explode(SysUtils.Trim(FileContents), #13#10);
      NumLines  :=  Length(Lines);
      
      for i := 0 to NumLines - 1 do begin
        Line  :=  StrLib.Explode(SysUtils.Trim(Lines[i]), ';');
        
        if Length(Line) < NUM_BUTTON_COLUMNS then begin
          DlgMes.Msg
          (
            'Invalid number of columns (' + SysUtils.IntToStr(Length(Line)) +
            ') on line ' + SysUtils.IntToStr(i + 1) +
            ' in file "' + FileName + '".'#13#10 +
            'Expected ' + SysUtils.IntToStr(NUM_BUTTON_COLUMNS) + ' columns'
          );
        end // .if
        else begin
          Line[COL_TYPE]  :=  SysUtils.AnsiLowerCase(Line[COL_TYPE]);
        
          for y := 0 to NUM_BUTTON_COLUMNS - 1 do begin
            if Line[y] = '' then begin
              Line[y] :=  #0;
            end; // .if
          end; // .for
          
          if Line[COL_TYPE] = TYPENAME_ADVMAP then begin
            Line[COL_TYPE]  :=  TYPE_ADVMAP;
          end // .if
          else if Line[COL_TYPE] = TYPENAME_TOWN then begin
            Line[COL_TYPE]  :=  TYPE_TOWN;
          end // .ELSEIF
          else if Line[COL_TYPE] = TYPENAME_HERO then begin
            Line[COL_TYPE]  :=  TYPE_HERO;
          end // .ELSEIF
          else if Line[COL_TYPE] = TYPENAME_HEROES then begin
            Line[COL_TYPE]  :=  TYPE_HEROES;
          end // .ELSEIF
          else if Line[COL_TYPE] = TYPENAME_BATTLE then begin
            Line[COL_TYPE]  :=  TYPE_BATTLE;
          end // .ELSEIF
          else if Line[COL_TYPE] = TYPENAME_DUMMY then begin
            Line[COL_TYPE]  :=  TYPE_DUMMY;
          end // .ELSEIF
          else begin
            {!} Assert(false);
          end; // .else
          
          ButtonName  :=  Line[COL_NAME];
          
          if ButtonNames[ButtonName] <> nil then begin
            DlgMes.Msg
            (
              'Duplicate button name ("' + ButtonName + '") on line ' + SysUtils.IntToStr(i + 1) +
              ' in file "' + FileName + '"'
            );
          end // .if
          else begin
            ButtonNames[ButtonName] :=  Ptr(ButtonID);
            Line[COL_NAME]          :=  SysUtils.IntToStr(ButtonID);
            Inc(ButtonID);
            
            SetLength(ButtonsTable, NumButtons + 1);
            ButtonsTable[NumButtons]  :=  Line;
            Inc(NumButtons);
          end; // .else
        end; // .else
      end; // .for
    end; // .if
    
    SysUtils.FreeAndNil(ItemInfo);
  end; // .while
  
  Locator.FinitSearch;
  
  ExtButtonsTable^  :=  pointer(ButtonsTable);
  ExtNumButtons^    :=  NumButtons;
  // * * * * * //
  SysUtils.FreeAndNil(Locator);
end; // .procedure LoadButtons 

function GetButtonID (const ButtonName: string): integer; stdcall;
begin
  result  :=  integer(ButtonNames[ButtonName]);
  
  if result = 0 then begin
    result  :=  -1;
  end; // .if
end; // .function GetButtonID

procedure OnAfterWoG (Event: PEvent); stdcall;
begin
  (* Connect to Buttons.dll *)
  hButtons  :=  Windows.LoadLibrary(BUTTONS_DLL_NAME);
  {!} Assert(hButtons <> 0);
  ExtButtonsTable :=  GetProcAddress(hButtons, 'ButtonsTable');
  ExtNumButtons   :=  GetProcAddress(hButtons, 'NumButtons');
  {!} Assert(ExtButtonsTable <> nil);
  {!} Assert(ExtNumButtons <> nil);
  
  LoadButtons;
end; // .procedure OnAfterWoG

begin
  NumButtons  :=  0;
  ButtonNames :=  AssocArrays.NewSimpleAssocArr(Crypto.AnsiCRC32, SysUtils.AnsiLowerCase);

  GameExt.RegisterHandler(OnAfterWoG, 'OnAfterWoG');
end.
