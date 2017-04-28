//
//  Midnight.h
//  MSFSP
//
//  Created by Makara Khloth on 3/29/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "MSFSP.h"
#import "SpringBoard.h"

HOOK(SpringBoard, _midnightPassed, void) {
	CALL_ORIG(SpringBoard, _midnightPassed);
	
	DLog (@"Mid-night passed ...");
	CFNotificationCenterPostNotification (CFNotificationCenterGetDarwinNotifyCenter(),
										  (CFStringRef) @"SBMidnightPassedNotification",
										  nil,
										  nil,		// If center is a Darwin notification center, this value is ignored.
										  false);
}