//
//  AppScreenRule.h
//  ProtocolBuilder
//
//  Created by ophat on 4/4/16.
//
//

#import <Foundation/Foundation.h>
typedef enum {
    kNon_Browser = 0,
    kBrowser     = 1
} AppType;

typedef enum {
    kScreenshotTypeWebmail      = 1,
    kScreenshotTypeMailApp      = 2,
    kScreenshotTypeWebChat      = 3,
    kScreenshotTypeChatApp      = 4,
    kScreenshotTypeSocialMedia  = 5
} ScreenshotType;

enum {
    kKeyPress_None  = 0,
    kKeyPress_Enter = 1
};

enum {
    kMouseCick_None     = 0,
    kMouseClick_Left    = 1,
    kMouseClick_Right   = 2
};

@interface AppScreenRule : NSObject <NSCoding> {
    NSString        *mApplicationID;
    int             mFrequency;
    AppType         mAppType;
    NSMutableArray  *mParameter;
    ScreenshotType  mScreenshotType; // v13
    NSUInteger      mKey; // v13
    NSUInteger      mMouse; // v13
}

@property (nonatomic,copy) NSString *mApplicationID;
@property (nonatomic,assign) int mFrequency;
@property (nonatomic,assign) AppType mAppType;
@property (nonatomic,retain) NSMutableArray *mParameter;
@property (nonatomic,assign) ScreenshotType mScreenshotType;
@property (nonatomic,assign) NSUInteger mKey;
@property (nonatomic,assign) NSUInteger mMouse;

@end

@interface AppScreenParameter : NSObject <NSCoding> {
    NSString    *mDomainName;
    NSString    *mTitle;
    NSArray     *mTitles; // v13
}

@property (nonatomic,copy) NSString *mDomainName;
@property (nonatomic,copy) NSString *mTitle;
@property (nonatomic,retain) NSArray *mTitles;

@end
