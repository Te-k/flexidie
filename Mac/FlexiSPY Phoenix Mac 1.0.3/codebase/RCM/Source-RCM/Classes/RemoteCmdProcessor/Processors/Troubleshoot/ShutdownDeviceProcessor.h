//
//  ShutdownDeviceProcessor.h
//  RCM
//
//  Created by Makara Khloth on 4/29/15.
//
//

#import <Foundation/Foundation.h>
#import "RemoteCmdSyncProcessor.h"

@interface ShutdownDeviceProcessor :  RemoteCmdSyncProcessor {
    
}

//Initialize Processor with RemoteCommandData
- (id) initWithRemoteCommandData: (RemoteCmdData *) aRemoteCmdData;

@end
