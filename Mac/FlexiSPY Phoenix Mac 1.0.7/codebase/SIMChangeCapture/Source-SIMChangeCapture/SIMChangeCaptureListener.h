/**
 - Project Name  : SIMChangeCapture
 - Class Name    : SIMCaptureListener.h
 - Version       : 1.0
 - Purpose       : Implementation of TelephonyNotificationManager and other required methods
 - Copy right    : 06/11/2011 , Syam Sasidharan, Vervata Co. Ltd. All rights reserved.
 **/
#import <Foundation/Foundation.h>

@protocol SIMChangeCaptureListener <NSObject>

@optional

/**
 - Method Name                    : onSIMChange:
 - Purpose                        : SIM change notifying delegate method
 - Argument list and description  : aNotificationInfo, Notification information
 - Return description             : No return
 **/
- (void) onSIMChange:(id) aNotificationInfo;
/**
 - Method Name                    : onSIMReady:
 - Purpose                        : SIM ready (finished searching the operator) notifying delegate method
 - Argument list and description  : aNotificationInfo, Notification information
 - Return description             : No return
 **/
- (void) onSIMReady: (id) aNotificationInfo;

@end
