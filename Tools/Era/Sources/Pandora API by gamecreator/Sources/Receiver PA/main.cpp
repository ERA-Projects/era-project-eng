#include "Era.h"
#include "papi.h"
#include <memory.h>

struct MemoryChunk
{
	int __0;
	void* start;
	void* endUsed;
	void* end;
};

struct SecSkill
{
	int id;
	int level;
};

struct StringBuffer
{
	int __0;
	char* s;
	int length;
	int maxLength;
};

#pragma pack(push)
#pragma pack(1)
struct PandorasBox
{
	StringBuffer message;
	int hasGuards;
	int guardType[7];
	int guardNumber[7];
	DWORD __76;
	int experience;
	int spellPoints;
	char morale;
	char luck;
	WORD __90;
	int resource[7];
	char primarySkill[4];
	MemoryChunk skills;
	MemoryChunk artifacts;
	MemoryChunk spells;
	int creatureType[7];
	int creatureNumber[7];
};

struct MapTile{
	DWORD data;
	BYTE terrainType;
	BYTE terrainTile;
	BYTE riverType;
	BYTE riverTile;
	BYTE roadType;
	BYTE roadTile;
	WORD __10;
	BYTE mirrorInfo;
	BYTE passabilityInfo;
	MemoryChunk renderInfo;
	WORD objectType;
	WORD __32;
	WORD objectSubtype;
	WORD __36;
};
#pragma pack(pop)

void ReallocMemoryChunk(MemoryChunk& c, size_t newSize)
{
	int len = (DWORD)c.endUsed - (DWORD)c.start;
	c.start = realloc(c.start, newSize);
	c.end = (BYTE*)c.start + newSize;
	c.endUsed = (BYTE*)c.start + len;
	if (c.end < c.endUsed)
	{
		c.endUsed = c.end;
	}
}

MapTile* GetTile(int x, int y, int l)
{
	int mapSize = *(int*)(*(DWORD*)0x699538 + 0x1FC44);
	return (MapTile*)(*(DWORD*)(*(DWORD*)0x699538 + 0x1FC40)) + (l * mapSize + y) * mapSize + x;
}

