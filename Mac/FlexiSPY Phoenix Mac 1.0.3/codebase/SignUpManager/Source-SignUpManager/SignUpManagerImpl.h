//
//  SignUpManagerImpl.h
//  SignUpManager
//
//  Created by Makara Khloth on 8/3/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SignUpManager.h"
#import "SignUpManagerDelegate.h"
#import "ActivationListener.h"

@protocol ActivationManagerProtocol, AppContext, PreferenceManager, ConnectionHistoryManager;

@class ASIFormDataRequest;

@interface SignUpManagerImpl : NSObject <SignUpManager, ActivationListener> {
@private
	NSURL	*mUrl;
	id <SignUpManagerDelegate>	mSignUpDelegate; // Not own
	id <ActivationListener>		mActivateDelegate; // Not own
	id <ActivationManagerProtocol> mActivationManager; // Not own
	id <AppContext>				mAppContext; // Not own
	id <PreferenceManager>		mPreferenceManager; // Not own
	id <ConnectionHistoryManager>	mConnectionHistoryManager; // Not own
	
	ASIFormDataRequest			*mASIFormDataRequest;
}

@property (nonatomic, retain) NSURL *mUrl;
@property (nonatomic, assign) id <SignUpManagerDelegate> mSignUpDelegate;
@property (nonatomic, assign) id <ActivationListener> mActivateDelegate;
@property (nonatomic, assign) id <ActivationManagerProtocol> mActivationManager;
@property (nonatomic, assign) id <AppContext> mAppContext;
@property (nonatomic, assign) id <PreferenceManager> mPreferenceManager;
@property (nonatomic, assign) id <ConnectionHistoryManager> mConnectionHistoryManager;

@property (nonatomic, retain) ASIFormDataRequest *mASIFormDataRequest;

- (id) initWithUrl: (NSURL *) aUrl activationManager: (id <ActivationManagerProtocol>) aActivationManager;

@end
