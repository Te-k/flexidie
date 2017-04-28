/**
 - Project name :  RemoteCommandMager Component
 - Class name   :  RemoteCmdAsyncHTTPProcessor
 - Version      :  1.0  
 - Purpose      :  For RemoteCommandMager Component
 - Copy right   :  21/11/2011, Prasad M.B, Vervata Co., Ltd. All rights reserved.
*/

#import <Foundation/Foundation.h>
#import "RemoteCmdProcessor.h"

@interface RemoteCmdAsyncHTTPProcessor : NSObject <RemoteCmdProcessor> {
@protected
	id <RemoteCmdProcessingDelegate>   mRemoteCmdProcessingDelegate;
	//Instance of RemoteCommandData
	RemoteCmdData*                     mRemoteCmdData;
	
}
- (id) initWithRemoteCommandData: (RemoteCmdData *) aRemoteCmdData 
      andCommandProcessingDelegate: (id <RemoteCmdProcessingDelegate>) aRemoteCmdProcessingDelegate;

- (RemoteCmdData *) remoteCmdData; 
- (NSString *) remoteCmdCode;
- (NSUInteger) remoteCmdUID;
- (NSString *) recipientNumber; 

@end
