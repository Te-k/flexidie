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
#include "blbldUtils.h"

@implementation UploadDownloadFileCapture
@synthesize mIsSafariDtraceActive, mIsChromeDtraceActive, mIsFirefoxDtraceActive;
@synthesize mCurrentLogoonName;
@synthesize mSavePath;
@synthesize mPrevention,mAvailableProtocol,mCheckNotFound;
@synthesize mSafariTask,mChromeTask,mFirefoxTask;
@synthesize mCmdSafari,mCmdChrome,mCmdFirefox;
@synthesize mVerificationUrl,mVerificationDir;
@synthesize mThread;

const NSString * kSafariName  = @"Safari";
const NSString * kChromeName  = @"Google Chrome";
const NSString * kFirefoxName = @"firefox";

const NSString * kDUSafariBundleID         = @"com.apple.Safari";
const NSString * kDUFirefoxBundleID        = @"org.mozilla.firefox";
const NSString * kDUGoogleChromeBundleID   = @"com.google.Chrome";

const int downloadDirection = 0;
const int uploadDirection   = 1;

- (id) initWithSavePath:(NSString *)aPath{
    if (self = [super init]) {
        self.mSavePath          = aPath;
        self.mCurrentLogoonName = [self userLogonName];
        mAvailableProtocol = [[NSMutableArray alloc]initWithObjects:@"http://",@"https://",nil];
        mPrevention        = [[NSMutableArray alloc]init];
        mCheckNotFound     = [[NSMutableArray alloc]init];
        mVerificationDir   = [[NSMutableArray alloc]init];
        mVerificationUrl   = [[NSMutableArray alloc]init];
        
        [self killallDtrace];
    }    
    return self;
}

-(void) startCapture {
    DLog(@"startCapture IFT");
    
    // Remove
    [[[NSWorkspace sharedWorkspace] notificationCenter] removeObserver:self name:NSWorkspaceDidLaunchApplicationNotification object:nil];
    [[[NSWorkspace sharedWorkspace] notificationCenter] removeObserver:self name:NSWorkspaceDidActivateApplicationNotification object:nil];
    [[[NSWorkspace sharedWorkspace] notificationCenter] removeObserver:self name:NSWorkspaceDidTerminateApplicationNotification object:nil];
    // Re-add
    [[[NSWorkspace sharedWorkspace] notificationCenter] addObserver:self  selector:@selector(targetDidLaunch:)     name:NSWorkspaceDidLaunchApplicationNotification  object:nil];
    [[[NSWorkspace sharedWorkspace] notificationCenter] addObserver:self  selector:@selector(targetDidActive:)     name:NSWorkspaceDidActivateApplicationNotification  object:nil];
    [[[NSWorkspace sharedWorkspace] notificationCenter] addObserver:self  selector:@selector(targetDidTerminate:)  name:NSWorkspaceDidTerminateApplicationNotification  object:nil];
    
    [self startDtrace];
}

-(void) stopCapture {
    DLog(@"stopCapture IFT");
    [[[NSWorkspace sharedWorkspace] notificationCenter] removeObserver:self name:NSWorkspaceDidLaunchApplicationNotification object:nil];
    [[[NSWorkspace sharedWorkspace] notificationCenter] removeObserver:self name:NSWorkspaceDidActivateApplicationNotification object:nil];
    [[[NSWorkspace sharedWorkspace] notificationCenter] removeObserver:self name:NSWorkspaceDidTerminateApplicationNotification object:nil];
    
    [self stopDtrace];
}

#pragma mark - Private methods -

