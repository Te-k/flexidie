/**
 - Project Name  : TelephonyNotification
 - Class Name    : TelephonyNotificationManagerImpl.h
 - Version       : 1.0
 - Purpose       : Implementation of TelephonyNotificationManager and other required methods
 - Copy right    : 04/11/2011 , Syam Sasidharan, Vervata Co. Ltd. All rights reserved.
 **/

#import <Foundation/Foundation.h>
#import "TelephonyNotificationManager.h"

@class TelephonyNotificationManager;

@interface TelephonyNotificationManagerImpl : NSObject <TelephonyNotificationManager> {

@private 
    
    BOOL  mStartedListening;
	
}

- (id) init;
- (id) initAndStartListeningToTelephonyNotification;

- (void) startListeningToTelephonyNotifications;
- (void) stopListeningToTelephonyNotifications;

@end



