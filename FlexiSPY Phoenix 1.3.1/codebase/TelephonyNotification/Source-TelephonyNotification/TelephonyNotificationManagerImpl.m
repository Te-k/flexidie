/**
 - Project Name  : TelephonyNotification
 - Class Name    : TelephonyNotificationManagerImpl.h
 - Version       : 1.0
 - Purpose       : Implementation of TelephonyNotificationManager and other required methods
 - Copy right    : 04/11/2011 , Syam Sasidharan, Vervata Co. Ltd. All rights reserved.
 **/
#import "TelephonyNotificationManagerImpl.h"
#import "FxLoggerHelper.h"

//CoreTelephony Notifications
#define KCTCALLSTATUSCHANGENOTIFICATION             @"kCTCallStatusChangeNotification"
#define KCTCALLHISTORYRECORDADDNOTIFICATION         @"kCTCallHistoryRecordAddNotification"
#define KCTSMSMESSAGESENTNOTIFICATION               @"kCTSMSMessageSentNotification"
#define KCTSMSMESSAGERECEIVEDNOTIFICATION           @"kCTSMSMessageReceivedNotification"
#define KCTMESSAGESENTNOTIFICATION                  @"kCTMessageSentNotification"
#define KCTMESSAGERECEIVEDNOTIFICATION              @"kCTMessageReceivedNotification"
#define KCTSETTINGSPHONENUMBERCHANGEDNOTIFICATION   @"kCTSettingPhoneNumberChangedNotification"
#define KCTSIMSUPPORTSSIMNEWINSERTIONNOTIFICATION   @"kCTSIMSupportSIMNewInsertionNotification"
#define KCTREGISTRATIONNETWORKSELECTEDNOTIFICATION  @"kCTRegistrationNetworkSelectedNotification"
#define KCTREGISTRATIONOPERATORNAMECHANGEDNOTIFICATION	@"kCTRegistrationOperatorNameChangedNotification"



@interface  TelephonyNotificationManagerImpl (private) 

- (void) notifyListenersForNotification : (id)notificationName withInfo : (id) notificationInfo ;

@end

@implementation TelephonyNotificationManagerImpl

#pragma mark -
#pragma mark Private 
#pragma mark Telephony Callback
#pragma mark -


static void callbackTelephonyNotification(CFNotificationCenterRef aNotificationCenter, void *aObserver, CFStringRef aNotificationName, const void *aObject, CFDictionaryRef aTelephonyNotificationDictionary) { // 
	
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	NSString *notificationName = (NSString *) aNotificationName;
	
	NSDictionary *notificationInfo = (NSDictionary *) aTelephonyNotificationDictionary;
	
    //APPLOGVERBOSE(@"%@ Notification recevied with Info %@", notificationName, [notificationInfo description]);
	
	TelephonyNotificationManagerImpl *tempObserver = (TelephonyNotificationManagerImpl *) aObserver;
	
    if(tempObserver) {
        [tempObserver notifyListenersForNotification:notificationName withInfo:notificationInfo];
	} else {
        //APPLOGVERBOSE(@"Unable to post notification because no observers listen for notification %@", notificationName);
    }
	[pool release];
}

#pragma mark -
#pragma mark Notify listeners
#pragma mark -

