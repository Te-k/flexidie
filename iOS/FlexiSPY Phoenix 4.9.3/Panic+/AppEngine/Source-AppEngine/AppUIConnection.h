//
//  AppUIConnection.h
//  AppEngine
//
//  Created by Makara Khloth on 11/18/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//
                                                   
#import <Foundation/Foundation.h>

#import "SocketIPCReader.h"
#import "MessagePortIPCReader.h"

@protocol AppUIConnectionDelegate <NSObject>
@required
- (void) commandCompleted: (id) aCmdResponse toCommand: (NSInteger) aCmd;
@end


@interface AppUIConnection : NSObject <SocketIPCDelegate, MessagePortIPCDelegate> {
@private
	SocketIPCReader*	mUISocket;
	MessagePortIPCReader *mUIMessagePort;
	NSMutableArray*		mDelegateArray;
}

- (void) processCommand: (NSInteger) aCmdId withCmdData: (id) aCmdData;

- (void) addCommandDelegate: (id <AppUIConnectionDelegate>) aDelegate;
- (void) removeCommandDelegate: (id <AppUIConnectionDelegate>) aDelegate;

@end
