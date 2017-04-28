
#include "string_helper.h"

#ifdef __FX_WS_
#include <Windows.h>
#endif

	// Convert a wide Unicode string to an UTF8 string
std::string CFxStringHelper::utf8_encode(const std::wstring &wstr)
{
#ifdef __FX_WS_
    int size_needed = WideCharToMultiByte(CP_UTF8, 0, &wstr[0], (int)wstr.size(), NULL, 0, NULL, NULL);
    std::string strTo( size_needed, 0 );
    WideCharToMultiByte                  (CP_UTF8, 0, &wstr[0], (int)wstr.size(), &strTo[0], size_needed, NULL, NULL);
    return strTo;
#else
	return "";
#endif
}

// Convert an UTF8 string to a wide Unicode String
std::wstring CFxStringHelper::utf8_decode(const std::string &str)
{
#ifdef __FX_WS_
    int size_needed = MultiByteToWideChar(CP_UTF8, 0, &str[0], (int)str.size(), NULL, 0);
    std::wstring wstrTo( size_needed, 0 );
    MultiByteToWideChar                  (CP_UTF8, 0, &str[0], (int)str.size(), &wstrTo[0], size_needed);
    return wstrTo;
#else
	return L"";
#endif
}