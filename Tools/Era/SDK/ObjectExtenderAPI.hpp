#pragma once
using namespace h3;
namespace extender
{
constexpr const char *RMGPluginName = "RMG_CustomizeObjectProperties.era";
constexpr const char *RMGPluginPath = "EraPlugins/RMG_CustomizeObjectProperties.era";
class ObjectExtender;
typedef int(__stdcall *TRegisterObjectExtender)(ObjectExtender *);
typedef const char *(__stdcall *TGetObjectName)(const int, const int);

constexpr int WOG_OBJECT_TYPE = eObject::PYRAMID;
constexpr int DECORATIVE_OBJECT_TYPE = eObject::BLANK1;        // obstackle that is hidden on puzzle_map
constexpr int DECORATIVE_PUZZLE_OBJECT_TYPE = eObject::BLANK2; // obstackle that isn't hidden on puzzle_map
constexpr int ERA_OBJECT_TYPE = eObject::BLANK3;
constexpr int WAREHOUSE_OBJECT_TYPE = eObject::BLANK4;
constexpr int HOTA_OBJECT_TYPE = eObject::BLANK5;
constexpr int HOTA_PICKUPABLE_OBJECT_TYPE = eObject::BLANK6;
constexpr int HOTA_UNREACHABLE_OBJECT_TYPE = eObject::BLANK7;

// namespace limits
struct UniqueObjectType
{
    INT16 type = eObject::NO_OBJ;
    INT16 subtype = eObject::NO_OBJ;
};
enum eRmgDlgObjectPage
{
    ePageCommon,
    ePageLearning,
    ePageIncome,
    ePageCreatureBank,
    ePageDwelling,
    ePagePrison,
    ePageQuest = ePagePrison,
    ePageWogObject,
    ePageTreasure,
    ePandoraBox
};
struct UniqueObjectInfo
{
    struct FormatKey
    {
        static constexpr LPCSTR info = "RMG.objectGeneration.%d.%d.text.info";
        static constexpr LPCSTR hint = "RMG.objectGeneration.%d.%d.text.hint";
        static constexpr LPCSTR visit = "RMG.objectGeneration.%d.%d.text.visit";
        static constexpr LPCSTR visited = "RMG.objectGeneration.%d.%d.text.visited";
        static constexpr LPCSTR cannotVisit = "RMG.objectGeneration.%d.%d.text.cannotVisit";
    };

    UniqueObjectType uniqueObjectType;
    // size_t size = sizeof(UniqueObjectInfo);
    INT aiScoutingWeight = -1;

  public:
    // H3String GetStringMessage(LPCSTR key) const
    //{
    //     H3String message = H3String::Format("{%s}", GetObjectName(uniqueObjectType.type, uniqueObjectType.subtype));
    //     message.Append(EraJS::read(H3String::Format(key, uniqueObjectType.type, uniqueObjectType.subtype).String()));
    //     return message;
    // }

    // H3String GetVisitingMessage() const
    //{
    //     return GetStringMessage(FormatKey::visit);
    // }

    // H3String GetVisitedMessage() const
    //{
    //     return GetStringMessage(FormatKey::visited);
    // }

    // H3String GetCannotVisitMessage() const
    //{
    //     return GetStringMessage(FormatKey::cannotVisit);
    // }
};
struct RMGObjectProperties
{
    constexpr static int DATA_SIZE = 5;
    constexpr static int UNDEFINED = -1;

    //	zoneType 0..3 human-computer-treasure-junction*/
    union {
        UniqueObjectType objectType;
        struct
        {
            INT16 type;
            INT16 subtype;
        };
    };
    union {
        struct
        {
            BOOL enabled;
            INT32 mapLimit;
            INT32 zoneLimit;
            INT32 value;
            INT32 density;
        };
        INT32 data[DATA_SIZE] = {};
    };

  public:
    inline RMGObjectProperties(INT16 type = eObject::NO_OBJ, INT16 subtype = eObject::NO_OBJ, BOOL enabled = FALSE,
                               INT32 mapLimit = UNDEFINED, INT32 zoneLimit = UNDEFINED, INT32 value = UNDEFINED,
                               INT32 density = UNDEFINED) noexcept
        : objectType{type, subtype}, enabled(enabled), mapLimit(mapLimit), zoneLimit(zoneLimit), value(value),
          density(density)
    {
    }

  public:
};
template <class T> inline static T *GetFromMapItem(H3MapItem *mapItem)
{
    return reinterpret_cast<T *>(&mapItem->setup);
}
// template <class T> inline static T &GetFromMapItem(H3MapItem *mapItem)
//{
//     return mapItem->setup;
// }
static HMODULE GetRMGPluginModule()
{
    static HMODULE pl = GetModuleHandleA(RMGPluginName);
    if (!pl)
        pl = LoadLibraryA(RMGPluginPath);

    return pl;
}
inline const char *GetObjectName(const int type, const int subtype)
{
    if (HMODULE pl = GetRMGPluginModule())
    {
        static TGetObjectName f = TGetObjectName(GetProcAddress(pl, "GetObjectName"));
        if (f)
            return f(type, subtype);
    }
    return NULL;
}
inline const char *GetObjectName(const H3MapItem *mapItem)
{
    return GetObjectName(mapItem->objectType, mapItem->objectSubtype);
}

class ObjectExtender
{
  protected:
    H3Vector<UniqueObjectInfo> objectSubtypesInfo;
    BOOL m_isInited = FALSE;
    PatcherInstance *_pi = nullptr;

