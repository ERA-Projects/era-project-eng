unit Concur;
(* Author:      EtherniDee aka Berserker
   Desctiption: Support for concurrency *)

interface
uses Windows;

type
  TCritSection = record
   private
    fCritSection: Windows.TRTLCriticalSection;

   public
    procedure Init;
    procedure Enter;
    procedure Leave;
    procedure Delete;
  end; // .record TCritSection


implementation

procedure TCritSection.Init;
begin
  Windows.InitializeCriticalSection(fCritSection);
end; // .procedure TCritSection.Init

procedure TCritSection.Enter;
begin
  Windows.EnterCriticalSection(fCritSection);
end; // .procedure TCritSection.Enter

procedure TCritSection.Leave;
begin
  Windows.LeaveCriticalSection(fCritSection);
end; // .procedure TCritSection.Leave

procedure TCritSection.Delete;
begin
  Windows.DeleteCriticalSection(fCritSection);
end; // .procedure TCritSection.Delete

end.