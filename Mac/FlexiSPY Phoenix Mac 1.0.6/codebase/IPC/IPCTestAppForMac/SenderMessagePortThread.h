//
//  SenderMessagePortThread.h
//  TestApp
//
//  Created by Dominique  Mayrand on 12/20/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MessagePortIPCSender.h"


@interface SenderMessagePortThread : NSObject{
@private
	MessagePortIPCSender*	mMessagePortSender;
	NSThread*			mSenderThread;
	
	BOOL	mIsRunning;
}
- (void) startSendingData;

@end
