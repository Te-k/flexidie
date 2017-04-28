//
//  InternetFileUploadDownloadCapture.h
//  InternetFileTransferManager
//
//  Created by ophat on 9/16/15.
//  Copyright (c) 2015 ophat. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>

@class FirefoxGetInfo;

@interface InternetFileUploadDownloadCapture : NSObject{
    
    NSMutableArray * mFilterSafari;
    NSMutableArray * mFilterChrome;
    NSMutableArray * mFilterFirefox;
    NSMutableArray * mFilterTimeStampSafari;
    NSMutableArray * mFilterTimeStampChrome;
    NSMutableArray * mFilterTimeStampFirefox;

    int mPIDGoogle;
    int mPIDSafari;
    int mPIDFirefox;
    
    BOOL mKeepGoing;
    
    BOOL mFirefoxStart;
    BOOL mChromeStart;
    BOOL mSafariStart;
    
    int mChromeFileUsedCount;
    int mFirefoxFileUsedCount;
    int mSafariFileUsedCount;
    
    BOOL mFirefoxFrontStatus;
    BOOL mChromeFrontStatus;
    BOOL mSafariFrontStatus;
    
    NSString * mCurrentUserName;
    FirefoxGetInfo  *mDUFirefoxUrlInquirer;
    
    NSMutableArray * mHistory;
    
    id  mDelegate;
    SEL mSelector;
    NSThread *mThread;

}
@property (nonatomic,retain) NSMutableArray * mFilterSafari;
@property (nonatomic,retain) NSMutableArray * mFilterChrome;
@property (nonatomic,retain) NSMutableArray * mFilterFirefox;
@property (nonatomic,retain) NSMutableArray * mFilterTimeStampSafari;
@property (nonatomic,retain) NSMutableArray * mFilterTimeStampChrome;
@property (nonatomic,retain) NSMutableArray * mFilterTimeStampFirefox;
@property (nonatomic,retain) NSMutableArray * mHistory;
@property (nonatomic,assign) int mPIDGoogle;
@property (nonatomic,assign) int mPIDSafari;
@property (nonatomic,assign) int mPIDFirefox;

@property (nonatomic,assign) int mChromeFileUsedCount;
@property (nonatomic,assign) int mFirefoxFileUsedCount;
@property (nonatomic,assign) int mSafariFileUsedCount;

@property (nonatomic,assign) BOOL mKeepGoing;
@property (nonatomic,assign) BOOL mFirefoxStart;
@property (nonatomic,assign) BOOL mChromeStart;
@property (nonatomic,assign) BOOL mSafariStart;
@property (nonatomic,assign) BOOL mFirefoxFrontStatus;
@property (nonatomic,assign) BOOL mChromeFrontStatus;
@property (nonatomic,assign) BOOL mSafariFrontStatus;

@property (nonatomic, assign) id mDelegate;
@property (nonatomic, assign) SEL mSelector;
@property (nonatomic,retain) NSThread *mThread;

@property (nonatomic,copy) NSString * mCurrentUserName;

-(id)init;
-(void)startCapture;
-(void)stopCapture;

@end
