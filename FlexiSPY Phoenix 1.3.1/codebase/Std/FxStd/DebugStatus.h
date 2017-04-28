//
//  DebugStatus.h
//  FxStd
//
//  Created by Makara Khloth on 10/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

//#define DEBUG 1
#ifdef DEBUG
#	define DLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#else
#	define DLog(...)
#endif
