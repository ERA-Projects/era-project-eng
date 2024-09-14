UNIT DlgMesLng;
{
DESCRIPTION:  Language unit
AUTHOR:       Alexander Shostak (aka Berserker aka EtherniDee aka BerSoft)
}

(***)  INTERFACE   (***)

TYPE
  TLangStrings =
  (
    STR_QUESTION
  ); // TLangStrings

  PLangStringsArr = ^TLangStringsArr;
  TLangStringsArr = ARRAY [TLangStrings] OF STRING;


VAR
  Strs: TLangStringsArr =
  (
    // STR_QUESTION
    'Question'
  ); // Lng


(***) IMPLEMENTATION (***)


END.
