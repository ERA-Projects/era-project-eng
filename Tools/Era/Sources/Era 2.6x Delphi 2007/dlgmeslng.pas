unit DlgMesLng;
{
DESCRIPTION:  Language unit
AUTHOR:       Alexander Shostak (aka Berserker aka EtherniDee aka BerSoft)
}

(***)  interface   (***)

type
  TLangStrings =
  (
    STR_QUESTION
  ); // TLangStrings

  PLangStringsArr = ^TLangStringsArr;
  TLangStringsArr = array [TLangStrings] of string;


var
  Strs: TLangStringsArr =
  (
    // STR_QUESTION
    'Question'
  ); // Lng


(***) implementation (***)


end.
