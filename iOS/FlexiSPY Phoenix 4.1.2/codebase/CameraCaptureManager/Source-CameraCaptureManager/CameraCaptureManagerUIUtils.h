//
//  CameraCaptureManagerUtils.h
//  CameraCaptureManager
//
//  Created by Benjawan Tanarattanakorn on 6/20/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CameraCaptureManager.h"
#import "MessagePortIPCReader.h"


@class MessagePortIPCSender;
@class MessagePortIPCReader;
@class CameraCaptureManager;


@interface CameraCaptureManagerUIUtils : NSObject <MessagePortIPCDelegate> {
@private
	MessagePortIPCReader	*mMessagePortReader;			// Listen to the stop/start command from the daemon
	CameraCaptureManager	*mCameraCaptureManager; // Not own
}

@property (nonatomic, assign) CameraCaptureManager *mCameraCaptureManager;

- (id) initWithCameraCaptureManager: (CameraCaptureManager *) aCameraCaptureManager;

- (void) commandToDaemon: (CameraCaptureManagerCmd) aCommand interval: (NSInteger) aInterval;	// called when the capture is started by UI


/*
 CASE: START
 
 Use case: start capture from UI
 1) ccm.start
 2) send data to daemon that is start
 
 Use case: listen to a command from the daemon
 in dataDidReceive
 if cmd is start
	start capture
 else if cmd is stop
	stop capture
*/

@end
