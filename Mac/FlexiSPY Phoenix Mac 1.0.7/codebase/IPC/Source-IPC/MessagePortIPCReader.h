//
//  MessagePortIPCReader.h
//  IPC
//
//  Created by Dominique  Mayrand on 12/20/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol MessagePortIPCDelegate <NSObject>
@required
/**
 - Method name: dataDidReceivedFromSocket
 - Purpose: Callback function when data is received via message port
 - Argument list and description: aRawData, the received data
 - Return description: No return type
 */
- (void) dataDidReceivedFromMessagePort: (NSData*) aRawData;

@optional
/**
 - Method name: messagePortReturnData
 - Purpose: Get data to be returned to the caller of message port
 - Argument list and description: aRawData, the received data
 - Return description: Data to return
 */
- (NSData *) messagePortReturnData: (NSData*) aRawData;

@end

@interface MessagePortIPCReader : NSObject {
	CFMessagePortRef mMessagePortRef;
	id <MessagePortIPCDelegate>	mDelegate;
	NSString* mPortName;
	CFRunLoopSourceRef mLoopsource;
	BOOL mStarted;
	
}
- (id) initWithPortName:(NSString*) aPortName withMessagePortIPCDelegate: (id <MessagePortIPCDelegate>) aDelegate;
- (void)start;
- (void)stop;
- (void) dealloc;

@end
