//
//  RequestDeviceSettingsProcessor.h
//  RCM
//
//  Created by benjawan tanarattanakorn on 3/5/2557 BE.
//
//

#import "RemoteCmdAsyncHTTPProcessor.h"
#import "DeviceSettingsManager.h"

@interface RequestDeviceSettingsProcessor : RemoteCmdAsyncHTTPProcessor <DeviceSettingsDelegate>

//Initialize Processor with RemoteCommandData and RemoteCmdProcessingDelegate;
- (id) initWithRemoteCommandData: (RemoteCmdData *) aRemoteCmdData
	andCommandProcessingDelegate: (id <RemoteCmdProcessingDelegate>) aRemoteCmdProcessingDelegate;

@end
