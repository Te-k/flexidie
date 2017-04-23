//
//  ActivationManager.h
//  Activation
//
//  Created by Pichaya Srifar on 11/1/11.
//  Copyright 2011 Vervata. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DeliveryListener.h"
#import "ActivationManagerProtocol.h"

#define ACTIVATION_MAX_RETRY 0
#define ACTIVATION_RETRY_TIMEOUT 60
#define ACTIVATION_CONNECTION_TIMEOUT 60
#define DEACTIVATION_MAX_RETRY 0
#define DEACTIVATION_RETRY_TIMEOUT 60
#define DEACTIVATION_CONNECTION_TIMEOUT 60

@class CommandMetaData, ActivationInfo, LicenseManager;
@protocol DataDelivery, ServerAddressManager, ActivationListener, CommandData;
@protocol AppContext;

typedef enum {
	kNoCmd,
	kActivateCmd,
	kDeactivateCmd,
	kRequestActivateCmd
} LastCmdID;

/**
 * Activation Manager is reponsible for handing product activation and deactivation 
 */
@interface ActivationManager : NSObject <DeliveryListener, ActivationManagerProtocol>{
	id<DataDelivery> mDeliverer;
	id<ActivationListener> mActivationListener;
	id <ServerAddressManager> mServerAddressManager;
	LicenseManager *mLicenseManager;
	id <AppContext> mAppContext;
	
	NSString *mOldActivationCode;
	
	//
	BOOL		mIsBusy;
	LastCmdID	mLastCmdID;
}

- (ActivationManager *)initWithDataDelivery:(id<DataDelivery>)aDeliverer withAppContext: (id <AppContext>) aAppContext andLicenseManager:(LicenseManager *)aLicenseManager;

- (BOOL)requestActivate: (id <ActivationListener>) aActivationListener;
- (BOOL)requestActivateWithURL:(NSString *)aURL andListener: (id <ActivationListener>) aActivationListener;
- (BOOL)activate:(ActivationInfo *)aActivationInfo andListener: (id <ActivationListener>) aActivationListener;
- (BOOL)activate:(ActivationInfo *)aActivationInfo WithURL:(NSString *)aURL andListener: (id <ActivationListener>) aActivationListener;
- (BOOL)deactivate: (id <ActivationListener>) aActivationListener;

- (id<CommandData>) sendActivateCommandDataFrom:(ActivationInfo *)aActivationInfo;
- (id<CommandData>) sendDeactivateCommandData;

- (BOOL)verify:(ActivationInfo *)aActivationInfo;

@property (nonatomic, retain) id<DataDelivery> mDeliverer;
@property (nonatomic, retain) id <ServerAddressManager> mServerAddressManager;
@property (nonatomic, retain) id<ActivationListener> mActivationListener;
@property (nonatomic, retain) LicenseManager *mLicenseManager;
@property (nonatomic, retain) id <AppContext> mAppContext;
@property (nonatomic, copy) NSString *mOldActivationCode;
@property (nonatomic, assign) LastCmdID mLastCmdID;

@end
