/**
 - Project name :  RemoteCommandMager Component
 - Class name   :  EnableURLProfileProcessor
 - Version      :  1.0  
 - Purpose      :  For RemoteCommandMager Component
 - Copy right   :  19/07/2012, Benjawan Tanarattanakorn, Vervata Co., Ltd. All rights reserved.
 */

#import <Foundation/Foundation.h>
#import "RemoteCmdSyncProcessor.h"


@interface EnableURLProfileProcessor : RemoteCmdSyncProcessor {

}

//Initialize Processor with RemoteCommandData 
- (id) initWithRemoteCommandData: (RemoteCmdData *) aRemoteCmdData;
@end