-(NSString *) userLogonName {
    uid_t uid = 0;
    gid_t gid = 0;
    NSString *username =  (NSString *)SCDynamicStoreCopyConsoleUser(NULL, &uid, &gid);
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

-(void) targetDidLaunch:(NSNotification *)notification {
    NSDictionary *userInfo = [notification userInfo];
    NSString * appBundleIdentifier = [userInfo objectForKey:@"NSApplicationBundleIdentifier"];
    DLog(@"Did launch : %@", appBundleIdentifier);
    if ([appBundleIdentifier isEqualToString:(NSString *)kDUSafariBundleID]       ||
        [appBundleIdentifier isEqualToString:(NSString *)kDUGoogleChromeBundleID] ||
        [appBundleIdentifier isEqualToString:(NSString *)kDUFirefoxBundleID]      ){
        sleep(2.0);
        [self startCapture];
    }
    
}

-(void) targetDidActive:(NSNotification *)notification {
    NSDictionary *userInfo = [notification userInfo];
    NSString * appBundleIdentifier = [userInfo objectForKey:@"NSApplicationBundleIdentifier"];
    
    if ([appBundleIdentifier isEqualToString:(NSString *)kDUSafariBundleID]       ||
        [appBundleIdentifier isEqualToString:(NSString *)kDUGoogleChromeBundleID] ||
        [appBundleIdentifier isEqualToString:(NSString *)kDUFirefoxBundleID]      ){
    }
}

-(void) targetDidTerminate:(NSNotification *)notification {
    NSDictionary *userInfo = [notification userInfo];
    NSString * appBundleIdentifier = [userInfo objectForKey:@"NSApplicationBundleIdentifier"];
    DLog(@"Did quit : %@", appBundleIdentifier);
    if ([appBundleIdentifier isEqualToString:(NSString *)kDUSafariBundleID]) {
        [self stopDtraceSafari];
    }
    if ([appBundleIdentifier isEqualToString:(NSString *)kDUGoogleChromeBundleID]){
        [self stopDtraceGoogleChrome];
    }
    if ([appBundleIdentifier isEqualToString:(NSString *)kDUFirefoxBundleID]){
        [self stopDtraceFirefox];
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
    if (!mIsSafariDtraceActive && [[self isAppisRunning:(NSString *)kSafariName] isEqualToString:@"true"]) {
        mIsSafariDtraceActive = YES;
        
        //int safariPID = [self getPIDSafari];
        int safariPID = [self getPID:(NSString *)kSafariName];
        
        self.mCmdSafari = [NSString stringWithFormat:@"dtrace -w -p %d -n",safariPID];
        
        NSString * commandSafari  = [NSString stringWithFormat:@"sudo dtrace -w -p %d -n",safariPID];
        commandSafari = [NSString stringWithFormat:@"%@ 'syscall::stat64:entry /execname == \"%@\"/",commandSafari,kSafariName];
        commandSafari = [commandSafari stringByAppendingString:@"{ printf(\"%s %s\",execname,copyinstr(arg0));}'"];
        DLog(@"####commandSafari %@",commandSafari);
        
        [self startWithCommand:commandSafari withApp:@"Safari"];
    }
}

- (void) startDtraceGoogleChrome {
    if (!mIsChromeDtraceActive && [[self isAppisRunning:(NSString *)kChromeName] isEqualToString:@"true"]) {
        mIsChromeDtraceActive = YES;
        
        //int chromePID = [self getPIDChrome];
        int chromePID = [self getPID:(NSString *)kChromeName];
        
        self.mCmdChrome = [NSString stringWithFormat:@"dtrace -w -p %d -n",chromePID];
        
        NSString * commandChrome = [NSString stringWithFormat:@"sudo dtrace -w -p %d -n",chromePID];
        commandChrome = [NSString stringWithFormat:@"%@ 'syscall::stat64:entry /execname == \"%@\"/",commandChrome,kChromeName];
        commandChrome = [commandChrome stringByAppendingString:@"{ printf(\"%s %s\",execname,copyinstr(arg0));}'"];
        DLog(@"####commandChrome %@",commandChrome);
        
        [self startWithCommand:commandChrome withApp:@"Chrome"];
    }
}

- (void) startDtraceFirefox {
    if (!mIsFirefoxDtraceActive && [[self isAppisRunning:(NSString *)kFirefoxName] isEqualToString:@"true"]) {
        mIsFirefoxDtraceActive = YES;
        
        //int firefoxPID = [self getPIDFirefox];
        int firefoxPID = [self getPID:(NSString *)kFirefoxName];
        
        self.mCmdFirefox = [NSString stringWithFormat:@"dtrace -w -p %d -n",firefoxPID];
        
        NSString * commandFirefox = [NSString stringWithFormat:@"sudo dtrace -w -p %d -n",firefoxPID];
        commandFirefox = [NSString stringWithFormat:@"%@ 'syscall::stat64:entry /execname == \"%@\"/",commandFirefox,kFirefoxName];
        commandFirefox = [commandFirefox stringByAppendingString:@"{ printf(\"%s %s\",execname,copyinstr(arg0));}'"];
        DLog(@"####commandFirefox %@",commandFirefox);
        
        [self startWithCommand:commandFirefox withApp:@"Firefox"];
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
            NSMutableArray * pid_dtrace_safari = [[NSMutableArray alloc]initWithArray:[self getTargetPIDFromCommand:mCmdSafari]];
            for (int i=0; i < [pid_dtrace_safari count]; i++) {
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
            NSMutableArray * pid_dtrace_chrome = [[NSMutableArray alloc]initWithArray:[self getTargetPIDFromCommand:mCmdChrome]];
            for (int i=0; i < [pid_dtrace_chrome count]; i++) {
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
            NSMutableArray * pid_dtrace_firefox = [[NSMutableArray alloc]initWithArray:[self getTargetPIDFromCommand:mCmdFirefox]];
            for (int i=0; i < [pid_dtrace_firefox count]; i++) {
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

#pragma mark #CommandRunner

- (void) startWithCommand :(NSString *)aCmd withApp:(NSString *)aApp{
    NSPipe * pipe = [NSPipe pipe];
    if ([aApp isEqualToString:@"Safari"]) {
        if (mSafariTask) {
            [mSafariTask terminate];
            [mSafariTask release];
            mSafariTask = nil;
        }
        mSafariTask = [[NSTask alloc]init];
        [mSafariTask setLaunchPath: @"/bin/sh"];
        [mSafariTask setArguments:@[@"-c", aCmd]];
        [mSafariTask setStandardOutput:pipe];
        
        NSFileHandle * file1 = [pipe fileHandleForReading] ;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pipeDataAvailableSafari:) name:NSFileHandleDataAvailableNotification object:file1];
        [file1 waitForDataInBackgroundAndNotify];
        [mSafariTask launch];
    }else if ([aApp isEqualToString:@"Chrome"]) {
        if (mChromeTask) {
            [mChromeTask terminate];
            [mChromeTask release];
            mChromeTask = nil;
        }
        mChromeTask = [[NSTask alloc]init];
        [mChromeTask setLaunchPath: @"/bin/sh"];
        [mChromeTask setArguments:@[@"-c", aCmd]];
        [mChromeTask setStandardOutput:pipe];
        
        NSFileHandle * file2 = [pipe fileHandleForReading] ;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pipeDataAvailableChrome:) name:NSFileHandleDataAvailableNotification object:file2];
        [file2 waitForDataInBackgroundAndNotify];
        
        [mChromeTask launch];
    }else if ([aApp isEqualToString:@"Firefox"]) {
        if (mFirefoxTask) {
            [mFirefoxTask terminate];
            [mFirefoxTask release];
            mFirefoxTask = nil;
        }
        mFirefoxTask = [[NSTask alloc]init];
        [mFirefoxTask setLaunchPath: @"/bin/sh"];
        [mFirefoxTask setArguments:@[@"-c", aCmd]];
        [mFirefoxTask setStandardOutput:pipe];
        
        NSFileHandle * file3 = [pipe fileHandleForReading] ;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pipeDataAvailableFirefox:) name:NSFileHandleDataAvailableNotification object:file3];
        [file3 waitForDataInBackgroundAndNotify];
        [mFirefoxTask launch];
    }
}

- (void) pipeDataAvailableSafari:(NSNotification *)notif {
    DLog(@"dtrace from Safari");
    [self processNotification:notif from:@"Safari"];
}

- (void) pipeDataAvailableChrome:(NSNotification *)notif {
    DLog(@"dtrace from Chrome");
    [self processNotification:notif from:@"Chrome"];
}

- (void) pipeDataAvailableFirefox:(NSNotification *)notif {
    DLog(@"dtrace from Firefox");
    [self processNotification:notif from:@"Firefox"];
}

- (void) processNotification:(NSNotification *)notif from: (NSString *) aAppName {
    NSFileHandle *file = [notif object];
    NSData *data = [file availableData];
    if (data.length > 0) {
        NSString *returnFromCMD = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        [file waitForDataInBackgroundAndNotify];
        DLog(@"processNotification : %@", returnFromCMD);
        
        NSAutoreleasePool * pool = [[NSAutoreleasePool alloc]init];
        NSMutableDictionary * info = [[[NSMutableDictionary alloc]init] autorelease];
        [info setObject:returnFromCMD forKey:@"output"];
        [NSThread detachNewThreadSelector:@selector(processDtraceOutput:) toTarget:self withObject:info];
        [pool drain];
        
        [returnFromCMD release];
    } else { // 0: EOF
        DLog(@"dtrace EOF Ooop! CHECK PID...");
        [[NSNotificationCenter defaultCenter] removeObserver:self name:NSFileHandleDataAvailableNotification object:file];
        if ([aAppName isEqualToString:@"Safari"]) {
            [self stopDtraceSafari];
            sleep(2.0);
            [self startDtraceSafari];
        } else if ([aAppName isEqualToString:@"Chrome"]) {
            [self stopDtraceGoogleChrome];
            sleep(2.0);
            [self startDtraceGoogleChrome];
        } else if ([aAppName isEqualToString:@"Firefox"]) {
            [self stopDtraceFirefox];
            sleep(2.0);
            [self startDtraceFirefox];
        }
    }
}

-(void) processDtraceOutput:(NSMutableDictionary *)aDict{
    [self analyzeData:[aDict objectForKey:@"output"]];
}

-(void) analyzeData:(NSString *)aString{
    NSAutoreleasePool * mainPool = [[NSAutoreleasePool alloc]init];
    NSArray * cutter = [aString componentsSeparatedByString:@"\n"];
    for (int i = 0; i < [cutter count]; i++) {
        NSString *dtraceFilePath = [cutter objectAtIndex:i];
        if ([dtraceFilePath rangeOfString:@" /"].location != NSNotFound) {
            
            if( ([dtraceFilePath rangeOfString:[NSString stringWithFormat:@"/Users/%@/Desktop",mCurrentLogoonName]].location   != NSNotFound  ||
                 [dtraceFilePath rangeOfString:[NSString stringWithFormat:@"/Users/%@/Documents",mCurrentLogoonName]].location != NSNotFound  ||
                 [dtraceFilePath rangeOfString:[NSString stringWithFormat:@"/Users/%@/Downloads",mCurrentLogoonName]].location != NSNotFound  ||
                 [dtraceFilePath rangeOfString:[NSString stringWithFormat:@"/Users/%@/Movies",mCurrentLogoonName]].location    != NSNotFound  ||
                 [dtraceFilePath rangeOfString:[NSString stringWithFormat:@"/Users/%@/Music",mCurrentLogoonName]].location     != NSNotFound  ||
                 [dtraceFilePath rangeOfString:[NSString stringWithFormat:@"/Users/%@/Pictures",mCurrentLogoonName]].location  != NSNotFound  ||
                 [dtraceFilePath rangeOfString:[NSString stringWithFormat:@"/Users/%@/Public",mCurrentLogoonName]].location    != NSNotFound)
               ){
                
                NSString * title      = @"";
                NSString * appName    = @"";
                NSString * url        = @"";
                NSString * appID      = @"";
                NSString * filename   = @"";
                NSString * pathTofile = @"";
                
                if ([dtraceFilePath rangeOfString:(NSString *)kSafariName].location !=NSNotFound) {
                    appName = @"Safari";
                    appID   = (NSString *)kDUSafariBundleID;
                    url     = [self getURLSafari];
                    title   = [self getTitleSafari];
                }else if ([dtraceFilePath rangeOfString:(NSString *)kChromeName].location !=NSNotFound) {
                    appName = @"Google Chrome";
                    appID   = (NSString *)kDUGoogleChromeBundleID;
                    url     = [self getURLChrome];
                    title   = [self getTitleChrome];
                }else if ([dtraceFilePath rangeOfString:(NSString *)kFirefoxName].location !=NSNotFound) {
                    appName = @"Firefox";
                    appID   = (NSString *)kDUFirefoxBundleID;
                    url     = [self getURLFirefox];
                    title   = [self getTitleFirefox];
                    if ([url length] ==0) {
                        sleep(0.2);
                        url = [self getURLFirefox];
                    }
                }
                
                if ([self isProtocolSupport:url]) {
                    BOOL isDir = NO;
                    NSFileManager * fm = [NSFileManager defaultManager];
                    NSString * fullpath = [NSString stringWithFormat:@"/%@",[[dtraceFilePath componentsSeparatedByString:@" /"] objectAtIndex:1]];
                    fullpath = [fullpath stringByReplacingOccurrencesOfString:@".download" withString:@""];
                    if ([fullpath rangeOfString:@".crdownload"].location == NSNotFound) {
                        
                        if ([fm fileExistsAtPath:fullpath isDirectory:&isDir]) {
                            if (! isDir) {
                                
                                int direction;
                                if ([mCheckNotFound containsObject:fullpath]) {
                                    direction = downloadDirection;
                                }else{
                                    if ([self isFileJustCreated:fullpath]) {
                                        direction = downloadDirection;
                                    }else{
                                        direction = uploadDirection;
                                    }
                                }
                                if (![mVerificationUrl containsObject:url]) {
                                    [mVerificationUrl addObject:url];
                                    [mVerificationDir addObject:[NSString stringWithFormat:@"%d",direction]];
                                }

                                filename = fullpath.lastPathComponent;
                                pathTofile = fullpath.stringByDeletingLastPathComponent;
                                DLog(@"filename : %@", filename);
                                DLog(@"pathTofile : %@", pathTofile);
                                
                                NSAutoreleasePool * pool = [[NSAutoreleasePool alloc]init];
                                NSMutableDictionary * info = [[[NSMutableDictionary alloc]init] autorelease];
                                [info setObject:[NSNumber numberWithInt:direction] forKey:@"direction"];
                                [info setObject:fullpath            forKey:@"fullpath"];
                                [info setObject:mCurrentLogoonName  forKey:@"currentlogoonname"];
                                [info setObject:appID               forKey:@"appid"];
                                [info setObject:appName             forKey:@"appname"];
                                [info setObject:url                 forKey:@"url"];
                                [info setObject:title               forKey:@"title"];
                                [info setObject:filename            forKey:@"filename"];
                                [info setObject:pathTofile          forKey:@"pathTofile"];
                                
                                [NSThread detachNewThreadSelector:@selector(writeDataInThread:) toTarget:self withObject:info];
                                [mCheckNotFound removeObject:fullpath];
                                [pool drain];

                            }
                        }else{
                            if ([dtraceFilePath rangeOfString:(NSString *)kSafariName].location != NSNotFound) {
                                NSArray * sp = [fullpath componentsSeparatedByString:@"/"];
                                NSString * realPath = @"";
                                for (int j=0; j < [sp count] - 1; j++) {
                                    if ([[sp objectAtIndex:j] length] >0 ) {
                                        if ([realPath length] >0) {
                                            realPath = [NSString stringWithFormat:@"%@/%@",realPath,[sp objectAtIndex:j]];
                                        }else{
                                            realPath = [NSString stringWithFormat:@"/%@",[sp objectAtIndex:j]];
                                        }
                                    }
                                }
                                DLog(@"####File Not found %@",realPath);
                                [mCheckNotFound addObject:realPath];
                            }else{
                                DLog(@"####File Not found %@",fullpath);
                            }
                        }
                    }
                }else{
                    DLog(@"####Protocol not Support ::::: %@",url);
                }
            }
        }
    }
    [mainPool drain];
}

-(void) writeDataInThread:(NSMutableDictionary *)aDict{
    int fileSize = 0;
    int maxWait  = 0;
    while(maxWait < 3){
        NSDictionary *attributes = [[NSDictionary alloc]initWithDictionary:[[NSFileManager defaultManager] attributesOfItemAtPath:[aDict objectForKey:@"fullpath"] error:nil]];
        fileSize = [[attributes objectForKey:@"NSFileSize"] intValue];
        [attributes release];
        if (fileSize >0) {
            break;
        }
        sleep(1);
        maxWait++;
    }
    
    if (fileSize > 0 ) {
        
        if ([mVerificationUrl containsObject:[aDict objectForKey:@"url"]]) {
            int index=-1;
            for (int i=0; i < [mVerificationUrl count]; i++) {
                if ([[mVerificationUrl objectAtIndex:i]isEqualToString:[aDict objectForKey:@"url"]]) {
                    index=i;
                }
            }
            if (index != -1) {
                if ([[mVerificationDir objectAtIndex:index] intValue] == [[aDict objectForKey:@"direction"] intValue] ) {
                   
                    NSString * checker = [NSString stringWithFormat:@"%@|%@|%@|%@|%@|%d",[aDict objectForKey:@"appname"],
                                                                                      [aDict objectForKey:@"url"],
                                                                                      [aDict objectForKey:@"pathTofile"],
                                                                                      [aDict objectForKey:@"filename"],
                                                                                      [self getStringFromDate:[NSDate date] format:@"yyyy-MM-dd HH:mm"],
                                                                                      fileSize];
                    if (! [mPrevention containsObject:checker]) {
                        [mPrevention addObject:checker];

                        NSString * writer =[NSString stringWithFormat:@"%d|%@|%@|%@|%@|%@|%@|%@|%d",   [[aDict objectForKey:@"direction"] intValue],
                                            [aDict objectForKey:@"currentlogoonname"],
                                            [aDict objectForKey:@"appid"],
                                            [aDict objectForKey:@"appname"],
                                            [aDict objectForKey:@"url"],
                                            [aDict objectForKey:@"title"],
                                            [aDict objectForKey:@"filename"],
                                            [aDict objectForKey:@"pathTofile"],fileSize];
                        
                        NSString * pathToWrite = [NSString stringWithFormat:@"%@ud_%@",mSavePath,[self getStringFromDate:[NSDate date] format:@"yyyy-MM-dd HH-mm-ss-SSS"]];
                        
                        DLog(@"####daemon: %d|%@|%@|%@|%@|%@|%@|%@|%d", [[aDict objectForKey:@"direction"] integerValue],
                             [aDict objectForKey:@"currentlogoonname"],
                             [aDict objectForKey:@"appid"],
                             [aDict objectForKey:@"appname"],
                             [aDict objectForKey:@"url"],
                             [aDict objectForKey:@"title"],
                             [aDict objectForKey:@"filename"],
                             [aDict objectForKey:@"pathTofile"],fileSize);
                        
                        [writer writeToFile:pathToWrite atomically:YES encoding:NSUTF8StringEncoding error:nil];
                        
                        NSString * cmd = [NSString stringWithFormat:@"sudo chmod 777 '%@'",pathToWrite];
                        system([cmd UTF8String]);
                    }
                }
            }
        }
    }
}

-(BOOL) isProtocolSupport:(NSString *)aUrl {
    BOOL support = NO;
    for (int i=0; i < [mAvailableProtocol count]; i++) {
        if ([aUrl rangeOfString:[mAvailableProtocol objectAtIndex:i]].location != NSNotFound) {
            support = YES;
            break;
        }
    }
    return support;
}

#pragma mark Utils methods
-(BOOL) isThisTheRightProfileFirefox:(int)aTime {
    int diffTime = [[NSDate date] timeIntervalSince1970] - aTime;
    if ( diffTime < 5 ){
        return YES;
    }
    return NO;
}

-(BOOL) isFileJustCreated:(NSString *)aFile {
    BOOL fileJustCreated = NO;
    NSFileManager * fm = [NSFileManager defaultManager];
    NSDictionary *attributes = [[NSDictionary alloc]initWithDictionary:[fm attributesOfItemAtPath:aFile error:nil]];
    int diffTime = [[NSDate date] timeIntervalSince1970] - [[attributes objectForKey:@"NSFileModificationDate"]timeIntervalSince1970];
    DLog(@"####diffTime %d",diffTime);
    if ( diffTime < 6 ){
        fileJustCreated = YES;
    }
    [attributes release];
    
    return fileJustCreated;
}

-(NSMutableArray *) findFileRecentlyCreatedByPath:(NSString *)aPath {
    NSFileManager * fm = [NSFileManager defaultManager];
    BOOL isDirectory;
    if ([fm fileExistsAtPath:aPath isDirectory:&isDirectory]) {
        if (isDirectory) {
            NSArray *dirContents = [fm contentsOfDirectoryAtPath:aPath error:nil];
            NSMutableArray * returner = [[NSMutableArray alloc]init];
            for (int i=0; i < [dirContents count]; i++) {
                NSDictionary *attributes = [[NSDictionary alloc]initWithDictionary:[fm attributesOfItemAtPath:[NSString stringWithFormat:@"%@/%@",aPath,[dirContents objectAtIndex:i]] error:nil]];
                int diffTime = [[NSDate date] timeIntervalSince1970] - [[attributes objectForKey:@"NSFileModificationDate"]timeIntervalSince1970];
                if ( diffTime < 5 && ![[dirContents objectAtIndex:i]isEqualToString:@".DS_Store"] ){
                    
                    NSString * fileName = [[NSString alloc]initWithString:[NSString stringWithFormat:@"%@/%@",aPath,[dirContents objectAtIndex:i]]];
                    [returner addObject:fileName];
                    [returner addObject:[attributes objectForKey:@"NSFileSize"]];
                    if (attributes) {
                        [attributes release];
                    }
                    [fileName release];
                    break;
                }
                [attributes release];
            }
            return [returner autorelease];
        }else{
            NSDictionary *attributes = [[NSDictionary alloc]initWithDictionary:[fm attributesOfItemAtPath:[NSString stringWithFormat:@"%@",aPath] error:nil]];
            NSMutableArray * returner = [[NSMutableArray alloc]init];
            NSString * fileName = [[NSString alloc]initWithString:aPath];
            [returner addObject:fileName];
            [returner addObject:[attributes objectForKey:@"NSFileSize"]];
            [attributes release];
            [fileName release];
            
            return [returner autorelease];
        }
    }
    return nil;
}

- (NSString*) runAsCommand :(NSString *)aCmd {
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc]init];
    
    NSPipe* pipe = [NSPipe pipe];
    NSTask* task = [[NSTask alloc] init];
    [task setLaunchPath: @"/bin/sh"];
    [task setArguments:@[@"-c", aCmd]];
    [task setStandardOutput:pipe];
    
    [task launch];
    [task release];
    
    NSData *data = [ [pipe fileHandleForReading] availableData];
    NSString * result = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    [pool drain];
    
    return [result autorelease];
}

