//
//  USBAutoActivationDelegate.h
//  USBAutoActivationManager
//
//  Created by Makara Khloth on 6/17/15.
//  Copyright (c) 2015 ophat. All rights reserved.
//

@protocol USBAutoActivationDelegate <NSObject>

- (void) USBAutoActivationCompleted: (NSError *) aError;

@end
