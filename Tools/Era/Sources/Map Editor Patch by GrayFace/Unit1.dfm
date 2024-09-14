object Form1: TForm1
  Left = 192
  Top = 114
  HelpContext = 100
  BorderIcons = [biSystemMenu]
  BorderStyle = bsDialog
  Caption = 'Advanced Properties'
  ClientHeight = 405
  ClientWidth = 523
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  KeyPreview = True
  OldCreateOrder = False
  Scaled = False
  ShowHint = True
  OnClose = FormClose
  OnCreate = FormCreate
  OnHelp = FormHelp
  OnKeyDown = FormKeyDown
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object RSSpeedButton1: TRSSpeedButton
    Left = 194
    Top = 72
    Width = 23
    Height = 22
    Hint = 'Choose a picture from the lod file'
    HelpContext = 106
    OnClick = RSSpeedButton1Click
    OnContextPopup = RSSpeedButton1ContextPopup
  end
  object RSSpeedButton2: TRSSpeedButton
    Left = 218
    Top = 72
    Width = 23
    Height = 22
    Hint = 'Copy'
    HelpContext = 101
    OnClick = RSSpeedButton2Click
    OnContextPopup = RSSpeedButton1ContextPopup
  end
  object RSSpeedButton3: TRSSpeedButton
    Left = 242
    Top = 72
    Width = 23
    Height = 22
    Hint = 'Paste'
    HelpContext = 102
    OnClick = RSSpeedButton3Click
    OnContextPopup = RSSpeedButton1ContextPopup
  end
  object Image1: TImage
    Left = 272
    Top = 8
    Width = 32
    Height = 32
    HelpContext = 103
    OnClick = Image1Click
    OnContextPopup = RSSpeedButton1ContextPopup
    OnDblClick = Image1Click
  end
  object Image2: TImage
    Left = 272
    Top = 41
    Width = 32
    Height = 32
    HelpContext = 103
    OnClick = Image1Click
    OnContextPopup = RSSpeedButton1ContextPopup
    OnDblClick = Image1Click
  end
  object Image3: TImage
    Left = 272
    Top = 74
    Width = 32
    Height = 32
    HelpContext = 103
    OnClick = Image1Click
    OnContextPopup = RSSpeedButton1ContextPopup
    OnDblClick = Image1Click
  end
  object Image4: TImage
    Left = 272
    Top = 107
    Width = 32
    Height = 32
    HelpContext = 103
    OnClick = Image1Click
    OnContextPopup = RSSpeedButton1ContextPopup
    OnDblClick = Image1Click
  end
  object Image5: TImage
    Left = 272
    Top = 140
    Width = 32
    Height = 32
    HelpContext = 103
    OnClick = Image1Click
    OnContextPopup = RSSpeedButton1ContextPopup
    OnDblClick = Image1Click
  end
  object Image6: TImage
    Left = 272
    Top = 173
    Width = 32
    Height = 32
    HelpContext = 103
    OnClick = Image1Click
    OnContextPopup = RSSpeedButton1ContextPopup
    OnDblClick = Image1Click
  end
  object Image7: TImage
    Left = 272
    Top = 206
    Width = 32
    Height = 32
    HelpContext = 103
    OnClick = Image1Click
    OnContextPopup = RSSpeedButton1ContextPopup
    OnDblClick = Image1Click
  end
  object Image8: TImage
    Left = 272
    Top = 239
    Width = 32
    Height = 32
    HelpContext = 103
    OnClick = Image1Click
    OnContextPopup = RSSpeedButton1ContextPopup
    OnDblClick = Image1Click
  end
  object Image9: TImage
    Left = 272
    Top = 272
    Width = 32
    Height = 32
    HelpContext = 103
    OnClick = Image1Click
    OnContextPopup = RSSpeedButton1ContextPopup
    OnDblClick = Image1Click
  end
  object Label1: TLabel
    Left = 8
    Top = 11
    Width = 49
    Height = 13
    Alignment = taRightJustify
    AutoSize = False
    Caption = 'Type:'
  end
  object Label2: TLabel
    Left = 8
    Top = 43
    Width = 49
    Height = 13
    Alignment = taRightJustify
    AutoSize = False
    Caption = 'Subtype:'
  end
  object Label3: TLabel
    Left = 8
    Top = 75
    Width = 49
    Height = 13
    Alignment = taRightJustify
    AutoSize = False
    Caption = 'Picture:'
  end
  object Label13: TLabel
    Left = 271
    Top = 309
    Width = 34
    Height = 13
    HelpContext = 103
    Alignment = taCenter
    AutoSize = False
    Caption = 'All'
    OnContextPopup = RSSpeedButton1ContextPopup
  end
  object CheckNone: TImage
    Left = 288
    Top = 324
    Width = 17
    Height = 17
    Hint = 'Unselect All'
    HelpContext = 103
    Picture.Data = {
      07544269746D617072020000424D72020000000000001E010000280000001100
      000011000000010008000000000054010000C30E0000C30E00003A0000000000
      00000000000010107B007F7F7F001010840010108C0018188400101094001818
      9C001818A5001818B5002121A5002121BD001818C6001818DE001010E7001818
      E7001818EF002121D6002121DE002929D6002929DE003131DE003939DE002121
      E7002121EF002929EF003131EF003131F7003131FF003939F7003939FF004242
      CE004242D6004242DE004A4ADE004242E7004A4AEF004242FF004A4AF7004A4A
      FF005252E7005252F7005252FF005A5AFF006363FF006B6BFF007373FF007B7B
      FF008484FF008C8CFF009494FF009C9CFF00A5A5FF00ADADFF00BDBDFF00D6D6
      FF00DEDEFF00E3DFE00039390200003939393939393939393939390000003902
      0804000039393939393902000000390000000216110C06000039393939020101
      0300390000002B2C1D0E110700003939020407090A0A020000000202352A0E0D
      07000002050B0D17201F02000000393902022A0F0C0300030C0D1B2F2E023900
      00003939393902261309080C0D1A2F0202393900000039393939390223120D0D
      152802393939390000003939393902282618101B240000393939390000003939
      390220291E2C33312A21000039393900000039393902221B2B3702382D191100
      0039390000003939022C1E1C34023902361E0F110000390000003939022E272F
      3102393902332518171402000000393902303134023939393902022A1E1A0200
      0000393939023232023939393939390202023900000039393939023202393939
      393939393939390000003939393939023939393939393939393939000000}
    Transparent = True
    OnClick = CheckNoneClick
    OnContextPopup = RSSpeedButton1ContextPopup
    OnMouseDown = CheckAllMouseDown
    OnMouseUp = CheckAllMouseUp
  end
  object CheckAll: TImage
    Left = 271
    Top = 324
    Width = 17
    Height = 17
    Hint = 'Select All'
    HelpContext = 103
    Picture.Data = {
      07544269746D61700A020000424D0A02000000000000B6000000280000001100
      000011000000010008000000000054010000C30E0000C30E0000200000000000
      000000000000184A5A0010526300185A6B007F7F7F00217B9400218CA500298C
      A500299CB500299CBD0031A5BD0029ADCE0021BDDE0029BDDE0031B5D60031BD
      D60029BDE70039C6DE0029C6E70031C6E70039CEEF0052BDDE0042D6F7004AD6
      F70052DEFF005AE7FF0063E7FF006BF7FF007BFFFF0094FFFF009CFFFF00E3DF
      E0001F1F1F04001F1F1F1F1F1F1F1F1F1F1F1F0000001F1F1F0500001F1F1F1F
      1F1F1F1F1F1F1F0000001F1F04070500001F1F1F1F1F1F1F1F1F1F0000001F1F
      040A090300001F1F1F1F1F1F1F1F1F0000001F0415110D0B01001F1F1F1F1F1F
      1F1F1F0000001F041A1713130E00001F1F1F1F1F1F1F1F000000041B1C1D0419
      130F00001F1F1F1F1F1F1F000000041B1E041F0418100600001F1F1F1F1F1F00
      00001F04041F1F1F04161002001F1F1F1F1F1F0000001F1F1F1F1F1F1F041410
      00001F1F1F1F1F0000001F1F1F1F1F1F1F1F04130D00001F1F1F1F0000001F1F
      1F1F1F1F1F1F1F04120C00001F1F1F0000001F1F1F1F1F1F1F1F1F1F04100C00
      001F1F0000001F1F1F1F1F1F1F1F1F1F1F04100D00001F0000001F1F1F1F1F1F
      1F1F1F1F1F1F04121004000000001F1F1F1F1F1F1F1F1F1F1F1F1F0404120400
      00001F1F1F1F1F1F1F1F1F1F1F1F1F1F1F0404000000}
    Transparent = True
    OnClick = CheckAllClick
    OnContextPopup = RSSpeedButton1ContextPopup
    OnMouseDown = CheckAllMouseDown
    OnMouseUp = CheckAllMouseUp
  end
  object Label6: TLabel
    Tag = 2
    Left = 28
    Top = 306
    Width = 29
    Height = 13
    Caption = 'Empty'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
    Transparent = False
    OnClick = Image10Click
    OnContextPopup = Image10ContextPopup
    OnMouseUp = Image10MouseUp
  end
  object Image10: TImage
    Tag = 2
    Left = 8
    Top = 304
    Width = 17
    Height = 17
    OnClick = Image10Click
    OnContextPopup = Image10ContextPopup
    OnMouseUp = Image10MouseUp
  end
  object Image11: TImage
    Left = 77
    Top = 304
    Width = 17
    Height = 17
    OnClick = Image10Click
    OnContextPopup = Image10ContextPopup
    OnMouseUp = Image10MouseUp
  end
  object Label8: TLabel
    Left = 97
    Top = 306
    Width = 31
    Height = 13
    Caption = 'Object'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
    Transparent = False
    OnClick = Image10Click
    OnContextPopup = Image10ContextPopup
    OnMouseUp = Image10MouseUp
  end
  object Image12: TImage
    Tag = 1
    Left = 146
    Top = 304
    Width = 17
    Height = 17
    OnClick = Image10Click
    OnContextPopup = Image10ContextPopup
    OnMouseUp = Image10MouseUp
  end
  object Label9: TLabel
    Tag = 1
    Left = 166
    Top = 306
    Width = 25
    Height = 13
    Caption = 'Enter'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
    Transparent = False
    OnClick = Image10Click
    OnContextPopup = Image10ContextPopup
    OnMouseUp = Image10MouseUp
  end
  object Image15: TImage
    Left = 215
    Top = 304
    Width = 17
    Height = 17
  end
  object Label11: TLabel
    Left = 220
    Top = 306
    Width = 8
    Height = 13
    Caption = 'L'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
    Transparent = True
  end
  object Image16: TImage
    Left = 248
    Top = 304
    Width = 17
    Height = 17
  end
  object Label12: TLabel
    Left = 252
    Top = 306
    Width = 10
    Height = 13
    Caption = 'R'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
    Transparent = True
  end
  object Label4: TLabel
    Left = 7
    Top = 329
    Width = 138
    Height = 13
    Cursor = crHandPoint
    Alignment = taCenter
    AutoSize = False
    Caption = 'Standard Properties'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsUnderline]
    ParentFont = False
    OnClick = Label4Click
  end
  object Bevel1: TBevel
    Left = 312
    Top = 384
    Width = 18
    Height = 18
    Visible = False
  end
  object PaintBox1: TPaintBox
    Left = 8
    Top = 104
    Width = 256
    Height = 192
    OnMouseDown = PaintBox1MouseDown
    OnMouseMove = PaintBox1MouseMove
    OnMouseUp = PaintBox1MouseUp
    OnPaint = PaintBox1Paint
  end
  object Image13: TImage
    Left = 231
    Top = 304
    Width = 17
    Height = 17
  end
  object Label5: TLabel
    Left = 235
    Top = 306
    Width = 11
    Height = 13
    Caption = 'M'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
    Transparent = True
  end
  object ComboBox1: TRSComboBox
    Left = 64
    Top = 40
    Width = 201
    Height = 21
    ItemHeight = 0
    TabOrder = 0
  end
  object Edit2: TRSEdit
    Left = 64
    Top = 72
    Width = 129
    Height = 21
    TabOrder = 1
    OnChange = Edit2Change
  end
  object CheckBox1: TCheckBox
    Left = 152
    Top = 328
    Width = 112
    Height = 17
    HelpContext = 105
    Caption = 'A part of ground'
    TabOrder = 2
    OnContextPopup = RSSpeedButton1ContextPopup
  end
  object Button1: TButton
    Left = 40
    Top = 352
    Width = 72
    Height = 25
    Caption = 'OK'
    Default = True
    TabOrder = 3
    OnClick = Button1Click
  end
  object Button2: TButton
    Left = 120
    Top = 352
    Width = 72
    Height = 25
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 4
  end
  object Button3: TButton
    Left = 200
    Top = 352
    Width = 72
    Height = 25
    Caption = 'Help'
    TabOrder = 5
    OnClick = Button3Click
  end
  object ComboType: TRSComboBox
    Left = 64
    Top = 8
    Width = 201
    Height = 21
    HelpContext = 104
    Style = csDropDownList
    ItemHeight = 0
    TabOrder = 6
    OnChange = ComboTypeChange
    OnContextPopup = RSSpeedButton1ContextPopup
  end
end