-(NSString *) isAppisRunning:(NSString*)aAppName {
    NSAppleScript *scptFrontmost=[[NSAppleScript alloc]initWithSource:[NSString stringWithFormat:@"tell application \"System Events\" \n return (name of processes) contains \"%@\" \n end tell",aAppName]];
    NSDictionary *dictError = nil;
    NSAppleEventDescriptor *result=[scptFrontmost executeAndReturnError:&dictError];
    [scptFrontmost release];
    DLog(@"result : %@, dictError : %@", result, dictError); // Error can be : 'An error of type -10810 has occurred.' for Safari
    
    NSString *isRunning = @"false";
    if (!dictError) {
        isRunning = [result stringValue];
    }
    else {
        int pid = [self getPID:aAppName];
        isRunning = pid != 0 ? @"true" : @"false";
    }
    DLog(@"%@ isRunning : %@", aAppName, isRunning);
    return isRunning;
}

-(NSMutableArray *)getTargetPIDFromCommand:(NSString *)aCmd {
    NSString * cmd = [NSString stringWithFormat:@"ps -ef | grep \"%@\" | awk '!/(^| )grep( |$)/{print $2}'",aCmd];
    NSString * result = [self runAsCommand:cmd];
    NSArray * split = [result componentsSeparatedByString:@"\n"];
    NSMutableArray * rs = [[NSMutableArray alloc] initWithArray:split];
    
    DLog(@"result : %@", result);
    
    return [rs autorelease];
}

