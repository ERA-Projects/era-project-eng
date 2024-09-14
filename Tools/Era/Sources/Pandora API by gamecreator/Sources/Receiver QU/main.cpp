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

struct StringBuffer
{
	int __0;
	char* s;
	int length;
	int maxLength;
};

#pragma pack(push)
#pragma pack(1)
struct Quest
{
	void* checkFuction; // 0x641798 + questType * 0x3C
	int questorType; // 0 = quest guard, 1 = seer hut
	StringBuffer messageProposal;
	StringBuffer messageProgress;
	StringBuffer messageCompletion;
	int stringId; // texts variant, of no use
	int lastDay;
	union {
		int achieveLevel;				// achieve level
		char achievePrimarySkill[4];	// have primary skills
		struct {
			int __0;
			int targetHero;
			int successfulPlayers;
		} killHero;						// kill certain hero
		struct {
			int __0;
			int packedCoords;
			int displayCreatureType;
			int player;
		} killMonster;					// kill a monster in certain position on the map
		MemoryChunk getArtifacts;			// bring artifacts
		struct {
			MemoryChunk number;
			MemoryChunk type;
		} getCreatures;					// bring creatures
		int getResource[7];				// bring resources
		int beHero;						// visit as a certain hero
		int bePlayer;					// visit as a certain player
	} data;
};

struct SeerHut
{
	Quest* quest;
	BYTE playersVisited;
	int rewardType;
	int rewardValue;
	int rewardValue2;
	BYTE seerNameId;
	BYTE __18;
};

