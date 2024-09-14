LIBRARY Angel;
USES Win, Utils, Main, UExports;
{!INFO
MODULENAME = 'Angel 2B'
VERSION = '4'
AUTHOR = 'Berserker'
DESCRIPTION = 'Техническая DLL для Эры Демиургов'
}

EXPORTS
  UExports.SaveGame NAME 'SaveGame',
  UExports.SetOption NAME 'SetOption',
  UExports.ResetEra NAME 'ResetEra',
  General.ErmMessage NAME 'ErmMessage',
  General.ErmMessageEx NAME 'ErmMessageEx',
  General.HookCode NAME 'HookCode',
  General.KillProcess NAME 'KillProcess',
  General.FatalError NAME 'FatalError',
  General.HexColor2Int NAME 'HexColor2Int',
  General.GenerateCustomErmEvent NAME 'GenerateCustomErmEvent',
  General.EventParams NAME 'EventParams',
  Win.CopyMemory NAME 'CopyMemory';


BEGIN
  Main.InitEra;
END.
