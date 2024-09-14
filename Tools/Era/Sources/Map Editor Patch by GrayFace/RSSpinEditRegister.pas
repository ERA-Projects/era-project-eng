unit RSSpinEditRegister;

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
  SysUtils, Classes, RSSpinEdit, DesignIntf, DesignEditors;//, DesignMenus, VCLEditors;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('RSPak', [TRSSpinEdit]);
  RegisterComponents('RSPak', [TRSSpinButton]);

  RegisterPropertyEditor(TComponent.ClassInfo, TRSSpinEdit, 'Button', TClassProperty);
  RegisterPropertyEditor(TComponent.ClassInfo, TRSSpinButton, 'UpButton', TClassProperty);
  RegisterPropertyEditor(TComponent.ClassInfo, TRSSpinButton, 'DownButton', TClassProperty);
end;

end.
 