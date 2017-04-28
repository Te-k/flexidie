#include <Foundation/Foundation.h>

#ifdef GNUSTEP_BASE_VERSION
#    define NSBlockClassName @"_NSBlock"
#else
#    define NSBlockClassName @"NSBlock"
#endif

id CallBlockWithArguments(id block, NSArray *aArguments);
