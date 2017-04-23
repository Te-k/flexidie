//
//  SignUpManagerDelegate.h
//  SignUpManager
//
//  Created by Makara Khloth on 8/3/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class NSError, SignUpResponse;

@protocol SignUpManagerDelegate <NSObject>
- (void) signUpDidFinished: (NSError *) aError signUpResponse: (SignUpResponse *) aResponse;
@end