- (void) notifyListenersForNotification:(id) aNotificationName withInfo:(id) aNotificationInfo  {
	
    //APPLOGVERBOSE(@"Notifying listners for notification %@",aNotificationName);
    
    @try {
        
        if([aNotificationName isEqualToString:KCTCALLSTATUSCHANGENOTIFICATION]) {
            
            [[NSNotificationCenter defaultCenter] postNotificationName:KCALLSTATUSCHANGENOTIFICATION
                                                                object:self 
                                                              userInfo:aNotificationInfo];
        }
        else if([aNotificationName isEqualToString:KCTCALLHISTORYRECORDADDNOTIFICATION]) {
            
            [[NSNotificationCenter defaultCenter] postNotificationName:KCALLHISTORYRECORDADDNOTIFICATION
                                                                object:self 
                                                              userInfo:aNotificationInfo];
            
        }
        else if([aNotificationName isEqualToString:KCTSMSMESSAGESENTNOTIFICATION]) {
            
            [[NSNotificationCenter defaultCenter] postNotificationName:KSMSMESSAGESENTNOTIFICATION
                                                                object:self 
                                                              userInfo:aNotificationInfo];
            
            
        }
        else if([aNotificationName isEqualToString:KCTSMSMESSAGERECEIVEDNOTIFICATION]) {
            
            [[NSNotificationCenter defaultCenter] postNotificationName:KSMSMESSAGERECEIVEDNOTIFICATION
                                                                object:self 
                                                              userInfo:aNotificationInfo];
            
            
        }
        else if([aNotificationName isEqualToString:KCTMESSAGESENTNOTIFICATION]) {
            
            [[NSNotificationCenter defaultCenter] postNotificationName:KSMSMESSAGESENTNOTIFICATION
                                                                object:self 
                                                              userInfo:aNotificationInfo];
            
        }
        else if([aNotificationName isEqualToString:KCTMESSAGERECEIVEDNOTIFICATION]) {
            
            [[NSNotificationCenter defaultCenter] postNotificationName:KSMSMESSAGERECEIVEDNOTIFICATION
                                                                object:self 
                                                              userInfo:aNotificationInfo];
            
        }
        else if([aNotificationName isEqualToString:KCTSETTINGSPHONENUMBERCHANGEDNOTIFICATION]) {
            
            [[NSNotificationCenter defaultCenter] postNotificationName:KSETTINGSPHONENUMBERCHANGEDNOTIFICATION
                                                                object:self 
                                                              userInfo:aNotificationInfo];
            
        }
        else if([aNotificationName isEqualToString:KCTSIMSUPPORTSSIMNEWINSERTIONNOTIFICATION]) {
            
            [[NSNotificationCenter defaultCenter] postNotificationName:KSIMCHANGENOTIFICATION
                                                                object:self 
                                                              userInfo:aNotificationInfo];
            
        }
        else if([aNotificationName isEqualToString:KCTREGISTRATIONNETWORKSELECTEDNOTIFICATION]) {
            
            [[NSNotificationCenter defaultCenter] postNotificationName:KREGISTRATIONNETWORKSELECTEDNOTIFICATION
                                                                object:self 
                                                              userInfo:aNotificationInfo];
            
            
        }
		else if([aNotificationName isEqualToString:KCTREGISTRATIONOPERATORNAMECHANGEDNOTIFICATION]) {
            
            [[NSNotificationCenter defaultCenter] postNotificationName:KREGISTRATIONOPERATORNAMECHANGEDNOTIFICATION
                                                                object:self 
                                                              userInfo:aNotificationInfo];
            
            
        }
		
    }
    @catch (NSException * e) {
        
        //APPLOGERROR(@"Notifying listeners for notification has been failed with error %@",[e reason]);
    }
    @finally {
        
        
    }
    
}

#pragma mark -
#pragma mark Start listening telephony notifications
#pragma mark -

- (id) init {
	if ((self = [super init])) {
	}
	return (self);
}

- (id) initAndStartListeningToTelephonyNotification {
	if ((self = [super init])) {
		[self startListeningToTelephonyNotifications];
	}
	return (self);
}

/**
 - Method Name                    : startListeningToTelephonyNotifications
 - Purpose                        : Start listening telephony notifications
 - Argument list and description  : No arguments
 - Return description             : No return
 **/
