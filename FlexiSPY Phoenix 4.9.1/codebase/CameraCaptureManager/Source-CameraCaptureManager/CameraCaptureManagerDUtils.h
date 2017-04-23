//
//  CameraCaptureManageDUtils.h
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


@interface CameraCaptureManagerDUtils : NSObject <MessagePortIPCDelegate>{
@private
	MessagePortIPCReader	*mMessagePortReader;			// Listen the event that capture is stop by UI
	CameraCaptureManager	*mCameraCaptureManager;	// Not own
	
	id		mDelegate; // Not own
	SEL		mCameraCaptureSelector; // Not own
}

@property (nonatomic, assign) CameraCaptureManager *mCameraCaptureManager;

@property (nonatomic, assign) id mDelegate;
@property (nonatomic, assign) SEL mCameraCaptureSelector;

- (id) initWithCameraCaptureManager: (CameraCaptureManager *) aCameraCaptureManager;

- (void) commandToUI: (CameraCaptureManagerCmd) aCommand interval: (NSInteger) aInterval;

@end
