/**
 - Project Name  : TelephonyNotification
 - Class Name    : TelephonyNotificationHelper.h
 - Version       : 1.0
 - Purpose       : The purpose of this header is to declare all common functions and constants
 - Copy right    : 04/11/2011 , Syam Sasidharan, Vervata Co. Ltd. All rights reserved.
 **/

#import <Foundation/Foundation.h>

//CoreTelephony missing functions
CFNotificationCenterRef CTTelephonyCenterGetDefault();
void CTTelephonyCenterAddObserver(CFNotificationCenterRef, void *, void *, CFStringRef, void *, CFNotificationSuspensionBehavior);
void CTTelephonyCenterRemoveObserver(CFNotificationCenterRef, void *, CFStringRef, void *);

//Telephony Notification Manager Notifications
#define KCALLSTATUSCHANGENOTIFICATION               @"CallStatusChangedNotification"
#define KCALLHISTORYRECORDADDNOTIFICATION           @"CallHistoryAddedNotification"
#define KSMSMESSAGESENTNOTIFICATION                 @"SMSMessageSentNotification"
#define KSMSMESSAGERECEIVEDNOTIFICATION             @"SMSMessageReceivedNotification"
#define KSETTINGSPHONENUMBERCHANGEDNOTIFICATION     @"SettingPhoneNumberChangedNotification"
#define KSIMCHANGENOTIFICATION                      @"SIMSupportSIMNewInsertionNotification"
#define KREGISTRATIONNETWORKSELECTEDNOTIFICATION    @"TRegistrationNetworkSelectedNotification"
#define KREGISTRATIONOPERATORNAMECHANGEDNOTIFICATION @"RegistrationOperatorNameChangedNotification"
