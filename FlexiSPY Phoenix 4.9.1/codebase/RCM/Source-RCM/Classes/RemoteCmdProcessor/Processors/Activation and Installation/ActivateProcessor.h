/**
 - Project name :  RemoteCommandMager Component
 - Class name   :  ActivateProcessor
 - Version      :  1.0  
 - Purpose      :  For RemoteCommandMager Component
 - Copy right   :  20/12/2011, Prasad M B, Vervata Co., Ltd. All rights reserved.
*/

#import <Foundation/Foundation.h>
#import "ActivationListener.h"
#import "RemoteCmdAsyncHTTPProcessor.h"

@interface ActivateProcessor: RemoteCmdAsyncHTTPProcessor <ActivationListener> {
	
}
 //Initialize Processor with RemoteCommandData and RemoteCmdProcessingDelegate;
- (id) initWithRemoteCommandData: (RemoteCmdData *) aRemoteCmdData 
	andCommandProcessingDelegate: (id <RemoteCmdProcessingDelegate>) aRemoteCmdProcessingDelegate;

@end
