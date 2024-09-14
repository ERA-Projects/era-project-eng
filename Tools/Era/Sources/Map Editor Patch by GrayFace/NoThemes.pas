unit NoThemes;

interface

uses UxTheme, Windows, SysUtils, Common;

procedure KillThemes;

implementation

procedure KillThemes;
const
   // Cancel loading UxTheme.dll
  PatchData : array[0..2] of byte = ($31, $C0, $C3);
begin
  DoPatch(@InitThemeLibrary, @PatchData, SizeOf(PatchData));
end;

end.
