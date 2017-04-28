//
//  SignUpManagerImpl.m
//  SignUpManager
//
//  Created by Makara Khloth on 8/3/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "SignUpManagerImpl.h"
#import "SignUpRequest.h"
#import "SignUpResponse.h"
#import "SignUpInfo.h"

#import "ActivationManagerProtocol.h"
#import "ActivationListener.h"
#import "ActivationInfo.h"
#import "ActivationResponse.h"
#import "AppContext.h"
#import "PhoneInfo.h"
#import "ProductInfo.h"
#import "PreferenceManager.h"
#import "PrefSignUp.h"
#import "DefStd.h"
#import "ConnectionHistoryManager.h"
#import "DefConnectionHistory.h"

#import "ASIFormDataRequest.h"

@implementation SignUpManagerImpl

@synthesize mUrl;
@synthesize mSignUpDelegate;
@synthesize mActivateDelegate;
@synthesize mActivationManager;
@synthesize mAppContext;
@synthesize mPreferenceManager;
@synthesize mConnectionHistoryManager;

@synthesize mASIFormDataRequest;

- (id) initWithUrl: (NSURL *) aUrl activationManager: (id <ActivationManagerProtocol>) aActivationManager {
    if ((self = [super init])) {
        [self setMUrl:aUrl];
		[self setMActivationManager:aActivationManager];
    }
    return (self);
}

- (void) clearSignUpInfo {
	PrefSignUp *prefSignUp = (PrefSignUp *)[mPreferenceManager preference:kSignUp];
	[prefSignUp reset];
	[mPreferenceManager savePreference:prefSignUp];
}

- (SignUpInfo *) signUpInfo {
	PrefSignUp *prefSignUp = (PrefSignUp *)[mPreferenceManager preference:kSignUp];
	SignUpInfo *signUpInfo = [[[SignUpInfo alloc] init] autorelease];
	[signUpInfo setMIsSignedUp:[prefSignUp mSignedUp]];
	[signUpInfo setMSignUpActivationCode:[prefSignUp mActivationCode]];
	return (signUpInfo);
}

- (void) signUp: (SignUpRequest *) aRequest signUpDelegate: (id <SignUpManagerDelegate>) aDelegate {
    DLog(@"======= Sign up start ========");
	
    // Set delegate
    [self setMSignUpDelegate:aDelegate];
	[self setMActivateDelegate:nil];
	
    // Start request
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:mUrl];
	NSString *pID = [NSString stringWithFormat:@"%d", [aRequest mProductID]];
	NSString *configID = [NSString stringWithFormat:@"%d", [aRequest mConfigurationID]];
    [request setPostValue:pID forKey:@"productId"];
    [request setPostValue:configID forKey:@"configurationId"];
    [request setPostValue:[aRequest mEmail] forKey:@"email"];
    [request setDelegate:self];
    [request setTimeOutSeconds:60];
    [request startAsynchronous];
	[self setMASIFormDataRequest:request];
}

- (void) signUpActivate: (SignUpRequest *) aSignUpRequest
		 signUpDelegate: (id <SignUpManagerDelegate>) aSignUpDelegate
	 activationDelegate: (id <ActivationListener>) aActivateDelegate {
	
	// Flag of task will reset in this function too (from kSignUpOnly to kSignUpActivate)
	
	[self signUp:aSignUpRequest signUpDelegate:aSignUpDelegate];
	
	[self setMActivateDelegate:aActivateDelegate];
}

#pragma mark -
#pragma mark ASIHTTPRequest
#pragma mark -

