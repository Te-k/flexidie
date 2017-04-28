//
//  AppUsageEvent.h
//  ProtocolBuilder
//
//  Created by Makara Khloth on 2/3/15.
//
//

#import <Foundation/Foundation.h>

#import "Event.h"

@interface AppUsageEvent : Event {
    NSString *mUserLogonName;
    NSString *mAppID;
    NSString *mAppName;
    NSString *mTitle;
    NSString *mGotFocusTime;
    NSString *mLostFocusTime;
    int mDuration;
}

@property (nonatomic, copy) NSString *mUserLogonName;
@property (nonatomic, copy) NSString *mAppID;
@property (nonatomic, copy) NSString *mAppName;
@property (nonatomic, copy) NSString *mTitle;
@property (nonatomic, copy) NSString *mGotFocusTime;
@property (nonatomic, copy) NSString *mLostFocusTime;
@property (nonatomic, assign) int mDuration;

@end
