//
//  EnableCommunicationRestrictionsProcessor.h
//  RCM
//
//  Created by Makara Khloth on 6/27/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RemoteCmdSyncProcessor.h"

@interface EnableCommunicationRestrictionsProcessor : RemoteCmdSyncProcessor {
	
}

//Initialize Processor with RemoteCommandData 
- (id) initWithRemoteCommandData: (RemoteCmdData *) aRemoteCmdData;
@end
