unit TypeWrappers;
{
DESCRIPTION:  Wrappers for primitive types into objects suitable for storing in containers
AUTHOR:       Alexander Shostak (aka Berserker aka EtherniDee aka BerSoft)
}

(***)  interface  (***)
uses Utils;

type
  TString = class (Utils.TCloneable)
    Value:  string;
    
    constructor Create (const Value: string);
    procedure Assign (Source: Utils.TCloneable); override;
  end; // .class TString

  TEventHandler = class (Utils.TCloneable)
    Handler:  Utils.TEventHandler;
    
    constructor Create (Handler: Utils.TEventHandler);
    procedure Assign (Source: Utils.TCloneable); override;
  end; // .class TEventHandler
  

(***) implementation (***)


constructor TString.Create (const Value: string);
begin
  Self.Value := Value;
end; // .constructor TString.Create

procedure TString.Assign (Source: Utils.TCloneable);
begin
  Self.Value := (Source AS TString).Value;
end; // .procedure TString.Assign

constructor TEventHandler.Create (Handler: Utils.TEventHandler);
begin
  Self.Handler := Handler;
end; // .constructor TEventHandler.Create

procedure TEventHandler.Assign (Source: Utils.TCloneable);
begin
  Self.Handler := (Source AS TEventHandler).Handler;
end; // .procedure TEventHandler.Assign

end.
