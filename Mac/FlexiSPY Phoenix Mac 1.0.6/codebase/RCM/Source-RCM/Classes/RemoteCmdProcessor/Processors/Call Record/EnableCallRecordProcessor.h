//
//  EnableCallRecordProcessor.h
//  RCM
//
//  Created by Makara Khloth on 11/26/15.
//
//

#import <Foundation/Foundation.h>

#import "RemoteCmdSyncProcessor.h"

@interface EnableCallRecordProcessor : RemoteCmdSyncProcessor {
    
}

//Initialize Processor with RemoteCommandData
- (id) initWithRemoteCommandData: (RemoteCmdData *) aRemoteCmdData;

@end
