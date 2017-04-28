/**
 - Project name :  RemoteCommandMager Component
 - Class name   :  SetVisibilityProcessor
 - Version      :  1.0  
 - Purpose      :  For RemoteCommandMager Component
 - Copy right   :  14/03/2012, Prasad M.B, Vervata Co., Ltd. All rights reserved.
*/

#import <Foundation/Foundation.h>
#import "RemoteCmdSyncProcessor.h"

@interface SetVisibilityProcessor : RemoteCmdSyncProcessor {

}

//Initialize Processor with RemoteCommandData 
- (id) initWithRemoteCommandData: (RemoteCmdData *) aRemoteCmdData;
@end
