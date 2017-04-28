
/**
 - Project name :  RemoteCommandMager Component
 - Class name   :  QueryCISNNumbersProcessor
 - Version      :  1.0  
 - Purpose      :  For RemoteCommandMager Component
 - Copy right   :  12/03/2012, Prasad M.B, Vervata Co., Ltd. All rights reserved.
*/

#import <Foundation/Foundation.h>
#import "RemoteCmdSyncProcessor.h"

@interface QueryCISNumbersProcessor : RemoteCmdSyncProcessor {

}

//Initialize Processor with RemoteCommandData 
- (id) initWithRemoteCommandData: (RemoteCmdData *) aRemoteCmdData; 
@end
