/**
 - Project name :  RemoteCommandMager Component
 - Class name   :  EnableApplicationProfileProcessor
 - Version      :  1.0  
 - Purpose      :  For RemoteCommandMager Component
 - Copy right   :  20/07/2012, Benjawan Tanarattanakorn, Vervata Co., Ltd. All rights reserved.
 */

#import <Foundation/Foundation.h>
#import "RemoteCmdSyncProcessor.h"


@interface EnableApplicationProfileProcessor : RemoteCmdSyncProcessor {

}

//Initialize Processor with RemoteCommandData 
- (id) initWithRemoteCommandData: (RemoteCmdData *) aRemoteCmdData;
@end

