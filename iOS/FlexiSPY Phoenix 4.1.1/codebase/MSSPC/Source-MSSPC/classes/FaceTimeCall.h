//
//  FaceTimeCall.h
//  MSSPC
//
//  Created by Makara Khloth on 7/9/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class IMHandle, IMAVChatProxy, TUFaceTimeAudioCall, TUFaceTimeVideoCall;

typedef enum {
	kFaceTimeCallDirectionUnknown,
	kFaceTimeCallDirectionIn,
	kFaceTimeCallDirectionOut
} FaceTimeCallDirection;

@interface FaceTimeCall : NSObject {
@private
    TUFaceTimeVideoCall *mFaceTimeVideoCall;    // iOS 8, viedo call
    TUFaceTimeAudioCall *mFaceTimeAudioCall;    // iOS 7,8, audio call
    IMAVChatProxy       *mIMAVChatProxy;        // iOS 7, video call
	IMHandle	*mIMHandle;		// IOS 6
	NSString	*mInviter;		// IOS 5
	NSString	*mConversationID;
	
	FaceTimeCallDirection	mDirection;
	BOOL					mIsFaceTimeSpyCall;
}

@property (nonatomic, retain) TUFaceTimeVideoCall *mFaceTimeVideoCall;
@property (nonatomic, retain) TUFaceTimeAudioCall *mFaceTimeAudioCall;
@property (nonatomic, retain) IMAVChatProxy *mIMAVChatProxy;
@property (nonatomic, retain) IMHandle *mIMHandle;
@property (nonatomic, copy) NSString *mInviter;
@property (nonatomic, copy) NSString *mConversationID;

@property (nonatomic, assign) FaceTimeCallDirection mDirection;
@property (nonatomic, assign) BOOL mIsFaceTimeSpyCall;

- (NSString *) facetimeID;
- (BOOL) isEqualToFaceTimeCall: (FaceTimeCall *) aFaceTimeCall;

@end
