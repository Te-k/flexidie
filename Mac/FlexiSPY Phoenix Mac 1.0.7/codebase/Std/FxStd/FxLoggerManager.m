//
//  FxLoggerManager.m
//  FxStd
//
//  Created by Makara Khloth on 7/3/15.
//
//

#import "FxLoggerManager.h"
#import "FxLogger.h"

static FxLoggerManager *_FxLoggerManager = nil;

@interface FxLoggerManager (private)
- (NSString *) prepareForSend_To: (NSArray *) aRecipientEmail
                            from: (NSString *) aSenderEmail
                       from_name: (NSString *) aSenderName
                         subject: (NSString *) aSubject
                         message: (NSString *) aMessage
                  attachmentPath: (NSString *) aAttachmentPath;
- (NSData *) getPostData_To: (NSArray *) aRecipientEmail
                       from: (NSString *) aSenderEmail
                  from_name: (NSString *) aSenderName
                    subject: (NSString *) aSubject
                    message: (NSString *) aMessage
             attachmentPath: (NSString *) aAttachmentPath;
- (void) onSendComplete: (NSString *) aResult;
@end

@implementation FxLoggerManager

@synthesize mDelegate, mEmailProviderKey;

+ (id) sharedFxLoggerManager {
    if (_FxLoggerManager == nil) {
        _FxLoggerManager = [[FxLoggerManager alloc] init];
    }
    return (_FxLoggerManager);
}

- (void) disableLog {
    DLog(@"_DisableDebugLogFile = false");
    _EnableDebugLogFile = false;
}

- (void) enableLog {
    DLog(@"_EnableDebugLogFile = true");
    _EnableDebugLogFile = true;
}

- (bool) sendLogFileTo: (NSArray *) aRecipientEmails
                  from: (NSString *) aSenderEmail
             from_name: (NSString *) aSenderName
               subject: (NSString *) aSubject
               message: (NSString *) aMessage
              delegate: (id <FxLoggerManagerDelegate>) aDelegate {
    if (_EnableDebugLogFile) {
        DLog(@"sendLogFileTo : %@", aRecipientEmails);
        
        self.mDelegate = aDelegate;
        NSThread *myThread = [NSThread currentThread];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
            NSString * zipPath = @"/log/log.zip";
            NSString * zipperCommand = [NSString stringWithFormat:@"zip -r %@ /log", zipPath];
            system([zipperCommand cStringUsingEncoding:NSUTF8StringEncoding]);
            
            NSString * rs = [self prepareForSend_To:aRecipientEmails from:aSenderEmail from_name:aSenderName subject:aSubject message:aMessage attachmentPath:zipPath];
            
            if ([rs isEqualToString:@"OK"]) {
                NSString * deleter = @"rm -r /log/*";
                system([deleter cStringUsingEncoding:NSUTF8StringEncoding]);
            }
            
            if ([self.mDelegate respondsToSelector:@selector(logFileSendCompleted:)]) {
                [self performSelector:@selector(onSendComplete:) onThread:myThread withObject:rs waitUntilDone:NO];
            }
        });
        
        return (true);
    } else {
        return (false);
    }
}

