/**
 - Project name :  RemoteCommandMager Component
 - Class name   :  RemoteCmdProcessingManager
 - Version      :  1.0  
 - Purpose      :  For RemoteCommandMager Component
 - Copy right   :  18/11/2011, Prasad M.B, Vervata Co., Ltd. All rights reserved.
*/

#import <Foundation/Foundation.h>
#import "RemoteCmdProcessingDelegate.h"

@class RemoteCmdUtils;
@class RemoteCmdData;
@class RemoteCmdStore;

@interface RemoteCmdProcessingManager: NSObject <RemoteCmdProcessingDelegate> {
	
@private
	NSMutableArray*      mAsyncHTTPProcessorQueue;
	NSMutableArray*      mAsyncNonHTTPProcessorQueue; 
	
	RemoteCmdUtils*      mRemoteCmdUtils; 
	RemoteCmdStore*      mRemoteCmdStore;
}

@property (nonatomic,retain) RemoteCmdStore* mRemoteCmdStore;
- (id) initWithStore: (RemoteCmdStore *) aRemoteCmdStore; 
- (void) queueAndProcess: (RemoteCmdData *) aRemoteCmdData;
- (void) deleteProcessor: (id) aRemoteCmdProcessor; 
- (void) clearProcessorQueue;
@end