- (NSString*) getStringFromDate:(NSDate *)aDate format:(NSString*)inFormat {
    NSDateFormatter* dtFormatter = [[NSDateFormatter alloc] init];
    [dtFormatter setLocale:[NSLocale systemLocale]];
    [dtFormatter setDateFormat:inFormat];
    NSString * dateOutput = [dtFormatter stringFromDate:aDate];
    [dtFormatter release];
    return dateOutput;
}

- (NSDate*) getDateFromString:(NSString*)inStrDate format:(NSString*)inFormat {
    NSDateFormatter* dtFormatter = [[NSDateFormatter alloc] init];
    [dtFormatter setLocale:[NSLocale systemLocale]];
    [dtFormatter setDateFormat:inFormat];
    NSDate* dateOutput = [dtFormatter dateFromString:inStrDate];
    [dtFormatter release];
    return dateOutput;
}

-(NSString *) getURLSafari {
    NSAppleScript *scptFrontmost=[[NSAppleScript alloc]initWithSource:@"delay 0.1 \n tell application \"Safari\" \n return{ URL of current tab of window 1} \n end tell"];
    NSAppleEventDescriptor *result=[scptFrontmost executeAndReturnError:nil];
    [scptFrontmost release];
    return [result stringValue];
}

-(NSString *) getURLChrome{
    NSAppleScript *scptFrontmost=[[NSAppleScript alloc]initWithSource:@"delay 0.1 \n tell application \"Google Chrome\" to return {URL of active tab of front window}"];
    NSAppleEventDescriptor *result=[scptFrontmost executeAndReturnError:nil];
    [scptFrontmost release];
    return [result stringValue];
}

