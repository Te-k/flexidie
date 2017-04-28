//
//  AppTerminateMonitor.m
//  blbld
//
//  Created by Makara Khloth on 2/17/15.
//
//

#import "AppTerminateMonitor.h"
#import "blbldUtils.h"

#import <AppKit/AppKit.h>
#include <sys/types.h>
#include <sys/event.h>
#include <sys/time.h>

static void NoteExitKQueueCallback(
                                   CFFileDescriptorRef f,
                                   CFOptionFlags       callBackTypes,
                                   void *              info
                                   );

@interface AppTerminateMonitor (private)
- (void) applicationDidTerminate: (NSNotification *) aNotification;
- (void) NoteExit;
@end

@implementation AppTerminateMonitor

@synthesize mDelegate, mSelector;
@synthesize mProcessName;

- (void) start {
    // Not call if LSUIElements set to true in plist
    NSNotificationCenter *nc = [[NSWorkspace sharedWorkspace] notificationCenter];
    [nc addObserver:self selector:@selector(applicationDidTerminate:) name:NSWorkspaceDidTerminateApplicationNotification object:nil];
    
    [self NoteExit];
}

- (void) stop {
    NSNotificationCenter *nc = [[NSWorkspace sharedWorkspace] notificationCenter];
    [nc removeObserver:self name:NSWorkspaceDidTerminateApplicationNotification object:nil];
    
    if (mNoteExitKQueueRef) {
        CFFileDescriptorDisableCallBacks(mNoteExitKQueueRef, kCFFileDescriptorReadCallBack);
        CFRelease(mNoteExitKQueueRef);
        mNoteExitKQueueRef = nil;
    }
}

#pragma mark - Private method -

- (void) applicationDidTerminate: (NSNotification *) aNotification {
    //DLog(@"Notification of applicaton terminated: %@", aNotification);
    NSDictionary *userInfo = [aNotification userInfo];
    NSString *bundleID = [userInfo objectForKey:@"NSApplicationBundleIdentifier"];
    if ([bundleID rangeOfString:self.mProcessName].location != NSNotFound) {
        if ([mDelegate respondsToSelector:mSelector]) {
            [mDelegate performSelector:mSelector withObject:nil];
        }
    }
}

- (void) NoteExit
{
    pid_t gTargetPID = -1;
    NSArray *processes = [blbldUtils getRunnigProcesses];
    for (NSDictionary *pInfo in processes) {
        if ([[pInfo objectForKey:kRunningProcessNameTag] isEqualToString:self.mProcessName]) {
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
    
    // Execution continues in NoteExitKQueueCallback, below.
}

static void NoteExitKQueueCallback(
                                   CFFileDescriptorRef f,
                                   CFOptionFlags       callBackTypes,
                                   void *              info
                                   )
{
    struct kevent   event;
    
    (void) kevent( CFFileDescriptorGetNativeDescriptor(f), NULL, 0, &event, 1, NULL);
    
    DLog(@"Process terminated %d", (int) (pid_t) event.ident);
    
    // You've been notified!
    AppTerminateMonitor *mySelf = (AppTerminateMonitor *)info;
    if ([mySelf.mDelegate respondsToSelector:mySelf.mSelector]) {
        [mySelf.mDelegate performSelector:mySelf.mSelector withObject:nil];
    }
}

- (void) dealloc {
    [mProcessName release];
    [super dealloc];
}

@end
