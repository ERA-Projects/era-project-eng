UNIT TypeWrappers;
{
DESCRIPTION:  Wrappers for primitive types into objects suitable for storing in containers
AUTHOR:       Alexander Shostak (aka Berserker aka EtherniDee aka BerSoft)
}

(***)  INTERFACE  (***)
USES Utils;

TYPE
  TString = CLASS (Utils.TCloneable)
    Value:  STRING;
    
    CONSTRUCTOR Create (CONST Value: STRING);
    PROCEDURE Assign (Source: Utils.TCloneable); OVERRIDE;
  END; // .CLASS TString


(***) IMPLEMENTATION (***)


CONSTRUCTOR TString.Create (CONST Value: STRING);
BEGIN
  Self.Value  :=  Value;
END; // .CONSTRUCTOR TString.Create

PROCEDURE TString.Assign (Source: Utils.TCloneable);
BEGIN
  Self.Value  :=  (Source AS TString).Value;
END; // .PROCEDURE TString.Assign

END.
