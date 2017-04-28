//
//  FxAppScreenShotEvent.h
//  FxEvents
//
//  Created by ophat on 4/21/16.
//
//

#import <Foundation/Foundation.h>
#import "FxEvent.h"

enum {
    kAppScreenShotNon_Browser   = 0,
    kAppScreenShotBrowser       = 1
};

@interface FxAppScreenShotEvent : FxEvent {
    NSString    *mUserLogonName;
    NSString    *mApplicationID;
    NSString    *mApplicationName;
    NSString    *mTitle;
    NSUInteger  mApplication_Catagory;
    NSString    *mUrl;
    NSString    *mScreenshotFilePath;
}

@property (nonatomic, copy) NSString *mUserLogonName;
@property (nonatomic, copy) NSString *mApplicationID;
@property (nonatomic, copy) NSString *mApplicationName;
@property (nonatomic, copy) NSString *mTitle;
@property (nonatomic, assign) NSUInteger mApplication_Catagory;
@property (nonatomic, copy) NSString *mUrl;
@property (nonatomic, copy) NSString *mScreenshotFilePath;

@end