- (void) requestFinished: (ASIHTTPRequest *) aRequest {    
    DLog(@"======= Sign up finished success ======== %@, headers = %@", aRequest, [aRequest responseHeaders]);
	
    NSString *signUpStatus = [[aRequest responseHeaders] objectForKey:@"signupStatus"];
    NSString *activationCode = [[aRequest responseHeaders] objectForKey:@"activationCode"];
    NSString *message = [[aRequest responseHeaders] objectForKey:@"message"];
	
    DLog(@"signUpStatus = %@, activationCode = %@, message = %@", signUpStatus, activationCode, message);
    
    SignUpResponse *response = [[[SignUpResponse alloc] init] autorelease];
    [response setMStatus:signUpStatus];
    [response setMActivationCode:activationCode];
    [response setMMessage:message];
    
	id <SignUpManagerDelegate> signUpDelegate = [self mSignUpDelegate];
	id <ActivationListener> activateDelegate = [self mActivateDelegate];
	
	[self setMSignUpDelegate:nil];
	
	NSError *error1 = [aRequest error];
	DLog (@"Request http is error = %@", error1);
	
    if (error1 || [signUpStatus isEqualToString:@"ERROR"]) {
		NSError *error2 = [NSError errorWithDomain:@"Sign up error===" code:kUrlSignUpError userInfo:nil];
		
		[self setMActivateDelegate:nil];
		
		// Add connection history
		[mConnectionHistoryManager addApplicationCategoryConnectionHistoryWithCmdAction:kCommandActionSignUpForActivationCode
																			commandCode:kSignUpForActivationCode
																			  errorCode:kUrlSignUpError
																		   errorMessage:[response mMessage]];
        
		if ([signUpDelegate respondsToSelector:@selector(signUpDidFinished:signUpResponse:)]) {
			[signUpDelegate signUpDidFinished:error2 signUpResponse:response];
		}
    } else {
		// Save sign up status
		PrefSignUp *prefSignUp = (PrefSignUp *)[mPreferenceManager preference:kSignUp];
		[prefSignUp setMSignedUp:YES];
		[prefSignUp setMActivationCode:[response mActivationCode]];
		[mPreferenceManager savePreference:prefSignUp];
		
		// Add connection history
		[mConnectionHistoryManager addApplicationCategoryConnectionHistoryWithCmdAction:kCommandActionSignUpForActivationCode
																			commandCode:kSignUpForActivationCode
																			  errorCode:0
																		   errorMessage:@""];
		
		if ([signUpDelegate respondsToSelector:@selector(signUpDidFinished:signUpResponse:)]) {
			[signUpDelegate signUpDidFinished:nil signUpResponse:response];
		}
		
		if (activateDelegate) {
			ActivationInfo *activationInfo = [[[ActivationInfo alloc] init] autorelease];
			[activationInfo setMActivationCode:[response mActivationCode]];
			[activationInfo setMDeviceInfo:[[mAppContext getPhoneInfo] getDeviceInfo]];
			[activationInfo setMDeviceModel:[[mAppContext getPhoneInfo] getDeviceModel]];
			
			BOOL successfully = [[self mActivationManager] activate:activationInfo andListener:self];
			DLog (@"Send activate to server after sign up successfully = %d", successfully);
			if (!successfully) {
				[self setMActivateDelegate:nil];
				if ([activateDelegate respondsToSelector:@selector(onComplete:)]) {
					ActivationResponse *activationResponse = [[[ActivationResponse alloc] init] autorelease];
					[activationResponse setMResponseCode:kActivationManagerBusy];
					[activateDelegate onComplete:activationResponse];
				}
			}
		}
    }
}

- (void) requestFailed: (ASIHTTPRequest *) aRequest {
    DLog(@"======= Sign up finished fail ========");
	NSError *error = [aRequest error];
    DLog(@"HTTP sign up request error = %@", error);
	
    SignUpResponse *response = [[[SignUpResponse alloc] init] autorelease];
    [response setMStatus:@"ERROR"];
    [response setMMessage:[[aRequest error] localizedDescription]];
	
	id <SignUpManagerDelegate> delegate = [self mSignUpDelegate];
	
	[self setMSignUpDelegate:nil];
	[self setMActivateDelegate:nil];
	
	if ([delegate respondsToSelector:@selector(signUpDidFinished:signUPResponse:)]) {
		[delegate signUpDidFinished:error signUpResponse:response];
	}
}

#pragma mark -
#pragma mark ActivationListener
#pragma mark -

- (void) onComplete:(ActivationResponse *)aActivationResponse {
	DLog (@"Activate in sign up is complete with resposne = %@", aActivationResponse);
	id <ActivationListener> activateDelegate = [self mActivateDelegate];
	[self setMActivateDelegate:nil];
	if ([activateDelegate respondsToSelector:@selector(onComplete:)]) {
		[activateDelegate onComplete:aActivationResponse];
	}
}

#pragma mark -
#pragma mark Memory management
#pragma mark -

- (void) dealloc {
	[mASIFormDataRequest release];
	[mUrl release];
	[super dealloc];
}

@end