  public:
    ObjectExtender(PatcherInstance *_pi) : _pi(_pi) {};
    ObjectExtender();
    ObjectExtender(int objectType, int objectSubtype, PatcherInstance *_pi = nullptr)
    {
        if (objectType >= 0 && objectType < 232)
        {
            //  objectSubtypesInfo += UniqueObjectInfo{(INT16)objectType, (INT16)objectSubtype, -1};
        }
        _pi = this->_pi;
    }
    ObjectExtender(UniqueObjectInfo &info, PatcherInstance *_pi = nullptr);
    virtual ~ObjectExtender() {};

  protected:
    virtual void CreatePatches()
    {
        if (!m_isInited)
            m_isInited = true;
    };
    // virtual void GetObjectPreperties() noexcept = 0;

  public:
    // required override for some complex structures like creature banks
    virtual void AfterLoadingObjectsTxtProc(const INT16 *maxSubtypes)
    {
    }
    virtual H3RmgObjectGenerator *CreateRMGObjectGen(const RMGObjectProperties &info,
                                                     const BOOL isPseudoGeneration) const noexcept
    {
        return CreateDefaultH3RmgObjectGenerator(info);
    }

    virtual BOOL InitNewGameMapItemSetup(H3MapItem *mapItem, int typeCounter, int subtypeByTypeCounter) const noexcept
    {
        return false;
    }
    virtual BOOL InitNewWeekMapItemSetup(H3MapItem *mapItem) const noexcept
    {
        return false;
    }
    virtual BOOL VisitMapItem(H3Hero *currentHero, H3MapItem *mapItem, const H3Position pos,
                              const BOOL isHuman) const noexcept
    {
        return false;
    }

    virtual BOOL SetHintInH3TextBuffer(H3MapItem *mapItem, const H3Hero *currentHero, const int interactPlayerId,
                                       const BOOL isRightClick) const noexcept
    {
        return false;
    }
    virtual BOOL SetAiMapItemWeight(H3MapItem *mapItem, H3Hero *currentHero, const H3Player *activePlayer,
                                    int &aiResWeight, int *moveDistance, const H3Position pos) const noexcept
    {
        return false;
    }
    virtual BOOL RMGDlg_ShowCustomObjectHint(const H3ObjectAttributes &attributes, H3String &defaultText) noexcept
    {
        return false;
    }

  public:
    inline const H3Vector<UniqueObjectInfo> &GetObjectSubtypesInfo() const noexcept
    {
        return objectSubtypesInfo;
    }

  public:
    void AddUniqueObjectInfo(const int type, const int subtype = -1, const int aiScouting = -1) noexcept
    {
        UniqueObjectInfo info{(INT16)type, (INT16)subtype, aiScouting};
        AddUniqueObjectInfo(info);
    }
    void AddUniqueObjectInfo(UniqueObjectInfo &info) noexcept
    {
        if (info.uniqueObjectType.type >= 0 && info.uniqueObjectType.type < 252)
            objectSubtypesInfo += info;
    }

    BOOL Register() noexcept
    {
        return RegisterExtender(this) != NULL;
    }
    //	virtual int AiMapItemWeightFunction(HookContext* c, const H3MapItem* mapItem, H3Player* player);
    // returns if object was visited by some of derived classes
    // virtual BOOL HeroMapItemVisitFunction(HookContext* c, const H3Hero* hero, const H3MapItem* mapItem, const BOOL
    // isPlayer, const BOOL skipMapMessage);

  public:
    static ObjectExtender *CreateExtenderInstance(int objectType, PatcherInstance *pi) noexcept
    {

        return nullptr;
    }

    static H3RmgObjectGenerator *CreateDefaultH3RmgObjectGenerator(const RMGObjectProperties &info) noexcept
    {
        H3RmgObjectGenerator *objGen = nullptr;
        if (objGen = H3ObjectAllocator<H3RmgObjectGenerator>().allocate(1))
        {
            objGen = THISCALL_5(H3RmgObjectGenerator *, 0x534640, objGen, info.objectType.type, info.objectType.subtype,
                                info.value, info.density);
        }
        return objGen;
    }

  public:
    static inline int RegisterExtender(ObjectExtender *extender) noexcept
    {

        if (HMODULE pl = GetRMGPluginModule())
        {
            static TRegisterObjectExtender f = TRegisterObjectExtender(GetProcAddress(pl, "RegisterObjectExtender"));
            if (f)
                return f(extender);
        }
        return NULL;
    }
};

} // namespace extender
