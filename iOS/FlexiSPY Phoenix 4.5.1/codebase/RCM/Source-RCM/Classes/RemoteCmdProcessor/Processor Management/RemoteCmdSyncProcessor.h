/**
 - Project name :  RemoteCommandMager Component
 - Class name   :  RemoteCmdSyncProcessor
 - Version      :  1.0  
 - Purpose      :  For RemoteCommandMager Component
 - Copy right   :  21/11/2011, Prasad M.B, Vervata Co., Ltd. All rights reserved.
 */

#import <Foundation/Foundation.h>
#import "RemoteCmdProcessor.h"

@interface RemoteCmdSyncProcessor : NSObject <RemoteCmdProcessor> {
@protected
	RemoteCmdData*                     mRemoteCmdData;
}
- (id) initWithRemoteCommandData: (RemoteCmdData *) aRemoteCmdData;
- (RemoteCmdData *) remoteCmdData;
- (NSString *) recipientNumber ;
- (NSString *) remoteCmdCode;
- (NSUInteger) remoteCmdUID;

@end
