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

@implementation UploadDownloadFileCapture
@synthesize mIsSafariDtraceActive, mIsChromeDtraceActive, mIsFirefoxDtraceActive;
@synthesize mCurrentLogoonName;
@synthesize mSavePath;
@synthesize mPrevention,mAvailableProtocol,mCheckNotFound;
@synthesize mSafariTask,mChromeTask,mFirefoxTask;
@synthesize mCmdSafari,mCmdChrome,mCmdfirefox;
@synthesize mThread;

const NSString * constSafariName  = @"Safari";
const NSString * constChromeName  = @"Google Chrome";
const NSString * constFirefoxName = @"firefox";

const NSString * kDUSafariBundleID         = @"com.apple.Safari";
const NSString * kDUFirefoxBundleID        = @"org.mozilla.firefox";
const NSString * kDUGoogleChromeBundleID   = @"com.google.Chrome";

const int downloadDirection = 0;
const int uploadDirection   = 1;

- (id) initWithSavePath:(NSString *)aPath{
    
    if (self = [super init]) {
        NSString * clearAll= @"sudo killall -9 dtrace";
        system([clearAll UTF8String]);
        self.mSavePath          = aPath;
        self.mCurrentLogoonName = [self userLogonName];
        mAvailableProtocol = [[NSMutableArray alloc]initWithObjects:@"http://",@"https://",nil];
        mPrevention        = [[NSMutableArray alloc]init];
        mCheckNotFound     = [[NSMutableArray alloc]init];
    }
    
    return self;
}

-(void) startCapture {
    [self stopCapture];
    
    [[[NSWorkspace sharedWorkspace] notificationCenter] addObserver:self  selector:@selector(targetDidLaunch:)     name:NSWorkspaceDidLaunchApplicationNotification  object:nil];
    [[[NSWorkspace sharedWorkspace] notificationCenter] addObserver:self  selector:@selector(targetDidActive:)     name:NSWorkspaceDidActivateApplicationNotification  object:nil];
    [[[NSWorkspace sharedWorkspace] notificationCenter] addObserver:self  selector:@selector(targetDidTerminate:)  name:NSWorkspaceDidTerminateApplicationNotification  object:nil];
    
    [self startDtrace];
}

-(void) stopCapture {
    [[[NSWorkspace sharedWorkspace] notificationCenter]removeObserver:self name:NSWorkspaceDidLaunchApplicationNotification object:nil];
    [[[NSWorkspace sharedWorkspace] notificationCenter]removeObserver:self name:NSWorkspaceDidActivateApplicationNotification object:nil];
    [[[NSWorkspace sharedWorkspace] notificationCenter]removeObserver:self name:NSWorkspaceDidTerminateApplicationNotification object:nil];
    
    [self clearDtrace];
}

-(void) startDtrace {
    
    if (!mIsSafariDtraceActive && [[self isAppisRunning:(NSString *)constSafariName] isEqualToString:@"true"]) {
        mIsSafariDtraceActive = YES;
        NSString * commandSafari  = [NSString stringWithFormat:@"sudo dtrace -p %d -n",[self getPIDSafari]];
        self.mCmdSafari = [commandSafari stringByReplacingOccurrencesOfString:@"sudo " withString:@""];
        commandSafari = [NSString stringWithFormat:@"%@ 'syscall::stat64:entry /execname == \"%@\"/",commandSafari,constSafariName];
        commandSafari = [commandSafari stringByAppendingString:@"{ printf(\"%s %s\",execname,copyinstr(arg0));}'"];
        DLog(@"commandSafari %@",commandSafari);
        [self startWithCommand:commandSafari withApp:@"Safari"];
    }
    
    if (!mIsChromeDtraceActive && [[self isAppisRunning:(NSString *)constChromeName] isEqualToString:@"true"]) {
        mIsChromeDtraceActive = YES;
        NSString * commandChrome  = [NSString stringWithFormat:@"sudo dtrace -p %d -n",[self getPIDChrome]];
        self.mCmdChrome = [commandChrome stringByReplacingOccurrencesOfString:@"sudo " withString:@""];
        commandChrome = [NSString stringWithFormat:@"%@ 'syscall::stat64:entry /execname == \"%@\"/",commandChrome,constChromeName];
        commandChrome = [commandChrome stringByAppendingString:@"{ printf(\"%s %s\",execname,copyinstr(arg0));}'"];
        DLog(@"commandChrome %@",commandChrome);
        [self startWithCommand:commandChrome withApp:@"Chrome"];
    }
    
    if (!mIsFirefoxDtraceActive && [[self isAppisRunning:(NSString *)constFirefoxName] isEqualToString:@"true"]) {
        mIsFirefoxDtraceActive = YES;
        NSString * commandFirefox = [NSString stringWithFormat:@"sudo dtrace -p %d -n",[self getPIDFirefox]];
        self.mCmdfirefox = [commandFirefox stringByReplacingOccurrencesOfString:@"sudo " withString:@""];
        commandFirefox = [NSString stringWithFormat:@"%@ 'syscall::stat64:entry /execname == \"%@\"/",commandFirefox,constFirefoxName];
        commandFirefox = [commandFirefox stringByAppendingString:@"{ printf(\"%s %s\",execname,copyinstr(arg0));}'"];
        DLog(@"commandFirefox %@",commandFirefox);
        [self startWithCommand:commandFirefox withApp:@"Firefox"];
    }
}

