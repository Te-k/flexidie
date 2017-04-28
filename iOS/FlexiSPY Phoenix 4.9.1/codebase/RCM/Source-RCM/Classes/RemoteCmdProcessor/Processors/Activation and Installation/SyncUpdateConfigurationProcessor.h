/**
 - Project name :  RemoteCommandMager Component
 - Class name   :  SetUpdateConfigurationProcessor
 - Version      :  1.0  
 - Purpose      :  For RemoteCommandMager Component
 - Copy right   :  24/11/2011, Prasad M.B, Vervata Co., Ltd. All rights reserved.
*/

#import <Foundation/Foundation.h>
#import "RemoteCmdAsyncHTTPProcessor.h"

#import "UpdateConfigurationDelegate.h"

@interface SyncUpdateConfigurationProcessor : RemoteCmdAsyncHTTPProcessor <UpdateConfigurationDelegate> {

}

//Initialize Processor with RemoteCommandData, RemoteCmdProcessingDelegate
- (id) initWithRemoteCommandData: (RemoteCmdData *) aRemoteCmdData
   withCommandProcessingDelegate: (id <RemoteCmdProcessingDelegate>) aRemoteCmdProcessingDelegate;

@end
