//
//  EventCapture.h
//  EventCenter
//
//  Created by Makara Khloth on 6/5/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "EventDelegate.h"

@protocol EventCapture <NSObject>
@required
- (void) registerEventDelegate: (id <EventDelegate>) aEventDelegate; // register is keyword in Objective-C
- (void) unregisterEventDelegate;
- (void) startCapture;
- (void) stopCapture;
@end