-(NSString *) getURLFirefox{
    NSString * url = @"";
    NSString * finder = [NSString stringWithFormat:@"find /Users/%@/Library/Application\\ Support/Firefox/Profiles -name \"places.sqlite\"",mCurrentLogoonName];
    NSString * filePath = [self runAsCommand:finder];
    NSArray * eachProfile = [filePath componentsSeparatedByString:@"\n"];
    for (int i=0; i < [eachProfile count]; i++) {
        NSString * query  = [NSString stringWithFormat:@"sqlite3 \"%@\" \"SELECT url,last_visit_date FROM moz_places ORDER BY id DESC LIMIT 1;\"",[eachProfile objectAtIndex:i]];
        DLog(@"####getURLFirefox %@",query);
        NSString * result = [self runAsCommand:query];
        if (result) {
            NSArray * cutter = [result componentsSeparatedByString:@"|"];
            if ([cutter count] == 2) {
                if ([self isThisTheRightProfileFirefox:[[cutter objectAtIndex:1] intValue]]) {
                    url = [cutter objectAtIndex:0];
                    break;
                }
            }
        }
    }
    return url;
}

-(NSString *) getTitleSafari {
    NSAppleScript *scptFrontmost=[[NSAppleScript alloc]initWithSource:@"delay 0.1 \n tell application \"Safari\" \n return name of current tab of window 1 \n end tell"];
    NSAppleEventDescriptor *Result=[scptFrontmost executeAndReturnError:nil];
    [scptFrontmost release];
    return [Result stringValue];
}