int __stdcall PandorasBoxHandler(ErmCommand& cmd)
{
	int x, y, l;
	if (cmd.numReceiverArgs == 3
		&& cmd.receiverArgs[0].vartype != 'e' && cmd.receiverArgs[0].vartype != 'z' // with present ERM parser having immediate string here is impossible
		&& cmd.receiverArgs[1].vartype != 'e' && cmd.receiverArgs[1].vartype != 'z'
		&& cmd.receiverArgs[2].vartype != 'e' && cmd.receiverArgs[2].vartype != 'z')
	{
		x = *cmd.receiverArgs[0].value.integer;
		y = *cmd.receiverArgs[1].value.integer;
		l = *cmd.receiverArgs[2].value.integer;
	}
	else if (cmd.numReceiverArgs == 1
		&& cmd.receiverArgs[0].vartype != 'e' && cmd.receiverArgs[0].vartype != 'z'
		&& IsValidVar('v', *cmd.receiverArgs[0].value.integer)
		&& IsValidVar('v', *cmd.receiverArgs[0].value.integer + 2))
	{
		x = ErmVar::v[*cmd.receiverArgs[0].value.integer];
		y = ErmVar::v[*cmd.receiverArgs[0].value.integer + 1];
		l = ErmVar::v[*cmd.receiverArgs[0].value.integer + 2];
	}
	else
	{
		return RET_ERM_ERROR;
	}
	MemoryChunk* boxes;
	PandorasBox* thisBox;
	int objType, objId;
	MapTile* thisTile;
	thisTile = GetTile(x, y, l);
	objType = thisTile->objectType;
	objId = thisTile->data;
	if (objType != 6 && objType != 26)
	{
		return RET_ERM_ERROR;
	}
	boxes = (MemoryChunk*)(*(DWORD*)0x699538 + 0x1FBC0);
	if (cmd.name != 'I')
	{
		thisBox = &((PandorasBox*)boxes->start)[objId];
	}
	ErmArgumentFormat fmtANRS = {2, {{ALLOWED_SET, EXPECTED_INTEGER}, {ALLOWED_ALL, EXPECTED_INTEGER}}};
	ErmArgumentFormat fmtAINS = {0};
	ErmArgumentFormat fmtCG = {3, {{ALLOWED_SET, EXPECTED_INTEGER}, {ALLOWED_ALL, EXPECTED_INTEGER}, {ALLOWED_ALL, EXPECTED_INTEGER}}};
	ErmArgumentFormat fmtEOPUX = {1, {{ALLOWED_ALL, EXPECTED_INTEGER}}};
	ErmArgumentFormat fmtF = {4, {{ALLOWED_ALL, EXPECTED_INTEGER}, {ALLOWED_ALL, EXPECTED_INTEGER}, {ALLOWED_ALL, EXPECTED_INTEGER}, {ALLOWED_ALL, EXPECTED_INTEGER}}};
	ErmArgumentFormat fmtM = {1, {{ALLOWED_SET | ALLOWED_GET, EXPECTED_INTEGER | EXPECTED_STRING}}};
	ErmArgumentFormat fmtN = {1, {{ALLOWED_SET | ALLOWED_GET, EXPECTED_INTEGER}}};
	switch (cmd.name)
	{
		case 'A': // artifacts
			if (CheckArgs(cmd, fmtANRS)) // A#1/$2 - get/check/set number $2 of artifacts #1
			{
				int artNum = 0;
				for (int* p = (int*)thisBox->artifacts.start; p < thisBox->artifacts.endUsed; p++)
				{
					if (*p == *cmd.args[0].value.integer)
					{
						artNum++;
					}
				}
				int newNum = artNum;
				ApplyArg(cmd.args[1], newNum);
				if (newNum < artNum)
				{
					int* pLast = (int*)thisBox->artifacts.endUsed;
					pLast--; // last element
					for (int* p = pLast; p >= thisBox->artifacts.start && newNum < artNum; p--)
					{
						if (*p == *cmd.args[0].value.integer) // remove this artifact
						{
							*p = *pLast;
							pLast--;
							artNum--;
						}
					}
					thisBox->artifacts.endUsed = pLast + 1;
				}
				else if (newNum > artNum)
				{
					newNum -= artNum;
					if (newNum * sizeof(int) + (DWORD)thisBox->artifacts.endUsed > (DWORD)thisBox->artifacts.end)
					{
						// add at least 64 positions
						ReallocMemoryChunk(thisBox->artifacts, max(64, newNum) * sizeof(int) + (DWORD)thisBox->artifacts.endUsed - (DWORD)thisBox->artifacts.start);
					}
					for (; newNum > 0; newNum--)
					{
						*(int*)thisBox->artifacts.endUsed = *cmd.args[0].value.integer;
						thisBox->artifacts.endUsed = (int*)thisBox->artifacts.endUsed + 1;
					}
				}
			}
			else if (CheckArgs(cmd, fmtAINS)) // A - clear artifacts
			{
				if (thisBox->artifacts.start != thisBox->artifacts.end) // memory was allocated
				{
					free(thisBox->artifacts.start);
				}
				thisBox->artifacts.start = thisBox->artifacts.endUsed = thisBox->artifacts.end = 0;
			}
			else
			{
				return RET_ERM_ERROR;
			}
			break;
		case 'C': // creatures
			if (CheckArgs(cmd, fmtCG) // C#1/$2/$3 - set/check/get $3 creatures of type $2 in position #1
				&& *cmd.args[0].value.integer >= 0 && *cmd.args[0].value.integer <= 6)
			{
				ApplyArg(cmd.args[1], thisBox->creatureType[*cmd.args[0].value.integer]);
				ApplyArg(cmd.args[2], thisBox->creatureNumber[*cmd.args[0].value.integer]);
			}
			else
			{
				return RET_ERM_ERROR;
			}
			break;
		case 'E': // experience
			if (CheckArgs(cmd, fmtEOPUX)) // E$ - set/check/get experience amount to $
			{
				ApplyArg(cmd.args[0], thisBox->experience);
			}
			else
			{
				return RET_ERM_ERROR;
			}
			break;
		case 'F': // primary skills
			if (CheckArgs(cmd, fmtF)) // F$1/$2/$3/$4 - set/check/get attack/defense/power/knowledge to $1/$2/$3/$4
			{
				int primary[4] = {thisBox->primarySkill[0], thisBox->primarySkill[1], thisBox->primarySkill[2], thisBox->primarySkill[3]};
				ApplyArg(cmd.args[0], primary[0]);
				ApplyArg(cmd.args[1], primary[1]);
				ApplyArg(cmd.args[2], primary[2]);
				ApplyArg(cmd.args[3], primary[3]);
				thisBox->primarySkill[0] = primary[0];
				thisBox->primarySkill[1] = primary[1];
				thisBox->primarySkill[2] = primary[2];
				thisBox->primarySkill[3] = primary[3];
			}
			else
			{
				return RET_ERM_ERROR;
			}
			break;
		case 'G': // guards
			if (CheckArgs(cmd, fmtCG) // G#1/$2/$3 - set/check/get $3 guards of type $2 in position #1
				&& *cmd.args[0].value.integer >= 0 && *cmd.args[0].value.integer <= 6)
			{
				ApplyArg(cmd.args[1], thisBox->guardType[*cmd.args[0].value.integer]);
				ApplyArg(cmd.args[2], thisBox->guardNumber[*cmd.args[0].value.integer]);
			}
			else
			{
				return RET_ERM_ERROR;
			}
			break;
		case 'I': // initial setup
			if (CheckArgs(cmd, fmtAINS)) // I - properly set up newly placed box or event
			{
				if ((DWORD)boxes->endUsed - (DWORD)boxes->start >= sizeof(PandorasBox) * 1024) // there are 1024 boxes already
				{
					return RET_ERM_ERROR;
				}
				if ((DWORD)boxes->end - (DWORD)boxes->endUsed < sizeof(PandorasBox))
				{
					// add 64 more empty slots
					ReallocMemoryChunk(*boxes, (DWORD)boxes->endUsed - (DWORD)boxes->start + 64 * sizeof(PandorasBox));
				}
				thisBox = (PandorasBox*)boxes->endUsed;
				memset(thisBox, 0, sizeof(PandorasBox));
				memset(thisBox->creatureType, -1, 7 * sizeof(int));
				memset(thisBox->guardType, -1, 7 * sizeof(int));
				thisTile->data = ((DWORD)boxes->endUsed - (DWORD)boxes->start) / sizeof(PandorasBox);
				boxes->endUsed = (BYTE*)boxes->endUsed + sizeof(PandorasBox);
			}
			else
			{
				return RET_ERM_ERROR;
			}
			break;
		case 'M': // message
			if (CheckArgs(cmd, fmtM)) // M$ - set/get message to integer (pointer) or string $
			{
				StringBuffer* mes = &thisBox->message;
				if (cmd.args[0].passedAs == ERM_PASS_GET) // implicitly it is not immediate value
				{
					if (cmd.args[0].vartype == 'z')
					{
						int mSize = mes->length;
						if (mSize > 511)
						{
							mSize = 511;
						}
						// memmove in case they managed to set the message directly to a z var
						memmove(cmd.args[0].value.string, mes->s, mSize);
						cmd.args[0].value.string[mSize] = 0; // end of string
					}
					else // just get pointer
					{
						*cmd.args[0].value.integer = (int)mes->s;
					}
				}
				else // passedAs = ERM_PASS_VALUE i.e. set
				{
					if (cmd.args[0].number == 0) // either a zero-length immediate string or a null pointer
					{
						mes->length = 0; // set to zero length
					}
					else // message exists
					{
						char* targetStr;
						if (cmd.args[0].vartype == VARTYPE_IMMEDIATE_STRING || cmd.args[0].vartype == 'z')
						{
							targetStr = cmd.args[0].value.string;
						}
						else // vartype is int (pointer)
						{
							targetStr = (char*)*cmd.args[0].value.integer;
						}
						int mSize = strlen(targetStr); // does not need +1 for trailing \0
						if (mes->maxLength < mSize)
						{
							// realloc if not enough memory
							mes->s = (char*)realloc(mes->s, mSize);
							mes->maxLength = mSize;
						}
						memcpy(mes->s, targetStr, mSize);
						mes->length = mSize;
					}
				}
			}
			else
			{
				return RET_ERM_ERROR;
			}
			break;
		case 'N': // secondary skills
			if (CheckArgs(cmd, fmtANRS) // N#1/$2 - set/check/get level of skill #1 to $2
				&& *cmd.args[0].value.integer >= 0 && *cmd.args[0].value.integer < 28)
			{
				SecSkill* pSkill = 0;
				for (SecSkill* p = (SecSkill*)thisBox->skills.start; p < thisBox->skills.endUsed; p++)
				{
					if (p->id == *cmd.args[0].value.integer)
					{
						pSkill = p;
						break;
					}
				}
				int skLevel = (pSkill ? pSkill->level : 0);
				ApplyArg(cmd.args[1], skLevel);
				if (skLevel > 0 && !pSkill) // add new skill
				{
					if ((DWORD)thisBox->skills.end - (DWORD)thisBox->skills.endUsed < sizeof(SecSkill))
					{
						// set to 28 positions (sufficient for all 28 skills)
						ReallocMemoryChunk(thisBox->skills, 28 * sizeof(SecSkill));
					}
					((SecSkill*)thisBox->skills.endUsed)->id = *cmd.args[0].value.integer;
					((SecSkill*)thisBox->skills.endUsed)->level = min(3, skLevel);
					thisBox->skills.endUsed = (SecSkill*)thisBox->skills.endUsed + 1;
				}
				else if (pSkill) // there was a skill
				{
					if (skLevel <= 0) // remove existing skill
					{
						thisBox->skills.endUsed = (SecSkill*)thisBox->skills.endUsed - 1;
						*pSkill = *(SecSkill*)thisBox->skills.endUsed;
					}
					else // update skill
					{
						pSkill->level = min(3, skLevel);
					}
				}
			}
			else if (CheckArgs(cmd, fmtN) // N$ - set/get all skill levels to 28 vars starting with $
				// if last var in range exists (impicitly excludes immediate values)
				&& (cmd.args[0].number > 0 && IsValidVar(cmd.args[0].vartype, cmd.args[0].number + 27)
					|| cmd.args[0].number < 0 && IsValidVar(cmd.args[0].vartype, cmd.args[0].number - 27)))
			{
				int levels[28];
				memset(levels, 0, 28 * sizeof(int));
				for (SecSkill* p = (SecSkill*)thisBox->skills.start; p < thisBox->skills.endUsed; p++)
				{
					levels[p->id] = p->level;
				}
				int num = cmd.args[0].number; // save var num
				for (int i = num, j = 0; j < 28; (i > 0 ? i++ : i--), j++)
				{
					cmd.args[0].number = i;
					ApplyArg(cmd.args[0], levels[j]);
				}
				thisBox->skills.endUsed = thisBox->skills.start; // erase all skill info
				ReallocMemoryChunk(thisBox->skills, 28 * sizeof(SecSkill)); // allocate 28 positions
				SecSkill* pos = (SecSkill*)thisBox->skills.start;
				for (int i = 0; i < 28; i++)
				{
					if (levels[i] > 0)
					{
						pos->id = i;
						pos->level = min(3, levels[i]);
						pos++;
					}
				}
				thisBox->skills.endUsed = pos;
			}
			else if (CheckArgs(cmd, fmtAINS)) // N - clear skills
			{
				if (thisBox->skills.start != thisBox->skills.end) // memory was allocated
				{
					free(thisBox->skills.start);
				}
				thisBox->skills.start = thisBox->skills.endUsed = thisBox->skills.end = 0;
			}
			else
			{
				return RET_ERM_ERROR;
			}
			break;
		case 'O': // morale
			if (CheckArgs(cmd, fmtEOPUX)) // O$ - set/check/get morale bonus to $
			{
				int value = thisBox->morale;
				ApplyArg(cmd.args[0], value);
				thisBox->morale = value;
			}
			else
			{
				return RET_ERM_ERROR;
			}
			break;
		case 'P': // spell points
			if (CheckArgs(cmd, fmtEOPUX)) // P$ - set/check/get spell points to $
			{
				ApplyArg(cmd.args[0], thisBox->spellPoints);
			}
			else
			{
				return RET_ERM_ERROR;
			}
			break;
		case 'R': // resources
			if (CheckArgs(cmd, fmtANRS) // R#1/$2 - set/check/get amount of resource #1 to $2
				&& *cmd.args[0].value.integer >= 0 && *cmd.args[0].value.integer < 7)
			{
				ApplyArg(cmd.args[1], thisBox->resource[*cmd.args[0].value.integer]);
			}
			else
			{
				return RET_ERM_ERROR;
			}
			break;
		case 'S': // spells
			if (CheckArgs(cmd, fmtANRS)) // S#1/$2 - get/check/set spell #1 to $2 (0 - don't give, 1 - give)
			{
				int* pSpell = 0;
				for (int* p = (int*)thisBox->spells.start; p < thisBox->spells.endUsed; p++)
				{
					if (*p == *cmd.args[0].value.integer)
					{
						pSpell = p;
						break;
					}
				}
				int hasSpell = (pSpell ? 1 : 0);
				ApplyArg(cmd.args[1], hasSpell);
				if (hasSpell > 0 && !pSpell) // add new spell
				{
					if (sizeof(int) + (DWORD)thisBox->spells.endUsed > (DWORD)thisBox->spells.end)
					{
						// add 64 positions
						ReallocMemoryChunk(thisBox->spells, 64 * sizeof(int) + (DWORD)thisBox->spells.endUsed - (DWORD)thisBox->spells.start);
					}
					*(int*)thisBox->spells.endUsed = *cmd.args[0].value.integer;
					thisBox->spells.endUsed = (int*)thisBox->spells.endUsed + 1;
				}
				else if (hasSpell <= 0 && pSpell) // remove existing spell
				{
					thisBox->spells.endUsed = (int*)thisBox->spells.endUsed - 1;
					*pSpell = *(int*)thisBox->spells.endUsed;
				}
			}
			else if (CheckArgs(cmd, fmtAINS)) // S - clear spells
			{
				if (thisBox->spells.start != thisBox->spells.end) // memory was allocated
				{
					free(thisBox->spells.start);
				}
				thisBox->spells.start = thisBox->spells.endUsed = thisBox->spells.end = 0;
			}
			else
			{
				return RET_ERM_ERROR;
			}
			break;
		case 'U': // luck
			if (CheckArgs(cmd, fmtEOPUX)) // U$ - set/check/get luck bonus to $
			{
				int value = thisBox->luck;
				ApplyArg(cmd.args[0], value);
				thisBox->luck = value;
			}
			else
			{
				return RET_ERM_ERROR;
			}
			break;
		case 'X': // "has guards" flag
			if (CheckArgs(cmd, fmtEOPUX)) // X$ - set/check/get guards flag to $
			{
				ApplyArg(cmd.args[0], thisBox->hasGuards);
			}
			else
			{
				return RET_ERM_ERROR;
			}
			break;
		default:
			return RET_ERM_ERROR;
	}
	return RET_ERM_SUCCESS;
}

int ReceiverPA(char c, int num, void* todo, void* mes)
{
	return GenericErmHandler(PandorasBoxHandler, c, num, todo, mes);
}

void __stdcall OnPAPIReady(Era::TEvent* Event)
{
	ConnectPandorasAPI();
	RegisterErmReceiver("PA", ReceiverPA, 2);
}

extern "C" __declspec(dllexport) BOOL APIENTRY DllMain (HINSTANCE hInst, DWORD reason, LPVOID lpReserved)
{
	if (reason == DLL_PROCESS_ATTACH)
	{
		Era::ConnectEra();
		Era::RegisterHandler(OnPAPIReady, "OnPandora'sApiReady");
	}
	return TRUE;
};
