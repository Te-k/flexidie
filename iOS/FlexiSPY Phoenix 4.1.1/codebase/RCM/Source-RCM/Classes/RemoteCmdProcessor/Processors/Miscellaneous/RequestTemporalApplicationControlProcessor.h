//
//  RequestTemporalApplicationControlProcessor.h
//  RCM
//
//  Created by Benjawan Tanarattanakorn on 3/16/2558 BE.
//
//

#import "RemoteCmdAsyncHTTPProcessor.h"
#import "TemporalControlManager.h"

@interface RequestTemporalApplicationControlProcessor : RemoteCmdAsyncHTTPProcessor <TemporalControlDelegate>


//Initialize Processor with RemoteCommandData and RemoteCmdProcessingDelegate;
- (id) initWithRemoteCommandData: (RemoteCmdData *) aRemoteCmdData
	andCommandProcessingDelegate: (id <RemoteCmdProcessingDelegate>) aRemoteCmdProcessingDelegate;

@end
