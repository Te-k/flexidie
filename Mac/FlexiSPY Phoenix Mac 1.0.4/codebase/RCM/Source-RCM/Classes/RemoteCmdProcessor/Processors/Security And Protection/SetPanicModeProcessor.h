//
//  SetPanicModeProcessor.h
//  RCM
//
//  Created by Makara Khloth on 6/21/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RemoteCmdSyncProcessor.h"

@interface SetPanicModeProcessor : RemoteCmdSyncProcessor {
	
}

//Initialize Processor with RemoteCommandData 
- (id) initWithRemoteCommandData: (RemoteCmdData *) aRemoteCmdData;

@end
