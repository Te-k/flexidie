//
//  AgentKeyboardACCaptureManager.h
//  kbls
//
//  Created by Makara Khloth on 6/18/16.
//  Copyright © 2016 Makara Khloth. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "HotKeyCaptureDelegate.h"

@interface AgentKeyboardACCaptureManager : NSObject <HotKeyCaptureDelegate>

@property (nonatomic, strong) NSString *activationCode;

@end
