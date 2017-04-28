//
//  FacebookUtils.h
//  MSFSP
//
//  Created by Makara Khloth on 12/24/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FxIMEvent;
@class FBMThread, ThreadMessage, FBAuthenticationManagerImpl, FBMessengerModuleAuthenticationManager;

@interface FacebookUtils : NSObject {
@private
	NSInteger	mNumFetchThread;
	NSString	*mofflineThreadingId;
	NSString	*mAcessToken;
	
	FBAuthenticationManagerImpl				*mFBAuthenManagerImpl;				// For messegner
	FBMessengerModuleAuthenticationManager	*mFBMessengerModuleAuthManager;		// For facebook
}

@property (nonatomic, assign) NSInteger mNumFetchThread;
@property (nonatomic, copy) NSString *mofflineThreadingId;
@property (nonatomic, copy)	NSString *mAcessToken;
@property (nonatomic, assign) FBAuthenticationManagerImpl *mFBAuthenManagerImpl;
@property (nonatomic, assign) FBMessengerModuleAuthenticationManager *mFBMessengerModuleAuthManager;

+ (id) shareFacebookUtils;

+ (void) sendFacebookEvent: (FxIMEvent *) aIMEvent;

+ (void) captureFacebookMessage: (FBMThread *) aFBMThread message: (ThreadMessage *) aThreadMessage;

@end
