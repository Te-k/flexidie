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

- (id)initWithPathToWatch:(NSString *)aPath{
    self = [super init];
    if (self) {
        // Initialization code here.
        [self watchForPath:aPath];
    }
    return self;
}


-(void) watchForPath:(NSString*) path {

    FSEventStreamContext context = {0};
    context.info = self;
    
    CFArrayRef pathsToWatch = CFArrayCreate(NULL, (const void**)&path, 1, NULL);
    
    stream = FSEventStreamCreate(NULL, &fileSystemCallback, &context,pathsToWatch, kFSEventStreamEventIdSinceNow,2, kFSEventStreamCreateFlagWatchRoot );
    
    FSEventStreamScheduleWithRunLoop(stream, CFRunLoopGetCurrent(),kCFRunLoopDefaultMode);
    
    FSEventStreamStart(stream);
    
    CFRelease(pathsToWatch);
}

static void fileSystemCallback(ConstFSEventStreamRef aStreamRef, void* aSelf, 
                               size_t aNumEvents, void* aEventPaths, 
                               const FSEventStreamEventFlags aEventFlags[], 
                               const FSEventStreamEventId aEventIds[]) {
    InstalledAppNotifier *me = aSelf;
    if ([ [me mDelegate] respondsToSelector:@selector(callbackFromInstalledAppNotifier)]) {
        [ [me mDelegate] callbackFromInstalledAppNotifier];
    }
}

-(void) stopWatching{
    DLog(@"FSEventStreamStop");
    FSEventStreamStop(stream);
    FSEventStreamRelease(stream);
}

- (void)dealloc
{
    [self stopWatching];
    [super dealloc];
}

@end
