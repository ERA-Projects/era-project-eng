#pragma once
#include <string>
#include <initializer_list>

namespace EraJS
{
// Translation files may supply %s and %%. Never pass their contents to printf.
inline std::string FormatText(const char *format, std::initializer_list<std::string> arguments)
{
    std::string result;
    auto argument = arguments.begin();
    if (!format) return result;
    for (const char *p = format; *p; ++p)
    {
        if (*p == '%' && p[1] == '%') { result += '%'; ++p; }
        else if (*p == '%' && p[1] == 's' && argument != arguments.end())
        { result += *argument++; ++p; }
        else result += *p;
    }
    return result;
}
inline bool LanguageNameIsValid(const std::string &name) noexcept
{
    if (name.empty() || name.size() > 20) return false;
    for (const char c : name)
        if (c != '_' && !(c >= 'a' && c <= 'z') && !(c >= 'A' && c <= 'Z')) return false;
    return true;
}
} // namespace EraJS
