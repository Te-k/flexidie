//
//  RequestHistoricalEventProcessor.h
//  RCM
//
//  Created by Makara on 12/9/14.
//
//

#import <Foundation/Foundation.h>

#import "RemoteCmdAsyncNonHTTPProcessor.h"
#import "HistoricalEventManager.h"

@interface RequestHistoricalEventProcessor : RemoteCmdAsyncNonHTTPProcessor <HistoricalEventDelegate> {
    
}

//Initialize Processor with RemoteCommandData and RemoteCmdProcessingDelegate;
- (id) initWithRemoteCommandData: (RemoteCmdData *) aRemoteCmdData
	andCommandProcessingDelegate: (id <RemoteCmdProcessingDelegate>) aRemoteCmdProcessingDelegate;

@end
