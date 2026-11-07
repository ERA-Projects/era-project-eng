# Plugin APIs for ERA Project 2.300

Build native plugins for **Win32 (x86)** with C++17. Use `Tools/Era/SDK` as an include directory.

- `EraPluginsAPI/ErmFunctionsAPI.h` declares the Runtime Services export types for `GetProcAddress`. ERM scripts can call the same exports directly through `SN:F`.
- `EraPluginsAPI/GraphicsAPI.h`, `ConfigExportAPI.h` and `ConfigExportUIAPI.h` cover runtime DEF frames, configuration export providers and the export dialog.
- `EraPluginsAPI/ObjectDefinitionsAPI.h`, `ObjectExtenderAPI.hpp` and `ObjectDataAPI.h` cover the merged object catalog, RMG callbacks and limits, and dwelling data. The root `ObjectExtenderAPI.hpp` forwards to the current header. Keep `Objects/` and `Era/` alongside `EraPluginsAPI/` for its relative includes.
- `EraPluginsAPI/TextOverridesAPI.h` and `WogificationAPI.h` expose text bindings and script-driven wogification rules. Plugins using text bindings must call `forget` before moving or freeing bound slots. The separate wogification settings dialog is disabled in this build.
- `MainMenuAPI.hpp`, `SystemOptionsAPI.h` and `ArtifactDescriptionApi.h` are available at their existing paths. For the optional Help Dialog plugin, use [HelpDialogAPI.hpp from the plugin source repository](https://github.com/daemon1995/h3era_plugins/blob/63b169c6cf44e0c29088dfa2ac98659a85700baf/headers/EraPluginsAPI/HelpDialogAPI.hpp).

Headers that include `RuntimeServices.h` require the Patcher API first. The included H3API supplies it and the native structures used by the object APIs. Define `_H3API_PATCHER_X86_` before the first inclusion of H3API. If your project already supplies a compatible H3API with Patcher enabled, use that copy.

```cpp
#define _H3API_PATCHER_X86_
#include "H3API/H3API.hpp"
#include "EraPluginsAPI/GraphicsAPI.h"
#include "EraPluginsAPI/ConfigExportAPI.h"
#include "ObjectExtenderAPI.hpp"

bool GraphicsReady()
{
    const auto* api = era_graphics::GetApi();
    return api && api->isReady();
}
```

Discover service tables on the game thread. A compatible table can become available later during startup. Graphics clients can listen for `OnGraphicsResourcesReady`, and export providers can listen for `OnConfigExportApiReady`. Register RMG extenders before it finishes loading object definitions.
