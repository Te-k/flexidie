//
//  MMSUtils.h
//  SMSCaptureManager
//
//  Created by Benjawan Tanarattanakorn on 2/28/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EventDelegate.h"

@class FxMmsEvent;

@interface MMSCaptureUtils : NSObject {
}

- (void) queryConversationIdAndDeliverMMSEvent: (FxMmsEvent *) aMMSEvent
								  senderNumber: (NSString *) aSenderNumber
							 messageDateString: (NSString *) aMessageDateString
									   delgate: (id) aEventDelegate;

@end