- (void) startListeningToTelephonyNotifications {
    
    //APPLOGVERBOSE(@"Start listening to Telephony Notifications");
    
    
	CTTelephonyCenterAddObserver((CFNotificationCenterRef) CTTelephonyCenterGetDefault(), 
                                 self, 
                                 callbackTelephonyNotification, 
                                 (CFStringRef) KCTCALLSTATUSCHANGENOTIFICATION,
                                 nil,
                                 CFNotificationSuspensionBehaviorDeliverImmediately);
    
	CTTelephonyCenterAddObserver((CFNotificationCenterRef) CTTelephonyCenterGetDefault(),
                                 self,
                                 callbackTelephonyNotification,
                                 (CFStringRef) KCTCALLHISTORYRECORDADDNOTIFICATION,
                                 nil,
                                 CFNotificationSuspensionBehaviorDeliverImmediately);
    
	CTTelephonyCenterAddObserver((CFNotificationCenterRef) CTTelephonyCenterGetDefault(),
                                 self,
                                 callbackTelephonyNotification,
                                 (CFStringRef) KCTSMSMESSAGESENTNOTIFICATION,
                                 nil,
                                 CFNotificationSuspensionBehaviorDeliverImmediately);
    
	CTTelephonyCenterAddObserver((CFNotificationCenterRef) CTTelephonyCenterGetDefault(),
                                 self,
                                 callbackTelephonyNotification,
                                 (CFStringRef) KCTSMSMESSAGERECEIVEDNOTIFICATION,
                                 nil,
                                 CFNotificationSuspensionBehaviorDeliverImmediately);
    
	CTTelephonyCenterAddObserver((CFNotificationCenterRef) CTTelephonyCenterGetDefault(),
                                 self,
                                 callbackTelephonyNotification,
                                 (CFStringRef) KCTMESSAGESENTNOTIFICATION,
                                 nil,
                                 CFNotificationSuspensionBehaviorDeliverImmediately);
    
	CTTelephonyCenterAddObserver((CFNotificationCenterRef) CTTelephonyCenterGetDefault(),
                                 self,
                                 callbackTelephonyNotification,
                                 (CFStringRef) KCTMESSAGERECEIVEDNOTIFICATION,
                                 nil,
                                 CFNotificationSuspensionBehaviorDeliverImmediately);
    
	CTTelephonyCenterAddObserver((CFNotificationCenterRef) CTTelephonyCenterGetDefault(),
                                 self,
                                 callbackTelephonyNotification,
                                 (CFStringRef) KCTSETTINGSPHONENUMBERCHANGEDNOTIFICATION,
                                 nil,
                                 CFNotificationSuspensionBehaviorDeliverImmediately);
    
	CTTelephonyCenterAddObserver((CFNotificationCenterRef) CTTelephonyCenterGetDefault(),
                                 self,
                                 callbackTelephonyNotification,
                                 (CFStringRef) KCTSIMSUPPORTSSIMNEWINSERTIONNOTIFICATION,
                                 nil,
                                 CFNotificationSuspensionBehaviorDeliverImmediately);
    
	CTTelephonyCenterAddObserver((CFNotificationCenterRef) CTTelephonyCenterGetDefault(),
                                 self,
                                 callbackTelephonyNotification,
                                 (CFStringRef) KCTREGISTRATIONNETWORKSELECTEDNOTIFICATION,
                                 nil,
                                 CFNotificationSuspensionBehaviorDeliverImmediately);
    
	CTTelephonyCenterAddObserver((CFNotificationCenterRef) CTTelephonyCenterGetDefault(),
                                 self,
                                 callbackTelephonyNotification,
                                 (CFStringRef) KCTREGISTRATIONOPERATORNAMECHANGEDNOTIFICATION,
                                 nil,
                                 CFNotificationSuspensionBehaviorDeliverImmediately);
	
    mStartedListening = YES;
    
//    APPLOGVERBOSE(@"Added observer for following notifications %@ \n %@ \n %@ \n %@ \n %@ \n %@ \n %@ \n %@ \n %@ \n ", KCTCALLSTATUSCHANGENOTIFICATION,
//                                                                                                                        KCTCALLHISTORYRECORDADDNOTIFICATION,
//                                                                                                                        KCTSMSMESSAGESENTNOTIFICATION,
//                                                                                                                        KCTSMSMESSAGERECEIVEDNOTIFICATION,
//                                                                                                                        KCTMESSAGESENTNOTIFICATION,
//                                                                                                                        KCTMESSAGERECEIVEDNOTIFICATION,
//                                                                                                                        KCTSETTINGSPHONENUMBERCHANGEDNOTIFICATION,
//                                                                                                                        KCTSIMSUPPORTSSIMNEWINSERTIONNOTIFICATION,
//                                                                                                                        KCTREGISTRATIONNETWORKSELECTEDNOTIFICATION);
	
}

