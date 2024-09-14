UNIT Lang;
{
DESCRIPTION:  Language system implementation allows to dinamically change language of the whole program
AUTHOR:       Alexander Shostak (aka Berserker aka EtherniDee aka BerSoft)
}

(*
Any unit which uses language system is called Client.
Writing strings directly in code is a bad idea when internationalization is required.
SomeForm.Title  :=  'Hello world!'; // BAD
The idea is to be able to write
SomeForm.Title  :=  Lng[MainFormLng.Title];
Lng is a pointer to array of strings. Strings are accessed via named constants. {UnitName}Lng is a language unit.
At unit initialization phase Client registers at Lang unit. Function Lang.SetLanguage loops through client list and tries to
find language data for clients.
Language data hierarchy:
  -) Binary string (either Unicode or Ansi)
  -) Array of binary strings
  -) Language unit - array of arrays of binary strings
  -) Language package - array of language units
Sources of language data:
  -) Generated and compiled with main project pascal language units. {UnitName}Lng.pas. Example: UtilsLng.pas
  -) Resource package built in exe. {ResPackName}. Example: Language.lpk
  -) File array of binary strings. {ClientName}.{wide | ansi}.{language name}. Example: Utils.ansi.eng
  -) File unit. {ClientName}.{wide | ansi}.lun. Example: Utils.wide.lun
  -) File package. {FilePackName}. Example: Language.lpk

Unit usage.
  -) Client unit begin..end block: RegisterClient(...)
  -) LoadFilePack, LoadResPack (optional)
  -) SetLanguage(...)
  -) ResetLanguage (optional)
  -) UnloadFilePack (optional)
*)

(***)  INTERFACE  (***)
USES Windows, SysUtils, Classes, Math, WinWrappers, Log, Utils, Files, CLang, CBinString, CLngStrArr, CLngUnit, CLngPack;

CONST
  (* Lang names *)
  RUS = 'rus';
  ENG = 'eng';
  
  (* Unit type *)
  IS_UNICODE  = TRUE;
  IS_ANSI     = FALSE;
  
  MAX_NUMSTRINGS  = HIGH(INTEGER) DIV SIZEOF(AnsiString);


TYPE
  PClient = ^TClient;
  TClient = RECORD
              Name:         STRING;
              LangName:     STRING;
              DefLangName:  STRING;
              Unicode:      BOOLEAN;
              NumStrings:   INTEGER;
    (* UO *)  LngVar:       PPOINTER; // Pointer to client's Lng variable which is pointer to array of strings
    (* U *)   DefStrArr:    POINTER;  // Pointer to client's default array of language strings
  END; // .RECORD TClient


VAR
  AllowLoadFromFiles: BOOLEAN = TRUE;
  LangDir:            STRING  = '.';
  FilePackName:       STRING  = 'Language.lpk';
  ResPackName:        STRING  = 'LngPack';


FUNCTION  GetLanguage: STRING;
FUNCTION  IsClientRegistered (CONST ClientName: STRING): BOOLEAN;
FUNCTION  GetClientsNum: INTEGER;
FUNCTION  GetClientList: (* O *) Classes.TStringList;
FUNCTION  GetClientLang (CONST ClientName: STRING): STRING;
PROCEDURE RegisterClient
(
        ClientName:   STRING;
  CONST DefLangName:  STRING;
        Unicode:      BOOLEAN;
        NumStrings:   INTEGER;
        LngVar:       POINTER;  // Pointer to client's Lng variable which is pointer to array of strings
        DefStrArr:    POINTER   // Pointer to client's default array of language strings
);
PROCEDURE UnloadFilePack;
FUNCTION  LoadFilePack: BOOLEAN;
FUNCTION  LoadResPack: BOOLEAN;
PROCEDURE ResetLanguage;
PROCEDURE SetLanguage (CONST NewLanguage: STRING);
  
  
(***)  IMPLEMENTATION  (***)


VAR
(* O *) ClientList:     Classes.TStringList;
(* U *) ResPack:        CLngPack.PLngPack;
(* O *) ResPackReader:  CLngPack.TLngPackReader;
(* O *) FilePack:       CLngPack.PLngPack;
(* O *) FilePackReader: CLngPack.TLngPackReader;
        Language:       STRING;


FUNCTION GetLanguage: STRING;
BEGIN
  RESULT  :=  Language;
END; // .FUNCTION GetLanguage

