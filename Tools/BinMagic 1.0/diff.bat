@echo off
BinMagic.exe ^
	Cmd=MakePatch ^
	OrigFile=%1 ^
	ModifiedFile=%2 ^
	ResultPatch=%3 ^
	PatchFor=Memory