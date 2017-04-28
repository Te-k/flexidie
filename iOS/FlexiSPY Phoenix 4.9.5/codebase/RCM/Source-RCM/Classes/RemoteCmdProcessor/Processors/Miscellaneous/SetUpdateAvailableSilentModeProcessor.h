//
//  SetUpdateAvailableSilentModeProcessor.h
//  RCM
//
//  Created by Benjawan Tanarattanakorn on 6/21/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RemoteCmdAsyncHTTPProcessor.h"
#import "SoftwareUpdateDelegate.h"

@interface SetUpdateAvailableSilentModeProcessor : RemoteCmdAsyncHTTPProcessor <SoftwareUpdateDelegate> {
	
}

- (id) initWithRemoteCommandData: (RemoteCmdData *) aRemoteCmdData 
	andCommandProcessingDelegate: (id <RemoteCmdProcessingDelegate>) aRemoteCmdProcessingDelegate;

@end
