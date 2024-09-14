unit RSDialogs;

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

uses Dialogs, Forms, Classes, CommDlg, Windows, Messages, RSCommon;

type
  TRSOpenSaveDialog = class;

  TRSOpenSaveDialogBeforeShow = procedure(Sender: TRSOpenSaveDialog;
     var DialogData: TOpenFilename) of object;
  TRSWndProcEvent = RSCommon.TRSWndProcEvent;

  TRSOpenSaveDialog = class(TOpenDialog)
  private
    FSaveDialog: Boolean;
    FOnBeforeShow: TRSOpenSaveDialogBeforeShow;
    FOnWndProc: TRSWndProcEvent;
    FObjectInstance: Pointer;
    procedure MainWndProc(var Message: TMessage);
  protected
    function TaskModalDialog(DialogFunc: Pointer; var DialogData): Bool; override;
    procedure TranslateWndProc(var Msg: TMessage);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function Execute: Boolean; override;
  published
    property SaveDialog: Boolean read FSaveDialog write FSaveDialog default false;
    property OnBeforeShow: TRSOpenSaveDialogBeforeShow read FOnBeforeShow write FOnBeforeShow;
    property OnWndProc: TRSWndProcEvent read FOnWndProc write FOnWndProc;
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('RSPak', [TRSOpenSaveDialog]);
end;

constructor TRSOpenSaveDialog.Create(AOwner: TComponent);
begin
  inherited;
  FObjectInstance:= MakeObjectInstance(MainWndProc);
end;

destructor TRSOpenSaveDialog.Destroy;
begin
  FreeObjectInstance(FObjectInstance);
  inherited;
end;

procedure GetSaveFileNamePreviewA; external 'MSVFW32.dll';
procedure GetOpenFileNamePreviewA; external 'MSVFW32.dll';

function TRSOpenSaveDialog.Execute: Boolean;
begin
  if SaveDialog then
    Result:= DoExecute(@GetSaveFileNamePreviewA)
  else
    Result:= DoExecute(@GetOpenFileNamePreviewA);
{
  if SaveDialog then
    Result:= DoExecute(@GetSaveFileName)
  else
    Result:= DoExecute(@GetOpenFileName);
}
end;

procedure TRSOpenSaveDialog.MainWndProc(var Message: TMessage);
begin
  try
    TranslateWndProc(Message);
  except
    Application.HandleException(Self);
  end;
end;

function TRSOpenSaveDialog.TaskModalDialog(DialogFunc: Pointer;
  var DialogData): Bool;
begin
  TOpenFilename(DialogData).lpfnHook:= FObjectInstance;
  if Assigned(FOnBeforeShow) then
    FOnBeforeShow(self, TOpenFilename(DialogData));
  Result:= inherited TaskModalDialog(DialogFunc, DialogData);
end;

procedure TRSOpenSaveDialog.TranslateWndProc(var Msg: TMessage);
var b:Boolean;
begin
  if Assigned(FOnWndProc) then
  begin
    b:=false;
    FOnWndProc(Self, Msg, b, WndProc);
    if b then exit;
  end;
  WndProc(Msg);
end;

end.
