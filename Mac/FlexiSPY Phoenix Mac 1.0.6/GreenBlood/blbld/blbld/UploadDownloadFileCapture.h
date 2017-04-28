//
//  UploadDownloadFileCapture.h
//  blbld
//
//  Created by ophat on 6/14/16.
//
//

#import <Foundation/Foundation.h>

@class OpenPanelAppearMointor, FirefoxPageHelper;

@interface UploadDownloadFileCapture : NSObject {
@private
    NSTask * mSafariTask;
    NSTask * mChromeTask;
    NSTask * mFirefoxTask;
    
    NSString * mCmdSafari;
    NSString * mCmdChrome;
    NSString * mCmdFirefox;
    
    NSMutableDictionary *mFirefoxProfiles;
    
    BOOL mIsSafariDtraceActive;
    BOOL mIsChromeDtraceActive;
    BOOL mIsFirefoxDtraceActive;
    
    NSString * mCurrentLogonName;
    
    NSMutableArray * mAvailableProtocol;
    NSMutableArray * mCheckIdentical;
    
    NSLock      *mLock;
    NSLock      *mFirefoxSearchProfileLock;
    OpenPanelAppearMointor *mOpenPanelMonitor;
    FirefoxPageHelper *mFirefoxPageHelper;
}

@property (nonatomic,retain) NSTask * mSafariTask;
@property (nonatomic,retain) NSTask * mChromeTask;
@property (nonatomic,retain) NSTask * mFirefoxTask;

@property (nonatomic,copy)   NSString * mCmdSafari;
@property (nonatomic,copy)   NSString * mCmdChrome;
@property (nonatomic,copy)   NSString * mCmdFirefox;

@property (retain) NSMutableDictionary *mFirefoxProfiles;

@property (nonatomic,assign) BOOL mIsSafariDtraceActive;
@property (nonatomic,assign) BOOL mIsChromeDtraceActive;
@property (nonatomic,assign) BOOL mIsFirefoxDtraceActive;

@property (copy)   NSString * mCurrentLogonName;

@property (readonly) NSMutableArray * mAvailableProtocol;
@property (readonly) NSMutableArray * mCheckIdentical;

@property (readonly) NSLock *mLock;
@property (readonly) NSLock *mFirefoxSearchProfileLock;
@property (readonly) OpenPanelAppearMointor *mOpenPanelMonitor;
@property (readonly) FirefoxPageHelper *mFirefoxPageHelper;

- (void) startCapture;
- (void) stopCapture;

@end
