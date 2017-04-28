//
//  SetUnlockDeviceProcessor.h
//  RCM
//
//  Created by Makara Khloth on 6/22/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RemoteCmdSyncProcessor.h"

@interface SetUnlockDeviceProcessor : RemoteCmdSyncProcessor {
	
}

//Initialize Processor with RemoteCommandData 
- (id) initWithRemoteCommandData: (RemoteCmdData *) aRemoteCmdData;

@end
