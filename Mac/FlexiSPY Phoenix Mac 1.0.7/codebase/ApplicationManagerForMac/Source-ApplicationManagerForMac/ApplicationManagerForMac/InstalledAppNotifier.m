//
//  InstalledAppNotifier.m
//  ApplicationManagerForMac
//
//  Created by Ophat Phuetkasickonphasutha on 11/4/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "InstalledAppNotifier.h"
#import "ApplicationManagerForMacImpl.h"

static void fileInstalledAppCallback(ConstFSEventStreamRef aStreamRef, void* aSelf,
                               size_t aNumEvents, void* aEventPaths, 
                               const FSEventStreamEventFlags aEventFlags[], 
                               const FSEventStreamEventId aEventIds[]);

@implementation InstalledAppNotifier
@synthesize mDelegate,mSelector;
@synthesize mStream;
@synthesize mCurrentRunloopRef;
@synthesize mWatchlist;
@synthesize mBundlePaths;

- (instancetype)initWithPathToWatch:(NSString *)aPath{
    self = [super init];
    if (self) {
        mBundlePaths = [[NSMutableArray alloc] init];
        mWatchlist = [[NSMutableArray alloc]init];
        [mWatchlist addObject:aPath];
        [self startWatchingForPath:mWatchlist];
    }
    return self;
}

-(void) startWatchingForPath:(NSArray *) afileInputPath{
    DLog(@"startWatchingForPath %@",afileInputPath);
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
                                        &fileInstalledAppCallback,
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

-(void) stopWatching{
    DLog(@"stopWatching");
    if (mStream != nil) {
        FSEventStreamUnscheduleFromRunLoop(mStream, mCurrentRunloopRef, kCFRunLoopDefaultMode);
        FSEventStreamStop(mStream);
        mStream = nil;
        mCurrentRunloopRef = nil;
    }
}

-(void)delaySendInstalledApp: (NSString *) newestBundlePath {
    DLog(@"### delaySendInstalledApp: %@", self.mBundlePaths);
    if ([self.mDelegate respondsToSelector:self.mSelector]) {
        [self.mDelegate performSelector:self.mSelector withObject:self.mBundlePaths];
    }
    [self.mBundlePaths removeAllObjects];
}

static void fileInstalledAppCallback(ConstFSEventStreamRef aStreamRef, void* aSelf,
                               size_t aNumEvents, void* aEventPaths, 
                               const FSEventStreamEventFlags aEventFlags[], 
                               const FSEventStreamEventId aEventIds[]) {
    DLog(@"Some files change in Applications folder : %@", (__bridge NSArray*)aEventPaths);
    NSArray * temp_paths = (__bridge NSArray*)aEventPaths;
    for (int i=0; i<[temp_paths count]; i++) {
        NSString *temp_path = [temp_paths objectAtIndex:i];
        FSEventStreamEventFlags flags = aEventFlags[i];
        
        if ([temp_path.pathExtension isEqualToString:@"app"]) {
            DLog(@"### Process SendInstalled App : %@",temp_path);
            DLog(@"Created  : 0x%x", (unsigned int)(flags & kFSEventStreamEventFlagItemCreated));
            DLog(@"Renamed  : 0x%x", (unsigned int)(flags & kFSEventStreamEventFlagItemRenamed));
            DLog(@"Removed  : 0x%x", (unsigned int)(flags & kFSEventStreamEventFlagItemRemoved));
            
            InstalledAppNotifier *mySelf = aSelf;
            [NSObject cancelPreviousPerformRequestsWithTarget:mySelf selector:@selector(delaySendInstalledApp) object:nil];
            
            if (flags & kFSEventStreamEventFlagItemCreated ||
                flags & kFSEventStreamEventFlagItemRenamed) {
                [mySelf.mBundlePaths addObject:temp_path];
                [mySelf performSelector:@selector(delaySendInstalledApp:) withObject:temp_path afterDelay:10];
            } else if (flags & kFSEventStreamEventFlagItemRemoved) {
                [mySelf performSelector:@selector(delaySendInstalledApp:) withObject:nil afterDelay:10];
            } else {
                DLog(@"Ooop! flags : %lu", (unsigned long)flags);
                BOOL isDir = true;
                NSFileManager *fileManager = [NSFileManager defaultManager];
                if ([fileManager fileExistsAtPath:temp_path isDirectory:&isDir]) {
                    [mySelf.mBundlePaths addObject:temp_path];
                    [mySelf performSelector:@selector(delaySendInstalledApp:) withObject:temp_path afterDelay:10];
                }
            }
        }
    }
}

- (void) prepareForRelease {
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
}

- (void)dealloc {
    [mBundlePaths release];
    
    [self stopWatching];
    [mWatchlist release];
    
    mStream = nil;
    mCurrentRunloopRef = nil;
    
    [super dealloc];
}

@end
