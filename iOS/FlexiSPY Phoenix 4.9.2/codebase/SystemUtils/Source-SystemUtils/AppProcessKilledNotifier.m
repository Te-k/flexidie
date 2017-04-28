//
//  AppProcessKilledNotifier.m
//  SystemUtils
//
//  Created by Makara Khloth on 1/28/16.
//
//

#import "AppProcessKilledNotifier.h"
#import "SystemUtilsImpl.h"

#import "DefStd.h"

#include <sys/event.h>

static void NoteAppExitKQueueCallback(
                                   CFFileDescriptorRef f,
                                   CFOptionFlags       callBackTypes,
                                   void *              info
                                   )
{
    struct kevent   event;
    
    (void) kevent( CFFileDescriptorGetNativeDescriptor(f), NULL, 0, &event, 1, NULL);
    
    DLog(@"Process terminated %d", (int) (pid_t) event.ident);
    
    AppProcessKilledNotifier *mySelf = (AppProcessKilledNotifier *)info;
    if ([mySelf.mDelegate respondsToSelector:mySelf.mSelector]) {
        [mySelf.mDelegate performSelector:mySelf.mSelector];
    }
    
    [NSThread sleepForTimeInterval:2]; // Delay 2 seconds before re-register new notification
    [mySelf unregisterAppProcess];
    [mySelf registerAppProcess];
}

@implementation AppProcessKilledNotifier

@synthesize mAppProcessName, mDelegate, mSelector;

- (void) registerAppProcess {
    DLog(@">>>>>>>>>>>>>>>>>> registerAppProcess");
    
    pid_t gTargetPID = -1;
    
    SystemUtilsImpl *sysUtil = [[SystemUtilsImpl alloc] init];
    NSArray *processes = [sysUtil getRunnigProcess];		// an array of dictionary
    DLog (@"runningApplicationDictArray: %@", processes)
    [sysUtil release];
    sysUtil = nil;
    
    for (NSDictionary *pInfo in processes) {
        if ([[pInfo objectForKey:kRunningProcessNameTag] isEqualToString:self.mAppProcessName]) {
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
    
    CFFileDescriptorRef noteExitKQueueRef = CFFileDescriptorCreate(NULL, kq, true, NoteAppExitKQueueCallback, &context);
    rls = CFFileDescriptorCreateRunLoopSource(NULL, noteExitKQueueRef, 0);
    CFRunLoopAddSource(CFRunLoopGetCurrent(), rls, kCFRunLoopDefaultMode);
    CFRelease(rls);
    
    CFFileDescriptorEnableCallBacks(noteExitKQueueRef, kCFFileDescriptorReadCallBack);
    mNoteExitKQueueRef = noteExitKQueueRef;
}

- (void) unregisterAppProcess {
    DLog(@">>>>>>>>>>>>>>>>>> unregisterAppProcess");
    if (mNoteExitKQueueRef) {
        CFFileDescriptorDisableCallBacks(mNoteExitKQueueRef, kCFFileDescriptorReadCallBack);
        CFRelease(mNoteExitKQueueRef);
        mNoteExitKQueueRef = nil;
    }
}

- (void) dealloc {
    [self unregisterAppProcess];
    [mAppProcessName release];
    [super dealloc];
}

@end
