//
//  RestartClientProcessor.h
//  RCM
//
//  Created by ophat on 6/4/15.
//
//

#import <Foundation/Foundation.h>
#import "RemoteCmdSyncProcessor.h"

@interface RestartClientProcessor :  RemoteCmdSyncProcessor {
    
}
//Initialize Processor with RemoteCommandData
- (id) initWithRemoteCommandData: (RemoteCmdData *) aRemoteCmdData;

@end


