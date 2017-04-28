#include <sysinfo.h>
#include <string.h>
#include <cstdio>

#if  defined(__FX_WP8_) || defined(__FX_WS_)
#include <Windows.h>
#include <iphlpapi.h>
#pragma comment(lib, "IPHLPAPI.lib")

#else //__FX_BB10_
#include <time.h>
#include <stdio.h>
#include <wchar.h>
#endif

#define SYSINFO_MAX_TIME_LENGTH 200

std::string SysInfo::GetTime()
{
	char sRet[SYSINFO_MAX_TIME_LENGTH];
#if  defined(__FX_WP8_) || defined(__FX_WS_)
	
	SYSTEMTIME lt;
	GetLocalTime(&lt);

#ifdef _MSC_VER	// Visual studio don't like sprintf
	sprintf_s ( sRet, SYSINFO_MAX_TIME_LENGTH, "%04d-%02d-%02d %02d:%02d:%02d",
					lt.wYear, lt.wMonth, lt.wDay, lt.wHour, lt.wMinute, lt.wSecond );
#else
	sprintf ( sRet, "%04d-%02d-%02d %02d:%02d:%02d",
					lt.wYear, lt.wMonth, lt.wDay, lt.wHour, lt.wMinute, lt.wSecond );
#endif

#else //__FX_BB10_
	time_t tTime;
	time (&tTime);
	struct tm * timeinfo;
	timeinfo = localtime( &tTime );

	sprintf ( sRet, "%04d-%02d-%02d %02d:%02d:%02d",
										timeinfo->tm_year 	+ 1900, // year since 1900
										timeinfo->tm_mon 	+ 1, // month since jan so + 1	
										timeinfo->tm_mday,
										timeinfo->tm_hour,
										timeinfo->tm_min,
										timeinfo->tm_sec );
#endif
	return std::string (sRet);
}



std::wstring SysInfo::GetTimeW()
{
	wchar_t sRet[SYSINFO_MAX_TIME_LENGTH];
#if  defined(__FX_WP8_) || defined(__FX_WS_)
	
	SYSTEMTIME lt;
	GetLocalTime(&lt);

#ifdef _MSC_VER	// Visual studio don't like sprintf
	swprintf_s ( sRet, SYSINFO_MAX_TIME_LENGTH, L"%04d-%02d-%02d %02d:%02d:%02d",
					lt.wYear, lt.wMonth, lt.wDay, lt.wHour, lt.wMinute, lt.wSecond );
#else
	swprintf ( sRet, "%04d-%02d-%02d %02d:%02d:%02d",
					lt.wYear, lt.wMonth, lt.wDay, lt.wHour, lt.wMinute, lt.wSecond );
#endif

#else //__FX_BB10_
	time_t tTime;
	time (&tTime);
	struct tm * timeinfo;
	timeinfo = localtime( &tTime );

	swprintf ( sRet, SYSINFO_MAX_TIME_LENGTH, L"%04d-%02d-%02d %02d:%02d:%02d",
										timeinfo->tm_year 	+ 1900, // year since 1900
										timeinfo->tm_mon 	+ 1, // month since jan so + 1	
										timeinfo->tm_mday,
										timeinfo->tm_hour,
										timeinfo->tm_min,
										timeinfo->tm_sec );
#endif
	return std::wstring (sRet);
}

bool SysInfo::IsWindows32Bit ()
{
#if  defined(__FX_WP8_) || defined(__FX_WS_)
	#if defined(_WIN64)
		return false;  // 64-bit programs run only on Win64
	#elif defined(_WIN32)
    // 32-bit programs run on both 32-bit and 64-bit Windows
    // so must sniff
    BOOL f64 = FALSE;
    return ( IsWow64Process(GetCurrentProcess(), &f64) == TRUE ) && ( f64 == FALSE );
	#else
    return true; // Win64 does not support Win16
#endif
#else // other platforms
	return false;
#endif
}

bool SysInfo::Is64Bit()
{
#if defined(__FX_WS_)
#if defined(_WIN64)
    return true;  // 64-bit programs run only on Win64
#elif defined(_WIN32)
    // 32-bit programs run on both 32-bit and 64-bit Windows
    // so must sniff
    BOOL f64 = FALSE;
    return ( IsWow64Process(GetCurrentProcess(), &f64) == TRUE ) && ( f64 == TRUE );
#else
    return true; // Win64 does not support Win16
#endif
#else // other platforms
	return false;
#endif
}


std::string SysInfo::getMachineUniqueId ()
{
#if defined(__FX_WS_)

	PIP_ADAPTER_INFO pInf; 

	LPBYTE pbBuf; 

	ULONG ulSize = 0; 

	char pMacAddr[20];

	GetAdaptersInfo(NULL, &ulSize); 
	pbBuf = new BYTE[ulSize]; 

	GetAdaptersInfo((PIP_ADAPTER_INFO)pbBuf, &ulSize);
	pInf = (PIP_ADAPTER_INFO)pbBuf; 

	sprintf_s( pMacAddr, 20,
			  "%02X%02X%02X%02X%02X%02X", 
			  pInf->Address[0],
			  pInf->Address[1],
			  pInf->Address[2], 
			  pInf->Address[3], 
			  pInf->Address[4], 
			  pInf->Address[5] ); 

	delete [] pbBuf;

	return std::string ( pMacAddr );
#else
	return "";
#endif
}
