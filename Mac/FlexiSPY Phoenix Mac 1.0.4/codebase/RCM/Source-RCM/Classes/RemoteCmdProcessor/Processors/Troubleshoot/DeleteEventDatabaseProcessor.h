//
//  DeleteEventDatabaseProcessor.h
//  RCM
//
//  Created by Makara Khloth on 5/29/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RemoteCmdSyncProcessor.h"

@interface DeleteEventDatabaseProcessor :  RemoteCmdSyncProcessor {
	
}

//Initialize Processor with RemoteCommandData
- (id) initWithRemoteCommandData: (RemoteCmdData *) aRemoteCmdData; 

@end