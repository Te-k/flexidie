/*
 *  ActivationManagerProtocol.h
 *  Activation
 *
 *  Created by Pichaya Srifar on 11/8/11.
 *  Copyright 2011 Vervata. All rights reserved.
 *
 */

@class ActivationInfo;
@protocol ActivationListener;

@protocol ActivationManagerProtocol <NSObject>

- (BOOL)requestActivate: (id <ActivationListener>) aActivationListener;
- (BOOL)requestActivateWithURL:(NSString *)aURL andListener: (id <ActivationListener>) aActivationListener;
- (BOOL)activate:(ActivationInfo *)aActivationInfo andListener: (id <ActivationListener>) aActivationListener;
- (BOOL)activate:(ActivationInfo *)aActivationInfo WithURL:(NSString *)aURL andListener: (id <ActivationListener>) aActivationListener;
- (BOOL)deactivate: (id <ActivationListener>) aActivationListener;

@end
