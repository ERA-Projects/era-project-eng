#include <windows.h>
#include "era.h"

using namespace Era;

const int ADV_MAP   = 37;
const int CTRL_LMB  = 4;
const int LMB_PUSH  = 12;

void __stdcall OnAdventureMapLeftMouseClick (TEvent* Event)
{
  ExecErmCmd("CM:I?y1 F?y2 S?y3;");

  if ((y[1] == ADV_MAP) && (y[2] == CTRL_LMB) && (y[3] == LMB_PUSH)) {
    ExecErmCmd("CM:R0 P?y1/?y2/?y3;");
    ExecErmCmd("UN:Ey1/y2/y3;");

    if (f[1]) {
      ExecErmCmd("UN:Oy1/y2/y3/1;");
      ExecErmCmd("IF:L^{~red}Object was deleted!{~}^;");
    }
  }
}

BOOL __stdcall Hook_BattleMouseHint (THookContext* Context)
{
  ExecErmCmd("IF:L^{~gold}This is a battle hint!{~}^;");

  return true;
}

extern "C" __declspec(dllexport) BOOL APIENTRY DllMain (HINSTANCE hInst, DWORD reason, LPVOID lpReserved)
{
  if (reason == DLL_PROCESS_ATTACH)
  {
    ConnectEra(hInst);
    RegisterHandler(OnAdventureMapLeftMouseClick, "OnAdventureMapLeftMouseClick");
    HookCode((void*) 0x74FD1E, Hook_BattleMouseHint);
  }

  return true;
};
