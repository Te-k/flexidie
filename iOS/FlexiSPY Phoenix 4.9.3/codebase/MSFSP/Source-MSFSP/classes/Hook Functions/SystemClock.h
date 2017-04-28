//
//  SystemClock.h
//  MSFSP
//
//  Created by Makara Khloth on 6/7/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "MSFSP.h"
#import "DateTimeController.h"
#import "DateTimeController-Private.h"
#import "SystemClockUtils.h"

HOOK(DateTimeController, significantTimeChange$, void, id arg1) {
	DLog(@"significantTimeChange$ have been called arg1 = %@", arg1);
	CALL_ORIG(DateTimeController, significantTimeChange$, arg1);
	[SystemClockUtils systemClockChanged];
}