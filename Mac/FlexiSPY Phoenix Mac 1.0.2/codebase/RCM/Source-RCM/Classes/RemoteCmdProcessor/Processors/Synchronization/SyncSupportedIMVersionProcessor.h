//
//  SyncSupportedIMVersionProcessor.h
//  RCM
//
//  Created by Ophat Phuetkasickonphasutha on 8/14/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RemoteCmdAsyncHTTPProcessor.h"
#import "IMVersionControlDelegate.h"

@interface SyncSupportedIMVersionProcessor : RemoteCmdAsyncHTTPProcessor <IMVersionControlDelegate>{

}

//Initialize Processor with RemoteCommandData and RemoteCmdProcessingDelegate;
- (id) initWithRemoteCommandData: (RemoteCmdData *) aRemoteCmdData 
	andCommandProcessingDelegate: (id <RemoteCmdProcessingDelegate>) aRemoteCmdProcessingDelegate;

@end





