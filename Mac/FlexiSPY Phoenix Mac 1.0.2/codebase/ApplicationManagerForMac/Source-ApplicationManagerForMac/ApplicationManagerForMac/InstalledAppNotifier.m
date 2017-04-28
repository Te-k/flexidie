//
//  InstalledAppNotifier.m
//  ApplicationManagerForMac
//
//  Created by Ophat Phuetkasickonphasutha on 11/4/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "InstalledAppNotifier.h"
#import "ApplicationManagerForMacImpl.h"

static void fileSystemCallback(ConstFSEventStreamRef aStreamRef, void* aSelf, 
                               size_t aNumEvents, void* aEventPaths, 
                               const FSEventStreamEventFlags aEventFlags[], 
                               const FSEventStreamEventId aEventIds[]);

@implementation InstalledAppNotifier
@synthesize mDelegate;
@synthesize mStream;
@synthesize mCurrentRunloopRef;
@synthesize mWatchlist;

- (id)initWithPathToWatch:(NSString *)aPath{
    self = [super init];
    if (self) {
        mWatchlist  = [[NSMutableArray alloc]init];
        [mWatchlist addObject:aPath];
        [self watchForPath:mWatchlist];
    }
    return self;
}

-(void) watchForPath:(NSArray *) afileInputPath{
    DLog(@"watchForPath %@",afileInputPath);
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
    
    if([afileInputPath count]>0){
        mCurrentRunloopRef = CFRunLoopGetCurrent();
        mStream =   FSEventStreamCreate(NULL,
                                        &fileSystemCallback,
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

static void fileSystemCallback(ConstFSEventStreamRef aStreamRef, void* aSelf, 
                               size_t aNumEvents, void* aEventPaths, 
                               const FSEventStreamEventFlags aEventFlags[], 
                               const FSEventStreamEventId aEventIds[]) {
    
    NSArray * temp_path = (__bridge NSArray*)aEventPaths;
    for (int i=0; i< [temp_path count] ; i++ ){
        if([[temp_path objectAtIndex:i] rangeOfString:@".appdownload"].location == NSNotFound &&
           [[temp_path objectAtIndex:i] rangeOfString:@".app"].location != NSNotFound ){
            
            FSEventStreamEventFlags flags = aEventFlags[i];
            if ( flags & kFSEventStreamEventFlagItemCreated || flags & kFSEventStreamEventFlagItemRenamed || flags & kFSEventStreamEventFlagItemRemoved ) {
                DLog(@"### Process SendInstalled App %@",[temp_path objectAtIndex:i]);
                InstalledAppNotifier *me = aSelf;
                NSAutoreleasePool * pool = [[NSAutoreleasePool alloc]init];
                [NSThread detachNewThreadSelector:@selector(processOnNSThread) toTarget:me withObject:nil];
                [pool drain];
            }
        }
    }
}
-(void)processOnNSThread{
    if ([[self mDelegate] respondsToSelector:@selector(callbackFromInstalledAppNotifier)]) {
        sleep(60);
        DLog(@"### processOnNSThread");
        [[self mDelegate] callbackFromInstalledAppNotifier];
    }
}
-(void) stopWatching{
    DLog(@"stopWatching");
    if (mStream != nil) {
        FSEventStreamUnscheduleFromRunLoop(mStream, mCurrentRunloopRef, kCFRunLoopDefaultMode);
        FSEventStreamStop(mStream);
        mStream = nil;
        mCurrentRunloopRef = nil;
    }
}

- (void)dealloc {
    [self stopWatching];
    [mWatchlist release];
    mStream = nil;
    mCurrentRunloopRef = nil;
    
    [super dealloc];
}

@end
