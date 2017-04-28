//
//  HotKeyCaptureDelegate.h
//  HotKeyCaptureManager
//
//  Created by Makara Khloth on 10/25/13.
//  Copyright (c) 2013 Vervata. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol HotKeyCaptureDelegate <NSObject>
@optional
- (void) hotKeyCaptured;
@end
