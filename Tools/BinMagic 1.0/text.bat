@echo off
BinMagic.exe ^
	Cmd=ConvertPatch ^
	SourcePatch=%1 ^
	ResultPatch="%~n1.txt" ^
	PatchFor=Memory ^
	Optimize