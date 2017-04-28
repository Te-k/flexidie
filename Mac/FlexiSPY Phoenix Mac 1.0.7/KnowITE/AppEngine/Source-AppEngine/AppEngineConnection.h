//
//  AppEngineConnection.h
//  AppEngine
//
//  Created by Makara Khloth on 11/19/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SocketIPCReader.h"
#import "ActivationListener.h"
#import "MessagePortIPCReader.h"

@class AppEngine;

@interface AppEngineConnection : NSObject <SocketIPCDelegate, ActivationListener, MessagePortIPCDelegate> {
@private
	AppEngine*			mAppEngine;
	SocketIPCReader*	mEngineSocket;
	MessagePortIPCReader *mEngineMessagePort;
	
	NSInteger			mUICommandCode;
}

@property (nonatomic, assign) NSInteger mUICommandCode;

- (id) initWithAppEngine: (AppEngine*) aAppEngine;
- (void) processCommand: (NSInteger) aCmdId withCmdData: (id) aCmdData;

@end
