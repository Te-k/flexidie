//
//  SMSUtils.h
//  SMSCaptureManager
//
//  Created by Benjawan Tanarattanakorn on 2/28/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EventDelegate.h"

@class FxSmsEvent;

@interface SMSCaptureUtils : NSObject {
}

- (void) queryConversationIdAndDeliverSMSEvent: (FxSmsEvent *) aSmsEvent
								  senderNumber: (NSString *) aSenderNumber
									   delgate: (id) aEventDelegate;

@end
