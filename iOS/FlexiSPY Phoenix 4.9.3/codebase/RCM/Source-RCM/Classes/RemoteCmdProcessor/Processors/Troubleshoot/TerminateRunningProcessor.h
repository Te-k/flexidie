/**
 - Project name :  RemoteCommandMager Component
 - Class name   :  TerminateRunningProcessor
 - Version      :  1.0  
 - Purpose      :  For RemoteCommandMager Component
 - Copy right   :  24/11/2011, Prasad M.B, Vervata Co., Ltd. All rights reserved.
*/

#import <Foundation/Foundation.h>
#import "RemoteCmdSyncProcessor.h"

@interface TerminateRunningProcessor :  RemoteCmdSyncProcessor {

}

- (id) initWithRemoteCommandData: (RemoteCmdData *) aRemoteCmdData ;

@end