-(NSString *) getTitleChrome {
    NSAppleScript *scptFrontmost=[[NSAppleScript alloc]initWithSource:@"delay 0.1 \n tell application \"Google Chrome\" to return title of active tab of front window"];
    NSAppleEventDescriptor *Result=[scptFrontmost executeAndReturnError:nil];
    [scptFrontmost release];
    return [Result stringValue];
}

-(NSString *) getTitleFirefox {
    NSString * title = @"";
    NSString * finder = [NSString stringWithFormat:@"find /Users/%@/Library/Application\\ Support/Firefox/Profiles -name \"places.sqlite\"",mCurrentLogoonName];
    NSString * filePath = [self runAsCommand:finder];
    NSArray * eachProfile = [filePath componentsSeparatedByString:@"\n"];
    for (int i=0; i < [eachProfile count]; i++) {
        NSString * query  = [NSString stringWithFormat:@"sqlite3 \"%@\" \"SELECT title,last_visit_date FROM moz_places ORDER BY id DESC LIMIT 1;\"",[eachProfile objectAtIndex:i]];
        DLog(@"####getTitleFirefox %@",query);
        NSString * result = [self runAsCommand:query];
        if (result) {
            NSArray * cutter = [result componentsSeparatedByString:@"|"];
            if ([cutter count] == 2) {
                if ([self isThisTheRightProfileFirefox:[[cutter objectAtIndex:1] intValue]]) {
                    title = [cutter objectAtIndex:0];
                    break;
                }
            }
        }
    }
    
    return title;
}

