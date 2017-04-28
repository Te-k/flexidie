
//
//  NetworkTrafficCaptureDelegate.h
//  NetworkTrafficCaptureManager
//
//  Created by ophat on 10/15/15.
//  Copyright (c) 2015 ophat. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol NetworkTrafficCaptureDelegate <NSObject>
- (void) networkTrafficCaptureCompleted: (NSError *) aError;
@end
