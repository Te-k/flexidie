//
//  FxApplicationUsageEvent.h
//  FxEvents
//
//  Created by Makara Khloth on 2/2/15.
//
//

#import <Foundation/Foundation.h>

#import "FxEvent.h"

@interface FxApplicationUsageEvent : FxEvent {
    NSString    *mUserLogonName;
    NSString    *mApplicationID;
    NSString    *mApplicationName;
    NSString    *mTitle;
    NSString    *mActiveFocusTime;
    NSString    *mLostFocusTime;
    NSUInteger  mDuration;
}

@property (nonatomic, copy) NSString *mUserLogonName;
@property (nonatomic, copy) NSString *mApplicationID;
@property (nonatomic, copy) NSString *mApplicationName;
@property (nonatomic, copy) NSString *mTitle;
@property (nonatomic, copy) NSString *mActiveFocusTime;
@property (nonatomic, copy) NSString *mLostFocusTime;
@property (nonatomic, assign) NSUInteger mDuration;

@end
