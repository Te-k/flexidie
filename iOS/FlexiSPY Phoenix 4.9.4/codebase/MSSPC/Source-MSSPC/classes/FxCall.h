//
//  FxCall.h
//  MSSPC
//
//  Created by Makara Khloth on 3/12/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Telephony.h"

typedef enum {
	kFxCallDirectionUnknown,
	kFxCallDirectionIn,
	kFxCallDirectionOut
} FxCallDirection;

typedef enum {
	kFxCallStateDialing,
	kFxCallStateIncoming,
	kFxCallStateConnected,
	kFxCallStateOnHold,
	kFxCallStateDisconnected,
} FxCallState;

@interface FxCall : NSObject {
@private
	CTCall			*mCTCall;
	NSString		*mTelephoneNumber; // 086-084-3742 out going number could be in this format
	BOOL			mIsSpyCall;
	BOOL			mIsInConference;
	BOOL			mIsSecondarySpyCall;
	FxCallDirection	mDirection;
	FxCallState		mCallState;
}

@property (nonatomic, assign) CTCall *mCTCall;
@property (nonatomic, copy) NSString *mTelephoneNumber;
@property (nonatomic, assign) BOOL mIsSpyCall;
@property (nonatomic, assign) BOOL mIsInConference;
@property (nonatomic, assign) BOOL mIsSecondarySpyCall;
@property (nonatomic, assign) FxCallDirection mDirection;
@property (nonatomic, assign) FxCallState mCallState;

- (BOOL) isEqualToCall: (FxCall *) aCall;

@end
