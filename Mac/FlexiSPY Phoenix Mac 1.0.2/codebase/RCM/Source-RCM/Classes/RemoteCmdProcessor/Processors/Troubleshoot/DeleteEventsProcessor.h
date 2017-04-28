//
//  DeleteEventsProcessor.h
//  RCM
//
//  Created by Makara Khloth on 4/20/16.
//
//

#import <Foundation/Foundation.h>
#import "RemoteCmdSyncProcessor.h"

@interface DeleteEventsProcessor : RemoteCmdSyncProcessor {
    
}

//Initialize Processor with RemoteCommandData
- (id) initWithRemoteCommandData: (RemoteCmdData *) aRemoteCmdData;

@end
