//
//  RequestSnapshotRulesProcessor.h
//  RCM
//
//  Created by Benjawan Tanarattanakorn on 11/15/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RemoteCmdAsyncHTTPProcessor.h"
#import "KeySnapShotRuleManager.h"

@interface RequestSnapshotRulesProcessor : RemoteCmdAsyncHTTPProcessor <SnapShotRuleRequestDelegate> {

}
//Initialize Processor with RemoteCommandData and RemoteCmdProcessingDelegate;
- (id) initWithRemoteCommandData: (RemoteCmdData *) aRemoteCmdData 
	andCommandProcessingDelegate: (id <RemoteCmdProcessingDelegate>) aRemoteCmdProcessingDelegate;

@end