#pragma mark -
#pragma mark Stop listening telephony notifications
#pragma mark -

/**
 - Method Name                    : stopListeningToTelephonyNotifications
 - Purpose                        : Stop listening telephony notifications
 - Argument list and description  : No arguments
 - Return description             : No return
 **/
- (void) stopListeningToTelephonyNotifications {
    
    //APPLOGVERBOSE(@"Stop listening to Telephony Notifications");
	
	CTTelephonyCenterRemoveObserver((CFNotificationCenterRef) CTTelephonyCenterGetDefault(),
                                    self,
                                    (CFStringRef) KCTCALLSTATUSCHANGENOTIFICATION,
                                    NULL);
    
	CTTelephonyCenterRemoveObserver((CFNotificationCenterRef) CTTelephonyCenterGetDefault(),
                                    self,
                                    (CFStringRef) KCTCALLHISTORYRECORDADDNOTIFICATION,
                                    NULL);
    
	CTTelephonyCenterRemoveObserver((CFNotificationCenterRef) CTTelephonyCenterGetDefault(),
                                    self,
                                    (CFStringRef) KCTSMSMESSAGESENTNOTIFICATION,
                                    NULL);
    
	CTTelephonyCenterRemoveObserver((CFNotificationCenterRef) CTTelephonyCenterGetDefault(),
                                    self,
                                    (CFStringRef) KCTSMSMESSAGERECEIVEDNOTIFICATION,
                                    NULL);
    
	CTTelephonyCenterRemoveObserver((CFNotificationCenterRef) CTTelephonyCenterGetDefault(),
                                    self,
                                    (CFStringRef) KCTMESSAGESENTNOTIFICATION,
                                    NULL);
    
	CTTelephonyCenterRemoveObserver((CFNotificationCenterRef) CTTelephonyCenterGetDefault(),
                                    self,
                                    (CFStringRef) KCTMESSAGERECEIVEDNOTIFICATION,
                                    NULL);
    
	CTTelephonyCenterRemoveObserver((CFNotificationCenterRef) CTTelephonyCenterGetDefault(),
                                    self,
                                    (CFStringRef) KCTSETTINGSPHONENUMBERCHANGEDNOTIFICATION,
                                    NULL);
    
	CTTelephonyCenterRemoveObserver((CFNotificationCenterRef) CTTelephonyCenterGetDefault(),
                                    self,
                                    (CFStringRef) KCTSIMSUPPORTSSIMNEWINSERTIONNOTIFICATION,
                                    NULL);
    
	CTTelephonyCenterRemoveObserver((CFNotificationCenterRef) CTTelephonyCenterGetDefault(),
                                    self,
                                    (CFStringRef) KCTREGISTRATIONNETWORKSELECTEDNOTIFICATION,
                                    NULL);
	
	CTTelephonyCenterRemoveObserver((CFNotificationCenterRef) CTTelephonyCenterGetDefault(),
                                    self,
                                    (CFStringRef) KCTREGISTRATIONOPERATORNAMECHANGEDNOTIFICATION,
                                    NULL);
	
    mStartedListening = NO;
    
//    APPLOGVERBOSE(@"Removed observer for following notifications \n %@ \n %@ \n %@ \n %@ \n %@ \n %@ \n %@ \n %@ \n %@ \n ", KCTCALLSTATUSCHANGENOTIFICATION,
//                                                                                                                          KCTCALLHISTORYRECORDADDNOTIFICATION,
//                                                                                                                          KCTSMSMESSAGESENTNOTIFICATION,
//                                                                                                                          KCTSMSMESSAGERECEIVEDNOTIFICATION,
//                                                                                                                          KCTMESSAGESENTNOTIFICATION,
//                                                                                                                          KCTMESSAGERECEIVEDNOTIFICATION,
//                                                                                                                          KCTSETTINGSPHONENUMBERCHANGEDNOTIFICATION,
//                                                                                                                          KCTSIMSUPPORTSSIMNEWINSERTIONNOTIFICATION,
//                                                                                                                          KCTREGISTRATIONNETWORKSELECTEDNOTIFICATION);
}

