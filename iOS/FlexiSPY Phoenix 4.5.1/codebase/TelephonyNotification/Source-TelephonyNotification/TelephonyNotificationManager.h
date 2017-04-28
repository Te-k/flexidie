/**
 - Project Name  : TelephonyNotification
 - Class Name    : TelephonyNotificationManager.h
 - Version       : 1.0
 - Purpose       : The purpose of this header is to declare TelephonyNotificationManager delegate protocol methods.
 - Copy right    : 04/11/2011 , Syam Sasidharan, Vervata Co. Ltd. All rights reserved.
 **/
#import <Foundation/Foundation.h>
#import "TelephonyNotificationHelper.h"

@protocol TelephonyNotificationManager <NSObject>

@optional

/**
 - Method Name                    : addNotificationListener:withSelector:forNotification:
 - Purpose                        : To add a listner for a particular notification
 - Argument list and description  : aListener, an instance of the listner object
                                    aSelector, a method pointer, which need to be invoked when corresponding notification get posted
                                    aNotificationName, a notification name , to which the listener is listener is listen for
 - Return description             : No return
 **/
- (void) addNotificationListener:(id) aListener withSelector:(SEL) aSelector forNotification:(NSString *) aNotificationName;
/**
 - Method Name                    : removeListner:
 - Purpose                        : To remove the listener added 
 - Argument list and description  : aListener, an instance of the listner object
 - Return description             : No return
 **/
- (void) removeListner:(id) aListener;

- (void) removeListner: (id) aListener withName: (NSString *) aName;

@end

