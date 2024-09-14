#pragma once
#include <windows.h>

namespace ErmVar
{
	typedef int _ws[200];
	typedef char _zs[512];
	int* var = (int*)0x277186A;			// var['f']..var['t']
	bool* flag = (bool*)0x91F2DF;		// flag[1]..flag[1000]
	int* v = (int*)0x887664;			// v[1]..v[10000]
	int& hero = *(int*)0x27F9988;		// current hero for w vars
	_ws* w = (_ws*)0xA4AB0C;			// w[hero][1]..w[hero][200]
	_zs* z = (_zs*)0x9271E8;			// z[1]..z[1000]
	_zs* zMinus = (_zs*)0xA46B28;		// zMinus[1]..zMinus[10]
	int* x = (int*)0x91DA34;			// x[1]..x[16]
	int* y = (int*)0xA48D7C;			// y[1]..y[100]
	int* yMinus = (int*)0xA46A2C;		// yMinus[1]..yMinus[100]
	float* e = (float*)0xA48F14;		// e[1]..e[100]
	float* eMinus = (float*)0x27F93B4;	// eMinus[1]..eMinus[100]
}

enum
{
	// wog erm return codes:
	RET_ERM_ERROR = 0,
	RET_ERM_SUCCESS,
};

typedef int (__cdecl *ErmInnerHandler)(char, int, void*, void*);
enum ErmArgPassType
{
	ERM_PASS_NOT_DEFINED = 0,
	ERM_PASS_VALUE,		// nothing
	ERM_PASS_GET,		// ?
	ERM_PASS_TEST_E,	// =
	ERM_PASS_TEST_NE,	// <>
	ERM_PASS_TEST_GE,	// >=
	ERM_PASS_TEST_LE,	// <=
	ERM_PASS_TEST_G,	// >
	ERM_PASS_TEST_L,	// <
	ERM_PASS_ADD,		// d
};

enum ArgumentVartype
{
	VARTYPE_IMMEDIATE_INT = 0,
	VARTYPE_IMMEDIATE_STRING,
};

struct ErmArgument
{
	ErmArgPassType passedAs;
	union // value ptr
	{
		int* integer;
		char* string;
		float* real;
	} value;
	char vartype; // see ArgumentVartype for additional values
	int number; // var number, immediate value or immediate string length
	//_Mes_ parsed; // argument as seen in ERM (+ context)
};

struct ErmCommand
{
	char name;
	int numArgs;
	ErmArgument args[16];
	int numReceiverArgs;
	ErmArgument receiverArgs[16]; // really don't need that much; reserved for later
};

typedef int (__stdcall *ErmHandler)(ErmCommand& cmd);
typedef int (__stdcall *TGenericErmHandler)(ErmHandler handler, char c, int num, void* todo, void* mes);
typedef int (__stdcall *TRegisterErmReceiver)(char name[2], ErmInnerHandler handler, int type);

TGenericErmHandler GenericErmHandler = 0;
TRegisterErmReceiver RegisterErmReceiver = 0;

void ConnectPandorasAPI()
{
	HINSTANCE papi = LoadLibrary("Pandora's API.era");
	GenericErmHandler = (TGenericErmHandler) GetProcAddress(papi, "_GenericErmHandler@20");
	RegisterErmReceiver = (TRegisterErmReceiver) GetProcAddress(papi, "_RegisterErmReceiver@12");
}

enum ArgPassAllowed // bit field
{
	ALLOWED_CHECK = 1,
	ALLOWED_GET,
	ALLOWED_CHECK_GET,
	ALLOWED_SET,
	ALLOWED_ALL = 7,
};

enum ArgTypeExpected // bit fiend
{
	EXPECTED_INTEGER = 1,
	EXPECTED_REAL = 2,
	EXPECTED_STRING = 4,
	EXPECTED_ANY = 7,
};

void ApplyArg(ErmArgument& arg, int& value)
{
	if (arg.vartype == 'e' || arg.vartype == 'z' || arg.vartype == VARTYPE_IMMEDIATE_STRING)
	{
		return;
	}
	switch (arg.passedAs)
	{
		case ERM_PASS_GET:
			*arg.value.integer = value;
			break;
		case ERM_PASS_VALUE:
			value = *arg.value.integer;
			break;
		case ERM_PASS_ADD:
			value += *arg.value.integer;
			break;
		case ERM_PASS_TEST_E:
			ErmVar::flag[1] = (value == *arg.value.integer);
			break;
		case ERM_PASS_TEST_NE:
			ErmVar::flag[1] = (value != *arg.value.integer);
			break;
		case ERM_PASS_TEST_GE:
			ErmVar::flag[1] = (value >= *arg.value.integer);
			break;
		case ERM_PASS_TEST_LE:
			ErmVar::flag[1] = (value <= *arg.value.integer);
			break;
		case ERM_PASS_TEST_G:
			ErmVar::flag[1] = (value > *arg.value.integer);
			break;
		case ERM_PASS_TEST_L:
			ErmVar::flag[1] = (value < *arg.value.integer);
			break;
	}
	return;
}

struct ErmArgumentFormat
{
	int numArgsExpected;
	struct
	{
		/*ArgPassAllowed*/int pass;
		/*ArgTypeExpected*/int type;
	} argsExpected[16];
};

bool CheckArgs(ErmCommand& cmd, ErmArgumentFormat format)
{
	bool result = true;
	if (cmd.numArgs == format.numArgsExpected)
	{
		for (int i = cmd.numArgs - 1; i >=0 && result; i--)
		{
			switch (cmd.args[i].passedAs)
			{
				case ERM_PASS_GET:
					result = (result && (format.argsExpected[i].pass | ALLOWED_GET));
					break;
				case ERM_PASS_ADD: // must have get and set
					result = (result && (format.argsExpected[i].pass | ALLOWED_GET));
				case ERM_PASS_VALUE:
					result = (result && (format.argsExpected[i].pass | ALLOWED_SET));
					break;
				case ERM_PASS_TEST_E:
				case ERM_PASS_TEST_NE:
				case ERM_PASS_TEST_GE:
				case ERM_PASS_TEST_LE:
				case ERM_PASS_TEST_G:
				case ERM_PASS_TEST_L:
					result = (result && (format.argsExpected[i].pass | ALLOWED_CHECK));
					break;
				default:
					result = false;
					break;
			}
			switch (cmd.args[i].vartype)
			{
				case VARTYPE_IMMEDIATE_STRING:
					result = (result && cmd.args[i].passedAs != ERM_PASS_GET);
				case 'z':
					result = (result && (format.argsExpected[i].type | EXPECTED_STRING));
					break;
				case 'e':
					result = (result && (format.argsExpected[i].type | EXPECTED_REAL));
					break;
				case VARTYPE_IMMEDIATE_INT:
					result = (result && cmd.args[i].passedAs != ERM_PASS_GET);
				default: // every other var is int
					result = (result && (format.argsExpected[i].type | EXPECTED_INTEGER));
					break;
			}
		}
	}
	else
	{
		result = false;
	}
	return result;
}

bool IsValidVar(char vartype, int number)
{
	if (number == 0)
	{
		return (vartype >= 'f' && vartype <= 't');
	}
	else
	{
		switch (vartype)
		{
			case 'e':
				return (number >= -100 && number <= 100);
			case 'v':
				return (number > 0 && number <= 10000);
			case 'w':
				return (number > 0 && number <= 200);
			case 'x':
				return (number > 0 && number <= 16);
			case 'y':
				return (number >= -100 && number <= 100);
			case 'z':
				return (number >= -10 && number <= 1000);
			default:
				return false;
		}
	}
}