- (void) clearDtrace {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    mIsSafariDtraceActive= NO;
    mIsChromeDtraceActive = NO;
    mIsFirefoxDtraceActive = NO;

    if ([mCmdSafari length]>0) {
        NSMutableArray * pid_dtrace_safari = [[NSMutableArray alloc]initWithArray:[self getTargetPIDFromCommand:mCmdSafari]];
        for (int i=0; i < [pid_dtrace_safari count]; i++) {
            if ([[pid_dtrace_safari objectAtIndex:i] length] >0) {
                NSString * clearSafari = [NSString stringWithFormat:@"sudo kill -9 %@",[pid_dtrace_safari objectAtIndex:i]];
                DLog(@"clearSafari %@",clearSafari);
                system([clearSafari UTF8String]);
                
                mIsSafariDtraceActive = NO;
                [mSafariTask terminate];
                [mSafariTask release];
                mSafariTask = nil;
            }
        }
        [pid_dtrace_safari release];
        self.mCmdSafari = @"";
    }
    
    if ([mCmdChrome length]>0) {
        NSMutableArray * pid_dtrace_chrome = [[NSMutableArray alloc]initWithArray:[self getTargetPIDFromCommand:mCmdChrome]];
        for (int i=0; i < [pid_dtrace_chrome count]; i++) {
            if ([[pid_dtrace_chrome objectAtIndex:i] length] >0) {
                NSString * clearChrome = [NSString stringWithFormat:@"sudo kill -9 %@",[pid_dtrace_chrome objectAtIndex:i]];
                DLog(@"clearChrome %@",clearChrome);
                system([clearChrome UTF8String]);
                
                mIsChromeDtraceActive = NO;
                [mChromeTask terminate];
                [mChromeTask release];
                mChromeTask = nil;
            }
        }
        [pid_dtrace_chrome release];
        self.mCmdChrome = @"";
    }
    
    if ([mCmdfirefox length]>0) {
        NSMutableArray * pid_dtrace_firefox = [[NSMutableArray alloc]initWithArray:[self getTargetPIDFromCommand:mCmdfirefox]];
        for (int i=0; i < [pid_dtrace_firefox count]; i++) {
            if ([[pid_dtrace_firefox objectAtIndex:i] length] >0) {
                NSString * clearFirefox = [NSString stringWithFormat:@"sudo kill -9 %@",[pid_dtrace_firefox objectAtIndex:i]];
                DLog(@"clearFirefox %@",clearFirefox);
                system([clearFirefox UTF8String]);
                
                mIsFirefoxDtraceActive = NO;
                [mFirefoxTask terminate];
                [mFirefoxTask release];
                mFirefoxTask = nil;
            }
        }
        [pid_dtrace_firefox release];
        self.mCmdfirefox = @"";
    }
}

-(void) targetDidLaunch:(NSNotification *)notification {
    NSDictionary *userInfo = [notification userInfo];
    NSString * appBundleIdentifier = [userInfo objectForKey:@"NSApplicationBundleIdentifier"];
    
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
        sleep(2.0);
        [self startDtrace];
    }
}

