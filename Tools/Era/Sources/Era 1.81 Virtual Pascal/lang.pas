UNIT Lang;
{!INFO
MODULENAME = 'Language'
VERSION = '1.0'
AUTHOR = 'Berserker'
DESCRIPTION = '�������� ������ ��� ��� �� ������ ������������� �����������'
}

(***)  INTERFACE  (***)
USES Win;


TYPE
  TStrings = (
    Str_FatalError_Init_Title, // ��������� ��������� � ��������� ������ �� ����� ������������� ���
    Str_Error_DinPatch_CannotLoadBinFile, // ��� �� ����� ��������� �������� ���� �� ����� � ���������
    Str_Error_DinPatch_Exception, // �������� ���������� �� ����� ��������
    Str_Error_EraHtml_Overbuf, // ������� ������� ����� ������ ��� ����, ����� EraHtml ���� ��� ����������
    Str_Error_EraHtml_Err, // ��������� ������ �� ����� �������� ������ EraHtml
    Str_Error_Service_Params, // ��������� ������ �� ����� �������� ������ ���������� � ������� Service
    Str_Error_Service_G, // ������ � ���������� � Service.Goto
    Str_Error_Service_C, // ������ � ���������� � Service.Call
    Str_Error_Service_R, // ������ � ���������� � Service.Return
    Str_Error_Service_Q, // ������ � ���������� � Service.Quit
    Str_Error_Service_E, // ������ � ���������� � Service.Exec
    Str_Error_Service_A, // ������ � ���������� � Service.GetProc(A)ddress
    Str_Error_Service_L, // ������ � ���������� � Service.(L)oadLibrary
    Str_Error_Service_X // ������ � ���������� � Service.X (Manage Event Params)
    );
  
  TStr = ARRAY [TStrings] OF STRING; 
  
  
VAR
  Str: TStr = (
  'Era Initialization Fatal Error', // Str_FatalError_Init_Title
  'Cannot load bin file "', // Str_Error_DinPatch_CannotLoadBinFile
  'An exception was raised while patching game from bin file "', // Str_Error_DinPatch_Exception
  'Too big size of text to process via EraHtml. Terminating..."', // Str_Error_EraHtml_Overbuf
  'An error occured while parsing EraHtml text. Now you will see text contents and the game will terminate.', // Str_Error_EraHtml_Err
  'Era Service Error: Invalid parameters string in a call to !!SN. Context:', // Str_Error_Service_Params
  'Invalid parameters for !!SN:G command. Context:', // Str_Error_Service_G
  'Invalid parameters for !!SN:C command. Context:', // Str_Error_Service_C
  'Invalid parameters for !!SN:R command. Context:', // Str_Error_Service_R
  'Invalid parameters for !!SN:Q command. Context:', // Str_Error_Service_Q
  'Invalid parameters for !!SN:E command. Context:', // Str_Error_Service_E
  'Invalid parameters for !!SN:P command. Context:', // Str_Error_Service_A
  'Invalid parameters for !!SN:L command. Context:', // Str_Error_Service_L
  'Too many parameters for !!SN:X command. Context:' // Str_Error_Service_X
  ); // Str

  
(***)  IMPLEMENTATION  (***)


END.
