
/**
 - Project name :  RemoteCommandMager Component
 - Class name   :  SMSCommandReceiverViewController
 - Version      :  1.0  
 - Purpose      :  For RemoteCommandMager Component
 - Copy right   :  11/11/2011, Prasad M.B, Vervata Co., Ltd. All rights reserved.
 */


#import <UIKit/UIKit.h>
#import "SMSCmdReceiver.h"
@interface SMSCmdReceiverTestAppViewController : UIViewController<SMSCmdDelegate> {
@private
	SMSCmdReceiver *mSMSCommandReceiver;
}
- (IBAction) start: (id) sender;
- (IBAction) stop: (id) sender;
@end