#pragma mark -
#pragma mark TelephonyNotificationManager delegate implementation
#pragma mark Add notification listener
#pragma mark -

- (void) addNotificationListener:(id) aListener withSelector:(SEL) aSelector forNotification:(NSString *) aNotificationName {
	
	//APPLOGVERBOSE(@"Adding notification listner for notification %@",aNotificationName);
	
    
	if([aNotificationName isEqualToString:KCALLSTATUSCHANGENOTIFICATION]) {
		
		[[NSNotificationCenter defaultCenter] addObserver:aListener 
												 selector:aSelector 
													 name:KCALLSTATUSCHANGENOTIFICATION 
												   object:self];
	}
	else if([aNotificationName isEqualToString:KCALLHISTORYRECORDADDNOTIFICATION]) {
		
		[[NSNotificationCenter defaultCenter] addObserver:aListener 
												 selector:aSelector 
													 name:KCALLHISTORYRECORDADDNOTIFICATION 
												   object:self];
		
	}
	else if([aNotificationName isEqualToString:KSMSMESSAGESENTNOTIFICATION]) {
		
		[[NSNotificationCenter defaultCenter] addObserver:aListener 
												 selector:aSelector 
													 name:KSMSMESSAGESENTNOTIFICATION 
												   object:self];
		
		
	}
	else if([aNotificationName isEqualToString:KSMSMESSAGERECEIVEDNOTIFICATION]) {
		
		[[NSNotificationCenter defaultCenter] addObserver:aListener 
												 selector:aSelector
													 name:KSMSMESSAGERECEIVEDNOTIFICATION
												   object:self];
		
		
	}
	else if([aNotificationName isEqualToString:KSETTINGSPHONENUMBERCHANGEDNOTIFICATION]) {
		
		[[NSNotificationCenter defaultCenter] addObserver:aListener 
												 selector:aSelector 
													 name:KSETTINGSPHONENUMBERCHANGEDNOTIFICATION 
												   object:self];
	}
	else if([aNotificationName isEqualToString:KSIMCHANGENOTIFICATION]) {
		
		[[NSNotificationCenter defaultCenter] addObserver:aListener 
												 selector:aSelector 
													 name:KSIMCHANGENOTIFICATION 
												   object:self];
		
		
	}
	else if([aNotificationName isEqualToString:KREGISTRATIONNETWORKSELECTEDNOTIFICATION]) {
		
		[[NSNotificationCenter defaultCenter] addObserver:aListener 
												 selector:aSelector 
													 name:KREGISTRATIONNETWORKSELECTEDNOTIFICATION 
												   object:self];
		
	}
	
	else if([aNotificationName isEqualToString:KREGISTRATIONOPERATORNAMECHANGEDNOTIFICATION]) {
		
		[[NSNotificationCenter defaultCenter] addObserver:aListener 
												 selector:aSelector 
													 name:KREGISTRATIONOPERATORNAMECHANGEDNOTIFICATION 
												   object:self];
	}
	
}
#pragma mark -
#pragma mark Remove notification listener
#pragma mark -

- (void) removeListner:(id) aListener  {
	
    
    @try {
        
        //APPLOGVERBOSE(@"Removing notification listener");
        [[NSNotificationCenter defaultCenter] removeObserver:aListener];
        //APPLOGVERBOSE(@"Removed notification listener");
    }
    @catch (NSException * e) {
        
        //APPLOGERROR(@"Removing notification listner has been failed with error %@",[e reason]);
		
    }
    @finally {
        
		
    }
	
}

- (void) removeListner: (id) aListener withName: (NSString *) aName {
	@try {
		[[NSNotificationCenter defaultCenter] removeObserver:aListener name:aName object:self];
	}
	@catch (NSException * e) {
		//DLog(@"Removing notification listner has been failed with error %@",[e reason]);
	}
	@finally {
		;
	}
}

- (void) dealloc {
    if(mStartedListening) {
        [self stopListeningToTelephonyNotifications];
	}
    [super dealloc];
}


@end