FUNCTION FindClient (CONST ClientName: STRING; OUT Client: PClient): BOOLEAN;
VAR
  ClientInd: INTEGER;

BEGIN
  {!} ASSERT(Client = NIL);
  ClientInd :=  ClientList.IndexOf(ClientName);
  RESULT    :=  ClientInd <> -1;
  IF RESULT THEN BEGIN
    Client  :=  POINTER(ClientList.Objects[ClientInd]);
  END; // .IF
END; // .FUNCTION FindClient

FUNCTION IsClientRegistered (CONST ClientName: STRING): BOOLEAN;
BEGIN
  RESULT  :=  ClientList.IndexOf(ClientName) <> -1;
END; // .FUNCTION IsClientRegistered

FUNCTION GetClientsNum: INTEGER;
BEGIN
  RESULT  :=  ClientList.Count;
END; // .FUNCTION GetClientsNum

FUNCTION GetClientList: (* O *) Classes.TStringList;
VAR
  i:  INTEGER;

BEGIN
  RESULT                :=  Classes.TStringList.Create;
  RESULT.CaseSensitive  :=  TRUE;
  RESULT.Sorted         :=  TRUE;
  RESULT.Duplicates     :=  Classes.dupError;
  FOR i:=0 TO ClientList.Count - 1 DO BEGIN
    RESULT.Add(ClientList[i]);
  END; // .FOR
END; // .FUNCTION GetClientList

FUNCTION GetClientLang (CONST ClientName: STRING): STRING;
BEGIN
  {!} ASSERT(IsClientRegistered(ClientName));
  RESULT  :=  PClient(ClientList.Objects[ClientList.IndexOf(ClientName)]).LangName;
END; // .FUNCTION GetClientLang

PROCEDURE RegisterClient
(
        ClientName:   STRING;
  CONST DefLangName:  STRING;
        Unicode:      BOOLEAN;
        NumStrings:   INTEGER;
        LngVar:       POINTER;
        DefStrArr:    POINTER
);
VAR
(* O *) Client: PClient;
  
BEGIN
  ClientName  :=  SysUtils.AnsiLowerCase(ClientName);
  {!} ASSERT(CLang.IsValidClientName(ClientName));
  {!} ASSERT(NOT IsClientRegistered(ClientName));
  {!} ASSERT(CLang.IsValidLangName(DefLangName));
  {!} ASSERT(Math.InRange(NumStrings, 1, MAX_NUMSTRINGS));
  {!} ASSERT(LngVar <> NIL);
  {!} ASSERT(DefStrArr <> NIL);
  Client  :=  NIL;
  // * * * * * //
  NEW(Client);
  Client.Name         :=  ClientName;
  Client.LangName     :=  DefLangName;
  Client.DefLangName  :=  DefLangName;
  Client.Unicode      :=  Unicode;
  Client.NumStrings   :=  NumStrings;
  Client.LngVar       :=  LngVar;
  Client.DefStrArr    :=  DefStrArr;
  ClientList.AddObject(ClientName, POINTER(Client)); Client:=NIL;
END; // .PROCEDURE RegisterClient

PROCEDURE ResetClientLang (Client: PClient);
VAR
(* On *)  ArrOfStr: PEndlessAnsiStrArr;
          i:        INTEGER;

BEGIN
  {!} ASSERT(Client <> NIL);
  ArrOfStr  :=  NIL;
  // * * * * * //
  IF Client.LangName <> Client.DefLangName THEN BEGIN
    ArrOfStr  :=  Client.LngVar^; Client.LngVar^  :=  NIL;
    FOR i:=0 TO Client.NumStrings - 1 DO BEGIN
      ArrOfStr[i] :=  '';
    END; // .FOR
    FreeMem(ArrOfStr); ArrOfStr :=  NIL;
    Client.LngVar^  :=  Client.DefStrArr;
  END; // .IF
END; // .PROCEDURE ResetClientLang

PROCEDURE UnloadFilePack;
BEGIN
  FilePackReader.Disconnect;
  FreeMem(FilePack); FilePack := NIL;
END; // .PROCEDURE UnloadFilePack

FUNCTION LoadFilePack: BOOLEAN;
VAR
(* O *) FileObj:      Files.TFile;
        FilePackPath: STRING;
        FilePackSize: INTEGER;
        Error:        STRING;