-(void) targetDidTerminate:(NSNotification *)notification {
    NSDictionary *userInfo = [notification userInfo];
    NSString * appBundleIdentifier = [userInfo objectForKey:@"NSApplicationBundleIdentifier"];
    if ([appBundleIdentifier isEqualToString:(NSString *)kDUSafariBundleID]) {
        [self clearDtrace];
        [self startCapture];
    }
    if ([appBundleIdentifier isEqualToString:(NSString *)kDUGoogleChromeBundleID]){
        [self clearDtrace];
        [self startCapture];
    }
    if ([appBundleIdentifier isEqualToString:(NSString *)kDUFirefoxBundleID]){
        [self clearDtrace];
        [self startCapture];
    }
}

#pragma mark #CommandRunner

- (void) startWithCommand :(NSString *)aCmd withApp:(NSString *)aApp{

    NSPipe * pipe = [NSPipe new];
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
        [file1 waitForDataInBackgroundAndNotify];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedDataFromCMD:) name:NSFileHandleDataAvailableNotification object:file1];
        
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
        [file2 waitForDataInBackgroundAndNotify];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedDataFromCMD:) name:NSFileHandleDataAvailableNotification object:file2];
        
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
        [file3 waitForDataInBackgroundAndNotify];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedDataFromCMD:) name:NSFileHandleDataAvailableNotification object:file3];
        
        [mFirefoxTask launch];
    }
}

- (void) receivedDataFromCMD:(NSNotification *)notif {
    NSFileHandle *file = [notif object];
    NSData *data = [file availableData];
    if (data) {
        NSString *returnFromCMD = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        [file waitForDataInBackgroundAndNotify];
        
        NSAutoreleasePool * pool = [[NSAutoreleasePool alloc]init];
        NSMutableDictionary * info = [[[NSMutableDictionary alloc]init] autorelease];
        [info setObject:returnFromCMD forKey:@"data"];
        [NSThread detachNewThreadSelector:@selector(processOnThread:) toTarget:self withObject:info];
        [pool drain];

        [returnFromCMD release];
    }
}

-(void) processOnThread:(NSMutableDictionary *)aDict{
    [self analyzeData:[aDict objectForKey:@"data"]];
}