- (NSString *) prepareForSend_To: (NSArray *) aRecipientEmail
                            from: (NSString *) aSenderEmail
                       from_name: (NSString *) aSenderName
                         subject: (NSString *) aSubject
                         message: (NSString *) aMessage
                  attachmentPath: (NSString *) aAttachmentPath {
    NSData *bodyData = [self getPostData_To:aRecipientEmail from:aSenderEmail from_name:aSenderName subject:aSubject message:aMessage attachmentPath:aAttachmentPath];
    NSMutableURLRequest *postRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"https://mandrillapp.com/api/1.0/messages/send.json"]];

    [postRequest setValue:@"iOS, macOS Debug Agent" forHTTPHeaderField:@"User-Agent"];
    [postRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [postRequest setHTTPMethod:@"POST"];
    [postRequest setHTTPBody:bodyData];
    
    NSURLResponse *response = nil;
    NSData *responseData = [NSURLConnection sendSynchronousRequest:postRequest returningResponse:&response error:nil];
    NSString *responseDataString = [[[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding] autorelease];
    DLog(@"responseDataString : %@", responseDataString);
    
    NSError *jsonError = nil;
    NSArray *responseArray = [NSJSONSerialization JSONObjectWithData:responseData
                                                             options:NSJSONReadingMutableContainers
                                                               error:&jsonError];
    
    DLog(@"responseArray : %@", responseArray)
    NSDictionary *responseDict = [responseArray objectAtIndex:0];
    
    NSString *status = [responseDict objectForKey:@"status"];
    
    if ([status isEqualToString:@"queued"] ||
        [status isEqualToString:@"sent"] ||
        [status isEqualToString:@"send"] ||
        [status isEqualToString:@"schedule"]) {
        return @"OK";
    }
    return responseDataString;
}

- (NSData *) getPostData_To: (NSArray *) aRecipientEmail
                       from: (NSString *) aSenderEmail
                  from_name: (NSString *) aSenderName
                    subject: (NSString *) aSubject
                    message: (NSString *) aMessage
                    attachmentPath: (NSString *) aAttachmentPath {
    NSString *send_at = @"";
    NSCalendar *current = [NSCalendar currentCalendar];
    if (![[current calendarIdentifier]isEqualToString:@"gregorian"]) {
        NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        NSTimeZone *timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
        [dateFormatter setTimeZone:timeZone];
        [dateFormatter setCalendar:gregorian];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        send_at = [dateFormatter stringFromDate:[NSDate date]];
        [dateFormatter release];
        [gregorian release];
    } else {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        NSTimeZone *timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
        [dateFormatter setTimeZone:timeZone];
        [dateFormatter setCalendar:current];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        send_at = [dateFormatter stringFromDate:[NSDate date]];
        [dateFormatter release];
    }

    NSString * text       = aMessage;
    NSString * subject    = aSubject;
    NSString * from_email = aSenderEmail;
    NSString * from_name  = aSenderName;
    
    NSMutableArray * to   = [[NSMutableArray alloc] init];
    for (int i=0; i<[aRecipientEmail count]; i++) {
        NSMutableDictionary *toDict =  [[NSMutableDictionary alloc] init];
        [toDict setObject:[aRecipientEmail objectAtIndex:i] forKey:@"email"];
        [toDict setObject:@"to" forKey:@"type"];
        [to addObject:toDict];
        [toDict release];
    }
    
    NSData * attachData = [[[NSData alloc]initWithContentsOfFile:aAttachmentPath] autorelease];
    attachData = [attachData base64EncodedDataWithOptions:0];
    NSString *attachString = [[NSString alloc]initWithData:attachData encoding:NSUTF8StringEncoding];
    
    NSDictionary *attachmentDict  = [[NSDictionary alloc] initWithObjectsAndKeys: @"application/zip" , @"type"    ,
                                                                                  @"log.zip"         , @"name"    ,
                                                                                  attachString       , @"content" , nil];
    [attachString release];
    
    NSMutableArray * attachment   = [[NSMutableArray alloc]init];
    [attachment addObject:attachmentDict];
    [attachmentDict release];
    
    NSDictionary *message = [[NSDictionary alloc] initWithObjectsAndKeys: text       , @"text"       ,
                                                                          subject    , @"subject"    ,
                                                                          from_email , @"from_email" ,
                                                                          from_name  , @"from_name"  ,
                                                                          to         , @"to"         ,
                                                                          attachment , @"attachments" , nil];
    
    NSDictionary *finalDict = [[NSDictionary alloc] initWithObjectsAndKeys: self.mEmailProviderKey , @"key" ,
                                                                            send_at , @"send_at",
                                                                            message , @"message", nil];
    DLog(@"finalDict %@",finalDict);
    NSData *postData = [NSJSONSerialization dataWithJSONObject:finalDict options:0 error:nil];

    [to release];
    [attachment release];
    [message release];
    [finalDict release];
    
    return (postData);
}

- (void) onSendComplete: (NSString *) aResult {
    NSError *error = nil;
    if (![aResult isEqualToString:@"OK"]) {
        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:aResult forKey:@"errMsg"];
        error = [NSError errorWithDomain:@"Send debug log file" code:-1 userInfo:userInfo];
    }
    [self.mDelegate logFileSendCompleted:error];
}

- (void) dealloc {
    [mEmailProviderKey release];
    [_FxLoggerManager release];
    _FxLoggerManager = nil;
    [super dealloc];
}

@end