BEGIN
  FileObj :=  Files.TFile.Create;
  RESULT  :=  FALSE;
  // * * * * * //
  UnloadFilePack;
  IF AllowLoadFromFiles THEN BEGIN
    FilePackPath  :=  LangDir + '\' + FilePackName;
    IF SysUtils.FileExists(FilePackPath) THEN BEGIN
      RESULT  :=
        FileObj.Open(LangDir + '\' + FilePackName, Files.MODE_READ) AND
        FileObj.ReadAllToBuf(POINTER(FilePack), FilePackSize);
      IF NOT RESULT THEN BEGIN
        Log.Write('LanguageSystem', 'LoadFilePack', 'Cannot load language pack "' + FilePackPath + '"');
      END; // .IF
    END; // .IF
    IF RESULT THEN BEGIN
      FilePackReader.Connect(FilePack, FilePackSize);
      RESULT  :=  FilePackReader.Validate(Error);
      IF NOT RESULT THEN BEGIN
        Log.Write('LanguageSystem', 'LoadFilePack', 'Validation of language pack "' + FilePackPath + '" failed.'#13#10'Error: ' + Error);
        UnloadFilePack;
      END; // .IF
    END; // .IF
  END; // .IF
  // * * * * * //
  SysUtils.FreeAndNil(FileObj);
END; // .FUNCTION LoadFilePack

FUNCTION LoadResPack: BOOLEAN;
VAR
  hResource:    INTEGER;
  hMem:         INTEGER;
  ResPackSize:  INTEGER;
  Error:        STRING;
  
BEGIN
  RESULT  :=
    ResPackReader.Connected AND
    WinWrappers.FindResource(SysInit.HInstance, ResPackName, Windows.RT_RCDATA, hResource) AND
    WinWrappers.LoadResource(SysInit.HInstance, hResource, hMem) AND
    WinWrappers.SizeOfResource(hResource, System.MainInstance, ResPackSize);
  IF RESULT THEN BEGIN
    ResPackReader.Connect(ResPack, ResPackSize);
    RESULT  :=  ResPackReader.Validate(Error);
    IF NOT RESULT THEN BEGIN
      Log.Write('LanguageSystem', 'LoadResPack', 'Validation of language pack "' + ResPackName + '" failed.'#13#10'Error: ' + Error);
      ResPackReader.Disconnect;
      ResPack :=  NIL;        
    END; // .IF
  END; // .IF
END; // .FUNCTION LoadResPack

PROCEDURE SetClientLngStrArr (Client: PClient; LngStrArrReader: CLngStrArr.TLngStrArrReader);
VAR
(* O *) ArrOfStr:         PEndlessAnsiStrArr;
(* O *) BinStringReader:  CBinString.TBinStringReader;
        i:                INTEGER;

BEGIN
  {!} ASSERT(Client <> NIL);
  {!} ASSERT(LngStrArrReader <> NIL);
  ArrOfStr        :=  NIL;
  BinStringReader :=  NIL;
  // * * * * * //
  ResetClientLang(Client);
  GetMem(ArrOfStr, Client.NumStrings * 4); FillChar(ArrOfStr^, Client.NumStrings * 4, #0);
  LngStrArrReader.SeekBinString(0);
  i :=  0;
  WHILE LngStrArrReader.ReadBinString(BinStringReader) DO BEGIN
    IF Client.Unicode THEN BEGIN
      ArrOfStr[i] :=  BinStringReader.GetWideString;
    END // .IF
    ELSE BEGIN
      ArrOfStr[i] :=  BinStringReader.GetAnsiString;
    END; // .ELSE
    INC(i);
  END; // .WHILE
  Client.LangName :=  LngStrArrReader.LangName;
  Client.LngVar^  :=  ArrOfStr; ArrOfStr  :=  NIL;
END; // .PROCEDURE SetClientLngStrArr

FUNCTION LoadClientLangFromResPack (Client: PClient; CONST NewLanguage: STRING): BOOLEAN;
VAR
(* On *)  LngUnitReader:    CLngUnit.TLngUnitReader;
(* On *)  LngStrArrReader:  CLngStrArr.TLngStrArrReader;

BEGIN
  {!} ASSERT(Client <> NIL);
  {!} ASSERT(CLang.IsValidLangName(NewLanguage));
  LngUnitReader   :=  NIL;
  LngStrArrReader :=  NIL;
  // * * * * * //
  RESULT  :=
    ResPackReader.Connected AND
    ResPackReader.FindLngUnit(Client.Name, Client.Unicode, LngUnitReader) AND
    LngUnitReader.FindLngStrArr(NewLanguage, LngStrArrReader);
  IF RESULT THEN BEGIN
    SetClientLngStrArr(Client, LngStrArrReader);
  END; // .IF
  // * * * * * //
  SysUtils.FreeAndNil(LngStrArrReader);
  SysUtils.FreeAndNil(LngUnitReader);
END; // .FUNCTION LoadClientLangFromResPack

FUNCTION LoadClientLangFromFilePack (Client: PClient; CONST NewLanguage: STRING): BOOLEAN;
VAR
(* On *)  LngUnitReader:    CLngUnit.TLngUnitReader;
(* On *)  LngStrArrReader:  CLngStrArr.TLngStrArrReader;

BEGIN
  {!} ASSERT(Client <> NIL);
  {!} ASSERT(CLang.IsValidLangName(NewLanguage));
  LngUnitReader   :=  NIL;
  LngStrArrReader :=  NIL;
  // * * * * * //
  RESULT  :=
    FilePackReader.Connected AND
    FilePackReader.FindLngUnit(Client.Name, Client.Unicode, LngUnitReader) AND
    LngUnitReader.FindLngStrArr(NewLanguage, LngStrArrReader);
  IF RESULT THEN BEGIN
    SetClientLngStrArr(Client, LngStrArrReader);
  END; // .IF
  // * * * * * //
  SysUtils.FreeAndNil(LngStrArrReader);
  SysUtils.FreeAndNil(LngUnitReader);
END; // .FUNCTION LoadClientLangFromFilePack

FUNCTION LoadClientLangFromFileUnit (Client: PClient; CONST NewLanguage: STRING): BOOLEAN;
VAR
(* O  *)  FileObj:          Files.TFile;
(* On *)  LngUnit:          CLngUnit.PLngUnit;
(* On *)  LngUnitReader:    CLngUnit.TLngUnitReader;
(* On *)  LngStrArrReader:  CLngStrArr.TLngStrArrReader;
          FileUnitSize:     INTEGER;
          FileUnitPath:     STRING;
          Error:            STRING;

BEGIN
  {!} ASSERT(Client <> NIL);
  {!} ASSERT(CLang.IsValidLangName(NewLanguage));
  FileObj         :=  Files.TFile.Create;
  LngUnit         :=  NIL;
  LngUnitReader   :=  NIL;
  LngStrArrReader :=  NIL;
  RESULT          :=  FALSE;
  // * * * * * //
  FileUnitPath  :=  LangDir + '\' + Client.Name + '.' + CLang.GetEncodingPrefix(Client.Unicode) +'.lun';
  IF AllowLoadFromFiles AND SysUtils.FileExists(FileUnitPath) THEN BEGIN
    RESULT  :=
      FileObj.Open(FileUnitPath, Files.MODE_READ) AND
      FileObj.ReadAllToBuf(POINTER(LngUnit), FileUnitSize);
    IF NOT RESULT THEN BEGIN
      Log.Write('LanguageSystem', 'LoadClientLangFromFileUnit', 'Cannot load language unit "' + FileUnitPath + '"');
    END // .IF
    ELSE BEGIN
      LngUnitReader :=  CLngUnit.TLngUnitReader.Create;
      LngUnitReader.Connect(LngUnit, FileUnitSize);
      RESULT  :=  LngUnitReader.Validate(Error);
      IF NOT RESULT THEN BEGIN
        Log.Write('LanguageSystem', 'LoadClientLangFromFileUnit', 'Validation of language unit "' + FileUnitPath + '" failed.'#13#10'Error: ' + Error);
      END; // .IF
    END; // .ELSE
    IF RESULT THEN BEGIN
      RESULT  :=  LngUnitReader.FindLngStrArr(NewLanguage, LngStrArrReader);
      IF RESULT THEN BEGIN
        SetClientLngStrArr(Client, LngStrArrReader);
      END; // .IF
    END; // .IF
  END; // .IF
  // * * * * * //
  SysUtils.FreeAndNil(FileObj);
  FreeMem(LngUnit); LngUnit :=  NIL;
  SysUtils.FreeAndNil(LngStrArrReader);
  SysUtils.FreeAndNil(LngUnitReader);
END; // .FUNCTION LoadClientLangFromFileUnit

FUNCTION LoadClientLangFromFileStrArr (Client: PClient; CONST NewLanguage: STRING): BOOLEAN;
VAR
(* O  *)  FileObj:          Files.TFile;
(* On *)  LngStrArr:        CLngStrArr.PLngStrArr;
(* On *)  LngStrArrReader:  CLngStrArr.TLngStrArrReader;
          FileStrArrSize:   INTEGER;
          FileStrArrPath:   STRING;
          Error:            STRING;

BEGIN
  {!} ASSERT(Client <> NIL);
  {!} ASSERT(CLang.IsValidLangName(NewLanguage));
  FileObj         :=  Files.TFile.Create;
  LngStrArr       :=  NIL;
  LngStrArrReader :=  NIL;
  RESULT          :=  FALSE;
  // * * * * * //
  FileStrArrPath  :=  LangDir + '\' + Client.Name + '.' + CLang.GetEncodingPrefix(Client.Unicode) + '.' + NewLanguage;
  IF AllowLoadFromFiles AND SysUtils.FileExists(FileStrArrPath) THEN BEGIN
    RESULT  :=
      FileObj.Open(FileStrArrPath, Files.MODE_READ) AND
      FileObj.ReadAllToBuf(POINTER(LngStrArr), FileStrArrSize);
    IF NOT RESULT THEN BEGIN
      Log.Write('LanguageSystem', 'LoadClientLangFromFileStrArr', 'Cannot load language strings array "' + FileStrArrPath + '"');
    END // .IF
    ELSE BEGIN
      LngStrArrReader :=  CLngStrArr.TLngStrArrReader.Create;
      LngStrArrReader.Connect(LngStrArr, FileStrArrSize);
      RESULT  :=  LngStrArrReader.Validate(Error);
      IF NOT RESULT THEN BEGIN
        Log.Write('LanguageSystem', 'LoadClientLangFromFileStrArr', 'Validation of language strings array "' + FileStrArrPath + '" failed.'#13#10'Error: ' + Error);
      END // .IF
      ELSE BEGIN
        SetClientLngStrArr(Client, LngStrArrReader);
      END; // .ELSE
    END; // .ELSE
  END; // .IF
  // * * * * * //
  SysUtils.FreeAndNil(FileObj);
  FreeMem(LngStrArr); LngStrArr :=  NIL;
  SysUtils.FreeAndNil(LngStrArrReader);
END; // .FUNCTION LoadClientLangFromFileStrArr

FUNCTION SetClientLang (Client: PClient; CONST NewLanguage: STRING): BOOLEAN;
BEGIN
  {!} ASSERT(Client <> NIL);
  {!} ASSERT(CLang.IsValidLangName(NewLanguage));
  RESULT  :=  NewLanguage = Client.LangName;
  IF NOT RESULT THEN BEGIN
    ResetClientLang(Client);
  END; // .IF
  RESULT  :=
    (NewLanguage = Client.LangName) OR
    LoadClientLangFromResPack     (Client, NewLanguage) OR
    LoadClientLangFromFilePack    (Client, NewLanguage) OR
    LoadClientLangFromFileUnit    (Client, NewLanguage) OR
    LoadClientLangFromFileStrArr  (Client, NewLanguage);
END; // .FUNCTION SetClientLang

PROCEDURE ResetLanguage;
VAR
  i:  INTEGER;

BEGIN
  Language  :=  '';
  FOR i:=0 TO ClientList.Count - 1 DO BEGIN
    ResetClientLang(POINTER(ClientList.Objects[i]));
  END; // .FOR
END; // .PROCEDURE ResetLanguage

PROCEDURE SetLanguage (CONST NewLanguage: STRING);
VAR
  i:  INTEGER;

BEGIN
  {!} ASSERT(CLang.IsValidLangName(NewLanguage));
  FOR i:=0 TO ClientList.Count - 1 DO BEGIN
    SetClientLang(POINTER(ClientList.Objects[i]), NewLanguage)
  END; // .FOR
END; // .PROCEDURE SetLanguage

BEGIN
  ClientList                :=  Classes.TStringList.Create;
  ClientList.Sorted         :=  TRUE;
  ClientList.Duplicates     :=  Classes.dupError;
  ClientList.CaseSensitive  :=  FALSE;
  ResPackReader             :=  CLngPack.TLngPackReader.Create;
  FilePackReader            :=  CLngPack.TLngPackReader.Create;
END.