struct QuestGuard
{
	Quest* quest;
	BYTE playersVisited;
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

inline int PackCoords(int x, int y, int l)
{
	return (x & 0x3FF) + ((y & 0x3FF) << 16) + ((l & 0xF) << 26);
}

inline void UnpackCoords(int coords, int& x, int& y, int& l)
{
	x = coords & 0x3FF;
	y = (coords >> 16) & 0x3FF;
	l = (coords >> 26) & 0xF;
}

MapTile* GetTile(int x, int y, int l)
{
	int mapSize = *(int*)(*(DWORD*)0x699538 + 0x1FC44);
	return (MapTile*)(*(DWORD*)(*(DWORD*)0x699538 + 0x1FC40)) + (l * mapSize + y) * mapSize + x;
}

inline int GetQuestType(Quest* q)
{
	return (q ? ((DWORD)q->checkFuction - 0x641798) / 0x3C + 1 : 0); // 0 = nothing, then the list
}

int __stdcall QuestHandler(ErmCommand& cmd)
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
	MemoryChunk* objects;
	Quest* thisQuest;
	void* thisObj;
	int objType, objId;
	MapTile* thisTile;
	thisTile = GetTile(x, y, l);
	objType = thisTile->objectType;
	objId = thisTile->data;
	if (objType != 83 && objType != 215)
	{
		return RET_ERM_ERROR;
	}
	objects = (MemoryChunk*)(*(DWORD*)0x699538 + (objType == 83 ? 0x1FBD0 : 0x1FBE0));
	if (cmd.name != 'I')
	{
		if (objType == 83)
		{
			thisObj = &((SeerHut*)objects->start)[objId];
		}
		else
		{
			thisObj = &((QuestGuard*)objects->start)[objId];
		}
		thisQuest = ((QuestGuard*)thisObj)->quest; // safe, first 5 bytes are the same in Seer Hut and Quest Guard
	}
	ErmArgumentFormat fmtI = {0};
	ErmArgumentFormat fmtM = {2, {{ALLOWED_SET, EXPECTED_INTEGER}, {ALLOWED_SET | ALLOWED_GET, EXPECTED_INTEGER | EXPECTED_STRING}}};
	ErmArgumentFormat fmtDNV = {1, {{ALLOWED_ALL, EXPECTED_INTEGER}}};
	ErmArgumentFormat fmtQ = {1, {{ALLOWED_CHECK_GET, EXPECTED_INTEGER}}};
	ErmArgumentFormat fmtV = {2, {{ALLOWED_SET, EXPECTED_INTEGER}, {ALLOWED_ALL, EXPECTED_INTEGER}}};
	ErmArgumentFormat fmtR = {3, {{ALLOWED_ALL, EXPECTED_INTEGER}, {ALLOWED_ALL, EXPECTED_INTEGER}, {ALLOWED_ALL, EXPECTED_INTEGER}}};
	ErmArgumentFormat fmtQ0 = {1, {{ALLOWED_SET, EXPECTED_INTEGER}}};
	ErmArgumentFormat fmtQ1 = {2, {{ALLOWED_SET, EXPECTED_INTEGER}, {ALLOWED_ALL, EXPECTED_INTEGER}}};
	ErmArgumentFormat fmtQ2 = {5, {{ALLOWED_SET, EXPECTED_INTEGER}, {ALLOWED_ALL, EXPECTED_INTEGER}, {ALLOWED_ALL, EXPECTED_INTEGER}, {ALLOWED_ALL, EXPECTED_INTEGER}, {ALLOWED_ALL, EXPECTED_INTEGER}}};
	ErmArgumentFormat fmtQ3 = {3, {{ALLOWED_SET, EXPECTED_INTEGER}, {ALLOWED_ALL, EXPECTED_INTEGER}, {ALLOWED_ALL, EXPECTED_INTEGER}}};
	ErmArgumentFormat fmtQ4 = {6, {{ALLOWED_SET, EXPECTED_INTEGER}, {ALLOWED_ALL, EXPECTED_INTEGER}, {ALLOWED_ALL, EXPECTED_INTEGER}, {ALLOWED_ALL, EXPECTED_INTEGER}, {ALLOWED_ALL, EXPECTED_INTEGER}, {ALLOWED_ALL, EXPECTED_INTEGER}}};
	ErmArgumentFormat fmtQ5 = {3, {{ALLOWED_SET, EXPECTED_INTEGER}, {ALLOWED_SET, EXPECTED_INTEGER}, {ALLOWED_ALL, EXPECTED_INTEGER}}};
	switch (cmd.name)
	{
		case 'D': // last day
			if (!thisQuest) // check if quest is present
			{
				return RET_ERM_ERROR;
			}
			if (CheckArgs(cmd, fmtDNV)) // D$ - set/check/get last day to $
			{
				ApplyArg(cmd.args[0], thisQuest->lastDay);
			}
			else
			{
				return RET_ERM_ERROR;
			}
			break;
		case 'I': // initial setup
			if (CheckArgs(cmd, fmtI)) // I - properly set up newly placed hut or guard
			{
				DWORD objSize = (objType == 83 ? sizeof(SeerHut) : sizeof(QuestGuard));
				if ((DWORD)objects->end - (DWORD)objects->endUsed < objSize)
				{
					// add 64 more empty slots
					ReallocMemoryChunk(*objects, (DWORD)objects->endUsed - (DWORD)objects->start + 64 * objSize);
				}
				thisObj = objects->endUsed;
				memset(thisObj, 0, objSize);
				thisTile->data = ((DWORD)objects->endUsed - (DWORD)objects->start) / objSize;
				objects->endUsed = (BYTE*)objects->endUsed + objSize;
			}
			else
			{
				return RET_ERM_ERROR;
			}
			break;
		case 'M': // message
			if (!thisQuest) // check if quest is present
			{
				return RET_ERM_ERROR;
			}
			if (CheckArgs(cmd, fmtM) // M#1/$2 - set/get message #1 to integer (pointer) or string $2
				&& *cmd.args[0].value.integer >= 0 && *cmd.args[0].value.integer <= 2) // proposal/progress/completion
			{
				StringBuffer* mes = &thisQuest->messageProposal;
				mes = &mes[*cmd.args[0].value.integer];
				if (cmd.args[1].passedAs == ERM_PASS_GET) // implicitly it is not immediate value
				{
					if (cmd.args[1].vartype == 'z')
					{
						int mSize = mes->length;
						if (mSize > 511)
						{
							mSize = 511;
						}
						// memmove in case they managed to set the message directly to a z var
						memmove(cmd.args[1].value.string, mes->s, mSize);
						cmd.args[1].value.string[mSize] = 0; // end of string
					}
					else // just get pointer
					{
						*cmd.args[1].value.integer = (int)mes->s;
					}
				}
				else // passedAs = ERM_PASS_VALUE i.e. set
				{
					if (cmd.args[1].number == 0) // either a zero-length immediate string or a null pointer
					{
						mes->length = 0; // set to zero length
					}
					else // message exists
					{
						char* targetStr;
						if (cmd.args[1].vartype == VARTYPE_IMMEDIATE_STRING || cmd.args[1].vartype == 'z')
						{
							targetStr = cmd.args[1].value.string;
						}
						else // vartype is int (pointer)
						{
							targetStr = (char*)*cmd.args[1].value.integer;
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
		case 'N': // seer name
			if (objType != 83) // only seer huts allowed
			{
				return RET_ERM_ERROR;
			}
			if (CheckArgs(cmd, fmtDNV)) // N$ - set/check/get seer id (name) to $
			{
				int value = ((SeerHut*)thisObj)->seerNameId;
				ApplyArg(cmd.args[0], value);
				((SeerHut*)thisObj)->seerNameId = value;
			}
			else
			{
				return RET_ERM_ERROR;
			}
			break;
		case 'Q':
			// no matter if quest exists, will create it anyway
			if (CheckArgs(cmd, fmtQ)) // Q?$ - check/get quest type to $
			{
				int questType = GetQuestType(thisQuest);
				ApplyArg(cmd.args[0], questType);
			}
			else if (CheckArgs(cmd, fmtQ0) // Q0 - remove quest
				&& *cmd.args[0].value.integer == 0)
			{
				if (thisQuest)
				{
					free(thisQuest);
					((QuestGuard*)thisObj)->quest = 0;
				}
			}
			else if (cmd.numArgs >= 1 && cmd.args[0].passedAs == ERM_PASS_VALUE // multipurpose syntax: quest customization
				&& cmd.args[0].vartype != VARTYPE_IMMEDIATE_STRING && cmd.args[0].vartype != 'z'
				&& cmd.args[0].vartype != 'e'
				&& *cmd.args[0].value.integer >= 1 && *cmd.args[0].value.integer <= 9)
			{
				if (!thisQuest)
				{
					((QuestGuard*)thisObj)->quest = thisQuest = (Quest*)calloc(1, sizeof(Quest));
					thisQuest->questorType = (objType == 215 ? 0 : 1); // 0 = quest guard, 1 = seer hut
					thisQuest->lastDay = -1;
				}
				else if (GetQuestType(thisQuest) != *cmd.args[0].value.integer) // quest change, clear all data
				{
					memset(&thisQuest->data, 0, sizeof(thisQuest->data));
				}
				thisQuest->checkFuction = (void*)(0x641798 + (*cmd.args[0].value.integer - 1) * 0x3C);
				switch (*cmd.args[0].value.integer)
				{
					case 1:
						if (CheckArgs(cmd, fmtQ1)) // Q1/$ - set/check/get level to achieve to $
						{
							ApplyArg(cmd.args[1], thisQuest->data.achieveLevel);
						}
						else
						{
							return RET_ERM_ERROR;
						}
						break;
					case 2:
						if (CheckArgs(cmd, fmtQ2)) // Q2/$1/$2/$3/$4 - set/check/get primary skills to achieve to $1..$4
						{
							int primary[4] = {thisQuest->data.achievePrimarySkill[0], thisQuest->data.achievePrimarySkill[1], thisQuest->data.achievePrimarySkill[2], thisQuest->data.achievePrimarySkill[3]};
							ApplyArg(cmd.args[1], primary[0]);
							ApplyArg(cmd.args[2], primary[1]);
							ApplyArg(cmd.args[3], primary[2]);
							ApplyArg(cmd.args[4], primary[3]);
							thisQuest->data.achievePrimarySkill[0] = primary[0];
							thisQuest->data.achievePrimarySkill[1] = primary[1];
							thisQuest->data.achievePrimarySkill[2] = primary[2];
							thisQuest->data.achievePrimarySkill[3] = primary[3];
						}
						else
						{
							return RET_ERM_ERROR;
						}
						break;
					case 3:
						if (CheckArgs(cmd, fmtQ3)) // Q3/$1/$2 - set/check/get a hero to kill to $1 and successful players to $2
						{
							ApplyArg(cmd.args[1], thisQuest->data.killHero.targetHero);
							ApplyArg(cmd.args[2], thisQuest->data.killHero.successfulPlayers);
						}
						else
						{
							return RET_ERM_ERROR;
						}
						break;
					case 4:
						if (CheckArgs(cmd, fmtQ4)) // Q4/$1/$2/$3/$4/$5 - set/check/get coords of a creature to kill to $1..$3,
						{									// creature displayed in quest log to $4 and successful player to $5
							int cX, cY, cL;
							UnpackCoords(thisQuest->data.killMonster.packedCoords, cX, cY, cL);
							ApplyArg(cmd.args[1], cX);
							ApplyArg(cmd.args[2], cY);
							ApplyArg(cmd.args[3], cL);
							ApplyArg(cmd.args[4], thisQuest->data.killMonster.displayCreatureType);
							ApplyArg(cmd.args[5], thisQuest->data.killMonster.player);
							thisQuest->data.killMonster.packedCoords = PackCoords(cX, cY, cL);
						}
						else
						{
							return RET_ERM_ERROR;
						}
						break;
					case 5:
						if (CheckArgs(cmd, fmtQ5)) // Q5/#1/$2 - get/check/set number of artifacts #1 to deliver to $2
						{
							int artNum = 0;
							for (int* p = (int*)thisQuest->data.getArtifacts.start; p < thisQuest->data.getArtifacts.endUsed; p++)
							{
								if (*p == *cmd.args[1].value.integer)
								{
									artNum++;
								}
							}
							int newNum = artNum;
							ApplyArg(cmd.args[2], newNum);
							if (newNum < artNum)
							{
								int* pLast = (int*)thisQuest->data.getArtifacts.endUsed;
								pLast--; // last element
								for (int* p = pLast; p >= thisQuest->data.getArtifacts.start && newNum < artNum; p--)
								{
									if (*p == *cmd.args[1].value.integer) // remove this artifact
									{
										*p = *pLast;
										pLast--;
										artNum--;
									}
								}
								thisQuest->data.getArtifacts.endUsed = pLast + 1;
							}
							else if (newNum > artNum)
							{
								newNum -= artNum;
								if (newNum * sizeof(int) + (DWORD)thisQuest->data.getArtifacts.endUsed > (DWORD)thisQuest->data.getArtifacts.end)
								{
									// add at least 64 positions
									ReallocMemoryChunk(thisQuest->data.getArtifacts, max(64, newNum) * sizeof(int) + (DWORD)thisQuest->data.getArtifacts.endUsed - (DWORD)thisQuest->data.getArtifacts.start);
								}
								for (; newNum > 0; newNum--)
								{
									*(int*)thisQuest->data.getArtifacts.endUsed = *cmd.args[1].value.integer;
									thisQuest->data.getArtifacts.endUsed = (int*)thisQuest->data.getArtifacts.endUsed + 1;
								}
							}
						}
						else if (CheckArgs(cmd, fmtQ0)) // Q5 - clear artifacts
						{
							if (thisQuest->data.getArtifacts.start != thisQuest->data.getArtifacts.end) // memory was allocated
							{
								free(thisQuest->data.getArtifacts.start);
							}
							thisQuest->data.getArtifacts.start = thisQuest->data.getArtifacts.endUsed = thisQuest->data.getArtifacts.end = 0;
						}
						else
						{
							return RET_ERM_ERROR;
						}
						break;
					case 6:
						if (CheckArgs(cmd, fmtQ5)) // Q6/#1/$2 - get/check/set number of creatures of type #1 to deliver to $2
						{
							int* pNum = 0;
							int* pType = 0;
							for (pType = (int*)thisQuest->data.getCreatures.type.start; pType < thisQuest->data.getCreatures.type.endUsed; pType++)
							{
								if (*pType == *cmd.args[1].value.integer)
								{
									pNum = (int*)thisQuest->data.getCreatures.number.start + (pType - (int*)thisQuest->data.getCreatures.type.start);
									break;
								}
							}
							int newNum = (pNum ? *pNum : 0);
							ApplyArg(cmd.args[2], newNum);
							if (newNum) // creatures present
							{
								if (pNum) // and they were present
								{
									*pNum = newNum;
								}
								else // and they were not present
								{
									if ((DWORD)thisQuest->data.getCreatures.type.end - (DWORD)thisQuest->data.getCreatures.type.endUsed < sizeof(int))
									{
										// add 64 more positions
										ReallocMemoryChunk(thisQuest->data.getCreatures.type, 64 * sizeof(int) + (DWORD)thisQuest->data.getCreatures.type.endUsed - (DWORD)thisQuest->data.getCreatures.type.start);
									}
									if ((DWORD)thisQuest->data.getCreatures.number.end - (DWORD)thisQuest->data.getCreatures.number.endUsed < sizeof(int))
									{
										// add 64 more positions
										ReallocMemoryChunk(thisQuest->data.getCreatures.number, 64 * sizeof(int) + (DWORD)thisQuest->data.getCreatures.number.endUsed - (DWORD)thisQuest->data.getCreatures.number.start);
									}
									// add type
									pType = (int*)thisQuest->data.getCreatures.type.endUsed;
									*pType = *cmd.args[1].value.integer;
									thisQuest->data.getCreatures.type.endUsed = pType + 1;
									// add number
									pNum = (int*)thisQuest->data.getCreatures.number.endUsed;
									*pNum = *cmd.args[2].value.integer;
									thisQuest->data.getCreatures.number.endUsed = pNum + 1;
								}
							}
							else if (pNum) // creature were present, but now they are not
							{
								// remove type
								int* pLast = (int*)thisQuest->data.getCreatures.type.endUsed - 1; // last element
								*pType = *pLast;
								thisQuest->data.getCreatures.type.endUsed = pLast;
								// remove number
								pLast = (int*)thisQuest->data.getCreatures.number.endUsed - 1; // last element
								*pNum = *pLast;
								thisQuest->data.getCreatures.number.endUsed = pLast;
							}
						}
						else if (CheckArgs(cmd, fmtQ0)) // Q6 - clear creatures
						{
							// decided not to free memory, just set length to 0
							thisQuest->data.getCreatures.type.endUsed = thisQuest->data.getCreatures.type.start;
							thisQuest->data.getCreatures.number.endUsed = thisQuest->data.getCreatures.number.start;
						}
						else
						{
							return RET_ERM_ERROR;
						}
						break;
					case 7:
						if (CheckArgs(cmd, fmtQ5) // Q7/#1/$2 - set/check/get amount of resource #1 to deliver to $2
							&& *cmd.args[1].value.integer >= 0 && *cmd.args[1].value.integer < 7)
						{
							ApplyArg(cmd.args[2], thisQuest->data.getResource[*cmd.args[1].value.integer]);
						}
						else
						{
							return RET_ERM_ERROR;
						}
						break;
					case 8:
						if (CheckArgs(cmd, fmtQ1)) // Q8/$ - set/check/get hero to visit to $
						{
							ApplyArg(cmd.args[1], thisQuest->data.beHero);
						}
						else
						{
							return RET_ERM_ERROR;
						}
						break;
					case 9:
						if (CheckArgs(cmd, fmtQ1)) // Q9/$ - set/check/get player to visit to $
						{
							ApplyArg(cmd.args[1], thisQuest->data.bePlayer);
						}
						else
						{
							return RET_ERM_ERROR;
						}
						break;
				}
			}
			else
			{
				return RET_ERM_ERROR;
			}
			break;
		case 'R': // seer hut reward
			if (objType != 83) // only seer huts allowed
			{
				return RET_ERM_ERROR;
			}
			if (CheckArgs(cmd, fmtR)) // R$1/$2/$3 - set/check/get reward type to $1 and type-specific reward values to $2 and $3
			{
				ApplyArg(cmd.args[0], ((SeerHut*)thisObj)->rewardType);
				ApplyArg(cmd.args[1], ((SeerHut*)thisObj)->rewardValue);
				ApplyArg(cmd.args[2], ((SeerHut*)thisObj)->rewardValue2);
			}
			else
			{
				return RET_ERM_ERROR;
			}
			break;
		case 'V': // visited by player
			if (CheckArgs(cmd, fmtDNV)) // V$ - set/check/get player flags to $
			{
				int flags = ((QuestGuard*)thisObj)->playersVisited;
				ApplyArg(cmd.args[0], flags);
				((QuestGuard*)thisObj)->playersVisited = flags;
			}
			else if (CheckArgs(cmd, fmtV)) // V#1/$2 - set/check/get visited state for player #1 to $2
			{
				int player = *cmd.args[0].value.integer;
				if (player == -1)
				{
					player = *((int*)0x69CCF4); // get current player
				}
				else if (player < 0)
				{
					return RET_ERM_ERROR;
				}
				int flags = ((QuestGuard*)thisObj)->playersVisited;
				int thisFlag = (flags & (1 << player)) ? 1 : 0;
				ApplyArg(cmd.args[1], thisFlag);
				thisFlag = (thisFlag ? 0 : 1); // inverted to be used below
				flags &= (-1 - (thisFlag << player)); // apply inverted flag
				((QuestGuard*)thisObj)->playersVisited = flags;
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

int ReceiverQU(char c, int num, void* todo, void* mes)
{
	return GenericErmHandler(QuestHandler, c, num, todo, mes);
}

void __stdcall OnPAPIReady(Era::TEvent* Event)
{
	ConnectPandorasAPI();
	RegisterErmReceiver("QU", ReceiverQU, 2);
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
