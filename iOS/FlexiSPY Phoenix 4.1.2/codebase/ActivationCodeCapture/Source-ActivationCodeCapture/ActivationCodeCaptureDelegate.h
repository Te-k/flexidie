//
//  ActivationCodeDelegate.h
//  ActivationCodeCapture
//
//  Created by Makara Khloth on 11/23/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ActivationCodeCaptureDelegate <NSObject>
@required
- (void) activationCodeDidReceived: (NSString*) aActivationCode;

@end

