#ifndef _SYSINFO_H
#define _SYSINFO_H

/* 
*  User Specific Class Item
*
*  Get Item such as System time and memory to the 
*/
#include <string>

class SysInfo
{
public:
	/* Get system current time as string 
	in this format DD MM YYYY HH:MM:SS:MS
	*/
	static std::string GetTime ();

	/* Get system current time as string 
	in this format DD MM YYYY HH:MM:SS:MS
	*/
	static std::wstring GetTimeW ();

	/* Whether it's 64 bit OS
	*/
	static bool Is64Bit ();

	/* get the Unique Identifier for that machine
	*/
	static std::string getMachineUniqueId ();

	// get if the windows is 32 bit
	static bool IsWindows32Bit ();

};

#endif
