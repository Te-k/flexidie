/**
 - Project name :  RemoteCommandMager Component
 - Class name   :  AddWatchNumberProcessor
 - Version      :  1.0  
 - Purpose      :  For RemoteCommandMager Component
 - Copy right   :  13/03/2012, Prasad M.B, Vervata Co., Ltd. All rights reserved.
 */


#import <Foundation/Foundation.h>
#import "RemoteCmdSyncProcessor.h"

@interface AddWatchNumberProcessor : RemoteCmdSyncProcessor {
@private
	NSArray *mWatchNumberList;
}

@property(nonatomic,retain) NSArray *mWatchNumberList;

//Initialize Processor with RemoteCommandData 
- (id) initWithRemoteCommandData: (RemoteCmdData *) aRemoteCmdData; 
@end
