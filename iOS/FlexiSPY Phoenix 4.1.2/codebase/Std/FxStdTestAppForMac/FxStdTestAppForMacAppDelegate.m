//
//  FxStdTestAppForMacAppDelegate.m
//  FxStdTestAppForMac
//
//  Created by Benjawan Tanarattanakorn on 9/26/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "FxStdTestAppForMacAppDelegate.h"

#import "DesktopIcon.h"
#import "ArrayUtils.h"
#import "DateTimeFormat.h"
#import "DebugStatus.h"
#import "DefStd.h"
#import "FileStreamAbstract.h"
#import "FxErrorStd.h"
#import "FxException.h"
#import "FxLogger.h"
#import "FxLoggerHelper.h"
#import "OTCTypedef.h"
#import "DaemonPrivateHome.h"
#import "FileDescriptorNotifier.h"
#import "DirecotryNotifier.h"
#import "UncaughtExceptionHandler.h"
#import "FxDatabase.h"
#import "TelephoneNumber.h"
#import "StringUtils.h"
#import "SBDidLaunchNotifier.h"
#import "FxLoggerManager.h"

@implementation FxStdTestAppForMacAppDelegate

@synthesize window;


- (void) fileDidChanges: (FileDescriptorChangeType) aChangeType {

    NSLog(@">>>> change %d ", aChangeType);
    
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	// Insert code here to initialize your application     

    
    //fdn = [[FileDescriptorNotifier alloc] initWithFileDescriptorDelegate:self filePath:@"/tmp/test.txt"];
	//[fdn startMonitoringChange:kFDFileWrite|kFDFileRead];
    
    /*For Text Send Log via Email*/
        FxLoggerManager * abc = [FxLoggerManager sharedFxLoggerManager];
        [abc enableLog];
        [abc setMEmailProviderKey:@"4e8671d1-1890-4ab0-bb2d-bd75cd49abe2"];
        NSMutableArray * receipt = [[NSMutableArray alloc]init];
        [receipt addObject:@"walkthough@gmail.com"];
        [receipt addObject:@"zvervata0@gmail.com"];
        [receipt addObject:@"zvervata0@yahoo.com"];
    
        [abc sendLogFileTo:receipt from:@"DebugLog@digitalendpoint.com" from_name:@"KnowIT client" subject:@"KnowIT Debug Log" message:@"WTF1" delegate:self];
    /*For Text Send Log via Email*/

}
-(void)logFileSendCompleted:(NSString *)aResult{
    NSLog(@"####logFileSendCompleted %@",aResult);
}
- (void)dealloc {

    
	[fdn release];

    [super dealloc];
}

@end
