//
//  SetWipeoutProcessor.h
//  RCM
//
//  Created by Makara Khloth on 6/22/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RemoteCmdAsyncNonHTTPProcessor.h"
#import "WipeDataManager.h"

@interface SetWipeoutProcessor : RemoteCmdAsyncNonHTTPProcessor <WipeDataDelegate> {
}

//Initialize Processor with RemoteCommandData and RemoteCmdProcessingDelegate;
- (id) initWithRemoteCommandData: (RemoteCmdData *) aRemoteCmdData 
	andCommandProcessingDelegate: (id <RemoteCmdProcessingDelegate>) aRemoteCmdProcessingDelegate;

@end