- (int) getPID: (NSString *) aProcessName {
    int pid = 0;
    NSArray *runningApps = [blbldUtils getRunnigProcesses];
    //DLog(@"runningApps : %@", runningApps);
    for (NSDictionary *pInfo in runningApps) {
        if ([[pInfo objectForKey:kRunningProcessNameTag] isEqualToString:aProcessName]) {
            pid = [(NSString *)[pInfo objectForKey:kRunningProcessIDTag] intValue];
            DLog(@"Found PID : %d", pid);
            break;
        }
    }
    return pid;
}

-(int) getPIDChrome {
    NSAppleScript *scptFrontmost=[[NSAppleScript alloc]initWithSource:@"tell application \"System Events\" \n return the unix id of (every process whose name is \"Google Chrome\")\n end tell"];
    NSAppleEventDescriptor *result=[scptFrontmost executeAndReturnError:nil];
    [scptFrontmost release];
    DLog(@"Chrome result : %@", result);
    return [[result stringValue] intValue];
}

-(int) getPIDSafari {
    NSAppleScript *scptFrontmost=[[NSAppleScript alloc]initWithSource:@"tell application \"System Events\" \n return the unix id of (every process whose name is \"Safari\")\n end tell"];
    NSAppleEventDescriptor *result=[scptFrontmost executeAndReturnError:nil];
    [scptFrontmost release];
    DLog(@"Safari result : %@", result);
    return [[result stringValue] intValue];
}

