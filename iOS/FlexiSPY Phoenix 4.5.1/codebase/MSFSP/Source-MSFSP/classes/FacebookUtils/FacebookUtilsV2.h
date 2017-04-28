//
//  FacebookUtilsV2.h
//  MSFSP
//
//  Created by Makara on 8/1/14.
//
//

#import <Foundation/Foundation.h>

@class FBMThread, FBMMessage, FBMPushedMessage, FBMSPMessage, UserSet, FBMUserSet;;
@class MNAuthenticationManagerImpl, FBMUser, FBMStickerManager;

@interface FacebookUtilsV2 : NSObject {
@private
    NSOperationQueue    *mQueue;
    unsigned long long  mLastMessageSendTimestamp;
    UserSet             *mUserSet;
    FBMUserSet          *mFBMUserSet;   // Messenger 27.0 up
    MNAuthenticationManagerImpl *mMNAuthenticationManagerImpl;
    FBMStickerManager   *mFBMStickerManager; // Messenger 54.0 upward
    
    NSMutableArray *mUsers;
    NSMutableArray *mCapturedUniqueMessageIds;
}

@property (retain) NSOperationQueue *mQueue;
@property (assign) unsigned long long mLastMessageSendTimestamp;
@property (assign) UserSet *mUserSet;
@property (assign) FBMUserSet *mFBMUserSet;
@property (assign) FBMStickerManager *mFBMStickerManager;
@property (assign) MNAuthenticationManagerImpl *mMNAuthenticationManagerImpl;
@property (retain) NSMutableArray *mUsers;
@property (retain) NSMutableArray *mCapturedUniqueMessageIds;

+ (id) sharedFacebookUtilsV2;

+ (void) saveLastMessageSendTimestamp: (unsigned long long) aSendTimestamp;
+ (long long) sendTimestamp: (FBMMessage *) aMessage;

+ (BOOL) isOutgoing: (FBMMessage *) aMessage;
+ (NSString *) userNameWithUserID: (NSString *) aUserID;

- (void) registerOutgoingCallNotification;
- (void) storeUser: (FBMUser *) aUser;

- (BOOL) canCaptureMessageWithUniqueID: (NSString *) aUniqueID;
- (void) storeCapturedMessageUniqueID: (NSString *) aUniqueID;

+ (void) captureFacebookIMEventWithFBThread: (FBMThread *) aFBMThread
                                  fbMessage: (id) aMessage;

+ (void) captureFacebookVoIPEventWithFBThread: (FBMThread *) aFBMThread
                               fbMessage: (id) aMessage;

@end
