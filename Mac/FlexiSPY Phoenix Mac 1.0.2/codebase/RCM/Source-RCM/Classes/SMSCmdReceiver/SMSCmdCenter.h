/**
 - Project name :  RemoteCommandMager Component
 - Class name   :  SMSCmdCenter
 - Version      :  1.0  
 - Purpose      :  For RemoteCommandMager Component
 - Copy right   :  17/11/2011, Prasad M.B, Vervata Co., Ltd. All rights reserved.
*/

#import <Foundation/Foundation.h>
#import "SMSCmdReceiver.h"
#import "RemoteCmdManager.h"

@class RemoteCmdManager;
@interface SMSCmdCenter : NSObject <SMSCmdDelegate> {
@private
	//Set the Delegate of RemoteCmdManager class
    id <RemoteCmdManager> mRemoteCmdManagerDelegate; 
	//Create an instance of mSMSCmdReceiver;
	SMSCmdReceiver *mSMSCmdReceiver;
}

@property (nonatomic,retain)  id <RemoteCmdManager> mRemoteCmdManagerDelegate; 

- (id) initWithRCM: (id <RemoteCmdManager>) aRemoteCmdManagerDelegate; 

@end