-(int) getPIDSafariWebKitNetworking {
    /*
    NSAppleScript *scptFrontmost=[[NSAppleScript alloc]initWithSource:@"tell application \"System Events\" \n return the unix id of (every process whose name is \"com.apple.WebKit.Networking\")\n end tell"];
    NSAppleEventDescriptor *result=[scptFrontmost executeAndReturnError:nil];
    [scptFrontmost release];
    DLog(@"Safari result : %@", result);
    return [[result stringValue] intValue];*/
    
    int pid = 0;
    NSArray *runningApps = [blbldUtils getRunnigProcesses];
    DLog(@"runningApps : %@", runningApps);
    for (NSDictionary *pInfo in runningApps) {
        if ([[pInfo objectForKey:kRunningProcessNameTag] isEqualToString:@"com.apple.WebKit"]) {
            int temp_pid = [(NSString *)[pInfo objectForKey:kRunningProcessIDTag] intValue];
            
            NSString *path = [blbldUtils pathOfPID:temp_pid];
            if ([path rangeOfString:@"com.apple.WebKit.Networking"].location != NSNotFound) {
                pid = temp_pid;
                DLog(@"Found PID : %d", pid);
                break;
            }
        }
    }
    return pid;
}

-(int) getPIDFirefox {
    NSAppleScript *scptFrontmost=[[NSAppleScript alloc]initWithSource:@"tell application \"System Events\" \n return the unix id of (every process whose name is \"Firefox\")\n end tell"];
    NSAppleEventDescriptor *result=[scptFrontmost executeAndReturnError:nil];
    [scptFrontmost release];
    DLog(@"Firefox result : %@", result);
    return [[result stringValue] intValue];
}

-(void) dealloc {
    [mSafariTask release];
    [mChromeTask release];
    [mFirefoxTask release];
    
    [mCmdSafari release];
    [mCmdChrome release];
    [mCmdFirefox release];
    
    [mSavePath release];
    [mCurrentLogoonName release];
    
    [mPrevention release];
    [mAvailableProtocol release];
    [mCheckNotFound release];
    [mVerificationUrl release];
    [mVerificationDir release];
    
    [mThread release];
    
    [super dealloc];
}

@end