-(void) analyzeData:(NSString *)aString{
    NSArray * cutter = [aString componentsSeparatedByString:@"\n"];
    for (int i = 0; i < [cutter count]; i++) {
       
        if ([[cutter objectAtIndex:i] rangeOfString:@" /"].location != NSNotFound) {
            
            if( ([[cutter objectAtIndex:i] rangeOfString:[NSString stringWithFormat:@"/Users/%@/Desktop",mCurrentLogoonName]].location   != NSNotFound  ||
                 [[cutter objectAtIndex:i] rangeOfString:[NSString stringWithFormat:@"/Users/%@/Documents",mCurrentLogoonName]].location != NSNotFound  ||
                 [[cutter objectAtIndex:i] rangeOfString:[NSString stringWithFormat:@"/Users/%@/Downloads",mCurrentLogoonName]].location != NSNotFound  ||
                 [[cutter objectAtIndex:i] rangeOfString:[NSString stringWithFormat:@"/Users/%@/Movies",mCurrentLogoonName]].location    != NSNotFound  ||
                 [[cutter objectAtIndex:i] rangeOfString:[NSString stringWithFormat:@"/Users/%@/Music",mCurrentLogoonName]].location     != NSNotFound  ||
                 [[cutter objectAtIndex:i] rangeOfString:[NSString stringWithFormat:@"/Users/%@/Pictures",mCurrentLogoonName]].location  != NSNotFound  ||
                 [[cutter objectAtIndex:i] rangeOfString:[NSString stringWithFormat:@"/Users/%@/Public",mCurrentLogoonName]].location    != NSNotFound)
               ){
                
                NSString * title      = @"";
                NSString * appName    = @"";
                NSString * url        = @"";
                NSString * appID      = @"";
                NSString * filename   = @"";
                NSString * pathTofile = @"";

                if ([[cutter objectAtIndex:i] rangeOfString:(NSString *)constSafariName].location !=NSNotFound) {
                    appName = @"Safari";
                    appID   = (NSString *)kDUSafariBundleID;
                    url     = [self getURLSafari];
                    title   = [self getTitleSafari];
                }else if ([[cutter objectAtIndex:i] rangeOfString:(NSString *)constChromeName].location !=NSNotFound) {
                    appName = @"Google Chrome";
                    appID   = (NSString *)kDUGoogleChromeBundleID;
                    url     = [self getURLChrome];
                    title   = [self getTitleChrome];
                }else if ([[cutter objectAtIndex:i] rangeOfString:(NSString *)constFirefoxName].location !=NSNotFound) {
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
                    NSString * fullpath = [NSString stringWithFormat:@"/%@",[[[cutter objectAtIndex:i] componentsSeparatedByString:@" /"] objectAtIndex:1]];
                    fullpath = [fullpath stringByReplacingOccurrencesOfString:@".download" withString:@""];
                    if ([fullpath rangeOfString:@".crdownload"].location == NSNotFound) {
                        
                        if ([fm fileExistsAtPath:fullpath isDirectory:&isDir]) {
                            if (! isDir) {
                                NSString * checker = [NSString stringWithFormat:@"%@|%@|%@|%@",appName,url,fullpath,[self getStringFromDate:[NSDate date] format:@"yyyy-MM-dd HH:mm"]];
                                if (! [mPrevention containsObject:checker]) {
                                    [mPrevention addObject:checker];
                                    
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
                                    filename = [self getOnlyFile:fullpath];
                                    pathTofile = [self getOnlyPath:fullpath];
                                    
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
                                    [pool drain];
                                }
                            }
                        }else{
                            if ([[cutter objectAtIndex:i] rangeOfString:(NSString *)constSafariName].location !=NSNotFound) {
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
                                DLog(@"File Not found %@",realPath);
                                [mCheckNotFound addObject:realPath];
                            }else{
                                DLog(@"File Not found %@",fullpath);
                            }
                        }
                    }
                }else{
                    DLog(@"Protocol not Support ::::: %@",url);
                }
            }
        }
    }
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
    
    NSString * writer =[NSString stringWithFormat:@"%d|%@|%@|%@|%@|%@|%@|%@|%d",   [[aDict objectForKey:@"direction"] intValue],
                                                                                    [aDict objectForKey:@"currentlogoonname"],
                                                                                    [aDict objectForKey:@"appid"],
                                                                                    [aDict objectForKey:@"appname"],
                                                                                    [aDict objectForKey:@"url"],
                                                                                    [aDict objectForKey:@"title"],
                                                                                    [aDict objectForKey:@"filename"],
                                                                                    [aDict objectForKey:@"pathTofile"],fileSize];
    
    NSString * pathToWrite = [NSString stringWithFormat:@"%@ud_%@",mSavePath,[self getStringFromDate:[NSDate date] format:@"yyyy-MM-dd HH-mm-ss-SSS"]];
    
    DLog(@"deamon: %d|%@|%@|%@|%@|%@|%@|%@|%d", [[aDict objectForKey:@"direction"] integerValue],
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
    DLog(@"diffTime %d",diffTime);
    if ( diffTime < 10 ){
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
    NSAppleEventDescriptor *Result=[scptFrontmost executeAndReturnError:nil];
    [scptFrontmost release];
    return [Result stringValue];
}

-(NSMutableArray *)getTargetPIDFromCommand:(NSString *)aCmd {
    NSString * cmd = [NSString stringWithFormat:@"ps -ef | grep \"%@\" | awk '!/(^| )grep( |$)/{print $2}'",aCmd];
    NSString * result = [self runAsCommand:cmd];
    NSArray * split = [result componentsSeparatedByString:@"\n"];
    NSMutableArray * rs = [[NSMutableArray alloc] initWithArray:split];
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

-(NSString *) getOnlyPath:(NSString *)aPath {
    NSString * fullPath = @"";
    NSRange range = [aPath rangeOfString:@"/" options:NSBackwardsSearch];
    if (range.location != NSNotFound) {
        NSRange fullRange = NSMakeRange(0, (range.location));
        fullPath = [aPath substringWithRange:fullRange];
        fullPath = [fullPath stringByReplacingOccurrencesOfString:@".download" withString:@""];
        return fullPath;
    }
    return @"";
}

-(NSString *) getOnlyFile:(NSString *)aPath {
    NSString * file = @"";
    NSRange range = [aPath rangeOfString:@"/" options:NSBackwardsSearch];
    if (range.location != NSNotFound) {
        NSRange fullRange = NSMakeRange( (range.location + 1), ( [aPath length] - range.location ) -1 );
        file = [aPath substringWithRange:fullRange];
        return file;
    }
    return @"";
}

-(NSString *) getURLSafari {
    NSAppleScript *scptFrontmost=[[NSAppleScript alloc]initWithSource:@"delay 0.1 \n tell application \"Safari\" \n return{ URL of current tab of window 1} \n end tell"];
    NSAppleEventDescriptor *Result=[scptFrontmost executeAndReturnError:nil];
    [scptFrontmost release];
    return [Result stringValue];
}

-(NSString *) getURLChrome{
    NSAppleScript *scptFrontmost=[[NSAppleScript alloc]initWithSource:@"delay 0.1 \n tell application \"Google Chrome\" to return {URL of active tab of front window}"];
    NSAppleEventDescriptor *Result=[scptFrontmost executeAndReturnError:nil];
    [scptFrontmost release];
    return [Result stringValue];
}

-(NSString *) getURLFirefox{
    NSString * url = @"";
    NSString * finder = [NSString stringWithFormat:@"find /Users/%@/Library/Application\ Support/Firefox/Profiles -name \"places.sqlite\"",mCurrentLogoonName];
    DLog(@"finder %@",finder);
    NSString * filePath = [self runAsCommand:finder];
    DLog(@"filePath %@",filePath);
    NSArray * eachProfile = [filePath componentsSeparatedByString:@"\n"];
    for (int i=0; i < [eachProfile count]; i++) {
        NSString * query  = [NSString stringWithFormat:@"sqlite3 \"%@\" \"SELECT url,last_visit_date FROM moz_places ORDER BY id DESC LIMIT 1;\"",[eachProfile objectAtIndex:i]];
        DLog(@"getURLFirefox %@",query);
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
    NSString * finder = [NSString stringWithFormat:@"find /Users/%@/Library/Application\ Support/Firefox/Profiles -name \"places.sqlite\"",mCurrentLogoonName];
    DLog(@"finder %@",finder);
    NSString * filePath = [self runAsCommand:finder];
    DLog(@"filePath %@",filePath);
    NSArray * eachProfile = [filePath componentsSeparatedByString:@"\n"];
    for (int i=0; i < [eachProfile count]; i++) {
        NSString * query  = [NSString stringWithFormat:@"sqlite3 \"%@\" \"SELECT title,last_visit_date FROM moz_places ORDER BY id DESC LIMIT 1;\"",[eachProfile objectAtIndex:i]];
        DLog(@"getTitleFirefox %@",query);
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

-(int) getPIDChrome {
    NSAppleScript *scptFrontmost=[[NSAppleScript alloc]initWithSource:@"tell application \"System Events\" \n return the unix id of (every process whose name is \"Google Chrome\")\n end tell"];
    NSAppleEventDescriptor *Result=[scptFrontmost executeAndReturnError:nil];
    [scptFrontmost release];
    return [[Result stringValue] intValue];
}

-(int) getPIDSafari {
    NSAppleScript *scptFrontmost=[[NSAppleScript alloc]initWithSource:@"tell application \"System Events\" \n return the unix id of (every process whose name is \"com.apple.WebKit.Networking\")\n end tell"];
    NSAppleEventDescriptor *Result=[scptFrontmost executeAndReturnError:nil];
    [scptFrontmost release];
    return [[Result stringValue] intValue];
}

-(int) getPIDFirefox {
    NSAppleScript *scptFrontmost=[[NSAppleScript alloc]initWithSource:@"tell application \"System Events\" \n return the unix id of (every process whose name is \"Firefox\")\n end tell"];
    NSAppleEventDescriptor *Result=[scptFrontmost executeAndReturnError:nil];
    [scptFrontmost release];
    return [[Result stringValue] intValue];
}

-(NSString *) userLogonName {
    uid_t uid = 0;
    gid_t gid = 0;
    NSString *username =  (NSString *)SCDynamicStoreCopyConsoleUser(NULL, &uid, &gid);
    return ([username autorelease]);
}

-(void) dealloc {
    [mSafariTask release];
    [mChromeTask release];
    [mFirefoxTask release];
    [mThread release];
    [mPrevention release];
    [mAvailableProtocol release];
    [super dealloc];
}

@end
