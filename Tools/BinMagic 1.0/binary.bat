@echo off
BinMagic.exe ^
	Cmd=ConvertPatch ^
	SourcePatch=%1 ^
	ResultPatch="%~n1.bin" ^
	PatchFor=Memory ^
	Optimize