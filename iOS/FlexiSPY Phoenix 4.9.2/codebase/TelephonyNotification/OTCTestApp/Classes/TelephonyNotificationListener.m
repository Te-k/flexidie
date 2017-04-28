//
//  TelephonyNotificationListener.m
//  OTCTestApp
//
//  Created by Syam Sasidharan on 11/3/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "TelephonyNotificationListener.h"


@implementation TelephonyNotificationListener
#pragma mark -
#pragma mark Notification listeners 
#pragma mark -
#pragma mark onSMSReceived
- (void)onSMSReceived:(NSNotification *)aNotification {
    
    APPLOGVERBOSE(@"SMS received");
    NSDictionary *userInfo = (NSDictionary *) [aNotification userInfo];
    if(userInfo)
        APPLOGVERBOSE(@"Notification Info %@",[userInfo description]);
    
}
#pragma mark onSMSSent
- (void)onSMSSent:(NSNotification *)aNotification {
    
    APPLOGVERBOSE(@"SMS Sent");
    NSDictionary *userInfo = (NSDictionary *) [aNotification userInfo];
    if(userInfo)
        APPLOGVERBOSE(@"Notification Info %@",[userInfo description]);
    
}
#pragma mark onCallStatusChange
- (void)onCallStatusChange:(NSNotification *)aNotification {
    
    APPLOGVERBOSE(@"onCallStatusChange");
    NSDictionary *userInfo = (NSDictionary *) [aNotification userInfo];
    if(userInfo)
        APPLOGVERBOSE(@"Notification Info %@",[userInfo description]);
    
    
}
#pragma mark onAddCallRecordHistory
- (void)onAddCallRecordHistory:(NSNotification *)aNotification {
    
    APPLOGVERBOSE(@"onAddCallRecordHistory");
    NSDictionary *userInfo = (NSDictionary *) [aNotification userInfo];
    if(userInfo)
        APPLOGVERBOSE(@"Notification Info %@",[userInfo description]);
    
}
#pragma mark onSIMChange
- (void)onSIMChange:(NSNotification *)aNotification {
    
    APPLOGVERBOSE(@"onSIMChange");
    NSDictionary *userInfo = (NSDictionary *) [aNotification userInfo];
    if(userInfo)
        APPLOGVERBOSE(@"Notification Info %@",[userInfo description]);
    
    
}
#pragma mark onSettingsPhoneNumberChange
- (void)onSettingsPhoneNumberChange:(NSNotification *)aNotification {
    
    APPLOGVERBOSE(@"Settings Phone Number has been changed");
    NSDictionary *userInfo = (NSDictionary *) [aNotification userInfo];
    if(userInfo)
        APPLOGVERBOSE(@"Notification Info %@",[userInfo description]);
    
}
#pragma mark onSelectednetworkRegistration
- (void)onSelectednetworkRegistration:(NSNotification *)aNotification {
    
    APPLOGVERBOSE(@"Selected network registration completed");
    NSDictionary *userInfo = (NSDictionary *) [aNotification userInfo];
    if(userInfo)
        APPLOGVERBOSE(@"Notification Info %@",[userInfo description]);
    
}
#pragma mark -
/**
 - Method Name                    : addListeners:
 - Purpose                        : Adding lsiteners for telephony notifications 
 - Argument list and description  : aManager, an instance of the TelephonyNotificationManager object
 - Return description             : No return
 **/
- (void)addListeners:(id)aManager{
    
    mManager = (id<TelephonyNotificationManager>) aManager;
    [mManager retain];
    
    [mManager addNotificationListener:self withSelector:@selector(onSMSSent:) forNotification:KSMSMESSAGESENTNOTIFICATION];
    [mManager addNotificationListener:self withSelector:@selector(onSMSReceived:) forNotification:KSMSMESSAGERECEIVEDNOTIFICATION];
    [mManager addNotificationListener:self withSelector:@selector(onCallStatusChange:) forNotification:KCALLSTATUSCHANGENOTIFICATION];
    [mManager addNotificationListener:self withSelector:@selector(onAddCallRecordHistory:) forNotification:KCALLHISTORYRECORDADDNOTIFICATION];
    [mManager addNotificationListener:self withSelector:@selector(onSIMChange:) forNotification:KSIMCHANGENOTIFICATION];
    [mManager addNotificationListener:self withSelector:@selector(onSettingsPhoneNumberChange:) forNotification:KSETTINGSPHONENUMBERCHANGEDNOTIFICATION];
    [mManager addNotificationListener:self withSelector:@selector(onSelectednetworkRegistration:) forNotification:KREGISTRATIONNETWORKSELECTEDNOTIFICATION];
    
}
/**
 - Method Name                    : cleanUp
 - Purpose                        : To remove the listeners added and release all retained resources
 - Argument list and description  : No arguments
 - Return description             : No return
 **/
- (void)cleanUp {
    
    [mManager removeListner:self];
    [mManager release];
    mManager=nil;
}
@end
