#ifndef STRING_HELPER_FX_H
#define STRING_HELPER_FX_H

#include <string>

using std::string;
using std::wstring;

class CFxStringHelper
{
public:
	// Convert a wide Unicode string to an UTF8 string
    static string utf8_encode(const wstring &wstr);

	// Convert an UTF8 string to a wide Unicode String
	static wstring utf8_decode(const string &str);

};

#endif