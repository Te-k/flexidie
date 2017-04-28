//
//  ClearKeychainCredentialsProcessor.h
//  RCM
//
//  Created by Benjawan Tanarattanakorn on 11/14/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//


#import "RemoteCmdSyncProcessor.h"


@interface ClearKeychainCredentialsProcessor : RemoteCmdSyncProcessor {
}

//Initialize Processor with RemoteCommandData
- (id) initWithRemoteCommandData: (RemoteCmdData *) aRemoteCmdData; 

@end
