unit RSPopupMenu;

{ *********************************************************************** }
{                                                                         }
{ RSPak                                    Copyright (c) Rozhenko Sergey  }
{ http://sites.google.com/site/sergroj/                                   }
{ sergroj@mail.ru                                                         }
{                                                                         }
{ This file is a subject to any one of these licenses at your choice:     }
{ BSD License, MIT License, Apache License, Mozilla Public License.       }
{                                                                         }
{ *********************************************************************** }
{$I RSPak.inc}

interface

uses
  Classes, Menus;

type
  TRSPopupMenu = class(TPopupMenu)
  private
    FOnAfterPopup: TNotifyEvent;
  protected
    FOwnItems: TMenuItem;
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure SetItems(v:TMenuItem); virtual;
    procedure Popup(X, Y: Integer); override;
  published
    property OnAfterPopup: TNotifyEvent read FOnAfterPopup write FOnAfterPopup;
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('RSPak', [TRSPopupMenu]);
end;

{
********************************** TRSPopupMenu ***********************************
}

constructor TRSPopupMenu.Create(AOwner: TComponent);
begin
  inherited;
  FOwnItems:=Items;
end;

destructor TRSPopupMenu.Destroy;
begin
  SetItems(nil);
  inherited;
end;

procedure TRSPopupMenu.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  inherited;
  if (Operation=opRemove) and (AComponent=Items) then
    TMenuItem((@Items)^):=FOwnItems;
end;

procedure TRSPopupMenu.Popup(X, Y: Integer);
begin
  inherited;
  if Assigned(FOnAfterPopup) then  FOnAfterPopup(self);
end;

procedure TRSPopupMenu.SetItems(v: TMenuItem);
begin
  if v=Items then exit;

  if Items<>FOwnItems then
    Items.RemoveFreeNotification(self);

  if (v<>nil) and (v<>FOwnItems) then
  begin
    TMenuItem((@Items)^):=v;
    v.FreeNotification(self);

    // Можно еще менять свойства менюшки на те, что в Items...

  end else
    TMenuItem((@Items)^):=FOwnItems;
end;

end.
