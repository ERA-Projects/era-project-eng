#pragma once

#include <stdint.h>

// Optional synchronous API. All request pointers remain owned by the caller.
namespace ArtifactDescriptionApi
{
static const char VARIABLE[] = "GEM.ArtifactDescription.Api.1";
static const uint32_t MAGIC = 0x31444147u;
static const uint32_t VERSION = 1;

#pragma pack(push, 4)
struct Request
{
    uint32_t size;
    uint32_t version;
    const void *hero;
    const void *artifact;
    int32_t slot; // Body slot 0..18; -1 means no selected body slot.
};
typedef int(__stdcall *ShowProc)(const Request *request);
struct Api
{
    uint32_t magic;
    uint32_t size;
    uint32_t version;
    ShowProc show;
};
#pragma pack(pop)

static_assert(sizeof(void *) == 4, "Artifact description API requires Win32");
static_assert(sizeof(Request) == 20, "Unexpected artifact request layout");
static_assert(sizeof(Api) == 16, "Unexpected artifact API layout");
}
