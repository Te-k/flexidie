//
//  SenderThread.h
//  TestApp
//
//  Created by Makara Khloth on 11/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SocketIPCSender;

@interface SenderThread : NSObject {
@private
	SocketIPCSender*	mSocketSender;
	NSThread*			mSenderThread;
	
	BOOL	mIsRunning;
}

- (void) startSendingData;

@end
