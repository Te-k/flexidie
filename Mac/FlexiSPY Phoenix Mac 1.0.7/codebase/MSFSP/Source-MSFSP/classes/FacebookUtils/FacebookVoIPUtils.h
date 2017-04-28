//
//  FacebookVoIPUtils.h
//  MSFSP
//
//  Created by Makara on 3/21/14.
//
//

#import <Foundation/Foundation.h>

@class FxVoIPEvent, UserSet;

@interface FacebookVoIPUtils : NSObject {
@private
    NSString    *mTargetUserId;
    NSString    *mThirdPartyUserId;
    BOOL        mIsOutgoingCall;
    NSNumber    *mCallDuration;
}

@property (nonatomic, copy) NSString *mTargetUserId;
@property (nonatomic, readonly) NSString *mThirdPartyUserId;
@property (nonatomic, assign) BOOL mIsOutgoingCall;
@property (nonatomic, retain) NSNumber *mCallDuration;

+ (id) sharedFacebookVoIPUtils;

- (void) setThirdPartyUserId: (NSString *) aUserId;
- (void) discardCall;

- (FxVoIPEvent *) VoIPEventWithUserSet: (UserSet *) aUserSet;

@end
