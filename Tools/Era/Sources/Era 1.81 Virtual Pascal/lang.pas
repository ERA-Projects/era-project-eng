UNIT Lang;
{!INFO
MODULENAME = 'Language'
VERSION = '1.0'
AUTHOR = 'Berserker'
DESCRIPTION = 'Языковой модуль для Эры на случай необходимости локализации'
}

(***)  INTERFACE  (***)
USES Win;


TYPE
  TStrings = (
    Str_FatalError_Init_Title, // Заголовок сообщения о фатальной ошибке во время инициализации Эры
    Str_Error_DinPatch_CannotLoadBinFile, // Эры не может загрузить бинарный файл из папки с плагинами
    Str_Error_DinPatch_Exception, // Возникло исключение во время патчинга
    Str_Error_EraHtml_Overbuf, // Слишком большой объём текста для того, чтобы EraHtml смог его обработать
    Str_Error_EraHtml_Err, // Произошла ошибка во время парсинга текста EraHtml
    Str_Error_Service_Params, // Произошла ошибка во время парсинга текста параметров к функции Service
    Str_Error_Service_G, // Ошибка в параметрах к Service.Goto
    Str_Error_Service_C, // Ошибка в параметрах к Service.Call
    Str_Error_Service_R, // Ошибка в параметрах к Service.Return
    Str_Error_Service_Q, // Ошибка в параметрах к Service.Quit
    Str_Error_Service_E, // Ошибка в параметрах к Service.Exec
    Str_Error_Service_A, // Ошибка в параметрах к Service.GetProc(A)ddress
    Str_Error_Service_L, // Ошибка в параметрах к Service.(L)oadLibrary
    Str_Error_Service_X // Ошибка в параметрах к Service.X (Manage Event Params)
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
