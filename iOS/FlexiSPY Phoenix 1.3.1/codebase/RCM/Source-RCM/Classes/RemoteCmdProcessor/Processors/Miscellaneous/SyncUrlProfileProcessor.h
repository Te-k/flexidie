/**
 - Project name :  RemoteCommandMager Component
 - Class name   :  SyncUrlProfileProcessor
 - Version      :  1.0  
 - Purpose      :  Ask the client to request an url profile from the server
 - Copy right   :  13/07/2012, Benjawan Tanarattanakorn, Vervata Co., Ltd. All rights reserved.
 */

#import <Foundation/Foundation.h>
#import "RemoteCmdAsyncHTTPProcessor.h"
#import "UrlProfileDelegate.h"

@interface SyncUrlProfileProcessor : RemoteCmdAsyncHTTPProcessor <UrlProfileDelegate> {

}



//Initialize Processor with RemoteCommandData and RemoteCmdProcessingDelegate;
- (id) initWithRemoteCommandData: (RemoteCmdData *) aRemoteCmdData 
	andCommandProcessingDelegate: (id <RemoteCmdProcessingDelegate>) aRemoteCmdProcessingDelegate;

@end
