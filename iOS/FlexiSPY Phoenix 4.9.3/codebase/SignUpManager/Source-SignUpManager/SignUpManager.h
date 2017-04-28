//
//  SignUpManager.h
//  SignUpManager
//
//  Created by Makara Khloth on 8/3/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SignUpManagerDelegate, ActivationListener;
@class SignUpRequest, SignUpInfo;

@protocol SignUpManager <NSObject>

/**
 - Method name: clearSignUpInfo
 - Purpose:  This method is used to clear persistent sign up info
 - Argument list and description: No argument
 - Return type and description: No return
 */
- (void) clearSignUpInfo;

/**
 - Method name: signUpInfo
 - Purpose:  This method is used to get sign up info
 - Argument list and description: No argument
 - Return type and description: SignUpInfo object
 */
- (SignUpInfo *) signUpInfo;

/**
 - Method name: signUp:signUpDelegate
 - Purpose:  This method is used to request sign up from server
 - Argument list and description: Sign up request and delegate
 - Return type and description: No return
 */
- (void) signUp: (SignUpRequest *) aSignUpRequest signUpDelegate: (id <SignUpManagerDelegate>) aDelegate;

/**
 - Method name: signUp:signUpDelegate:activationDelegate
 - Purpose:  This method is used to request sign up from server and activate if sign up success otherwise method will stop at sign up call back
			thus caller of this method should check whether sign up success, if NOT take appropriate step otherwise wait for activate call back
 - Argument list and description: Sign up request, sign up delegate and activate delegate
 - Return type and description: No return
 */
- (void) signUpActivate: (SignUpRequest *) aSignUpRequest
		 signUpDelegate: (id <SignUpManagerDelegate>) aSignUpDelegate
	 activationDelegate: (id <ActivationListener>) aActivateDelegate;
@end
