//
//  UserActivityMonitor.h
//  UserActivityCaptureManager
//
//  Created by Makara Khloth on 2/16/15.
//  Copyright (c) 2015 Makara Khloth. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserActivityMonitor : NSObject {
    id mDelegate;
    SEL mSelector;
    
    NSDate *mRecentLogoffDate;
}

@property (nonatomic, assign) id mDelegate;
@property (nonatomic, assign) SEL mSelector;

@property (nonatomic, retain) NSDate *mRecentLogoffDate;

- (void) startMonitor;
- (void) stopMonitor;

@end
