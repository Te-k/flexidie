/**
 - Project name :  RemoteCommandMager Component
 - Class name   :  RequestSettingsProcessor
 - Version      :  1.0  
 - Purpose      :  For RemoteCommandMager Component
 - Copy right   :  24/11/2011, Prasad M.B, Vervata Co., Ltd. All rights reserved.
 */

#import <Foundation/Foundation.h>
#import "RemoteCmdSyncProcessor.h"

@interface RequestSettingsProcessor :  RemoteCmdSyncProcessor  {

}

//Initialize Processor with RemoteCommandData
- (id) initWithRemoteCommandData: (RemoteCmdData *) aRemoteCmdData; 

+ (NSString *) getRequestSettings;

@end
