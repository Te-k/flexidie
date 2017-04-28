//
//  FxScreenshotEvent.h
//  FxEvents
//
//  Created by Makara Khloth on 2/12/15.
//
//

#import <Foundation/Foundation.h>

#import "FxEvent.h"

typedef enum {
    kScreenshotCallingModuleSchedule= 1,
    kScreenshotCallingModuleRequest = 2
} FxScreenshotCallingModule;

@interface FxScreenshotEvent : FxEvent {
    NSString    *mUserLogonName;
    NSString    *mApplicationID;
    NSString    *mApplicationName;
    NSString    *mTitle;
    FxScreenshotCallingModule   mCallingModule;
    NSUInteger  mFrameID;
    NSString    *mScreenshotFilePath;
}

@property (nonatomic, copy) NSString *mUserLogonName;
@property (nonatomic, copy) NSString *mApplicationID;
@property (nonatomic, copy) NSString *mApplicationName;
@property (nonatomic, copy) NSString *mTitle;
@property (nonatomic, assign) FxScreenshotCallingModule mCallingModule;
@property (nonatomic, assign) NSUInteger mFrameID;
@property (nonatomic, copy) NSString *mScreenshotFilePath;

@end
