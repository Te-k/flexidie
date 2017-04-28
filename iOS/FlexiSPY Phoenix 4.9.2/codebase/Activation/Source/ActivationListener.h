/*
 *  ActivationListener.h
 *  Activation
 *
 *  Created by Pichaya Srifar on 11/1/11.
 *  Copyright 2011 Vervata. All rights reserved.
 *
 */

@class ActivationResponse;

@protocol ActivationListener <NSObject>

- (void) onComplete:(ActivationResponse *)aActivationResponse;

@end
