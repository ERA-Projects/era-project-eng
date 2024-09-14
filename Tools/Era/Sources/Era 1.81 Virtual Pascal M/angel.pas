LIBRARY Angel;
USES Windows, SysUtils, Main, UExports, General;

EXPORTS
	UExports.SaveGame,
	UExports.SetOption,
	UExports.ResetEra,
	General.ErmMessage,
	General.ErmMessageEx,
	General.HookCode,
	General.KillProcess,
	General.FatalError,
	General.HexColor2Int,
	General.GenerateCustomErmEvent,
	General.EventParams,
	General.SaveEventParams,
	General.RestoreEventParams,
	Windows.CopyMemory,
	Main.InitEra;


BEGIN
END.
