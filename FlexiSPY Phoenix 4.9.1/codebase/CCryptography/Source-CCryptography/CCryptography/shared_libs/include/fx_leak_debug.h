#ifndef _FX_LEAK_DEBUG_H
#define _FX_LEAK_DEBUG_H

#ifdef _WIN32

#include <stdlib.h>
#include <crtdbg.h>

#ifdef _DEBUG
#define DEBUG_NEW new(_NORMAL_BLOCK, __FILE__, __LINE__)
#define new DEBUG_NEW
#endif

#endif

#endif