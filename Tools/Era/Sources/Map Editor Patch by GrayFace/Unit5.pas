unit Unit5;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, RSQ, Unit4, Common, RSLang, Buttons, RSSpeedButton, StdCtrls;

type
  TForm5 = class(TForm)
    RSSpeedButton1: TRSSpeedButton;
    ButtonGround: TRSSpeedButton;
    ButtonObjects: TRSSpeedButton;
    Memo1: TMemo;
    LabelCopy1: TLabel;
    LabelCopy2: TLabel;
    LabelPaste: TLabel;
    Label1: TLabel;
    LabelCopyCaption: TLabel;
    LabelPasteCaption: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure RSSpeedButton1Click(Sender: TObject);
  private
    { Private declarations }
  public
    procedure Initialize;
    procedure UpdateMode;
  end;

var
  Form5: TForm5;

implementation

{$R *.dfm}

{ TForm5 }

procedure TForm5.FormCreate(Sender: TObject);
const
  w=16;
var
  b:TBitmap; h:int;
begin
  b:=TBitmap.Create;
  try
    b.Handle:= LoadBitmap($400000, ptr(314));
    h:= b.Height;
    with ButtonGround.Glyph, Canvas do
    begin
      Width:=w+2;
      Height:=h+2;
      CopyRect(Bounds(0, 0, w, h), b.Canvas, Bounds(0, 0, w, h));
    end;
    with ButtonObjects.Glyph, Canvas do
    begin
      Width:=w+2;
      Height:=h+2;
      CopyRect(Bounds(0, 0, w, h), b.Canvas, Bounds(w*8, 0, w, h));
    end;
  finally
    b.Free;
  end;

  Memo1.Height:= Height - Memo1.Top;
end;

procedure TForm5.Initialize;
begin
  Application.CreateForm(TForm5, Form5);
  self:= Form5;
  RSLanguage.AddSection('[CopyMap Bar]', self);
end;

procedure TForm5.RSSpeedButton1Click(Sender: TObject);
begin
  with Form4 do
  begin
    CopyMapMode:= cmmNone;
    ButtonCopyMap.Down:= false;
    ButtonPasteMap.Down:= false;
  end;
end;

procedure TForm5.UpdateMode;
begin
  ButtonGround.Visible:= (Form4.CopyMapMode = cmmPaste);
  ButtonObjects.Visible:= (Form4.CopyMapMode = cmmPaste);
  case Form4.CopyMapMode of
    cmmPaste:
    begin
      Label1.Caption:= LabelPasteCaption.Caption;
      Memo1.Text:= LabelPaste.Caption;
    end;

    cmmCopySq:
    begin
      Label1.Caption:= LabelCopyCaption.Caption;
      if Form4.CopyStartX < 0 then
        Memo1.Text:= LabelCopy1.Caption
      else
        Memo1.Text:= LabelCopy2.Caption;
    end;
  end;
end;

end.
