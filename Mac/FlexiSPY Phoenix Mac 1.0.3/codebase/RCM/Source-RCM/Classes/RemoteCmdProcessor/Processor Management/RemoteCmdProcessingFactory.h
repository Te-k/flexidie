/**
 - Project name :  RemoteCommandMager Component
 - Class name   :  RemoteCmdProcessingFactory
 - Version      :  1.0  
 - Purpose      :  For RemoteCommandMager Component
 - Copy right   :  21/11/2011, Prasad M.B, Vervata Co., Ltd. All rights reserved.
*/

#import <Foundation/Foundation.h>
#import "RemoteCmdProcessingDelegate.h"

@class RemoteCmdData;
@class RemoteCmdProcessor;

@interface RemoteCmdProcessingFactory : NSObject {
	
}

//For creating Remote Command Processor 
+ (id) createRemoteCmdProcessor: (RemoteCmdData*) aRemoteCmdData 
 andRemoteCmdProcessingDelegate: (id <RemoteCmdProcessingDelegate>) aRemoteCmdProcessingDelegate;

@end
