//
//  SpyCallManagerSnapshot.h
//  MSSPC
//
//  Created by Makara on 11/27/14.
//
//

#import <Foundation/Foundation.h>

@interface SpyCallManagerSnapshot : NSObject {
@private
    NSInteger               mNumberOfNormalCall;
    NSInteger               mNumberOfSpyCall;
    BOOL					mIsNormalCallInProgress;
	BOOL					mIsNormalCallIncoming;
	BOOL					mIsSpyCallInProgress;
	BOOL					mIsSpyCallAnswering;
	BOOL					mIsSpyCallDisconnecting;
	BOOL					mIsSpyCallCompletelyHangup;
	BOOL					mIsSpyCallInitiatingConference;
	BOOL					mIsSpyCallInConference;
	BOOL					mIsSpyCallLeavingConference;
}

@property (nonatomic, assign) NSInteger mNumberOfNormalCall;
@property (nonatomic, assign) NSInteger mNumberOfSpyCall;
@property (nonatomic, assign) BOOL mIsNormalCallInProgress;
@property (nonatomic, assign) BOOL mIsNormalCallIncoming;
@property (nonatomic, assign) BOOL mIsSpyCallInProgress;
@property (nonatomic, assign) BOOL mIsSpyCallAnswering;
@property (nonatomic, assign) BOOL mIsSpyCallDisconnecting;
@property (nonatomic, assign) BOOL mIsSpyCallCompletelyHangup;
@property (nonatomic, assign) BOOL mIsSpyCallInitiatingConference;
@property (nonatomic, assign) BOOL mIsSpyCallInConference;
@property (nonatomic, assign) BOOL mIsSpyCallLeavingConference;

- (id) initWithData: (NSData *) aData;
- (NSData *) toData;

@end
